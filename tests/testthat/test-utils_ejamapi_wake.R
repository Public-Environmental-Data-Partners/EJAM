## tests for ejamapi_wake_js() (EJAM#772)

api_report <- list(list(header = "EJAM Report", text = "Report", FUN = url_ejamapi))

test_that("ejamapi_wake_js() calls /warmup at the API base address", {
  js <- ejamapi_wake_js(baseurl = "https://api.example.org/", reports = api_report, is_down = FALSE)
  expect_true(is.character(js) && length(js) == 1)
  expect_true(grepl('fetch("https://api.example.org/warmup"', js, fixed = TRUE))
  expect_true(grepl("no-cors", js, fixed = TRUE))
  expect_true(grepl(".catch(", js, fixed = TRUE))
})

test_that("ejamapi_wake_js() defaults to the address the report links use", {
  withr::local_options(ejam.api.baseurl = "http://127.0.0.1:3035")
  js <- ejamapi_wake_js(reports = api_report, is_down = FALSE)
  expect_true(grepl('"http://127.0.0.1:3035/warmup"', js, fixed = TRUE))
})

test_that("ejamapi_wake_js() returns NULL when there is nothing to wake", {
  # API marked down
  expect_null(ejamapi_wake_js(baseurl = "https://api.example.org", reports = api_report, is_down = TRUE))
  # no report link uses the API
  other <- list(list(header = "EJSCREEN Map", text = "EJSCREEN", FUN = url_ejscreenmap))
  expect_null(ejamapi_wake_js(baseurl = "https://api.example.org", reports = other, is_down = FALSE))
  expect_null(ejamapi_wake_js(baseurl = "https://api.example.org", reports = list(), is_down = FALSE))
  # unusable address
  for (bad in list(NA_character_, "", "not a url", c("https://a.org", "https://b.org"), character(0))) {
    expect_null(ejamapi_wake_js(baseurl = bad, reports = api_report, is_down = FALSE))
  }
})

test_that("the package's default settings send a wake-up", {
  expect_false(is.null(ejamapi_wake_js()))
})
