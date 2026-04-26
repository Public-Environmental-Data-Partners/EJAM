
#  FUNCTIONS

# latlon_from_address_table()
# latlon_from_address()

############################################################################## #

offline_warning()

############################################################################## #
# latlon_from_address_table ####
############################################################################## #

testthat::test_that("latlon_from_address_table works on testinput_address_table", {

  testthat::skip_if_offline()
  skip_if_not_installed("AOI")
  testthat::expect_no_error({
    x <- latlon_from_address_table(testinput_address_table)
  })

  original = structure(list(
    request = c("1200 Pennsylvania Ave Washington DC ",
                "5 pARK AVE NY NY "),
    score = c(99.48, 100),
    arcgis_address = c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
                       "5 Park Ave, New York, New York, 10016"),
    lon = c(-77.028948300066, -73.980999465092),
    lat = c(38.8948262664, 40.747143677784)
  ), row.names = c(NA, -2L), class = "data.frame")

  x$request = tolower(x$request)
  x$arcgis_address = tolower(x$arcgis_address)
  original$request = tolower(original$request)
  original$arcgis_address = tolower(original$arcgis_address)

  testthat::expect_equal(x,
                         original, tolerance = 0.01)

  testthat::expect_no_error({
    x <- latlon_from_address_table(testinput_address_table_withfull)
  })
})
###################### #

testthat::test_that("latlon_from_address_table if address col conflicts with street/city/state cols", {

  ### geocoder has hard-to-predict behavior if ambiguous address provided:
  #
  # latlon_from_address_table(data.frame(address="Research Triangle Park", street="5 Park Ave", city="New York", state="NY")) # returns address in NY    (New York supersedes RTP)
  # latlon_from_address_table(data.frame(address="Research Triangle Park", street="5 Park Ave", city="NY",       state="NY")) # returns address in NC !! (NY does not supersede RTP)
  # latlon_from_address_table(data.frame(address="xxxxxxxx xxxxxxxx xxxx", street="5 Park Ave", city="NY",       state="NY")) # returns address in NY    (NY works)

  testthat::skip_if_offline()
  skip_if_not_installed("AOI")
  testthat::expect_message({
    test1 = testinput_address_table_withfull
    test1$city[2] <- "New York"
    x <- latlon_from_address_table(testinput_address_table_withfull)
    y <- latlon_from_address_table(test1)
  })

  original =    structure(list(
    arcgis_address = c(
      "1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
      "5 Park Ave, New York, New York, 10016"),
    lon = c(-77.028948300066, -73.980999465092),
    lat = c(38.8948262664, 40.747143677784)
  ),
  class = "data.frame", row.names = c(NA, -2L))
  original$arcgis_address = tolower(original$arcgis_address)
  x$arcgis_address = tolower(x$arcgis_address)
  y$arcgis_address = tolower(y$arcgis_address)

  ### fails because this example RTP overrides the "NY" city but not the "New York" city info!
  #   testthat::expect_equal(
  #     x[,c("arcgis_address", "lon", "lat")],
  #     original, tolerance = 0.01
  # )

  testthat::expect_equal(
    y[,c("arcgis_address", "lon", "lat")],
    original, tolerance = 0.01
  )
})
###################### #
## *** NOTE IT FAILS or has trouble IF A COLUMN WITH STREET NAME ONLY IS CALLED "address" instead of that storing the full address.
###################### #
# ~-------------------------------------------------------------------- #####
############################################################################## #
# latlon_from_address ####
############################################################################## #

# test_that("latlon_from_address works at all, default params", {
#   testthat::skip_if_not_installed("AOI")
#   a1 <- "1200 Pennsylvania Ave NW, Washington DC"
#   a2 <- "4930 Old Page Road Durham NC 27703"
#   testthat::expect_no_error(latlon_from_address(a1))
#   testthat::expect_no_error(latlon_from_address(c(a1, a2)))
# })
###################### #

testthat::test_that("latlon_from_address works", {

  testthat::skip_if_offline()
  skip_if_not_installed("AOI")
  if (!exists("geocode")) {
    library(AOI)
    cat("MUST LOAD AOI PKG FOR THIS geocode to work \n\n")
  }
  addresses_example_temp = c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
                             "5 Park Ave, New York, New York, 10016")
  testthat::expect_no_error({
    x <- latlon_from_address(addresses_example_temp)
    x$request = tolower(x$request)
    x$arcgis_address = tolower(x$arcgis_address)
  })

  expected_x <-     structure(list(
    request = tolower(
      c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
        "5 Park Ave, New York, New York, 10016")
    ),
    score = c(100L, 100L),
    arcgis_address = tolower(
      c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
        "5 Park Ave, New York, New York, 10016")
    ),
    lon = c(-77.028948300066, -73.980999465092),
    lat = c(38.8948262664, 40.747143677784)
  ), row.names = c(NA, -2L), class = "data.frame")

  testthat::expect_true(
    all.equal(
      x,
      expected_x
    )
    # ,
    # tolerance = 0.01
  )
})
###################### #

