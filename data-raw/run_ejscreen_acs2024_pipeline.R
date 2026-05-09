###################################################### #

# Repeatable ACS 2020-2024 EJSCREEN/EJAM pipeline runner.
#
# Relies on calc_ejscreen_dataset() as a high-level function
#
# By default this writes CSV checkpoints to:
#   data-raw/pipeline_outputs/ejscreen_acs_2024
#
# To rerun after updated environmental indicators are available:
#   1. Save the updated blockgroup-level environmental table as
#      bg_envirodata.csv in the pipeline folder. It must include bgfips and
#      pctpre1960, plus the environmental indicators to use for EJ indexes.
#   2. Source this script again. Existing raw ACS and bg_acsdata checkpoints are
#      reused, and downstream blockgroupstats/bgej/usastats/statestats are
#      recalculated from the updated bg_envirodata.csv.
#
# Useful environment variables:
#   EJAM_PIPELINE_DIR: override output folder.
#   EJAM_PIPELINE_STORAGE: auto, local, or s3. auto treats s3:// paths as S3.
#   EJAM_FORCE_ACS: TRUE to redownload/recalculate raw ACS and bg_acsdata.
#   EJAM_FORCE_BG_ACSDATA: TRUE to rebuild bg_acsdata from saved raw ACS.
#   EJAM_INCLUDE_EJSCREEN_EXPORT: TRUE to create ejscreen_export.csv.
#   EJAM_USE_PROVISIONAL_BG_ENVIRODATA: FALSE to require bg_envirodata.csv.

###################################################### #
# setup ####

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else if (!exists("calc_ejscreen_dataset")) {
  library(EJAM)
}

library(data.table)

env_flag <- function(name, default = FALSE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "TRUE" else "FALSE")
  toupper(value) %in% c("1", "TRUE", "YES", "Y")
}

## year ####
yr <- as.integer(Sys.getenv("EJAM_PIPELINE_YR", unset = "2024"))

pipeline_dir <- Sys.getenv(
  "EJAM_PIPELINE_DIR",
  unset = file.path(getwd(), "data-raw", "pipeline_outputs", paste0("ejscreen_acs_", yr))
)
pipeline_storage <- Sys.getenv("EJAM_PIPELINE_STORAGE", unset = "auto")
pipeline_storage <- match.arg(pipeline_storage, c("auto", "local", "s3"))
pipeline_storage <- EJAM:::ejscreen_pipeline_storage_backend(pipeline_dir, storage = pipeline_storage)
force_acs <- env_flag("EJAM_FORCE_ACS", FALSE)
force_bg_acsdata <- env_flag("EJAM_FORCE_BG_ACSDATA", force_acs)
include_ejscreen_export <- env_flag("EJAM_INCLUDE_EJSCREEN_EXPORT", TRUE)
use_provisional_bg_envirodata <- env_flag("EJAM_USE_PROVISIONAL_BG_ENVIRODATA", TRUE)
acs_download_timeout <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_TIMEOUT", unset = "3600"))
acs_download_retries <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_RETRIES", unset = "2"))

if (pipeline_storage == "local") {
  dir.create(pipeline_dir, recursive = TRUE, showWarnings = FALSE)
}
message("Pipeline folder: ", pipeline_dir)
message("Pipeline storage: ", pipeline_storage)

stage_path <- function(stage) {
  EJAM:::ejscreen_pipeline_stage_path(stage, pipeline_dir, format = "csv")
}

load_csv_stage <- function(stage) {
  EJAM:::ejscreen_pipeline_load(stage, pipeline_dir = pipeline_dir, format = "csv", storage = pipeline_storage)
}

stage_exists <- function(stage) {
  EJAM:::ejscreen_pipeline_stage_exists(stage, pipeline_dir = pipeline_dir, format = "csv", storage = pipeline_storage)
}

pipeline_file_path <- function(file_name) {
  file.path(pipeline_dir, file_name)
}

write_pipeline_text <- function(lines, file_name) {
  path <- pipeline_file_path(file_name)
  if (pipeline_storage == "s3") {
    tmp <- tempfile(fileext = ".txt")
    writeLines(lines, con = tmp)
    EJAM:::ejscreen_pipeline_s3_upload(tmp, path)
  } else {
    writeLines(lines, con = path)
  }
  invisible(path)
}

