pipeline_config_envvars <- c(
  "EJAM_PIPELINE_YR",
  "EJAM_PIPELINE_ROOT",
  "EJAM_PIPELINE_DIR",
  "EJAM_PIPELINE_STORAGE",
  "EJAM_STAGE_FORMAT",
  "EJAM_STAGE_FORMATS",
  "EJAM_BLOCKGROUP_UNIVERSE_SOURCE",
  "EJAM_TRACT_WEIGHT_SOURCE",
  "EJAM_DECENNIAL_BGWTS_CACHE",
  "EJAM_REFRESH_DECENNIAL_BGWTS",
  "EJAM_FORCE_ACS",
  "EJAM_FORCE_BG_ACSDATA",
  "EJAM_FORCE_BG_GEODATA",
  "EJAM_TIGER_BG_CACHE_DIR",
  "EJAM_ACS_DOWNLOAD_TIMEOUT",
  "EJAM_ACS_DOWNLOAD_RETRIES",
  "EJAM_INCLUDE_ISLANDAREAS_DATA",
  "EJAM_ISLANDAREAS_REFERENCE_PATH",
  "EJAM_USE_ISLANDAREAS_DEMOGRAPHICS",
  "EJAM_USE_PROVISIONAL_BG_ENVIRODATA",
  "EJAM_BG_ENVIRODATA_REFERENCE_PATH",
  "EJAM_BG_ENVIRODATA_REFERENCE_VARS",
  "EJAM_INCLUDE_EJSCREEN_EXPORT",
  "EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT",
  "EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS",
  "EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT",
  "EJAM_VALIDATE_VS_PRIOR",
  "EJAM_PRIOR_PIPELINE_YR",
  "EJAM_PRIOR_PIPELINE_DIR",
  "EJAM_PRIOR_PACKAGE_REF",
  "EJAM_PRIOR_PACKAGE_PATH",
  "EJAM_EJSCREEN_EXPORT_REFERENCE_PATH",
  "EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH",
  "EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE",
  "EJAM_VALIDATE_VS_PRIOR_WALDO",
  "EJAM_RUN_DATACREATE_BEFORE",
  "EJAM_RUN_DATACREATE_AFTER",
  "EJAM_REPLACE_PACKAGE_DATA",
  "EJAM_INCLUDE_FRS_UPDATE"
)

clear_pipeline_config_envvars <- function() {
  withr::local_envvar(
    stats::setNames(rep(NA_character_, length(pipeline_config_envvars)), pipeline_config_envvars),
    .local_envir = parent.frame()
  )
}

test_that("ejscreen_pipeline_default_env_values captures runner defaults", {
  root <- "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"

  defaults <- EJAM:::ejscreen_pipeline_default_env_values(yr = 2024)

  expect_equal(defaults[["EJAM_PIPELINE_YR"]], "2024")
  expect_equal(defaults[["EJAM_PIPELINE_ROOT"]], root)
  expect_equal(defaults[["EJAM_PIPELINE_STORAGE"]], "s3")
  expect_equal(defaults[["EJAM_PIPELINE_DIR"]], file.path(root, "ejscreen_acs_2024"))
  expect_equal(defaults[["EJAM_STAGE_FORMATS"]], "csv,rda")
  expect_equal(defaults[["EJAM_INCLUDE_ISLANDAREAS_DATA"]], "TRUE")
  expect_equal(defaults[["EJAM_USE_ISLANDAREAS_DEMOGRAPHICS"]], "FALSE")
  expect_equal(defaults[["EJAM_PRIOR_PIPELINE_YR"]], "2023")
  expect_equal(defaults[["EJAM_REPLACE_PACKAGE_DATA"]], "FALSE")

  local_defaults <- EJAM:::ejscreen_pipeline_default_env_values(yr = 2024, storage = "local")
  expect_equal(local_defaults[["EJAM_PIPELINE_STORAGE"]], "local")
  expect_match(local_defaults[["EJAM_PIPELINE_DIR"]], "data-raw/pipeline_outputs/ejscreen_acs_2024", fixed = TRUE)
})

test_that("ejscreen_pipeline_set_env_defaults preserves explicit overrides", {
  clear_pipeline_config_envvars()
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2023",
    EJAM_STAGE_FORMAT = "rda"
  ))

  defaults <- EJAM:::ejscreen_pipeline_default_env_values(yr = 2024)
  EJAM:::ejscreen_pipeline_set_env_defaults(defaults)

  expect_equal(Sys.getenv("EJAM_PIPELINE_YR"), "2023")
  expect_equal(Sys.getenv("EJAM_STAGE_FORMAT"), "rda")
  expect_equal(Sys.getenv("EJAM_PIPELINE_STORAGE"), "s3")
  expect_equal(Sys.getenv("EJAM_PRIOR_PACKAGE_PATH"), "data/blockgroupstats.rda")
})

test_that("ejscreen_pipeline_config builds annual defaults without reading env vars", {
  clear_pipeline_config_envvars()
  withr::local_envvar(EJAM_PIPELINE_DIR = "s3://wrong/place")

  cfg <- EJAM:::ejscreen_pipeline_config(yr = 2024)

  expect_s3_class(cfg, "ejam_ejscreen_pipeline_config")
  expect_equal(cfg$yr, 2024L)
  expect_equal(cfg$pipeline_root, "s3://pedp-data-preserved/ejscreen-data-processing/pipeline")
  expect_equal(
    cfg$pipeline_dir,
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2024"
  )
  expect_equal(cfg$pipeline_storage, "s3")
  expect_equal(cfg$stage_format, "csv")
  expect_equal(cfg$stage_formats, c("csv", "rda"))
  expect_equal(cfg$prior_pipeline_yr, "2023")
  expect_equal(
    cfg$prior_pipeline_dir,
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2023"
  )
  expect_true(cfg$include_islandareas_data)
  expect_false(cfg$use_islandareas_demographics)
  expect_true(cfg$include_ejscreen_export)
  expect_true(cfg$include_ejscreen_export_statepct)
  expect_false(cfg$include_ejscreen_pctile_lookup_exports)
  expect_false(cfg$include_ejscreen_dataset_creator_input)
  expect_true(cfg$validate_vs_prior)
})

test_that("ejscreen_pipeline_config normalizes stage formats and validates choices", {
  cfg <- EJAM:::ejscreen_pipeline_config(
    yr = 2024,
    pipeline_storage = "local",
    pipeline_root = file.path(tempdir(), "ejam-pipeline-config"),
    stage_format = "arrow",
    stage_formats = c("csv", "rda", "csv")
  )

  expect_equal(cfg$stage_formats, c("arrow", "csv", "rda"))
  expect_error(
    EJAM:::ejscreen_pipeline_config(yr = 2024, stage_format = "txt"),
    "stage_format"
  )
  expect_error(
    EJAM:::ejscreen_pipeline_config(yr = 2024, blockgroup_universe_source = "tiger"),
    "blockgroup_universe_source"
  )
})

test_that("ejscreen_pipeline_config_from_env honors environment overrides", {
  clear_pipeline_config_envvars()
  root <- file.path(tempdir(), "ejam-pipeline-env-root")
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2022",
    EJAM_PIPELINE_ROOT = root,
    EJAM_PIPELINE_STORAGE = "local",
    EJAM_STAGE_FORMAT = "rda",
    EJAM_STAGE_FORMATS = "csv",
    EJAM_FORCE_ACS = "yes",
    EJAM_INCLUDE_EJSCREEN_EXPORT = "false",
    EJAM_BG_ENVIRODATA_REFERENCE_VARS = "drinking, DWATER",
    EJAM_RUN_DATACREATE_BEFORE = "0",
    EJAM_INCLUDE_FRS_UPDATE = "1"
  ))

  cfg <- EJAM:::ejscreen_pipeline_config_from_env()

  expect_equal(cfg$yr, 2022L)
  expect_equal(cfg$pipeline_storage, "local")
  expect_equal(cfg$pipeline_root, root)
  expect_equal(cfg$pipeline_dir, file.path(root, "ejscreen_acs_2022"))
  expect_equal(cfg$stage_format, "rda")
  expect_equal(cfg$stage_formats, c("rda", "csv"))
  expect_true(cfg$force_acs)
  expect_true(cfg$force_bg_acsdata)
  expect_false(cfg$include_ejscreen_export)
  expect_false(cfg$include_ejscreen_export_statepct)
  expect_equal(cfg$bg_envirodata_reference_vars, c("drinking", "DWATER"))
  expect_false(cfg$run_datacreate_before)
  expect_true(cfg$run_datacreate_after)
  expect_true(cfg$include_frs_update)
})

