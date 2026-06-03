
# see ?ejamapi() and test-ejamapi.R for testing the wrapper that is an interface to
#   the "report" and "data" endpoints, using GET and POST, for the live EJAM API that is hosted on a server.

# see ?url_ejamapi() and test-url_ejamapi.R for testing the utility that provides a URL
#   (that handles the "report" endpoint, and is designed to work in the live EJAM API that is hosted on a server).

# see ?ejamapi_local() and test-ejamapi_local.R for testing the DRAFT-ONLY API defined in the EJAM package, run locally.

##################### #  ##################### #  ##################### #

# parameters to test/try:

# > EJAM:::args2(ejamapi)
#   ejamapi(

#     lat = NULL,
#     lon = NULL,
#     sites = NULL,
#     sitepoints = NULL,

#     shape = NULL,
#     shapefile = NULL,
#     fips = NULL,

#     buffer = NULL,
#     radius = NULL,

#     geometries = FALSE,
#     scale = "blockgroup",
#     baseurl = "https://ejamapi-84652557241.us-central1.run.app/",
#     endpoint = c("data", "report")[1],
#     browse = TRUE,
#     ejamit_format = FALSE,
#     dry_run = FALSE,
#     ...
#   )
##################### #  ##################### #  ##################### #

### UNTESTED CASES:
#
#     geometries = TRUE  is untested
#
#     baseurl  =   other endpoints  is untested
#
#     ...    is untested with actual params that might work if passed to url_ejamapi ??
##################### #  ##################### #  ##################### #

# test data / examples
pts = data.frame(lat = c(44,45), lon = c(-117,-118))
pt1 = pts[1,]
fips_bg = testinput_fips_blockgroups
fips_bg1 = fips_bg[1]
fips_county = testinput_fips_counties
fips_county1 = fips_county[1]
polys = testshapes_2
poly1 = polys[1,]
##################### #  ##################### #  ##################### #

endpoint <- "data"  #    endpoint = "report"

