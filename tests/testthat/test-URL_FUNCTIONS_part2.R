
# test-URL_FUNCTIONS_part2.R

############### test all the other url_xyz functions in a loop:

# tests  ####

# function should be identical to the copy in test-ejamapi.R

do_url_tests = function(funcname = "url_ejscreenmap", FUN = NULL) {

  ## e.g.,
  #   funcname <- "url_county_health"; FUN <- NULL

  if (is.null(FUN)) {FUN <- get(funcname)}

  # fipsmix = testinput_fips_mix
  fipsmix =  c(
    "091701844002024", # block
    testinput_fips_blockgroups[1],
    testinput_fips_tracts[2],
    "4748000", ## Memphis  # testinput_fips_cities[1],
    testinput_fips_counties[1],
    testinput_fips_states[2]
  )


  ############### #
  try(test_that(paste0(funcname, " sitepoints POINTS works"), {
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10[1,])})})
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10, radius = 1)})})
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " BG FIPS works"), {
    expect_no_error({
      # expect_warning( # if this county is not available in nationalequityatlas.org
      # fips2name("06037")
      # [1] "Los Angeles County, CA"
      x <- FUN(fips = "060371011101" ) # in "Los Angeles County, CA"
    })
    expect_no_error({
      x <- FUN(fips = c("060371011101", "060371011102") ) # in "Los Angeles County, CA"   # testinput_fips_blockgroups[1:2] )
    })
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " mix of FIPS works"), {
    expect_no_error({
      x <- FUN(fips = fipsmix)
    })
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " SHAPEFILE works"), {
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2[1, ])})})
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2, radius = 1)})})
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " REGID works"), {
    expect_no_error({
      x <- FUN( regid = testinput_regid[1] )
      expect_true(grepl("^https://", x[1]))
    })
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1]))
    })})
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1]))
    })})
  }))
  ############### #
  try(test_that(paste0(funcname, " 1 url per sitepoint OR regid"), {
    expect_no_error({
      suppressWarnings({
        x <- FUN(sitepoints = testpoints_10[1:6, ], radius = 1,
                 # fips = fipsmix[1:6],
                 # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
                 regid = testinput_regid[1:6])
      })
    })
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per fips OR regid"), {
    expect_no_error({
      suppressWarnings({x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
        fips = fipsmix[1:6],
        # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
        regid = testinput_regid[1:6])})})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per polygon of SHAPEFILE or regid"), {
    expect_no_error({suppressWarnings({x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
      # fips = fipsmix[1:6],
      shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
      regid = testinput_regid[1:6])})})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
}
############## ############### ############### ############### ############### #
############## ############### ############### ############### ############### #

# functions being tested  ####

funcnames = c(
  'url_ejscreenmap',
  'url_enviromapper',
  'url_echo_facility',
  'url_frs_facility',
  'url_county_health',
  'url_state_health',
  'url_county_equityatlas',
  'url_state_equityatlas'
)
for (func in funcnames) {
  do_url_tests(funcname = func)
}

# do_url_tests("url_ejscreenmap", url_ejscreenmap)
# do_url_tests("url_enviromapper", url_enviromapper)
#
# do_url_tests("url_echo_facility", url_echo_facility)
# do_url_tests("url_frs_facility", url_frs_facility)
#
# do_url_tests("url_county_health", url_county_health)
# do_url_tests("url_state_health", url_state_health)
#
# do_url_tests("url_county_equityatlas", url_county_equityatlas)
# # browseURL( "https://nationalequityatlas.org/research/data_summary?geo=04000000000024003" )
# do_url_tests("url_state_equityatlas", url_state_equityatlas)

# url_naics.com()

# url_github_preview()

############## TESTS FOR FACILITY-NEARBY URL FUNCTIONS ############## #

test_that("url_efpoints builds correct base URL for each sitecategory layer number", {
  expect_true(grepl("MapServer/0/query", EJAM:::url_efpoints(sitecategory = "npl")))
  expect_true(grepl("MapServer/1/query", EJAM:::url_efpoints(sitecategory = "tri")))
  expect_true(grepl("MapServer/2/query", EJAM:::url_efpoints(sitecategory = "water")))
  expect_true(grepl("MapServer/3/query", EJAM:::url_efpoints(sitecategory = "air")))
  expect_true(grepl("MapServer/4/query", EJAM:::url_efpoints(sitecategory = "tsdf")))
  expect_true(grepl("MapServer/5/query", EJAM:::url_efpoints(sitecategory = "brownfields")))
})

test_that("url_efpoints URL starts with expected base domain", {
  u <- EJAM:::url_efpoints(sitecategory = "npl")
  expect_true(grepl("^https://geopub.epa.gov", u))
})

test_that("url_efpoints includes state_code in where clause when provided", {
  u <- EJAM:::url_efpoints(sitecategory = "npl", state_code = "NJ")
  expect_true(grepl("state_code", utils::URLdecode(u)))
  expect_true(grepl("NJ", u))
})

test_that("url_efpoints errors when multiple sitecategories supplied", {
  expect_error(EJAM:::url_efpoints(sitecategory = c("npl", "tri")))
})

test_that("url_efpoints errors when baseurl is overridden", {
  expect_error(EJAM:::url_efpoints(sitecategory = "npl",
                                  baseurl = "https://example.com/query?"))
})

test_that("url_facilities_nearby returns one URL per frompoint", {
  lats <- c(39.65, 40.0)
  lons <- c(-75.73, -74.0)
  urls <- EJAM:::url_facilities_nearby(sitecategory = "npl", lat = lats, lon = lons, radius = 1)
  expect_equal(length(urls), 2)
  expect_true(all(grepl("^https://", urls)))
  expect_true(all(grepl("MapServer/0/query", urls)))
})

test_that("url_facilities_nearby encodes point geometry in URL", {
  u <- EJAM:::url_facilities_nearby(sitecategory = "tsdf", lat = 39.65, lon = -75.73, radius = 3)
  expect_true(grepl("esriGeometryPoint", utils::URLdecode(u)))
  expect_true(grepl("StatuteMile", utils::URLdecode(u)))
})

test_that("url_facilities_nearby errors if lat and lon lengths differ", {
  expect_error(EJAM:::url_facilities_nearby(lat = c(39.65, 40.0), lon = -75.73))
})

test_that("url_facilities_nearby uses correct layer number per sitecategory", {
  expect_true(grepl("MapServer/0/query", EJAM:::url_facilities_nearby("npl",  lat = 39.65, lon = -75.73, radius = 1)))
  expect_true(grepl("MapServer/4/query", EJAM:::url_facilities_nearby("tsdf", lat = 39.65, lon = -75.73, radius = 1)))
})
