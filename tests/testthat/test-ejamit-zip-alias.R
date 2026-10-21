# Test alias dispatch before the spatial analysis starts; no data/downloads needed.
test_that("ejamit accepts zip as a name-only alias and rejects conflicting inputs", {
  expect_error(ejamit(zip = "10605", zipcode = "10605"), "only one of zip or zipcode")
  expect_error(ejamit(zip = "10605", fips = "10001"), "zipcode cannot be combined")
  expect_error(ejamit(zip = "10605", shapefile = "dummy"), "zipcode cannot be combined")
  expect_error(ejamit(zip = "10605", lat = 40, lon = -75), "zipcode cannot be combined")
  local_mocked_bindings(shapes_from_zip = function(zipcode) {
    expect_identical(zipcode, c("01001", "10605"))
    stop("alias reached ZIP boundary lookup")
  })
  expect_error(ejamit(zip = c("01001", "10605")), "alias reached ZIP boundary lookup")
})
