
testthat::test_that("sitetype2text ok", {
  expect_no_error({
    sitetype2text()
  })
  expect_equal(
    sitetype2text(),
    "place"
  )
})
########################## #
testthat::test_that("sitetype2text cities", {
  expect_equal(
    sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'city'),
    "specified cities"
  )
})
########################## #
test_that("sitetype2text fips", {
  expect_equal(
    sitetype2text(sitetype='fips'),
    "specified Census unit"
  )
})
########################## #
test_that("sitetype2text latlon", {
  expect_equal(
    sitetype2text(sitetype='latlon'),
    "specified point"
  )
})
########################## #
test_that("sitetype2text shp", {
  expect_equal(
    sitetype2text(sitetype='shp'),
    "specified polygon"
  )
})
########################## #
## sitetype2text() lowercases site_method and compares against lowercase
## literals throughout, so SIC and MACT already work in either case.
## These guard against the tolower() mismatch that site_method2text() had.
test_that("sitetype2text handles SIC and MACT in either case", {
  expect_equal(
    sitetype2text(sitetype = 'latlon', site_method = 'SIC'),
    "SIC industry-specific site"
  )
  expect_equal(
    sitetype2text(sitetype = 'latlon', site_method = 'sic'),
    "SIC industry-specific site"
  )
  expect_equal(
    sitetype2text(sitetype = 'latlon', site_method = 'MACT'),
    "MACT category site"
  )
  expect_equal(
    sitetype2text(sitetype = 'latlon', site_method = 'mact'),
    "MACT category site"
  )
})
########################## #
########################## #
## site_method2text() lowercases site_method up front, so every branch must
## compare against a lowercase literal. The SIC and MACT branches used to
## compare against "SIC"/"MACT" directly, making them unreachable and leaving
## those two methods with a blank description.
test_that("site_method2text SIC in either case", {
  expect_equal(
    EJAM:::site_method2text("SIC"),
    "EPA-regulated facilities by SIC code (industry type)"
  )
  expect_equal(
    EJAM:::site_method2text("sic"),
    "EPA-regulated facilities by SIC code (industry type)"
  )
})
########################## #
test_that("site_method2text MACT in either case", {
  expect_equal(
    EJAM:::site_method2text("MACT"),
    "EPA-regulated facilities by MACT category (air toxics emissions source type)"
  )
  expect_equal(
    EJAM:::site_method2text("mact"),
    "EPA-regulated facilities by MACT category (air toxics emissions source type)"
  )
})
########################## #
test_that("site_method2text describes every documented site_method", {
  ## none of the documented site_method values should fall through to ""
  ## must stay in step with the @param site_method roxygen list, which #483 added
  ## ZIP (and ZCTA, its synonym) to - otherwise "all documented values" is a claim
  ## this test does not actually check, and a ZIP/ZCTA regression slips through.
  site_method_options <- c("latlon", "SHP", "FIPS", "FIPS_PLACE", "ZIP", "ZCTA",
                           "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT")
  expect_false(
    any(EJAM:::site_method2text(site_method_options) %in% ""),
    label = "all documented site_method values have text"
  )
  expect_false(
    any(EJAM:::site_method2text(tolower(site_method_options)) %in% ""),
    label = "all documented site_method values have text when lowercase"
  )
})
########################## #
test_that("site_method2text is vectorized and returns '' for unknown", {
  expect_equal(
    EJAM:::site_method2text(c("SIC", "mact", "shp")),
    c("EPA-regulated facilities by SIC code (industry type)",
      "EPA-regulated facilities by MACT category (air toxics emissions source type)",
      "shapefile")
  )
  expect_equal(EJAM:::site_method2text("not_a_method"), "")
})
########################## #
########################## #
## buffer_desc_from_sitetype() is what puts site_method2text()'s output in front
## of a user, in the notes tab of the Excel workbook. Its append step used to be
## gated on buffer_desc == "", which no branch can produce, so it never ran.
test_that("buffer_desc_from_sitetype appends the site_method detail", {
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "SIC"),
    paste0("Locations defined by latitude, longitude and radius, based on ",
           "EPA-regulated facilities by SIC code (industry type)")
  )
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "MACT"),
    paste0("Locations defined by latitude, longitude and radius, based on ",
           "EPA-regulated facilities by MACT category (air toxics emissions source type)")
  )
  ## same in either case
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "sic"),
    EJAM:::buffer_desc_from_sitetype("latlon", "SIC")
  )
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "mact"),
    EJAM:::buffer_desc_from_sitetype("latlon", "MACT")
  )
  ## and for the other methods that say more than sitetype does
  expect_match(EJAM:::buffer_desc_from_sitetype("latlon", "FRS"),  ", based on ", fixed = TRUE)
  expect_match(EJAM:::buffer_desc_from_sitetype("latlon", "NAICS"), ", based on ", fixed = TRUE)
  expect_match(EJAM:::buffer_desc_from_sitetype("shp", "ZIP"),      ", based on ", fixed = TRUE)
  expect_match(EJAM:::buffer_desc_from_sitetype("fips", "FIPS_PLACE"), ", based on ", fixed = TRUE)
})
########################## #
test_that("buffer_desc_from_sitetype omits detail that only restates sitetype", {
  ## table_xls_from_ejam() defaults site_method to sitetype ('shp' -> 'SHP',
  ## 'fips' -> 'FIPS') when it is not supplied, so these are the common cases,
  ## and "Polygons defined by shapefile, based on shapefile" would be silly.
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("shp", "SHP"),
    "Polygons defined by shapefile"
  )
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("fips", "FIPS"),
    "Census Units defined by FIPS code"
  )
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "latlon"),
    "Locations defined by latitude, longitude and radius"
  )
  ## map clicks are just coordinates too
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "mapclick"),
    "Locations defined by latitude, longitude and radius"
  )
})
########################## #
test_that("buffer_desc_from_sitetype handles missing/empty site_method", {
  ## these two are the documented @examples, and must not error
  expect_equal(EJAM:::buffer_desc_from_sitetype("shp"),  "Polygons defined by shapefile")
  expect_equal(EJAM:::buffer_desc_from_sitetype("fips"), "Census Units defined by FIPS code")
  expect_equal(
    EJAM:::buffer_desc_from_sitetype("latlon", "NAICS"),
    paste0("Locations defined by latitude, longitude and radius, based on ",
           "EPA-regulated facilities by NAICS code (industry type)")
  )
  ## anything with no text to add leaves the plain description alone
  latlon_plain <- "Locations defined by latitude, longitude and radius"
  expect_equal(EJAM:::buffer_desc_from_sitetype("latlon", NULL),           latlon_plain)
  expect_equal(EJAM:::buffer_desc_from_sitetype("latlon", NA),             latlon_plain)
  expect_equal(EJAM:::buffer_desc_from_sitetype("latlon", ""),             latlon_plain)
  expect_equal(EJAM:::buffer_desc_from_sitetype("latlon", character(0)),   latlon_plain)
  expect_equal(EJAM:::buffer_desc_from_sitetype("latlon", "not_a_method"), latlon_plain)
  ## unknown sitetype still gets the detail
  expect_equal(
    EJAM:::buffer_desc_from_sitetype(NULL, "MACT"),
    paste0("Selected Locations, based on ",
           "EPA-regulated facilities by MACT category (air toxics emissions source type)")
  )
})
########################## #
########################## #

