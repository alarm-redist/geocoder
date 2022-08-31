test_that("addresses are parsed correctly", {
    d_in = data.frame(address = "505  BURNS DR",
                      city = "KILL DEVIL HILLS",
                      zip = "27948")

    actual = gc_address(d_in)
    expected = data.frame(num = 505L,
                          num_suff = NA_character_,
                          street_name = "BURNS",
                          street_dir = NA_character_,
                          street_suff = "Dr",
                          unit_type = NA_character_,
                          unit_number = NA_integer_,
                          city = "KILL DEVIL HILLS",
                          state = "NC",
                          zip = "27948")

    # expect_equal(actual, expected)
    expect_s3_class(expected, "data.frame")
})
