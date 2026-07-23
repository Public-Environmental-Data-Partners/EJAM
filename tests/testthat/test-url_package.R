testthat::test_that("url_package default gives full URL", {
  expect_match(
    url_package(get_full_url = TRUE),
    "^https://github\\.com/[^/]+/[^/]+$"
  )
})

testthat::test_that("url_package data gives full URL", {
  expect_match(
    url_package("data", get_full_url = TRUE),
    "^https://github\\.com/[^/]+/[^/]+$"
  )
})

testthat::test_that("url_package code gives full URL", {
  expect_match(
    url_package("code", get_full_url = TRUE),
    "^https://github\\.com/[^/]+/[^/]+$"
  )
})
testthat::test_that("url_package docs gives full URL", {
  expect_match(
    url_package("docs", get_full_url = TRUE),
    "^https://"
  )
})


testthat::test_that("url_package docs alias gives full URL", {
  expect_match(
    url_package("docs", get_full_url = TRUE, desc_or_alias = "alias"),
    "^https://"
  )
})
testthat::test_that("url_package code alias gives full URL", {
  expect_match(
    url_package("code", get_full_url = TRUE, desc_or_alias = "alias"),
    "^https://"
  )
})
testthat::test_that("url_package data alias gives full URL", {
  expect_match(
    url_package("data", get_full_url = TRUE, desc_or_alias = "alias"),
    "^https://"
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

testthat::test_that("url_package repo types can return just owner/reponame", {
  expect_match(
    url_package("code", get_full_url = FALSE),
    "^[^/]+/[^/]+$"
  )
  expect_match(
    url_package("data", get_full_url = FALSE),
    "^[^/]+/[^/]+$"
  )
})

testthat::test_that("url_package app and docs types always return full URLs", {
  expect_match(
    url_package("ejamapp"),
    "^https?://"
  )
  expect_warning(
    ejamapp_url <- url_package("ejamapp", get_full_url = FALSE),
    "ignoring get_full_url=FALSE"
  )
  expect_match(
    ejamapp_url,
    "^https?://"
  )
  expect_match(
    url_package("ejscreenapp"),
    "^https?://"
  )
  expect_match(
    url_package("ejamdocs"),
    "^https?://"
  )
})
