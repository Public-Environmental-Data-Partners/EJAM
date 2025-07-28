
## ***ensure THESE ARE CONSISTENT AND WORK WITH ejamit() so they
##    all do or dont assign uniq id to, and
##    all include or all omit rows in s2b for
##    invalid / 0 blocks sites of various kinds
## (fips can be good, valid but no bounds, valid but wrong type (noncity), looks right but invalid fips, NA, or NULL)
#################################################################### #
# LOOP OF TEST CASES - to just print results not run unit test ####
## getblocksnearby_from_fips_cityshape()   ####

testcases_city = function(rs=TRUE, printall=FALSE, testall=FALSE) {

  check = function(y,rs=TRUE) {
    print(deparse1(substitute(y)))
    if (rs) {
      if (NROW(y$polys) > 0) {
        print(y$polys[, intersect(names(y$polys), c('FIPS', 'geometry','ejam_uniq_id'))])
      } else {
        print("No polys table")
      }
      x <- y$pts
    } else {
      x <- y
    }
    if (!NROW(x) == 0) {x = x[,.SD[1],by="ejam_uniq_id"]}
    print(x)
    cat("--------------------------------------------------------\n")
    return(NULL)
  }
  tcaselist = list(
    c( testinput_fips_cities[1]),
    c( testinput_fips_cities[1], NA),
    c( testinput_fips_cities[1], "99"),
    "1234567",
    NA,
    c(NA,NA),
    c("1234567", "1234567"),
    c(NA, "1234567"),
    c(NA, NA, "1234567", "0234560", testinput_fips_cities[1]),
    testinput_fips_blockgroups[1],
    c(testinput_fips_cities[1], testinput_fips_blockgroups[1])
  )
  for (i in seq_along(tcaselist)) {
    n = i
    if (printall) {
      cat("input: ", paste0(tcaselist[[i]], collapse = ", "), "\n")
    }
    if (testall) {
    test_that(paste0("city case ", n," ok"), {

     x =  try({
      expect_no_error({
        z = getblocksnearby_from_fips_cityshape(tcaselist[[i]], return_shp = rs)[]
      })
       expect_true({if (rs) {"sf" %in% class(z$polys)} else { is.data.frame(z)}})
      })
    })
    }
  }
  return(NULL)
}

## was using this to print results during debugging
# testcases_city()
rm(testcases_city)
# cat("Done with loop of test cases for getblocksnearby_from_fips_cityshape()\n")
#################################################################### #

## getblocksnearby_from_fips_noncity()   ####

