test_that("url_ejamapi live point report URL responds", {
  skip_if_offline()

  url <- url_ejamapi(sitepoints = testpoints_10[1, ], as_html = FALSE)

  expect_true(url_online(url[1]))
})

test_that("url_ejamapi live FIPS report URL responds", {
  skip_if_offline()

  url <- url_ejamapi(fips = testinput_fips_counties[1], as_html = FALSE)

  expect_true(url_online(url[1]))
})

test_that("url_ejamapi live polygon app-fallback URL responds", {
  skip_if_offline()

  url <- url_ejamapi(shapefile = testinput_shapes_2[1, ], as_html = FALSE)

  expect_true(url_online(url[1]))
})
