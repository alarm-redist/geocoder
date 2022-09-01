#' Parse Addresses
#'
#' @param data A data frame
#' @param address The column containing the address. Can be a one-line address
#'   or just the street address component (if `city`, `state`, etc. are
#'   provided). Tidy-evaluated within `data`.
#' @param city A column containing city names. Tidy-evaluated within `data`.
#' @param zip A column containing ZIP codes. Tidy-evaluated within `data`.
#' @param state A column containing states. Tidy-evaluated within `data`.
#' @param county  A column containing counties. May help in matching cities if
#'   ZIPs are not present. Tidy-evaluated within `data`.
#'
#' @return A data frame containing columns with the parsed address. These match
#'   the Census format for street addresses.
#'
#' @examples
#' data(nc_addr)
#' gc_address(nc_addr)
#'
#' @export
gc_address <- function(data, address, city=NULL, zip=NULL, state=NULL, county=NULL) {
    if (!is.character(address)) {
        cli_abort("{.arg address} must be a character vector")
    }

    # get addresses, split into words, and convert to long format for vectorized processing
    address <- eval_tidy(enquo(address), data)
    address <- address |>
        str_remove_all("[.,
        str_split(str_squish(address), " ", simplify=FALSE)
    idx <- rep(seq_along(address), lengths(address))
    pos_fwd <- unlist(lapply(address, seq_along),
                      recursive=FALSE, use.names=FALSE)
    pos_rev <- unlist(lapply(address, \(x) seq.int(-length(x), -1)),
                      recursive=FALSE, use.names=FALSE)
    address <- unlist(address, recursive=FALSE, use.names=FALSE)

    # pull out various components, either from `address` or specific arguments
    if (is.null(zip)) {
        extr <- extract_zip(address, pos_rev)
    } else {
        zip <- eval_tidy(enquo(zip), data) |>
            standardize_zip()
    }

    if (!is.null(city)) city = eval_tidy(enquo(city), data)
    if (!is.null(state)) state = eval_tidy(enquo(state), data)
    if (!is.null(county)) county = eval_tidy(enquo(county), data)
}

if (F) {
x = with(nc_addr, paste0(address, ", ", city, ", NC ", zip)); x[is.na(nc_addr$address)] = NA_character_; address = x
}


regex_zip = "^(\\d{5})([+-]\\d{4})?$" # 5 digits followed by optional 4-digit code
extract_zip <- function(address, pos_rev) {
    have_zip = which(str_detect(address, regex_zip) & (pos_rev >= -2L))
}
standardize_zip <- function(zip) {
    str_match(zip, regex_zip)[, 1]
}