for (endpoint in c("data", "report")) {

  ### maybe want to test the browse feature? just once if at all in automated unit tests.
  browse <- FALSE
  # if (endpoint == "report") { browse <- FALSE } else { browse <- TRUE }

  # for (eg in c(TRUE, FALSE)) {
  eg <- TRUE # dry_run

  ## odd case of extra parameter via ... that is not relevant
  testthat::test_that(paste0(endpoint, ": ", "xyz=999"), {
    expect_no_error({
      junk <- capture_output({
        x <- ejamapi(fips = fips_bg1,     dry_run = eg, endpoint = endpoint, browse = browse,
                     xyz=999)
      })
    })
    if (eg) {
       if (endpoint == "data") {
         expect_true(class(x) == "httr2_request")
       }
      if (endpoint == "report") {
        expect_true(class(x) == "character")
      }
    } else {
      if (endpoint == "data") {
        expect_true(is.data.frame(x))
        expect_equal(NROW(x), length(fips_bg1))
        expect_equal(x$pop, blockgroupstats$pop[blockgroupstats$bgfips == fips_bg1])
      }
      if (endpoint == "report") {
        expect_true(is.list(x))
        expect_equal(length(x), length(fips_bg1))
        expect_true("html" %in% class(x))
      }
    }
  })
  ##################### #
  testthat::test_that(paste0(endpoint, ": ", "1 fips ok"), {
    ### fips cases
    ### just 1
    expect_no_error({
      junk <- capture_output({
        x <- ejamapi(fips = fips_bg1,     dry_run = eg, endpoint = endpoint, browse = browse)
      })
    })
    expect_no_error({
      junk <- capture_output({
        x <- ejamapi(fips = fips_county1, dry_run = eg, endpoint = endpoint, browse = browse, scale = "county")
      })
    })
  })
  ##################### #
  testthat::test_that(paste0(endpoint, ": ", "1 point ok"), {
    ### latlon cases
    ### just 1
    junk <- capture_output({
      expect_no_error({
        x <- ejamapi(lat=pt1$lat, lon=pt1$lon, dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        x <- ejamapi(sites=pt1,                dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        x <- ejamapi(sitepoints=pt1,           dry_run = eg, endpoint = endpoint, browse = browse)
      })
      if (!eg && endpoint == "data") {
        expect_equal(x$radius.miles, 3) # default
      }
      expect_no_error({
        x <- ejamapi(sitepoints=pt1,           dry_run = eg, endpoint = endpoint, buffer=3.14, browse = browse)
      })
      if (!eg && endpoint == "data") {
        expect_equal(x$radius.miles, 3.14) #
      }
      expect_no_error({
        x <- ejamapi(sitepoints=pt1,           dry_run = eg, endpoint = endpoint, radius=3.14, browse = browse)
      })
      if (!eg && endpoint == "data") {
        expect_true(is.data.frame(x))
        expect_equal(NROW(x), 1)

      }

    })
  })
  ##################### #
  testthat::test_that(paste0(endpoint, ": ", "1 point ejamit_format ok"), {
    expect_no_error({
      x <- ejamapi(sitepoints=pt1,           dry_run = eg, endpoint = endpoint, radius=3.14, ejamit_format = TRUE, browse = browse)
    })
    if (!eg && endpoint == "data") {
      expect_true(is.list(x))
      expect_true("results_bysite" %in% names(x))
      expect_true("latlon" == x$sitetype)
      expect_true(NROW(x$results_bysite) == 1)
      expect_equal(x$results_bysite$radius.miles, 3.14)
    }
  })
  ##################### #
  testthat::test_that(paste0(endpoint, ": ", "1 polygon ok"), {
    ### shp cases
    ### just 1
    expect_no_error({
      x <- ejamapi(shape=poly1,     dry_run = eg, endpoint = endpoint, browse = browse)
    })
    expect_no_error({
      x <- ejamapi(shapefile=poly1, dry_run = eg, endpoint = endpoint, browse = browse)
    })
  })
  ##################### #  ##################### #  ##################### #

  ## cannot use vector of FIPS in report endpoint
  ## cannot use vector of points in report endpoint?
  ## cannot use multiple polygons in report endpoint?
  if (endpoint != "report") {

    testthat::test_that(paste0(endpoint, ": ", "multi fips ok"), {
      ### >1
      expect_no_error({
        ejamapi(fips = fips_bg,     dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        ejamapi(fips = fips_county, dry_run = eg, endpoint = endpoint, browse = browse)
      })
    })
    ##################### #
    testthat::test_that(paste0(endpoint, ": ", "multi point ok"), {
      ### >1
      expect_no_error({
        x <- ejamapi(lat=pts$lat, lon=pts$lon, dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        x <- ejamapi(sites=pts,                dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        x <- ejamapi(sitepoints=pts,           dry_run = eg, endpoint = endpoint, browse = browse)
      })
    })
    testthat::test_that(paste0(endpoint, ": ", "multi point ejamit_format ok"), {
      expect_no_error({
        x <- ejamapi(sitepoints=pts,           dry_run = eg, endpoint = endpoint, radius=3.14, ejamit_format = TRUE, browse = browse)
      })
    })
    ##################### #
    testthat::test_that(paste0(endpoint, ": ", "multi polygon ok"), {
      ### >1
      expect_no_error({
        x <- ejamapi(shape=polys,     dry_run = eg, endpoint = endpoint, browse = browse)
      })
      expect_no_error({
        x <- ejamapi(shapefile=polys, dry_run = eg, endpoint = endpoint, browse = browse)
      })
    })
    ##################### #
  }
  ##################### #  ##################### #  ##################### #

  # }
}

##################### #  ##################### #  ##################### #

## try getting multiple census units within a state or county

# > fips2name(testinput_fips_counties[1])
# [1] "Kent County, DE"
# > fips2name(testinput_fips_states[1])
# [1] "Delaware"

##################### #

## note the columns that are entirely NA values seem to NOT get returned by the API?
# > setdiff(names( testoutput_ejamit_fips_counties$results_bysite), names(x) )
# [1] "lon"                           "lat"                           "in_how_many_states"
# [4] "pctile.rateheartdisease"       "pctile.rateasthma"             "pctile.ratecancer"
# [7] "pctile.pctfire30"              "pctile.pctflood30"             "state.pctile.rateheartdisease"
# [10] "state.pctile.rateasthma"       "state.pctile.ratecancer"       "state.pctile.pctfire30"
# [13] "state.pctile.pctflood30"       "radius.miles"
# data.frame(testoutput_ejamit_fips_counties$results_bysite)[, setdiff(names( testoutput_ejamit_fips_counties$results_bysite), names(x) )]

testthat::test_that("all blockgroups in a county", {
  # scale = "blockgroup", fips = testinput_fips_counties[1] # should return all blockgroups in the county
  endpoint = "data"
  eg = FALSE
  expect_no_error({
    x <- ejamapi(
      scale = "blockgroup", fips = testinput_fips_counties[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  # correct format returned
  expect_true(is.data.frame(x))
  # got as many fips as expected
  expect_true(NROW(x) ==
                length( fips_bgs_in_fips( testinput_fips_counties[1] )))
  # got same FIPS codes as expected. Do not require the live API population
  # values to match local package data because the deployed API can be on a
  # different EJAM/EJScreen data release than this development branch.
  expect_true(setequal(
    x$ejam_uniq_id,
    fips_bgs_in_fips(testinput_fips_counties[1])
  ))
  expect_true("pop" %in% names(x))
  expect_true(is.numeric(x$pop))
})
##################### #
testthat::test_that("all blockgroups in a state", {
  endpoint = "data"
  eg = FALSE
  expect_no_error({
    x <- ejamapi(
      scale = "blockgroup", fips = testinput_fips_states[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  # got same FIPS codes as expected. Do not require the live API population
  # values to match local package data because the deployed API can be on a
  # different EJAM/EJScreen data release than this development branch.
  expect_true(setequal(
    x$ejam_uniq_id,
    fips_bgs_in_fips(testinput_fips_states[1])
  ))
  expect_true("pop" %in% names(x))
  expect_true(is.numeric(x$pop))
})
##################### #
testthat::test_that("all counties in a state", {
  endpoint = "data"
  eg = FALSE
  expect_no_error({
    x <- ejamapi(
      scale = "county", fips = testinput_fips_states[1],
      dry_run = eg, endpoint = endpoint, browse = browse)
  })
  # got same FIPS codes as expected
  expect_true(
    isTRUE(all(x$ejam_uniq_id ==
                 fips_counties_from_statefips( testinput_fips_states[1] )
    )))
})
##################### #  ##################### #  ##################### #
