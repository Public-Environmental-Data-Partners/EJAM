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
