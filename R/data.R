#' North Carolina Address Data
#'
#' A dataset containing 1,000 fake address records.
#' Created by randomizing a subset of the public Dare County, North Carolina voter file.
#' Driver's license records have no connection to the listed addresses.
#'
#' @format A data frame with 1,000 rows and 5 records:
#' \describe{
#'   \item{address}{Street address. May be NA}
#'   \item{city}{City of street address. May be NA}
#'   \item{zip}{5-digit ZIP code. May be NA}
#'   \item{county}{County name}
#'   \item{drivers_lic}{TRUE if the voter has a driver's license, FALSE if not.}
#' }
#'
#' @source \url{https://www.ncsbe.gov/results-data/voter-registration-data}
"nc_addr"
