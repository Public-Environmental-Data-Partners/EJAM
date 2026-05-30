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
