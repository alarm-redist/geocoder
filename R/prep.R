#' Prepare Streets Database
#'
#' Download and format address ranges from the Census TIGER/Line API, and then
#' store in Arrow format. One of `county` or `zip` must be provided.
#'
#' @param data A data frame containing columns `state_code` and either
#'   `county_code`, `zip`, or `city`, such as the output of  [gc_address()].
#' @param path The folder where the database will be stored. See
#'   [gc_cache_path()] and the README for more information.
#' @param year The year to download data for.
#' @param save_edge Whether to save road edge shapefile information. Needed to
#'   use [gc_code_pt()].
#' @param save_face Whether to save shapefile face information. Needed to
#'   use [gc_code_block()].
#' @param save_cens Whether to save additional Census geographies (school
#'   districts, NECTAs, etc.) for matching with [gc_code_block()]. Only applies
#'   if `save_face=TRUE`.
#' @param refresh If `TRUE`, force re-downloading of the Census data.
#'
#' @returns The data, invisibly.
#'
#' @examples \donttest{
#' # may take longer than 5 seconds
#' gc_prep_street_db(data.frame(state_code = "37", county_code = "055"))
#' gc_prep_street_db(data.frame(state_code = "37", county_code = "055",
#'                              zip = "27920", city = "Buxton"))
#' }
#'
#' @export
gc_prep_street_db <- function(data, path = gc_cache_path(), year = 2022,
                              save_edge = TRUE, save_face = TRUE, save_cens = FALSE,
                              refresh = FALSE) {
    city_zip_county <- readRDS(
        system.file("extdata", "city_zip_county.rds", package = "geocoder", mustWork = TRUE)
    )
    col_idx <- match(c("state_code", "county_code", "zip", "city"), colnames(data))
    if (is.na(col_idx[1])) {
        cli_abort("{.arg data} must have a {.var state_code} column.")
    }
    if (is.na(col_idx[2]) && is.na(col_idx[3]) && is.na(col_idx[4])) {
        cli_abort("{.arg data} must have a {.var county_code}, {.var zip}, or {.var city} column.")
    }

    need <- tibble()

    if (!is.na(col_idx[2])) { # get counties
        need <- dplyr::distinct(data, .data$state_code, .data$county_code) |>
            dplyr::filter(!is.na(.data$state_code), !is.na(.data$county_code)) |>
            dplyr::bind_rows(need)
    }
    if (!is.na(col_idx[3])) { # match ZIPs to counties
        need <- dplyr::semi_join(
            city_zip_county,
            data[col_idx[c(1, 3)]],
            by = c("state_code", "zip")
        ) |>
            dplyr::distinct(.data$state_code, .data$county_code) |>
            dplyr::filter(!is.na(.data$state_code), !is.na(.data$county_code)) |>
            dplyr::bind_rows(need)
    }
    if (!is.na(col_idx[4])) { # match cities to counties
        need <- dplyr::semi_join(
            city_zip_county,
            data[col_idx[c(1, 4)]],
            by = c("state_code", "city")
        ) |>
            dplyr::distinct(.data$state_code, .data$county_code) |>
            dplyr::filter(!is.na(.data$state_code), !is.na(.data$county_code)) |>
            dplyr::bind_rows(need)
    }
    need <- dplyr::distinct(need)

    res <- purrr::pmap(need, purrr::safely(gc_make_db),
        year = year,
        save_edge = save_edge, save_face = save_face, save_cens = save_cens,
        refresh = refresh
    )
    bad <- purrr::map_lgl(res, function(l) !is.null(l$error))

    if (any(bad)) {
        cli_warn("Errors in downloading data for {sum(bad)} count{?y/ies}")
        print(need[bad, ])
    }

    invisible(data)
}

