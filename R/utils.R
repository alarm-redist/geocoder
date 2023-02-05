str_pmatch <- function(x, table) {
    vapply(x, pmatch, 0L, table = table, USE.NAMES = FALSE)
}

na_if <- function(x, y) {
    x[x == y] <- NA
    x
}

coalesce <- function(x, y) {
    x[is.na(x)] <- y
    x
}

sort_long_short <- function(x) {
    x[order(nchar(x), x, decreasing = TRUE)]
}
