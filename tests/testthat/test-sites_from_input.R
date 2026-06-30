
test_that("list of NULLs if no input", {
  expect_no_error({
    x = sites_from_input()
  })
  expect_null(x$sitepoints)
  expect_null(x$shapefile)
  expect_null(x$fips)
  expect_null(x$sitetype)
})

test_that("list of NULLs if all NULL input", {
  x = sites_from_input(sitepoints = NULL, lat = NULL, lon = NULL, shapefile = NULL, fips = NULL)
  expect_null(x$sitepoints)
  expect_null(x$shapefile)
  expect_null(x$fips)
  expect_null(x$sitetype)
})

test_that("list of NULLs if length 0 input", {
  expect_no_error({
    x = sites_from_input(sitepoints = data.frame(lat = vector(), lon = vector()))
  })
  expect_null(x$sitepoints)

  x = sites_from_input(fips = vector())
  expect_null(x$fips)

  x = testinput_shapes_2
  x <- x[x$STATEFP == 0, ]
  x = sites_from_input(shapefile = x)
  expect_null(x$shapefile)
})

test_that("list of NULLs if all NULL input", {
  x = sites_from_input(sitepoints = NULL, lat = NULL, lon = NULL, shapefile = NULL, fips = NULL)
  expect_null(x$sitepoints)
  expect_null(x$shapefile)
  expect_null(x$fips)
  expect_null(x$sitetype)
})

test_that("output and sitetype matches sole input", {

  inp = testpoints_10
  x = sites_from_input(sitepoints = inp)
  expect_equal(x$sitepoints, inp)
  expect_equal(x$sitetype, "latlon")
  # expect_null(x$sitepoints)
  expect_null(x$shapefile)
  expect_null(x$fips)


  inp = testinput_fips_mix
  x = sites_from_input(fips = inp)
  expect_equal(x$fips, inp)
  expect_equal(x$sitetype, "fips")
  expect_null(x$sitepoints)
  expect_null(x$shapefile)
  # expect_null(x$fips)


  inp = testinput_shapes_2
  x = sites_from_input(shapefile = inp)
  expect_equal(x$shapefile, inp)
  expect_equal(x$sitetype, "shp")
  expect_null(x$sitepoints)
  # expect_null(x$shapefile)
  expect_null(x$fips)

})

test_that("lat,lon inputs work", {
  x = sites_from_input(lat=1:2, lon=8:9)
  expect_equal(x$sitetype, "latlon")
  expect_equal(x$sitepoints$lat, 1:2)
  expect_equal(x$sitepoints$lon, 8:9)
  expect_null(x$fips)
  expect_null(x$shapefile)
})

test_that("warns if multiple inputs?", {
  suppressWarnings({
    expect_warning({
      x = sites_from_input(sitepoints = testpoints_10, fips = testinput_fips_mix)
    })
  })
  suppressWarnings({
    expect_warning({
      x = sites_from_input(sitepoints = testpoints_10, shapefile = testinput_shapes_2)
    })
  })

})

########## #

test_that("message not warning if lat,lon, and sitepoints provided?", {
  suppressWarnings({
    expect_message({
      x = sites_from_input(sitepoints = testpoints_10, lat = 1, lon = 2)
    })
  })
})

test_that("sites_from_input() accepts shape/shp aliases for shapefile", {
  sf1 <- shapefile_from_any(testshapes_2, cleanit = FALSE)
  expect_equal(sites_from_input(shapefile = sf1)$sitetype, "shp")
  expect_equal(sites_from_input(shape = sf1)$sitetype, "shp")
  expect_equal(sites_from_input(shp = sf1)$sitetype, "shp")
})
