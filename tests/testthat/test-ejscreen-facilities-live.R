test_that("get_ejscreen_facilities_nearby returns a data.frame", {
  skip_if_offline()

  result <- tryCatch(
    get_ejscreen_facilities_nearby(
      frompoints = data.frame(lat = 39.65, lon = -75.73),
      radius = 0.5,
      sitecategory = "npl"
    ),
    httr2_http = function(e) skip(paste("live EJScreen facility API unavailable:", conditionMessage(e)))
  )
  expect_true(is.data.frame(result))
  if (NROW(result) > 0) {
    expect_true("lat" %in% names(result))
    expect_true("lon" %in% names(result))
    expect_true("frompoint_n" %in% names(result))
    expect_true("sitecategory" %in% names(result))
  }
})

test_that("get_ejscreen_facilities_nearby returns empty data.frame when no facilities found", {
  skip_if_offline()

  result <- tryCatch(
    get_ejscreen_facilities_nearby(
      frompoints = data.frame(lat = 0.0, lon = -150.0),
      radius = 0.1,
      sitecategory = "npl"
    ),
    httr2_http = function(e) skip(paste("live EJScreen facility API unavailable:", conditionMessage(e)))
  )
  expect_true(is.data.frame(result))
  expect_equal(NROW(result), 0)
})