show_sitetype2text_examples = function() {

  nsites_options = c(1, 10)

  sitetype_options = c("latlon", "shp", "fips")

  # site_method_options      = c("latlon", "SHP", "FIPS", "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT")
  site_method_options_latlon = c("latlon",                              "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT")
  site_method_options_shp    = c(          "SHP")
  site_method_options_fips   = c(                 "FIPS", "FIPS_PLACE")

  census_unit_type_options = c("state", "county", "tract", "city", "blockgroup", "block")


  for (nsites_this in nsites_options) {
    cat("--------------------------- nsites = ", nsites_this, "\n")
    # $###################

    sitetype_this = "latlon"
    census_unit_type_this = NULL
    for (site_method_this in site_method_options_latlon) {

      msg = sitetype2text(sitetype = sitetype_this,
                          site_method = site_method_this,
                          census_unit_type = census_unit_type_this,
                          nsites = nsites_this)
      spacer = paste0(rep(" ", 33 - nchar(msg)), collapse = "")
      cat(paste0("TEXT: '", msg,  "' ", spacer, "sitetype2text(nsites=", nsites_this, ", sitetype='", sitetype_this, "', site_method='", site_method_this, "')\n"))

    }
    cat("\n")
    # $###################

    sitetype_this = "shp"
    census_unit_type_this = NULL
    for (site_method_this in site_method_options_shp) {

      msg = sitetype2text(sitetype = sitetype_this,
                          site_method = site_method_this,
                          census_unit_type = census_unit_type_this,
                          nsites = nsites_this)
      spacer = paste0(rep(" ", 33 - nchar(msg)), collapse = "")
      cat(paste0("TEXT: '", msg,  "' ", spacer, "sitetype2text(nsites=", nsites_this, ", sitetype='", sitetype_this, "', site_method='", site_method_this, "')\n"))
    }
    cat("\n")
    # $###################

    sitetype_this = "fips"
    for (site_method_this in site_method_options_fips) {

      for (census_unit_type_this in census_unit_type_options) {

        msg = sitetype2text(sitetype = sitetype_this,
                            site_method = site_method_this,
                            census_unit_type = census_unit_type_this,
                            nsites = nsites_this)
        spacer = paste0(rep(" ", 33 - nchar(msg)), collapse = "")
        cat(paste0("TEXT: '", msg,  "' ", spacer, "sitetype2text(nsites=", nsites_this, ", sitetype='", sitetype_this, "', site_method='", site_method_this,
                   "', census_unit_type = '", census_unit_type_this, "')\n"))
      }
    }
    cat("\n")
    # $###################

  }

}