#' workhorse function to make database
#' @noRd
#' @param state_code state fips
#' @param county_code county fips, one at a time
gc_make_db <- function(state_code, county_code, path = gc_cache_path(), year = 2022,
                       save_edge = FALSE, save_face = FALSE, save_cens = FALSE,
                       refresh = FALSE) {
    # for provided state and county, download the files and subset ----
    outpath <- db_path(path, "addr_feat", year, state_code, county_code)
    needs_addr_feat <- !dir.exists(outpath) ||
        (save_edge && !dir.exists(db_path(path, "edges", year, state_code, county_code))) ||
        (save_face && !dir.exists(db_path(path, "faces", year, state_code, county_code)))
    if (needs_addr_feat || isTRUE(refresh)) {
        cen_addr_feat <- download_cens_addr_feat(state_code, county_code) |>
            dplyr::select(c(
                "TLID", "TFIDL", "TFIDR",
                "LFROMHN", "LTOHN", "RFROMHN", "RTOHN", "ZIPL", "ZIPR",
                "PARITYL", "PARITYR", "PLUS4L", "PLUS4R",
                "geometry"
            )) |>
            dplyr::distinct()
        arrow::write_dataset(sf::st_drop_geometry(cen_addr_feat), outpath)
    }

    if (!dir.exists(outpath <- db_path(path, "featnames", year, state_code, county_code)) ||
        isTRUE(refresh)) {
        cen_featnames <- download_cens_featnames(state_code, county_code) |>
            dplyr::select(c(
                "TLID", "FULLNAME", "NAME", "PREDIRABRV", "PRETYPABRV", "PREQUALABR",
                "SUFDIRABRV", "SUFTYPABRV", "SUFQUALABR", "PREDIR", "PRETYP",
                "PREQUAL", "SUFDIR", "SUFTYP", "SUFQUAL"
            )) |>
            dplyr::mutate(dplyr::across("FULLNAME":"SUFQUAL", str_to_upper))
        arrow::write_dataset(cen_featnames, outpath)
    }


    if (save_face && (
        !dir.exists(outpath <- db_path(path, "faces", year, state_code, county_code)) ||
            isTRUE(refresh)
    )) {
        tfids <- unique(c(cen_addr_feat$TFIDL, cen_addr_feat$TFIDR))

        cen_faces <- download_cens_faces(state_code, county_code) |>
            dplyr::select(c(
                "TFID",
                state = "STATEFP", county = "COUNTYFP",
                tract = "TRACTCE", block_group = "BLKGRPCE", block = "BLOCKCE20",
                "PUMACE20", "COUSUBFP", "SUBMCDFP",
                "ESTATEFP", "CONCTYFP", "PLACEFP", "AIANNHFP", "AIANNHCE", "COMPTYP",
                "TRSUBFP", "TRSUBCE", "ANRCFP", "TTRACTCE", "TBLKGPCE", "ELSDLEA",
                "SCSDLEA", "UNSDLEA", "SDADMLEA", "CD116FP", "SLDUST", "SLDLST",
                "CSAFP", "CBSAFP", "METDIVFP", "CNECTAFP", "NECTAFP", "NCTADVFP"
            )) |>
            dplyr::filter(.data$TFID %in% tfids)

        if (!save_cens) {
            cen_faces <- dplyr::select(
                cen_faces,
                "TFID", "state", "county", "tract", "block_group", "block"
            )
        }
        arrow::write_dataset(cen_faces, outpath)
    }

    # edges: tells us the geometry, TLID, TFIDL, TFIDR
    if (save_edge && (
        !dir.exists(outpath <- db_path(path, "edges", year, state_code, county_code)) ||
            isTRUE(refresh)
    )) {
        dir.create(outpath, showWarnings=FALSE, recursive=TRUE)
        cen_addr_feat |>
            as_tibble() |>
            dplyr::mutate(geometry = wk::as_wkb(.data$geometry)) |>
            dplyr::select("TLID", "geometry") |>
            saveRDS(str_c(outpath, "/edges.rds"), compress = TRUE)
    }

    invisible(NULL)
}
