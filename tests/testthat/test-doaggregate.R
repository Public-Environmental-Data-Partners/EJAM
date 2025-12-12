############################################################################## #

## unit tests for EJAM::doaggregate

## Initial set of tests checks function works with good inputs, and
## correctly handles bad table input or bad radius input.
##
## More tests needed, to check handling of other input parameters.


if (!exists('blockwts')) {
  stop('tests cannot run without blockwts dataset being loaded')
}
################# #  ################# #  ################# #

################# #
# DOES IT STILL RETURN WHAT IT USED TO, OR HAS FUNCTION CHANGED SO THAT OUTPUTS NO LONGER MATCH ARCHIVED OUTPUTS? ####
################# #

test_that("still returns same results_overall as saved", {

  # # data created/saved was this:
  # out_data_doagg <- doaggregate(out_data_getblocks, sites2states_or_latlon = testpoints_data, radius = myrad, include_ejindexes = TRUE) # not the default but want to test this way

  suppressWarnings({
    # WHAT IT RETURNS NOW:
    x <- doaggregate(testoutput_getblocksnearby_10pts_1miles,
                     sites2states_or_latlon = testpoints_10,
                     radius = 1, include_ejindexes = TRUE)
    overall_has_changed <- !isTRUE(
      all.equal(
      testoutput_doaggregate_10pts_1miles$results_overall,
      x$results_overall)
      )
  })
  expect_equal(
    testoutput_doaggregate_10pts_1miles$results_overall,
    x$results_overall # use defaults
  )
  skip_if(overall_has_changed, "not testing all outputs of doaggregate against archived since results_overall test failed")
  # overall_has_changed

  expect_equal(
    testoutput_doaggregate_10pts_1miles$results_bysite,
    x$results_bysite # use defaults
  )
  expect_equal(
    testoutput_doaggregate_10pts_1miles$results_bybg_people,
    x$results_bybg_people # use defaults
  )
  expect_equal(
    testoutput_doaggregate_10pts_1miles$longnames,
    x$longnames # use defaults
  )
  rm(x)
})
############################################################################## #
############################################################################## #

# CAN WE REPLICATE NUMBERS doaggregate() REPORTS FOR 1 SITE?  ####
# doaggregate() aggregation over 3 complete bgs at the 1 site

#   Do numbers look right in results_bysite, etc.?
# had done replication via comparison to ejscreen epa api outputs and to prior results

# replicate = function() {

# create test data
# analyze 1 site that is a tract that contains 5 blockgroups and 230 blocks
inputfips = "01117030701"
bgfips_in = fips_bgs_in_fips(inputfips) #
junk = capture_output({suppressMessages({
  s2b = getblocksnearby_from_fips(inputfips)
  bysite = doaggregate(s2b)$results_bysite  # finds bysite$state.pctile.Demog.Index 26, bysite$state.pctile.Demog.Index.Supp 25
})})
bgstats <- copy(blockgroupstats[bgfips %in% bgfips_in])

geocols = c("ejam_uniq_id", "pop", "ST", "statename", "REGION", "in_how_many_states",
            "radius.miles", "lat", "lon",
            "area", "sitecount_avg",
            "sitecount_max", "sitecount_unique", "distance_min", "distance_min_avgperson", "bgcount_near_site", "blockcount_near_site"
)
summedcols <-  names(bgstats)[calctype(names(bgstats)) %in% 'sum of counts']
summedcols <- setdiff(summedcols, "area") #
################### #
test_that("replicate geocols", {

  expect_equal(bysite$ejam_uniq_id, 1)
  expect_equal(bysite$pop, sum(bgstats$pop))
  expect_equal(bysite$ST, fips2state_abbrev(inputfips)[1])
  expect_equal(bysite$statename, fips2statename(inputfips)[1])
  expect_equal(bysite$in_how_many_states, 1)
  expect_equal(bysite$REGION, fips_st2eparegion(fips2state_fips(inputfips)))
  expect_equal(bysite$radius.miles, 0)
  expect_equal(bysite$lat, NA)# (varies by latlon,fips,shp cases)
  expect_equal(bysite$lon, NA)# (varies by latlon,fips,shp cases)
  # area  # (varies by latlon,fips,shp cases)
  # "sitecount_max", "sitecount_unique", "distance_min", "distance_min_avgperson", "bgcount_near_site", "blockcount_near_site"
})
################### #
test_that("replicate sums", {

  ## can we replicate all the indicators that are aggregated over blockgroups at site via sum() ?

  x_calculated_here <-   bgstats[, lapply(.SD, function(x) sum(x)), .SDcols = summedcols]
  x_doag <- bysite[, ..summedcols]
  expect_equal(round(x_calculated_here, 3), round(x_doag, 3))
})
################### #
## can we replicate all the indicators that are aggregated over blockgroups at site via population weighted mean?

