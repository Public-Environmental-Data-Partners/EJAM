# Tests for shapefix()
################################################################ #

testthat::test_that("shapefix(NULL) returns NULL without error", {
  # Previously caused: no applicable method for 'st_geometry' applied to an object of class "NULL"
  result <- testthat::expect_warning(
    shapefix(NULL),
    regexp = "valid file extension"
  )
  testthat::expect_null(result)
})
