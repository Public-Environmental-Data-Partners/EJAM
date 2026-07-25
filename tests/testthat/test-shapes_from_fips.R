
# shapes_from_fips
junk <- capture.output({
  mystates = c('DE', "RI")
  fipslist = list(
    statefips = name2fips(mystates),
    countyfips = fips_counties_from_state_abbrev(c('DE')),
    cityfips = name2fips(c('Rehoboth Beach,DE', 'Camden,de')),
    tractfips = substr(blockgroupstats$bgfips[300:301], 1, 11),
    bgfips = blockgroupstats$bgfips[300:301]
  )
  shp <- list()

})

# for (i in seq_along(fipslist)) {
#   shp[[i]] <- shapes_from_fips(fipslist[[i]])
#   print(shp[[i]])
#   # mapfast(shp[[i]])
# }

# . ####

testthat::test_that("shapes_from_fips for statefips", {

  expect_no_error({
    shp <- shapes_from_fips(fipslist$statefips)
  })
  expect_true({'sf' %in% class(shp)})
  expect_identical(mystates, shp$STATE_ABBR)
})

testthat::test_that("shapes_from_fips for countyfips", {
  junk = capture.output({
    expect_no_error({
      suppressWarnings({

        shp <- shapes_from_fips(fipslist$countyfips)
      })
    })
  })
  expect_true({'sf' %in% class(shp)})
  expect_identical(fipslist$countyfips, shp$FIPS)
})

testthat::test_that("shapes_from_fips for cityfips", {

  expect_no_error({
    shp <- shapes_from_fips(fipslist$cityfips)
  })
  expect_true({'sf' %in% class(shp)})
  expect_identical(shp$FIPS, fipslist$cityfips)
})

testthat::test_that("shapes_from_fips for tractfips", {
  junk = capture.output({

    expect_no_error({
      shapes_from_fips( "05001480300" ); shapes_from_fips( 05001480300 ) # had a problem earlier
      shp <- shapes_from_fips(fipslist$tractfips)
    })
  })
  expect_true({'sf' %in% class(shp)})
  expect_identical(shp$FIPS, fipslist$tractfips)
  expect_identical(NROW(shp), length(fipslist$tractfips))
})

testthat::test_that("shapes_from_fips for bgfips", {
  junk = capture.output({

    expect_no_error({
      shp <- shapes_from_fips(fipslist$bgfips)
    })
  })
  expect_true({'sf' %in% class(shp)})
})
################ ################# ################# ################# ################# #

# bad fips: if fips are NA, non-NA invalid, valid but missing polygon, or duplicated (sorted, mix of types) ####

################ ################# ################# ################# ################# #
## inputs to try ####
## use these for several separate tests

inputfips <- c(NA,        # fips is NA
               "10",      # State
               "4273072", # fips valid but no polygons downloaded, so shape_from_fips() returns NA row for that one, empty polygon
               "10001",   # County not city
               99,        # fips is invalid but not NA
               "2966134", # city
               NA,        # fips is NA and dupe (i.e., more than 1 of the fips are NA)
               "2966134"  # city, duplicated fips
)
# use for several tests
junk = capture.output({
  suppressWarnings({
    suppressMessages({
      shp <- shapes_from_fips(inputfips)
    })
  })
})

# fips_not_na <- inputfips[!is.na(inputfips)]; not_na = inputfips %in% fips_not_na
# fips_not_invalid <- inputfips[fips_valid(inputfips)]; not_invalid = inputfips %in% fips_not_invalid
# fips_not_empty_polygon <- shp$FIPS[!sf::st_is_empty(shp$geometry)]; not_empty_polygon = inputfips %in% fips_not_empty_polygon
# TF_fips_not_dupe <- !( inputfips %in% inputfips[duplicated(inputfips)] ); is_unique = TF_fips_not_dupe
# inputinfo <- data.frame(inputfips,
#            not_na = ifelse(not_na, "y", "XXXX"),
#            not_invalid = ifelse(not_invalid, "y", "XXXX"),
#            not_empty_polygon = ifelse(not_empty_polygon, "y", "XXXX"),
#            is_unique = ifelse(is_unique, "y", "XXXX") # flags original AND the copy
#            )
# inputinfo

