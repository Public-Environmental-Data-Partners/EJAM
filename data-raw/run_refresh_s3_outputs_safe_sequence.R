# Safe S3 refresh sequence for ACS2022 replication and annual pipeline outputs
#
# Purpose:
#   Show the exact settings and commands planned for refreshing S3 pipeline
#   outputs after the current ACS2024 code changes.
#
# This file is intentionally not auto-running anything. Source this file, then
# call one step at a time after reviewing the settings below.
#
# Recommended order:
#   1. run_pipeline_2022()
#   2. run_acs22_replication()
#   3. run_pipeline_2023()
#   4. run_pipeline_2024()
#
# Time-saving option:
#   After run_pipeline_2022() finishes, run_acs22_replication() and
#   run_pipeline_2023() in separate R sessions/background jobs. Do not start
#   run_pipeline_2024() until run_pipeline_2023() has finished, because 2024
#   validation compares to 2023.
#
# Safety limits:
#   These settings do not replace package data, do not run datacreate_ package
#   data scripts, do not update FRS, and do not publish release assets.

repo_dir <- "/Users/markcorrales/R PACKAGES/EJAM"
s3_pipeline_root <- "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
epa_acs22_reference_dir <- file.path(
  s3_pipeline_root,
  "ejscreen_acs_2022/epa_original_reference/2024_2.32_August_UseMe"
)

pipeline_script <- file.path(repo_dir, "data-raw/run_ejscreen_dataset_pipeline.R")
replication_script <- file.path(repo_dir, "data-raw/run_acs22_replication_summaries.R")
targeted_diagnostics_script <- file.path(
  repo_dir,
  "data-raw/run_acs22_replication_targeted_diagnostics.R"
)

load_local_ejam <- function() {
  if (requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(repo_dir, quiet = TRUE)
  } else {
    library(EJAM)
  }
  invisible(TRUE)
}

pipeline_env_names <- c(
  "EJAM_PIPELINE_YR",
  "EJAM_PIPELINE_ROOT",
  "EJAM_PIPELINE_DIR",
  "EJAM_PIPELINE_STORAGE",
  "EJAM_STAGE_FORMAT",
  "EJAM_STAGE_FORMATS",
  "EJAM_BLOCKGROUP_UNIVERSE_SOURCE",
  "EJAM_TRACT_WEIGHT_SOURCE",
  "EJAM_FORCE_ACS",
  "EJAM_FORCE_BG_ACSDATA",
  "EJAM_FORCE_BG_GEODATA",
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

set_env <- function(values) {
  Sys.unsetenv(pipeline_env_names)
  do.call(Sys.setenv, as.list(values))
  invisible(values)
}

common_pipeline_env <- function(year) {
  year <- as.character(year)
  c(
    EJAM_PIPELINE_YR = year,
    EJAM_PIPELINE_ROOT = s3_pipeline_root,
    EJAM_PIPELINE_DIR = file.path(s3_pipeline_root, paste0("ejscreen_acs_", year)),
    EJAM_PIPELINE_STORAGE = "s3",

    # Read saved R data stages for speed; still write both rda and csv stages.
    # If a required .rda stage is missing or stale, switch EJAM_STAGE_FORMAT to
    # "csv" for that run.
    EJAM_STAGE_FORMAT = "rda",
    EJAM_STAGE_FORMATS = "rda,csv",

    EJAM_BLOCKGROUP_UNIVERSE_SOURCE = "acs",
    EJAM_TRACT_WEIGHT_SOURCE = "decennial2020",

    # Use saved ACS/bg_acsdata/geodata stages; this is not a fresh ACS download.
    EJAM_FORCE_ACS = "FALSE",
    EJAM_FORCE_BG_ACSDATA = "FALSE",
    EJAM_FORCE_BG_GEODATA = "FALSE",
    EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
    EJAM_ACS_DOWNLOAD_RETRIES = "2",

    # Island Areas are included for BG/export/map visibility, but Island Areas
    # Census demographics remain off by design.
    EJAM_INCLUDE_ISLANDAREAS_DATA = "TRUE",
    EJAM_ISLANDAREAS_REFERENCE_PATH = file.path(
      epa_acs22_reference_dir,
      "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv"
    ),
    EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = "FALSE",

    # Do not fall back to packaged environmental data during this S3 refresh.
    EJAM_USE_PROVISIONAL_BG_ENVIRODATA = "FALSE",
    EJAM_BG_ENVIRODATA_REFERENCE_PATH = "",
    EJAM_BG_ENVIRODATA_REFERENCE_VARS = "",

    # Refresh the EJScreen-friendly blockgroup exports. EJScreen-formatted
    # lookup-table exports are not created by default because the live app maps
    # from the blockgroup exports and reports are served through EJAM-API/EJAM.
    EJAM_INCLUDE_EJSCREEN_EXPORT = "TRUE",
    EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT = "TRUE",
    EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS = "FALSE",
    EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT = "FALSE",

    # Annual update validation.
    EJAM_VALIDATE_VS_PRIOR = "TRUE",
    EJAM_PRIOR_PIPELINE_YR = as.character(as.integer(year) - 1L),
    EJAM_PRIOR_PIPELINE_DIR = "",
    EJAM_PRIOR_PACKAGE_REF = "",
    EJAM_PRIOR_PACKAGE_PATH = "data/blockgroupstats.rda",
    EJAM_EJSCREEN_EXPORT_REFERENCE_PATH = "",
    EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH = "",
    EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE = "FALSE",
    EJAM_VALIDATE_VS_PRIOR_WALDO = "FALSE",

    # Keep this refresh from touching package data or release assets.
    EJAM_RUN_DATACREATE_BEFORE = "FALSE",
    EJAM_RUN_DATACREATE_AFTER = "FALSE",
    EJAM_REPLACE_PACKAGE_DATA = "FALSE",
    EJAM_INCLUDE_FRS_UPDATE = "FALSE"
  )
}

run_pipeline_with_env <- function(values) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(repo_dir)
  set_env(values)
  print(as.list(Sys.getenv(pipeline_env_names)))
  source(pipeline_script, local = new.env(parent = globalenv()))
}

