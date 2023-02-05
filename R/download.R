#' Figure out where to download things
#'
#' @noRd
gc_download_path <- function() {
    user_cache <- getOption("geocoder.cache_dir")
    if (!is.null(user_cache)) {
        user_cache
    } else if (getOption("geocoder.use_cache", FALSE)) {
        rappdirs::user_cache_dir("geocoder")
    } else {
        tempdir()
    }
}


# internal download functions ----
download_cens_addr_feat <- function(state_fips, county_fips, year = 2022) {
    tf <- withr::local_tempfile(fileext = ".zip")
    td <- withr::local_tempdir(pattern = str_glue("{year}_{state_fips}{county_fips}_feat_"))
    curl::curl_download(
        url = str_glue("https://www2.census.gov/geo/tiger/TIGER{year}/ADDRFEAT/tl_{year}_{state_fips}{county_fips}_addrfeat.zip"),
        destfile = tf
    )
    utils::unzip(zipfile = tf, exdir = td)

    str_glue("{td}/tl_{year}_{state_fips}{county_fips}_addrfeat.shp") |>
        sf::read_sf(quiet = TRUE) |>
        dplyr::mutate(dplyr::across(dplyr::where(is.numeric), as.integer))
}

download_cens_addr <- function(state_fips, county_fips, year = 2022) {
    tf <- withr::local_tempfile(fileext = ".zip")
    td <- withr::local_tempdir(pattern = str_glue("{year}_{state_fips}{county_fips}_addr_"))
    curl::curl_download(
        url = str_glue("https://www2.census.gov/geo/tiger/TIGER{year}/ADDR/tl_{year}_{state_fips}{county_fips}_addr.zip"),
        destfile = tf
    )
    utils::unzip(zipfile = tf, exdir = td)

    str_glue("{td}/tl_{year}_{state_fips}{county_fips}_addr.dbf") |>
        foreign::read.dbf() |>
        as_tibble()
}

download_cens_featnames <- function(state_fips, county_fips, year = 2022) {
    tf <- withr::local_tempfile(fileext = ".zip")
    td <- withr::local_tempdir(pattern = str_glue("{year}_{state_fips}{county_fips}_featnames_"))
    curl::curl_download(
        url = str_glue("https://www2.census.gov/geo/tiger/TIGER{year}/FEATNAMES/tl_{year}_{state_fips}{county_fips}_featnames.zip"),
        destfile = tf
    )
    utils::unzip(zipfile = tf, exdir = td)

    str_glue("{td}/tl_{year}_{state_fips}{county_fips}_featnames.dbf") |>
        foreign::read.dbf() |>
        as_tibble()
}

# download_cens_edges <- function(state_fips, county_fips, year = 2022) {
#     tf <- withr::local_tempfile(fileext = ".zip")
#     td <- withr::local_tempdir(pattern = str_glue("{year}_{state_fips}{county_fips}_edges_"))
#     curl::curl_download(
#         url = str_glue("https://www2.census.gov/geo/tiger/TIGER2022/EDGES/tl_{year}_{state_fips}{county_fips}_edges.zip"),
#         destfile = tf
#     )
#     utils::unzip(zipfile = tf, exdir = td)
#
#     sf::st_read(str_glue(paste0(td, "/tl_{year}_{state_fips}{county_fips}_edges.shp")), quiet = TRUE)
# }

download_cens_faces <- function(state_fips, county_fips, year = 2022) {
    tf <- withr::local_tempfile(fileext = ".zip")
    td <- withr::local_tempdir(pattern = str_glue("{year}_{state_fips}{county_fips}_faces_"))
    curl::curl_download(
        url = str_glue("https://www2.census.gov/geo/tiger/TIGER{year}/FACES/tl_{year}_{state_fips}{county_fips}_faces.zip"),
        destfile = tf
    )
    utils::unzip(zipfile = tf, exdir = td)

    str_glue("{td}/tl_{year}_{state_fips}{county_fips}_faces.shp") |>
        sf::read_sf(quiet = TRUE) |>
        dplyr::mutate(dplyr::across(dplyr::where(is.numeric), as.integer))
}