test_that("ejscreen_pipeline_config_summary reports env and resolved settings", {
  clear_pipeline_config_envvars()
  root <- file.path(tempdir(), "ejam-pipeline-summary-root")
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2024",
    EJAM_PIPELINE_ROOT = root,
    EJAM_PIPELINE_STORAGE = "local",
    EJAM_STAGE_FORMAT = "rda",
    EJAM_STAGE_FORMATS = "csv",
    EJAM_FORCE_ACS = "1",
    EJAM_BG_ENVIRODATA_REFERENCE_VARS = "drinking,DWATER",
    AWS_PROFILE = "test-profile",
    AWS_REGION = "us-east-1"
  ))

  cfg <- EJAM:::ejscreen_pipeline_config_from_env()
  summary <- EJAM:::ejscreen_pipeline_config_summary(cfg)

  expect_equal(rownames(summary), EJAM:::ejscreen_pipeline_setting_names())
  expect_equal(colnames(summary), c("Sys.getenv", "using_here"))
  expect_equal(summary["EJAM_PIPELINE_YR", "Sys.getenv"], "2024")
  expect_equal(summary["EJAM_PIPELINE_YR", "using_here"], "2024")
  expect_equal(summary["EJAM_PIPELINE_DIR", "using_here"], file.path(root, "ejscreen_acs_2024"))
  expect_equal(summary["EJAM_STAGE_FORMATS", "using_here"], "rda,csv")
  expect_equal(summary["EJAM_FORCE_BG_ACSDATA", "using_here"], "TRUE")
  expect_equal(summary["EJAM_BG_ENVIRODATA_REFERENCE_VARS", "using_here"], "drinking,DWATER")
  expect_equal(summary["AWS_PROFILE", "using_here"], "test-profile")
})

test_that("pipeline_config_annual provides a concise annual recipe", {
  root <- file.path(tempdir(), "ejam-pipeline-annual-root")
  cfg <- EJAM:::pipeline_config_annual(
    yr = 2023,
    pipeline_root = root,
    pipeline_storage = "local"
  )

  expect_s3_class(cfg, "ejam_ejscreen_pipeline_config")
  expect_equal(cfg$yr, 2023L)
  expect_equal(cfg$pipeline_dir, file.path(root, "ejscreen_acs_2023"))
  expect_equal(cfg$prior_pipeline_yr, "2022")
  expect_true(cfg$include_ejscreen_export)
  expect_true(cfg$include_ejscreen_export_statepct)
  expect_false(cfg$include_ejscreen_pctile_lookup_exports)
})

test_that("pipeline_config_release keeps release defaults explicit and overridable", {
  root <- file.path(tempdir(), "ejam-pipeline-release-root")
  cfg <- EJAM:::pipeline_config_release(
    yr = 2024,
    pipeline_root = root,
    pipeline_storage = "local",
    replace_package_data = TRUE
  )

  expect_equal(cfg$pipeline_dir, file.path(root, "ejscreen_acs_2024"))
  expect_equal(cfg$stage_format, "csv")
  expect_equal(cfg$stage_formats, c("csv", "rda"))
  expect_true(cfg$include_ejscreen_export)
  expect_true(cfg$include_ejscreen_export_statepct)
  expect_false(cfg$include_ejscreen_pctile_lookup_exports)
  expect_true(cfg$validate_vs_prior)
  expect_true(cfg$run_datacreate_before)
  expect_true(cfg$run_datacreate_after)
  expect_true(cfg$replace_package_data)
})

test_that("pipeline_config_validation_only avoids update side effects", {
  root <- file.path(tempdir(), "ejam-pipeline-validation-root")
  cfg <- EJAM:::pipeline_config_validation_only(
    yr = 2024,
    pipeline_root = root,
    pipeline_storage = "local"
  )

  expect_false(cfg$force_acs)
  expect_false(cfg$force_bg_acsdata)
  expect_false(cfg$force_bg_geodata)
  expect_true(cfg$validate_vs_prior)
  expect_false(cfg$run_datacreate_before)
  expect_false(cfg$run_datacreate_after)
  expect_false(cfg$replace_package_data)
  expect_false(cfg$include_frs_update)
})

test_that("pipeline_config_exports_only enables exports without annual side effects", {
  root <- file.path(tempdir(), "ejam-pipeline-exports-root")
  cfg <- EJAM:::pipeline_config_exports_only(
    yr = 2024,
    pipeline_root = root,
    pipeline_storage = "local",
    include_ejscreen_dataset_creator_input = TRUE
  )

  expect_false(cfg$force_acs)
  expect_false(cfg$force_bg_acsdata)
  expect_false(cfg$force_bg_geodata)
  expect_true(cfg$include_ejscreen_export)
  expect_true(cfg$include_ejscreen_export_statepct)
  expect_false(cfg$include_ejscreen_pctile_lookup_exports)
  expect_true(cfg$include_ejscreen_dataset_creator_input)
  expect_false(cfg$validate_vs_prior)
  expect_false(cfg$run_datacreate_before)
  expect_false(cfg$run_datacreate_after)
  expect_false(cfg$replace_package_data)
})

test_that("ejscreen_pipeline_config_recipe_from_env applies common script env settings", {
  clear_pipeline_config_envvars()
  root <- file.path(tempdir(), "ejam-pipeline-recipe-env-root")
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2023",
    EJAM_PIPELINE_ROOT = root,
    EJAM_PIPELINE_STORAGE = "local",
    EJAM_STAGE_FORMAT = "rda",
    EJAM_STAGE_FORMATS = "csv,rda"
  ))

  cfg <- EJAM:::ejscreen_pipeline_config_recipe_from_env(EJAM:::pipeline_config_validation_only)

  expect_equal(cfg$yr, 2023L)
  expect_equal(cfg$pipeline_root, root)
  expect_equal(cfg$pipeline_dir, file.path(root, "ejscreen_acs_2023"))
  expect_equal(cfg$pipeline_storage, "local")
  expect_equal(cfg$stage_format, "rda")
  expect_equal(cfg$stage_formats, c("csv", "rda"))
  expect_false(cfg$run_datacreate_before)
  expect_true(cfg$validate_vs_prior)
})

test_that("ejscreen_pipeline_apply_config_env applies recipe settings for runner compatibility", {
  clear_pipeline_config_envvars()
  withr::local_envvar(c(
    AWS_PROFILE = "keep-existing-profile",
    AWS_REGION = "keep-existing-region"
  ))
  root <- file.path(tempdir(), "ejam-pipeline-apply-env-root")
  cfg <- EJAM:::pipeline_config_validation_only(
    yr = 2024,
    pipeline_root = root,
    pipeline_storage = "local"
  )

  applied <- EJAM:::ejscreen_pipeline_apply_config_env(cfg)

  expect_equal(applied[["EJAM_PIPELINE_YR"]], "2024")
  expect_equal(Sys.getenv("EJAM_PIPELINE_DIR"), file.path(root, "ejscreen_acs_2024"))
  expect_equal(Sys.getenv("EJAM_VALIDATE_VS_PRIOR"), "TRUE")
  expect_equal(Sys.getenv("EJAM_RUN_DATACREATE_BEFORE"), "FALSE")
  expect_equal(Sys.getenv("EJAM_RUN_DATACREATE_AFTER"), "FALSE")
  expect_equal(Sys.getenv("EJAM_REPLACE_PACKAGE_DATA"), "FALSE")
  expect_equal(Sys.getenv("AWS_PROFILE"), "keep-existing-profile")
  expect_false("AWS_PROFILE" %in% names(applied))
})

test_that("ejscreen_pipeline_apply_config_env can preserve existing env vars", {
  clear_pipeline_config_envvars()
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2023",
    EJAM_STAGE_FORMAT = "rda"
  ))
  cfg <- EJAM:::pipeline_config_annual(yr = 2024)

  applied <- EJAM:::ejscreen_pipeline_apply_config_env(cfg, overwrite = FALSE)

  expect_equal(Sys.getenv("EJAM_PIPELINE_YR"), "2023")
  expect_equal(Sys.getenv("EJAM_STAGE_FORMAT"), "rda")
  expect_equal(Sys.getenv("EJAM_PIPELINE_STORAGE"), "s3")
  expect_false("EJAM_PIPELINE_YR" %in% names(applied))
  expect_true("EJAM_PIPELINE_STORAGE" %in% names(applied))
})

test_that("ejscreen_pipeline_run_script applies config before sourcing runner", {
  clear_pipeline_config_envvars()
  root <- file.path(tempdir(), "ejam-pipeline-run-script-root")
  cfg <- EJAM:::pipeline_config_validation_only(
    yr = 2024,
    pipeline_root = root,
    pipeline_storage = "local"
  )
  stub_script <- tempfile(fileext = ".R")
  observed_path <- tempfile(fileext = ".rds")
  writeLines(
    c(
      "observed <- list(",
      "  yr = Sys.getenv('EJAM_PIPELINE_YR'),",
      "  pipeline_dir = Sys.getenv('EJAM_PIPELINE_DIR'),",
      "  run_datacreate_before = Sys.getenv('EJAM_RUN_DATACREATE_BEFORE'),",
      "  validate_vs_prior = Sys.getenv('EJAM_VALIDATE_VS_PRIOR')",
      ")",
      paste0("saveRDS(observed, ", deparse(observed_path), ")")
    ),
    con = stub_script
  )

  result <- EJAM:::ejscreen_pipeline_run_script(
    config = cfg,
    script = stub_script,
    restore_env = TRUE
  )
  observed <- readRDS(observed_path)

  expect_equal(observed$yr, "2024")
  expect_equal(observed$pipeline_dir, file.path(root, "ejscreen_acs_2024"))
  expect_equal(observed$run_datacreate_before, "FALSE")
  expect_equal(observed$validate_vs_prior, "TRUE")
  expect_equal(Sys.getenv("EJAM_PIPELINE_YR", unset = NA_character_), NA_character_)
  expect_named(result, c("config", "applied_env", "source_result"))
})

