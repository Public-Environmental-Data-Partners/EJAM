###################################################### #

# Repeatable ACS 2020-2024 EJSCREEN/EJAM pipeline runner.
# Run via source("data-raw/run_ejscreen_acs2024_pipeline.R")
# Relies on calc_ejscreen_dataset() as a high-level function
#
# Depending on specified year, storage location, and directory,
#   this writes csv (or other format) file checkpoints to a local or aws directory such as
#   data-raw/pipeline_outputs/ejscreen_acs_2022
#   (as an example of local storage of the 2022 data)
#   or
#   s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2024
#   (as an example of S3 storage, for the 2020-2024 ACS data).
#
# To rerun after updated environmental indicators are available:
#   1. Save the updated blockgroup-level environmental table as
#      bg_envirodata.csv (or format specified by stage_format) in the pipeline folder.
#      It must include columns "bgfips" and
#      "pctpre1960", plus the rest of the environmental indicators to use for EJ indexes,
#       as specified in EJAM::names_e.
#   2. Source this script again. Existing raw ACS and bg_acsdata checkpoints are
#      reused, and downstream blockgroupstats/bgej/usastats/statestats are
#      recalculated from the updated file bg_envirodata.csv (or format specified by stage_format).
#
#  Also see ejscreen_pipeline_validate_vs_prior()
#  for comparing the outputs of this pipeline to the prior version of the data,
#  to help confirm that changes are as expected.
#
# Useful environment variables:

#   EJAM_PIPELINE_YR: the last year of the 5-year ACS survey to use, e.g. 2022 or 2024. Default is the most recent year that is likely to be published by Census.

#   EJAM_PIPELINE_DIR: override output folder.
#   EJAM_PIPELINE_STORAGE: auto, local, or s3. auto treats s3:// paths as S3.

#   EJAM_FORCE_ACS:        FALSE means reuse already-downloaded raw data. TRUE to redownload/recalculate raw ACS and bg_acsdata.
#   EJAM_FORCE_BG_ACSDATA: FALSE means reuse already calculated bg_acsdata if it exists (even if forcing redownload of raw ACS). TRUE to rebuild bg_acsdata from saved raw ACS.
#   EJAM_ACS_DOWNLOAD_TIMEOUT
#   EJAM_ACS_DOWNLOAD_RETRIES

#   EJAM_USE_PROVISIONAL_BG_ENVIRODATA: TRUE means reuse envt data still in EJAM::blockgroupstats. FALSE to require bg_envirodata.csv or .xyz file.

#   EJAM_INCLUDE_EJSCREEN_EXPORT: TRUE to create ejscreen_export.csv or .xyz file.

#   EJAM_VALIDATE_VS_PRIOR: TRUE to compare selected outputs to currently packaged EJAM datasets and save prior_validation_*.txt and prior_validation_summary.csv.
#   EJAM_VALIDATE_VS_PRIOR_WALDO: TRUE to include optional waldo::compare() output in prior validation detail files.

#   CENSUS_API_KEY: used by functions that download ACS data (or that download boundaries/shapefiles for FIPS from some sources)
###################################################### #

# DEFAULT SETTINGS  ####

# Leave these defaults here, and then
# Override by setting environment variables further BELOW before sourcing this script.
# note that right here the EJAM_PIPELINE_DIR is based on type of EJAM_PIPELINE_STORAGE but
# if EJAM_PIPELINE_STORAGE is set to "auto" here, then it gets figured out later based on EJAM_PIPELINE_DIR

# infer latest likely published ACS end year for default
default_yr <- suppressMessages({EJAM:::acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE)})
yr = default_yr
storage = "s3" # or "local" or "auto"
dir_child = paste0("ejscreen_acs_", yr)
dir_parent_s3 = "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
dir_parent_local = file.path(getwd(), "data-raw", "pipeline_outputs")
# dir_parent_local = file.path(tempdir(), "data-raw", "pipeline") # an alternative local path that is outside the package folder
dir_parent <- if (storage == "local") {dir_parent_local} else {dir_parent_s3}
dir_full <- file.path(dir_parent, dir_child)

