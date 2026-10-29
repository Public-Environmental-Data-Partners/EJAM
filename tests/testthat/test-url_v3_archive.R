test_that("v3 archive metadata selects one consistent stack", {
  withr::local_envvar(c(EJAM_API_BASEURL = NA, EJAM_DOCS_BASE_URL = NA))
  withr::local_options(list(ejam.api.baseurl = NULL))
  expected <- list(
    api = c("https://api-archive.ejanalysis.com", "https://api-archive.ejanalysis.com", "https://api-archive.ejanalysis.com"),
    ejam = c("https://ejam-archive.publicenvirodata.org", "https://ejam-archive.ejanalysis.com", "https://ejam-archive.ejanalysis.com"),
    ejscreen = c("https://pedp-ejscreen-archive.azurewebsites.net/index.html", "https://ejscreen-archive.ejanalysis.com", "https://ejscreen-archive.ejanalysis.com"),
    docs = c("https://public-environmental-data-partners.github.io/EJAM/v3.2022.3", "https://docs-archive.ejanalysis.com", "https://docs-archive.ejanalysis.com"),
    apidocs = c("https://public-environmental-data-partners.github.io/EJAM/v3.2022.3/articles/dev-api.html", "https://apidocs-archive.ejanalysis.com", "https://apidocs-archive.ejanalysis.com"),
    ejscreendocs = c("https://public-environmental-data-partners.github.io/EJAM/v3.2022.3/articles/ejscreen.html", "https://ejscreendocs-archive.ejanalysis.com", "https://ejscreendocs-archive.ejanalysis.com")
  )
  for (type in names(expected)) {
    for (i in seq_along(expected[[type]])) {
      expect_identical(url_package(type, desc_or_alias = c("desc", "alias", "redirect")[i]),
                       expected[[type]][i], info = type)
    }
  }
  metadata <- desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))
  expect_identical(as.character(metadata$get("Config/EJAM/url_api_direct")),
                   "https://ejamapi-archive-84652557241.us-central1.run.app")
  expect_match(as.character(metadata$get("URL")),
               "^https://public-environmental-data-partners[.]github[.]io/EJAM/v3[.]2022[.]3,")
  expect_identical(as.character(metadata$get("Version")), "3.2022.3")
  expect_identical(as.character(metadata$get("VersionACS")), "2018-2022")
  expect_identical(as.character(metadata$get("ejamdata_required_tag")), "v3.2022.3")
  expect_identical(url_ejamapp(fips = "10001"), "https://ejam-archive.ejanalysis.com?fips=10001")
  expect_identical(url_ejscreenmap(zip = "10001"), "https://pedp-ejscreen-archive.azurewebsites.net/index.html?zip=10001")
  expect_match(url_ejamapi(lat = 39, lon = -75), "^https://api-archive[.]ejanalysis[.]com/report[?]")
})
