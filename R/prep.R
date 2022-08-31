#' Prepare Streets Database
#'
#' Download and format address ranges from the Census TIGER/Line API, and then
#' store in Arrow/GeoParquet format. One of `county` or `zip` must be provided.
#'
#' @param county The county or counties to download address ranges for. Can be
#'   specified as a FIPS code or county name that will be partially matched to a
#'   list of all counties.
#' @param state The state that the county belongs to. Partially matched to a
#'   list of all states.
#' @param zip The ZIP code(s) to download address ranges for. Will be converted
#'   to a list of counties that cover all the provided ZIP codes.
#'
#' @returns The path to the database, invisibly.
#'
#' @examples
#' gc_prep_street_db(county="Dare", state="NC")
#'
#' @export
gc_prep_street_db <- function(county=NULL, state=NULL, zip=NULL) {
    db_dir <- gc_download_path()

    invisible(db_dir)
}