Sys.setenv(
  EJAM_PIPELINE_YR = yr,
  EJAM_PIPELINE_STORAGE = storage,
  EJAM_PIPELINE_DIR = dir_full,
  EJAM_STAGE_FORMAT = "csv", # options are c("csv", "rds", "rda", "arrow")

  EJAM_FORCE_ACS        = "FALSE",
  EJAM_FORCE_BG_ACSDATA = "FALSE",
  EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
  EJAM_ACS_DOWNLOAD_RETRIES = "2",

  EJAM_USE_PROVISIONAL_BG_ENVIRODATA = "FALSE",

  EJAM_INCLUDE_EJSCREEN_EXPORT = "TRUE",

  EJAM_VALIDATE_VS_PRIOR       = "TRUE",
  EJAM_VALIDATE_VS_PRIOR_WALDO = "FALSE"
)
###################################################### #
# USE NON-DEFAULT SETTINGS - for this run ####
###################################################### #

## uncomment this block to use these settings (instead of defaults)
# # to recreate datasets using ACS 2018-2022 survey data
#
# yr = "2022"
#
# Sys.setenv(
#            EJAM_PIPELINE_YR = yr,
#            EJAM_PIPELINE_DIR = paste0("s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_", yr),
#            EJAM_PIPELINE_STORAGE = "s3",
#         # or #   EJAM_PIPELINE_STORAGE = "local",
#         #    #   EJAM_PIPELINE_DIR = file.path(getwd(), "data-raw", "pipeline_outputs", paste0("ejscreen_acs_", yr)),
#            EJAM_STAGE_FORMAT = "csv",  # options will be c("csv", "rds", "rda", "arrow")
#            EJAM_FORCE_ACS = FALSE,    # FALSE means reuse if already had downloaded.
#            EJAM_FORCE_BG_ACSDATA = FALSE, # or as needed
#            EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
#            EJAM_ACS_DOWNLOAD_RETRIES = "2",
#      EJAM_USE_PROVISIONAL_BG_ENVIRODATA = TRUE, # TRUE during testing not once finalized datasets - TO TRY TO REPLICATE 2022 DATA
#      EJAM_INCLUDE_EJSCREEN_EXPORT = TRUE,
#            EJAM_VALIDATE_VS_PRIOR = TRUE,
#            EJAM_VALIDATE_VS_PRIOR_WALDO = FALSE
# )
# ###################################################### #
## uncomment this block to use these settings (instead of defaults)
# # to specify using ACS 2020-2024 survey data
#
# yr = "2024"
#
# Sys.setenv(
#            EJAM_PIPELINE_YR = yr,
#            EJAM_PIPELINE_DIR = paste0("s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_", yr),
#            EJAM_PIPELINE_STORAGE = "s3",
#         # or #   EJAM_PIPELINE_DIR = file.path(getwd(), "data-raw", "pipeline_outputs", paste0("ejscreen_acs_", yr)),
#            EJAM_STAGE_FORMAT = "csv",  # options will be c("csv", "rds", "rda", "arrow")
#         #    #   EJAM_PIPELINE_STORAGE = "local",
#            EJAM_FORCE_ACS = TRUE,    # FALSE means reuse if already had downloaded.
#            EJAM_FORCE_BG_ACSDATA = TRUE, # or as needed
#            EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
#            EJAM_ACS_DOWNLOAD_RETRIES = "2",
#         EJAM_USE_PROVISIONAL_BG_ENVIRODATA = TRUE, #  set FALSE once new envt data are available
#         EJAM_INCLUDE_EJSCREEN_EXPORT = TRUE,
#            EJAM_VALIDATE_VS_PRIOR = TRUE, # 1st time this is used on 2024 yr, it will compare to 2022 TO SEE HOW MUCH THINGS CHANGED VS last version that was packaged so initially that will be 2022 but after saved in package if this is run again it will not do much.
#            EJAM_VALIDATE_VS_PRIOR_WALDO = FALSE
# )
###################################################### #
## To check them:
#
print(
  cbind(current_setting = Sys.getenv(c(
    'EJAM_PIPELINE_YR',
    'EJAM_PIPELINE_DIR',
    'EJAM_PIPELINE_STORAGE',
    'EJAM_STAGE_FORMAT',

    'EJAM_FORCE_ACS',
    'EJAM_FORCE_BG_ACSDATA',
    'EJAM_ACS_DOWNLOAD_TIMEOUT',
    'EJAM_ACS_DOWNLOAD_RETRIES',
    'EJAM_USE_PROVISIONAL_BG_ENVIRODATA',
    'EJAM_INCLUDE_EJSCREEN_EXPORT',
    'EJAM_VALIDATE_VS_PRIOR',
    'EJAM_VALIDATE_VS_PRIOR_WALDO'
  )))
)
###################################################### #
#
# VALIDATION VS A SPECIFIC PRIOR DATASET ####
#
# The code below by default compared new results versus EJAM::blockgroupstats, EJAM::usastats, etc.
# In other words, it compares to whatever version happens to be currently packaged in EJAM when this script is run,
# which may be the old 2022 data or the 2024 data, etc.,
# depending on when you run it and what is in the package at that time.
#
# To control which prior datasets/files to use for comparison/replication purposes,
# in the code below in the section
# "Optional validation versus prior or currently packaged datasets",
# make edits to specify which datasets to compare to the prior version of the data, and
# which columns to compare (e.g. shared columns, or specific key columns).

