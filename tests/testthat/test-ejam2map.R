############################################## #

test_that("map2browser() works latlon", {
  testthat::skip_if_not(interactive(), message = "skipping because browse only works when interactive()")
  expect_no_error({
    suppressWarnings(
      x <-  map2browser(ejam2map(testoutput_ejamit_10pts_1miles))
    )
    # file.exists(x) # tricky to test for that
  })
  expect_true(is.character(x))
  expect_true(length(x) == 1)
})
############################################## #


test_that("ejam2map() works latlon", {
  expect_no_error({
    suppressWarnings({
      mymap = ejam2map(testoutput_ejamit_10pts_1miles, launch_browser = FALSE)
    })
  })
  expect_true("leaflet" %in% class(mymap))

  expect_no_error(
    popups <- map2popups(mymap)
  )
  # # htmltools::html_print( shiny::HTML(popups))
  expect_equal(length(popups),
               NROW(testoutput_ejamit_10pts_1miles$results_bysite))

  ## are URLs of reports  missing ?
  expect_no_error(
    urls <- map2popups_urls(mymap)
  )
  expect_equal(length(urls),
               NROW(testoutput_ejamit_10pts_1miles$results_bysite)
  )



})
############################################## #

# need more tests

## how to check polygons shown are good?

# etc.

############################################## #

############################################## ############################################### #
test_that("ejam2map() works fips given shp", {
  expect_no_error({
    suppressWarnings({
      mymap = ejam2map(testoutput_ejamit_fips_counties,
                   shp = shapes_from_fips(  testinput_fips_counties),
                   launch_browser = FALSE
      )
    })
  })
  expect_true("leaflet" %in% class(mymap))

  expect_no_error(
    popups <- map2popups(mymap)
  )
  # # htmltools::html_print( shiny::HTML(popups))
  expect_equal(length(popups),
               NROW(testoutput_ejamit_fips_counties$results_bysite))

  expect_no_error(
    urls <- map2popups_urls(mymap)
  )
  expect_equal(length(urls),
               NROW(testoutput_ejamit_fips_counties$results_bysite)
  )


})
############################################## #
test_that("ejam2map() works fips not given shp", {
  expect_no_error({
    suppressWarnings({
      mymap = ejam2map(testoutput_ejamit_fips_counties, launch_browser = FALSE)


    })
  })
  expect_true("leaflet" %in% class(mymap))

  expect_no_error(
    popups <- map2popups(mymap)
  )
  # # htmltools::html_print( shiny::HTML(popups))
  expect_equal(length(popups),
               NROW(testoutput_ejamit_fips_counties$results_bysite))

  expect_no_error(
    urls <- map2popups_urls(mymap)
  )
  expect_equal(length(urls),
               NROW(testoutput_ejamit_fips_counties$results_bysite)
  )

})
############################################## #

test_that("ejam2map() works fips sitenumber=2", {
  expect_no_error({
    suppressWarnings({
      x = ejam2map(testoutput_ejamit_10pts_1miles,
                   sitenumber = 2,
                   launch_browser = F
      )
    })
  })
  expect_true("leaflet" %in% class(x))

})
################################################################################ ############# #

test_that("ejam2map() works given shp", {
  expect_no_error({
    suppressWarnings({
      x = ejam2map(testoutput_ejamit_shapes_2,
                   shp = testinput_shapes_2,
                   # sitenumber = 0,
                   launch_browser = F
      )
    })
  })
  expect_true("leaflet" %in% class(x))
})
############################################## #
test_that("ejam2map()  missing shp", {
  expect_error({
    suppressWarnings({
      x = ejam2map(testoutput_ejamit_shapes_2,
                   # shp = testinput_shapes_2,
                   # sitenumber = 0,
                   launch_browser = F
      )
    })
  })
  # expect_true("leaflet" %in% class(x))
})
############################################## #
test_that("ejam2map() works given shp, sitenumber=2", {
  expect_no_error({
    suppressWarnings({
      x = ejam2map(testoutput_ejamit_shapes_2,
                   shp = testinput_shapes_2,
                   sitenumber = 2,
                   launch_browser = F
      )
    })
  })
  expect_true("leaflet" %in% class(x))

  # expect_equal(  ,
  # 2    # ***
  # )


})
############################################## ############################################### #
