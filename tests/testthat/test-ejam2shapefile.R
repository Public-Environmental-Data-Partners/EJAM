
cat("\n") # because can't suppress some info being printed to console.

# test cases/ examples
########################################################################## #
# IF FILE PROVIDED, DONT ASK USER TO CONFIRM
# IF FOLDER PROVIDED, DONT ASK USER TO CONFIRM
# IF FILE NOT PROVIDED, DOES NOT ASK TO CONFIRM THE DEFAULT FILENAME IS OK
# IF FOLDER NOT PROVIDED... IT ASKS TO CONFIRM THE DEFAULT FOLDER IS OK IF INTERACTIVE, SO SKIP THAT case IN THESE TESTS.

########################################################################## #

# no prompt if folder is specified, or if save=F



test_that("ejam2shapefile ok if save=F", {
  expect_no_error(
    expect_no_warning( #
      # save FALSE
      suppressMessages({
        junk <- testthat::capture_output({

          # make the test data smaller to try to speed it up
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          shp <- ejam2shapefile(tout, save = FALSE)
          # shp <- ejam2shapefile(testoutput_ejamit_10pts_1miles, save = FALSE)
        })
      })
    )
    # map_shapes_leaflet(shp)
  )
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
################################# #

## note: cannot find a way to suppress the text output about 4 files being created - sink and capture output and suppressMessages dont help

test_that("ejam2shapefile ok if folder=tempdir()", {

  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          # make the test data smaller to try to speed it up
          tout = list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x = ejam2shapefile(tout, folder = tempdir())
        })
        junk <- capture_output({
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
################################# #

test_that("ejam2shapefile ok if folder and .shp specified", {
  extension = ".shp"
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x <- ejam2shapefile(tout, file = paste0('test', extension), folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
########################################################################## #

test_that("ejam2shapefile ok if folder and .zip specified", {
  extension <- ".zip"
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x <- ejam2shapefile(tout, file = paste0('test', extension), folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
########################################################################## #

test_that("ejam2shapefile ok if folder and .json specified", {
  extension <- ".json"
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x <- ejam2shapefile(tout, file = paste0('test', extension), folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
########################################################################## #

test_that("ejam2shapefile ok if folder and .geojson specified", {
  extension <- ".geojson"
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x <- ejam2shapefile(tout, file = paste0('test', extension), folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
########################################################################## #

test_that("ejam2shapefile ok if folder and .kml specified", {
  extension <- ".kml"
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk = capture_output({
          tout <- list(results_bysite = testoutput_ejamit_10pts_1miles$results_bysite[1:2, ])
          x <- ejam2shapefile(tout, file = paste0('test', extension), folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_true("sf" %in% class(shp))
  # expect_equal(NROW(shp), 10)
  expect_equal(NROW(shp), 2)
})
########################################################################## #

# FIPS analysis ####
# County bounds come from the built-in counties_shapefile dataset, so no download is needed.

test_that("ejam2shapefile gets polygons for a FIPS analysis, from ejam_uniq_id", {
  out <- testoutput_ejamit_fips_counties # results_bysite has the FIPS in ejam_uniq_id, no fips column
  expect_false("fips" %in% names(out$results_bysite))
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk <- capture_output({
          shp <- ejam2shapefile(out, save = FALSE)
        })
      })
    })
  })
  expect_true("sf" %in% class(shp))
  expect_equal(NROW(shp), NROW(out$results_bysite))
  expect_false(any(sf::st_is_empty(shp)))
  expect_equal(shp$FIPS, out$results_bysite$ejam_uniq_id) # same order as results_bysite
  expect_equal(shp$pop, out$results_bysite$pop) # pop from the results, not from the boundaries
})
################################# #

test_that("ejam2shapefile FIPS analysis gives empty geometry for NA ejam_uniq_id, keeping row order", {
  out <- data.table::copy(testoutput_ejamit_fips_counties)
  out$results_bysite$ejam_uniq_id[2] <- NA # as for an invalid FIPS input
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk <- capture_output({
          shp <- ejam2shapefile(out, save = FALSE)
        })
      })
    })
  })
  expect_equal(NROW(shp), 3)
  expect_equal(as.vector(sf::st_is_empty(shp)), c(FALSE, TRUE, FALSE))
  expect_equal(shp$ejam_uniq_id, c("10001", NA, "10005"))
  expect_equal(shp$FIPS[c(1, 3)], c("10001", "10005"))
})
################################# #

test_that("ejam2shapefile FIPS analysis uses a fips column if there is one", {
  bysite <- data.table::copy(testoutput_ejamit_fips_counties$results_bysite)
  bysite$FIPS <- bysite$ejam_uniq_id
  bysite$ejam_uniq_id <- 1:3
  suppressWarnings({
    suppressMessages({
      junk <- capture_output({
        shp <- ejam2shapefile(list(results_bysite = bysite, sitetype = "fips"), save = FALSE)
      })
    })
  })
  expect_equal(NROW(shp), 3)
  expect_false(any(sf::st_is_empty(shp)))
  expect_equal(shp$FIPS, c("10001", "10003", "10005"))
})
################################# #

test_that("ejam2shapefile FIPS analysis with a buffer exports the buffered footprint", {
  out0 <- testoutput_ejamit_fips_counties # radius.miles is NA, no buffer
  out1 <- data.table::copy(testoutput_ejamit_fips_counties)
  out1$results_bysite$radius.miles <- 1 # as from ejamit(fips = ..., radius = 1)
  suppressWarnings({
    suppressMessages({
      junk <- capture_output({
        shp0 <- ejam2shapefile(out0, save = FALSE)
        shp1 <- ejam2shapefile(out1, save = FALSE)
        expected0 <- shapes_from_fips(out0$results_bysite$ejam_uniq_id)
        expected1 <- shape_buffered_from_shapefile(expected0, radius.miles = 1)
      })
    })
  })
  area0 <- as.numeric(sf::st_area(shp0))
  area1 <- as.numeric(sf::st_area(shp1))
  expect_equal(area0, as.numeric(sf::st_area(expected0)))
  expect_equal(area1, as.numeric(sf::st_area(expected1)))
  expect_true(all(area1 > area0))
  expect_equal(shp1$FIPS, out1$results_bysite$ejam_uniq_id) # same order as results_bysite
})
################################# #

test_that("ejam2shapefile FIPS results table alone, with an NA ejam_uniq_id row", {
  bysite <- data.table::copy(testoutput_ejamit_fips_counties$results_bysite)
  bysite$ejam_uniq_id[2] <- NA # as for an invalid FIPS input
  # without the list from ejamit(), the FIPS site type must be inferred from the table
  skip_if(is.na(suppressWarnings(sitetype_from_dt(bysite))),
          "needs sitetype_from_dt() to ignore NA ids, as in Public-Environmental-Data-Partners/EJAM#795")
  suppressWarnings({
    suppressMessages({
      junk <- capture_output({
        shp <- ejam2shapefile(bysite, save = FALSE)
      })
    })
  })
  expect_equal(NROW(shp), 3)
  expect_equal(as.vector(sf::st_is_empty(shp)), c(FALSE, TRUE, FALSE))
  expect_equal(shp$ejam_uniq_id, c("10001", NA, "10005"))
})
################################# #

test_that("ejam2shapefile FIPS analysis can save a file", {
  expect_no_error({
    suppressWarnings({
      suppressMessages({
        junk <- capture_output({
          x <- ejam2shapefile(testoutput_ejamit_fips_counties, file = "test_fips.geojson", folder = tempdir())
          shp <- shapefile_from_any(x)
        })
      })
    })
  })
  expect_true(file.exists(x))
  expect_equal(NROW(shp), 3)
})
########################################################################## #

# input is not modified ####

test_that("ejam2shapefile does not convert the input data.table to a data.frame (latlon)", {
  tout <- list(results_bysite = data.table::copy(testoutput_ejamit_10pts_1miles$results_bysite[1:2, ]))
  before <- data.table::copy(tout)
  suppressWarnings({
    suppressMessages({
      junk <- capture_output({
        shp <- ejam2shapefile(tout, save = FALSE) # list like output of ejamit()
        shp <- ejam2shapefile(tout$results_bysite, save = FALSE) # just the table
      })
    })
  })
  expect_true(data.table::is.data.table(tout$results_bysite))
  expect_equal(tout, before)
})
################################# #

test_that("ejam2shapefile does not convert the input data.table to a data.frame (FIPS)", {
  out <- data.table::copy(testoutput_ejamit_fips_counties)
  before <- data.table::copy(out)
  suppressWarnings({
    suppressMessages({
      junk <- capture_output({
        shp <- ejam2shapefile(out, save = FALSE)
      })
    })
  })
  expect_true(data.table::is.data.table(out$results_bysite))
  expect_equal(out, before)
})
########################################################################## #


# *** if interactive it normally tries to prompt for shapefile folder in some cases  ####

## not really using these tests of interactive mode so just comment them out.


# if (interactive() & !exists("noquestions")) {
#   if ( askYesNo("run tests where you have to interactively specify a folder for shapefiles?")) {
#     noquestions = FALSE
#   }  else {
#     noquestions <- TRUE
#   }
# } else {
#   noquestions = TRUE
# }

# noquestions = TRUE

#
# test_that("ejam2shapefile ok if save=T", {
#   if (!exists('noquestions')) {noquestions <- TRUE}
#   testthat::skip_if(noquestions)
#
#   expect_no_error({
#     suppressWarnings({
#       suppressMessages({
#         junk = capture_output({
#
#           # save TRUE - note if interactive it tries to prompt for folder
#           x <- ejam2shapefile(testoutput_ejamit_10pts_1miles, save = TRUE)
#           shp = shapefile_from_any(x)
#           # map_shapes_leaflet(shp)
#
#         })
#       })
#     })
#   })
#   expect_true(file.exists(x))
#   expect_true("sf" %in% class(shp))
#   expect_equal(NROW(shp), 10)
# })
# ################################# #
#
# test_that("ejam2shapefile ok if use defaults", {
#   if (!exists('noquestions')) {noquestions <- TRUE}
#   testthat::skip_if(noquestions)
#
#   expect_no_error({
#     suppressWarnings({
#       suppressMessages({
#         junk = capture_output({
#
#           # defaults - note if interactive it tries to prompt for folder
#           x = ejam2shapefile(testoutput_ejamit_10pts_1miles)
#           # zip::zip_list(x) # not required by EJAM pkg
#           shp <- shapefile_from_any(x)
#         })
#       })
#     })
#   })
#   expect_true(file.exists(x))
#   expect_true("sf" %in% class(shp))
#   expect_equal(NROW(shp), 10)
# })
# ################################# #
#
# test_that("ejam2shapefile ok if use defaults + file", {
#   if (!exists('noquestions')) {noquestions <- TRUE}
#   testthat::skip_if(noquestions)
#
#   expect_no_error({
#     suppressWarnings({
#       suppressMessages({
#         junk = capture_output({
#
#           # provide fname - note if interactive it tries to prompt for folder
#           x = ejam2shapefile(testoutput_ejamit_10pts_1miles, file = "test.shp")
#           # zip::zip_list(x) # not required by EJAM pkg
#           shp <- shapefile_from_any(x)
#
#         })
#       })
#     })
#   })
#   expect_true(file.exists(x))
#   expect_true("sf" %in% class(shp))
#   expect_equal(NROW(shp), 10)
# })
# ########################################################################## #