###################################################### #

# load packages ####

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else if (!exists("calc_ejscreen_dataset")) {
  library(EJAM)
}

library(data.table)

# get settings ####

env_flag <- function(name, default = FALSE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "TRUE" else "FALSE")
  toupper(value) %in% c("1", "TRUE", "YES", "Y")
}

### year ####

default_yr <- suppressMessages({EJAM:::acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE)})
yr <- as.integer(Sys.getenv("EJAM_PIPELINE_YR", unset = default_yr))
pipeline_yr <- yr
message("Year: ", pipeline_yr)

### storage / folders / file format settings ####

pipeline_dir <- Sys.getenv(
  "EJAM_PIPELINE_DIR",
  unset = file.path(getwd(), "data-raw", "pipeline_outputs", paste0("ejscreen_acs_", yr))
)
pipeline_storage <- Sys.getenv("EJAM_PIPELINE_STORAGE", unset = "auto")
pipeline_storage <- match.arg(pipeline_storage, c("auto", "local", "s3"))
pipeline_storage <- EJAM:::ejscreen_pipeline_storage_backend(pipeline_dir, storage = pipeline_storage)
if (pipeline_storage == "local") {
  dir.create(pipeline_dir, recursive = TRUE, showWarnings = FALSE)
}
stage_format <- Sys.getenv("EJAM_STAGE_FORMAT", unset = "csv")

message("Pipeline folder: ", pipeline_dir)
message("Pipeline storage: ", pipeline_storage)
message("File format aka stage_format: ", stage_format)

### ACS DEMOGRAPHIC DATA settings ####

force_acs <- env_flag("EJAM_FORCE_ACS", FALSE)
force_bg_acsdata <- env_flag("EJAM_FORCE_BG_ACSDATA", force_acs)
acs_download_timeout <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_TIMEOUT", unset = "3600"))
acs_download_retries <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_RETRIES", unset = "2"))

### ENVIRONMENTAL DATA settings ####

use_provisional_bg_envirodata <- env_flag("EJAM_USE_PROVISIONAL_BG_ENVIRODATA", FALSE)

### ESCREEN DATASET EXPORT settings ####

include_ejscreen_export <- env_flag("EJAM_INCLUDE_EJSCREEN_EXPORT", TRUE)

### validation vs prior data  ####

validate_vs_prior <- env_flag("EJAM_VALIDATE_VS_PRIOR", TRUE)
validate_vs_prior_waldo <- env_flag("EJAM_VALIDATE_VS_PRIOR_WALDO", FALSE)

