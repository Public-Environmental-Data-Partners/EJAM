
#################### #  fixcolnames ####

cat('\n testing fixcolnames() \n')


test_that(desc = 'fixcolnames handles dupes in input', {
  test.original <- c(
    "RAW_D_INCOME","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.r <- c(
    "pctlowinc", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)

  vars <- fixcolnames(test.original, oldtype = 'api', newtype = 'r')
  expect_equal(vars, test.r)
})
############### #

test_that(desc = 'fixcolnames() output is char vector of right length, for a simple test set of 2 names', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  all.long     <- map_headernames$longname[!is.na(map_headernames$longname) & nchar(map_headernames$longname) > 0]
  all.rname    <- map_headernames$rname[!is.na(map_headernames$rname) & nchar(map_headernames$rname) > 0]

  oldvars <- c('totalPop', 'y')
  vars <- fixcolnames(oldvars, oldtype = 'api', newtype = 'r')
  expect_vector(vars)
  expect_type(vars, "character")
  expect_identical(length(vars), length(oldvars))
})
############### #

test_that(desc = 'fixcolnames renames totalPop to pop for correct element', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  all.long     <- map_headernames$longname[!is.na(map_headernames$longname) & nchar(map_headernames$longname) > 0]
  all.rname    <- map_headernames$rname[!is.na(map_headernames$rname) & nchar(map_headernames$rname) > 0]

  oldvars <- c('totalPop', 'y')
  vars <- fixcolnames(oldvars, oldtype = 'api', newtype = 'r')
  expect_equal(grepl("totalPop", oldvars), grepl("pop", vars))
})
############### #

test_that('fixcolnames() returns 1 for 1, NA for NA even if all are NA', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  all.long     <- map_headernames$longname[!is.na(map_headernames$longname) & nchar(map_headernames$longname) > 0]
  all.rname    <- map_headernames$rname[!is.na(map_headernames$rname) & nchar(map_headernames$rname) > 0]

  # renaming works: 1 or more API indicator names including totalPop get renamed as character vector, same length, NA as NA
  expect_identical(fixcolnames('just_one_item') , 'just_one_item')
  expect_identical(fixcolnames(c("validword", NA_character_)) , c("validword", NA))
  expect_identical(is.na(fixcolnames(NA)), TRUE)
})
############### #

########### more tests for fixcolnames

testthat::test_that('fixcolnames() no error for all original names', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  ok = which(!duplicated(all.original))
  maphead = map_headernames[ok, ]
  all.long     <- maphead$longname[!is.na(maphead$longname) & nchar(maphead$longname) > 0]
  all.rname    <- maphead$rname[!is.na(maphead$rname) & nchar(maphead$rname) > 0]

  expect_no_error(fixcolnames(all.original, oldtype = 'api', newtype = 'api'))
  expect_no_error({all.r <- fixcolnames(all.original, oldtype = 'api', newtype = 'r')})
  expect_no_error(fixcolnames(all.original, oldtype = 'api', newtype = 'rname'))
  expect_no_error(fixcolnames(all.original, oldtype = 'api', newtype = 'long'))
  expect_no_error(fixcolnames(all.original, oldtype = 'api', newtype = 'original'))
  expect_no_error(fixcolnames(all.original, newtype = 'original'))
  expect_no_error(fixcolnames(all.original))
  expect_no_error(fixcolnames(all.original, oldtype = 'rname'))

  expect_equal(names_these, fixcolnames(fixcolnames(names_these, 'r', 'long'), 'long', 'r'))
})
############### #

testthat::test_that('fixcolnames() no error for all long names', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  ok = which(!duplicated(all.original))
  maphead = map_headernames[ok, ]
  all.long     <- maphead$longname[!is.na(maphead$longname) & nchar(maphead$longname) > 0]
  all.rname    <- maphead$rname[!is.na(maphead$rname) & nchar(maphead$rname) > 0]

  expect_no_error(fixcolnames(all.long, oldtype = 'api', newtype = 'api'))
  expect_no_error({all.r <- fixcolnames(all.long, oldtype = 'api', newtype = 'r')})
  expect_no_error(fixcolnames(all.long, oldtype = 'api', newtype = 'rname'))
  expect_no_error(fixcolnames(all.long, oldtype = 'api', newtype = 'long'))
  expect_no_error(fixcolnames(all.long, oldtype = 'api', newtype = 'original'))
  expect_no_error(fixcolnames(all.long, newtype = 'original'))
  expect_no_error(fixcolnames(all.long))
  expect_no_error(fixcolnames(all.long, oldtype = 'rname'))

  expect_equal(
    test.original,
    fixcolnames(fixcolnames(test.original, 'api', 'long'), 'long', 'api')
  )
})
############### #

testthat::test_that('fixcolnames() no error for all r names', {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  ok = which(!duplicated(all.original))
  maphead = map_headernames[ok, ]
  all.long     <- maphead$longname[!is.na(maphead$longname) & nchar(maphead$longname) > 0]
  all.rname    <- maphead$rname[!is.na(maphead$rname) & nchar(maphead$rname) > 0]

  expect_no_error(fixcolnames(all.rname, oldtype = 'api', newtype = 'api'))
  expect_no_error({all.r <- fixcolnames(all.rname, oldtype = 'api', newtype = 'r')})
  expect_no_error(fixcolnames(all.rname, oldtype = 'api', newtype = 'rname'))
  expect_no_error(fixcolnames(all.rname, oldtype = 'api', newtype = 'long'))
  expect_no_error(fixcolnames(all.rname, oldtype = 'api', newtype = 'original'))
  expect_no_error(fixcolnames(all.rname, newtype = 'original'))
  expect_no_error(fixcolnames(all.rname))
  expect_no_error(fixcolnames(all.rname, oldtype = 'rname'))

  expect_equal(
    test.rname,
    fixcolnames(fixcolnames(test.rname, 'r', 'long'), 'long', 'r')
  )
})
############### #

