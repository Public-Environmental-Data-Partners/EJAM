######################################################### #

testthat::test_that("latlon_from_shapefile() ok", {

  junk <- capture.output({
    testshape_points <- shapefile_from_sitepoints(testpoints_10)
  })
  expect_no_error({suppressWarnings({ suppressMessages({
    junk <- capture.output({
      suppressMessages({
      x <- latlon_from_shapefile(testshape_points)
  })
    })
  })  })})
  expect_true(
    is.data.frame(x) # and data.table
  )
  expect_true(
  all.equal(
    round(sf::st_drop_geometry(  testshape_points[,c("lat","lon")]),3),
    round(x[,c("lat","lon")],3),
    check.attributes = FALSE
  )
  )
  expect_true(
    all(sapply(x[,c("lat","lon")], is.numeric))
    )
  expect_true(
    all(latlon_is.valid(lat=x$lat,lon = x$lon))
              )
})
################################################################ #

testthat::test_that("latlon_from_shapefile_centroids() ok", {

  junk <- capture.output({
    testshape_points <- shapefile_from_sitepoints(testpoints_10)
  })
  expect_no_error({suppressWarnings({ suppressMessages({
    junk <- capture.output({
      x <- latlon_from_shapefile_centroids(testshape_points)
    })
  })  })})
  expect_true(
    is.data.frame(x)
  )
  expect_true(
    all.equal(
      round(sf::st_drop_geometry(  testshape_points[,c("lat","lon")]),3),
      round(x[,c("lat","lon")],3),
      check.attributes = FALSE
    )
  )
  expect_true(all(sapply(x[,c("lat","lon")], is.numeric)))
  expect_true(all(latlon_is.valid(lat=x$lat,lon = x$lon)))
})
################################################################ #

testthat::test_that("shapefile2latlon(testshape_points) aka latlon_from_shapefile(testshape) not crash", {

  junk <- capture.output({
    testshape_points <- shapefile_from_sitepoints(testpoints_10)
  })
  expect_no_error({suppressWarnings({
    junk <- capture.output({
      JUNK <- shapefile2latlon(testshape_points)
      x <- latlon_from_shapefile(testshape_points)
    })
  })})
  expect_true(
    is.data.frame(x) & data.table::is.data.table(x)
  )
  expect_true(all(sapply(x[,c("lat","lon")], is.numeric)))
  expect_true(all(latlon_is.valid(lat=x$lat,lon = x$lon)))
})





################################################ #

testthat::test_that("  works with SHAPEFILE with INTPTLAT INTPTLON", {

  expect_no_error({
    suppressMessages({
      x <- latlon_from_anything(testinput_shapes_2)
    })
  })
  expect_equal(
    NROW(x), 2
  )
  expect_true(
    all(c("lat", "lon") %in% names(x))
  )
  expect_true(all(sapply(x[,c("lat","lon")], is.numeric)))
  expect_true(all(latlon_is.valid(lat=x$lat,lon = x$lon)))
})
################################################ #

testthat::test_that("  works with SHAPEFILE with geometry NOT INTPTLAT INTPTLON", {

  expect_no_error({
    suppressMessages({
      x <- latlon_from_anything(testinput_shapes_2[,c("NAME", "geometry")])
    })
  })
  expect_equal(
    NROW(x), 2
  )
  expect_true(
    all(c("lat", "lon") %in% names(x))
  )
  expect_true(all(sapply(x[,c("lat","lon")], is.numeric)))
  expect_true(all(latlon_is.valid(lat=x$lat,lon = x$lon)))
})

testthat::test_that("latlon_from_shapefile_centroids() gives NA for an empty polygon, listed first", {
  # issue #801: sf::st_centroid() stops with an error if given an empty polygon in a spatial data.frame
  good <- sf::st_geometry(testinput_shapes_2)
  shp <- sf::st_sf(sitename = c("empty", "a", "b"),
                   geometry = c(sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(good)), good[1:2]))
  expect_no_error({x <- latlon_from_shapefile_centroids(shp)})
  expect_equal(NROW(x), 3)
  expect_true(is.na(x$lat[1]) && is.na(x$lon[1]))
  expect_equal(x[2:3, c("lat", "lon")], latlon_from_shapefile_centroids(testinput_shapes_2)[, c("lat", "lon")],
               ignore_attr = TRUE)
})
################################################################ #