#################################################### #
print(
  cbind(Sys.getenv = Sys.getenv(c(
    'EJAM_PIPELINE_YR',
    'EJAM_PIPELINE_DIR',
    'EJAM_PIPELINE_STORAGE',
    'EJAM_STAGE_FORMAT',

    'EJAM_FORCE_ACS',
    'EJAM_FORCE_BG_ACSDATA',
    'EJAM_ACS_DOWNLOAD_TIMEOUT',
    'EJAM_ACS_DOWNLOAD_RETRIES',

    'EJAM_USE_PROVISIONAL_BG_ENVIRODATA',

    'EJAM_INCLUDE_EJSCREEN_EXPORT',

    'EJAM_VALIDATE_VS_PRIOR',
    'EJAM_VALIDATE_VS_PRIOR_WALDO'
  )),
  using_here = c(
    pipeline_yr = pipeline_yr,
    pipeline_dir=pipeline_dir,
    pipeline_storage=pipeline_storage,
    stage_format=stage_format,

    force_acs=force_acs,
    force_bg_acsdata=force_bg_acsdata,
    acs_download_timeout=acs_download_timeout,
    acs_download_retries=acs_download_retries,

    use_provisional_bg_envirodata=use_provisional_bg_envirodata,

    include_ejscreen_export=include_ejscreen_export,

    validate_vs_prior=validate_vs_prior,
    validate_vs_prior_waldo=validate_vs_prior_waldo
  ))
)
# census_api_key = "(see actual key)",
#################################################### #
## to insert a pause here to confirm settings, could use this:
# if (interactive()) {
#   ready <- FALSE
#   ready <- askYesNo("Ready to run the pipeline with those settings?")
#   if (!isTRUE(ready)) {stop("halted until ready")}
# }
#################################################### #
#################################################### #
# ~ ####
# helper functions ####

####################### #
load_file_stage <- function(stage) {
  # this helper is shorthand, and presumes that pipeline_dir, stage_format, and pipeline_storage are defined in the environment (as they are in this script), so that you can just call load_file_stage("bg_acsdata") for example, and it will know where to look for it and what format to expect.
  EJAM:::ejscreen_pipeline_load(stage, pipeline_dir = pipeline_dir, format = stage_format, storage = pipeline_storage)
}
####################### #
stage_exists <- function(stage) {
  # this helper is shorthand, and presumes that pipeline_dir, stage_format, and pipeline_storage are defined in the environment (as they are in this script), so that you can just call load_file_stage("bg_acsdata") for example, and it will know where to look for it and what format to expect.
  EJAM:::ejscreen_pipeline_stage_exists(stage, pipeline_dir = pipeline_dir, format = stage_format, storage = pipeline_storage)
}
####################### #
# to save validation summary, use csv format always, even if stage_format is something else, to make it easy to open and read those files.
# to save schema info, use .txt format always, even if stage_format is something else, to make it easy to open and read those files.
## see also # EJAM:::ejscreen_pipeline_save(x=, stage=, pipeline_dir=, format = "txt", overwrite = T, storage=)

