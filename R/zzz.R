# dynamically combine some regexes into larger patterns at load-time
.onLoad <- function(libname, pkgname) {
    # regex_street_city <<- str_glue(
    #     "^(\\d+)([A-Z]?)(?: {regex_street_dirs})?\\.?((?: \\S+)+?) ",
    #     "(?:{regex_street_types})\\.?(?: {regex_street_dirs_short})?\\.?",
    #     "( {regex_unit})?((?: \\S+)+)"
    # )

    regex_poss_saint <<- str_glue("\\b(?:{regex_street_types})\\.?( {regex_street_dirs})?\\.?( {regex_unit})? ST\\.? ")
}