test_that("ejscreen_pipeline_run_recipe_script builds recipe config before sourcing runner", {
  clear_pipeline_config_envvars()
  root <- file.path(tempdir(), "ejam-pipeline-run-recipe-root")
  withr::local_envvar(c(
    EJAM_PIPELINE_YR = "2024",
    EJAM_PIPELINE_ROOT = root,
    EJAM_PIPELINE_STORAGE = "local"
  ))
  stub_script <- tempfile(fileext = ".R")
  observed_path <- tempfile(fileext = ".rds")
  writeLines(
    c(
      "observed <- list(",
      "  yr = Sys.getenv('EJAM_PIPELINE_YR'),",
      "  pipeline_dir = Sys.getenv('EJAM_PIPELINE_DIR'),",
      "  include_ejscreen_export = Sys.getenv('EJAM_INCLUDE_EJSCREEN_EXPORT'),",
      "  validate_vs_prior = Sys.getenv('EJAM_VALIDATE_VS_PRIOR'),",
      "  skip_package_load = Sys.getenv('EJAM_PIPELINE_SKIP_PACKAGE_LOAD')",
      ")",
      paste0("saveRDS(observed, ", deparse(observed_path), ")")
    ),
    con = stub_script
  )

  result <- EJAM:::ejscreen_pipeline_run_recipe_script(
    recipe = EJAM:::pipeline_config_exports_only,
    script = stub_script,
    restore_env = TRUE
  )
  observed <- readRDS(observed_path)

  expect_equal(observed$yr, "2024")
  expect_equal(observed$pipeline_dir, file.path(root, "ejscreen_acs_2024"))
  expect_equal(observed$include_ejscreen_export, "TRUE")
  expect_equal(observed$validate_vs_prior, "FALSE")
  expect_equal(observed$skip_package_load, "TRUE")
  expect_equal(Sys.getenv("EJAM_PIPELINE_YR", unset = NA_character_), "2024")
  expect_equal(Sys.getenv("EJAM_PIPELINE_SKIP_PACKAGE_LOAD", unset = NA_character_), NA_character_)
  expect_named(result, c("config", "applied_env", "source_result"))
})

test_that("ejscreen_pipeline_source_scripts sources enabled scripts and reports disabled scripts", {
  marker <- tempfile()
  script <- tempfile(fileext = ".R")
  writeLines(
    paste0("writeLines('ran', ", deparse(marker), ")"),
    con = script
  )

  result <- NULL
  expect_output(
    result <- EJAM:::ejscreen_pipeline_source_scripts(script, enabled = TRUE),
    paste0("sourcing the script in ", script),
    fixed = TRUE
  )
  expect_equal(result, script)
  expect_equal(readLines(marker, warn = FALSE), "ran")

  disabled_marker <- tempfile()
  disabled_script <- tempfile(fileext = ".R")
  writeLines(
    paste0("writeLines('ran', ", deparse(disabled_marker), ")"),
    con = disabled_script
  )
  expect_message(
    result <- EJAM:::ejscreen_pipeline_source_scripts(
      disabled_script,
      enabled = FALSE,
      skip_message = "Skipping test scripts."
    ),
    "Skipping test scripts.",
    fixed = TRUE
  )
  expect_equal(result, character())
  expect_false(file.exists(disabled_marker))
})

test_that("ejscreen_pipeline_validation_stages keeps core and optional stages ordered", {
  core <- EJAM:::ejscreen_pipeline_validation_stages(
    include_ejscreen_export = FALSE,
    include_ejscreen_export_statepct = FALSE
  )

  expect_equal(
    core[1:4],
    c("bg_acsdata", "bg_envirodata", "bg_geodata", "bg_extra_indicators")
  )
  expect_true(all(c("blockgroupstats", "bgej", "usastats", "statestats") %in% core))
  expect_false("bg_islandareas_demographics" %in% core)
  expect_false("ejscreen_export" %in% core)

  expanded <- EJAM:::ejscreen_pipeline_validation_stages(
    include_islandareas_data = TRUE,
    use_islandareas_demographics = FALSE,
    has_bg_islandareas_demographics = TRUE,
    include_ejscreen_export = TRUE,
    include_ejscreen_export_statepct = TRUE,
    include_ejscreen_pctile_lookup_exports = TRUE,
    include_ejscreen_dataset_creator_input = TRUE
  )

  expect_equal(expanded[1], "bg_islandareas_demographics")
  expect_equal(
    tail(expanded, 5),
    c(
      "ejscreen_export",
      "ejscreen_export_statepct",
      "ejscreen_us_pctile_lookup",
      "ejscreen_state_pctile_lookup",
      "ejscreen_dataset_creator_input"
    )
  )
})

test_that("ejscreen_pipeline_validation_summary writes stage validation rows", {
  loaded <- character()
  validated <- character()
  written <- NULL

  fake_load <- function(stage) {
    loaded <<- c(loaded, stage)
    if (identical(stage, "stage_one")) {
      data.frame(a = 1:2, b = 3:4)
    } else {
      data.frame(a = 1)
    }
  }
  fake_validate <- function(x, stage, strict) {
    validated <<- c(validated, paste(stage, strict))
    if (identical(stage, "stage_one")) {
      list(errors = character(), warnings = "warn one")
    } else {
      list(errors = "bad two", warnings = character())
    }
  }
  fake_path <- function(stage, pipeline_dir, format) {
    paste(pipeline_dir, stage, format, sep = "/")
  }
  fake_write <- function(x, filename, pipeline_dir, storage) {
    written <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    invisible(filename)
  }

  result <- EJAM:::ejscreen_pipeline_validation_summary(
    stages = c("stage_one", "stage_two"),
    pipeline_dir = "pipe",
    stage_format = "csv",
    pipeline_storage = "local",
    load_stage_fun = fake_load,
    validate_fun = fake_validate,
    stage_path_fun = fake_path,
    write_fun = fake_write
  )

  expect_equal(loaded, c("stage_one", "stage_two"))
  expect_equal(validated, c("stage_one FALSE", "stage_two FALSE"))
  expect_equal(result$stage, c("stage_one", "stage_two"))
  expect_equal(result$path, c("pipe/stage_one/csv", "pipe/stage_two/csv"))
  expect_equal(result$rows, c(2L, 1L))
  expect_equal(result$columns, c(2L, 1L))
  expect_equal(result$errors, c("", "bad two"))
  expect_equal(result$warnings, c("warn one", ""))
  expect_equal(written$filename, "pipeline_validation_summary.csv")
  expect_equal(written$pipeline_dir, "pipe")
  expect_equal(written$storage, "local")
})

test_that("ejscreen_pipeline_export_schema_reports writes requested schema reports", {
  schema_calls <- list()
  written <- list()
  fake_schema_report <- function(ejscreen_export, expected_output_names = NULL) {
    schema_calls[[length(schema_calls) + 1L]] <<- list(
      ejscreen_export = ejscreen_export,
      expected_output_names = expected_output_names
    )
    data.frame(
      rows = NROW(ejscreen_export),
      has_expected = !is.null(expected_output_names)
    )
  }
  fake_write <- function(x, filename, pipeline_dir, storage) {
    written[[length(written) + 1L]] <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    invisible(filename)
  }

  result <- EJAM:::ejscreen_pipeline_export_schema_reports(
    outputs = list(
      ejscreen_export = data.frame(x = 1:2),
      ejscreen_export_statepct = data.frame(y = 1:3)
    ),
    include_ejscreen_export = TRUE,
    include_ejscreen_export_statepct = TRUE,
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    schema_report_fun = fake_schema_report,
    statepct_fields_fun = function() c("STATE_FIELD"),
    write_fun = fake_write
  )

  expect_named(
    result,
    c("ejscreen_export_schema_report", "ejscreen_export_statepct_schema_report")
  )
  expect_equal(length(schema_calls), 2)
  expect_equal(NROW(schema_calls[[1]]$ejscreen_export), 2L)
  expect_null(schema_calls[[1]]$expected_output_names)
  expect_equal(NROW(schema_calls[[2]]$ejscreen_export), 3L)
  expect_equal(schema_calls[[2]]$expected_output_names, "STATE_FIELD")
  expect_equal(
    vapply(written, `[[`, character(1), "filename"),
    c("ejscreen_export_schema_report.csv", "ejscreen_export_statepct_schema_report.csv")
  )
  expect_true(all(vapply(written, `[[`, character(1), "pipeline_dir") == "pipe"))
  expect_true(all(vapply(written, `[[`, character(1), "storage") == "local"))
})