write_pipeline_txt_or_csv <- function(x, filename, pipeline_dir, pipeline_storage) {

  # get file extension aka format from filename
  format <- tools::file_ext(filename)
  if (format == "txt") {
    FUN <- writeLines
  } else {
    if (format == "csv") {
      FUN <- data.table::fwrite
    } else {
      stop("format must be csv or txt here")
    }
  }
  path <- file.path(pipeline_dir, filename)
  if (pipeline_storage == "s3") {
    tmp <- tempfile(fileext = paste0(".", format)) ###
    FUN(x, tmp)
    EJAM:::ejscreen_pipeline_s3_upload(tmp, path)
  } else {
    FUN(x, path)
  }
  invisible(path)
}
####################### #
write_pipeline_text <- function(lines, filename) {
  write_pipeline_txt_or_csv(
    x = lines,
    filename = filename,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage
  )
}
####################### #
prior_shared_subset <- function(old_dt, new_dt) {
  old_dt <- data.table::as.data.table(data.table::copy(old_dt))
  shared <- intersect(names(old_dt), names(new_dt))
  keep <- unique(c("bgfips", shared))
  keep <- keep[keep %in% names(old_dt)]
  old_dt[, keep, with = FALSE]
}
####################### #
write_prior_validation <- function(stage, new_dt, old_dt, old_label) {
  warnings <- character()
  error <- character()
  result <- tryCatch(
    withCallingHandlers(
      EJAM:::ejscreen_pipeline_validate_vs_prior(
        new_dt = new_dt,
        old_dt = old_dt,
        use_waldo = validate_vs_prior_waldo,
        verbose = FALSE
      ),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      error <<- conditionMessage(e)
      NULL
    }
  )

  stage_safe <- gsub("[^A-Za-z0-9_]+", "_", stage)
  detail_filename <- paste0("prior_validation_", stage_safe, ".txt")

  if (is.null(result)) {
    write_pipeline_text(
      c(
        paste0("Prior-version validation for stage: ", stage),
        paste0("Reference object: ", old_label),
        paste0("Created: ", Sys.time()),
        "",
        paste0("ERROR: ", error)
      ),
      detail_filename
    )
    return(data.table::data.table(
      stage = stage,
      path = EJAM:::ejscreen_pipeline_stage_path(stage = stage, pipeline_dir = pipeline_dir, format = stage_format),
      old_label = old_label,
      error = error,
      warnings = paste(warnings, collapse = " | ")
    ))
  }

  write_pipeline_text(
    EJAM:::ejscreen_pipeline_prior_validation_text(
      result = result,
      stage = stage,
      old_label = old_label,
      warnings = warnings
    ),
    detail_filename
  )
  row <- EJAM:::ejscreen_pipeline_prior_validation_as_row(
    result = result,
    stage = stage,
    path = EJAM:::ejscreen_pipeline_stage_path(stage = stage, pipeline_dir = pipeline_dir, format = stage_format),
    old_label = old_label,
    warnings = warnings
  )
  row[, error := ""]
  row[]
}
####################### #
# ~ ----------------------------------------------- ####
###################################################### #
# Download ACS raw blockgroup data stage ####
###################################################### #

need_bg_acsdata <- force_bg_acsdata || !stage_exists("bg_acsdata")
need_bg_acs_raw <- force_acs || need_bg_acsdata

stagename <- "bg_acs_raw"
message(paste0("Stage: ", stagename))

bg_acs_raw <- NULL
if (!isTRUE(need_bg_acs_raw)) {
  message("Skipping bg_acs_raw because saved bg_acsdata exists and ACS rebuild was not requested")
} else if (force_acs || !stage_exists(stagename)) {
  message("Creating bg_acs_raw from ACSdownload/Census files")
  bg_acs_raw <- EJAM::download_bg_acs_raw(
    yr = yr,
    pipeline_dir = pipeline_dir,
    save_stage = TRUE,
    stage_format = stage_format,
    raw_acs_storage = "folder",
    raw_table_format = "csv",
    overwrite = TRUE,
    storage = pipeline_storage,
    download_timeout = acs_download_timeout,
    download_retries = acs_download_retries
  )
} else {
  message(paste0("Using provided/existing ", stagename))
  bg_acs_raw <- load_file_stage(stagename)
}
###################################################### #
# Calculate ACS-based indicators, bg_acsdata stage ####
###################################################### #

# bg_acsdata  is the cleaned/processed version of the raw ACS data that is used for calculating indicators and stats.
# This is a separate stage because it can be time consuming to download ACS in the prior stage and you may want to manually add other raw scores here,
# but if you have already calculated it and saved it, you can reuse it even if you want to recalculate downstream stages like blockgroupstats or bgej.

stagename <- "bg_acsdata"
message(paste0("Stage: ", stagename))
if (isTRUE(need_bg_acsdata)) {
  message("Creating bg_acsdata from bg_acs_raw")
  bg_acsdata <- EJAM:::calc_bg_acsdata(
    yr = yr,
    acs_raw = bg_acs_raw,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    overwrite = TRUE
  )
  EJAM:::ejscreen_pipeline_save(bg_acsdata, stage = stagename, pipeline_dir = pipeline_dir, format = stage_format, overwrite = TRUE, storage = pipeline_storage)
} else {
  message(paste0("Using provided/existing ", stagename))
  bg_acsdata <- load_file_stage(stagename)
}
###################################################### #

