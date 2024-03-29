#' Geocode Addresses
#'
#' These functions efficiently geocode addresses and return either matched
#' Census geographies (`gc_code_block()`) or actual shapefile information
#' (`gc_code_pt()`) with points for each address.
#'
#' @param addresses A data frame with parsed addresses, from [gc_address()].
#' @param street_db Path to the street database prepared by [gc_prep_street_db()].
#'
#' @returns A data frame with a row for each input address. For `gc_code_block()`,
#'   the columns will report matched Census geographies at different levels.
#'   For `gc_code_block()`, there will be one column, `geometry`, with POINT
#'   geometries for each address.
#'
#' @examples
#' data(nc_addr)
#' nc_addr |>
#'     gc_address(address, city, zip, state = "NC", county = county) |>
#'     gc_code_block()
#'
#' @name gc_code
NULL

#' @rdname gc_code
#' @export
gc_code_block <- function(addresses, street_db = gc_download_path()) {
}

#' @rdname gc_code
#' @export
gc_code_pt <- function(addresses, street_db = gc_download_path()) {
}

#' Handles the internal joining
#' @noRd
gc_code_feat <- function(addresses, path = gc_cache_path(), year = 2022) {
    addresses <- arrow::arrow_table(addresses)
    # arrow open data set to load in the databases
    # filter to year and then do the merges

    addr_feat <- arrow::open_dataset(
        sources = db_path(path, "addr_feat"),
        schema = arrow::schema(
            year = int32(), state = utf8(), county = utf8(),
            TLID = int32(), TFIDL = int32(), TFIDR = int32(), LFROMHN = utf8(),
            LTOHN = utf8(), RFROMHN = utf8(), RTOHN = utf8(), ZIPL = utf8(),
            ZIPR = utf8(), PARITYL = utf8(), PARITYR = utf8(), PLUS4L = utf8(),
            PLUS4R = utf8()
        )
    )
    featnames <- arrow::open_dataset(
        sources = db_path(path, "featnames"),
        schema = arrow::schema(
            year = int32(), state = utf8(), county = utf8(),
            TLID = int32(), FULLNAME = utf8(), NAME = utf8(), PREDIRABRV = utf8(),
            PRETYPABRV = utf8(), PREQUALABR = utf8(), SUFDIRABRV = utf8(),
            SUFTYPABRV = utf8(), SUFQUALABR = utf8(), PREDIR = utf8(),
            PRETYP = utf8(), PREQUAL = utf8(), SUFDIR = utf8(), SUFTYP = utf8(),
            SUFQUAL = utf8()
        )
    )

    cli::cli_abort("yikes: do not use this yet")
    # addresses <- addresses |>
    addresses |>
        dplyr::left_join(
            y = featnames,
            by = c(
                state_code = "state",
                county_code = "county"
                # zip = "",
                # num = "",
                # num_suff = "",
                # street_dir_pre = "",
                # street_name = "NAME",
                # street_type = "SUFTYP",
                # street_dir_suff = "SUFDIR"
                # unit = "",
                # city = ""
            ),
        ) |>
        dplyr::collect()



}