#   show_sitetype2text_examples()

rm(show_sitetype2text_examples)

# --------------------------- nsites =  1
# TEXT: 'specified point'                  sitetype2text(nsites=1, sitetype='latlon', site_method='latlon')
# TEXT: 'FRS ID-specified site'            sitetype2text(nsites=1, sitetype='latlon', site_method='FRS')
# TEXT: 'NAICS industry-specific site'     sitetype2text(nsites=1, sitetype='latlon', site_method='NAICS')
# TEXT: 'SIC industry-specific site'       sitetype2text(nsites=1, sitetype='latlon', site_method='SIC')
# TEXT: 'EPA program-specific site'        sitetype2text(nsites=1, sitetype='latlon', site_method='EPA_PROGRAM')
# TEXT: 'MACT category site'               sitetype2text(nsites=1, sitetype='latlon', site_method='MACT')
#
# TEXT: 'specified polygon'                sitetype2text(nsites=1, sitetype='shp', site_method='SHP')
#
# TEXT: 'specified state'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'state')
# TEXT: 'specified county'                 sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'county')
# TEXT: 'specified tract'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'tract')
# TEXT: 'specified city'                   sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'city')
# TEXT: 'specified blockgroup'             sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'blockgroup')
# TEXT: 'specified block'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS', census_unit_type = 'block')
# TEXT: 'specified state'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'state')
# TEXT: 'specified county'                 sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'county')
# TEXT: 'specified tract'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'tract')
# TEXT: 'specified city'                   sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'city')
# TEXT: 'specified blockgroup'             sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'blockgroup')
# TEXT: 'specified block'                  sitetype2text(nsites=1, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'block')
#
# --------------------------- nsites =  10
# TEXT: 'specified points'                 sitetype2text(nsites=10, sitetype='latlon', site_method='latlon')
# TEXT: 'FRS ID-specified sites'           sitetype2text(nsites=10, sitetype='latlon', site_method='FRS')
# TEXT: 'NAICS industry-specific sites'    sitetype2text(nsites=10, sitetype='latlon', site_method='NAICS')
# TEXT: 'SIC industry-specific sites'      sitetype2text(nsites=10, sitetype='latlon', site_method='SIC')
# TEXT: 'EPA program-specific sites'       sitetype2text(nsites=10, sitetype='latlon', site_method='EPA_PROGRAM')
# TEXT: 'MACT category sites'              sitetype2text(nsites=10, sitetype='latlon', site_method='MACT')
#
# TEXT: 'specified polygons'               sitetype2text(nsites=10, sitetype='shp', site_method='SHP')
#
# TEXT: 'specified states'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'state')
# TEXT: 'specified counties'               sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'county')
# TEXT: 'specified tracts'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'tract')
# TEXT: 'specified cities'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'city')
# TEXT: 'specified blockgroups'            sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'blockgroup')
# TEXT: 'specified blocks'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS', census_unit_type = 'block')
# TEXT: 'specified states'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'state')
# TEXT: 'specified counties'               sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'county')
# TEXT: 'specified tracts'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'tract')
# TEXT: 'specified cities'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'city')
# TEXT: 'specified blockgroups'            sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'blockgroup')
# TEXT: 'specified blocks'                 sitetype2text(nsites=10, sitetype='fips', site_method='FIPS_PLACE', census_unit_type = 'block')

########################## #
testthat::test_that("sitetype2text handles a length-0 sitetype or site_method", {
  ## character(0) is not NULL, so it slipped past the is.null() defaults and survived
  ## the is.na() replacement unchanged; `sitetype %in% ...` then gave logical(0) and
  ## the if() errored instead of simply not matching.
  expect_no_error(res <- sitetype2text(character(0)))
  expect_equal(res, "place")                                   # same as sitetype2text(NULL)
  expect_no_error(res2 <- sitetype2text("latlon", site_method = character(0)))
  expect_equal(res2, "specified point")
  expect_equal(sitetype2text(character(0)), sitetype2text(NULL))

  ## unchanged for ordinary values
  expect_equal(sitetype2text(sitetype = "shp"), "specified polygon")
  expect_equal(sitetype2text(nsites = 10, sitetype = "shp", site_method = "ZIP"),
               "specified zip codes")
})
