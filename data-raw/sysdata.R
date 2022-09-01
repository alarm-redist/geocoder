library(tidyverse)
library(rvest)

ap_abbr = tibble(
    ap = c("Ala.","Alaska","Ariz.",
           "Ark.","Calif.","Colo.","Conn.","Del.","Fla.","Ga.",
           "Hawaii","Idaho","Ill.","Ind.","Iowa","Kan.","Ky.",
           "La.","Md.","Maine","Mass.","Mich.","Minn.","Miss.",
           "Mo.","Mont.","Neb.","Nev.","N.H.","N.J.","N.M.",
           "N.Y.","N.C.","N.D.","Ohio","Okla.","Ore.","Pa.",
           "R.I.","S.C.","S.D.","Tenn.","Texas","Utah","Vt.",
           "Va.","Wash.","W.Va.","Wis.","Wyo.","D.C.", "P.R.", "U.S.V.I."),
    state = c("AL","AK","AZ","AR","CA",
              "CO","CT","DE","FL","GA","HI","ID","IL","IN","IA",
              "KS","KY","LA","MD","ME","MA","MI","MN","MS",
              "MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND",
              "OH","OK","OR","PA","RI","SC","SD","TN","TX",
              "UT","VT","VA","WA","WV","WI","WY","DC", "PR", "VI")
)
states <- censable::stata |>
    select(state_code = fips,
           state_abbr = abb,
           state_name = name) |>
    left_join(rename(ap_abbr, state_ap=ap), by=c("state_abbr"="state")) |>
    as_tibble()

counties <- as_tibble(tinytiger::county_fips_2020) |>
    rename(state_code=state,
           county_code=county,
           county_name=name)


path <- 'data-raw/ZIP_COUNTY.xlsx'
download.file("https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx", path)
county_zip_code <- readxl::read_excel(path) |>
    transmute(
        state_code = str_sub(county, 1, 2),
        county_code = str_sub(county, 3, 5),
        zip_code = zip
    )

street_dirs <- tibble(
    dir_std = c("E","E","E","N","N","N",
                "NE","NE","NE","NE","NW","NW","NW","NW","NW","S",
                "S","S","SE","SE","SE","SE","SW","SW","SW","SW",
                "SW","W","W","W","W"),
    dir_in = c("EAST","ESTE","E","NORTH",
               "NORTE","N","NORTHEAST","NORTH EAST","NORESTE","NE",
               "NORTHWEST","NORTH WEST","NOROESTE","NW","NO",
               "SOUTH","SUR","S","SOUTHEAST","SOUTH EAST","SUDESTE","SE",
               "SOUTHWEST","SOUTH WEST","SUDOESTE","SW","SO",
               "WEST","OESTE","W","O")
)


html <- read_html("https://pe.usps.com/text/pub28/28apc_002.htm")
street_types <- html_element(html, "#ep533076") |>
    html_table(header=TRUE) |>
    select(type_std=`Postal ServiceStandardSuffixAbbreviation`,
           type_in=`CommonlyUsed StreetSuffix orAbbreviation`)
street_types <- bind_rows(
    street_types,
    tibble(type_std=street_types$type_std, type_in=street_types$type_std)
) |>
    arrange(type_std) |>
    distinct()


usethis::use_data(states, counties, county_zip_code, street_dirs, street_types,
                  internal=TRUE, overwrite=TRUE, compress="xz")


# # may not need this
# street_quals <- tibble(
#     qual_std = c("ACC","ACC","ALT","ALT",
#                  "BUS","BUS","BYP","BYP","CON","CON","EXD","EXD",
#                  "EXN","EXN","HST","HST","LP","LP","OLD","OVP","OVP",
#                  "PUB","PUB","PVT","PVT","RMP","RMP","SCN","SCN",
#                  "SPR","SPR","UNP","UNP"),
#     qual_in = c("ACCESS","ACC","ALTERNATE",
#                 "ALT","BUSINESS","BUS","BYPASS","BYP","CONNECTOR",
#                 "CON","EXTENDED","EXD","EXTENSION","EXN","HISTORIC",
#                 "HST","LOOP","LP","OLD","OVERPASS","PVT","PUBLIC",
#                 "PUB","PRIVATE","SCN","RAMP","SPR","SCENIC","RMP",
#                 "SPUR","UNP","UNDERPASS","OVP")
# )

# # manually extract table with Tabula (no headers)  :(
# # <https://www2.census.gov/geo/pdfs/maps-data/data/tiger/tgrshp2021/TGRSHP2021_TechDoc_D.pdf>
# street_type_raw <- read_csv("data-raw/tabula-TGRSHP2021_TechDoc_D.csv", col_names=FALSE)
# street_types <- street_type_raw |>
#     transmute(type_std = str_to_upper(X3),
#               type_full = str_to_upper(X2),
#               as_prefix = X6 == "Y",
#               as_suffix = X7 == "Y")


# # OLD: address range
# library(tinytiger)
# library(sf)
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
