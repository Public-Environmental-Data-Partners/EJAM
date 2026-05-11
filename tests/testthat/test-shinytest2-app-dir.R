test_that("shinytest2 app launcher uses installed package when source root is unavailable", {
  expect_true(exists("ejam_shinytest2_make_app_dir"))

  fake_rcheck_root <- file.path(tempdir(), "EJAM.Rcheck")
  dir.create(fake_rcheck_root, recursive = TRUE, showWarnings = FALSE)

  app_dir <- ejam_shinytest2_make_app_dir(fake_rcheck_root, test_category = "path-root")
  on.exit(unlink(app_dir, recursive = TRUE, force = TRUE), add = TRUE)

  app_lines <- readLines(file.path(app_dir, "app.R"), warn = FALSE)

  expect_true(any(grepl("library\\(EJAM\\)", app_lines)))
  expect_false(any(grepl("pkgload::load_all", app_lines, fixed = TRUE)))
})

test_that("shinytest2 app launcher uses source root when available", {
  expect_true(exists("ejam_shinytest2_make_app_dir"))

  source_root <- normalizePath(testthat::test_path("../../"), mustWork = TRUE)
  skip_if_not(file.exists(file.path(source_root, "DESCRIPTION")))

  app_dir <- ejam_shinytest2_make_app_dir(source_root, test_category = "path-root")
  on.exit(unlink(app_dir, recursive = TRUE, force = TRUE), add = TRUE)

  app_lines <- readLines(file.path(app_dir, "app.R"), warn = FALSE)

  expect_true(any(grepl("pkgload::load_all", app_lines, fixed = TRUE)))
  expect_false(any(grepl("library\\(EJAM\\)", app_lines)))
})