popwtdmeancols = names(bysite)[calcweight(names(bysite)) %in% 'pop'] # about 47 of the columns are aggregated this way
popwtdmeancols <- intersect(popwtdmeancols, names(bgstats))
# [1] "sitecount_avg" is in doag output but not in blockgroupstats

test_that("replicate popwtd means", {

  x_calculated_here <-   bgstats[, lapply(.SD, function(x) sum(x * pop)/sum(pop) ), .SDcols = popwtdmeancols]
  x_doag <- bysite[, ..popwtdmeancols]
  expect_equal(round(x_calculated_here, 3), round(x_doag, 3))
})

## can we replicate yesno columns like air nonattainment (yesno_airnonatt)

flagcols =  names(bgstats)[calctype(names(bgstats)) %in% "flag" ]
################### #
test_that("replicate yesno columns", {

  x_calculated_here = as.vector(unlist(lapply(bgstats[,..flagcols], max)))
  x_doag = as.vector(unlist(bysite[,..flagcols]))
  expect_equal((x_calculated_here), (x_doag))
})
################### #
othercols = setdiff(names(bysite), c(popwtdmeancols, summedcols, geocols, flagcols))
################### # ################### #

## can we replicate pctilecols?

# US percentiles
# This assumes pctile_from_raw_lookup() works correctly and just checks that doaggregate() used it as expected

pctilecols = grep("pctile", othercols, value = T)
uspctilecols = grep("^pctile", othercols, value = T)
statepctilecols = grep("^state.pctile", othercols, value = T)
forpctilecols = gsub("pctile.", "", uspctilecols)
################### #
test_that("replicate percentiles US", {

  suppressWarnings({
    # and see calc_pctile_columns()
    x_calculated_here = as.vector(pctile_from_raw_lookup(bysite[,..forpctilecols],
                                                         varname.in.lookup.table = forpctilecols))
  })
  x_doag = as.vector(unlist(bysite[,..uspctilecols]))
  expect_equal(x_calculated_here, x_doag)
})
################### # ################### #

# STATE percentiles   - problem with  bysite$state.pctile.Demog.Index.Supp

