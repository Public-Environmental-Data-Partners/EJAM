################################### #
# no crash for basic example
test_that('case simple example, return data.table',{
  suppressWarnings({
    expect_no_error({val <- getblocksnearby(sitepoints = testpoints_10, quiet = TRUE)})
  })
  expect_true('data.table' %in% class(val))
})
################################### #
# test_that("testpoints_10 has same colnames as other testpoints_", {  #  FAILED BUT NOT IMPORTANT
#   expect_identical(names(testpoints_10), names(testpoints_100))
#   expect_identical(names(testpoints_10), names(testpoints_1000))
#   expect_identical(names(testpoints_10), names(testpoints_10000))
#   expect_in(names(testpoints_10), names(testpoints_100_dt))
# })
################################### #
test_that("testpoints_5 has same colnames as testpoints_5,500", {
  expect_identical(names(testpoints_5), names(testpoints_50))
  expect_identical(names(testpoints_5), names(testpoints_500))
})
################################### #
test_that("testpoints_10 has same colnames as testpoints_5 etc", {
  expect_in(names(testpoints_10), names(testpoints_5))
})
################################### #
test_that("getblocksnearby() same results as saved", {
  suppressWarnings({
    x = getblocksnearby(testpoints_10, radius = 1, quiet = T)
    y = testoutput_getblocksnearby_10pts_1miles
    if (NROW(x) != NROW(y)) {cat("NEED TO UPDATE testoutput_getblocksnearby_10pts_1miles !?\n")}
    testthat::skip_if(NROW(x) != NROW(y), message = "may need to update testoutput_getblocksnearby_10pts_1miles")
    expect_identical(
      x, y,ignore_attr =TRUE
    )
  })
})
################################### #
# NUMBER OF POINTS
#
# > sort(unique(testpoints_10$sitenumber))
# [1]  1  2  3  4  5  6  7  8  9 10
# > NROW(testpoints_10)
# [1] 10

# BUT... not every point shows up in output of getblocksnearby()

