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
