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

test_that("popup_from_ejscreen() handles zero-row results after invalid shapes are dropped", {
  zero_rows <- testoutput_ejamit_10pts_1miles$results_bysite[0, ]
  popups <- NULL

  expect_no_error({
    popups <- popup_from_ejscreen(zero_rows)
  })
  expect_identical(popups, character(0))
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

test_that("map_ejam_plus_shp() handles all shapes being dropped as invalid", {
  out <- testoutput_ejamit_fips_counties
  out$results_bysite <- out$results_bysite[1, ]
  out$results_bysite$ejam_uniq_id <- "010039900000"
  out$results_bysite$radius.miles <- 0

  empty_shape <- sf::st_sf(
    ejam_uniq_id = "010039900000",
    geometry = sf::st_sfc(sf::st_geometrycollection(), crs = 4326)
  )

  expect_message({
    x <- map_ejam_plus_shp(
      shp = empty_shape,
      out = out,
      radius_buffer = 0,
      launch_browser = FALSE
    )
  }, "There were 1 invalid polygons.", fixed = TRUE)
  expect_true("leaflet" %in% class(x))
  expect_equal(unlist(x$x$fitBounds[1:4]), c(37, -115, 48, -65))
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
  # Two shapes: first is empty (simulates a place whose boundary could not be downloaded),
  # second is a real polygon.  The popup for the empty shape must be dropped so that
  # the surviving polygon gets its own correct popup (not the one that belonged to the
  # missing-boundary site).  Covers the fix for issue #267.
  shp <- sf::st_sf(
    FIPS = c("0000001", "0000002"),
    geometry = sf::st_sfc(
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE)))
    )
  )
  x <- map_shapes_leaflet(shp, popup = c("missing boundary", "mapped boundary"))
  # map2popups_polygon() finds the addPolygons call regardless of call index
  expect_equal(map2popups_polygon(x), "mapped boundary")

  # Three shapes: empty in the middle – both outer popups must survive in order.
  shp2 <- sf::st_sf(
    FIPS = c("0000001", "0000002", "0000003"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE))),
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(2, 2, 2, 3, 3, 3, 3, 2, 2, 2), ncol = 2, byrow = TRUE)))
    )
  )
  x2 <- map_shapes_leaflet(shp2, popup = c("first mapped", "missing boundary", "third mapped"))
  expect_equal(map2popups_polygon(x2), c("first mapped", "third mapped"))

  # When popup count already matches shape count (all non-empty), no filtering needed.
  x3 <- map_shapes_leaflet(shp2, popup = c("already filtered first", "already filtered third"))
  expect_equal(map2popups_polygon(x3), c("already filtered first", "already filtered third"))
})

test_that("map_shapes_leaflet_proxy() keeps popup alignment after dropping empty geometries", {
  # Regression test for issue #267:
  # Previously map_shapes_leaflet_proxy() dropped empty geometries from shapes but
  # did NOT filter the popup vector, causing the remaining polygon to receive the
  # wrong popup (the one that belonged to the missing-boundary site).

  # Case 1: first shape empty, second has a real polygon.
  shp <- sf::st_sf(
    FIPS = c("0000001", "0000002"),
    geometry = sf::st_sfc(
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE)))
    )
  )
  base_map <- leaflet::leaflet()
  x <- map_shapes_leaflet_proxy(base_map, shapes = shp,
                                popup = c("missing boundary", "mapped boundary"))
  expect_equal(map2popups_polygon(x), "mapped boundary")

  # Case 2: three shapes, empty in the middle.
  shp2 <- sf::st_sf(
    FIPS = c("0000001", "0000002", "0000003"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(matrix(c(0, 0, 0, 1, 1, 1, 1, 0, 0, 0), ncol = 2, byrow = TRUE))),
      sf::st_as_sfc("POLYGON EMPTY")[[1]],
      sf::st_polygon(list(matrix(c(2, 2, 2, 3, 3, 3, 3, 2, 2, 2), ncol = 2, byrow = TRUE)))
    )
  )
  x2 <- map_shapes_leaflet_proxy(base_map, shapes = shp2,
                                 popup = c("first mapped", "missing boundary", "third mapped"))
  expect_equal(map2popups_polygon(x2), c("first mapped", "third mapped"))

  # Case 3: popup count already matches non-empty shape count – no filtering, no error.
  x3 <- map_shapes_leaflet_proxy(base_map, shapes = shp2,
                                 popup = c("already filtered first", "already filtered third"))
  expect_equal(map2popups_polygon(x3), c("already filtered first", "already filtered third"))
})
############################################## #