########### more tests for fixcolnames

testthat::test_that("valid oldtype specified but inputs are not that type, so return all unchanged including NAs", {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  all.long     <- map_headernames$longname[!is.na(map_headernames$longname) & nchar(map_headernames$longname) > 0]
  all.rname    <- map_headernames$rname[!is.na(map_headernames$rname) & nchar(map_headernames$rname) > 0]

  testthat::expect_true({
    # # wrong from, so just returns unchanged including NA as NA:
    all(fixcolnames(test.rname,
                    oldtype = 'long', newtype = 'original')     == test.rname, na.rm = T)
  })
})
############### #

testthat::test_that("nonexistent oldtype specified so warn and return all unchanged", {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  all.long     <- map_headernames$longname[!is.na(map_headernames$longname) & nchar(map_headernames$longname) > 0]
  all.rname    <- map_headernames$rname[!is.na(map_headernames$rname) & nchar(map_headernames$rname) > 0]

  testthat::expect_true({
    suppressWarnings( {
      all(fixcolnames(test.rname, oldtype = 'TYPEDOESNOTEXIST', newtype = 'original') == test.rname, na.rm = T)}) # NOW JUST WARNS
  })
  testthat::expect_warning({
    all(fixcolnames(test.rname,
                    oldtype = 'TYPEDOESNOTEXIST', newtype = 'original')    == test.rname, na.rm = T) # NOW JUST WARNS
  })
})
############### #

testthat::test_that("nonexistent newtype specified so warn and return all unchanged", {
  test.original <- c(
    "S_E_TRAFFIC_PER","RAW_D_INCOME","N_P5_PM25",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score", "pctlowinc", "pctile.EJ.DISPARITY.pm.supp",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "% Low Income",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "unfound", NA)
  # cbind(test.original, test.rname, test.long)
  all.original <- map_headernames$apiname[!is.na(map_headernames$apiname) & nchar(map_headernames$apiname) > 0]
  ok = which(!duplicated(all.original))
  maphead = map_headernames[ok, ]
  all.long     <- maphead$longname[!is.na(maphead$longname) & nchar(maphead$longname) > 0]
  all.rname    <- maphead$rname[!is.na(maphead$rname) & nchar(maphead$rname) > 0]

  testthat::expect_true({
    suppressWarnings( {  all(fixcolnames(test.rname,
                                         oldtype = 'r', newtype = 'TYPEDOESNOTEXIST')    == test.rname, na.rm = T)}) # NOW JUST WARNS
  })
  testthat::expect_warning({
    all(fixcolnames(test.rname,
                    oldtype = 'r', newtype = 'TYPEDOESNOTEXIST')    == test.rname, na.rm = T) # NOW JUST WARNS
  })
})
###################### #

test_that("fixcolnames ejscreen to r with dupe", {
test.original <- c(
  "S_E_TRAFFIC_PER","N_P5_PM25",
  "RAW_D_INCOME", "RAW_D_INCOME",
  "unfound", NA)
test.rname <- c(
  "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
  "pctlowinc","pctlowinc",
  "unfound", NA)
test.long <- c(
  "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
  "US percentile for Supplemental Summary Index for Particulate Matter",
  "% Low Income","% Low Income",
  "unfound", NA)

expect_equal(
fixcolnames(test.original,
            oldtype='original', newtype='r'),
test.rname
)
})
############ #

test_that("fixcolnames ejscreen to long with dupe", {
  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.original,
                oldtype='original', newtype='long'),
    test.long
  )
})
############ #

test_that("from=to, so just returns unchanged:", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.original,
                oldtype='original', newtype='original') ,
    test.original
  )
})
############ #

test_that("wrong from, so just returns unchanged", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)


    expect_equal(
  fixcolnames(test.original,
              oldtype='long',     newtype='original') ,
  test.original #
  )

  expect_warning(
    fixcolnames(test.original,
                oldtype='wrong',  newtype='original')  # warns
  )

})
############ #

test_that("from==to, so just returns long unchanged", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.long,
                oldtype = 'long', newtype = 'long'),
    test.long
  )
})
############ #

test_that("from==to, so just returns r unchanged", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.rname,
                oldtype='r', newtype='r'),
    test.rname #
  )
})
############ #

test_that("r to long name type", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.rname,
                oldtype='r', newtype='long'),
    test.long #
  )
})
############ #

test_that("r to ejscreen name type", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.rname,
                oldtype='r', newtype='original'),
    test.original #
   )
})
############ #

test_that("long to r name type", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.long,
                oldtype = 'long', newtype = 'r') ,
    test.rname
  )
})
############ #

test_that("long to original name type", {

  test.original <- c(
    "S_E_TRAFFIC_PER","N_P5_PM25",
    "RAW_D_INCOME", "RAW_D_INCOME",
    "unfound", NA)
  test.rname <- c(
    "state.pctile.traffic.score",  "pctile.EJ.DISPARITY.pm.supp",
    "pctlowinc","pctlowinc",
    "unfound", NA)
  test.long <- c(
    "State percentile for Traffic Proximity and Volume (daily traffic count/distance to road)",
    "US percentile for Supplemental Summary Index for Particulate Matter",
    "% Low Income","% Low Income",
    "unfound", NA)

  expect_equal(
    fixcolnames(test.long,
                oldtype = 'long', newtype = 'original') ,
    test.original

  )
})
############################## #