forpctilecols = gsub("state.pctile.", "", statepctilecols)
################### #
test_that("replicate percentiles STATE", {

  ## created test data like this:
  ## analyze 1 site that is a tract that contains 5 blockgroups and 230 blocks
  # inputfips = "01117030701"
  # bgfips_in = fips_bgs_in_fips(inputfips)
  # s2b = getblocksnearby_from_fips(inputfips)
  # bysite = doaggregate(s2b)$results_bysite

  suppressWarnings({
    # and see calc_pctile_columns()
    x_calculated_here = as.vector(pctile_from_raw_lookup(bysite[, ..forpctilecols], # this would use Demog.Index, Demog.Index.Supp, but need .State after those here
                                                         varname.in.lookup.table = forpctilecols, # ok
                                                         lookup = statestats,
                                                         zone = bysite$ST))

    # account for pctile.Demog.Index      since it does not use Demog.Index      as basis, but needs Demog.Index.State
    # account for pctile.Demog.Index.Supp since it does not use Demog.Index.Supp as basis, but needs Demog.Index.Supp.State
    forpctilecols_fixed = gsub("(Demog.Index.*)", "\\1.State", forpctilecols)
    # and see calc_pctile_columns()
    x_calculated_here_fixed = as.vector(pctile_from_raw_lookup(bysite[, ..forpctilecols_fixed],  # fixed
                                                               varname.in.lookup.table = forpctilecols,
                                                               lookup = statestats,
                                                               zone = bysite$ST))

  })
  x_doag = as.vector(unlist(bysite[, ..statepctilecols]))

  expect_equal(x_calculated_here_fixed, x_doag)
  #expect_equal(x_calculated_here,       x_doag)
  ## if not fixed by changing demog index ones for calculation here (as done in doaggregate() code),  the "Demog.Index.Supp" pctile fails to replicate:
  # `actual[1:5]`:   26.0  **29.0  25.0 0.0 62.0
  # `expected[1:5]`: 26.0  **25.0  25.0 0.0 62.0
})
################### # ################### #
## can we replicate averages?  ratios?

avg.or.ratio.cols = grep("avg\\.", othercols, value = T)
ratiocols = grep("ratio", avg.or.ratio.cols, invert = F, value = T)
avgcols = grep("ratio", avg.or.ratio.cols, invert = T, value = T)
usavgcols = grep("^avg", avgcols, value = T)
stavgcols = grep("state.avg", avgcols, value = T)
################### #
test_that("replicate US AVG", {

  x_calculated_here = as.vector(EJAM:::usastats_means(gsub("avg.", "", usavgcols)) )
  x_doag = as.vector(unlist(bysite[, ..usavgcols]))
  expect_equal(x_calculated_here, x_doag)
})
################### #
test_that("replicate STATE AVG", {

  x_calculated_here =  as.vector(unlist(statestats[statestats$PCTILE %in% "mean" & statestats$REGION  %in% "AL", gsub("state.avg.", "", stavgcols)]))
  # x_calculated_here_approx =  as.numeric(as.vector(EJAM:::statestats_means(ST = bysite$ST, gsub("state.avg.", "", stavgcols))[gsub("state.avg.", "", stavgcols),] ))
  x_doag = as.vector(unlist(bysite[, ..stavgcols]))
  expect_equal(round(x_calculated_here, 3), round(x_doag, 3))
  # expect_equal(round(x_calculated_here_approx, 2), round(x_doag, 2))
})
################### #
othercols = setdiff(othercols, c(pctilecols, avg.or.ratio.cols))

## can we replicate other weighted means besides population weights?

otherwtdmeancols = othercols[calctype(othercols) %in% "wtdmean" ]
# > sort(table(calcweight(otherwtdmeancols)), decreasing = T)
# lan_universe          hhlds        lingiso        age25up     builtunits disab_universe  occupiedunits  povknownratio unemployedbase
#          12              4              4              1              1              1              1              1              1
################### #
test_that("***replicate other wtdmeans?", {

  wts = bgstats[ , calcweight(otherwtdmeancols), with = F]
  ## these could be checked also
  expect_equal(sum(bgstats$povknownratio * bgstats$pctlowinc) / sum(bgstats$povknownratio),
               bysite$pctlowinc)
  # this only checked one of the indicators





})
################### #
# bgstats$lan_universe seems wrong - why the same for each bg that is aggregated in this analysis? ***

othercols = setdiff(othercols, c(   otherwtdmeancols))
# none left


# } # if in a function

### run the replication tests
# replicate()

# rm(replicate)
############################################################################## #
############################################################################## #

# IF ALL INPUTS ARE NORMAL ####
################# #

################# ################## ################## #

test_that("doag if SHAPE all valid", {  # add a test of NAs? ***

  junk = capture_output({
    shp <- rbind(testinput_shapes_2, testinput_shapes_2[2,], testinput_shapes_2[1,])
    suppressWarnings({
      s2b <- get_blockpoints_in_shape(polys = shp)$pts
      x <- doaggregate(s2b)
    })
  })
  expect_equal( (x$results_bysite$ejam_uniq_id), 1:NROW(shp))
})
################# ################## ################## #

