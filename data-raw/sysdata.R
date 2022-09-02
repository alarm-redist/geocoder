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
states <- bind_rows(
    select(states, state_code, state_in=state_abbr),
    select(states, state_code, state_in=state_name),
    select(states, state_code, state_in=state_ap)
) |>
    arrange(state_code) |>
    drop_na() |>
    mutate(state_in = str_to_upper(state_in)) |>
    distinct()


counties <- as_tibble(tinytiger::county_fips_2020) |>
    rename(state_code=state,
           county_code=county,
           county_name=name)


path <- 'data-raw/ZIP_COUNTY.xlsx'
curl::curl_download("https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx", path)
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


street_types <- rvest::read_html("https://pe.usps.com/text/pub28/28apc_002.htm") |>
    rvest::html_element("#ep533076") |>
    rvest::html_table(header=TRUE) |>
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

