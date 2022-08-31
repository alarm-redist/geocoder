#' Figure out where to download things
#'
#' @noRd
gc_download_path <- function() {
  user_cache <- getOption("geocoder.cache_dir")
  if (!is.null(user_cache)) {
    user_cache
  } else if (getOption("geocoder.use_cache", FALSE) &&
             requireNamespace("rappdirs", quietly = TRUE)) {
    rappdirs::user_cache_dir("geocoder")
  } else {
    tempdir()
  }
}
