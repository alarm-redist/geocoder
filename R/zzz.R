# dynamically combine some regexes into larger patterns at load-time
.onLoad <- function(libname, pkgname) {
    regex_poss_saint <<- str_glue("\\b(?:{regex_street_types})\\.?( {regex_street_dirs})?\\.?( {regex_unit})? ST\\.? ")
}
