library(tidyverse)
library(tinytiger)
library(sf)

# county_zip_code <- map_dfr(
#     seq_len(nrow(county_fips_2020)),
#     function(i) {
#         Sys.sleep(1)
#         st <- county_fips_2020$state[i]
#         ct <- county_fips_2020$county[i]
#         cat(str_pad(i, 4), '/3143 --- state: ', st, ' county: ', ct, '\n')
#         x <- tt_address_ranges(state = st, county = ct)
#         tibble(
#             state_code = st, county_code = ct, zip_code = sort(unique(c(x$ZIPL, x$ZIPR)))
#         )
#     }
# )

county_zip_code <- readxl::read_excel('data-raw/ZIP_COUNTY_122021.xlsx') |>
    transmute(
        state_code = str_sub(county, 1, 2),
        county_code = str_sub(county, 3, 5),
        zip_code = zip
    )

