skip("Working on `prep.R`")

test_that("Database preparation works without errors", {
    expect_no_error({
        nc_addr |>
            gc_address(address=address, city=city, zip=zip, state="NC") |>
            gc_prep_street_db(save_cens=TRUE)
    })
})