##   inputfips not_na not_invalid not_empty_polygon is_unique
##
## 1      <NA>   XXXX        XXXX              XXXX      XXXX
## 2        10      y           y                 y         y
## 3   4273072      y           y              XXXX         y
## 4     10001      y           y                 y         y
## 5        99      y        XXXX              XXXX         y
## 6   2966134      y           y                 y      XXXX
## 7      <NA>   XXXX        XXXX              XXXX      XXXX
## 8   2966134      y           y                 y      XXXX

################ ################# #
## tests of bad fips ####
################ ################# #

testthat::test_that("bad fips - no error (some fips are NA, invalid non-NA, valid but lack polygon, or duplicated)", {

  expect_no_error({
    junk = capture.output({
      suppressWarnings({
        suppressMessages({
          shp <- shapes_from_fips(inputfips)
        })
      })
    })
  })
  expect_true({'sf' %in% class(shp)})
})
################ ################# #

testthat::test_that("bad fips - returns the VALID, nonempty polygon fips at least, ignoring sort", {

  fips_with_empty_polygon <- shp$FIPS[sf::st_is_empty(shp$geometry)]
  # only 1 in shp, if NA/invalid ones are not returned at all

  expect_equal(
    sum(duplicated( shp$FIPS[!sf::st_is_empty(shp$geometry)             & fips_valid(shp$FIPS)] )),
    sum(duplicated( inputfips[!(inputfips %in% fips_with_empty_polygon) & fips_valid(inputfips)] ))
  )
  expect_setequal(
    shp$FIPS[!sf::st_is_empty(shp$geometry)             & fips_valid(shp$FIPS)],
    inputfips[!(inputfips %in% fips_with_empty_polygon) & fips_valid(inputfips)]
  )
})
################ #

testthat::test_that("bad fips - returns the VALID, nonempty polygon fips at least, SORTED", {

  fips_with_empty_polygon <- shp$FIPS[sf::st_is_empty(shp$geometry)]

  expect_equal(
    shp$FIPS[!sf::st_is_empty(shp$geometry)             & fips_valid(shp$FIPS)],
    inputfips[!(inputfips %in% fips_with_empty_polygon) & fips_valid(inputfips)]
  )
})
################ ################# #

testthat::test_that("bad fips - returns the (VALID) fips at least, ignoring sort, even if some bounds unavailable", {

  expect_equal(
    sum(duplicated(shp$FIPS[ fips_valid(shp$FIPS)])),
    sum(duplicated(inputfips[fips_valid(inputfips)]))
  )
  # same fips returned as input, for the valid, nonNA ones at least,
  #  ignoring sort
  expect_setequal(
    shp$FIPS[ fips_valid(shp$FIPS)],
    inputfips[fips_valid(inputfips)] # "10"      "4273072" "10001"     "2966134" "2966134"
  )
})
################ #

testthat::test_that("bad fips - returns the (VALID) fips at least, SORTED, even if some bounds unavailable", {

  # same fips returned as input, for the valid, nonNA ones at least,
  #  original sort order
  expect_equal(
    shp$FIPS[ fips_valid(shp$FIPS)],
    inputfips[fips_valid(inputfips)]
  )
})
################ ################# #

testthat::test_that("bad fips - returns the non-NA (VALID) fips at least, ignoring sort, but not necessarily valid fips missing bounds", {

  expect_equal(
    sum(duplicated(shp$FIPS[!is.na(shp$FIPS)  ])),
    sum(duplicated(inputfips[!is.na(inputfips)]))
  )
  # expect_setequal(
  #   shp$FIPS[!is.na(shp$FIPS)  ],  # NA instead of  "99" so this test would fail
  #   inputfips[!is.na(inputfips)]   # includes "99"
  # )
  expect_setequal(
    shp$FIPS[!is.na(fips_lead_zero(  shp$FIPS))  ],  # NA instead of  "99" once fips_lead_zero is done
    inputfips[!is.na(fips_lead_zero( inputfips))]   # NA instead of "99" once fips_lead_zero is done
  )
  expect_setequal(
    shp$FIPS[fips_valid(shp$FIPS)  ],  # removes "99" and NA values
    inputfips[fips_valid(inputfips)]   # removes "99" and NA values
  )
})
################ #