test_that('doag if LATLON all valid', {

  junk = capture_output({
    expect_no_error({
      suppressWarnings({
        val <- doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles,
                           sites2states_or_latlon = testpoints_10,
                           radius = max(testoutput_getblocksnearby_10pts_1miles$distance), include_ejindexes = TRUE)
      })
    })
  })
  expect_true('list' %in% class(val))
  expect_equal(val$results_bysite$ejam_uniq_id, 1:10)
  expect_identical(
    names(val),
    c("results_overall", "results_bysite", "results_bybg_people",
      "longnames", "count_of_blocks_near_multiple_sites")
  )
})
################# ################## ################## #

test_that('doag if FIPS all valid', {

  junk = capture_output({
    expect_no_error({
      suppressWarnings({
        val <- doaggregate(sites2blocks = getblocksnearby_from_fips(testinput_fips_counties[1:2]),
                           # sites2states_or_latlon = ???,
                           silentinteractive = T)
      })
    })
  })
  expect_true('list' %in% class(val))
  expect_equal(val$results_bysite$ejam_uniq_id, 1:2)
  expect_identical(
    names(val),
    c("results_overall", "results_bysite", "results_bybg_people",
      "longnames", "count_of_blocks_near_multiple_sites")
  )
})
################# ################## ################## #

################### #
# IF SOME INPUTS ARE INVALID / LACK BLOCKS? ####
################### #

# see similar tests of getblocksnearby()

test_that("doag returns only valid sites, if 1 of LATLON is NA", {

  inputsitenumber <- c(3,1,2,5,4) # this is the sitenumber not the ejam_uniq_id assigned!
  input_ejam_uniq_id <- 1:5
  dat <- testpoints_10[inputsitenumber, ]
  # ONE INVALID ROW:
  dat[3, ] <- NA
  junk = capture_output({
    suppressWarnings({
      suppressMessages({
        dat <- state_from_sitetable(dat)
      })
    })
  })
  inputstates <- dat$ST

  # getblocksnearby() will return distance of NA if a row of inputs is NA values
  suppressWarnings({
    s2b <- getblocksnearby(dat, radius = 1, quiet = TRUE)
  })
  ########### #
  junk = capture_output({
    suppressWarnings({

      # if given NO sites2states_or_latlon,
      # does doaggregate() include invalid sites in d1$results_bysite$ejam_uniq_id ? ***
      d1 = doaggregate(s2b, radius = 1)  # s2b has a row with valid id but other columns are NA
      outputstates1 = d1$results_bysite$ST
      outid1 = d1$results_bysite$ejam_uniq_id

      # if given sites2states_or_latlon with original ejam_uniq_id 1:5,
      # does doaggregate() include invalid sites in d1$results_bysite$ejam_uniq_id ? ***
      d2 = doaggregate(s2b, sites2states_or_latlon = dat, radius = 1)
      outputstates2 = d2$results_bysite$ST
      outid2 = d2$results_bysite$ejam_uniq_id
    })
  })

  # print(inputstates)
  # print(outputstates1); print(outputstates2)
  #
  # print(input_ejam_uniq_id)
  # print(outid1); print(outid2)

  expect_equal(outid1, input_ejam_uniq_id[!is.na(dat$lat)])
  expect_equal(outid2, input_ejam_uniq_id[!is.na(dat$lat)])

  expect_equal(outputstates1, inputstates[!is.na(dat$lat)])
  expect_equal(outputstates2, inputstates[!is.na(dat$lat)])
})
################# ################## ################## #

