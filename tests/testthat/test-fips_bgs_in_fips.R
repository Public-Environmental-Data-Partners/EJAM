############################################################################# #
### fips_bgs_in_fips() ####

############################################################################# #
# convert any FIPS codes to the FIPS of all the blockgroups that are
#   among or within or containing those FIPS
# @   details  This is a way to get a list of blockgroups, specified by state/county/tract or even block.
#
# Takes a vector of one or more FIPS that could be State (2-digit), County (5-digit),
#   Tract (11-digit), or blockgroup (12 digit), or even block (15-digit fips).
#
#   Returns unique vector of FIPS of all US blockgroups (including DC and Puerto Rico)
#   that contain any specified blocks, are equal to any specified blockgroup fips,
#   or are contained within any provided tract/county/state FIPS.
#
# @   param fips vector of US FIPS codes, as character or numeric,
#   with or without their leading zeroes, each with as many characters
# @   seealso [fips_lead_zero()]
# @   return vector of blockgroup FIPS (or NA values) that may be much longer than the
#   vector of fips passed to this function.
# @   examples
#   # all blockgroups in one state
#   blockgroupstats[,.N,by=substr(bgfips,1,2)]
#   length(fips_bgs_in_fips("72"))
#   # all blockgroups in this one county
#   fips_bgs_in_fips(30001)
#   # all blockgroups that contain any of these 6 blocks (just one bg)
#   fips_bgs_in_fips( blockid2fips$blockfips[1:6])
#   # 2 counties
#   fips_bgs_in_fips(c(36009,36011))
############################################################################# #

# Also see fips_bgs_in_fips1() and maybe add tests for that variant?
############################################################################# #

testthat::test_that("fips_bgs_in_fips gets all bgs in each fipstype", {

  testfipslist <- list(
    blockgroup = testinput_fips_blockgroups,
    tract = testinput_fips_tracts,
    #   city = testinput_fips_cities, # for cities, must use getblocksnearby_from_fips()
    county = testinput_fips_counties,
    state = testinput_fips_states,

    mix = c(testinput_fips_blockgroups[1],
            testinput_fips_tracts[3],
            #  testinput_fips_cities[1],
            "53023",
            56) # name2fips('WY')
  )
  testfipslist = lapply(testfipslist, function(z) {attributes(z) <- NULL; z}) # drop distracting metadata
  ## e.g., dput(testfipslist['mix']$mix)
  ## c("050014801001", "05001480300", "53023", "56")

  expect_no_error({
    # 1 vector of bgfips output for each vector of FIPS inputs of any 1   type
    x = lapply(testfipslist, fips_bgs_in_fips)
  })

  # within bgs,
  # bgs were found, and 1st part of those bgfips  = fips input
  expect_true(all(fipstype(x$tract) == "blockgroup"))
  expect_equal(
    x$blockgroup,
    testfipslist$blockgroup
  )

  for (ftype in c('tract', 'county', 'state')) {
    suppressMessages({
      flen = EJAM:::fipstype2nchar(ftype)
    })
    inwhat = as.vector(unlist(testfipslist[ftype]))
    bgfound = as.vector(unlist(x[ftype]))
    bgexpected = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, flen) %in% unique(inwhat)]
    # bgs were found, and 1st part of those bgfips  = fips input
    expect_true(all(fipstype(bgfound) == "blockgroup"))
    # did it find ALL and ONLY the bgs expected?
    expect_setequal(bgfound,
                    bgexpected)
    # were the found ones actually within the input units? (as a doublecheck)
    expect_setequal(
      unique(substr(bgfound, 1, flen)), # queried units portion of the bgs found
      unique(inwhat)      # units that were looked in
    )
  }

})
############################################################################# #
## fips_bgs_in_fips1() ####

test_that('fips_bgs_in_fips1 same result as fips_bgs_in_fips', {

  testfipslist <- list(
    blockgroup = testinput_fips_blockgroups,
    tract = testinput_fips_tracts,
    #   city = testinput_fips_cities, # for cities, must use getblocksnearby_from_fips()
    county = testinput_fips_counties,
    state = testinput_fips_states,

    mix = c(testinput_fips_blockgroups[1],
            testinput_fips_tracts[3],
            #  testinput_fips_cities[1],
            "53023",
            56) # name2fips('WY')
  )
  testfipslist = lapply(testfipslist, function(z) {attributes(z) <- NULL; z}) # drop distracting metadata

  ## to keep distinct the vector of bgs in each input fips:
  ##  sapply(testinput_fips_counties[1:2], fips_bgs_in_fips)

  expect_no_error({
    x  = sapply(testfipslist, function(v) sapply(v, fips_bgs_in_fips ))
    x1 = sapply(testfipslist, function(v) sapply(v, fips_bgs_in_fips1))
  })
  expect_equal(x, x1)
})
############################################################################# #

# testfipslist_withcity <- list(
#   blockgroup = testinput_fips_blockgroups,
#   tract = testinput_fips_tracts,
#     city = testinput_fips_cities, # for cities, must use getblocksnearby_from_fips()
#   county = testinput_fips_counties,
#   state = testinput_fips_states,
#
#   mix = c(testinput_fips_blockgroups[1],
#           testinput_fips_tracts[3],
#            testinput_fips_cities[1],
#           "53023",
#           56) # name2fips('WY')
# )
# testfipslist_withcity = lapply(testfipslist_withcity, function(z) {attributes(z) <- NULL; z}) # drop distracting metadata
############################################################################# #