write_pipeline_csv <- function(x, file_name) {
  path <- pipeline_file_path(file_name)
  if (pipeline_storage == "s3") {
    tmp <- tempfile(fileext = ".csv")
    fwrite(x, tmp)
    EJAM:::ejscreen_pipeline_s3_upload(tmp, path)
  } else {
    fwrite(x, path)
  }
  invisible(path)
}

###################################################### #
# Download ACS raw blockgroup data stage ####
###################################################### #

if (force_acs || !stage_exists("bg_acs_raw")) {
  message("Creating bg_acs_raw from ACSdownload/Census files")
  bg_acs_raw <- EJAM::download_bg_acs_raw(
    yr = yr,
    pipeline_dir = pipeline_dir,
    save_stage = TRUE,
    stage_format = "csv",
    raw_acs_storage = "folder",
    raw_table_format = "csv",
    overwrite = TRUE,
    storage = pipeline_storage,
    download_timeout = acs_download_timeout,
    download_retries = acs_download_retries
  )
} else {
  message("Reusing saved bg_acs_raw")
  bg_acs_raw <- load_csv_stage("bg_acs_raw")
}
###################################################### #
# Calculate ACS-based indicators, bg_acsdata stage ####
###################################################### #

# bg_acsdata  is the cleaned/processed version of the raw ACS data that is used for calculating indicators and stats.
# This is a separate stage because it can be time consuming to calculate and you may want to manually add other raw scores here,
# but if you have already calculated it and saved it, you can reuse it even if you want to recalculate downstream stages like blockgroupstats or bgej.

if (force_bg_acsdata || !stage_exists("bg_acsdata")) {
  message("Creating bg_acsdata from bg_acs_raw")
  bg_acsdata <- EJAM:::calc_bg_acsdata(
    yr = yr,
    acs_raw = bg_acs_raw,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = "csv",
    overwrite = TRUE
  )
  EJAM:::ejscreen_pipeline_save(bg_acsdata, "bg_acsdata", pipeline_dir, format = "csv", overwrite = TRUE, storage = pipeline_storage)
} else {
  message("Reusing saved bg_acsdata")
  bg_acsdata <- load_csv_stage("bg_acsdata")
}

###################################################### #
# Environmental indicators stage - Read new or re-use existing data ####
###################################################### #

bg_envirodata_path <- stage_path("bg_envirodata")
if (stage_exists("bg_envirodata")) {
  message("Using provided bg_envirodata.csv")
  bg_envirodata <- load_csv_stage("bg_envirodata")
} else if (isTRUE(use_provisional_bg_envirodata)) {
  message("Creating PROVISIONAL bg_envirodata.csv from current package blockgroupstats")
  env_cols <- intersect(EJAM::names_e, names(EJAM::blockgroupstats))
  bg_envirodata <- as.data.table(EJAM::blockgroupstats)[, c("bgfips", env_cols), with = FALSE]
  EJAM:::ejscreen_pipeline_save(bg_envirodata, "bg_envirodata", pipeline_dir, format = "csv", overwrite = TRUE, storage = pipeline_storage)
  write_pipeline_text(
    c(
      "PROVISIONAL bg_envirodata.csv",
      "This file was copied from the currently packaged EJAM::blockgroupstats.",
      "Replace it with updated environmental indicators and rerun data-raw/run_ejscreen_acs2024_pipeline.R.",
      paste("Created:", Sys.time())
    ),
    "bg_envirodata_SOURCE.txt"
  )
} else {
  stop("Missing bg_envirodata.csv. Save updated environmental indicators there or set EJAM_USE_PROVISIONAL_BG_ENVIRODATA=TRUE")
}

###################################################### #
# Extra indicators stage - Read new or re-use existing data ####
###################################################### #

bg_extra_indicators_path <- stage_path("bg_extra_indicators")
if (stage_exists("bg_extra_indicators")) {
  message("Using provided bg_extra_indicators.csv")
  bg_extra_indicators <- load_csv_stage("bg_extra_indicators")
} else {
  message("Creating bg_extra_indicators.csv from current package blockgroupstats")

  bg_extra_indicators <- EJAM:::calc_bg_extra_indicators(

    existing_blockgroupstats = EJAM::blockgroupstats,
    reuse_existing_if_missing = TRUE,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = "csv",
    overwrite = TRUE
  )
  EJAM:::ejscreen_pipeline_save(bg_extra_indicators, "bg_extra_indicators", pipeline_dir, format = "csv", overwrite = TRUE, storage = pipeline_storage)
  write_pipeline_text(
    c(
      "PROVISIONAL bg_extra_indicators.csv",
      "This file was copied from the currently packaged EJAM::blockgroupstats.",
      "Replace it with updated non-ACS, non-environmental blockgroup indicators if available, then rerun.",
      paste("Created:", Sys.time())
    ),
    "bg_extra_indicators_SOURCE.txt"
  )
}