test_that("doag returns only valid sites, if 1 of NONCITY fips invalid", {

  inputfips = c("061090011001" ,"530530723132" ,"340230083002" ,"240338052021", "390490095901")
  # ONE INVALID ROW:
  inputfips[3  ] <- NA
  junk = capture_output({
    suppressWarnings({
      suppressMessages({
        s2b <- getblocksnearby_from_fips(inputfips)
        x <- doaggregate(s2b)  # doag now outputs 1:N as ejam_uniq_id here since output of getblocks... is always 1:N now
        outputid =  x$results_bysite$ejam_uniq_id
        inputid = seq_along(inputfips)
      })
    })
  })

  # at least the NON-NA fips are sorted same in output of doag as in input of doag
  testthat::expect_equal(fips2pop(inputfips[!is.na(inputfips)]),  x$results_bysite$pop )

  # BUT, the NA fips is NOT in output of doag.: ***
  #  expect_equal(outputid, inputid)   #####   is there one row in output for each input including invalid ones? no - ejamit() handles that but doaggregate() does not ?
  expect_equal(outputid, inputid[!is.na(inputfips)])
})
################# ################## ################## #

test_that("doag returns only valid sites, if some of CITY FIPS lack blocks", {

  # See effects of sites with zero blocks found

  ################# #
  neednewexample <- FALSE #   neednewexample <- TRUE
  if (neednewexample) {

    rm(shp4, inputfips4, shp5a, noshpfips, noshpfips1, shp5, inputfips5, inputfips, shp)
    ## get 4 valid fips that return boundaries shp data
    shp4 <- data.frame(GEOID = NA)
    while (any(is.na(shp4$GEOID))) {
      inputfips4 <- dput(as.character(sample(censusplaces$fips, 4)))
      shp4 <- shapes_from_fips(inputfips4)
    }
    cat(inputfips4, "are valid fips with available shape bounds for download\n")
    ## find one valid fips that lacks available shape bounds for download
    shp5a <- data.frame(GEOID = 999)
    while (!any(is.na(shp5a$GEOID))) {
      noshpfips <- dput(as.character(sample(censusplaces$fips, 5)))
      shp5a <- shapes_from_fips(noshpfips)
    }
    noshpfips1 <- noshpfips[is.na(shp5a$GEOID)][1]
    cat(noshpfips1, "is a valid fips but lacks spatial bounds data\n")
    # add the one that lacks shape data
    inputfips5 <- c(inputfips4[2:1], noshpfips1, inputfips4[3:4])
    shp5 <- shapes_from_fips(inputfips5)
    print(sf::st_drop_geometry(shp5[, c(1:4, NCOL(shp5))]))
    cbind(inputfips5)
    print(dput(inputfips5))
    # ONE INVALID ROW in addition to the one lacking boundaries data:
    inputfips <- inputfips5
    inputfips[!is.na(shp5$GEOID)][2] <- NA

    shp <- shapes_from_fips(inputfips)
    print(sf::st_drop_geometry(shp[, c(1:4, NCOL(shp))]))
    print(dput(inputfips))

    rm(shp4, inputfips4, shp5a, noshpfips, noshpfips1, shp5, inputfips5 )
  }
  ################# #

  inputfips <- c("264240", "1941475", "2377625", "1937560", "3862060") # dput(as.character(sample(censusplaces$fips, 5)))
  inputids = seq_along(inputfips)
  junk = capture_output({
    suppressWarnings({
      s2b <- getblocksnearby_from_fips(inputfips, return_shp = TRUE)
    })
    # which(inputfips %in% s2b$fips) # missing those with zero blocks found (invalid fips or no downloaded polygons available)

    # without sites2states_or_latlon at all, it does not have all the original fips -- missing those with zero blocks due to lack of bounds download available
    x <- doaggregate(s2b$pts)
    outputids1 <- x$results_bysite$ejam_uniq_id

    # with sites2states_or_latlon but not ejam_uniq_id in it
    x <- doaggregate(s2b$pts, sites2states_or_latlon = data.frame(fips = inputfips, ST = fips2state_abbrev(inputfips)))
    outputids2 <- x$results_bysite$ejam_uniq_id

    # with ejam_uniq_id in sites2states_or_latlon
    x <- doaggregate(s2b$pts, sites2states_or_latlon = data.frame(ejam_uniq_id = inputids, fips = inputfips, ST = fips2state_abbrev(inputfips)))
    outputids3 <- x$results_bysite$ejam_uniq_id
  })
  expect_equal(outputids1, inputids[!sf::st_is_empty(s2b$polys)])
  expect_equal(outputids2, inputids[!sf::st_is_empty(s2b$polys)])
  expect_equal(outputids3, inputids[!sf::st_is_empty(s2b$polys)]) # even if ejam_uniq_id in sites2states_or_latlon passed to doag
})
################# ################## ################## #


