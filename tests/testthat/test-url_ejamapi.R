
# test-url_ejamapi.R

# tests  ####

# function should be identical to the copy in test-URL_FUNCTIONS_part2.R

do_url_tests = function(funcname = "url_ejamapi", FUN = NULL, ...) {

  ## e.g.,
  #   funcname <- "url_ejamapi"; FUN <- NULL

  if (is.null(FUN)) {FUN <- get(funcname)}

  test_that("Site responds with 200", {
    expect_true(url_online(FUN(sitepoints = testpoints_10[1,], ...)))
  })

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
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10[1,], ...)})})
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10, radius = 1, ...)})})
    expect_true(url_online(x[1]))
  }))
  ############### #
  try(test_that(paste0(funcname, " BG FIPS works"), {
    oldwidth = options("width")
    expect_no_error({
      x <- FUN(fips = testinput_fips_blockgroups[1] , ...)
    })
    expect_no_error({
      x <- FUN(fips = testinput_fips_blockgroups[1:2] , ...)
    })
    expect_true(url_online(x[1]))
    options(width = as.vector(unlist(oldwidth)))
  }))
  ############### #
  try(test_that(paste0(funcname, " mix of FIPS works"), {
    oldwidth = options("width")
    expect_no_error({
      x <- FUN(fips = fipsmix, ...)
    })
    expect_true(url_online(x[1]))
    options(width = as.vector(unlist(oldwidth)))
  }))
  ############### #
  try(test_that(paste0(funcname, " SHAPEFILE works"), {
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2[1, ], ...)})})
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2, radius = 1, ...)})})
    expect_true(url_online(x[1]))
  }))
  ############### #
  try(test_that(paste0(funcname, " REGID works"), {
    expect_no_error({
      x <- FUN( regid = testinput_regid[1], ... )
      expect_true(url_online(x[1]))
    })
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1], ...))
    })})
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1], ...))
    })})
  }))
  ############### #
  try(test_that(paste0(funcname, " 1 url per sitepoint OR regid"), {
    expect_no_error({
      suppressWarnings({
        x <- FUN(sitepoints = testpoints_10[1:6, ], radius = 1,
                 # fips = fipsmix[1:6],
                 # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
                 regid = testinput_regid[1:6], ...)
      })
    })
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per fips OR regid"), {
    expect_no_error({
      suppressWarnings({x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
        fips = fipsmix[1:6], ...,
        # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
        regid = testinput_regid[1:6])})})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per polygon of shapefile or regid"), {
    expect_no_error({suppressWarnings({
      x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
      # fips = fipsmix[1:6],
      shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2), ...,
      regid = testinput_regid[1:6])
      })})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))

}
############## ############### ############### ############### ############### #
############## ############### ############### ############### ############### #

# fips must be blockgroup fips currently? - other types not yet implemented 9/2025

do_url_tests("url_ejamapi", url_ejamapi)

do_url_tests("url_ejamapi", url_ejamapi, sitenumber = 2)


# sitenumber (overall vs 1-site) ####

# N  means Nth site report
# -1 means "overall" report
# 0  means "each" site report, in a vector of URLs


if (FALSE) {
  # somewhat like the examples:

  pts1 <- testpoints_10[1,]
  pts2 <- testpoints_10[1:2,]
  x1 <- url_ejamapi(sitepoints = pts1, radius = 3.14)
  x2 <- url_ejamapi(pts2, radius = 3.14)
  x1
  x2
  browseURL(x1)

  ##### not finished. wont work this way
  ## ejamreport = function(...) {ejam2report(ejamit(...))}
  ## params1 = rlang::list2(sitepoints=pts1, radius=3.14)
  ## out1 <- ejamit(params1)

#  out1 <- ejamit(sitepoints=pts1, radius=3.14)
#  ejam2report(out1)
#  ejamreport(sitepoints=pts1, radius=3.14)

  fips1 <- "050014801001"
  fips2 <- testinput_fips_mix
  y1 <- url_ejamapi(fips = fips1)  # c("050014801001", "050014802001"))
  y2 <- url_ejamapi(fips = fips2)
  y1
  y2
  browseURL(y1)
  ejam2report(ejamit(fips=fips1, radius=0))

  shp2 <- testinput_shapes_2[, c("geometry", "FIPS")]
  shp1 <- shp2[1, ]
  z1 <- url_ejamapi(shapefile = shp1)
  z2 <- url_ejamapi(shapefile = shp2)
  z1
  z2
  browseURL(z1)
# ejam2report(ejamit(shapefile=shp1, radius=0))

}