test_that("ejscreen_pipeline_dataset_creator_report writes optional report attribute", {
  written <- NULL
  report <- data.frame(field = "x", status = "ok")
  creator_input <- data.frame(x = 1)
  attr(creator_input, "ejscreen_dataset_creator_input_report") <- report
  fake_write <- function(x, filename, pipeline_dir, storage) {
    written <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    invisible(filename)
  }

  result <- EJAM:::ejscreen_pipeline_dataset_creator_report(
    outputs = list(ejscreen_dataset_creator_input = creator_input),
    include_ejscreen_dataset_creator_input = TRUE,
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    write_fun = fake_write
  )

  expect_equal(result, report)
  expect_equal(written$x, report)
  expect_equal(written$filename, "ejscreen_dataset_creator_input_report.csv")
  expect_equal(written$pipeline_dir, "pipe")
  expect_equal(written$storage, "local")

  written <- NULL
  skipped <- EJAM:::ejscreen_pipeline_dataset_creator_report(
    outputs = list(ejscreen_dataset_creator_input = creator_input),
    include_ejscreen_dataset_creator_input = FALSE,
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    write_fun = fake_write
  )
  expect_null(skipped)
  expect_null(written)
})

test_that("ejscreen_pipeline_dynamic_geography_report writes arrow validation report", {
  report <- data.frame(dataset = "blockpoints", status = "ok")
  report_calls <- list()
  written <- NULL
  fake_report <- function(blockgroupstats_ref, silent) {
    report_calls[[length(report_calls) + 1L]] <<- list(
      blockgroupstats_ref = blockgroupstats_ref,
      silent = silent
    )
    report
  }
  fake_write <- function(x, filename, pipeline_dir, storage) {
    written <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    invisible(filename)
  }

  result <- EJAM:::ejscreen_pipeline_dynamic_geography_report(
    blockgroupstats = data.frame(bgfips = "010010201001"),
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    report_fun = fake_report,
    write_fun = fake_write
  )

  expect_equal(result, report)
  expect_equal(length(report_calls), 1L)
  expect_true(report_calls[[1]]$silent)
  expect_equal(written$x, report)
  expect_equal(written$filename, "dynamic_geography_arrow_report.csv")
  expect_equal(written$pipeline_dir, "pipe")
  expect_equal(written$storage, "local")
})

test_that("ejscreen_pipeline_prior_validation_stages keeps annual comparison stages ordered", {
  expect_equal(
    EJAM:::ejscreen_pipeline_prior_validation_stages(),
    c(
      "bg_acsdata",
      "bg_envirodata",
      "bg_geodata",
      "bg_extra_indicators",
      "blockgroupstats",
      "bgej",
      "usastats",
      "statestats"
    )
  )
})

test_that("ejscreen_pipeline_prior_validation dispatches package and pipeline comparisons", {
  package_calls <- list()
  version_calls <- list()
  fake_package_validation <- function(...) {
    args <- list(...)
    package_calls[[length(package_calls) + 1L]] <<- args
    list(summary = data.frame(kind = "package"))
  }
  fake_compare_versions <- function(...) {
    args <- list(...)
    version_calls[[length(version_calls) + 1L]] <<- args
    list(summary = data.frame(kind = "versions"))
  }

  skipped <- EJAM:::ejscreen_pipeline_prior_validation(
    validate_vs_prior = FALSE,
    pipeline_yr = 2024,
    prior_pipeline_yr = "2023",
    pipeline_root = "root",
    pipeline_dir = "new-dir",
    prior_pipeline_dir = "old-dir",
    stage_format = "csv",
    pipeline_storage = "local",
    package_validation_fun = fake_package_validation,
    compare_versions_fun = fake_compare_versions
  )
  expect_null(skipped)
  expect_length(package_calls, 0)
  expect_length(version_calls, 0)

  by_package <- EJAM:::ejscreen_pipeline_prior_validation(
    validate_vs_prior = TRUE,
    prior_package_ref = "v2_32_8_001",
    prior_package_path = "data/blockgroupstats.rda",
    pipeline_yr = 2022,
    prior_pipeline_yr = "2021",
    pipeline_root = "root",
    pipeline_dir = "new-dir",
    prior_pipeline_dir = "old-dir",
    stage_format = "csv",
    pipeline_storage = "local",
    validate_vs_prior_waldo = TRUE,
    package_validation_fun = fake_package_validation,
    compare_versions_fun = fake_compare_versions
  )
  expect_equal(by_package$summary$kind, "package")
  expect_length(package_calls, 1)
  expect_equal(package_calls[[1]]$new_pipeline_dir, "new-dir")
  expect_equal(package_calls[[1]]$prior_package_ref, "v2_32_8_001")
  expect_equal(package_calls[[1]]$storage, "local")
  expect_true(package_calls[[1]]$use_waldo)
  expect_length(version_calls, 0)

  by_pipeline <- EJAM:::ejscreen_pipeline_prior_validation(
    validate_vs_prior = TRUE,
    prior_package_ref = "",
    pipeline_yr = 2024,
    prior_pipeline_yr = "2023",
    pipeline_root = "root",
    pipeline_dir = "new-dir",
    prior_pipeline_dir = "old-dir",
    stage_format = "csv",
    pipeline_storage = "local",
    validate_vs_prior_waldo = FALSE,
    package_validation_fun = fake_package_validation,
    compare_versions_fun = fake_compare_versions,
    stages_fun = function() c("stage_a", "stage_b")
  )
  expect_equal(by_pipeline$summary$kind, "versions")
  expect_length(version_calls, 1)
  expect_equal(version_calls[[1]]$new_yr, 2024)
  expect_equal(version_calls[[1]]$old_yr, "2023")
  expect_equal(version_calls[[1]]$stages, c("stage_a", "stage_b"))
  expect_equal(version_calls[[1]]$old_pipeline_dir, "old-dir")
  expect_false(version_calls[[1]]$use_waldo)
})

test_that("ejscreen_pipeline_export_reference_validations writes national and statepct comparisons", {
  report_calls <- list()
  printed <- list()
  fake_report <- function(...) {
    args <- list(...)
    report_calls[[length(report_calls) + 1L]] <<- args
    list(summary = data.frame(output_prefix = args$output_prefix))
  }
  fake_print <- function(x) {
    printed[[length(printed) + 1L]] <<- x
  }

  result <- EJAM:::ejscreen_pipeline_export_reference_validations(
    outputs = list(
      ejscreen_export = data.frame(national = 1),
      ejscreen_export_statepct = data.frame(statepct = 1)
    ),
    include_ejscreen_export = TRUE,
    include_ejscreen_export_statepct = TRUE,
    validate_ejscreen_export_reference = TRUE,
    ejscreen_export_reference_path = "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv",
    ejscreen_export_statepct_reference_path = "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv",
    pipeline_yr = 2022,
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    report_fun = fake_report,
    print_fun = fake_print
  )

  expect_named(
    result,
    c("ejscreen_export_reference_validation", "ejscreen_export_statepct_reference_validation")
  )
  expect_equal(length(report_calls), 2)
  expect_equal(report_calls[[1]]$output_prefix, "prior_validation_ejscreen_export_vs_epa_2024_acs2022")
  expect_equal(report_calls[[2]]$output_prefix, "prior_validation_ejscreen_export_statepct_vs_epa_2024_acs2022")
  expect_equal(report_calls[[1]]$reference_format, "csv")
  expect_equal(report_calls[[2]]$reference_label, "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv")
  expect_match(report_calls[[1]]$note, "ACS 2022", fixed = TRUE)
  expect_match(report_calls[[2]]$note, "StatePct-style export", fixed = TRUE)
  expect_equal(report_calls[[1]]$storage, "local")
  expect_equal(report_calls[[2]]$output_dir, "pipe")
  expect_true(report_calls[[1]]$write_files)
  expect_equal(length(printed), 2)
})

test_that("ejscreen_pipeline validation status helpers detect error rows", {
  validation_summary <- data.frame(
    stage = c("ok", "missing", "bad"),
    errors = c("", NA_character_, "problem")
  )

  expect_equal(
    EJAM:::ejscreen_pipeline_validation_error_index(validation_summary),
    c(FALSE, FALSE, TRUE)
  )
  expect_true(EJAM:::ejscreen_pipeline_validation_has_errors(validation_summary))
  expect_equal(EJAM:::ejscreen_pipeline_manifest_status(validation_summary), "validation_failed")

  validation_summary$errors <- c("", NA_character_, "")
  expect_false(EJAM:::ejscreen_pipeline_validation_has_errors(validation_summary))
  expect_equal(EJAM:::ejscreen_pipeline_manifest_status(validation_summary), "completed")
  expect_error(
    EJAM:::ejscreen_pipeline_validation_error_index(data.frame(stage = "ok")),
    "validation_summary must include an errors column",
    fixed = TRUE
  )
})

