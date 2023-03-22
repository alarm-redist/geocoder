# Parsing and Geocoding Strategy

The modal user-facing workflow we are aiming for:

```r
d_addr |> # user's data, contains addresses
    gc_address(address, zip=zip_code, state="PA") |>
    gc_prep_street_db() |> 
    gc_code_pt() # or gc_code_block()
```

## Package data

**Internal** (see [`sysdata.R`](data-raw/sysdata.R))
- `states`: FIPS lookup (full name, postal code, and AP abbreviation)
- `counties`: FIPS lookup
- `street_dirs`: standardized street direction lookup
- `street_types`: standardized street type lookup

**Larger internal** (see [`city_zip_county.R`](data-raw/city_zip_county.R))
- `city_zip_county.rds`: ZIP/county/city combinations table built from HUD crosswalks, ZIP database, and USGS GNIS.
- `city_regex.rds`: trie-ified regex matching all city names in `city_zip_county` table

**Regular expressions**

We programatically build regexes for address parsing.
These are pre-built in [`build_regex.R`](R/build_regex.R), with some higher-level regexes constructed on-the-fly.
Larger regexes are [trie-based](https://en.wikipedia.org/wiki/Trie) regexes because we are matching many options.
See also `city_regex.rds` above.

**User-facing** (see [`nc_addr.R`](data-raw/nc_addr.R))
- `nc_addr`: Random 1,000 addresses from Dare County, NC voter file

## Address Parsing: `gc_address()`
See [`address.R`](R/address.R); [`test-address.R`](tests/testthat/test-address.R)

**Stage input:** data frame with column(s) containing unparsed addresses

**Stage output:** tibble containing addresses standardized and parsed into columns

1. Check for ZIP codes, first from `zip` argument and then by regex on generic address column
1. Check for state names, first from `state` argument and then by regex on generic address column
1. Check for city names, first from `city` argument and then from dictionary-based regex at end of generic address column
1. Parse street name, type, prefixes and suffixes, and house and unit numbers from remainder of address column
1. Standardize county name and code, if provided in `county` argument

For all steps, if we parse a component from the generic address column, we remove that component before the next step.
Thus "1 OXFORD ST CAMBRIDGE MA 02138" becomes, in order:
1. "1 OXFORD ST CAMBRIDGE MA 02138"
1. "1 OXFORD ST CAMBRIDGE MA"
1. "1 OXFORD ST CAMBRIDGE"
1. "1 OXFORD ST"


## Data Download and Preparation: `gc_prep_street_db()`
See [`prep.R`](R/prep.R); [`test-prep.R`](tests/testthat/test-prep.R)

**Stage input:**  tibble containing addresses standardized and parsed into columns

**Stage output:** same as input (invisibly). As side effect, downloads and organizes Census street and address data

1. Build a list of county FIPS codes we need data for. This is a concatenation of:
    1. Counties in address tibble
    1. Counties crosswalked from ZIP codes
    1. **TODO**: if no counties or ZIPs, get all counties in state. Consider doing this anyway as xwalk may not be complete
1. Download data for each county:
    1. Download Census `EDGES`, `FACES`, `ADDRFEAT`, and `FEATNAMES` files
    1. Subset to appropriate columns and parse appropriate types
    1. Save as parquet (or rds for the one geo column in `EDGES`)


## Joining Addresses to Streets and Address Ranges: `gc_code_feat()` [internal]
See [`geocode.R`](R/geocode.R)

## Geocoding Points: `gc_prep_street_db()`
See [`geocode.R`](R/geocode.R)

## Geocoding Census Geographies: `gc_prep_street_db()`
See [`geocode.R`](R/geocode.R)
