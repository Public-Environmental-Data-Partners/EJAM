# These test the DATA the deployed API sends back, so the API has to be up for any
# of it to mean anything. skip_if_offline() only proves the runner has an internet
# connection, which is why these used to go red whenever the API itself was down or
# still redeploying. Probe the API first and skip - see skip_if_url_unreachable()
# in setup.R, and Public-Environmental-Data-Partners/EJAM#548

endpoint <- "data"
browse <- FALSE
eg <- FALSE
apiurl <- url_package("api")

testthat::test_that("ejamapi live API returns all blockgroups in a county", {
  skip_if_offline()
  skip_if_url_unreachable(apiurl, what = "the deployed EJAM API")

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
  skip_if_url_unreachable(apiurl, what = "the deployed EJAM API")

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
  skip_if_url_unreachable(apiurl, what = "the deployed EJAM API")

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