###################################################### #
# Create blockgroupstats, bgej, usastats, & statestats ####
###################################################### #

message("Creating blockgroupstats, bgej, usastats, statestats",
        if (isTRUE(include_ejscreen_export)) ", and ejscreen_export" else "")

out <- EJAM::calc_ejscreen_dataset(

  yr = yr,
  bg_acsdata = bg_acsdata,
  bg_envirodata = bg_envirodata,
  bg_extra_indicators = bg_extra_indicators,

  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage,
  save_stages = TRUE,
  use_saved_stages = FALSE,
  stage_format = "csv",
  raw_acs_storage = "folder",
  raw_table_format = "csv",
  download_acs_raw = FALSE,
  download_timeout = acs_download_timeout,
  download_retries = acs_download_retries,
  return_intermediate = TRUE,
  include_ejscreen_export = include_ejscreen_export,
  overwrite = TRUE
)

###################################################### #
# Validation summary ####
###################################################### #

stages_to_validate <- c(

  # note this list of stages is not quite the same as the stages in
  # ejscreen_pipeline_stage_names(), a longer list, or in
  # EJAM:::ejscreen_pipeline_stage_canonical(), a shorter list

  # inputs or early stages
  "bg_acsdata",    # demographics as calculated from bg_acs_raw (the downloaded survey data)
  "bg_envirodata", # environmental indicators (the key ones, 13 as of 2026)
  "bg_extra_indicators", # many other indicators, like % low life expectancy, etc.

  # indicators dataset
  "blockgroupstats", # includes acs, enviro, and extra_indicators, not EJ Indexes
  "bgej",            # includes just EJ Indexes, 1 for each of the 13 environmental indicators, but each in 4 forms: US basic, US supplementary, State basic, State supplementary

  # percentile lookup tables:
  "usastats_acs",
  "statestats_acs",
  "usastats_envirodata",
  "statestats_envirodata",
  "usastats_ej",
  "statestats_ej",
  "usastats",  # combines the acs, enviro, and ej lookup tables
  "statestats"
)

if (isTRUE(include_ejscreen_export)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_export")
}

validation_summary <- rbindlist(lapply(stages_to_validate, function(stage) {
  x <- load_csv_stage(stage)
  result <- EJAM:::ejscreen_pipeline_validate(x, stage = stage, strict = FALSE)
  data.table(
    stage = stage,
    path = stage_path(stage),
    rows = NROW(x),
    columns = NCOL(x),
    errors = paste(result$errors, collapse = " | "),
    warnings = paste(result$warnings, collapse = " | ")
  )
}), fill = TRUE)

write_pipeline_csv(validation_summary, "pipeline_validation_summary.csv")

if (isTRUE(include_ejscreen_export)) {
  ejscreen_schema_report <- EJAM:::calc_ejscreen_export_schema_report(
    ejscreen_export = out$ejscreen_export
  )
  write_pipeline_csv(ejscreen_schema_report, "ejscreen_export_schema_report.csv")
}

if (any(nzchar(validation_summary$errors))) {
  print(validation_summary[nzchar(errors)])
  stop("Pipeline validation errors found. See pipeline_validation_summary.csv")
}

message("Pipeline completed. Validation summary:")
print(validation_summary[, .(stage, rows, columns, warnings)])
message("Output folder: ", pipeline_dir)

invisible(out)

###################################################### #

# when ready to actually replace the old blockgroupstats dataset entirely:
if (interactive()) {
  if (askYesNo("ready to save blockgroupstats in the package data folder with new metadata?")) {
    blockgroupstats <- out$blockgroupstats

    EJAM:::metadata_add_and_use_this("blockgroupstats")

    rm(blockgroupstats)

    ######################################### #
    ### datacreate_avg.in.us.R ####
    # rstudioapi::documentOpen("./data-raw/datacreate_avg.in.us.R")
    ### this creates "avg.in.us" national averages of key indicators, for convenience, but also avgs are in usastats, statestats
    source("./data-raw/datacreate_avg.in.us.R")
    ######################################### #


    cat("REBUILD/INSTALL THE PACKAGE NOW \n")
  }
}