################# #
# IF ALL INPUT IS BAD ####
################# #

test_that('error if in inputs are null, empty, NA, or blank',{
  expect_warning(doaggregate(NULL, silentinteractive = TRUE))
  expect_warning(doaggregate(NA, silentinteractive = TRUE))
  expect_error(doaggregate())
  expect_warning({
    x <- doaggregate('', silentinteractive = TRUE)
  })
  expect_true(is.null(x))
})
################# #
test_that('warn but no error if input is data.frame but not data.table (?)', {
  df <- data.table::setDF(  data.table::copy(testoutput_getblocksnearby_10pts_1miles) )
  suppressWarnings(
    expect_no_error(doaggregate(df))
  )
  suppressWarnings(
    expect_warning({
      x <- doaggregate(df)
    })
  )
  expect_true("results_overall" %in% names(x))
})
################# #
test_that('error if input has column not named distance', {
  wrongnames <- data.table::copy(testoutput_getblocksnearby_10pts_1miles)
  data.table::setnames(wrongnames, 'distance', 'radius')
  suppressWarnings({
    expect_warning({
      suppressMessages({
        junk = capture_output({
          x <- doaggregate(sites2blocks = wrongnames)
        })
      })
    })
  })
  expect_true("results_overall" %in% names(x))
})
###############################################  ##
# TESTS TO ADD, FOR HANDLING OF MISSING or various values for  param  sites2states_or_latlon
#
# This case never arises if using shiny app  or ejamit
#
# testthat::test_that("doaggregate() handles missing sites2states_or_latlon", {
#   expect_error({
#     x = doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles,
#                     radius = 1)
#     })
# })
# doaggregate(testpoints_10[1:2,], radius = 1)

################# #  ################# #  ################# #

################# #
# IF RADIUS NUMBER IS UNUSUAL / NOT ALLOWED  ####
################# #

# note that SOME OF THESE TESTS ARE A BIT REDUNDANT AND MAYBE CAN GET CLEANED UP- IT IS COMPLICATED HOW RADIUS CAN BE INFERRED OR IS SUPPLIED BUT DOES NOT SEEM TO MATCH WHAT MUST HAVE BEEN USED IN getblocksnearby()

test_that('warning if ask for radius < 0', {
  junk = capture_output({
    expect_no_warning(
      suppressMessages({
        doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles , radius = 0)
      })
    )
    expect_warning({
      suppressMessages({
        x <- doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles , radius = -0.001)
      })
    })
    expect_true("results_overall" %in% names(x))
  })
})

test_that('warning if ask for radius > 32, and just uses 32 instead', {
  # if (radius > 32) {radius <- 32; warning("Cannot use radius above 32 miles (almost 51 km) here - Returning results for 32 miles!")}
  junk = capture_output({
    suppressWarnings(
      expect_warning({
        x <- doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles , radius = 32.01, silentinteractive = TRUE)
      }))
  })
  expect_true("results_overall" %in% names(x))
})

testthat::test_that("same result if radius requested is 32 or 50, since >32 gets treated as if 32", {
  junk = capture_output({
    suppressMessages(suppressWarnings(x <- doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles, radius = 50, silentinteractive = TRUE) ))
    suppressMessages(suppressWarnings(y <- doaggregate(sites2blocks = testoutput_getblocksnearby_10pts_1miles, radius = 32, silentinteractive = TRUE) ))
  })
  expect_equal(x, y, ignore_attr = TRUE)
})

