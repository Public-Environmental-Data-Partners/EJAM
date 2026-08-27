# Live checks that the URLs url_ejamapi() builds are ones the API actually accepts.
# Skips (does not fail) when the API cannot answer, but a 4xx still fails - a bad
# path or query string is exactly the regression these tests exist to catch.
# See expect_url_online_or_skip() in setup.R

test_that("url_ejamapi live point report URL responds", {
  skip_if_offline()

  url <- url_ejamapi(sitepoints = testpoints_10[1, ], as_html = FALSE)

  expect_url_online_or_skip(url[1], what = "url_ejamapi() point report URL")
})

test_that("url_ejamapi live FIPS report URL responds", {
  skip_if_offline()

  url <- url_ejamapi(fips = testinput_fips_counties[1], as_html = FALSE)

  expect_url_online_or_skip(url[1], what = "url_ejamapi() FIPS report URL")
})

test_that("url_ejamapi live polygon app-fallback URL responds", {
  skip_if_offline()

  url <- url_ejamapi(shapefile = testinput_shapes_2[1, ], as_html = FALSE)

  expect_url_online_or_skip(url[1], what = "url_ejamapi() polygon app-fallback URL")
})
