
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