###################################################### #
# Environmental indicators stage - Read new or re-use existing data ####
###################################################### #

## unused?
# bg_envirodata_path <- EJAM:::ejscreen_pipeline_stage_path(stage = "bg_envirodata", pipeline_dir, format = stage_format)

stagename <- "bg_envirodata"
message(paste0("Stage: ", stagename))

if (stage_exists(stagename)) {
  message(paste0("Using provided/existing ", stagename))
  bg_envirodata <- load_file_stage(stagename)

} else if (isTRUE(use_provisional_bg_envirodata)) {
  message(paste0("Creating PROVISIONAL bg_envirodata.", stage_format," from current package blockgroupstats"))
  if (!all(EJAM::names_e %in% names(EJAM::blockgroupstats))) {
    warning("Provisional EJAM::blockgroupstats does not have all of expected env indicator columns as specified in EJAM::names_e")
  }
  env_cols <- intersect(EJAM::names_e, names(EJAM::blockgroupstats))
  bg_envirodata <- as.data.table(EJAM::blockgroupstats)[, c("bgfips", env_cols), with = FALSE]
  # validate the provisional copy
  if (!isTRUE(all.equal(
    as.data.table(EJAM::blockgroupstats)[, env_cols, with = FALSE],
    bg_envirodata[, env_cols, with = FALSE],
    check.attributes = FALSE
  ))) {stop("Provisional bg_envirodata from blockgroupstats does not have the same env indicator values as EJAM::blockgroupstats")}
  EJAM:::ejscreen_pipeline_save(bg_envirodata, stage = stagename, pipeline_dir = pipeline_dir, format = stage_format, overwrite = TRUE, storage = pipeline_storage)
  write_pipeline_text(
    c(
      paste0("PROVISIONAL bg_envirodata.", stage_format),
      "This file was copied from the currently packaged EJAM::blockgroupstats.",
      "Replace it with updated environmental indicators and rerun data-raw/run_ejscreen_acs2024_pipeline.R.",
      paste("Created:", Sys.time())
    ),
    "bg_envirodata_SOURCE.txt"
  )
} else {
  stop("Missing bg_envirodata file and use_provisional_bg_envirodata was set FALSE. Save updated environmental indicators there or set EJAM_USE_PROVISIONAL_BG_ENVIRODATA=TRUE")
}

###################################################### #
# Extra indicators stage - Read new or re-use existing data ####
###################################################### #

stagename <- "bg_extra_indicators"
message(paste0("Stage: ", stagename))