run_pipeline_2022 <- function() {
  values <- common_pipeline_env(2022)

  # ACS22 is the one-time EPA replication vintage. This compares 2026 pipeline
  # output to EJAM v2.32.8.001 package data and to archived EPA v2.32 exports.
  # The saved ACS22 bg_envirodata stage should already be the corrected source
  # of environmental values. In particular, drinking-water missingness should be
  # present in bg_envirodata itself. Do not use a runner-only reference override
  # here; if bg_envirodata is wrong, correct and resave that stage first so the
  # pipeline consumes bg_envirodata as-is.
  values["EJAM_PRIOR_PACKAGE_REF"] <- "v2.32.8.001"
  values["EJAM_PRIOR_PIPELINE_YR"] <- "2021"
  values["EJAM_EJSCREEN_EXPORT_REFERENCE_PATH"] <- file.path(
    epa_acs22_reference_dir,
    "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv"
  )
  values["EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH"] <- file.path(
    epa_acs22_reference_dir,
    "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv"
  )
  values["EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE"] <- "TRUE"

  run_pipeline_with_env(values)
}

run_acs22_replication <- function() {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(repo_dir)
  load_local_ejam()

  Sys.setenv(
    EJAM_ACS22_REPLICATION_ROOT = s3_pipeline_root,
    EJAM_ACS22_REPLICATION_PIPELINE_2022_DIR = file.path(
      s3_pipeline_root,
      "ejscreen_acs_2022"
    ),
    EJAM_ACS22_REPLICATION_EPA_REFERENCE_DIR = epa_acs22_reference_dir,
    EJAM_ACS22_REPLICATION_EJAM_2025_REF = "v2.32.8.001",
    EJAM_ACS22_REPLICATION_EJAMDATA_REPO =
      "Public-Environmental-Data-Partners/ejamdata",
    EJAM_ACS22_REPLICATION_INCLUDE_LOOKUP_EXPORTS = "FALSE",
    EJAM_ACS22_REPLICATION_STORAGE = "s3"
  )

  source(replication_script, local = TRUE)
  acs22_replication_run_reports()

  source(targeted_diagnostics_script, local = TRUE)
  acs22_diag_report()
}

run_pipeline_2023 <- function() {
  values <- common_pipeline_env(2023)
  values["EJAM_PRIOR_PIPELINE_YR"] <- "2022"
  run_pipeline_with_env(values)
}

run_pipeline_2024 <- function() {
  values <- common_pipeline_env(2024)
  values["EJAM_PRIOR_PIPELINE_YR"] <- "2023"
  run_pipeline_with_env(values)
}

run_all_serial <- function() {
  run_pipeline_2022()
  run_acs22_replication()
  run_pipeline_2023()
  run_pipeline_2024()
}

message("Loaded S3 refresh helper. No steps have been run.")
message("Recommended serial command: run_all_serial()")
message("Safer manual sequence: run_pipeline_2022(); run_acs22_replication(); run_pipeline_2023(); run_pipeline_2024()")
