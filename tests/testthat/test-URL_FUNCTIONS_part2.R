
# test-URL_FUNCTIONS_part2.R

############### test all the other url_xyz functions in a loop:

# tests  ####

# function should be identical to the copy in test-ejamapi.R

do_url_tests = function(funcname = "url_ejscreenmap", FUN = NULL) {

  ## e.g.,
  #   funcname <- "url_county_health"; FUN <- NULL

  if (is.null(FUN)) {FUN <- get(funcname)}

  if (!grepl("equityatlas", funcname)) {
    # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
    test_that("Site responds with 200", {
      expect_true(url_online(FUN(sitepoints = testpoints_10[1,])))
    })
  }
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
    if (!grepl("equityatlas", funcname)) {
      # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
      expect_true(url_online(x[1]))
    }
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
    if (!grepl("equityatlas", funcname)) {
      # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
      expect_true(url_online(x[1]))
    }
  }))
  ############### #
  try(test_that(paste0(funcname, " mix of FIPS works"), {
    expect_no_error({
      x <- FUN(fips = fipsmix)
    })
    if (!grepl("equityatlas", funcname)) {
      # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
      expect_true(url_online(x[1]))
    }
  }))
  ############### #
  try(test_that(paste0(funcname, " SHAPEFILE works"), {
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2[1, ])})})
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2, radius = 1)})})
    if (!grepl("equityatlas", funcname)) {
      # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
      expect_true(url_online(x[1]))
    }
  }))
  ############### #
  try(test_that(paste0(funcname, " REGID works"), {
    expect_no_error({
      x <- FUN( regid = testinput_regid[1] )
      if (!grepl("equityatlas", funcname)) {
        # url_online() fails for those equity atlas URLs even when the URL is OK, browseable
        expect_true(url_online(x[1]))
      }
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