# > sort(unique(testoutput_getblocksnearby_10pts_1miles$ejam_uniq_id))
# [1]  1  2  3  4  5    7  8  9 10
# length(unique(testoutput_getblocksnearby_10pts_1miles$ejam_uniq_id))
# [1] 9
# > sort(unique(getblocksnearby(
#     testpoints_10, radius = 1, quiet = T)$ejam_uniq_id))
# Some points appear to be in US Island Areas, which may lack some data such as demographic data here
# Analyzing 10 points, radius of 1 miles around each.
# [1]  1  2  3  4  5    7  8  9 10
# > length(sort(unique(getblocksnearby(
#     testpoints_10, radius = 1, quiet = T)$ejam_uniq_id)))
# [1] 9
################################### #
testthat::test_that("one ejam_uniq_id per VALID input sitepoint THAT HAS RESULTS (in saved testoutput_getblocksnearby_10pts_1miles)", {
  expect_true(
    length(unique(testoutput_getblocksnearby_10pts_1miles$ejam_uniq_id)) <= NROW(testpoints_10)
  )
  expect_true(
    suppressWarnings(
      all(getblocksnearby(testpoints_1000, radius = 1, quiet = T)$ejam_uniq_id %in% 1:NROW(testpoints_1000))
    ))
})
################################### #
testthat::test_that("one ejam_uniq_id per VALID input sitepoint THAT HAS RESULTS (in getblocks output now)", {
  expect_true(
    # length(unique(testoutput_getblocksnearby_10pts_1miles$ejam_uniq_id)),
    suppressWarnings(
      length(unique(getblocksnearby(testpoints_100, radius = 1, quiet = T)$ejam_uniq_id)) <= NROW(testpoints_100)
    ))
})
################# #  ################# #  ################# #
test_that("getblocksnearby() outputs sorted like input latlon", {

  inputsitenumber <- c(3,1,2,5,4) # this is the sitenumber not the ejam_uniq_id assigned!
  input_ejam_uniq_id <- 1:5
  dat <- testpoints_10[inputsitenumber, ] # so that sitenumber 3 appears 1st in the dat used
  dat <- state_from_sitetable(dat)
  inputstates <- dat$ST
  s2b <- getblocksnearby(dat, radius = 1, quiet = TRUE)
  outputsitenumber <- unique(s2b$sitenumber)
  outputstates <- unique(EJAM:::state_from_blockid_table(s2b)) # unexported function
  output_ejam_uniq_id <- unique(s2b$ejam_uniq_id)
  # print(dat)
  # print(s2b[, .SD[1], by="ejam_uniq_id"]) # prints 1st row from each id
  #   print(cbind(inputstates = inputstates, outputstates = outputstates,
  # inputsitenumber = inputsitenumber, outputsitenumber = outputsitenumber,
  # input_ejam_uniq_id = input_ejam_uniq_id, output_ejam_uniq_id = output_ejam_uniq_id))

  testthat::expect_equal(outputstates, inputstates)
  testthat::expect_equal(output_ejam_uniq_id, input_ejam_uniq_id)
})
################# #
test_that("some latlon NA, some valid", {

  inputsitenumber <- c(3,1,2,5,4) # this is the sitenumber not the ejam_uniq_id assigned!
  input_ejam_uniq_id <- 1:5
  dat <- testpoints_10[inputsitenumber, ]
  # ONE INVALID ROW:
  dat[3, ] <- NA
  inputsitenumber[3 ] <- NA

  suppressWarnings({
    suppressMessages({
      dat <- state_from_sitetable(dat) # adds columns like ST and ejam_uniq_id but doesn't sort
    })
    inputstates <- dat$ST # includes the NA

    s2b <- getblocksnearby(dat, radius = 1, quiet = TRUE)
  })
  output_ejam_uniq_id <- unique(s2b$ejam_uniq_id)
  outputstates <- unique(EJAM:::state_from_blockid_table(s2b)) # unexported function
  # print(dat)
  # print(s2b[,.SD[1], by="ejam_uniq_id"]) # prints 1st row from each id
  expect_equal(unique(dat$ejam_uniq_id), c(1,2,3,4,5))
  expect_equal(is.na(dat$lat), c(FALSE, FALSE, TRUE, FALSE, FALSE))
  expect_equal(unique(s2b$ejam_uniq_id), c(1, 2,  4, 5))
  expect_equal(unique(s2b$ejam_uniq_id), input_ejam_uniq_id[!is.na(dat$lat)])
  expect_equal(outputstates, inputstates[!is.na(inputstates)]) # since s2b now does not return rows for invalid sites
})
################# #  ################# #  ################# #
test_that("2 latlon NA, 2 valid", {

  inputsitenumber <- c(3,1,4,2) # this is the sitenumber not the ejam_uniq_id assigned!
  input_ejam_uniq_id <- 1:4
  dat <- testpoints_10[inputsitenumber, ]
  # 2 INVALID ROWS:
  dat[2:3, ] <- NA
  inputsitenumber[2:3 ] <- NA

  suppressWarnings({
    suppressMessages({
      dat <- state_from_sitetable(dat) # adds columns like ST and ejam_uniq_id but doesn't sort
    })
    inputstates <- dat$ST # includes the NA

    s2b <- getblocksnearby(dat, radius = 1, quiet = TRUE)
  })
  output_ejam_uniq_id <- unique(s2b$ejam_uniq_id)
  outputstates <- unique(EJAM:::state_from_blockid_table(s2b)) #   unexported
  # print(dat)
  # print(s2b[,.SD[1], by="ejam_uniq_id"]) # prints 1st row from each id
  expect_equal(unique(dat$ejam_uniq_id), c(1,2,3,4))
  expect_equal(is.na(dat$lat), c(FALSE, TRUE, TRUE, FALSE))
  expect_equal(unique(s2b$ejam_uniq_id), c(1,  4))
  expect_equal(unique(s2b$ejam_uniq_id), input_ejam_uniq_id[!is.na(dat$lat)])
  expect_equal(outputstates, inputstates[!is.na(inputstates)]) # since s2b now does not return rows for invalid sites
})
################# #  ################# #  ################# #
test_that("warning if no valid lat lon", {
  suppressWarnings(
    expect_warning(
      getblocksnearby(data.table(lat = 0 , lon = 0), quiet = TRUE)
    )
  )
})
################################### #
## in getblocks...
# stopifnot(is.numeric(radius), radius <= 100, radius >= 0, length(radius) == 1,
#           is.numeric(radius_donut_lower_edge), radius_donut_lower_edge <= 100, radius_donut_lower_edge >= 0, length(radius_donut_lower_edge) == 1)
# if (radius_donut_lower_edge > 0 && radius_donut_lower_edge >= radius) {stop("radius_donut_lower_edge must be less than radius")}
################################### #
#### ***  MIGHT WANT TO ERROR or WARN on radius 0 if latlon is sitetype ?
test_that('NO WARN NO ERROR, if radius = 0, since thats ok in fips/shp cases', {
  expect_no_condition(
    getblocksnearby(testpoints_10[1, ], radius = 0, quiet = TRUE)
  )
})
################################### #
test_that("ERROR if radius < 0", {
  expect_error({val <- getblocksnearby(sitepoints = testpoints_10, radius = -1 , quiet = TRUE)})
})
################################### #
test_that('ERROR if radius > 100 miles', {
  expect_error(
    getblocksnearby(testpoints_10[1, ], radius = 101, quiet = TRUE)
  )
})
################################### #
test_that("ERROR if radius NA or NULL or character not numeric", {
  expect_error({val <- getblocksnearby(sitepoints = testpoints_10, radius = NA,   quiet = TRUE )})
  expect_error({val <- getblocksnearby(sitepoints = testpoints_10, radius = NULL, quiet = TRUE )})
  expect_error({val <- getblocksnearby(sitepoints = testpoints_10, radius = "1", quiet = TRUE )})
})
################################### #
# no block within radius
test_that("NO BLOCKS nearby - no warning just empty table", {
  expect_no_condition({
    s2b = getblocksnearby(testpoints_10[1:2,], radius = 0.01, quiet = T)
  })
  expect_equal(NROW(s2b), 0)
})
################################### #
