test_that("DESCRIPTION requires Shiny 1.14.0 or newer", {
  imports <- read.dcf(testthat::test_path("../../DESCRIPTION"), fields = "Imports")[1, "Imports"]
  shiny_min <- sub(
    ".*shiny\\s*\\(\\s*>=\\s*([0-9.]+)\\s*\\).*",
    "\\1",
    imports
  )

  expect_false(identical(shiny_min, imports))
  expect_true(utils::compareVersion(shiny_min, "1.14.0") >= 0)
})

test_that("manually-enabled download buttons opt out of Shiny auto-enable", {
  app_ui_source <- paste(
    readLines(testthat::test_path("../../R/app_ui.R"), warn = FALSE),
    collapse = "\n"
  )
  app_server_source <- paste(
    readLines(testthat::test_path("../../R/app_server.R"), warn = FALSE),
    collapse = "\n"
  )

  manual_download_calls <- regmatches(
    app_server_source,
    gregexpr("shinyjs::(?:disable|enable)\\(id = 'download_[^']+'", app_server_source, perl = TRUE)
  )[[1]]
  manually_managed_download_ids <- unique(
    sub(".*id = '([^']+)'.*", "\\1", manual_download_calls)
  )

  expect_setequal(
    manually_managed_download_ids,
    c("download_report_multisite", "download_results_spreadsheet")
  )

  for (download_id in manually_managed_download_ids) {
    expect_match(
      app_ui_source,
      paste0("downloadButton\\([^)]*'", download_id, "'[^)]*enabled\\s*=\\s*FALSE"),
      perl = TRUE
    )
  }
})
