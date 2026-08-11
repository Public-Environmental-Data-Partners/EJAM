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
testthat::test_that("shapes_from_zip names what it dropped, using the caller's own text", {
  ## normalizing strips non-digits, so a warning built from the normalized vector said
  ## "Dropping invalid zip code(s): " and named nothing -- useless for finding the bad row.
  expect_warning(try(shapes_from_zip("not a zip"), silent = TRUE), 'not a zip', fixed = TRUE)
  expect_warning(try(shapes_from_zip(c("10012", "bogus")), silent = TRUE), "bogus", fixed = TRUE)
  expect_warning(try(shapes_from_zip(NA), silent = TRUE), "NA", fixed = TRUE)
  # empty string is shown as "" rather than vanishing into a blank list
  expect_warning(try(shapes_from_zip(c("10012", "")), silent = TRUE), '""', fixed = TRUE)
})
########################## #
testthat::test_that("ejam2report rebuilds zip polygons for zip/ZIP/ZCTA spellings", {
  ## ejamit() always sets site_method = "ZIP", but site_method2text() accepts both cases
  ## and "ZCTA", so a caller passing "zip" should still get polygons rather than silence.
  zip_report_output <- function() list(
    sitetype = "shp",
    site_method = "ZIP",
    zipcode = c("10012", "10506"),
    results_bysite = data.table::data.table(
      ejam_uniq_id = 1:2, valid = TRUE, invalid_msg = "", pop = c(10, 20),
      radius.miles = 0, statename = "New York"),
    results_overall = data.table::data.table(
      ejam_uniq_id = "overall", valid = TRUE, invalid_msg = "", pop = 30,
      radius.miles = 0, statename = "New York")
  )
  for (spelling in c("ZIP", "zip", "ZCTA", "zcta", "FIPS")) {
    called <- new.env(parent = emptyenv()); called$n <- 0L
    local_mocked_bindings(
      shapes_from_zip = function(zipcode, ...) {
        called$n <- called$n + 1L
        sf::st_as_sf(data.frame(zip = zipcode, geometry = sf::st_sfc(
          lapply(seq_along(zipcode), function(i) sf::st_polygon(list(rbind(
            c(-74, 40 + i), c(-73.9, 40 + i), c(-73.9, 40.1 + i), c(-74, 40 + i))))), crs = 4269)))
      },
      shapes_from_fips = function(fips, ...) data.frame(fips = fips),
      report_residents_within_xyz_from_ejamit = function(...) "residents",
      report_setup_temp_files = function(...) "template.Rmd",
      create_filename = function(...) "report.html",
      build_community_report = function(...) "<section>report</section>",
      plot_barplot_ratios_ez = function(...) ggplot2::ggplot(),
      ejam2map = function(...) "map",
      ensure_pandoc_available_for_ejam = function(...) invisible(TRUE),
      .package = "EJAM"
    )
    local_mocked_bindings(
      pandoc_available = function(...) TRUE,
      render = function(input, output_format, output_file, params, envir, quiet, ...) {
        writeLines("<html>report</html>", output_file); output_file
      }, .package = "rmarkdown"
    )
    out <- zip_report_output()
    out$site_method <- spelling
    suppressWarnings(try(ejam2report(out, site_method = spelling, return_html = TRUE,
                                     launch_browser = FALSE), silent = TRUE))
    if (spelling == "FIPS") {
      expect_identical(called$n, 0L, info = spelling)   # non-zip method must not rebuild zips
    } else {
      expect_gt(called$n, 0L)                            # all four zip spellings do
    }
  }
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