test_that("ejscreen_pipeline_finalize_run writes manifest and enforces validation errors", {
  validation_summary <- data.frame(
    stage = c("bg_acsdata", "blockgroupstats"),
    rows = c(2L, 3L),
    columns = c(4L, 5L),
    warnings = c("", "minor"),
    errors = c("", NA_character_)
  )
  manifest_calls <- list()
  printed <- list()
  messages <- character()
  fake_manifest <- function(...) {
    args <- list(...)
    manifest_calls[[length(manifest_calls) + 1L]] <<- args
    "pipeline_run_manifest.json"
  }
  fake_print <- function(x) {
    printed[[length(printed) + 1L]] <<- x
  }
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }
  fake_now <- function() {
    as.POSIXct("2026-05-30 12:34:56", tz = "UTC")
  }

  result <- EJAM:::ejscreen_pipeline_finalize_run(
    validation_summary = validation_summary,
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    pipeline_yr = 2024,
    stage_format = "csv",
    settings = c(EJAM_PIPELINE_YR = "2024"),
    provisional_inputs = c(bg_envirodata = FALSE),
    run_started_at = as.POSIXct("2026-05-30 12:00:00", tz = "UTC"),
    write_manifest_fun = fake_manifest,
    print_fun = fake_print,
    message_fun = fake_message,
    now_fun = fake_now
  )

  expect_named(result, c("manifest_path", "status"))
  expect_equal(result$status, "completed")
  expect_equal(result$manifest_path, "pipeline_run_manifest.json")
  expect_length(manifest_calls, 1)
  expect_equal(manifest_calls[[1]]$status, "completed")
  expect_equal(manifest_calls[[1]]$pipeline_dir, "pipe")
  expect_equal(manifest_calls[[1]]$settings, c(EJAM_PIPELINE_YR = "2024"))
  expect_equal(manifest_calls[[1]]$provisional_inputs, c(bg_envirodata = FALSE))
  expect_equal(length(printed), 2)
  expect_equal(names(printed[[1]]), c("stage", "rows", "columns", "warnings"))
  expect_true(any(grepl("Pipeline run manifest: pipeline_run_manifest.json", messages, fixed = TRUE)))
  expect_true(any(grepl("Output folder: pipe", messages, fixed = TRUE)))

  validation_summary$errors <- c("", "bad")
  expect_error(
    EJAM:::ejscreen_pipeline_finalize_run(
      validation_summary = validation_summary,
      pipeline_dir = "pipe",
      pipeline_storage = "local",
      pipeline_yr = 2024,
      stage_format = "csv",
      settings = character(),
      provisional_inputs = character(),
      run_started_at = as.POSIXct("2026-05-30 12:00:00", tz = "UTC"),
      write_manifest_fun = fake_manifest,
      print_fun = fake_print,
      message_fun = fake_message,
      now_fun = fake_now
    ),
    "Pipeline validation errors found. See pipeline_validation_summary file",
    fixed = TRUE
  )
  expect_equal(manifest_calls[[2]]$status, "validation_failed")
})

test_that("ejscreen_pipeline_replace_package_data is explicit and saves bgej artifacts", {
  outputs <- list(
    blockgroupstats = data.frame(bgfips = "1"),
    usastats = data.frame(pctile = 1),
    statestats = data.frame(ST = "CA"),
    bgej = data.frame(bgfips = "1", D2_PM25 = 2)
  )
  metadata_calls <- character()
  save_calls <- list()
  messages <- character()
  fake_metadata <- function(objectname) {
    metadata_calls <<- c(metadata_calls, objectname)
    TRUE
  }
  fake_save <- function(...) {
    args <- list(...)
    save_calls[[length(save_calls) + 1L]] <<- args
    paste0(args$stage, ".", args$format)
  }
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  skipped <- EJAM:::ejscreen_pipeline_replace_package_data(
    outputs = outputs,
    replace_package_data = FALSE,
    pipeline_dir = "pipe",
    pipeline_yr = 2024,
    interactive_fun = function() FALSE,
    ask_fun = function(...) stop("should not ask"),
    metadata_fun = fake_metadata,
    save_fun = fake_save,
    message_fun = fake_message
  )

  expect_false(skipped$replaced)
  expect_equal(metadata_calls, character())
  expect_equal(length(save_calls), 0)
  expect_true(any(grepl("Skipping package-data replacement", messages, fixed = TRUE)))

  replaced <- EJAM:::ejscreen_pipeline_replace_package_data(
    outputs = outputs,
    replace_package_data = TRUE,
    pipeline_dir = "pipe",
    pipeline_yr = 2024,
    interactive_fun = function() FALSE,
    ask_fun = function(...) stop("should not ask"),
    metadata_fun = fake_metadata,
    save_fun = fake_save,
    message_fun = fake_message
  )

  expect_true(replaced$replaced)
  expect_equal(
    metadata_calls,
    c("blockgroupstats", "usastats", "statestats")
  )
  expect_equal(vapply(save_calls, `[[`, character(1), "format"), c("rda", "arrow"))
  expect_equal(vapply(save_calls, `[[`, character(1), "stage"), c("bgej", "bgej"))
  expect_equal(save_calls[[1]]$pipeline_dir, "pipe")
  expect_equal(save_calls[[2]]$storage, "s3")
  expect_equal(save_calls[[2]]$yr, 2024)
})

test_that("ejscreen_pipeline_save_stage_formats saves requested formats and secondary stages", {
  save_calls <- list()
  fake_save <- function(...) {
    args <- list(...)
    save_calls[[length(save_calls) + 1L]] <<- args
    paste0(args$pipeline_dir, "/", args$stage, ".", args$format)
  }

  paths <- EJAM:::ejscreen_pipeline_save_stage_formats(
    x = data.frame(a = 1),
    stage = "bg_acsdata",
    formats = c("csv", "rda"),
    object_name = "custom_object",
    validate = FALSE,
    pipeline_dir = "pipe",
    pipeline_yr = 2024,
    storage = "local",
    save_fun = fake_save
  )

  expect_equal(paths, c(csv = "pipe/bg_acsdata.csv", rda = "pipe/bg_acsdata.rda"))
  expect_equal(vapply(save_calls, `[[`, character(1), "format"), c("csv", "rda"))
  expect_equal(save_calls[[1]]$object_name, "custom_object")
  expect_false(save_calls[[1]]$validate)
  expect_true(save_calls[[2]]$overwrite)
  expect_equal(save_calls[[2]]$yr, 2024)
  expect_equal(save_calls[[2]]$storage, "local")

  empty <- EJAM:::ejscreen_pipeline_save_stage_formats(
    x = NULL,
    stage = "missing",
    formats = c("csv", "rda"),
    pipeline_dir = "pipe",
    pipeline_yr = 2024,
    storage = "local",
    save_fun = fake_save
  )
  expect_equal(empty, stats::setNames(character(), character()))

  save_calls <- list()
  secondary <- EJAM:::ejscreen_pipeline_save_secondary_stage_formats(
    outputs = list(stage_a = data.frame(a = 1), stage_b = data.frame(b = 2)),
    stages = c("stage_a", "missing"),
    stage_formats = c("csv", "rda", "arrow"),
    primary_format = "csv",
    pipeline_dir = "pipe",
    pipeline_yr = 2024,
    storage = "s3",
    save_fun = fake_save
  )

  expect_named(secondary, "stage_a")
  expect_equal(secondary$stage_a, c(rda = "pipe/stage_a.rda", arrow = "pipe/stage_a.arrow"))
  expect_equal(vapply(save_calls, `[[`, character(1), "format"), c("rda", "arrow"))
  expect_equal(vapply(save_calls, `[[`, character(1), "stage"), c("stage_a", "stage_a"))
})

test_that("ejscreen_pipeline_write_text delegates to the pipeline writer", {
  write_call <- NULL
  fake_write <- function(x, filename, pipeline_dir, storage) {
    write_call <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    file.path(pipeline_dir, filename)
  }

  path <- EJAM:::ejscreen_pipeline_write_text(
    lines = c("one", "two"),
    filename = "note.txt",
    pipeline_dir = "pipe",
    storage = "local",
    write_fun = fake_write
  )

  expect_equal(path, "pipe/note.txt")
  expect_equal(write_call$x, c("one", "two"))
  expect_equal(write_call$filename, "note.txt")
  expect_equal(write_call$pipeline_dir, "pipe")
  expect_equal(write_call$storage, "local")
})

