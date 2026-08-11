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
testthat::test_that("shapes_from_zip enables tigris caching without overriding an explicit choice", {
  ## .onAttach() does not run for EJAM::shapes_from_zip(), so the function sets the
  ## caching option itself - but only when the caller has expressed no preference.
  ## An explicit options(tigris_use_cache = FALSE) is the caller's to make.
  fake_zctas <- function(starts_with = NULL, year = NULL, ...) {
    d <- data.frame(ZCTA5CE20 = starts_with)
    d$geometry <- sf::st_sfc(lapply(seq_along(starts_with), function(i) {
      sf::st_polygon(list(rbind(c(-74, 40 + i), c(-73.9, 40 + i), c(-73.9, 40.1 + i), c(-74, 40 + i))))
    }), crs = 4269)
    sf::st_as_sf(d)
  }
  testthat::local_mocked_bindings(zctas = fake_zctas, .package = "tigris")
  old <- getOption("tigris_use_cache")
  withr::defer(options(tigris_use_cache = old))

  # unset -> we supply the default the docs promise
  options(tigris_use_cache = NULL)
  suppressMessages(shapes_from_zip("10012"))
  expect_true(getOption("tigris_use_cache"))

  # explicitly FALSE -> left alone
  options(tigris_use_cache = FALSE)
  suppressMessages(shapes_from_zip("10012"))
  expect_false(getOption("tigris_use_cache"))

  # explicitly TRUE -> still TRUE
  options(tigris_use_cache = TRUE)
  suppressMessages(shapes_from_zip("10012"))
  expect_true(getOption("tigris_use_cache"))
})
########################## #
testthat::test_that("ejam2report zip polygon rebuild accepts zip/ZIP/ZCTA spellings", {
  ## ejamit() always sets site_method = "ZIP", but site_method2text() already accepts
  ## both cases and "ZCTA", so a caller passing "zip" should still get polygons.
  gate <- function(site_method) toupper(site_method) %in% c("ZIP", "ZCTA")
  expect_true(gate("ZIP"))
  expect_true(gate("zip"))
  expect_true(gate("ZCTA"))
  expect_true(gate("zcta"))
  expect_false(gate("FIPS"))
  expect_false(gate("SHP"))
  # the gate as it actually appears in the source, both branches
  src <- readLines(testthat::test_path("..", "..", "R", "ejam2report.R"))
  expect_length(grep('toupper(site_method) %in% c("ZIP", "ZCTA")', src, fixed = TRUE), 2)
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
