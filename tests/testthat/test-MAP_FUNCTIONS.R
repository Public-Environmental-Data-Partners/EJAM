# popup_from_ejscreen()
# popup_from_any()
# popup_from_df() - will deprecate once confirm popup_from_any() works in its place
# popup_from_uploadedpoints()

# mapfast()
# mapfastej()

# ejam2map()
# map2browser()


# map_facilities_proxy()
# mapfastej_counties()
# map_blockgroups_over_blocks()
# map_shapes_plot()
# map_shapes_leaflet_proxy()
# map_shapes_mapview  # If mapview pkg available
# shapes_counties_from_countyfips() #Get Counties boundaries via API, to map them
# shapes_blockgroups_from_bgfips()
# mapfast_gg()
############################################## #

test_that("popup_from_ejscreen() works even if 1 row or 1 indicator", {
  expect_no_error({
    suppressWarnings({
      x = popup_from_ejscreen(testoutput_ejamit_10pts_1miles$results_bysite[1:2,])

      # only one place (one row)
      x = popup_from_ejscreen(testoutput_ejamit_10pts_1miles$results_bysite[1,])
    })
  })
  expect_no_error({
    suppressWarnings({
      # what if only some indicators available??
      x10 = popup_from_ejscreen(testoutput_ejamit_10pts_1miles$results_bysite[,  1:20])
      # what if try to use for other table than supposed to
      x = popup_from_ejscreen(testpoints_10[1:2,])
    })
  })
  expect_equal(10, length(grep('long', x10)))
})
############################################## #

test_that("popup_from_any() works even if 1 row or 1 indicator", {
  expect_no_error({
    suppressMessages({

      x1 = popup_from_any(testpoints_10[1:2,])

      x2 = popup_from_any(testoutput_ejamit_10pts_1miles$results_bysite[1:2,], column_names = names_d, labels = fixcolnames(names_d, "r", "short"))
      x3 = popup_from_any(testoutput_ejamit_10pts_1miles$results_bysite[1:2,],  n = 7) # only uses the first 7 columns so NA reported for all others which seems not ideal
      length(x3)

      # only one place (one row)
      x4 = popup_from_any(testpoints_10[1,])

      # only one indicator
      x5 = popup_from_any(testoutput_ejamit_10pts_1miles$results_bysite[1:2,],  column_names = "pop")
      x5b = popup_from_any(testoutput_ejamit_10pts_1miles$results_bysite[1,],  n = 1) #  # one row, one indicator
      x5c = popup_from_any(testoutput_ejamit_10pts_1miles$results_bysite[1,],  column_names = "pctlowinc") #  # one row, one indicator

      # if data.table format
      x6 = popup_from_any(data.table(testpoints_10[1:2,]))
      x7 = popup_from_any(data.table(testpoints_10[1,]))
      x8 = popup_from_any(data.table(testoutput_ejamit_10pts_1miles$results_bysite)[1:2, ],  column_names = "pop")
      x9 = popup_from_any(data.table(testoutput_ejamit_10pts_1miles$results_bysite)[1, ],  column_names = "pop") # one row, one indicator

    })
  })

  suppressWarnings({
    expect_warning({
      x0 = popup_from_any(testpoints_10,  column_names = "pop is not a column in that dataset")
    })
  })
})
############################################## #

test_that("popup_from_any() coerces non-data-frame objects via as.data.frame()", {
  mat <- matrix(c("A", "B", 1, 2), ncol = 2)
  colnames(mat) <- c("name", "value")

  expect_no_error({
    x <- popup_from_any(mat)
  })

  expect_equal(2, length(x))
  expect_true(all(grepl("name: ", x, fixed = TRUE)))
  expect_true(all(grepl("value: ", x, fixed = TRUE)))
})
############################################## #

if (exists("popup_from_df")) { # will likely deprecate
  test_that("popup_from_df() works but popup_from_any() may replace it", {
    expect_no_error({
      suppressMessages({
        popup_from_df(testpoints_10[1:2,])
        popup_from_df(testoutput_ejamit_10pts_1miles$results_bysite[1:2,],  n = 3)
        x = popup_from_df(testoutput_ejamit_10pts_1miles$results_bysite[1:2,], column_names = names_d, labels = fixcolnames(names_d, "r", "short"))
        # not testing 1 row or 1 indicator cases
      })
    })
    expect_equal(2, length(x))
  })
}
############################################## #

