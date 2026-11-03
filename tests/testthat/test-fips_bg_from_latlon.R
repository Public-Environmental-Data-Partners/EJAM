# test-fips_bg_from_latlon.R

test_that("fips_bg_from_latlon ok if 2", {
  skip_if(offline(), "requires a live boundary service")
  expect_no_error({
    suppressWarnings({
      x = fips_bg_from_latlon(testpoints_10[1:2,])
      # Warning message:
      #   st_crs<- : replacing crs does not reproject data; use st_transform for that
    })
  })
  expect_equal(length(x), 2)
  expect_equal(fipstype(x[1]), "blockgroup")
  expect_equal(fips2state_abbrev(x[1]), state_from_latlon(testpoints_10[1,])$ST)

})



test_that("fips_bg_from_latlon ok if 1", {
  skip_if(offline(), "requires a live boundary service")
  expect_no_error({
    suppressWarnings({
      x = fips_bg_from_latlon(testpoints_10[1,])
      # Warning message:
      #   st_crs<- : replacing crs does not reproject data; use st_transform for that
    })
  })
  expect_equal(length(x), 1)
  expect_equal(fipstype(x[1]), "blockgroup")
  expect_equal(fips2state_abbrev(x[1]), state_from_latlon(testpoints_10[1,])$ST)

})

test_that("fips_bg_from_latlon if no valid latlon", {
 expect_no_error({
  x = fips_bg_from_latlon(data.frame(lat=NA, lon=NA))
 })

})

test_that("fips_bg_from_latlon if some valid latlon", {
  skip_if(offline(), "requires a live boundary service")
  expect_no_error({

    fips_bg_from_latlon(data.frame(lat=c(35,NA), lon= c(-100,NA)))
  })
})

