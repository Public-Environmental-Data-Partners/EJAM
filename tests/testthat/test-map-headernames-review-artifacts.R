test_that("map_headernames validation helper is named for validation", {
  ns <- asNamespace("EJAM")

  expect_true(exists("validate_map_headernames_ejscreen_names", envir = ns, inherits = FALSE))
  expect_false(exists("augment_map_headernames_ejscreen_names", envir = ns, inherits = FALSE))
})

test_that("map_headernames review artifacts avoid local default paths and can write redline xlsx", {
  testthat::skip_if_not_installed("openxlsx")

  script_path <- file.path("data-raw", "datacreate_map_headernames_review_artifacts.R")
  if (!file.exists(script_path)) {
    script_path <- file.path("..", "..", "data-raw", "datacreate_map_headernames_review_artifacts.R")
  }
  testthat::skip_if_not(file.exists(script_path))

  env <- new.env(parent = globalenv())
  sys.source(script_path, envir = env)

  default_dir <- env$map_headernames_review_artifact_dir()
  expect_false(grepl("Documents|~", default_dir))
  expect_equal(
    basename(default_dir),
    paste0("map_headernames_review_artifacts_", format(Sys.Date(), "%Y-%m-%d"))
  )

  old <- data.frame(
    n = c("1", "2"),
    rname = c("pm", "no2"),
    longname = c("PM old", "NO2"),
    varlist = c("names_e", "names_e"),
    ejscreen_indicator = c("PM25", "NO2"),
    stringsAsFactors = FALSE
  )
  new <- data.frame(
    n = c("1", "2", "3"),
    rname = c("pm", "no2", "o3"),
    longname = c("PM new", "NO2", "Ozone"),
    varlist = c("names_e", "names_e", "names_e"),
    ejscreen_indicator = c("PM25", "NO2", "OZONE"),
    stringsAsFactors = FALSE
  )

  tmp <- tempfile("map_headernames_review_artifacts_test_")
  dir.create(tmp)
  old_csv <- file.path(tmp, "old_map_headernames.csv")
  new_csv <- file.path(tmp, "new_map_headernames.csv")
  utils::write.csv(old, old_csv, row.names = FALSE, na = "")
  utils::write.csv(new, new_csv, row.names = FALSE, na = "")

  out <- env$datacreate_map_headernames_review_artifacts(
    current_csv = new_csv,
    old_csv = old_csv,
    output_dir = file.path(tmp, "artifacts"),
    write_redline_xlsx = TRUE,
    quiet = TRUE
  )

  expect_true(file.exists(out$files$summary))
  expect_true(file.exists(out$files$duplicates))
  expect_true(file.exists(out$files$redline_xlsx))
  expect_true("cell_changes" %in% openxlsx::getSheetNames(out$files$redline_xlsx))
})