test_that("popup_from_uploadedpoints() works", {
  expect_no_error({
    suppressMessages({
      x = popup_from_uploadedpoints(testpoints_10[1:2,])
      # just one location
      popup_from_uploadedpoints(testpoints_10[1,])
    })
  })
  expect_equal(2, length(x))
})
############################################## #



############################################## #
############################################## #
test_that("mapfast works", {
  expect_no_error({
    # suppressMessages({
    x = mapfast(testpoints_10)
    x
    mapfast(testoutput_ejamit_10pts_1miles$results_bysite, radius = 0.2, column_names = names_d, launch_browser = FALSE)
    mapfast(testoutput_ejamit_10pts_1miles$results_bysite, radius = 0.2, column_names = names_d, labels = fixcolnames(names_d, "r", "short"))
    # but note 0-1 not 0-100 shown for demog percentages this way
    # })
  })
  expect_true("leaflet" %in% class(x))
})

test_that("mapfast works given ejamit() output list not table", {
  suppressWarnings({
    expect_no_error({
      mapfast(testoutput_ejamit_10pts_1miles) # if forgot to specify table $results_bysite
    })
  })
})

test_that("mapfast should handle just 1 indicator!", {
  errmsgjunk = capture.output(
    expect_no_error({
      x = mapfast(testoutput_ejamit_10pts_1miles$results_bysite, radius = 0.2, column_names = "Demog.Index", labels = "Demographic Score", launch_browser = FALSE)
      x
    })
  )
  expect_true('leaflet' %in% class(x))
})
############################################## #

test_that("mapfastej() works", {
  expect_no_error({
    suppressWarnings({
      x = mapfastej(testoutput_ejamit_10pts_1miles$results_bysite)
      y = mapfastej(testoutput_ejamit_10pts_1miles$results_bysite, radius = 3)
    })
  })
  expect_true("leaflet" %in% class(x))
  expect_true("leaflet" %in% class(y))
})
############################################## #

############################################## #

test_that("map_facilities_proxy() works", {
  expect_no_error({
    suppressMessages({
      x = map_facilities_proxy(
        mapfast(testpoints_10[1,]), # only 1 point
        rad = 4,
        popup_vec = popup_from_any(data.frame(
          newinfo = "text",
          other = 1
        ))
      )
    })
  })
  expect_true("leaflet" %in% class(x))

  expect_no_error({
    suppressMessages({
      x = map_facilities_proxy(
        mapfast(testpoints_10[1:2,]),
        rad = 4,
        popup_vec = popup_from_any(data.frame(
          newinfo = c("xyz", "zzz"),
          other = 1:2
        ))
      )
    })
  })
  expect_true("leaflet" %in% class(x))
})

############################################## #

test_that("mapfastej_counties() works", {     # slow

  # getblocksnearby_from_fips() has warnings here
  suppressMessages({
    suppressWarnings({
      junk = capture.output(
        myshapes <- shapes_from_fips(fips_counties_from_state_abbrev("RI")[1])
      )    })
    expect_no_error({
      junk = capture.output({
        suppressWarnings({
          mydat = ejamit(fips = fips_counties_from_statename("Rhode Island")[1], radius = 0, silentinteractive = TRUE)$results_bysite

          x = mapfastej_counties(mydat)
        })
      })
    })
    expect_true("leaflet" %in% class(x))
    expect_true(sf::st_is_valid(myshapes))
  })
})
############################################## #
############################################## #

# shapes_from_fips() tests ####

# what if no CENSUS_API_KEY, and different services tried
## see places where it does or does not do this, e.g. :
# if (nchar(Sys.getenv("CENSUS_API_KEY")) == 0) {
#   warning("envt var CENSUS_API_KEY not found - this requires having set up a census api key - see ?tidycensus::census_api_key  ")
# }

ftypes <- c("blockgroups", "tracts", "cities", "counties", "states")
servicetypes <- c("DEFAULT", "tiger", "cartographic")

# ftypes <- "blockgroups"
# servicetypes = "DEFAULT"

