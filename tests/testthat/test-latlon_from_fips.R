
test_that("latlon_from_fips works on 1 NA fips", {
  expect_no_error({
    # expect_warning({
    x <-    latlon_from_fips(NA)
    # })
  })
  expect_equal(NROW(x), 1)
  expect_true("lon" %in% names(x))
  expect_true(
    all(
      is.na(x$lat))
  )
})


test_that("latlon_from_fips works on all NA fips", {
  expect_no_error({
    # expect_warning({
      x <-    latlon_from_fips(c(NA,NA))
    # })
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(
      is.na(x$lat))
  )
})

test_that("latlon_from_fips works on SOME NA fips", {
  expect_no_error({
    # expect_warning({
      x <- latlon_from_fips(c(NA,"09"))
    # })
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all.equal(
    is.na(x$lat),
    c(TRUE, FALSE)
  )
  )
})

test_that("latlon_from_fips works on BLOCK", {
  expect_no_error({
    x <-      latlon_from_fips( "091701844002024" )
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 1)
  expect_true(
    !is.na(x$lat[1])
  )
})

test_that("latlon_from_fips works on bg", {
  expect_no_error({
    latlon_from_fips(testinput_fips_blockgroups[1])
    x <-    latlon_from_fips(testinput_fips_blockgroups[1:2])
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(!is.na(x$lat))
  )
})

test_that("latlon_from_fips works on tract", {
  expect_no_error({
    latlon_from_fips(testinput_fips_tracts[1])
    latlon_from_fips(testinput_fips_tracts[3])# had a problem before
    x <-    latlon_from_fips(testinput_fips_tracts[1:2])
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(!is.na(x$lat))
  )
  })

test_that("latlon_from_fips works on city", {
  expect_no_error({
    latlon_from_fips(testinput_fips_cities[1])
    x =     latlon_from_fips(testinput_fips_cities[1:2])
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(!is.na(x$lat))
  )
})

test_that("latlon_from_fips works on county", {
  expect_no_error({
    latlon_from_fips(testinput_fips_counties[1])
    x =    latlon_from_fips(testinput_fips_counties[1:2])
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(!is.na(x$lat))
  )
})

test_that("latlon_from_fips works on states", {
  expect_no_error({
    latlon_from_fips(testinput_fips_states[1])
    x =    latlon_from_fips(testinput_fips_states[1:2])
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  expect_true(
    all(!is.na(x$lat))
  )
})

test_that("latlon_from_fips works on fipsmix", {
  expect_no_error({
    suppressWarnings({
      x <-    latlon_from_fips(testinput_fips_mix )
    })
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), length(testinput_fips_mix))
  ST <- state_from_latlon(lon = x$lon, lat = x$lat)$FIPS.ST # fips_state_from_latlon(sitepoints = x)
  expect_equal(ST, substr(testinput_fips_mix,1,2))
  expect_true(
    all(!is.na(x$lat))
  )
})

test_that("latlon_from_fips works on city and county", {
  expect_no_error({
    suppressWarnings({
      x <-    latlon_from_fips(c("4748000", "10001") )
    })
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  ST <- fips_state_from_latlon(sitepoints = x)
  expect_equal(ST, c("47", "10"))
  })

test_that("latlon_from_fips works on county and state", {
  expect_no_error({
    suppressWarnings({
      x <-    latlon_from_fips(c("10001", "05"))
    })
  })
  expect_true("lon" %in% names(x))
  expect_equal(NROW(x), 2)
  ST <- fips_state_from_latlon(sitepoints = x)
  expect_equal(ST, c("10", "05"))
})

############################################# #

#
# ## test they are correct latlon in sense of right county?
#
# for ( i in 1:length(  testinput_fips_mix[fipstype(testinput_fips_mix) != "state"])) {
#
#   fips <-  testinput_fips_mix[i]
#
#   suppressWarnings({
#     x <-    latlon_from_fips(fips[i] )
#   })
#
#   test_that(paste0("latlon are in same county as input fips was, for fips is ", fipstype(fips)), {
#
#
#     ## stuck on latlon_from_anything in here:
#
#     s2b = getblocksnearby(sitepoints = data.frame(lat = x$lat, lon = x$lon), radius = 0.5)
#
#
#     cat("fips = ",fips[i], "\n")
#     print(paste0("lat,lon", x$lat, ", ", x$lon, "\n"))
#
#     # get fips from s2b$bgid
#     s2b[bgpts,  fips := bgfips, on = "bgid"]
#     # setnames(s2b, "bgfips", "fips")
#     countyfips_per_latlon  <-  unique(fips2countyfips(s2b$fips))
#
#     expect_true({
#       n = length(intersect(
#         fips2countyfips(fips), countyfips_per_latlon
#       ))
#       if (n == 0) {cat("not the same county!?  \n")}
#       n > 0
#     })
#   })
# }
#

############################################# #
