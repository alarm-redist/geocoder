# Parsing and Geocoding Strategy

## Package data

#### Internal
- `states`: FIPS lookup (full name, postal code, and AP abbreviation)
- `counties`: FIPS lookup
- `county_zip_code`: ZIP->county lookup built from HUD crosswalk. **TODO** get reverse crosswalk data and build in the other direction
- `street_dirs`: standardized street direction lookup
- `street_types`: standardized street type lookup

#### User-facing
- `nc_addr`: Random 1,000 addresses from Dare County, NC voter file

## Address Parsing: `gc_address()`

**Stage input:** data frame with column(s) containing unparsed addresses

**Stage output:** tibble containing addresses standardized and parsed into columns

1. Check for ZIP codes, first from `zip` argument and then by regex on generic address column
1. Check for state names, first from `state` argument and then by regex on generic address column
1. Check for city names, first from `city` argument and then from dictionary-based regex at end of generic address column
1. Parse street name, type, prefixes and suffixes, and house and unit numbers from remainder of address column
1. Standardize county name and code, if provided in `county` argument

## Data Download and Preparation `gc_prep_street_db()`

**Stage input:**  tibble containing addresses standardized and parsed into columns

**Stage output:** same as input (invisibly). As side effect, downloads and organizes Census street and address data

1. Build a list of county FIPS codes we need data for. This is a concatenation of:
    a. Counties in address tibble
    b. Counties crosswalked from ZIP codes
    c. **TODO**: if no counties or ZIPs, get all counties in state. Consider doing this anyway as xwalk may not be complete
1. Download data for each county:
    a. Download Census `EDGES`, `FACES`, `ADDRFEAT`, and `FEATNAMES` files
    b. Subset to appropriate columns and parse appropriate types
    c. Save as parquet (or rds for the one geo column in `EDGES`)

## Joining Addresses to Streets and Address Ranges

## Geocoding Points

## Geocoding Census Geographies
