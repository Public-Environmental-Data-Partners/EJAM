# Tests for shapefix()
################################################################ #

testthat::test_that("shapefix(NULL) returns NULL without error", {
  # Previously caused: no applicable method for 'st_geometry' applied to an object of class "NULL"
  result <- NULL
  testthat::expect_warning(
    result <- shapefix(NULL),
    regexp = "Uploaded file should have valid file extension\\(s\\)"
  )
  testthat::expect_null(result)
})
################################################################ #

## helpers - read the packaged test shapefiles straight out of their .zip
zipped_shp <- function(zipname, shpname) {
  path <- system.file(file.path("testdata/shapes", zipname), package = "EJAM")
  testthat::skip_if(path == "", paste("test file not found:", zipname))
  sf::st_read(paste0("/vsizip/", path, "/", shpname), quiet = TRUE)
}

testthat::test_that("shapefix() flags POINT geometry but still returns the shapefile", {
  ## stations.zip is a shapefile of 86 points - the app rejects it, ejamit() does not. see issue #550
  pts <- zipped_shp("stations.zip", "stations.shp")
  testthat::expect_true(all(sf::st_geometry_type(pts) == "POINT"))

  result <- shapefix(pts)

  ## reported via attributes ...
  testthat::expect_match(attr(result, "validate_errmsg"), "points, not polygons")
  testthat::expect_match(attr(result, "validate_errmsg"), "Latitude/Longitude file upload")
  testthat::expect_true(attr(result, "disable_buttons_SHP"))
  ## ... but NOT rejected here, so that ejamit(shapefile = <points>, radius = N) still works
  testthat::expect_s3_class(result, "sf")
  testthat::expect_equal(NROW(result), NROW(pts))
})

testthat::test_that("shapefix() also flags MULTIPOINT geometry", {
  ## the check used to test only == "POINT", so MULTIPOINT slipped through
  mp <- sf::st_sf(a = 1:2, geometry = sf::st_sfc(
    sf::st_multipoint(matrix(c(0, 0, 1, 1), ncol = 2)),
    sf::st_multipoint(matrix(c(2, 2, 3, 3), ncol = 2)), crs = 4269))

  result <- shapefix(mp)

  testthat::expect_match(attr(result, "validate_errmsg"), "points, not polygons")
  testthat::expect_true(attr(result, "disable_buttons_SHP"))
})

testthat::test_that("shapefix() leaves polygons alone - no message, buttons enabled", {
  poly <- zipped_shp("portland_shp.zip", "Neighborhoods_regions.shp")

  result <- shapefix(poly)

  testthat::expect_null(attr(result, "validate_errmsg"))
  testthat::expect_false(attr(result, "disable_buttons_SHP"))
  testthat::expect_equal(attr(result, "num_valid_pts_uploaded_SHP"), NROW(poly))
  testthat::expect_equal(attr(result, "invalid_alert_SHP"), 0)
  ## the columns shapefix() is responsible for adding
  testthat::expect_true(all(c("ejam_uniq_id", "siteid", "valid", "invalid_msg") %in% names(result)))
  testthat::expect_equal(result$ejam_uniq_id, seq_len(NROW(poly)))
  testthat::expect_equal(attr(result, "sf_column"), "geometry")
})

testthat::test_that("shapefix() on a shapefile with 0 shapes reports it instead of erroring", {
  ## used to fail with "object 'shp_is_valid' not found", so the message below was unreachable
  empty <- sf::st_sf(a = character(0), geometry = sf::st_sfc(crs = 4269))

  result <- shapefix(empty)

  testthat::expect_s3_class(result, "sf")
  testthat::expect_equal(NROW(result), 0)
  testthat::expect_equal(attr(result, "validate_errmsg"), "No shapes found in file uploaded.")
  testthat::expect_true(attr(result, "disable_buttons_SHP"))
})

testthat::test_that("shapefix() warns (not errors) when ejam_uniq_id is present but not 1:N", {
  ## used to fail with "invalid argument type", because all.equal() returns a string, not FALSE
  poly <- zipped_shp("portland_shp.zip", "Neighborhoods_regions.shp")[1:3, ]
  poly$ejam_uniq_id <- c(99L, 98L, 97L)

  result <- NULL
  testthat::expect_warning(
    result <- shapefix(poly),
    regexp = "not 1 through N"
  )
  ## and the existing ids are kept, as the warning says
  testthat::expect_equal(result$ejam_uniq_id, c(99L, 98L, 97L))
})
