
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **geocoder**: Efficiently Geocode Addresses <img src="man/figures/logo.png" align="right" height="156" />

This project is under development. It should not work. If it happens to
appear to work, we make no guarantees of accuracy.

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/alarm-redist/geocoder/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/alarm-redist/geocoder/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `geocoder` is to …

## Installation

You can install the development version of `geocoder` like so:

``` r
remotes::install_github("alarm-redist/geocoder")
```

## Example

``` r
library(geocoder)
## basic example code
```

## Cache

Downloads will go to `options(geocoder.cache_dir)` if it is set. If it
is not, and `options(geocoder.use_cache = TRUE)`, downloads will be
cached between sessions in `rappdirs::user_cache_dir("geocoder")`. If If
`options(geocoder.use_cache = FALSE)` (the default), then the cache will
be in a temporary directory that does not persist between sessions. You
can check the size of the cache and clear it with `gc_cache_size()` and
`gc_cache_clear()`.