for (ftype in ftypes) {

  fips <- get(paste0("testinput_fips_", ftype))

  for (servicetype in servicetypes) {

    test_text <- paste0("if no CENSUS_API_KEY, fipstype=", ftype, ", svc=", servicetype)

    test_that(test_text, {
      fips <- fips
      oldkey <- Sys.getenv("CENSUS_API_KEY")
      Sys.setenv(CENSUS_API_KEY = "")
      expect_no_error({
        if (servicetype == "DEFAULT") {
          suppressWarnings({
            junk <- capture_output({
              x <- shapes_from_fips(fips)
            })
          })
        } else {
          suppressWarnings({
            junk <- capture_output({
              x <- shapes_from_fips(fips,
                                    myservice_blockgroup = servicetype,
                                    myservice_tract = servicetype,
                                    myservice_place = servicetype,
                                    myservice_county = servicetype
              )
            })
          })
        }

        expect_equal(NROW(x), length(fips))
        Sys.setenv(CENSUS_API_KEY = oldkey)
      })
    })
  }
}

############################################## #
############################################## #

test_that("map_blockgroups_over_blocks() works", {
  expect_no_error({
    junk = capture.output({
      y <- plot_blocks_nearby(testpoints_10[5,],
                            radius = 0.5,
                            returnmap = TRUE)
      x = map_blockgroups_over_blocks(y)
    })
  })
  expect_true("leaflet" %in% class(x))
})
############################################## #
test_that("shapes_counties_from_countyfips() works", {
  # Get Counties boundaries via API, to map them
  x = capture_output({
    expect_no_error({
      suppressWarnings({
        myshapes = shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")[1])
      })
    })
  })
  expect_true(sf::st_is_valid(myshapes))
})
############################################## # ############################################## #
############################################## #
test_that("map_shapes_plot() works", {
  suppressWarnings({
    myshapes = shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")[1])  # kind of slow so just done once here for tests

    expect_no_error({
      map_shapes_plot(myshapes)
    })
  })
})

test_that("map_shapes_leaflet() keeps popup alignment after dropping empty geometries", {
  shp <- sf::st_sf(
    FIPS = c("0000001", "0000002"),
    geometry = sf::st_sfc(
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE)))
    )
  )
  x <- map_shapes_leaflet(shp, popup = c("missing boundary", "mapped boundary"))
  expect_equal(map2popups(x), "mapped boundary")

  shp2 <- sf::st_sf(
    FIPS = c("0000001", "0000002", "0000003"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE))),
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(2, 2, 2, 3, 3, 3, 3, 2, 2, 2), ncol = 2, byrow = TRUE)))
    )
  )
  x2 <- map_shapes_leaflet(shp2, popup = c("first mapped", "missing boundary", "third mapped"))
  expect_equal(map2popups(x2), c("first mapped", "third mapped"))

  x3 <- map_shapes_leaflet(shp2, popup = c("already filtered first", "already filtered third"))
  expect_equal(map2popups(x3), c("already filtered first", "already filtered third"))
})

# test_that("map_shapes_leaflet_proxy() works", {
#
#   myshapes = shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")[1])
#
#   expect_no_error({
#     map_shapes_leaflet_proxy(     )
#   })
# })
############################################## #
test_that("map_shapes_mapview() if mapview pkg available works", {
  junk = capture_output({
    suppressWarnings({
      myshapes = shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")[1])  # kind of slow so just done once here for tests
    })
  })
  # myshapes = shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")[1])
  skip_if_not_installed("mapview")
  # requires mapview pkg be attached by setup.R in tests folders
  expect_no_error({
    suppressWarnings({
      require(mapview)
      # warns if package mapview not yet attached
      x = map_shapes_mapview(myshapes)
    })
  })
  expect_true('mapview' %in% class(x))
})
############################################## #
test_that("shapes_blockgroups_from_bgfips() works", {
  junk = capture_output({

    expect_no_error({
      x = shapes_blockgroups_from_bgfips()
    })
  })
  expect_true(sf::st_is_valid(x))
  expect_true("sf" %in% class(x))
})
############################################## #
test_that("mapfast_gg() works", {
  if (!EJAM:::pkg_available('maps')) {
    warning("maps package is needed for unit test of mapfast_gg()")
    skip("maps package is needed for unit test of mapfast_gg()")
    }
  expect_no_error({
    x = mapfast_gg(testpoints_10)
    x
  })
  expect_true('ggplot' %in% class(x))
})
############################################## # ############################################## #
