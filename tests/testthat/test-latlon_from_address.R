# test_that("latlon_from_address works at all, default params", {
#   testthat::skip_if_not_installed("AOI")
#   a1 <- "1200 Pennsylvania Ave NW, Washington DC"
#   a2 <- "4930 Old Page Road Durham NC 27703"
#   testthat::expect_no_error(latlon_from_address(a1))
#   testthat::expect_no_error(latlon_from_address(c(a1, a2)))
# })

offline_warning()

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

testthat::test_that("latlon_from_address( xy=FALSE) works", {

  testthat::skip_if_offline()
  testthat::skip_if_not_installed("AOI")
  require("AOI")

  a1 <- "1200 Pennsylvania Ave NW, Washington DC"
  a2 <- "4930 Old Page Road Durham NC 27703"
  out1old <- structure(list(request = "1200 Pennsylvania Ave NW, Washington DC",
                            score = 100L, arcgis_address = "1200 Pennsylvania Ave NW, Washington, District of Columbia, 20004",
                            lon = -77.02895, lat = 38.89483), row.names = c(NA, -1L), class = "data.frame")
  out2old <- structure(list(request = c("1200 Pennsylvania Ave NW, Washington DC",
                                        "4930 Old Page Road Durham NC 27703"),
                            score = c(100L, 100L),
                            arcgis_address = c("1200 Pennsylvania Ave NW, Washington, District of Columbia, 20004",
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

testthat::test_that("latlon_from_address( aoimap=T) works", {

  testthat::skip_if_offline()
  testthat::skip_if_not_installed("AOI")
  require("AOI")

  testthat::expect_no_error({
    x <- latlon_from_address("ames iowa", aoimap = T)
  })
  testthat::expect_true({"geometry" %in% names(x)})
})


