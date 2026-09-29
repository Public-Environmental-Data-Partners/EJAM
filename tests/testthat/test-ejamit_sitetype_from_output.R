
# test-ejamit_sitetype_from_output()

testthat::test_that("ejamit_sitetype_from_output(out_shp) ok",  {

  ###  MAKE TEST DATA
  suppressWarnings({
    junk = capture_output({
      # dir( system.file('testdata/shapes', package = "EJAM") )
      fil = 'portland_folder_shp'   # works
      # fil = 'portland.gdb.zip'    # did not work like this
      shapefname = paste0(system.file('testdata/shapes', package = "EJAM"), "/", fil)

      out_shp     = ejamit(shapefile = shapefname, radius = 0)
    })
  })

  expect_no_error({
    sitetypefound = ejamit_sitetype_from_output(out_shp)
  })
  expect_equal(sitetypefound, "shp")
})

testthat::test_that("ejamit_sitetype_from_output(out_fips) ok",  {

  ###  MAKE TEST DATA
  suppressWarnings({
    junk = capture_output({
      out_fips    = ejamit(fips = fips_counties_from_state_abbrev('DE'))
    })
  })
  expect_no_error({
    sitetypefound = ejamit_sitetype_from_output(out_fips)
  })
  expect_equal(sitetypefound, "fips")
})

testthat::test_that("ejamit_sitetype_from_output(out_latlon) ok",  {

  out_latlon  = testoutput_ejamit_10pts_1miles

  expect_no_error({
    sitetypefound = ejamit_sitetype_from_output(out_latlon)
  })
  expect_equal(sitetypefound, "latlon")
})



########################## #
## Guards on inputs the report path can actually produce.
## ejamit_sitetype_from_output() is documented to return NA when it cannot tell the
## site type, and callers such as buffer_desc_from_sitetype() rely on getting a value
## back rather than an error. These are the cases where it did not.

testthat::test_that("sitetype_from_dt() returns NA rather than erroring on NULL", {
  ## ejamit_sitetype_from_output() passes out$results_bysite straight through, and
  ## that is NULL for an empty result or a list with no such element.
  expect_warning(res <- EJAM:::sitetype_from_dt(NULL), "cannot determine valid sitetype")
  expect_true(is.na(res))
  expect_warning(res2 <- EJAM:::ejamit_sitetype_from_output(NULL), "cannot determine valid sitetype")
  expect_true(is.na(res2))
})

testthat::test_that("an empty results table is undetermined, not 'fips'", {
  ## all() on zero elements is vacuously TRUE, so a 0-row table with an ejam_uniq_id
  ## column used to be reported as a FIPS analysis on the strength of no values at all.
  expect_warning(res <- EJAM:::sitetype_from_dt(
    data.table::data.table(ejam_uniq_id = character(0))), "cannot determine valid sitetype")
  expect_true(is.na(res))
  expect_warning(res2 <- EJAM:::sitetype_from_dt(
    data.table::data.table(fips = character(0))), "cannot determine valid sitetype")
  expect_true(is.na(res2))

  ## still identifies a populated table exactly as before
  expect_equal(EJAM:::sitetype_from_dt(
    data.table::data.table(ejam_uniq_id = c("10001", "10003"))), "fips")
  expect_equal(EJAM:::sitetype_from_dt(
    data.table::data.table(lat = c(40, 41), lon = c(-74, -75))), "latlon")
})

testthat::test_that("a wrong-class input still errors rather than being papered over", {
  ## Passing a character vector where an ejamit() output list belongs is a caller bug,
  ## so it must keep erroring - guarding it would hide the mistake.
  expect_error(EJAM:::ejamit_sitetype_from_output("not_an_ejamit_output"))
  expect_error(EJAM:::ejamit_sitetype_from_output(NA_character_))
})

testthat::test_that("a zero-row latlon result is not misreported as fips", {
  ## The case that made the vacuous-all() bug more than theoretical: dropping every
  ## row of a latlon analysis (as happens once invalid sites are removed) left a table
  ## with lat/lon AND ejam_uniq_id columns. The lat/lon branch correctly declined it,
  ## then all(fips_valid(character(0))) returned TRUE and it was labelled "fips".
  zero_rows <- testoutput_ejamit_10pts_1miles$results_bysite[0, ]
  expect_true(all(c("lat", "lon", "ejam_uniq_id") %in% names(zero_rows)))
  expect_warning(res <- EJAM:::sitetype_from_dt(zero_rows), "cannot determine valid sitetype")
  expect_true(is.na(res))
  expect_false(identical(res, "fips"))

  ## the same table with its rows still present is still latlon
  expect_equal(EJAM:::sitetype_from_dt(testoutput_ejamit_10pts_1miles$results_bysite), "latlon")
})