test_that("no warning if radius = 32 exactly IF original analysis was for AT LEAST 1/1.5x that radius", {
  x = getblocksnearby(testpoints_10[1,], radius = 1.01 * (32 / 1.5), quiet = TRUE) # 1.5x is where it starts to warn now in doag
  testthat::expect_no_warning({
    junk = capture_output({
      suppressMessages({
        y <- doaggregate(sites2blocks = x, radius = 32, silentinteractive = TRUE)
      })
    })
  })
  expect_true("results_overall" %in% names(y))
})

test_that("warning if radius = 32 exactly and original analysis was LESS THAN 1/1.5x that radius", {
  x = getblocksnearby(testpoints_10[1,], radius = 0.99 * (32 / 1.5), quiet = TRUE)
  testthat::expect_warning({
    junk = capture_output({
      suppressMessages({
        y <- doaggregate(sites2blocks = x, radius = 32, silentinteractive = TRUE)
      })
    })
  })
  expect_true("results_overall" %in% names(y))
})

test_that("radius param to doag that is very small relative to radius seen from getblocks get reported and used to filter distances", {
  junk = capture_output({
    suppressMessages({
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = 0.25)$results_bysite$radius.miles[1]
    })
  })
  expect_equal(
    x,
    0.25
  )
})

test_that("radius param to doag that is 1.5x as big as radius seen from getblocks gets reported anyway as radius instead of inferring!?!? - do we want that???", {
  suppressWarnings(
    suppressMessages({
      junk = capture_output({
        x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = 1.5)$results_bysite$radius.miles[1]
      })
    })
  )
  expect_false(isTRUE(all.equal(x, 1.5)))
})

test_that("radius param to doagg that is MUCH larger than seen from getblocks is ignored and doag uses inferred radius instead", {
  suppressWarnings({
    suppressMessages({
      y <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = 1.6)$results_bysite$radius.miles[1]
    })
    expect_equal(
      y, 1
    )
  })
})
################# #  ################# #  ################# #


################# #
# IF RADIUS INPUT IS NOT A REAL NUMBER  ####
################# #

#     IF CHARACTER STRING PROVIDED AS RADIUS

#    may want to change this radius behavior ? ***

test_that('confusingly, warning (but not error) if radius = character string that can be coerced to a single number - does not actually coerce it but uses max seen!', {
  expect_warning({
    x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = "1")
  })
  expect_true(is.list(x))
})

test_that("radius param to doagg that is string/text like '0.25' is not interpreted as the number 0.25 but use radius inferred from output of getblocks", {
  suppressWarnings(
    expect_equal(
      doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = "0.25")$results_bysite$radius.miles[1],
      1) # inferred based on sites2blocks
  )})

## Run several test cases for inputs error checking, using list of test cases from setup.R
##
## to look at the test objects created earlier in setup.R,
# nix <- sapply(1:length(bad_numbers), function(z) {cat( "\n\n\n------------------------\n\n  ", names(bad_numbers)[z], "\n\n\n" ); print( bad_numbers[z][[1]] )}); rm(nix)

test_that(paste0("doaggregate radius with the input below should not warn or err!"), {
  cause_no_warn_no_err <- list(normalnumber = 1.3)
  cat('\n  Trying radius that is', names(cause_no_warn_no_err)[1], '- Testing to ensure it works... ')
  try({
    expect_no_condition({
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_no_warn_no_err[[1]])
    })
  })
  expect_true(
    NROW(x$results_bysite) == 10
  )
})