testthat::test_that("bad fips - returns non-NA (VALID) input fips at least, SORTED, but maybe not valid fips missing bounds", {

  expect_equal(
    shp$FIPS[fips_valid(shp$FIPS)  ]
    ,  # fips_valid() drops the   "99" and NA values
    inputfips[fips_valid(inputfips)]
  )
})
################ ################# #

testthat::test_that("bad fips - returns ALL (VALID) input fips, ignoring sort", {

  # expect_equal(
  #   sum(duplicated(shp$FIPS)),   #### would fail since the original "99" is NA within shp$FIPS, and is counted as another duplicate
  #   sum(duplicated(inputfips))
  # )
  expect_equal(
    sum(duplicated(shp$FIPS[fips_valid(shp$FIPS)])),
    sum(duplicated(inputfips[fips_valid(inputfips)]))
  )

  # same length vectors in/out?
  expect_equal(
    NROW(shp),
    length(inputfips)
  )

  # # does it include NA in output for the fips that is NA ? ***
  # expect_setequal(
  #   shp$FIPS,  # 99 was turned into NA
  #   inputfips  # has 99
  # )
  # does it include NA in output for the fips that is NA ? ***
  expect_setequal(
    shp$FIPS[fips_valid(shp$FIPS)],
    inputfips[fips_valid(inputfips)]
  )
})
################ #

testthat::test_that("bad fips - returns ALL (VALID) input fips, SORTED", {

  # does it include NA in output for the fips that is NA ? ***
  # expect_equal(
  #   shp$FIPS,
  #   inputfips
  # )
  expect_equal(
    shp$FIPS[fips_valid(shp$FIPS)],
    inputfips[fips_valid(inputfips)]
  )
})
################ ################# #


################ ################# ################# ################# ################# #
################ ################# ################# ################# ################# #

testthat::test_that("shapes_from_fips misc cases", {

  suppressMessages({
    expect_warning({shp <- shapes_from_fips("string not fips")})
    expect_true({NROW(shp) == 1 & sf::st_is_empty(shp$geometry)})

    expect_warning({shp1 <- shapes_from_fips(-1)})
    expect_true({NROW(shp1) == 1 & sf::st_is_empty(shp1$geometry)})

    expect_warning({shp <- shapes_from_fips(c("string not fips", 99))})
    expect_true({NROW(shp) == 2 & all(sf::st_is_empty(shp$geometry))})

    expect_warning({shp <- shapes_from_fips(NULL)})
    expect_null({shp})

    expect_true({2 == NROW(shapes_from_fips(c(1,0)))})  # some ok some not - state

    shp = shapes_from_fips(c('10001', '99999'))
    expect_true({
      NROW(shp) == 2 & all.equal(shp$FIPS , c("10001", NA)) # "99999") ) # right now, invalid FIPS get turned to NA
      })  # some ok some not - county

      shp <- shapes_from_fips(c('2513205','1239999'))
    expect_true({
      NROW(shp) == 2 & sf::st_is_empty(shp$geometry[2])
    })  # some ok some not - city
  })
})
################ ################# ################# ################# ################# #



################ ################# ################# ################# ################# #

# counties_shapefile built into the package, used instead of downloading ####

testthat::test_that("counties_shapefile dataset looks right", {

  expect_true({"sf" %in% class(counties_shapefile)})
  expect_true({all(c("GEOID", "geometry") %in% names(counties_shapefile))})
  # counties and county equivalents in the 50 states, DC, PR, and island areas
  expect_true({NROW(counties_shapefile) > 3000})
  expect_false({any(duplicated(counties_shapefile$GEOID))})
  expect_true({all(nchar(counties_shapefile$GEOID) == 5)})
})

