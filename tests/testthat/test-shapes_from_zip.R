## tests for shapes_from_zip() and the ejamit(zipcode = ) parameter
## See Public-Environmental-Data-Partners/EJAM#482

testthat::test_that("shapes_from_zip rejects invalid input (no download needed)", {
  expect_error(shapes_from_zip())
  expect_error(shapes_from_zip(NULL))
  expect_error(shapes_from_zip(character(0)))
  expect_error(suppressWarnings(shapes_from_zip("not a zip")))
})
########################## #
testthat::test_that("ejamit stops if zipcode is combined with other ways of specifying places", {
  expect_error(ejamit(zipcode = "10605", fips = "10001"), "zipcode cannot be combined")
  expect_error(ejamit(zipcode = "10605", shapefile = "dummy.zip"), "zipcode cannot be combined")
  expect_error(ejamit(zipcode = "10605", sitepoints = data.frame(lat = 40, lon = -75)), "zipcode cannot be combined")
})
########################## #
testthat::test_that("report text helpers describe zip code analyses", {
  expect_equal(
    sitetype2text(nsites = 10, sitetype = 'shp', site_method = 'ZIP'),
    "specified zip codes"
  )
  expect_equal(
    sitetype2text(nsites = 1, sitetype = 'shp', site_method = 'ZIP'),
    "specified zip code"
  )
  expect_equal(
    site_method2text("ZIP"),
    "zip codes (ZCTA boundaries)"
  )
})
########################## #
testthat::test_that("shapes_from_zip downloads ZCTA polygons (slow 1st time; cached after)", {
  testthat::skip_on_cran()
  testthat::skip_on_ci() # the national ZCTA boundaries file is a large download
  testthat::skip_if_offline()
  # numeric input and a ZIP+4 both get normalized to 5-digit zips
  z <- shapes_from_zip(c(10012, "10506-1234"))
  expect_s3_class(z, "sf")
  expect_equal(z$zip, c("10012", "10506"))
  expect_equal(NROW(z), 2)
})
