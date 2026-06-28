test_that("url_package default URL responds", {
  skip_if_offline()

  expect_true(
    url_online(url_package(get_full_url = TRUE))
  )
})
