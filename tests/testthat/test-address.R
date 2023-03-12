test_that("addresses are parsed correctly", {
    d_in1 = data.frame(address = "505  Burns Drive",
                      city = "KILL DEVIL HILLS",
                      zip = "27948")
    d_in2 = data.frame(address = "505  Burns Drive, Kill Devil Hills NC 27948 ")

    actual1 = gc_address(d_in1, address=address, city=city, zip=zip, state="N.C.")
    actual2 = gc_address(d_in2, address=address)

    expected = tibble(state_code = "37",
                      county_code = NA_character_,
                      zip_code = "27948",
                      num = 505L,
                      num_suff = NA_character_,
                      street_dir_pre = NA_character_,
                      street_name = "BURNS",
                      street_type = "DR",
                      street_dir_suff = NA_character_,
                      unit = NA_character_,
                      city = "KILL DEVIL HILLS")

    expect_equal(actual1, expected)
    expect_equal(actual2, expected)
})

test_that("street-city parser works correctly", {
    addr = c("62R OAK CIRCLE SAN RAFAEL",
             "1234 NE 117TH ST S SUITE 7 KIRKLAND",
             "1408 34TH AVE N ST PETERSBURG",
             "2243 AUBURN ST S #8B ST PETERSBURG",
             "505 S SOUTH ST PETERSBURG",
             "1225 ST CHARLES ST ST LOUIS",
             "100 S SAINT ST E STE S ST LOUIS",
             "405 ST JOSEPH LN STE 400B ST LOUIS",
             "3425 34TH AVE W APT 2 SEATTLE",
             "220 HIGHLAND AVE GLEN RIDDLE",
             "220 HIGHLAND AVE MEDIA",
             "1202 GREEN GLEN RD VESTAVIA HILLS")

    actual = parse_street_city(addr)
    expected = tibble::tribble(
        ~num, ~num_suff, ~street_dir_pre,     ~street_name, ~street_type, ~street_dir_suff,      ~unit,                ~city,
        62L,         "R",              NA,          "OAK",        "CIR",               NA,         NA,         "SAN RAFAEL",
        1234L,          NA,            "NE",        "117TH",         "ST",              "S",  "SUITE 7",         "KIRKLAND",
        1408L,          NA,              NA,       "34TH",         "AVE",              "N",       NA,    "SAINT PETERSBURG",
        2243L,          NA,              NA,       "AUBURN",         "ST",              "S",      "#8B", "SAINT PETERSBURG",
        505L,          NA,             "S",        "SOUTH",         "ST",               NA,         NA,        "PETERSBURG",
        1225L,          NA,              NA,   "ST CHARLES",         "ST",               NA,         NA,      "SAINT LOUIS",
        100L,          NA,              "S",        "SAINT",         "ST",               "E",    "STE S",     "SAINT LOUIS",
        405L,          NA,              NA,    "ST JOSEPH",         "LN",               NA,  "STE 400B",       "SAINT LOUIS",
        3425L,         NA,              NA,          "34TH",        "AVE",              "W",    "APT 2",       "SEATTLE",
        220L,          NA,              NA,      "HIGHLAND",        "AVE",              NA,          NA,       "GLEN RIDDLE",
        220L,          NA,              NA,      "HIGHLAND",        "AVE",              NA,          NA,       "MEDIA",
        1202L,         NA,              NA,    "GREEN GLEN",         "RD",              NA,          NA,    "VESTAVIA HILLS",
    )

    expect_equal(actual, expected)
})


test_that("street-only parser works correctly", {
    addr = c("62R OAK CIRCLE",
             "1234 NE 117TH ST S SUITE 7",
             "1408 34TH AVE N",
             "2243 AUBURN ST S #8B",
             "505 S SOUTH ST",
             "1225 ST CHARLES ST",
             "100 S SAINT ST E STE S",
             "405 ST JOSEPH LN STE 400B",
             "3425 34TH AVE W APT 2")

    actual = parse_street(addr)
    expected = tibble::tribble(
        ~num, ~num_suff, ~street_dir_pre,     ~street_name, ~street_type, ~street_dir_suff,      ~unit,
        62L,         "R",              NA,          "OAK",        "CIR",               NA,         NA,
        1234L,          NA,            "NE",      "117TH",         "ST",              "S",  "SUITE 7",
        1408L,          NA,              NA,       "34TH",         "AVE",              "N",       NA,
        2243L,          NA,              NA,     "AUBURN",         "ST",              "S",      "#8B",
        505L,          NA,             "S",       "SOUTH",         "ST",               NA,         NA,
        1225L,          NA,              NA, "ST CHARLES",         "ST",               NA,         NA,
        100L,          NA,              "S",        "SAINT",         "ST",             "E",    "STE S",
        405L,          NA,              NA,    "ST JOSEPH",         "LN",               NA, "STE 400B",
        3425L,         NA,              NA,          "34TH",        "AVE",              "W",    "APT 2",
    )

    expect_equal(actual, expected)
})