#     now CAN  use fips_bgs_in_fips() with city fips even though CDP IS NOT BROKEN INTO BGS EXACTLY

test_that('fips_bgs_in_fips - by CITY', {

# just test approx not exact method for city fips
  expect_no_error({val <- fips_bgs_in_fips(3651000)})
  expect_no_error({val <- fips_bgs_in_fips("3651000")})

  #expect_equal(length(val), 1)
  # check it's the same as the subset of state codes
  # x <- fips_bgs_in_fips("36")
  # y <- x[which(startsWith(x, "3651000"))]
  # expect_equal(y, val)
})
################## #
# returns only UNIQUE bg fips once each,
# even if 2 inputs contain or are inside same bg (turn into same bgid)
#  - do we want that to be the behavior? yes since we already do not expect a 1-to-1 in-out mapping.

test_that("fips_bgs_in_fips get only UNIQUE BGS in/w the fips", {
  expect_true({
    length(fips_bgs_in_fips(c("36071010801"))) == 3 # contains 3 unique blockgroups
  })
  expect_true({
    length(fips_bgs_in_fips(rep("36071010801", 5))) == 3 # will not return more matches than just unique
  })
  expect_true({
    length(fips_bgs_in_fips(rep("360710108011", 5))) == 1 # will not return more matches than just unique
  })
  expect_true({
    length(fips_bgs_in_fips(c(360710108011012, 360710108011006, 360710108011023))) == 1 # one unique bg returned even if it contains multiple blocks provided as query terms
  })
})
################## #
test_that('fips_bgs_in_fips by BLOCK get uniques only', {   ### NOTE ONE MIGHT NOT EXPECT OR NEED UNIQUE ONLY ?
  expect_true( {
    length(fips_bgs_in_fips(rep("360710108011", 5))) == 1
  })
  expect_no_warning({val <- fips_bgs_in_fips(c(360710108011012, 360710108011006, 360710108011023))})
  expect_no_warning({val <- fips_bgs_in_fips(c("360710108011012", "360710108011006", "360710108011023"))})
  expect_equal(length(val), 1)
})
################## #
test_that('fips_bgs_in_fips - leading zero addition', {

  expect_no_warning({val <- fips_bgs_in_fips("1055")}) # county
  expect_no_warning({val <- fips_bgs_in_fips(1055)})
  expect_equal(length(val), 90)
  expect_equal(substr(val[1], 1,2) , "01")

  expect_no_warning({val <- fips_bgs_in_fips("1")}) # state
  expect_no_warning({val <- fips_bgs_in_fips(1)})
  expect_equal(length(val), 3925)
  expect_equal(substr(val[1], 1,2) , "01")

  expect_no_warning({val <- fips_bgs_in_fips("1055011002")}) # tract
  expect_no_warning({val <- fips_bgs_in_fips(1055011002)})
  expect_equal(length(val), 3)
  expect_equal(substr(val[1], 1,2) , "01")

  expect_no_warning({val <- fips_bgs_in_fips(10690401001010)}) # not a bg
  expect_no_warning({val <- fips_bgs_in_fips("10690401001010")})
  expect_equal(length(val), 1) #
  expect_equal(substr(val[1], 1,2) , "01")
})
################## #
test_that('fips_bgs_in_fips - returns BGS in tract(s)', {
  tractfips1 <- "10005051900"
  expect_true(fipstype(tractfips1) == "tract") # tract as input,
  expect_true(all(fips_bgs_in_fips(tractfips1) %in% blockgroupstats$bgfips)) # returns actual bg fips
  expect_no_condition({val <- fips_bgs_in_fips(tractfips1)}) # tract that contains 3 bgs
  expect_equal(length(val), 3)
  expect_true(all(substr(val, 1, 11) == tractfips1))
  rm(tractfips1)
})
################## #
# > fipstype("blue")
# [1] "county"
# > fipstype("sdfsdfsdfasdf0")
# [1] "block"
### THESE RETURNED NULL, not NA:
# fips_bgs_in_fips("blue")
# fips_bgs_in_fips("36-071")
# fips_bgs_in_fips("36-07")
# fips_bgs_in_fips("$1001")
################## #
#  NO ERROR for invalid strings, no string cleaning (dashes/dots not removed)
test_that('fips_bgs_in_fips - NO ERROR if invalid text', {
  suppressWarnings({
    expect_no_error({val <- fips_bgs_in_fips("blue")})
    expect_no_error({val <- fips_bgs_in_fips("36-071")})
    expect_no_error({val <- fips_bgs_in_fips("36-07")})
    expect_no_error({val <- fips_bgs_in_fips("$1001")})
  })
  expect_equal(length(val), 0)
})
################## #
#  warnings for invalid strings, no string cleaning (dashes/dots not removed)
test_that('fips_bgs_in_fips - WARN if invalid text', {
  suppressWarnings({
    expect_warning({val <- fips_bgs_in_fips("blue")})
    expect_warning({val <- fips_bgs_in_fips("36-071")})
    expect_warning({val <- fips_bgs_in_fips("36-07")})
    expect_warning({val <- fips_bgs_in_fips("$1001")})
  })
})
################## #
