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
  expect_identical(
    url_package("docs", get_full_url = TRUE, desc_or_alias = "alias"),
    "https://docs.ejanalysis.com"
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

# --- expanded types added by the urls-in-DESCRIPTION work (PR #485) ---

testthat::test_that("url_package api returns the branded full URL with no trailing slash", {
  x <- url_package("api")
  expect_match(x, "^https://")
  expect_false(grepl("/$", x))
  expect_identical(x, "https://api.ejanalysis.com")
})

testthat::test_that("url_package app/api/docs types return full URLs even with default get_full_url", {
  for (ty in c("ejamapp", "app", "ejam", "ejamdev", "ejamappdev",
               "ejscreen", "ejscreenapp", "docs", "ejamdocs",
               "ejscreendocs", "apidocs", "api")) {
    expect_match(url_package(ty), "^https?://", info = ty)
  }
})

testthat::test_that("url_package type synonyms agree", {
  expect_identical(url_package("code"), url_package("ejamrepo"))
  expect_identical(url_package("data"), url_package("datarepo"))
  expect_identical(url_package("docs"), url_package("ejamdocs"))
  expect_identical(url_package("app"), url_package("ejamapp"))
  expect_identical(url_package("ejam"), url_package("ejamapp"))
  expect_identical(url_package("ejamdev"), url_package("ejamappdev"))
  expect_identical(url_package("ejscreen"), url_package("ejscreenapp"))
})

testthat::test_that("url_package repo types give owner/repo shorthand by default", {
  for (ty in c("code", "ejamrepo", "ejscreenrepo", "apirepo", "data", "datarepo")) {
    expect_match(url_package(ty), "^[^/]+/[^/]+$", info = ty)
  }
  expect_identical(url_package("data"), "Public-Environmental-Data-Partners/ejamdata")
})

testthat::test_that("url_package alias and redirect variants return full URLs", {
  for (ty in c("code", "data", "docs", "apidocs", "ejamapp", "ejscreenapp", "api")) {
    expect_match(url_package(ty, desc_or_alias = "alias"), "^https://", info = ty)
    expect_match(url_package(ty, desc_or_alias = "redirect"), "^https://", info = ty)
  }
  expect_identical(
    url_package("apidocs", desc_or_alias = "alias"),
    "https://apidocs.ejanalysis.com"
  )
  expect_identical(url_package("api", desc_or_alias = "redirect"), "https://ejanalysis.com/api")
})

testthat::test_that("url_package gives useful errors for invalid types", {
  type_error <- tryCatch(
    url_package("nonsense"),
    error = function(error) conditionMessage(error)
  )
  expect_match(
    type_error,
    'Invalid `type` value: "nonsense".',
    fixed = TRUE
  )
  expect_match(
    type_error,
    '`type` must be one of: "code", "ejamrepo"',
    fixed = TRUE
  )
  expect_match(type_error, '"api". See ?url_package.', fixed = TRUE)

  expect_error(url_package("apidocker")) # informational field, not an accepted type
  expect_error(url_package("apidocs_alias")) # select with desc_or_alias = "alias"
  expect_error(
    url_package(c("docs", "api")),
    "`type` must be one of:",
    fixed = TRUE
  )
  expect_error(
    url_package(character()),
    "Invalid `type` value: <empty>",
    fixed = TRUE
  )
})

testthat::test_that("url_package docs_version appends subpath for docs types", {
  expect_match(url_package("docs", docs_version = "dev"), "/dev$")
  expect_match(url_package("ejamdocs", docs_version = "v3.2022.1"), "/v3\\.2022\\.1$")
})
