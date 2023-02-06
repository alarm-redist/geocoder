str_pmatch <- function(x, table) {
    vapply(x, pmatch, 0L, table = table, USE.NAMES = FALSE)
}

na_if <- function(x, y) {
    x[x == y] <- NA
    x
}

coalesce <- function(x, y) {
    x[is.na(x)] <- y
    x
}

sort_long_short <- function(x) {
    x[order(nchar(x), x, decreasing = TRUE)]
}

#' Database path
#' @noRd
#'
#' @param path defaults to `gc_cache_path()`
#' @param type database you want (one of 'addr_feat', 'featnames', 'faces', 'edges')
#' @param year integer year
#' @param state_code state fips
#' @param county_code county fips
db_path <- function(path, type, year, state_code, county_code) {
    if (missing(year)) {
        str_glue("{path}/{type}")
    } else {
        str_glue("{path}/{type}/year={year}/state={state_code}/county={county_code}")
    }
}