test_that("ejscreen_pipeline_reusable_blockgroupstats chooses same-vintage fallback data", {
  target_acs <- "ACS 2020-2024"
  old_acs <- "ACS 2019-2023"
  current <- data.frame(id = 1L)
  current_old <- data.frame(id = 10L)
  prior_data <- data.frame(id = 2L)
  detect_current <- function(x) attr(x, "acs_version", exact = TRUE)
  acs_version <- function(yr) target_acs
  warnings <- character()
  fake_warning <- function(..., call. = TRUE) {
    warnings <<- c(warnings, paste0(...))
  }

  attr(current, "acs_version") <- target_acs
  result_current <- EJAM:::ejscreen_pipeline_reusable_blockgroupstats(
    pipeline_yr = 2024,
    prior_package_ref = "",
    prior_package_path = "data/blockgroupstats.rda",
    current_blockgroupstats = current,
    detect_acs_version_fun = detect_current,
    acs_version_fun = acs_version,
    load_git_data_fun = function(...) stop("should not load prior ref"),
    warning_fun = fake_warning
  )
  expect_s3_class(result_current, "data.table")
  expect_equal(result_current$id, 1L)
  expect_equal(warnings, character())

  attr(current_old, "acs_version") <- old_acs
  result_prior <- EJAM:::ejscreen_pipeline_reusable_blockgroupstats(
    pipeline_yr = 2024,
    prior_package_ref = "v2.5.0",
    prior_package_path = "data/blockgroupstats.rda",
    current_blockgroupstats = current_old,
    detect_acs_version_fun = detect_current,
    acs_version_fun = acs_version,
    load_git_data_fun = function(ref, path) {
      list(data = prior_data, acs_version = target_acs)
    },
    warning_fun = fake_warning
  )
  expect_equal(result_prior$id, 2L)
  expect_equal(warnings, character())

  result_fallback <- EJAM:::ejscreen_pipeline_reusable_blockgroupstats(
    pipeline_yr = 2024,
    prior_package_ref = "v2.5.0",
    prior_package_path = "data/blockgroupstats.rda",
    current_blockgroupstats = current_old,
    detect_acs_version_fun = detect_current,
    acs_version_fun = acs_version,
    load_git_data_fun = function(ref, path) {
      list(data = prior_data, acs_version = old_acs)
    },
    warning_fun = fake_warning
  )
  expect_equal(result_fallback$id, 10L)
  expect_true(any(grepl("Prior package blockgroupstats ACS version", warnings, fixed = TRUE)))
  expect_true(any(grepl("Using currently packaged EJAM::blockgroupstats", warnings, fixed = TRUE)))
})

test_that("ejscreen_pipeline_stage_io builds bound stage helpers and caches fallback data", {
  load_call <- NULL
  exists_call <- NULL
  save_call <- NULL
  secondary_call <- NULL
  reuse_calls <- 0L
  io <- EJAM:::ejscreen_pipeline_stage_io(
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_formats = c("csv", "rda"),
    pipeline_yr = 2024,
    storage = "local",
    prior_package_ref = "v2.5.0",
    prior_package_path = "data/blockgroupstats.rda",
    load_fun = function(stage, pipeline_dir, format, storage) {
      load_call <<- list(
        stage = stage,
        pipeline_dir = pipeline_dir,
        format = format,
        storage = storage
      )
      data.frame(stage = stage)
    },
    stage_exists_fun = function(stage, pipeline_dir, format, storage) {
      exists_call <<- list(
        stage = stage,
        pipeline_dir = pipeline_dir,
        format = format,
        storage = storage
      )
      TRUE
    },
    save_stage_formats_fun = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    },
    save_secondary_stage_formats_fun = function(...) {
      secondary_call <<- list(...)
      list(stage_a = c(rda = "stage_a.rda"))
    },
    reusable_blockgroupstats_fun = function(...) {
      reuse_calls <<- reuse_calls + 1L
      data.frame(bgfips = "1")
    }
  )

  expect_named(
    io,
    c(
      "load_stage",
      "stage_exists",
      "save_stage_formats",
      "save_secondary_stage_formats",
      "get_reuse_blockgroupstats"
    )
  )
  expect_equal(io$load_stage("bg_acsdata")$stage, "bg_acsdata")
  expect_equal(load_call, list(stage = "bg_acsdata", pipeline_dir = "pipe", format = "csv", storage = "local"))
  expect_true(io$stage_exists("bg_envirodata"))
  expect_equal(exists_call$format, "csv")
  io$save_stage_formats(data.frame(a = 1), stage = "stage_a", validate = FALSE)
  expect_equal(save_call$stage, "stage_a")
  expect_equal(save_call$formats, c("csv", "rda"))
  expect_false(save_call$validate)
  io$save_secondary_stage_formats(list(stage_a = data.frame(a = 1)), stages = "stage_a")
  expect_equal(secondary_call$primary_format, "csv")
  expect_equal(io$get_reuse_blockgroupstats()$bgfips, "1")
  expect_equal(io$get_reuse_blockgroupstats()$bgfips, "1")
  expect_equal(reuse_calls, 1L)
})

test_that("ejscreen_pipeline_stage_bg_acs_raw skips, loads, or downloads as needed", {
  messages <- character()
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  stage_io_skip <- list(
    stage_exists = function(stage) identical(stage, "bg_acsdata"),
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) stop("should not save")
  )
  skipped <- EJAM:::ejscreen_pipeline_stage_bg_acs_raw(
    yr = 2024,
    force_acs = FALSE,
    force_bg_acsdata = FALSE,
    include_islandareas_data = FALSE,
    stage_io = stage_io_skip,
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "local",
    acs_download_timeout = 1,
    acs_download_retries = 0,
    download_fun = function(...) stop("should not download"),
    message_fun = fake_message
  )
  expect_false(skipped$need_bg_acsdata)
  expect_false(skipped$need_bg_acs_raw)
  expect_null(skipped$bg_acs_raw)
  expect_true(any(grepl("Skipping bg_acs_raw", messages, fixed = TRUE)))

  load_calls <- character()
  save_calls <- list()
  stage_io_load <- list(
    stage_exists = function(stage) TRUE,
    load_stage = function(stage) {
      load_calls <<- c(load_calls, stage)
      data.frame(raw = 1)
    },
    save_stage_formats = function(...) {
      save_calls[[length(save_calls) + 1L]] <<- list(...)
      c(rda = "saved.rda")
    }
  )
  loaded <- EJAM:::ejscreen_pipeline_stage_bg_acs_raw(
    yr = 2024,
    force_acs = FALSE,
    force_bg_acsdata = TRUE,
    include_islandareas_data = FALSE,
    stage_io = stage_io_load,
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "local",
    acs_download_timeout = 1,
    acs_download_retries = 0,
    download_fun = function(...) stop("should not download"),
    message_fun = fake_message
  )
  expect_true(loaded$need_bg_acsdata)
  expect_equal(loaded$bg_acs_raw$raw, 1)
  expect_equal(load_calls, "bg_acs_raw")
  expect_equal(save_calls[[1]]$formats, "rda")
  expect_false(save_calls[[1]]$validate)

  download_call <- NULL
  stage_io_download <- list(
    stage_exists = function(stage) FALSE,
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) {
      save_calls[[length(save_calls) + 1L]] <<- list(...)
      c(rda = "saved.rda")
    }
  )
  downloaded <- EJAM:::ejscreen_pipeline_stage_bg_acs_raw(
    yr = 2024,
    force_acs = TRUE,
    force_bg_acsdata = FALSE,
    include_islandareas_data = FALSE,
    stage_io = stage_io_download,
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "s3",
    acs_download_timeout = 3600,
    acs_download_retries = 2,
    download_fun = function(...) {
      download_call <<- list(...)
      data.frame(raw = 2)
    },
    message_fun = fake_message
  )
  expect_equal(downloaded$bg_acs_raw$raw, 2)
  expect_equal(download_call$yr, 2024)
  expect_equal(download_call$pipeline_dir, "pipe")
  expect_equal(download_call$storage, "s3")
  expect_true(download_call$save_stage)
  expect_equal(download_call$download_timeout, 3600)
  expect_equal(download_call$download_retries, 2)
})

