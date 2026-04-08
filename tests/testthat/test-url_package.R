testthat::test_that("url_package default gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package(get_full_url = TRUE))
  )
})

testthat::test_that("url_package data gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("data", get_full_url = TRUE))
  )
})

testthat::test_that("url_package code gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("code", get_full_url = TRUE))
  )
})
testthat::test_that("url_package docs gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("docs", get_full_url = TRUE))
  )
})


testthat::test_that("url_package docs alias gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("docs", get_full_url = TRUE, desc_or_alias = "alias"))
  )
})
testthat::test_that("url_package code alias gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("code", get_full_url = TRUE, desc_or_alias = "alias"))
  )
})
testthat::test_that("url_package data alias gives working URL", {
  testthat::skip_if_offline()
  expect_true(
    url_online(url_package("data", get_full_url = TRUE, desc_or_alias = "alias"))
  )
})

testthat::test_that("url_package code() gives just owner/reponame not URL", {
  expect_true(
    grepl("^[^\\/]*\\/[^\\/]*$", url_package(
      # get_full_url = FALSE
      ))
  )
  expect_true(
    grepl("^[^\\/]*\\/[^\\/]*$", url_package(
       get_full_url = FALSE
    ))
  )
})