if (stage_exists(stagename)) {
  message(paste0("Using provided/existing ", stagename))
  bg_extra_indicators <- load_file_stage(stagename)
} else {
  message(paste0("Creating ", stagename, ".", stage_format," from current package blockgroupstats"))

  bg_extra_indicators <- EJAM:::calc_bg_extra_indicators(

    existing_blockgroupstats = EJAM::blockgroupstats,
    reuse_existing_if_missing = TRUE,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    overwrite = TRUE
  )
  EJAM:::ejscreen_pipeline_save(x = bg_extra_indicators, stage = stagename, pipeline_dir = pipeline_dir, format = stage_format, overwrite = TRUE, storage = pipeline_storage)
  write_pipeline_text(
    c(
      paste0("PROVISIONAL bg_extra_indicators.", stage_format),
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
print(Sys.time())

out <- EJAM::calc_ejscreen_dataset(

  yr = yr,
  bg_acsdata = bg_acsdata,
  bg_envirodata = bg_envirodata,
  bg_extra_indicators = bg_extra_indicators,

  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage,
  save_stages = TRUE,
  use_saved_stages = FALSE,
  stage_format = stage_format,
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

message("Validating key stages and saving summary.")
print(Sys.time())

stages_to_validate <- c(

  # note this list of stages is not quite the same as the stages in
  # ejscreen_pipeline_stage_names(), a longer list, or in
  # EJAM:::ejscreen_pipeline_stage_canonical(), a shorter list

  # inputs or early stages
  "bg_acsdata",    # demographics as calculated from bg_acs_raw (the downloaded survey data)
  "bg_envirodata", # environmental indicators (the key ones, 13 as of 2026)
  "bg_extra_indicators", # many other indicators, like % low life expectancy, etc.

  # key indicators dataset
  "blockgroupstats", # a final product - includes acs, enviro, and extra_indicators, not EJ Indexes
  "bgej",            # a final product - includes just EJ Indexes, 1 for each of the 13 environmental indicators, but each in 4 forms: US basic, US supplementary, State basic, State supplementary

  # percentile lookup tables:
  "usastats_acs",
  "statestats_acs",
  "usastats_envirodata",
  "statestats_envirodata",
  "usastats_ej",
  "statestats_ej",
  "usastats",  # a final product - combines the acs, enviro, and ej lookup tables for USA as 1 file
  "statestats" # a final product - combines the acs, enviro, and ej lookup tables for all states as 1 file
)

if (isTRUE(include_ejscreen_export)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_export")
}

filename <- paste0("pipeline_validation_summary.", "csv")

validation_summary <- data.table::rbindlist(
  lapply(stages_to_validate, function(stagename) {
    x <- load_file_stage(stagename)
    result <- EJAM:::ejscreen_pipeline_validate(x, stage = stagename, strict = FALSE)
    data.table::data.table(
      stage = stagename,
      path = EJAM:::ejscreen_pipeline_stage_path(stage = stagename,
                                                 pipeline_dir = pipeline_dir,
                                                 format = stage_format),
      rows = NROW(x),
      columns = NCOL(x),
      errors = paste(result$errors, collapse = " | "),
      warnings = paste(result$warnings, collapse = " | ")
    )
  }),
  fill = TRUE
)

write_pipeline_txt_or_csv(x = validation_summary,
                          filename = filename,
                          pipeline_dir = pipeline_dir,
                          pipeline_storage = pipeline_storage)

if (isTRUE(include_ejscreen_export)) {
  filename <- paste0("ejscreen_export_schema_report.", "csv")
  ejscreen_schema_report <- EJAM:::calc_ejscreen_export_schema_report(
    ejscreen_export = out$ejscreen_export
  )
  write_pipeline_txt_or_csv(x = ejscreen_schema_report,
                            filename = filename,
                            pipeline_dir = pipeline_dir,
                            pipeline_storage = pipeline_storage)
}
print(Sys.time())
###################################################### #
# > Optional validation versus prior or currently packaged datasets ####
###################################################### #

if (isTRUE(validate_vs_prior)) {

  message("Comparing selected stages to currently packaged EJAM datasets.")
  prior_blockgroupstats <- data.table::as.data.table(data.table::copy(EJAM::blockgroupstats))
  if (!exists("bgej")) {dataload_dynamic("bgej")}
  prior_bgej <- data.table::as.data.table(data.table::copy( bgej ))
  prior_usastats <- data.table::as.data.table(data.table::copy(EJAM::usastats))
  prior_statestats <- data.table::as.data.table(data.table::copy(EJAM::statestats))

  prior_validation_summary <- data.table::rbindlist(
    list(
      write_prior_validation(
        stage = "bg_acsdata",
        new_dt = bg_acsdata,
        old_dt = prior_shared_subset(prior_blockgroupstats, bg_acsdata),
        old_label = "shared columns in EJAM::blockgroupstats"
      ),
      write_prior_validation(
        stage = "bg_envirodata",
        new_dt = bg_envirodata,
        old_dt = prior_shared_subset(prior_blockgroupstats, bg_envirodata),
        old_label = "shared columns in EJAM::blockgroupstats"
      ),
      write_prior_validation(
        stage = "bg_extra_indicators",
        new_dt = bg_extra_indicators,
        old_dt = prior_shared_subset(prior_blockgroupstats, bg_extra_indicators),
        old_label = "shared columns in EJAM::blockgroupstats"
      ),
      write_prior_validation(
        stage = "blockgroupstats",
        new_dt = out$blockgroupstats,
        old_dt = prior_blockgroupstats,
        old_label = "EJAM::blockgroupstats"
      ),
      write_prior_validation(
        stage = "bgej",
        new_dt = out$bgej,
        old_dt = prior_bgej,
        old_label = "EJAM::bgej"
      ),
      write_prior_validation(
        stage = "usastats",
        new_dt = out$usastats,
        old_dt = prior_usastats,
        old_label = "EJAM::usastats"
      ),
      write_prior_validation(
        stage = "statestats",
        new_dt = out$statestats,
        old_dt = prior_statestats,
        old_label = "EJAM::statestats"
      )
    ),
    fill = TRUE
  )

  write_pipeline_txt_or_csv(
    x = prior_validation_summary,
    filename = "prior_validation_summary.csv",
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage
  )
  message("Prior-version validation summary:")
  prior_validation_print_cols <- intersect(
    c("stage", "rows_new", "rows_old", "columns_new", "columns_old",
      "bgfips_set_equal", "shared_data_equal", "not_replicated_n", "error"),
    names(prior_validation_summary)
  )
  print(prior_validation_summary[, ..prior_validation_print_cols])
}

if (any(nzchar(validation_summary$errors))) {
  print(validation_summary[nzchar(errors)])
  stop(paste0("Pipeline validation errors found. See pipeline_validation_summary file"))
}

message("Pipeline completed. Validation summary:")
print(validation_summary[, .(stage, rows, columns, warnings)])
message("Output folder: ", pipeline_dir)
print(Sys.time())

invisible(out)

# ~ ----------------------------------------------- ####
###################################################### #

# REPLACE /data/blockgroupstats.rda etc. if ready  ####

# when ready to actually replace the old blockgroupstats dataset entirely:
if (interactive()) {
  if (askYesNo(
    "ready to REPLACE data/blockgroupstats.rda, bgej.rda, usastats.rda, statestats.rda in the package ? ")) {

    blockgroupstats <- out$blockgroupstats
    bgej <- out$bgej
    usastats <- out$usastats
    statestats <- out$statestats

    EJAM:::metadata_add_and_use_this("blockgroupstats")
    EJAM:::metadata_add_and_use_this("usastats")
    EJAM:::metadata_add_and_use_this("statestats")

    # EJAM:::metadata_add_and_use_this("bgej") # NO - this goes in ejamdata, not in the package datasets
    ### could use workaround for local testing where bgej.arrow gets saved locally in data folder
    ### but that does not translate to anyone else installing from github.
    ## could save as .rda and .arrow on s3 also,
    ## and maybe shift to getting it from there instead of from ejamdata
## for now save in s3 as rda and arrow. noting the old bgej.arrow is still in local data folder.
    EJAM:::ejscreen_pipeline_save(x = bgej, format = "rda", validate = F, storage = "s3", pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR"), stage = "bgej"  )
    EJAM:::ejscreen_pipeline_save(x = bgej, format = "arrow", validate = F, storage = "s3", pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR"), stage = "bgej"  )

    # [1] "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2024/bgej.rda"

    # rm(blockgroupstats, bgej, usastats, statestats)

    # rm(list=ls())
# restart, reinstall
  }
}
###################################################### #
# Create OTHER datasets / minor items? ####

## datacreate_avg.in.us.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_avg.in.us.R")
### this creates "avg.in.us" national averages of key indicators, for convenience, but also avgs are in usastats, statestats
# source("./data-raw/datacreate_avg.in.us.R")

# high_pctiles_tied_with_min.rda  also in case still used

## recreate the testoutput files via the scripts in data-raw
## such as  data-raw/datacreate_testpoints_testoutputs.R
# and data-raw/datacreate_testoutput_*.R


## etc. ####
###################################################### #
# cat("REBUILD/INSTALL THE PACKAGE NOW \n")
###################################################### #