print_testcases_noncity = function(rs=TRUE) {

  check = function(y,rs=TRUE) {
    print(deparse1(substitute(y)))
    if (rs) {
      if (NROW(y$polys) > 0) {
        print(y$polys[, intersect(names(y$polys), c('FIPS', 'geometry','ejam_uniq_id'))])
      } else {
        print("No polys table")
      }
      x <- y$pts
    } else {
      x <- y
    }
    if (!NROW(x) == 0) {x = x[,.SD[1],by="ejam_uniq_id"]}
    print(x)
    cat("--------------------------------------------------------\n")
    return(NULL)
  }
  ## these do not output a NA row for each bad fips:

  z <- x1 <- try(getblocksnearby_from_fips_noncity(c(testinput_fips_blockgroups[1]), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x1,rs)
  z <- x2 <- try(getblocksnearby_from_fips_noncity(c(testinput_fips_blockgroups[1], NA), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x2,rs)
  z <- x3 <- try(getblocksnearby_from_fips_noncity(c(testinput_fips_blockgroups[1], "99"), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x3,rs)
  z <- x4 <- try(getblocksnearby_from_fips_noncity("99", return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x4,rs)
  z <- x5 <- try(getblocksnearby_from_fips_noncity(NA, return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x5,rs)
  z <- x6 <- try(getblocksnearby_from_fips_noncity(c(NA, NA), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x6,rs)
  z <- x7 <- try(getblocksnearby_from_fips_noncity(c("99", "99"), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x7,rs)
  z <- x8 <- try(getblocksnearby_from_fips_noncity(c(NA, "99"), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x8,rs)
  z <- x9 <- try(getblocksnearby_from_fips_noncity(c(NA, NA, "77", "99", testinput_fips_blockgroups[1]), return_shp = rs)[])
  if (!inherits(z, "try-error")) check(x9,rs)
  z <- x10 <- try(getblocksnearby_from_fips_noncity(testinput_fips_cities[1], return_shp = rs)[] )# wrong type
  if (!inherits(z, "try-error")) check(x10,rs)
  z <- x11 <- try(getblocksnearby_from_fips_noncity(c(testinput_fips_cities[1], testinput_fips_blockgroups[1]), return_shp = rs)[]) # wrong type and a valid
  if (!inherits(z, "try-error")) check(x11,rs)
  return(NULL)
}

## was using this to print results during debugging
# print_testcases_noncity()
rm(print_testcases_noncity)
# cat("Done with loop of test cases for getblocksnearby_from_fips_noncity()\n")
#################################################################### #
# . ####


################# #  ################# #  ################# ################## #

# getblocksnearby_from_fips_noncity(), a helper ####

testthat::test_that("getblocksnearby_from_fips_noncity 1 fipstype", {

  f1  <- rev(testinput_fips_blockgroups)[1:2]
  f2  <- rev(testinput_fips_tracts)[1:2]
  # f3  <- rev(testinput_fips_cities)[1:2]  #### city
  f4  <- rev(testinput_fips_counties)[1:2]
  f5  <- rev(testinput_fips_states)[1:2]

  tlist = list(f1,f2,  f4,f5)
  for (this in tlist) {
    expect_no_error({
      s2b = getblocksnearby_from_fips_noncity(this)
    })
    expect_equal(
      colnames(s2b),
      c('ejam_uniq_id', 'blockid', 'distance', 'blockwt',  'bgid', 'fips')
    )
    expect_equal(unique(s2b$fips), this)
    expect_equal(1:2, unique(s2b$ejam_uniq_id))
  }
})
################# #

testthat::test_that("getblocksnearby_from_fips_noncity fipsmix", {

  fips_mix = c(testinput_fips_blockgroups[2], testinput_fips_tracts[2],  testinput_fips_counties[2], testinput_fips_states[2])

  expect_no_error({
    s2b = getblocksnearby_from_fips_noncity(fips_mix)
  })
  expect_equal(
    colnames(s2b),
    c('ejam_uniq_id', 'blockid', 'distance', 'blockwt',  'bgid', 'fips')
  )
  expect_equal(unique(s2b$fips), fips_mix)
  expect_equal(1:length(fips_mix), unique(s2b$ejam_uniq_id))
})
################# #  ################# #  ################# ################## #

# getblocksnearby_from_fips_cityshape(), a helper ####

testthat::test_that("getblocksnearby_from_fips_cityshape just cities", {

  f3  <- rev(testinput_fips_cities)
  expect_no_error({
    s2b = getblocksnearby_from_fips_cityshape(f3)
  })
  expect_equal(
    names(s2b),
    c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "fips")
  )
  expect_equal(unique(s2b$fips), f3)
  expect_equal(unique(s2b$ejam_uniq_id), 1:2)
})
################# #  ################# #  ################# ################## #
# . ------------------------------------------------------ - ####
# getblocksnearby_from_fips(), the main function ####

## simplest tests ####

testthat::test_that("basics: 1 bg, no shp- colnames ok", {
  testthat::capture_output({
    testthat::expect_no_error({
      x <- getblocksnearby_from_fips("482011000011") # one blockgroup only
    })
    testthat::expect_setequal(
      names(x),
      c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "fips")
    )
  })
})
################# #  ################# #  ################# #

testthat::test_that("basics: return_shp=T for bgs", {

  testthat::capture_output({

    testthat::expect_no_error({
      suppressMessages({
        x <- getblocksnearby_from_fips("482011000011", return_shp=T) # one blockgroup only
        # y=doaggregate(x)
      })
    })
    testthat::expect_true("sf" %in%  class(  x$polys))

    testthat::expect_no_error({
      suppressMessages({
        x <- getblocksnearby_from_fips(fips_counties_from_state_abbrev("DE"), in_shiny = F, need_blockwt = TRUE, return_shp=T)
      })
    })

    expect_setequal(names(x), c("polys", "pts"))
    expect_true("sf" %in% class(x$polys))
    testthat::expect_setequal(
      names(x$pts),
      c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "fips")
    )
    # counties_ej <- doaggregate(x)
    #cannot use mapfast(counties_ej$results_bysite) since no lat lon.  mapfastej_counties() should work...
  })
})
################# #  ################# #  ################# ################## #  ################# #  ################# #
################# #  ################# #  ################# ################## #  ################# #  ################# #
# . ####
# LOOP OF TEST CASES: ####

## getblocksnearby_from_fips() - loop of test cases ####

testcases_each_fipstype <- function() {

  # large set of test cases
  # (bg, tract, city, county, state, mix)

  f1  <- rev(testinput_fips_blockgroups)
  f2  <- rev(testinput_fips_tracts)
  f3  <- rev(testinput_fips_cities)
  f4  <- rev(testinput_fips_counties)
  f5  <- rev(testinput_fips_states)

  ## bad inputs to test (invalid, missing poly, NA)   ####

  testinput_fips_sets <- list(
    ## possibly missing boundaries for some?
    `1 fipstype, no NA` = list(        # i = 1
      bgs     = f1,
      tracts  = f2,
      cities  = f3,
      counties= f4,
      states  = f5
    ),
    `1 of valid fips lacks geom` = list(       # i = 2
      cities = c(f3, "4273072")
    ),
    `1 noncity + 1 city` = list(       # i = 3
      cities_counties = c(f3[1], f4[1])
    ),
    `mix of noncity types` = list(       # i = 4
      all_but_cities = c(f1, f2, f4, f5)
    ),
    `mix of fips types` = list(       # i = 5
      all = c(f1, f2, f3, f4, f5)
    )
    ,
    `some fips are 99` = list(
      bgs     = c(f1, 99),
      tracts  = c(f2, 99),
      cities  = c(f3, 99),
      counties= c(f4, 99),
      states  = c(f5, 99)
    )
    ,
    `some fips NA` = list(      #
      bgs     = c(NA, f1, NA),  # ii = 1
      tracts  = c(NA, f2, NA),  # ii = 2
      cities  = c(NA, f3, NA),  # ii = 3  # ??  f3 is "2743000" "2743306"
      counties= c(NA, f4, NA),  # ii = 4
      states  = c(NA, f5, NA)   # ii = 5
    )
    ,
    `some fips NA, some 99` = list(
      bgs     = c(NA, f1, 99),
      tracts  = c(NA, f2, 99),
      cities  = c(NA, f3, 99),
      counties= c(NA, f4, 99),
      states  = c(NA, f5, 99)
    ),
    `same fips duplicated` = list(
      bgs     = c(f1[1], f1, f1[1]),
      tracts  = c(f2[1], f2, f2[1]),
      cities  = c(f3[1], f3, f3[1]),
      counties= c(f4[1], f4, f4[1]),
      states  = c(f5[1], f5, f5[1])
    )

  )

  ## params to test (return_shp, allow_multi...) ####

  for (allow_multiple_fips_types in TRUE) {
    #  for (allow_multiple_fips_types in c(TRUE, FALSE)) {   # nonessential to allow FALSE here
    cat("\n\n----------------- allow_multiple_fips_types =", allow_multiple_fips_types, ' ---------------------')

    for (return_shp in c(FALSE, TRUE)) {
      cat("\n\n         ----------------- return_shp =", return_shp, ' ---------------------\n\n')

      for (i in seq_along(testinput_fips_sets)) {

        for (ii in seq_along(testinput_fips_sets[[i]])) {

          try({
            test_that(paste0(names(testinput_fips_sets)[i],
                             paste0(" (", names(testinput_fips_sets[[i]][ii]), ")"),
                             " (return_shp=", substr(return_shp,1,1), ", allow_multi=", substr(allow_multiple_fips_types,1,1), ")"), {

                               cat(paste0("return_shp=", return_shp, ", allow_multi=", allow_multiple_fips_types, "  --"))
                               cat("  test set name:", names(testinput_fips_sets)[i],
                                   paste0("(", names(testinput_fips_sets[[i]][ii]), ")"), "\n")

                               originalfips <- as.character(as.vector(unlist(testinput_fips_sets[[i]][ii])))
                               originalfips_nona = originalfips[!is.na(originalfips)]
                               originalfips_valid = originalfips[fips_valid(originalfips)] # but might be valid with missing polygon download

                               if (allow_multiple_fips_types == FALSE & grepl("mix", names(testinput_fips_sets)[i])) {
                                 # ("allow_multiple_fips_types=FALSE but this test set has mixed fips types")
                                 expect_error({            # or may just warn now -----------------  ERROR expected since trying multiple types  when not allowed
                                   junk = capture_output({ suppressMessages({
                                     x <- getblocksnearby_from_fips(
                                       originalfips,
                                       return_shp = return_shp,
                                       allow_multiple_fips_types = allow_multiple_fips_types
                                     )
                                   })})
                                 })
                               } else {

                                 expect_no_error({            #   --------------------------------  OK - allowing multiple types
                                   junk = capture_output({ suppressMessages({

                                     x <- getblocksnearby_from_fips(
                                       originalfips,
                                       return_shp = return_shp,
                                       allow_multiple_fips_types = allow_multiple_fips_types
                                     )

                                   })})
                                 })

                                 ################## #  ################# #  ################# #
                                 if (return_shp) {

                                   ## polygons table:
                                   expect_true("sf" %in% class(x$polys))
                                   expect_equal(       x$polys$ejam_uniq_id, seq_along(originalfips)) # shp df HAS A ROW FOR EACH FIPS EVEN IF NA OR OTHERWISE INVALID?
                                   emptygeofips =  x$polys$FIPS[sf::st_is_empty( x$polys)]
                                   expect_equal(       x$polys$FIPS,                   originalfips)   # even NAs

                                   # s2b table (lacks the NAs and other invalid fips, but otherwise same ordering?)
                                   # each valid fips input has a uniq id in output
                                   expect_equal(unique(x$pts$ejam_uniq_id), seq_along(originalfips_valid[!(originalfips_valid %in% emptygeofips)]))
                                   expect_equal(unique(x$pts$fips),                   originalfips_valid[!(originalfips_valid %in% emptygeofips)])

                                 } else {

                                   # s2b table (lacks the NAs and other invalid fips, but otherwise same ordering?)
                                   # each valid fips input has a uniq id in output (unless bounds missing for valid fips)
                                   expect_true(all(unique(x$ejam_uniq_id) %in% seq_along(originalfips_valid))) # equal unless subset because bounds missing for valid fips
                                   expect_true(all(unique(x$fips)         %in%    unique(originalfips_valid)))  # ditto
                                 }
                                 ################## #  ################# #  ################# #

                               } # end no mixed types case
                             }) # end test_that
          }) # end try
        }

      }
    }
  }
  cat('\n\n')
}

#    RUN ALL THOSE TESTS:

testcases_each_fipstype()
cat("Done with loop of test cases for getblocksnearby_from_fips()\n")
# cleanup
rm(testcases_each_fipstype)

################# #  ################# #  ################# ################## #  ################# #  ################# #
################# #  ################# #  ################# ################## #  ################# #  ################# #
# . ####
# other older tests - may be redundant ####

################# #  ################# #  ################# ################## #  ################# #  ################# #

# loop tests each fipstype - older set of tests ####

## 1 type at a time, 2 sites per type ####

testfips_list <- list(testinput_fips_blockgroups, testinput_fips_tracts, testinput_fips_cities, testinput_fips_counties, testinput_fips_states)

for (testfips in testfips_list) {
  testfips <- testfips[1:2]
  ftype <- fipstype(testfips)[1]

  testthat::test_that(paste0("colnames,fips,id ok for 1 type: ", ftype), {

    testthat::capture_output({
      testthat::expect_no_error({
        suppressMessages({
          x <- getblocksnearby_from_fips(
            testfips
            # , return_shp = FALSE, allow_multiple_fips_types = FALSE
          )
        })
      })
    })
    testthat::expect_setequal(
      names(x),
      c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "fips")
    )
    testthat::expect_equal(length(unique(x$ejam_uniq_id)), length(testfips))
    testthat::expect_equal(unique(x$fips), testfips)
    testthat::expect_equal(state_from_nearest_block_bysite(x)$ST, fips2state_abbrev(testfips))
  })
}
rm(testfips_list, testfips, ftype)
################# #  ################# #  ################# ################## #  ################# #  ################# #

## mix of types  (one_of_each)   ####

testfips_list <- list(testinput_fips_blockgroups, testinput_fips_tracts, testinput_fips_cities, testinput_fips_counties, testinput_fips_states)
testfips <- sapply(testfips_list, function(x) x[1])

testthat::test_that(paste0("colnames,fips,id  ok for MIX of types"), {

  testthat::capture_output({
    testthat::expect_no_error({
      x <- getblocksnearby_from_fips(
        testfips
        # , return_shp = FALSE, allow_multiple_fips_types = FALSE
      )
    })
  })
  testthat::expect_setequal(
    names(x),
    c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "fips")
  )
  testthat::expect_equal(length(unique(x$ejam_uniq_id)), length(testfips))
  testthat::expect_equal(unique(x$fips), testfips)
  testthat::expect_equal(state_from_nearest_block_bysite(x)$ST, fips2state_abbrev(testfips))
})

rm(testfips_list, testfips)
################# #  ################# #  ################# ################## #  ################# #  ################# #


################# #  ################# #  ################# #
################# #  ################# #  ################# #

test_that("getblocksnearby_from_fips() _noncity case, output has NA rows, sorted as input", {

  # getblocksnearby_from_fips_noncity() is used

  inputfips = c("061090011001" ,"530530723132" ,"340230083002" ,"240338052021", "390490095901")
  # ONE INVALID ROW:
  inputfips[3  ] <- NA
  suppressMessages({
    suppressWarnings({
      s2b <- getblocksnearby_from_fips(inputfips)
    })
  })
  outputfips <- unique(s2b$fips)
  # cbind(inputfips, outputfips)
  expect_equal(outputfips, inputfips[c(1,2,  4,5)])

  expect_equal(unique(s2b$distance),  0)
})
################# #  ################# #  ################# #

test_that("getblocksnearby_from_fips() _cityshape case, output has NA rows, sorted as input", {

  # getblocksnearby_from_fips_cityshape() is used

  # ONE SORT OF VALID ROW- FIPS IS REAL BUT CANNOT GET POLYGONS:
  ## cannot obtain shapefile for "4273072" so shape_from_fips() returns NA row for that one, empty polygon
  x <- c("4273072", "1332412", "3920212", "2966134", "4272168")
  # AND ONE INVALID ROW:
  x[5] <- NA
  inputfips <- x

  # undebug(getblocksnearby_from_fips)
  #   undebug(getblocksnearby_from_fips_cityshape)
  #   undebug(shapes_places_from_placefips)
  #   undebug(get_blockpoints_in_shape)
  #   rm(outputfips)
  suppressMessages({  # messages about downloading bounds
    suppressWarnings({
      s2b <- getblocksnearby_from_fips(inputfips)
    })
  })
  # confirms each input is reflected in outputs even if fips was NA or bounds not downloaded
  expect_true(all.equal(unique(s2b$ejam_uniq_id) , c(2,3,4))) # because 5 is NA and 1 has no available bounds downloaded
  # the   valid fips only, appear in outputs
})
################# #  ################# #  ################# #
################# #  ################# #  ################# #

test_that("getblocksnearby_from_fips() returns NA, handles mix of city & noncity FIPS", {

  inputfips = c("061090011001", # bg
                "4273072",# city  lacks bounds available
                "1332412", "3920212", # cities
                "530530723132" , NA, NA, "240338052021", "390490095901", # bgs AND 2 fips are given as NA
                "99") # Totally INVALID FIPS code but not NA value
  suppressMessages({
    suppressWarnings({
      s2b <- getblocksnearby_from_fips(inputfips)
    })
  })

  expect_false(99 %in% unique(s2b$fips))
  outputfips <- unique(s2b$fips)
  expect_equal(outputfips, inputfips[fips_valid(inputfips) & !(inputfips %in% "4273072")])

  expect_true(NROW(s2b) > 3 * length(inputfips)) # at least 3 blocks per fips on avg
  expect_equal(unique(s2b$distance), 0)

})
################# #  ################# #  ################# #

