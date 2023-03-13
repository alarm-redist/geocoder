library(tidyverse)
library(here)

fmt_city <- function(x) {
    x |>
        str_replace_all("^M(A?)C ", "M\\1C") |>
        str_replace_all("^O[ ']", "O") |>
        str_replace_all("^ST\\.? ", "SAINT ") |>
        str_remove_all("[.,']") |>
        stringi::stri_trans_general("Latin-ASCII")
}

# Load data ---------

d_st = group_by(states, state_code) |>
    slice_head(n=1) |>
    ungroup() |>
    rename(state_county = state_in)

# Read HUD crosswalks
if (!file.exists(path_zc <- "data-raw/ZIP_COUNTY.xlsx")) {
    curl::curl_download("https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx", path_zc)
}
if (!file.exists(path_cz <- "data-raw/COUNTY_ZIP.xlsx")) {
    curl::curl_download("https://www.huduser.gov/portal/datasets/usps/COUNTY_ZIP_122021.xlsx", path_cz)
}
d_zc <- readxl::read_excel(path_zc)
d_cz <- readxl::read_excel(path_cz)

d_hud <- bind_rows(d_zc, d_cz) |>
    rows_update(tibble(zip="20736", county="24009"), by="zip") |>
    select(zip, fips=county, city=usps_zip_pref_city, state=usps_zip_pref_state) |>
    separate(fips, c("state_code", "county_code"), sep=2) |>
    mutate(city = fmt_city(city)) |>
    distinct()
rm(d_zc, d_cz)

# Read 'free ZIP code database' which includes alternative city names
path <- here("data-raw/free-zipcode-database.csv")
if (!file.exists(path)) {
    download.file("http://federalgovernmentzipcodes.us/free-zipcode-database.csv", path)
}
d_free <- read_csv(path, show_col_types=FALSE) |>
    select(zip = Zipcode, city=City, state=State, type=ZipCodeType, class=LocationType) |>
    mutate(city = fmt_city(city))

# Read USGS populated places data
path <- here("data-raw/POP_PLACES.zip")
if (!file.exists(path)) {
    download.file("https://geonames.usgs.gov/docs/stategaz/POP_PLACES.zip", path)
}
d_gnis <- read_delim(path, delim="|", show_col_types=FALSE) |>
    select(city=FEATURE_NAME,  county=COUNTY_NAME, state=STATE_ALPHA,
           state_code=STATE_NUMERIC, county_code=COUNTY_NUMERIC) |>
    mutate(city = fmt_city(str_to_upper(str_remove(city, " \\(.+?\\)$"))),
           county = str_remove(county, " \\(.+?\\)$")) |>
    distinct()


# Combine ---------


d = d_free |>
    filter(type != "MILITARY", class != "NOT ACCEPTABLE") |>
    full_join(d_hud, by=c("zip", "city", "state"), multiple="all") |>
    left_join(d_gnis, by=c("city", "state"), suffix=c("", "_gnis"), multiple="all") |>
    mutate(state_code = coalesce(state_code, state_code_gnis),
           county_code = coalesce(county_code, county_code_gnis),
           priority = case_when(
               class == "PRIMARY" & type == "STANDARD" ~ 4L,
               class == "PRIMARY" & type == "PO BOX" ~ 3L,
               class == "PRIMARY" & type == "UNIQUE" ~ 3L,
               is.na(class) ~ 2L,
               class == "ACCEPTABLE" & type == "STANDARD" ~ 1L,
               TRUE ~ 0L
           )) |>
    left_join(select(d_hud, zip, state_code, county_code), by="zip",
              suffix=c("", "_hud"), multiple="any") |>
    mutate(state_code = coalesce(state_code, state_code_hud),
           county_code = coalesce(county_code, county_code_hud)) |>
    distinct(zip, city, state, priority, state_code, county_code) |>
    arrange(zip, desc(priority), city)

write_rds(d, "inst/extdata/city_zip_county.rds", compress="gz")

regex_city = rgx_trie(unique(d$city))
write_rds(regex_city, "inst/extdata/city_regex.rds", compress="gz")
cat(regex_city, file="inst/extdata/city_regex.txt")

saints = filter(d, str_starts(city, "SAINT ")) |>
    pull(city) |>
    unique() |>
    str_sub(7) |>
    sort()
saints = saints[!saints %in% d$city]
write_rds(saints, here("data-raw/saints.rds"), compress="gz")