test_that("ejscreen_pipeline_prepare_islandareas loads reference or optional demographics", {
  messages <- character()
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  stage_io_none <- list(
    stage_exists = function(stage) stop("should not check stages"),
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) stop("should not save")
  )
  skipped <- EJAM:::ejscreen_pipeline_prepare_islandareas(
    include_islandareas_data = FALSE,
    need_bg_acsdata = TRUE,
    use_islandareas_demographics = FALSE,
    force_acs = FALSE,
    stage_io = stage_io_none,
    islandareas_reference_path = "ref.csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "local",
    load_reference_fun = function(...) stop("should not load reference"),
    download_raw_fun = function(...) stop("should not download"),
    calc_demographics_fun = function(...) stop("should not calculate"),
    message_fun = fake_message
  )
  expect_null(skipped$bg_islandareas_raw)
  expect_null(skipped$bg_islandareas_demographics)
  expect_null(skipped$bg_islandareas_reference)

  reference_call <- NULL
  reference <- EJAM:::ejscreen_pipeline_prepare_islandareas(
    include_islandareas_data = TRUE,
    need_bg_acsdata = TRUE,
    use_islandareas_demographics = FALSE,
    force_acs = FALSE,
    stage_io = stage_io_none,
    islandareas_reference_path = "ref.csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "s3",
    load_reference_fun = function(...) {
      reference_call <<- list(...)
      data.frame(bgfips = "780309611001")
    },
    download_raw_fun = function(...) stop("should not download"),
    calc_demographics_fun = function(...) stop("should not calculate"),
    message_fun = fake_message
  )
  expect_equal(reference$bg_islandareas_reference$bgfips, "780309611001")
  expect_equal(reference_call$path, "ref.csv")
  expect_equal(reference_call$storage, "s3")

  load_calls <- character()
  save_calls <- list()
  stage_io_demographics <- list(
    stage_exists = function(stage) identical(stage, "bg_islandareas_demographics"),
    load_stage = function(stage) {
      load_calls <<- c(load_calls, stage)
      data.frame(bgfips = "660109501001")
    },
    save_stage_formats = function(...) {
      save_calls[[length(save_calls) + 1L]] <<- list(...)
      c(csv = "saved.csv")
    }
  )
  demographics <- EJAM:::ejscreen_pipeline_prepare_islandareas(
    include_islandareas_data = TRUE,
    need_bg_acsdata = TRUE,
    use_islandareas_demographics = TRUE,
    force_acs = FALSE,
    stage_io = stage_io_demographics,
    islandareas_reference_path = "ref.csv",
    stage_formats = c("csv", "rda"),
    pipeline_storage = "local",
    load_reference_fun = function(...) stop("should not load reference"),
    download_raw_fun = function(...) stop("should not download"),
    calc_demographics_fun = function(...) stop("should not calculate"),
    message_fun = fake_message
  )
  expect_equal(demographics$bg_islandareas_demographics$bgfips, "660109501001")
  expect_equal(load_calls, "bg_islandareas_demographics")
  expect_equal(save_calls[[1]]$stage, "bg_islandareas_demographics")

  download_calls <- 0L
  calc_input <- NULL
  stage_io_download <- list(
    stage_exists = function(stage) FALSE,
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) {
      save_calls[[length(save_calls) + 1L]] <<- list(...)
      c(rda = "saved.rda")
    }
  )
  created <- EJAM:::ejscreen_pipeline_prepare_islandareas(
    include_islandareas_data = TRUE,
    need_bg_acsdata = TRUE,
    use_islandareas_demographics = TRUE,
    force_acs = TRUE,
    stage_io = stage_io_download,
    islandareas_reference_path = "ref.csv",
    stage_formats = c("csv", "rda", "arrow"),
    pipeline_storage = "local",
    load_reference_fun = function(...) stop("should not load reference"),
    download_raw_fun = function(...) {
      download_calls <<- download_calls + 1L
      list(raw = "islandareas")
    },
    calc_demographics_fun = function(x) {
      calc_input <<- x
      data.frame(bgfips = "690851001001")
    },
    message_fun = fake_message
  )
  expect_equal(download_calls, 1L)
  expect_equal(calc_input$raw, "islandareas")
  expect_equal(created$bg_islandareas_demographics$bgfips, "690851001001")
  expect_equal(save_calls[[2]]$stage, "bg_islandareas_raw")
  expect_equal(save_calls[[2]]$formats, "rda")
  expect_equal(save_calls[[3]]$stage, "bg_islandareas_demographics")
  expect_equal(save_calls[[3]]$formats, c("csv", "rda", "arrow"))
})

test_that("ejscreen_pipeline_stage_bg_acsdata creates or loads the stage", {
  messages <- character()
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  calc_call <- NULL
  save_call <- NULL
  stage_io_create <- list(
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    }
  )
  created <- EJAM:::ejscreen_pipeline_stage_bg_acsdata(
    yr = 2024,
    need_bg_acsdata = TRUE,
    bg_acs_raw = list(raw = "acs"),
    bg_islandareas_raw = list(raw = "ia"),
    bg_islandareas_demographics = data.frame(bgfips = "660109501001"),
    bg_islandareas_reference = data.frame(bgfips = "780309611001"),
    include_islandareas_data = TRUE,
    use_islandareas_demographics = FALSE,
    tract_weight_source = "decennial2020",
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_io = stage_io_create,
    calc_fun = function(...) {
      calc_call <<- list(...)
      data.frame(bgfips = "010010201001")
    },
    message_fun = fake_message
  )
  expect_equal(created$bgfips, "010010201001")
  expect_equal(calc_call$yr, 2024)
  expect_equal(calc_call$acs_raw$raw, "acs")
  expect_true(calc_call$include_islandareas_data)
  expect_false(calc_call$use_islandareas_demographics)
  expect_equal(calc_call$tract_weight_source, "decennial2020")
  expect_false(calc_call$save_stage)
  expect_equal(save_call$stage, "bg_acsdata")

  load_calls <- character()
  stage_io_load <- list(
    load_stage = function(stage) {
      load_calls <<- c(load_calls, stage)
      data.frame(bgfips = "020200001001")
    },
    save_stage_formats = function(...) stop("should not save")
  )
  loaded <- EJAM:::ejscreen_pipeline_stage_bg_acsdata(
    yr = 2024,
    need_bg_acsdata = FALSE,
    bg_acs_raw = NULL,
    bg_islandareas_raw = NULL,
    bg_islandareas_demographics = NULL,
    bg_islandareas_reference = NULL,
    include_islandareas_data = FALSE,
    use_islandareas_demographics = FALSE,
    tract_weight_source = "decennial2020",
    pipeline_dir = "pipe",
    stage_format = "csv",
    stage_io = stage_io_load,
    calc_fun = function(...) stop("should not calculate"),
    message_fun = fake_message
  )
  expect_equal(loaded$bgfips, "020200001001")
  expect_equal(load_calls, "bg_acsdata")
})

test_that("ejscreen_pipeline_stage_bg_envirodata loads, builds provisional data, and applies additions", {
  messages <- character()
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  save_call <- NULL
  stage_io_existing <- list(
    stage_exists = function(stage) identical(stage, "bg_envirodata"),
    load_stage = function(stage) data.frame(bgfips = "010010201001", drinking = 1),
    save_stage_formats = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    },
    get_reuse_blockgroupstats = function() stop("should not reuse")
  )
  existing <- EJAM:::ejscreen_pipeline_stage_bg_envirodata(
    pipeline_yr = 2024,
    use_provisional_bg_envirodata = FALSE,
    stage_io = stage_io_existing,
    stage_format = "csv",
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    include_islandareas_data = FALSE,
    names_e = "drinking",
    message_fun = fake_message
  )
  expect_equal(existing$bg_envirodata$drinking, 1)
  expect_false(existing$used_provisional_bg_envirodata)
  expect_equal(save_call$stage, "bg_envirodata")

  stage_io_missing <- list(
    stage_exists = function(stage) FALSE,
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) stop("should not save"),
    get_reuse_blockgroupstats = function() stop("should not reuse")
  )
  expect_error(
    EJAM:::ejscreen_pipeline_stage_bg_envirodata(
      pipeline_yr = 2024,
      use_provisional_bg_envirodata = FALSE,
      stage_io = stage_io_missing,
      stage_format = "csv",
      pipeline_dir = "pipe",
      pipeline_storage = "local",
      include_islandareas_data = FALSE,
      names_e = "drinking",
      message_fun = fake_message
    ),
    "Missing bg_envirodata file"
  )

  write_calls <- list()
  load_reference_call <- NULL
  adjustment_call <- NULL
  islandareas_loaded <- NULL
  merge_call <- NULL
  stage_io_provisional <- list(
    stage_exists = function(stage) FALSE,
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    },
    get_reuse_blockgroupstats = function() {
      data.frame(
        bgfips = "010010201001",
        drinking = 0,
        npl = 2,
        unrelated = 10
      )
    }
  )
  provisional <- EJAM:::ejscreen_pipeline_stage_bg_envirodata(
    pipeline_yr = 2024,
    use_provisional_bg_envirodata = TRUE,
    stage_io = stage_io_provisional,
    stage_format = "csv",
    pipeline_dir = "pipe",
    pipeline_storage = "s3",
    bg_envirodata_reference_path = "reference.csv",
    bg_envirodata_reference_vars = "drinking",
    include_islandareas_data = TRUE,
    bg_islandareas_reference = NULL,
    islandareas_reference_path = "island-ref.csv",
    names_e = c("drinking", "npl"),
    detect_acs_version_fun = function(x) "ACS 2020-2024",
    acs_version_fun = function(yr) "ACS 2020-2024",
    load_stage_fun = function(...) {
      load_reference_call <<- list(...)
      data.frame(bgfips = "010010201001", drinking = 3)
    },
    adjust_fun = function(bg_envirodata, reference, vars) {
      adjustment_call <<- list(bg_envirodata = bg_envirodata, reference = reference, vars = vars)
      bg_envirodata$drinking <- reference$drinking
      attr(bg_envirodata, "ejscreen_reference_adjustment") <- data.frame(var = vars)
      bg_envirodata
    },
    load_islandareas_reference_fun = function(...) {
      islandareas_loaded <<- list(...)
      data.frame(bgfips = "780309611001", drinking = 4, npl = 5)
    },
    islandareas_envirodata_fun = function(reference) reference,
    merge_fun = function(x, islandareas_data) {
      merge_call <<- list(x = x, islandareas_data = islandareas_data)
      rbind(x, islandareas_data)
    },
    write_text_fun = function(lines, filename, pipeline_dir, storage) {
      write_calls[[length(write_calls) + 1L]] <<- list(
        lines = lines,
        filename = filename,
        pipeline_dir = pipeline_dir,
        storage = storage
      )
      filename
    },
    capture_output_fun = function(expr) "adjustment summary",
    message_fun = fake_message
  )
  expect_true(provisional$used_provisional_bg_envirodata)
  expect_equal(provisional$bg_envirodata$bgfips, c("010010201001", "780309611001"))
  expect_equal(provisional$bg_envirodata$drinking, c(3, 4))
  expect_equal(load_reference_call$path, "reference.csv")
  expect_equal(load_reference_call$format, "csv")
  expect_equal(adjustment_call$vars, "drinking")
  expect_equal(islandareas_loaded$path, "island-ref.csv")
  expect_equal(merge_call$islandareas_data$bgfips, "780309611001")
  expect_equal(save_call$stage, "bg_envirodata")
  expect_equal(vapply(write_calls, `[[`, character(1), "filename"),
               c("bg_envirodata_SOURCE.txt", "bg_envirodata_REFERENCE_ADJUSTMENT.txt"))
})