testthat::test_that("latlon_from_address err if too many addresses", {

  testthat::skip_if_offline()
  testthat::expect_error(latlon_from_address(rep("a", 1001)))
})
##################### #

test_that("latlon_from_address( xy=TRUE) works", {

  testthat::skip_if_offline()
  testthat::skip_if_not_installed("AOI")

  if (!exists("geocode") || !is.function(geocode)) {
    expect_warning(
      # if pkg installed but not attached, warn and return NULL
      latlon_from_address("1200 Pennsylvania Ave NW, Washington DC")
    )
    expect_null(
      latlon_from_address("1200 Pennsylvania Ave NW, Washington DC")
    )
  }

  ## test should work if installed as long as we load/attach the package, if it is not already in Imports of DESCRIPTION of EJAM pkg.
  require("AOI")

  a1 <- "1200 Pennsylvania Ave NW, Washington DC"
  a2 <- "4930 Old Page Road Durham NC 27703"
  out1old <- structure(list(lon = -77.02895, lat = 38.89483), class = "data.frame", row.names = c(NA, -1L))
  out2old <- structure(list(lon = c(-77.02895, -78.84164), lat = c(38.89483, 35.88678)), class = "data.frame", row.names = c(NA, -2L))
  testthat::expect_no_error({
    out1 <- latlon_from_address(a1, xy = TRUE)
  })
  testthat::expect_no_error({
    out2 <- latlon_from_address(c(a1, a2), xy = TRUE)
  })


  out1 <- round(out1, 3)
  out1old <- round(out1old, 3)

  out2 <- round(out2, 3)
  out2old <- round(out2old, 3)

  testthat::expect_equal(out1, out1old)
  testthat::expect_equal(out2, out2old)
})
############################################################################## #

testthat::test_that("latlon_from_address( xy=FALSE) works", {

  testthat::skip_if_offline()
  testthat::skip_if_not_installed("AOI")
  require("AOI")

  a1 <- "1200 Pennsylvania Ave NW, Washington DC"
  a2 <- "4930 Old Page Road Durham NC 27703"
  out1old <- structure(list(request = "1200 Pennsylvania Ave NW, Washington DC",
                            score = 100L, arcgis_address = "1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
                            lon = -77.02895, lat = 38.89483), row.names = c(NA, -1L), class = "data.frame")
  out2old <- structure(list(request = c("1200 Pennsylvania Ave NW, Washington DC",
                                        "4930 Old Page Road Durham NC 27703"),
                            score = c(100L, 100L),
                            arcgis_address = c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20044",
                                               "4930 Old Page Rd, Durham, North Carolina, 27703"),
                            lon = c(-77.02895, -78.84164),
                            lat = c(38.89483, 35.88678)), row.names = c(NA, -2L), class = "data.frame")
  testthat::expect_no_error({
    out1 <- latlon_from_address(a1, xy = FALSE)
    # rounded off should be identical
    out1$lat = round(out1$lat, 3)
    out1$lon = round(out1$lon, 3)
    # out1old
    out1old$lat = round(out1old$lat, 3)
    out1old$lon = round(out1old$lon, 3)
  })
  testthat::expect_no_error({
    out2 <- latlon_from_address(c(a1, a2), xy = FALSE)
    # rounded off should be identical
    out2$lat = round(out2$lat, 3)
    out2$lon = round(out2$lon, 3)
    # out2old
    out2old$lat = round(out2old$lat, 3)
    out2old$lon = round(out2old$lon, 3)
  })
  testthat::expect_equal(tolower(out1), tolower(out1old))
  testthat::expect_equal(tolower(out2), tolower(out2old))
})
############################################################################## #

testthat::test_that("latlon_from_address( aoimap=T) works", {

  testthat::skip_if_offline()
  testthat::skip_if_not_installed("AOI")
  require("AOI")

  testthat::expect_no_error({
    x <- latlon_from_address("ames iowa", aoimap = T)
  })
  testthat::expect_true({"geometry" %in% names(x)})
})
############################################################################## #
