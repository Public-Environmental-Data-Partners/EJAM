test_that("speed_format_seconds handles vectors and missing values", {
  expect_identical(
    EJAM:::speed_format_seconds(c(30, 100, NA_real_)),
    c("30 seconds", "1.7 minutes", "unknown")
  )
})

test_that("speed_fips_analysis_subtype uses fipstype labels", {
  expect_identical(
    EJAM:::speed_fips_analysis_subtype(EJAM::fips_counties_from_state_abbrev("DE")),
    "county"
  )
  expect_identical(
    EJAM:::speed_fips_analysis_subtype(EJAM::testinput_fips_cities[1:2]),
    "city"
  )
})

test_that("speed_runtime_model_key handles fips subtypes", {
  expect_identical(EJAM:::speed_runtime_model_key("latlon"), "points")
  expect_identical(EJAM:::speed_runtime_model_key("fips", "county"), "fips_county")
  expect_identical(EJAM:::speed_runtime_model_key("shp"), "shapefile")
})

test_that("speedtest_runtime_scenarios can return an empty combined result", {
  out <- EJAM:::speedtest_runtime_scenarios(
    detailed_csv = NULL,
    run_points = FALSE,
    run_fips = FALSE,
    run_fips_counties = FALSE,
    run_fips_cities = FALSE,
    run_shapefile = FALSE
  )
  expect_type(out, "list")
  expect_length(out, 0L)
  detailed <- attr(out, "detailed_results")
  expect_true(is.data.frame(detailed))
  expect_identical(nrow(detailed), 0L)
})