testthat::test_that("shapes_counties_from_countyfips_local() serves known county fips", {

  myfips <- c("10001", "10003", "10005")
  shp <- EJAM:::shapes_counties_from_countyfips_local(myfips)

  expect_true({"sf" %in% class(shp)})
  expect_identical(myfips, shp$FIPS)          # same order as input
  expect_equal(NROW(shp), length(myfips))     # one row per input fips
  expect_false({any(sf::st_is_empty(shp))})   # real boundaries, not empty polygons
})

testthat::test_that("shapes_counties_from_countyfips_local() returns NULL rather than partial results", {

  # if any requested fips is not in the built-in dataset, the caller must be able
  # to fall back to downloading, instead of getting an answer missing some counties
  expect_null({EJAM:::shapes_counties_from_countyfips_local(c("10001", "99999"))})
  expect_null({EJAM:::shapes_counties_from_countyfips_local("99999")})
})

testthat::test_that("built-in county bounds match what downloading returns", {

  testthat::skip_if_offline()
  testthat::skip_if(nchar(Sys.getenv("CENSUS_API_KEY")) == 0,
                    "no CENSUS_API_KEY, so cannot compare against the download path")

  myfips <- c("10001", "10003", "10005")
  junk <- capture.output({
    suppressWarnings({
      local_shp <- EJAM:::shapes_counties_from_countyfips(myfips, use_local = TRUE)
      dl_shp    <- EJAM:::shapes_counties_from_countyfips(myfips, use_local = FALSE)
    })
  })

  expect_identical(names(local_shp), names(dl_shp))
  # every non-geometry column should be identical no matter where bounds came from
  expect_equal(sf::st_drop_geometry(local_shp), sf::st_drop_geometry(dl_shp),
               ignore_attr = TRUE)
  # ... and so should the GEOMETRIES: both paths must serve the same cartographic
  # vintage (acs_endyear()), or use_local changes *which* boundaries are served,
  # not just where they come from (review finding on PR #472)
  expect_equal(sf::st_coordinates(local_shp), sf::st_coordinates(dl_shp))
})

testthat::test_that("built-in county bounds vintage matches the runtime download vintage", {
  # offline guard for the same contract as above: the dataset must be generated
  # from the same cartographic vintage the download path requests (acs_endyear());
  # regenerate via data-raw/datacreate_counties_shapefile.R if this ever fails
  expect_true(grepl(paste0("GENZ", acs_endyear()),
                    attr(counties_shapefile, "source_url"), fixed = TRUE))
})

testthat::test_that("county bounds work with no CENSUS_API_KEY (as on the API server)", {

  # the whole point of building the bounds into the package: a container with no
  # Census API key and no network can still map a County
  oldkey <- Sys.getenv("CENSUS_API_KEY")
  on.exit(Sys.setenv(CENSUS_API_KEY = oldkey), add = TRUE)
  Sys.setenv(CENSUS_API_KEY = "")

  myfips <- c("10001", "10003", "10005")
  expect_no_warning({
    shp <- EJAM:::shapes_counties_from_countyfips(myfips)
  })
  expect_identical(myfips, shp$FIPS)
})

testthat::test_that("use_local=FALSE still uses the download path", {

  # Proof that the built-in bounds are really bypassed: with no CENSUS_API_KEY,
  # the download path warns about the missing key before it tries the network.
  # If use_local=FALSE were silently served locally, no such warning would occur.
  # try() swallows whatever the ensuing network attempt does, which is not the point here.
  oldkey <- Sys.getenv("CENSUS_API_KEY")
  on.exit(Sys.setenv(CENSUS_API_KEY = oldkey), add = TRUE)
  Sys.setenv(CENSUS_API_KEY = "")

  warns <- character(0)
  junk <- capture.output({
    withCallingHandlers(
      try(EJAM:::shapes_counties_from_countyfips("10001", use_local = FALSE), silent = TRUE),
      warning = function(w) {
        warns <<- c(warns, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
  })
  expect_true({any(grepl("CENSUS_API_KEY", warns))})
})
################ ################# ################# ################# ################# #
