#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang eval_tidy enquo
#' @importFrom cli cli_abort cli_warn cli_inform
#' @import stringr
#' @import tibble
## usethis namespace: end
NULL

regex_state <- ""
regex_street_types <- ""
regex_street_dirs <- ""
regex_street_city <- ""
regex_street <- ""
regex_street_only <- ""
regex_unit <- "(?:APT |APARTMENT |UNIT |SUITE |# ?|NO\\.? |STE\\.? )[0-9A-Z]+"
regex_saints <- ""
regex_poss_saint <- ""


.onLoad <- function(libname, pkgname) {
    regex_state <<- states$state_in |>
        sort_long_short() |>
        str_c("\\b", mid=_, "$", collapse="|") |>
        str_replace_all("\\.", "\\\\.") |>
        str_c("(", mid=_, ")")
    regex_street_types <<- street_types$type_in |>
        sort_long_short() |>
        str_c(mid=_, collapse="|") |>
        str_c("(", mid=_, ")")
    regex_part_dir <- street_dirs$dir_in |>
        sort_long_short() |>
        str_c(mid=_, collapse="|")
    regex_street_dirs <<- str_c("(", regex_part_dir, ")")
    which_short <- which(str_length(street_dirs$dir_in) <= 2)
    regex_street_dirs_short <<- street_dirs$dir_in[which_short] |>
        sort_long_short() |>
        str_c(mid=_, collapse="|") |>
        str_c("(", mid=_, ")")

    regex_street_city <<- str_glue("^(\\d+)([A-Z]?)(?: {regex_street_dirs})?\\.?((?: \\S+)+) ",
                                   "(?:{regex_street_types})\\.?(?: {regex_street_dirs_short})?\\.?",
                                   "( {regex_unit})?((?: \\S+)+)")
    regex_street <<- str_glue("^(\\d+)([A-Z]?)(?: {regex_street_dirs})?\\.?((?: \\S+)+) ",
                              "(?:{regex_street_types})\\.?(?: {regex_street_dirs})?\\.?( {regex_unit})?$")
    regex_street_only <<- str_glue("^(?:{regex_street_dirs} )?\\.?(\\S+(?: \\S+)*) ",
                              "(?:{regex_street_types})\\.?(?: {regex_street_dirs})?\\.?$")
    regex_poss_saint <<- str_glue("\\b(?:{regex_street_types})\\.?( {regex_street_dirs})?\\.?( {regex_unit})? ST\\.? ")

    regex_saints <<- str_c(
        "ST\\.? (AGATHA|ALBANS|ALBANS BAY|AMANT|ANN|ANNE|ANSGAR|AUGUSTINE|",
        "BONAVENTURE|BONIFACE|BONIFACIUS|CHARLES|",
        "CLAIR|CLAIR SHORES|CLAIRSVILLE|CLOUD|COLUMBANS|CROIX|CROIX FALLS|",
        "DONATUS|FRANCISVILLE|GABRIEL|GENEVIEVE|",
        "GEORGE ISLAND|GEORGES|GERMAIN|HEDWIG|HELENA ISLAND|HELENS|",
        "HILAIRE|IGNACE|IGNATIUS|INIGOES|JAMES|JO|JOE|JOHN|",
        "JOHNS|JOHNSBURY|JOHNSBURY CENTER|JOHNSVILLE|LANDRY|",
        "LIBORY|LOUIS|MARIE|MARIE|MARIES|",
        "MARTINVILLE|MARY|MARY OF THE WOODS|MARYS|MARYS CITY|MEINRAD|",
        "MICHAELS|NAZIANZ|OLAF|ONGE|PAUL|PAUL ISLAND|PAUL PARK|",
        "PAULS|PETER|PETERS|REGIS|REGIS FALLS|SIMONS ISLAND|",
        "STEPHENS CHURCH|VRAIN|XAVIER)$"
        )
}

