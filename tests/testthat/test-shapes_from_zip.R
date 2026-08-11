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
testthat::test_that("shapes_from_zip picks the 5-digit ZCTA id column, not GEOIDFQ (no download needed)", {
  ## Census ZCTA boundaries also carry a fully qualified id, GEOIDFQ20, whose values
  ## look like "8600000US10012" and match no zip code. Picking it would make every
  ## lookup fail, so the plain 5-digit column has to win regardless of column order.
  fake_zctas <- function(cols) {
    function(starts_with = NULL, year = NULL, ...) {
      d <- data.frame(lapply(cols, function(nm) {
        if (grepl("^GEOIDFQ", nm)) paste0("8600000US", starts_with) else starts_with
      }))
      names(d) <- cols
      d$geometry <- sf::st_sfc(lapply(seq_along(starts_with), function(i) {
        sf::st_polygon(list(rbind(c(-74, 40 + i), c(-73.9, 40 + i), c(-73.9, 40.1 + i), c(-74, 40 + i))))
      }), crs = 4269)
      sf::st_as_sf(d)
    }
  }
  # GEOIDFQ20 listed first, which is what the earlier "^GEOID" match would have taken
  for (cols in list(c("GEOIDFQ20", "GEOID20", "ZCTA5CE20"),
                    c("GEOIDFQ20", "GEOID20"),
                    c("ZCTA5CE20", "GEOIDFQ20"))) {
    testthat::local_mocked_bindings(zctas = fake_zctas(cols), .package = "tigris")
    z <- suppressMessages(shapes_from_zip(c("10012", "10506")))
    expect_equal(z$zip, c("10012", "10506"), info = paste(cols, collapse = ","))
    expect_equal(NROW(z), 2, info = paste(cols, collapse = ","))
  }
  # and still errors clearly when no usable id column exists at all
  testthat::local_mocked_bindings(zctas = fake_zctas(c("NAME20", "CLASSFP20")), .package = "tigris")
  expect_error(suppressMessages(shapes_from_zip("10012")), "Cannot find zip code")
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
