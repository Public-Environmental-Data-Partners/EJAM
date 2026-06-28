endpoint <- "data"
browse <- FALSE
eg <- FALSE

testthat::test_that("ejamapi live API returns all blockgroups in a county", {
  skip_if_offline()

  expect_no_error({
    x <- ejamapi(
      scale = "blockgroup", fips = testinput_fips_counties[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  expect_true(is.data.frame(x))
  expect_true(NROW(x) ==
                length(fips_bgs_in_fips(testinput_fips_counties[1])))
  expect_true(setequal(
    x$ejam_uniq_id,
    fips_bgs_in_fips(testinput_fips_counties[1])
  ))
  expect_true("pop" %in% names(x))
  expect_true(is.numeric(x$pop))
})

testthat::test_that("ejamapi live API returns all blockgroups in a state", {
  skip_if_offline()

  expect_no_error({
    x <- ejamapi(
      scale = "blockgroup", fips = testinput_fips_states[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  expect_true(setequal(
    x$ejam_uniq_id,
    fips_bgs_in_fips(testinput_fips_states[1])
  ))
  expect_true("pop" %in% names(x))
  expect_true(is.numeric(x$pop))
})

testthat::test_that("ejamapi live API returns all counties in a state", {
  skip_if_offline()

  expect_no_error({
    x <- ejamapi(
      scale = "county", fips = testinput_fips_states[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  expect_true(
    isTRUE(all(x$ejam_uniq_id ==
                 fips_counties_from_statefips(testinput_fips_states[1])
    )))
})