test_that("shapefile upload map path logs no console error (issue #136)", {
  # Regression test for issue #136: uploading a shapefile printed
  #   Error in UseMethod("st_geometry") : no applicable method for 'st_geometry'
  #   applied to an object of class "SpatialPolygonsDataFrame" ...
  # even though the map still rendered. The app's SHP branch had coerced the uploaded
  # polygons to sp, and map_shapes_leaflet_proxy() calls sf::st_is_empty() inside a
  # try(), which has no sp method - so the error was printed but not raised.
  # Note this checks the message stream, not expect_error(), because the message is
  # exactly what the user saw and nothing actually stops.

  ## d_uploads built the same way the SHP branch of app_server() builds it
  d_uploads <- testinput_shapes_2 %>%
    dplyr::select(-any_of(c("valid", "invalid_msg"))) %>%
    sf::st_zm()
  expect_s3_class(d_uploads, "sf")

  ## what the app does now: sf all the way through, nothing printed
  console_sf <- capture.output(type = "message", suppressWarnings(
    x <- map_shapes_leaflet_proxy(
      leaflet::leaflet(),
      shapes = d_uploads,
      popup = popup_from_df(d_uploads %>% sf::st_drop_geometry())
    )
  ))
  expect_false(any(grepl("st_geometry|Error", console_sf)))
  expect_s3_class(x, "leaflet")

  ## and what it used to do, to show this test would have caught the bug.
  ## (skipped if some future sf handles Spatial objects here, leaving nothing to regress against)
  skip_if_not_installed("sp")
  d_uploads_sp <- suppressWarnings(sf::as_Spatial(d_uploads))
  skip_if_not(inherits(try(sf::st_is_empty(d_uploads_sp), silent = TRUE), "try-error"),
              "sf now handles Spatial objects in st_is_empty(), so the issue #136 error is moot")
  console_sp <- capture.output(type = "message", suppressWarnings(
    map_shapes_leaflet_proxy(
      leaflet::leaflet(),
      shapes = d_uploads_sp,
      popup = popup_from_df(sf::st_drop_geometry(d_uploads_sp))
    )
  ))
  expect_match(paste(console_sp, collapse = " "), "st_geometry")
})
############################################## #

test_that("app_server SHP map path does not coerce uploaded shapes to sp (issue #136)", {
  ## The fix for issue #136 is a line inside app_server(), which these unit tests cannot
  ## call, so check the SOURCE of that branch instead. Inspecting R/app_server.R only works
  ## from the source tree (devtools/pkgload), not under R CMD check of the installed
  ## package, so skip visibly there - same approach as test-shiny-1-14-compat.R
  app_server_path <- testthat::test_path("../../R/app_server.R")
  skip_if_not(file.exists(app_server_path),
              "R source not available (installed-package check); source-inspection test runs only from the source tree")
  app_server_source <- paste(readLines(app_server_path, warn = FALSE), collapse = "\n")

  ## just the leafletProxy() SHP branch, from the "SHP" test up to the next branch
  shp_block <- sub(
    '(?s)^.*\\} else if \\("SHP" %in% current_upload_method\\(\\)\\) \\{(.*?)\\} else if \\(.*$',
    "\\1", app_server_source, perl = TRUE
  )
  expect_false(identical(shp_block, app_server_source)) # i.e., the branch was found
  expect_match(shp_block, "map_shapes_leaflet_proxy", fixed = TRUE)
  expect_match(shp_block, "sf::st_drop_geometry(", fixed = TRUE)

  ## sf::st_drop_geometry() has no method for sp objects, so nothing in this branch
  ## may convert the uploaded shapes to sp. (comments about it are fine, so drop those first)
  shp_code_only <- sub("#.*$", "", strsplit(shp_block, "\n")[[1]])
  expect_false(any(grepl("as_Spatial", shp_code_only, fixed = TRUE)))
})
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
  testthat::skip_if_not_installed("maps")
  withr::local_package("maps")

  expect_no_error({
    x = mapfast_gg(testpoints_10)
    x
  })
  expect_true('ggplot' %in% class(x))
})
############################################## # ############################################## #
