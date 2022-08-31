library(dplyr)

# Download and format voter file from NC
make_nc_df = function(county="Dare") {
  counties = tinytiger::county_fips_2020$name[tinytiger::county_fips_2020$state == "37"]
  county_i = match(paste(county, "County"), counties)

  url = glue::glue("https://s3.amazonaws.com/dl.ncsbe.gov/data/ncvoter{county_i}.zip")
  tmp = withr::local_tempdir()
  zipfile = paste(tmp, "ncvoters.zip")
  download.file(url, zipfile, quiet=TRUE)
  unzip(zipfile, exdir=tmp)
  rawfile = glue::glue("{tmp}/ncvoter{county_i}.txt")

  voters_raw = readr::read_tsv(rawfile, show_col_types=F,
                               col_types=readr::cols(age_at_year_end="i",
                                                     birth_year="i",
                                                     .default="c"))

  race_codes = c(A="asian", B="black", I="aian", M="other", O="other",
                 P="other", W="white")
  party_codes = c(UNA="ind", DEM="dem", REP="rep", LIB="lib")

  voters = voters_raw %>%
    filter(race_code != "U", ethnic_code != "UN") %>%
    mutate(race = factor(dplyr::if_else(ethnic_code == "HL", "hisp",
                                        race_codes[race_code]),
                         levels=c("white", "black", "hisp", "asian", "aian", "other")),
           gender = as.factor(gender_code),
           party = factor(party_codes[party_cd],
                          levels=c("dem", "ind", "rep", "lib")),
           age = cut(age_at_year_end,
                     breaks=c(18, 20, 25, 30, 35, 40, 45, 50, 55,
                              60, 62, 65, 67, 70, 75, 80, 85, 150),
                     right=FALSE),
           address = dplyr::na_if(res_street_address, "REMOVED"),
           city = res_city_desc,
           county_name = county,
           county = paste0("37", tinytiger::county_fips_2020$county[county_i]),
           lic = drivers_lic == "Y") %>%
    select(regnum=voter_reg_num,
           last_name:middle_name, suffix=name_suffix_lbl,
           address, city, zip=zip_code, county, county_name,
           race, gender, age, birth_state, party, lic) %>%
    dplyr::slice(which(!is.na(.$last_name)))

  unlink(zipfile)
  unlink(rawfile)

  voters
}

nc_full = make_nc_df("Dare")

nc_addr = nc_full |>
  select(address:zip, county=county_name, drivers_lic=lic) |>
  group_by(zip) |>
  mutate(drivers_lic = sample(drivers_lic)) |>
  ungroup() |>
  slice_sample(n=1000)

usethis::use_data(nc_addr, overwrite=TRUE, compress="xz")