test_that(paste0("doaggregate radius like with the input below should warn!"), {

  cause_warn <- bad_numbers[c('TRUE1', 'text1', 'list1', "NA1", "NULL1")]

  cat('\n  Trying radius that is', names(cause_warn)[1], '- Testing to ensure it warns... ')
  try({
    expect_warning(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_warn[[1]]),
      info = paste0("doaggregate radius like ", names(cause_warn)[1], " should warn!")
    )
    expect_true(is.list(x))
  })

  cat('\n  Trying radius that is', names(cause_warn)[2], '- Testing to ensure it warns... ')
  try({
    expect_warning(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_warn[[2]]),
      info = paste0("doaggregate radius like ", names(cause_warn)[2], " should warn!")
    )
  })

  cat('\n  Trying radius that is', names(cause_warn)[3], '- Testing to ensure it warns... ')
  try({
    expect_warning(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_warn[[3]]),
      info = paste0("doaggregate radius like ", names(cause_warn)[3], " should warn!")
    )
    expect_true(is.list(x))
  })

  cat('\n  Trying radius that is', names(cause_warn)[4], '- Testing to ensure it warns... ')
  try({
    expect_warning(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_warn[[4]]),
      info = paste0("doaggregate radius like ", names(cause_warn)[4], " should warn!")
    )
  })

  cat('\n  Trying radius that is', names(cause_warn)[5], '- Testing to ensure it warns... ')
  try({
    expect_warning(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_warn[[5]]),
      info = paste0("doaggregate radius like ", names(cause_warn)[5], " should warn!")
    )
  })
})

test_that(paste0("doaggregate radius like with the input below should report error!"), {
  cause_err <- bad_numbers[c("vector2", "array2","matrix_1row_4col", "matrix_4row_1col", "matrix_2x2" )]

  cat('\n  Trying radius that is', names(cause_err)[1], '- Testing to ensure it reports error... ')
  try({
    expect_error(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_err[[1]]),
      info = paste0("doaggregate radius like ", names(cause_err)[1], " should report error!")
    )
  })

  cat('\n  Trying radius that is', names(cause_err)[2], '- Testing to ensure it reports error... ')
  try({
    expect_error(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_err[[2]]),
      info = paste0("doaggregate radius like ", names(cause_err)[2], " should report error!")
    )
  })

  cat('\n  Trying radius that is', names(cause_err)[3], '- Testing to ensure it reports error... ')
  try({
    expect_error(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_err[[3]]),
      info = paste0("doaggregate radius like ", names(cause_err)[3], " should report error!")
    )
  })

  cat('\n  Trying radius that is', names(cause_err)[4], '- Testing to ensure it reports error... ')
  try({
    expect_error(
      x <- doaggregate(sites2blocks =  testoutput_getblocksnearby_10pts_1miles, radius = cause_err[[4]]),
      info = paste0("doaggregate radius like ", names(cause_err)[4], " should report error!")
    )
  })

  cat('\n  Trying radius that is', names(cause_err)[5], '- Testing to ensure it reports error... ')
  try({
    expect_error(
      x <- doaggregate(sites2blocks =  testoutput_getlocksnearby_10pts_1miles, radius = cause_err[[5]]),
      info = paste0("doaggregate radius like ", names(cause_err)[5], " should report error!")
    )
  })
  expect_true(TRUE) # just to avoid report of empty test
})

## print(setdiff(names(bad_numbers), names(c(cause_no_warn_no_err, cause_warn, cause_err))))
## c("matrix_1x1", "array1", "character1", "df1")
#
# cause_something_else <- bad_numbers[c("matrix_1x1", "array1", "character1", "df1")]  # ????

rm(cause_no_warn_no_err)
################# #  ################# #  ################# #



################# #
# *** IF OTHER INPUTS ARE BAD ?? ####
################# #

# cat('still need to test cases where inputs other than table or radius are invalid\n')




################# #
# ***  IF OTHER BAD FORMATS FOR TABLE?  ####
#SEE bad_numbers examples from setup.R, as used in radius tests below.

# cat('still need to test cases where input table is some other invalid format\n')




################# #
# ***  IF TABLE INPUT EXCEEDS SOME SIZE LIMIT? ####
# TOO MANY ROWS; TOO MANY COLUMNS; TOO MANY MEGABYTES?

# cat('still need to test cases where input table is valid class, type, but too many rows or columns\n')





