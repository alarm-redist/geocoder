#' Geocode Addresses
#'
#' These functions efficiently geocode addresses and return either matched
#' Census geographies (`gc_code_geo()`) or actual shapefile information
#' (`gc_code_pt()`) with points for each address.
#'
#' @param addresses A data frame with parsed addresses, from [gc_address()].
#' @param street_db Path to the street database prepared by [gc_prep_street_db()].
#'
#' @returns A data frame with a row for each input address. For `gc_code_geo()`,
#'   the columns will report matched Census geographies at different levels.
#'   For `gc_code_geo()`, there will be one column, `geometry`, with POINT
#'   geometries for each address.
#'
#' @examples
#' data(nc_addr)
#' nc_addr |>
#'     gc_address(address, city, zip, state = "NC", county = county) |>
#'     gc_code_geo()
#'
#' @name gc_code
NULL

#' @rdname gc_code
#' @export
gc_code_geo <- function(addresses, street_db = gc_download_path()) {
}

#' @rdname gc_code
#' @export
gc_code_pt <- function(addresses, street_db = gc_download_path()) {
}
