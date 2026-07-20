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

test_that("map popups honor sitenumber_label for a regenerated 1-site run (issue #348)", {
  # (Public-Environmental-Data-Partners/EJAM#348) The API's per-site report links re-analyze
  # one site that was row N of a larger analysis, so the regenerated results_bysite has the
  # auto row-number ejam_uniq_id of 1. The report header shows "(Site N)" via ejam2report()'s
  # display-only sitenumber_label; the map marker popup must match, not say "Site 1".
  out1 <- testoutput_ejamit_10pts_1miles$results_bysite[1, ] # ejam_uniq_id is 1, as in a regenerated run

  # popup builder itself
  pop <- popup_from_ejscreen(out1, sitenumber_label = 5)
  expect_true(grepl("(Site 5)", pop, fixed = TRUE))
  expect_true(grepl("Site ID: 5", pop, fixed = TRUE))
  expect_false(grepl("ejam_uniq_id 1", pop, fixed = TRUE)) # auto row id would contradict the label
  expect_false(grepl("(Site 1", pop, fixed = TRUE))

  # via mapfastej(), as ejam2report() builds the 1-site latlon map
  suppressWarnings({
    mymap <- mapfastej(out1, radius = 1, sitenumber_label = 5)
  })
  pp <- map2popups(mymap)
  expect_true(any(grepl("(Site 5)", pp, fixed = TRUE)))
  expect_false(any(grepl("ejam_uniq_id 1", pp, fixed = TRUE)))

  # without a label, popups are unchanged
  suppressWarnings({
    mymap0 <- mapfastej(out1, radius = 1)
  })
  pp0 <- map2popups(mymap0)
  expect_true(any(grepl("(Site 1, ejam_uniq_id 1)", pp0, fixed = TRUE)))

  # label is display-only for a single site: ignored for a multisite table
  popmulti <- popup_from_ejscreen(testoutput_ejamit_10pts_1miles$results_bysite, sitenumber_label = 5)
  expect_true(grepl("(Site 2, ejam_uniq_id 2)", popmulti[2], fixed = TRUE))

  # a numeric ejam_uniq_id that is NOT the auto row-number of a regenerated run
  # (does not equal 1, the row index of a 1-row table) is kept alongside the label
  out5 <- testoutput_ejamit_10pts_1miles$results_bysite[5, ] # ejam_uniq_id is 5
  popkeep <- popup_from_ejscreen(out5, sitenumber_label = 7)
  expect_true(grepl("(Site 7, ejam_uniq_id 5)", popkeep, fixed = TRUE))
  expect_true(grepl("Site ID (ejam_uniq_id): 5", popkeep, fixed = TRUE))

  # an invalid label (not a number or short text) is ignored, leaving popups unchanged
  popbad <- popup_from_ejscreen(out1, sitenumber_label = TRUE)
  expect_true(grepl("(Site 1, ejam_uniq_id 1)", popbad, fixed = TRUE))
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
