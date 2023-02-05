#' Prepare Streets Database
#'
#' Download and format address ranges from the Census TIGER/Line API, and then
#' store in Arrow format. One of `county` or `zip` must be provided.
#'
#' @param data A data frame containing columns `state_code` and either
#'   `county_code` or `zip_code`, such as the output of  [gc_address()].
#' @param path The folder where the database will be stored. See
#'   [gc_cache_path()] and the README for more information.
#' @param year The year to download data for.
#' @param save_edge Whether to save road edge shapefile information. Needed to
#'   use [gc_code_pt()].
#' @param save_face Whether to save shapefile face information. Needed to
#'   use [gc_code_block()].
#' @param save_cens Whether to save additional Census geographies (school
#'   districts, NECTAs, etc.) for matching with [gc_code_block()].
#' @param refresh If `TRUE`, force re-downloading of the Census data.
#'
#' @returns The data, invisibly.
#'
#' @examples
#' gc_prep_street_db(data.frame(state_code="37", county_code="055"))
#'
#' @export
gc_prep_street_db <- function(data, path = gc_cache_path(), year = 2022,
                              save_edge = TRUE, save_face = TRUE, save_cens = FALSE,
                              refresh = FALSE) {
    col_idx <- match(c("state_code", "county_code", "zip_code"), colnames(data))
    if (is.na(col_idx[1])) {
        cli_abort("{.arg data} must have a {.var state_code} column.")
    }
    if (is.na(col_idx[2]) && is.na(col_idx[2])) {
        cli_abort("{.arg data} must have a {.var county_code} or {.var zip_code} column.")
    }

    need <- tibble()

    if (!is.na(col_idx[2])) { # get counties
        need <- vctrs::vec_unique(data[1:2]) |>
            dplyr::filter(!is.na(.data$state_code), !is.na(.data$county_code)) |>
            dplyr::bind_rows(need)
    }

    if (!is.na(col_idx[3])) { # get ZIPs
        need <- dplyr::semi_join(county_zip_code, data[c(1, 3)],
            by = c("state_code", "zip_code")
        ) |>
            dplyr::distinct(.data$state_code, .data$county_code) |>
            dplyr::filter(!is.na(.data$state_code), !is.na(.data$county_code)) |>
            dplyr::bind_rows(need)
    }

    res <- purrr::pwalk(need, purrr::safely(gc_make_db),
        year = year,
        save_shp = save_shp, save_cens = save_cens, refresh = refresh
    )
    bad <- purrr::map_lgl(res, function(l) !is.null(l$error))

    if (any(bad)) {
        cli_warn("Errors in downloading data for the following {sum(bad)} count{?y/ies}:")
        print(need[bad, ])
    }

    invisible(data)
}
