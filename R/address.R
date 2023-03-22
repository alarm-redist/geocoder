#' Parse Addresses
#'
#' @param data A data frame
#' @param address The column containing the address. Can be a one-line address
#'   or just the street address component (if `city`, `state`, etc. are
#'   provided). Tidy-evaluated within `data`.
#' @param city A column containing city names. Tidy-evaluated within `data`.
#' @param zip A column containing ZIP codes. Tidy-evaluated within `data`.
#' @param state A column containing states. Tidy-evaluated within `data`.
#' @param county  A column containing counties. Matched to an internal list and
#'   passed on to the output. Tidy-evaluated within `data`.
#'
#' @return A data frame containing columns with the parsed address. These match
#'   the Census format for street addresses.
#'
#' @examples
#' gc_address(NULL, "125 5th St S St. Petersburg FL 33701")
#' gc_address(NULL, "1225 St Charles St St Louis MO")
#'
#' data(nc_addr)
#' gc_address(nc_addr, address = address, city = city, zip = zip, county = county, state = "NC")
#'
#' @export
gc_address <- function(data, address, city = NULL, zip = NULL, state = NULL, county = NULL) {
    # get addresses, split into words, and convert to long format for vectorized processing
    address <- eval_tidy(enquo(address), data)
    if (!is.character(address)) cli_abort("{.arg address} must be a character vector")
    address <- address |>
        str_remove_all(fixed("'")) |> # remove apostrophes
        str_replace_all(fixed(","), " ") |> # remove commas
        str_to_upper() |>
        str_squish()

    # pull out various components, either from `address` or specific arguments
    zip <- eval_tidy(enquo(zip), data)
    if (is.null(zip)) {
        extr <- extract_zip(address)
        address <- extr$address
        zip <- extr$zip
    }
    zip <- standardize_zip(zip)

    state <- eval_tidy(enquo(state), data)
    if (is.null(state)) {
        extr <- extract_state(address)
        address <- extr$address
        state <- extr$state
        if (any(is.na(state[!is.na(address)]))) {
            cli_abort(c("State information missing.",
                        ">"="If states are not included in the {.var address} column,
                        the state must be provided in the {.arg state} argument."))
        }
    }
    state <- standardize_state(state)
    if (length(state) == 1) state <- rep(state, length(address))

    city <- eval_tidy(enquo(city), data)
    if (is.null(city)) {
        extr <- extract_city(address)
        address <- extr$address
        city <- extr$city
    } else {
        city <- str_replace(city, regex_saints, "SAINT \\1")
    }

    # parse street
    out <- parse_street(address)

    county <- eval_tidy(enquo(county), data)
    if (!is.null(county)) {
        county <- standardize_county(county, state)
    } else {
        county <- NA_character_
    }
    if (length(county) == 1) county <- rep(county, length(address))

    as_tibble(cbind(
        tibble(state_code = state, county_code = county, zip_code = zip, city = city),
        out
    ))
}

extract_city <- function(address) {
    regex_path <- system.file("extdata/city_regex.rds", package="geocoder")
    regex_city <- str_c("\\b", readRDS(regex_path), "$")
    address <- address |>
        str_replace(regex_poss_saint, "\\1\\2\\4 SAINT ") |>
        str_replace(regex_saints, "SAINT \\1")
    idx <- str_locate(address, regex_city)
    part_1 <- str_trim(str_sub(address, 1, idx[, 1] - 1L))

    list(
        address = coalesce(part_1, address),
        city = str_sub(address, idx)
    )
}

# Streets and Cities ------
parse_street_city <- function(address) {
    regex_city <- readRDS(system.file("extdata/city_regex.rds", package="geocoder"))
    regex_street_city <- str_glue(
        "^(\\d+)([A-Z]?)(?: {regex_street_dirs})?\\.?((?: \\S+)+?) ",
        "(?:{regex_street_types})\\.?(?: {regex_street_dirs_short})?\\.?",
        "( {regex_unit})?((?: \\S+)+)$"
    )

    out <- address |>
        str_replace(regex_poss_saint, "\\1\\2\\4 SAINT ") |>
        str_replace(regex_saints, "SAINT \\1") |>
        str_match(regex_street_city)
    tibble(
        num = as.integer(out[, 2]),
        num_suff = na_if(out[, 3], ""),
        street_dir_pre = street_dirs$dir_std[match(out[, 4], street_dirs$dir_in)],
        street_name = str_trim(out[, 5]),
        street_type = street_types$type_std[match(out[, 6], street_types$type_in)],
        street_dir_suff = street_dirs$dir_std[match(out[, 7], street_dirs$dir_in)],
        unit = str_trim(out[, 8]),
        city = str_trim(out[, 9]),
    )
}

parse_street <- function(address) {
    regex_street <- str_glue(
        "^(\\d+)([A-Z]?)(?: {regex_street_dirs})?\\.?((?: \\S+)+) ",
        "(?:{regex_street_types})\\.?(?: {regex_street_dirs})?\\.?( {regex_unit})?(?: [A-Z]+)*$"
    )

    out <- str_match(address, regex_street)
    tibble(
        num = as.integer(out[, 2]),
        num_suff = na_if(out[, 3], ""),
        street_dir_pre = street_dirs$dir_std[match(out[, 4], street_dirs$dir_in)],
        street_name = str_trim(out[, 5]),
        street_type = street_types$type_std[match(out[, 6], street_types$type_in)],
        street_dir_suff = street_dirs$dir_std[match(out[, 7], street_dirs$dir_in)],
        unit = str_trim(out[, 8])
    )
}

parse_street_only <- function(street) {
    regex_street_only <- str_glue(
        "^(?:{regex_street_dirs} )?\\.?(\\S+(?: \\S+)*) ",
        "(?:{regex_street_types})\\.?(?: {regex_street_dirs})?\\.?$"
    )

    out <- street |>
        str_remove(" ?\\(.+\\) ?") |>
        str_replace("RD (\\d+)$", "RD \\1 RD") |>
        str_replace("RTE (\\d+)$", "RTE \\1 RTE") |>
        str_replace("HWY (\\d+)$", "HWY \\1 HWY") |>
        str_match(regex_street_only)
    tibble(
        street_dir_pre = street_dirs$dir_std[match(out[, 2], street_dirs$dir_in)],
        street_name = str_trim(out[, 3]),
        street_type = street_types$type_std[match(out[, 4], street_types$type_in)],
        street_dir_suff = street_dirs$dir_std[match(out[, 5], street_dirs$dir_in)]
    )
}

# Zip codes -------
regex_zip <- r"(^(\d{5})([+-]\d{4})?$)" # 5 digits followed by optional 4-digit code
extract_zip <- function(address) {
    final_word <- word(address, -1L)
    have_zip <- which(str_detect(final_word, regex_zip))
    trim <- rep(-1L, length(address))
    trim[have_zip] <- -2L
    zip <- final_word
    zip[-have_zip] <- NA_character_

    list(
        address = word(address, 1, trim),
        zip = zip
    )
}
standardize_zip <- function(zip) {
    str_match(zip, regex_zip)[, 1]
}

# States ------
extract_state <- function(address) {
    idx <- str_locate(address, regex_state)
    part_1 <- str_trim(str_sub(address, 1, idx[, 1] - 1L))

    list(
        address = coalesce(part_1, address),
        state = str_sub(address, idx)
    )
}
standardize_state <- function(state) {
    states$state_code[str_pmatch(state, states$state_in)]
}

# Counties ------
standardize_county <- function(county, state) {
    county <- str_to_upper(county)
    cty_lookup <- split(counties, counties$state_code)
    vapply(seq_along(county), function(i) {
        if (is.na(state[i])) {
            return(NA_character_)
        }
        tbl <- cty_lookup[[state[i]]]
        j <- pmatch(county[i], tbl$county_name)
        tbl$county_code[j]
    }, "")
}
