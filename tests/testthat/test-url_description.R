# Exercise alternate DESCRIPTION settings without changing the installed package.
url_description_fixture <- function(fields) {
  path <- tempfile("ejam-description-")
  write.dcf(as.data.frame(as.list(c(Package = "EJAM", fields)), check.names = FALSE), path)
  withr::defer(unlink(path), envir = parent.frame())
  lookup <- url_package
  environment(lookup) <- list2env(
    list(system.file = function(...) path), parent = environment(url_package)
  )
  lookup
}

test_that("DESCRIPTION archive settings flow through URL builders", {
  withr::local_envvar(c(EJAM_API_BASEURL = NA, EJAM_DOCS_BASE_URL = NA))
  withr::local_options(list(ejam.api.baseurl = NULL))
  fields <- c(
    "Config/EJAM/url_api" = "https://api-archive.example.test/",
    "Config/EJAM/url_ejamapp" = "https://ejam-archive.example.test/",
    "Config/EJAM/url_ejamapp_alias" = "https://launch-archive.example.test/",
    "Config/EJAM/url_ejscreenapp" = "https://ejscreen-archive.example.test/index.html",
    "Config/EJAM/url_ejamdocs" = "https://docs.example.test/EJAM/v1.2.3/",
    "Config/EJAM/url_apidocs" = "https://docs.example.test/EJAM/v1.2.3/articles/dev-api.html",
    "Config/EJAM/url_ejscreendocs" = "https://docs.example.test/EJAM/v1.2.3/articles/ejscreen.html"
  )
  lookup <- url_description_fixture(fields)
  testthat::local_mocked_bindings(url_package = lookup, .package = "EJAM")
  for (type in c("api", "ejamapp", "ejscreenapp", "ejamdocs", "apidocs", "ejscreendocs")) {
    expect_identical(url_package(type), sub("/+$", "", fields[[paste0("Config/EJAM/url_", type)]]))
  }
  expect_identical(url_package("api", desc_or_alias = "alias"), "https://api-archive.example.test")
  expect_identical(url_ejamapp(fips = "10001"), "https://launch-archive.example.test?fips=10001")
  expect_identical(url_ejscreenmap(zip = "10001"), "https://ejscreen-archive.example.test/index.html?zip=10001")
  expect_identical(url_ejscreenmap(lat = NA_real_, lon = NA_real_), fields[["Config/EJAM/url_ejscreenapp"]])
  expect_match(url_ejamapi(lat = 39, lon = -75), "^https://api-archive[.]example[.]test/report[?]")
  expect_identical(
    url_ejamapi(shapefile = testinput_shapes_2[1, ], as_html = FALSE),
    "https://launch-archive.example.test"
  )
  # Explicit custom URLs and NA fallbacks remain available.
  expect_identical(url_ejscreenmap(zip = "10001", baseurl = "https://custom.example.test"),
                   "https://custom.example.test?zip=10001")
  expect_true(is.na(url_ejscreenmap(lat = NA_real_, lon = NA_real_, ifna = NA_character_)))
})

test_that("missing API metadata fails clearly instead of recursing or using current API", {
  withr::local_envvar(c(EJAM_API_BASEURL = NA))
  withr::local_options(list(ejam.api.baseurl = NULL))
  lookup <- url_description_fixture(c("Config/EJAM/url_ejamapp" = "https://app.example.test"))
  for (variant in c("desc", "alias", "redirect")) {
    expect_error(lookup("api", desc_or_alias = variant),
                 "missing the field 'Config/EJAM/url_api'", fixed = TRUE)
  }
  withr::local_envvar(c(EJAM_API_BASEURL = "http://127.0.0.1:3035/"))
  expect_identical(lookup("api"), "http://127.0.0.1:3035")
})
