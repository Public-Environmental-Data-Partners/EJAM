# A live check that the URL url_package() hands out is actually serving.
# Skips (does not fail) when the site cannot answer - see
# expect_url_online_or_skip() in setup.R for why 4xx still fails.

test_that("url_package default URL responds", {
  skip_if_offline()

  expect_url_online_or_skip(
    url_package(get_full_url = TRUE),
    what = "url_package() default URL"
  )
})