test_that("ejscreen_pipeline_stage_bg_extra_indicators loads or builds from fallback", {
  messages <- character()
  fake_message <- function(...) {
    messages <<- c(messages, paste0(...))
  }

  save_call <- NULL
  stage_io_existing <- list(
    stage_exists = function(stage) identical(stage, "bg_extra_indicators"),
    load_stage = function(stage) data.frame(bgfips = "010010201001", extra = 1),
    save_stage_formats = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    },
    get_reuse_blockgroupstats = function() stop("should not reuse")
  )
  existing <- EJAM:::ejscreen_pipeline_stage_bg_extra_indicators(
    pipeline_yr = 2024,
    stage_io = stage_io_existing,
    stage_format = "csv",
    pipeline_dir = "pipe",
    pipeline_storage = "local",
    message_fun = fake_message
  )
  expect_equal(existing$bg_extra_indicators$extra, 1)
  expect_false(existing$used_provisional_bg_extra_indicators)
  expect_equal(save_call$stage, "bg_extra_indicators")

  calc_call <- NULL
  write_call <- NULL
  stage_io_fallback <- list(
    stage_exists = function(stage) FALSE,
    load_stage = function(stage) stop("should not load"),
    save_stage_formats = function(...) {
      save_call <<- list(...)
      c(csv = "saved.csv")
    },
    get_reuse_blockgroupstats = function() data.frame(bgfips = "010010201001", extra = 2)
  )
  fallback <- EJAM:::ejscreen_pipeline_stage_bg_extra_indicators(
    pipeline_yr = 2024,
    stage_io = stage_io_fallback,
    stage_format = "csv",
    pipeline_dir = "pipe",
    pipeline_storage = "s3",
    detect_acs_version_fun = function(x) "ACS 2020-2024",
    acs_version_fun = function(yr) "ACS 2020-2024",
    calc_fun = function(...) {
      calc_call <<- list(...)
      data.frame(bgfips = "010010201001", extra = 3)
    },
    write_text_fun = function(lines, filename, pipeline_dir, storage) {
      write_call <<- list(
        lines = lines,
        filename = filename,
        pipeline_dir = pipeline_dir,
        storage = storage
      )
      filename
    },
    message_fun = fake_message
  )
  expect_true(fallback$used_provisional_bg_extra_indicators)
  expect_equal(fallback$bg_extra_indicators$extra, 3)
  expect_true(calc_call$reuse_existing_if_missing)
  expect_false(calc_call$save_stage)
  expect_equal(calc_call$stage_format, "csv")
  expect_equal(save_call$stage, "bg_extra_indicators")
  expect_equal(write_call$filename, "bg_extra_indicators_SOURCE.txt")
  expect_equal(write_call$storage, "s3")
})

test_that("ejscreen_pipeline_compare_prior_package_stages builds expected git comparisons", {
  calls <- list()
  fake_compare <- function(...) {
    args <- list(...)
    calls[[length(calls) + 1L]] <<- args
    list(
      summary = data.frame(
        stage = args$stage,
        new_stage = args$new_stage,
        git_path = args$git_path,
        shared_only = args$shared_only
      )
    )
  }

  result <- EJAM:::ejscreen_pipeline_compare_prior_package_stages(
    new_pipeline_dir = "new-dir",
    prior_package_ref = "v2_32_8_001",
    prior_package_path = "data/blockgroupstats.rda",
    format = "csv",
    storage = "local",
    output_dir = "out-dir",
    write_files = FALSE,
    use_waldo = TRUE,
    compare_fun = fake_compare
  )

  expect_named(
    result,
    c(
      "bg_acsdata_vs_prior_package_blockgroupstats",
      "blockgroupstats_vs_prior_package_blockgroupstats",
      "usastats_vs_prior_package_usastats",
      "statestats_vs_prior_package_statestats"
    )
  )
  expect_length(calls, 4)
  expect_equal(calls[[1]]$stage, "bg_acsdata_vs_v2_32_8_001_blockgroupstats")
  expect_equal(calls[[1]]$new_stage, "bg_acsdata")
  expect_true(calls[[1]]$shared_only)
  expect_equal(calls[[2]]$new_stage, "blockgroupstats")
  expect_false(calls[[2]]$shared_only)
  expect_equal(calls[[3]]$git_path, "data/usastats.rda")
  expect_equal(calls[[4]]$stage, "statestats_vs_v2_32_8_001_statestats")
  expect_equal(calls[[4]]$use_waldo, TRUE)
})

test_that("ejscreen_pipeline_prior_package_validation writes summary and metadata", {
  written <- NULL
  fake_compare <- function(...) {
    args <- list(...)
    list(
      summary = data.frame(
        stage = args$stage,
        new_stage = args$new_stage
      )
    )
  }
  fake_write <- function(x, filename, pipeline_dir, storage) {
    written <<- list(
      x = x,
      filename = filename,
      pipeline_dir = pipeline_dir,
      storage = storage
    )
    invisible(filename)
  }

  result <- EJAM:::ejscreen_pipeline_prior_package_validation(
    new_pipeline_dir = "new-dir",
    prior_package_ref = "v2_32_8_001",
    prior_package_path = "data/blockgroupstats.rda",
    format = "csv",
    storage = "local",
    output_dir = "out-dir",
    write_files = TRUE,
    use_waldo = FALSE,
    compare_fun = fake_compare,
    write_fun = fake_write
  )

  expect_named(
    result,
    c("summary", "comparisons", "new_pipeline_dir", "old_git_ref", "old_git_path", "output_dir")
  )
  expect_equal(nrow(result$summary), 4)
  expect_equal(result$new_pipeline_dir, "new-dir")
  expect_equal(result$old_git_ref, "v2_32_8_001")
  expect_equal(result$old_git_path, "data/blockgroupstats.rda")
  expect_equal(written$filename, "prior_validation_summary.csv")
  expect_equal(written$pipeline_dir, "out-dir")
  expect_equal(written$storage, "local")
  expect_equal(nrow(written$x), 4)
})

test_that("ejscreen_pipeline_prior_validation_print_columns keeps available display columns ordered", {
  prior_validation_summary <- data.frame(
    error = "",
    stage = "blockgroupstats",
    ignored = TRUE,
    rows_new = 1L,
    not_replicated_n = 0L
  )

  expect_equal(
    EJAM:::ejscreen_pipeline_prior_validation_print_columns(prior_validation_summary),
    c("stage", "rows_new", "not_replicated_n", "error")
  )
})

test_that("recipe runner scripts exist and point to expected config recipes", {
  repo_root <- normalizePath(file.path(getwd(), "..", ".."), mustWork = FALSE)
  if (!file.exists(file.path(repo_root, "DESCRIPTION"))) {
    repo_root <- getwd()
  }
  script_rel <- c(
    annual = "data-raw/run_ejscreen_pipeline_annual.R",
    release = "data-raw/run_ejscreen_pipeline_release.R",
    validation_only = "data-raw/run_ejscreen_pipeline_validation_only.R",
    exports_only = "data-raw/run_ejscreen_pipeline_exports_only.R"
  )
  scripts <- file.path(repo_root, script_rel)
  names(scripts) <- names(script_rel)

  expect_true(all(file.exists(scripts)))
  for (script in scripts) {
    expect_silent(parse(script))
  }

  validation_lines <- readLines(scripts[["validation_only"]], warn = FALSE)
  exports_lines <- readLines(scripts[["exports_only"]], warn = FALSE)
  annual_lines <- readLines(scripts[["annual"]], warn = FALSE)
  release_lines <- readLines(scripts[["release"]], warn = FALSE)

  expect_true(any(grepl("pipeline_config_annual", annual_lines, fixed = TRUE)))
  expect_true(any(grepl("pipeline_config_release", release_lines, fixed = TRUE)))
  expect_true(any(grepl("pipeline_config_validation_only", validation_lines, fixed = TRUE)))
  expect_true(any(grepl("pipeline_config_exports_only", exports_lines, fixed = TRUE)))
  expect_true(any(grepl("ejscreen_pipeline_run_recipe_script", annual_lines, fixed = TRUE)))
  expect_true(any(grepl("ejscreen_pipeline_run_recipe_script", release_lines, fixed = TRUE)))
  expect_true(any(grepl("ejscreen_pipeline_run_recipe_script", validation_lines, fixed = TRUE)))
  expect_true(any(grepl("ejscreen_pipeline_run_recipe_script", exports_lines, fixed = TRUE)))
})
