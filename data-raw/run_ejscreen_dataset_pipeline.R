###################################################### #
#
# Repeatable EJSCREEN/EJAM pipeline runner for data updates (ACS demographics, etc.)
#
# First review the settings carefully, below, and specify which other datasets
# to update via datacreate_ scripts, specified below.
#
# Then run this script via
#   source("data-raw/run_ejscreen_dataset_pipeline.R")
#
###################################################### #
# The pipeline process uses the following key helper functions for various stages,
# which are called from the script or from `calc_ejscreen_dataset()`:
#
# - `download_bg_acs_raw()`
# - `calc_bg_islandareasdata()`
# - `calc_bg_acsdata()`
# - `load_file_stage()` # or `get_reuse_blockgroupstats()` for environmental data
# - `calc_bg_extra_indicators()`
# - `calc_bg_geodata()`
# - `calc_ejscreen_dataset()` # to assemble all of the above
# - `ejscreen_pipeline_validate()`
#
# It also provides an option for sourcing various datacreate_*.R files
#   before and after the main pipeline stages, to handle some related files
#   that might need to be updated.
#
# Depending on specified year, storage location, and directory,
#   this pipeline writes csv (or other format) file checkpoints to a local folder
#   such as data-raw/pipeline_outputs/ejscreen_acs_2022
#   (as an example of local storage of the datasets used with 2018-2022 ACS data)
#   or AWS directory such as
#   s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2024
#   (as an example of S3 storage, for the datasets used with 2020-2024 ACS data).
#
# To rerun after updated environmental indicators are available:
#   1. Save the updated blockgroup-level environmental table as
#      bg_envirodata.csv (or format specified by stage_format) in the pipeline folder.
#      It must include columns "bgfips" and "pctpre1960",
#      plus the rest of the environmental indicators (those used for EJ indexes),
#       as specified in `EJAM::names_e`.
#   2. Source this script again. Existing raw ACS and bg_acsdata checkpoints are
#      reused, and downstream blockgroupstats/bgej/usastats/statestats are
#      recalculated from the updated file bg_envirodata.csv (or format specified by stage_format).
#
#  Also see ejscreen_pipeline_validate_vs_prior()
#  for comparing the outputs of this pipeline to the prior version of the data,
#  to help confirm that changes are as expected.
#
# Arrow assets are part of the EJAM/EJScreen release bundle. When EJAM later
# obtains Arrow files via dataload_dynamic(), it uses the ejamdata release tag
# recorded in DESCRIPTION as ejamdata_required_tag, rather than whichever
# ejamdata release GitHub currently marks as latest.
###################################################### #

# Useful environment variables, used as settings (parameters) customizing the pipeline:

#   EJAM_PIPELINE_YR: the last year of the 5-year ACS survey to use, e.g. 2022 or 2024. Default is the most recent year that is likely to be published by Census.

#   EJAM_PIPELINE_ROOT: parent folder/S3 prefix containing version folders such as ejscreen_acs_2024.
#   EJAM_PIPELINE_DIR: override output folder.
#   EJAM_PIPELINE_STORAGE: auto, local, or s3. auto treats s3:// paths as S3.
#   EJAM_STAGE_FORMAT: primary stage format used for loading/validation, usually csv.
#   EJAM_STAGE_FORMATS: comma-separated formats to save for table stages, usually csv,rda.
#   EJAM_BLOCKGROUP_UNIVERSE_SOURCE: acs or union. acs is recommended and means the ACS tabulated blockgroup rows define the final blockgroupstats universe.
#   EJAM_TRACT_WEIGHT_SOURCE: decennial2020 or acs. decennial2020 matches legacy EJSCREEN tract-to-blockgroup apportionment.
#   EJAM_DECENNIAL_BGWTS_CACHE: optional local .rds cache path for 2020 Decennial blockgroup-to-tract weights.
#   EJAM_REFRESH_DECENNIAL_BGWTS: TRUE to redownload and overwrite cached decennial weights.

#   EJAM_FORCE_ACS:        FALSE means reuse already-downloaded raw data. TRUE to redownload/recalculate raw ACS and bg_acsdata.
#   EJAM_FORCE_BG_ACSDATA: FALSE means reuse already calculated bg_acsdata if it exists (even if forcing redownload of raw ACS). TRUE to rebuild bg_acsdata from saved raw ACS.
#   EJAM_FORCE_BG_GEODATA: FALSE means reuse already downloaded Census/TIGER blockgroup geography. TRUE to redownload/recalculate bg_geodata.
#   EJAM_TIGER_BG_CACHE_DIR: optional local folder for downloaded Census TIGER/Line blockgroup zip files. Defaults to the EJAM user cache.
#   EJAM_ACS_DOWNLOAD_TIMEOUT
#   EJAM_ACS_DOWNLOAD_RETRIES
#   EJAM_INCLUDE_ISLANDAREAS_DATA: TRUE to append AS/GU/MP/VI blockgroups to
#      the annual/release pipeline. This defaults to TRUE so Island Areas appear
#      in blockgroupstats,
#      ejscreen_export, ejscreen_export_statepct, and map-ready outputs. These
#      rows are not ACS rows. By default, DHC demographics are NOT used in
#      bg_acsdata or downstream EJSCREEN-compatible outputs, because the
#      legacy EPA/EJScreen Island Areas rows had no usable ACS demographic
#      values. Row IDs, area fields, and available environmental fields come
#      from the archived EPA EJScreen ACS2022 reference file named by
#      EJAM_ISLANDAREAS_REFERENCE_PATH.
#      This does not enable point-buffer/radius analysis in Island Areas; that
#      path intentionally has no Island Area blocks in blockpoints/blockwts/etc.,
#      so reports there should return no-data results.
#   EJAM_ISLANDAREAS_REFERENCE_PATH: archived EPA EJScreen reference CSV used
#      for Island Areas row IDs, area fields, and available environmental fields.
#   EJAM_USE_ISLANDAREAS_DEMOGRAPHICS: TRUE to opt into using the 2020 Island
#      Areas Census DHC demographics in bg_acsdata. This creates a mixed-source
#      supplemental dataset and is not the default EJSCREEN replication path.

#   EJAM_USE_PROVISIONAL_BG_ENVIRODATA: TRUE means reuse envt data still in EJAM::blockgroupstats. FALSE to require bg_envirodata.csv or .xyz file.
#   EJAM_BG_ENVIRODATA_REFERENCE_PATH: optional EJSCREEN-style reference CSV
#      used only when deliberately creating or repairing a bg_envirodata source
#      stage. Normal annual and replication runs should use bg_envirodata as-is
#      after that source stage has been corrected. Missing values in the
#      reference are preserved as missing values.
#      This is important for drinking water: EJAM versions after v2.32.8.001
#      should not convert missing drinking-water scores to zero unless the
#      source explicitly reports zero.
#   EJAM_BG_ENVIRODATA_REFERENCE_VARS: comma-separated rname or EJSCREEN field
#      names to replace from EJAM_BG_ENVIRODATA_REFERENCE_PATH, e.g. "drinking"
#      or "DWATER".

#   EJAM_INCLUDE_EJSCREEN_EXPORT: TRUE to create ejscreen_export.csv or .xyz file.
#   EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT: TRUE to create
#      ejscreen_export_statepct.csv, an EPA StatePct-style export where state
#      raw scores and state percentiles are written into the ordinary EPA field
#      names, matching files like EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv.
#   EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS: TRUE to create
#      ejscreen_us_pctile_lookup.csv and ejscreen_state_pctile_lookup.csv,
#      EJScreen-style lookup tables corresponding to usastats/statestats and
#      files like EJScreen_2024_BG_National_Lookup.csv and
#      EJScreen_2024_BG_State_Lookup.csv. Defaults to
#      EJAM_INCLUDE_EJSCREEN_EXPORT.
#   EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT: TRUE to create the smaller
#      ejscreen_dataset_creator_input stage for EPA's Python dataset-creator
#      workflow.

#   EJAM_VALIDATE_VS_PRIOR: TRUE to compare selected outputs to a prior saved pipeline version and save prior_validation_*.txt and prior_validation_summary.csv.
#   EJAM_PRIOR_PIPELINE_YR: prior version year to compare against. Defaults to yr - 1.
#   EJAM_PRIOR_PIPELINE_DIR: optional explicit prior version folder/S3 prefix. If unset, constructed from EJAM_PIPELINE_ROOT and EJAM_PRIOR_PIPELINE_YR.
#   EJAM_PRIOR_PACKAGE_REF: optional explicit Git ref/tag/SHA holding a prior package blockgroupstats.rda, such as development or v2.32.8.001.
#   EJAM_PRIOR_PACKAGE_PATH: optional path within EJAM_PRIOR_PACKAGE_REF. Defaults to data/blockgroupstats.rda.
#   EJAM_EJSCREEN_EXPORT_REFERENCE_PATH: optional EPA-style EJSCREEN export CSV to compare with the ejscreen_export stage. For yr 2022, the default is the S3 copy of EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv, which is based on ACS 2018-2022.
#   EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH: optional EPA-style StatePct
#      export CSV to compare with ejscreen_export_statepct. For yr 2022, the
#      default is the S3 copy of EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv.
#   EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE: TRUE to create prior_validation_ejscreen_export_vs_epa_2024_acs2022* reports when a reference path is available.
#   EJAM_VALIDATE_VS_PRIOR_WALDO: TRUE to include optional waldo::compare() output in prior validation detail files.

#   EJAM_RUN_DATACREATE_BEFORE: TRUE to source selected datacreate_ scripts
#      before the main pipeline stages. Set FALSE for validation-only reruns.
#   EJAM_RUN_DATACREATE_AFTER: TRUE to source selected datacreate_ scripts
#      after the main pipeline stages. Set FALSE for validation-only reruns.
#   EJAM_REPLACE_PACKAGE_DATA: TRUE to replace package .rda datasets for
#      blockgroupstats/usastats/statestats without the interactive prompt.
#   EJAM_INCLUDE_FRS_UPDATE: TRUE to include data-raw/datacreate_frs_.R in
#      the post-pipeline datacreate_ scripts.

#   CENSUS_API_KEY: used by functions that download ACS data (or that download boundaries/shapefiles for FIPS from some sources)
###################################################### #

# DEFAULT SETTINGS  ####

# Load the package source before any pipeline helpers are called. This runner is
# often used before reinstalling EJAM, so relying on the installed namespace can
# silently use stale code when validation-only settings skip datacreate_ scripts.
if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}
library(data.table)

run_started_at <- Sys.time()

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
prior_yr <- as.character(as.integer(yr) - 1L)
default_tiger_bg_cache_dir <- file.path(tools::R_user_dir("EJAM", which = "cache"), "tiger_bg")

set_pipeline_default <- function(name, value) {
  if (!nzchar(Sys.getenv(name, unset = ""))) {
    do.call(Sys.setenv, as.list(stats::setNames(as.character(value), name)))
  }
}

set_pipeline_default("EJAM_PIPELINE_YR", yr)
set_pipeline_default("EJAM_PIPELINE_ROOT", dir_parent)
set_pipeline_default("EJAM_PIPELINE_STORAGE", storage)
set_pipeline_default("EJAM_PIPELINE_DIR", dir_full)
set_pipeline_default("EJAM_STAGE_FORMAT", "csv") # options are c("csv", "rds", "rda", "arrow")
set_pipeline_default("EJAM_STAGE_FORMATS", "csv,rda") # comma-separated list of formats to save
set_pipeline_default("EJAM_BLOCKGROUP_UNIVERSE_SOURCE", "acs")
set_pipeline_default("EJAM_TRACT_WEIGHT_SOURCE", "decennial2020")

set_pipeline_default("EJAM_FORCE_ACS", "FALSE")
set_pipeline_default("EJAM_FORCE_BG_ACSDATA", "FALSE")
set_pipeline_default("EJAM_FORCE_BG_GEODATA", "FALSE")
set_pipeline_default("EJAM_TIGER_BG_CACHE_DIR", default_tiger_bg_cache_dir)
set_pipeline_default("EJAM_ACS_DOWNLOAD_TIMEOUT", "3600")
set_pipeline_default("EJAM_ACS_DOWNLOAD_RETRIES", "2")
set_pipeline_default("EJAM_INCLUDE_ISLANDAREAS_DATA", "TRUE")
set_pipeline_default("EJAM_ISLANDAREAS_REFERENCE_PATH", EJAM:::islandareas_epa_reference_default_path())
set_pipeline_default("EJAM_USE_ISLANDAREAS_DEMOGRAPHICS", "FALSE")

set_pipeline_default("EJAM_USE_PROVISIONAL_BG_ENVIRODATA", "FALSE")
set_pipeline_default("EJAM_BG_ENVIRODATA_REFERENCE_PATH", "")
set_pipeline_default("EJAM_BG_ENVIRODATA_REFERENCE_VARS", "")

set_pipeline_default("EJAM_INCLUDE_EJSCREEN_EXPORT", "TRUE")
set_pipeline_default("EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT", "FALSE")

set_pipeline_default("EJAM_VALIDATE_VS_PRIOR", "TRUE")
set_pipeline_default("EJAM_PRIOR_PIPELINE_YR", prior_yr)
set_pipeline_default("EJAM_PRIOR_PIPELINE_DIR", "")
set_pipeline_default("EJAM_PRIOR_PACKAGE_REF", "")
set_pipeline_default("EJAM_PRIOR_PACKAGE_PATH", "data/blockgroupstats.rda")
set_pipeline_default("EJAM_EJSCREEN_EXPORT_REFERENCE_PATH", "")
set_pipeline_default("EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE", "TRUE")
set_pipeline_default("EJAM_VALIDATE_VS_PRIOR_WALDO", "FALSE")

set_pipeline_default("EJAM_RUN_DATACREATE_BEFORE", "TRUE")
set_pipeline_default("EJAM_RUN_DATACREATE_AFTER", "TRUE")
set_pipeline_default("EJAM_REPLACE_PACKAGE_DATA", "FALSE")
set_pipeline_default("EJAM_INCLUDE_FRS_UPDATE", "FALSE")

###################################################### ####################################################### #

pipeline_env_flag <- function(name, default = FALSE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "TRUE" else "FALSE")
  toupper(value) %in% c("1", "TRUE", "YES", "Y")
}

run_datacreate_before <- pipeline_env_flag("EJAM_RUN_DATACREATE_BEFORE", TRUE)
run_datacreate_after <- pipeline_env_flag("EJAM_RUN_DATACREATE_AFTER", TRUE)
replace_package_data <- pipeline_env_flag("EJAM_REPLACE_PACKAGE_DATA", FALSE)
include_frs_update <- pipeline_env_flag("EJAM_INCLUDE_FRS_UPDATE", FALSE)

# Specifying OTHER datasets to update ####

# The pipeline is primarily focused on updating
# blockgroupstats and bgej, percentile lookup tables, and the EJScreen file.
# Various other datasets generally need to be checked or updated
# just before or just after those main blockgroup datasets are updated.
# Some shown here are optional, though.
# To check the current list of such scripts:
# dput( dir(pattern = "^datacreate_", recursive = TRUE) )
# Uncomment the lines below to run selected datacreate_ scripts.
# Any of them can be done manually and not all are essential.
###################################################### #
datacreate_scripts_to_run_before_pipeline <- c(

  ### ANNUAL UPDATES that must be done BEFORE pipeline updates most files

  ## Census Bureau data to check/update ANNUALLY, if geo data has changed
  ##
  ##     cities, states, island areas
  "data-raw/datacreate_states_shapefile.R", # census bureau data - downloads latest state boundaries that correspond to the ACS dataset.
  "data-raw/datacreate_stateinfo.R",    # census bureau data - table of state fips and centroids, unlikely to change but if done should do BEFORE pipeline.  makes stateinfo with a few columns
  "data-raw/datacreate_stateinfo2.R",   # census bureau data - table of state info, unlikely to change but if done should do BEFORE pipeline.   makes stateinfo2 with more columns
  "data-raw/datacreate_censusplaces.R", # census bureau data - table of cities, etc. - download from Census Bureau. Source data did not change 2025 through 5/2026. Relevant to updating testinput_fips_cities and testoutput_ejamit_fips_cities
  "data-raw/datacreate_islandareas.R",  # unlikely to change, just a file with latlon info
  "data-raw/datacreate_lat_alias.R",    # unlikely to change
  ##
  ##     block and blockgroup helper files
  ##
  ## Do not run these automatically for the v2.5.0 ACS 2020-2024 pipeline:
  ##
  ##   "data-raw/datacreate_bg_cenpop2020.R"
  ##   "data-raw/datacreate_bgpts.R"
  ##   "data-raw/datacreate_blockwts.R"
  ##
  ## For v2.5.0, keep the current EPA/EJScreen adjusted 2020-to-2022
  ## block helper Arrow files: blockwts, blockpoints, blockid2fips,
  ## bgid2fips, and quaddata.
  ##
  ## Reason: the current helper universe is an internally consistent
  ## superset of the ACS 2020-2024 blockgroupstats universe. Raw Census
  ## 2020 regeneration reintroduces the CT ACS 2022+ geography mismatch.
  ## Island Areas AS/GU/MP/VI are visible only in blockgroup dataset/export/map
  ## outputs for v2.5.0. Do not add Island Area blocks to these helper files
  ## for this release path; radius/buffer reports there should return no-data
  ## results rather than block-weighted estimates.
  ## If these helper files are refreshed later, do it as a separate,
  ## explicit geography-helper refresh with CT/NY setdiff checks and a
  ## bgid compatibility check against blockgroupstats and bgid2fips.

  ## Variable names (indicators), metadata, and formulas to check/update ANNUALLY, if the set of indicators or formulas have changed.
  ##
  ##     map_headernames is IMPORTANT TO CHECK/UPDATE CAREFULLY YEARLY.
  ##     Edit data-raw/map_headernames.csv directly, then run
  ##     data-raw/datacreate_map_headernames.R to validate/save the package data
  ##     before running the annual pipeline. Do not use the old .xlsx workflow
  ##     or one-off scripts that modify map_headernames after the CSV is read.
  # "data-raw/datacreate_map_headernames.R",            # run manually after CSV edits, before pipeline use
  # "data-raw/datacreate_map_headernames_fix_dupes.R",   # obsolete notes only; do not source
  ##
  "data-raw/datacreate_names_of_indicators.R",   # must do AFTER any map_headernames changes but BEFORE pipeline is done (probably), if names/varlists like names_e change
  "data-raw/datacreate_names_pct_as_fraction.R", # must do AFTER any map_headernames changes
  ##
  ##    Formulas for calculating indicators, which ACS tables are needed, etc., if that has changed.
  ##
  "data-raw/datacreate_tables_ejscreen_acs.R",  # must be ready/done BEFORE pipeline used
  "data-raw/datacreate_formulas_ejscreen_acs_pctdisability.R", # might not change in a given year, but if census variable names or tables change, use this and it must be done BEFORE the pipeline is run if formulas have been changed.
  "data-raw/datacreate_formulas_ejscreen_demog_index.R"        # might not change in a given year, but if census variable names or tables change, use this and it must be done BEFORE the pipeline is run if formulas have been changed.

)
###################################################### #
datacreate_scripts_to_run_after_pipeline <- c(

  ### ANNUAL UPDATES that must be done AFTER pipeline updates most files

  "data-raw/datacreate_high_pctiles_tied_with_min.R", # may be obsolete; helped with percentile lookups
  "data-raw/datacreate_avg.in.us.R",   # creates "avg.in.us" national averages of key indicators, for convenience

  #"data-raw/datacreate_runtime_models.R", # stores info on how long it took to run ejamit or doaggregate etc. to help predict ETA of large analysis

  "data-raw/datacreate_testinput_fips.R", # do AFTER updating censusplaces, pipeline (blockgroupstats), etc., in case those test fips changed
  "data-raw/datacreate_testpoints_testoutputs.R",  # must be done AFTER pipeline changes blockgroupstats, etc.
  "data-raw/datacreate_testoutput_ejamit_fips_.R",  # must be done AFTER pipeline updates blockgroupstats, avg in us, pctiles, etc., and AFTER states_shapefile is updated, and AFTER testinputs done
  "data-raw/datacreate_testoutput_ejamit_shapes_2.R"  # must be done AFTER pipeline updates blockgroupstats, avg in us, pctiles, etc., and AFTER states_shapefile is updated, and AFTER testinputs done

)
if (isTRUE(include_frs_update)) {
  datacreate_scripts_to_run_after_pipeline <- c(
    "data-raw/datacreate_frs_.R",
    datacreate_scripts_to_run_after_pipeline
  )
}
###################################################### #

###################################################### #
cat("To open script files, in case you need to check or update them, or to step through them manually, see: \n")
for (fpath in datacreate_scripts_to_run_before_pipeline) {
  cat(paste0("rstudioapi::documentOpen('", fpath,"')"), '\n')
}
for (fpath in datacreate_scripts_to_run_after_pipeline) {
  cat(paste0("rstudioapi::documentOpen('", fpath,"')"), '\n')
}

###################################################### #
# Create OTHER datasets  ####
#
#   must be done BEFORE new blockgroup datasets are created !

if (isTRUE(run_datacreate_before)) {
  for (fpath in datacreate_scripts_to_run_before_pipeline) {
    cat("sourcing the script in", fpath, "...\n")
    source(fpath)
  }
} else {
  message("Skipping pre-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_BEFORE is FALSE.")
}
###################################################### #


###################################################### ####################################################### #

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
#            EJAM_STAGE_FORMAT = "csv",  # primary format for loading/validation
#            EJAM_STAGE_FORMATS = "csv,rda",  # formats to save
#            EJAM_BLOCKGROUP_UNIVERSE_SOURCE = "acs",
#            EJAM_TRACT_WEIGHT_SOURCE = "decennial2020",
#            EJAM_FORCE_ACS = FALSE,    # FALSE means reuse if already had downloaded.
#            EJAM_FORCE_BG_ACSDATA = FALSE, # or as needed
#            EJAM_FORCE_BG_GEODATA = FALSE,
#            EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
#            EJAM_ACS_DOWNLOAD_RETRIES = "2",
#            EJAM_INCLUDE_ISLANDAREAS_DATA = FALSE,
#            EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = FALSE,
#      EJAM_USE_PROVISIONAL_BG_ENVIRODATA = TRUE, # TRUE during testing not once finalized datasets - TO TRY TO REPLICATE 2022 DATA
#      EJAM_INCLUDE_EJSCREEN_EXPORT = TRUE,
#            EJAM_VALIDATE_VS_PRIOR = TRUE,
#            EJAM_PRIOR_PIPELINE_YR = "2021", # ignored when EJAM_PRIOR_PACKAGE_REF is set
#            EJAM_PRIOR_PIPELINE_DIR = "",
#            EJAM_PRIOR_PACKAGE_REF = "development",
#            EJAM_PRIOR_PACKAGE_PATH = "data/blockgroupstats.rda",
#            EJAM_EJSCREEN_EXPORT_REFERENCE_PATH = "",
#            EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE = TRUE,
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
#            EJAM_STAGE_FORMAT = "csv",  # primary format for loading/validation
#            EJAM_STAGE_FORMATS = "csv,rda",  # formats to save
#            EJAM_BLOCKGROUP_UNIVERSE_SOURCE = "acs",
#            EJAM_TRACT_WEIGHT_SOURCE = "decennial2020",
#         #    #   EJAM_PIPELINE_STORAGE = "local",
#            EJAM_FORCE_ACS = TRUE,    # FALSE means reuse if already had downloaded.
#            EJAM_FORCE_BG_ACSDATA = TRUE, # or as needed
#            EJAM_FORCE_BG_GEODATA = TRUE,
#            EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
#            EJAM_ACS_DOWNLOAD_RETRIES = "2",
#            EJAM_INCLUDE_ISLANDAREAS_DATA = TRUE,
#            EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = FALSE,
#         EJAM_USE_PROVISIONAL_BG_ENVIRODATA = TRUE, #  set FALSE once new envt data are available
#         EJAM_INCLUDE_EJSCREEN_EXPORT = TRUE,
#            EJAM_VALIDATE_VS_PRIOR = TRUE,
#            EJAM_PRIOR_PIPELINE_YR = "2023",
#            EJAM_PRIOR_PIPELINE_DIR = "",
#            EJAM_PRIOR_PACKAGE_REF = "",
#            EJAM_PRIOR_PACKAGE_PATH = "data/blockgroupstats.rda",
#            EJAM_EJSCREEN_EXPORT_REFERENCE_PATH = "",
#            EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE = FALSE,
#            EJAM_VALIDATE_VS_PRIOR_WALDO = FALSE
# )
###################################################### #
## To check them:
#
print(
  cbind(current_setting = Sys.getenv(c(
    'EJAM_PIPELINE_YR',
    'EJAM_PIPELINE_ROOT',
    'EJAM_PIPELINE_DIR',
    'EJAM_PIPELINE_STORAGE',
    'EJAM_STAGE_FORMAT',
    'EJAM_STAGE_FORMATS',
    'EJAM_BLOCKGROUP_UNIVERSE_SOURCE',
    'EJAM_TRACT_WEIGHT_SOURCE',
    'EJAM_DECENNIAL_BGWTS_CACHE',
    'EJAM_REFRESH_DECENNIAL_BGWTS',

    'EJAM_FORCE_ACS',
    'EJAM_FORCE_BG_ACSDATA',
    'EJAM_FORCE_BG_GEODATA',
    'EJAM_TIGER_BG_CACHE_DIR',
    'EJAM_ACS_DOWNLOAD_TIMEOUT',
    'EJAM_ACS_DOWNLOAD_RETRIES',
    'EJAM_INCLUDE_ISLANDAREAS_DATA',
    'EJAM_ISLANDAREAS_REFERENCE_PATH',
    'EJAM_USE_ISLANDAREAS_DEMOGRAPHICS',
    'EJAM_USE_PROVISIONAL_BG_ENVIRODATA',
    'EJAM_INCLUDE_EJSCREEN_EXPORT',
    'EJAM_VALIDATE_VS_PRIOR',
    'EJAM_PRIOR_PIPELINE_YR',
    'EJAM_PRIOR_PIPELINE_DIR',
    'EJAM_PRIOR_PACKAGE_REF',
    'EJAM_PRIOR_PACKAGE_PATH',
    'EJAM_EJSCREEN_EXPORT_REFERENCE_PATH',
    'EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE',
    'EJAM_VALIDATE_VS_PRIOR_WALDO',
    'EJAM_RUN_DATACREATE_BEFORE',
    'EJAM_RUN_DATACREATE_AFTER',
    'EJAM_REPLACE_PACKAGE_DATA',
    'EJAM_INCLUDE_FRS_UPDATE'
  )))
)
###################################################### #
#
# VALIDATION VS A SPECIFIC PRIOR DATASET ####
#
# If EJAM_VALIDATE_VS_PRIOR is TRUE, this script compares the new saved pipeline
# stages to a prior saved pipeline version. Use EJAM_PRIOR_PIPELINE_YR or
# EJAM_PRIOR_PIPELINE_DIR to control the comparison target.

###################################################### #

# get settings ####

env_flag <- function(name, default = FALSE) {
  value <- Sys.getenv(name, unset = if (isTRUE(default)) "TRUE" else "FALSE")
  toupper(value) %in% c("1", "TRUE", "YES", "Y")
}

env_csv <- function(name) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) {
    return(character())
  }
  out <- trimws(strsplit(value, ",", fixed = TRUE)[[1]])
  out[nzchar(out)]
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
pipeline_root <- Sys.getenv(
  "EJAM_PIPELINE_ROOT",
  unset = if (grepl("/ejscreen_acs_[0-9]+/?$", pipeline_dir)) dirname(pipeline_dir) else "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
)
pipeline_storage <- Sys.getenv("EJAM_PIPELINE_STORAGE", unset = "auto")
pipeline_storage <- match.arg(pipeline_storage, c("auto", "local", "s3"))
pipeline_storage <- EJAM:::ejscreen_pipeline_storage_backend(pipeline_dir, storage = pipeline_storage)
if (pipeline_storage == "local") {
  dir.create(pipeline_dir, recursive = TRUE, showWarnings = FALSE)
}
stage_format <- Sys.getenv("EJAM_STAGE_FORMAT", unset = "csv")
stage_formats <- trimws(strsplit(Sys.getenv("EJAM_STAGE_FORMATS", unset = stage_format), ",", fixed = TRUE)[[1]])
stage_formats <- unique(stage_formats[nzchar(stage_formats)])
stage_formats <- intersect(stage_formats, c("csv", "rds", "rda", "arrow"))
if (!stage_format %in% stage_formats) {
  stage_formats <- c(stage_format, stage_formats)
}
blockgroup_universe_source <- Sys.getenv("EJAM_BLOCKGROUP_UNIVERSE_SOURCE", unset = "acs")
blockgroup_universe_source <- match.arg(blockgroup_universe_source, c("acs", "union"))
tract_weight_source <- Sys.getenv("EJAM_TRACT_WEIGHT_SOURCE", unset = "decennial2020")
tract_weight_source <- match.arg(tract_weight_source, c("decennial2020", "acs"))

message("Pipeline folder: ", pipeline_dir)
message("Pipeline storage: ", pipeline_storage)
message("File format aka stage_format: ", stage_format)
message("Saved stage formats: ", paste(stage_formats, collapse = ", "))
message("Blockgroup universe source: ", blockgroup_universe_source)
message("Tract apportionment weight source: ", tract_weight_source)

### ACS DEMOGRAPHIC DATA settings ####

force_acs <- env_flag("EJAM_FORCE_ACS", FALSE)
force_bg_acsdata <- env_flag("EJAM_FORCE_BG_ACSDATA", force_acs)
force_bg_geodata <- env_flag("EJAM_FORCE_BG_GEODATA", FALSE)
tiger_bg_cache_dir <- Sys.getenv("EJAM_TIGER_BG_CACHE_DIR", unset = default_tiger_bg_cache_dir)
acs_download_timeout <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_TIMEOUT", unset = "3600"))
acs_download_retries <- as.integer(Sys.getenv("EJAM_ACS_DOWNLOAD_RETRIES", unset = "2"))
include_islandareas_data <- env_flag("EJAM_INCLUDE_ISLANDAREAS_DATA", TRUE)
islandareas_reference_path <- Sys.getenv(
  "EJAM_ISLANDAREAS_REFERENCE_PATH",
  unset = EJAM:::islandareas_epa_reference_default_path()
)
use_islandareas_demographics <- env_flag("EJAM_USE_ISLANDAREAS_DEMOGRAPHICS", FALSE)

### ENVIRONMENTAL DATA settings ####

use_provisional_bg_envirodata <- env_flag("EJAM_USE_PROVISIONAL_BG_ENVIRODATA", FALSE)
bg_envirodata_reference_path <- Sys.getenv("EJAM_BG_ENVIRODATA_REFERENCE_PATH", unset = "")
bg_envirodata_reference_vars <- env_csv("EJAM_BG_ENVIRODATA_REFERENCE_VARS")

### EJSCREEN DATASET EXPORT settings ####

include_ejscreen_export <- env_flag("EJAM_INCLUDE_EJSCREEN_EXPORT", TRUE)
include_ejscreen_export_statepct <- env_flag("EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT", include_ejscreen_export)
include_ejscreen_pctile_lookup_exports <- env_flag("EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS", include_ejscreen_export)
include_ejscreen_dataset_creator_input <- env_flag("EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT", FALSE)

### validation vs prior data  ####

validate_vs_prior <- env_flag("EJAM_VALIDATE_VS_PRIOR", TRUE)
validate_vs_prior_waldo <- env_flag("EJAM_VALIDATE_VS_PRIOR_WALDO", FALSE)
ejscreen_export_reference_path <- Sys.getenv("EJAM_EJSCREEN_EXPORT_REFERENCE_PATH", unset = "")
ejscreen_export_statepct_reference_path <- Sys.getenv("EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH", unset = "")
if (!nzchar(ejscreen_export_reference_path) &&
    identical(as.character(pipeline_yr), "2022") &&
    identical(pipeline_storage, "s3")) {
  ejscreen_export_reference_path <- paste0(
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/",
    "ejscreen_acs_2022/epa_original_reference/2024_2.32_August_UseMe/",
    "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv"
  )
}
if (!nzchar(ejscreen_export_statepct_reference_path) &&
    identical(as.character(pipeline_yr), "2022") &&
    identical(pipeline_storage, "s3")) {
  ejscreen_export_statepct_reference_path <- paste0(
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/",
    "ejscreen_acs_2022/epa_original_reference/2024_2.32_August_UseMe/",
    "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv"
  )
}
validate_ejscreen_export_reference <- env_flag(
  "EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE",
  nzchar(ejscreen_export_reference_path) || nzchar(ejscreen_export_statepct_reference_path)
)
prior_pipeline_yr <- Sys.getenv(
  "EJAM_PRIOR_PIPELINE_YR",
  unset = as.character(as.integer(pipeline_yr) - 1L)
)
prior_pipeline_dir <- Sys.getenv("EJAM_PRIOR_PIPELINE_DIR", unset = "")
if (!nzchar(prior_pipeline_dir)) {
  prior_pipeline_dir <- EJAM:::ejscreen_pipeline_version_dir(prior_pipeline_yr, root = pipeline_root)
}
prior_package_ref <- Sys.getenv("EJAM_PRIOR_PACKAGE_REF", unset = "")
prior_package_path <- Sys.getenv("EJAM_PRIOR_PACKAGE_PATH", unset = "data/blockgroupstats.rda")

EJAM:::ejscreen_pipeline_validate_year_dir(pipeline_yr, pipeline_dir)
if (!nzchar(prior_package_ref)) {
  EJAM:::ejscreen_pipeline_validate_year_dir(prior_pipeline_yr, prior_pipeline_dir)
}

pipeline_setting_names <- c(
  'EJAM_PIPELINE_YR',
  'EJAM_PIPELINE_ROOT',
  'EJAM_PIPELINE_DIR',
  'EJAM_PIPELINE_STORAGE',
  'EJAM_STAGE_FORMAT',
  'EJAM_STAGE_FORMATS',
  'EJAM_BLOCKGROUP_UNIVERSE_SOURCE',
  'EJAM_TRACT_WEIGHT_SOURCE',
  'EJAM_DECENNIAL_BGWTS_CACHE',
  'EJAM_REFRESH_DECENNIAL_BGWTS',
  'EJAM_FORCE_ACS',
  'EJAM_FORCE_BG_ACSDATA',
  'EJAM_FORCE_BG_GEODATA',
  'EJAM_TIGER_BG_CACHE_DIR',
  'EJAM_ACS_DOWNLOAD_TIMEOUT',
  'EJAM_ACS_DOWNLOAD_RETRIES',
  'EJAM_INCLUDE_ISLANDAREAS_DATA',
  'EJAM_ISLANDAREAS_REFERENCE_PATH',
  'EJAM_USE_ISLANDAREAS_DEMOGRAPHICS',
  'EJAM_USE_PROVISIONAL_BG_ENVIRODATA',
  'EJAM_BG_ENVIRODATA_REFERENCE_PATH',
  'EJAM_BG_ENVIRODATA_REFERENCE_VARS',
  'EJAM_INCLUDE_EJSCREEN_EXPORT',
  'EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT',
  'EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS',
  'EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT',
  'EJAM_VALIDATE_VS_PRIOR',
  'EJAM_PRIOR_PIPELINE_YR',
  'EJAM_PRIOR_PIPELINE_DIR',
  'EJAM_PRIOR_PACKAGE_REF',
  'EJAM_PRIOR_PACKAGE_PATH',
  'EJAM_EJSCREEN_EXPORT_REFERENCE_PATH',
  'EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH',
  'EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE',
  'EJAM_VALIDATE_VS_PRIOR_WALDO',
  'EJAM_RUN_DATACREATE_BEFORE',
  'EJAM_RUN_DATACREATE_AFTER',
  'EJAM_REPLACE_PACKAGE_DATA',
  'EJAM_INCLUDE_FRS_UPDATE',
  'AWS_PROFILE',
  'AWS_REGION'
)

#################################################### #
print(
  cbind(Sys.getenv = Sys.getenv(pipeline_setting_names),
        using_here = c(
          pipeline_yr = pipeline_yr,
          pipeline_root=pipeline_root,
          pipeline_dir=pipeline_dir,
          pipeline_storage=pipeline_storage,
          stage_format=stage_format,
          stage_formats=paste(stage_formats, collapse = ","),
          blockgroup_universe_source=blockgroup_universe_source,
          tract_weight_source=tract_weight_source,
          decennial_bgwts_cache = Sys.getenv("EJAM_DECENNIAL_BGWTS_CACHE"),
          refresh_decennial_bgwts = Sys.getenv("EJAM_REFRESH_DECENNIAL_BGWTS"),

          force_acs=force_acs,
          force_bg_acsdata=force_bg_acsdata,
          force_bg_geodata=force_bg_geodata,
          tiger_bg_cache_dir=tiger_bg_cache_dir,
          acs_download_timeout=acs_download_timeout,
          acs_download_retries=acs_download_retries,
          include_islandareas_data=include_islandareas_data,
          islandareas_reference_path=islandareas_reference_path,
          use_islandareas_demographics=use_islandareas_demographics,

          use_provisional_bg_envirodata=use_provisional_bg_envirodata,
          bg_envirodata_reference_path=bg_envirodata_reference_path,
          bg_envirodata_reference_vars=paste(bg_envirodata_reference_vars, collapse = ","),

          include_ejscreen_export=include_ejscreen_export,
          include_ejscreen_export_statepct=include_ejscreen_export_statepct,
          include_ejscreen_pctile_lookup_exports=include_ejscreen_pctile_lookup_exports,
          include_ejscreen_dataset_creator_input=include_ejscreen_dataset_creator_input,

          validate_vs_prior=validate_vs_prior,
          prior_pipeline_yr=prior_pipeline_yr,
          prior_pipeline_dir=prior_pipeline_dir,
          prior_package_ref=prior_package_ref,
          prior_package_path=prior_package_path,
          ejscreen_export_reference_path=ejscreen_export_reference_path,
          ejscreen_export_statepct_reference_path=ejscreen_export_statepct_reference_path,
          validate_ejscreen_export_reference=validate_ejscreen_export_reference,
          validate_vs_prior_waldo=validate_vs_prior_waldo,
          run_datacreate_before=run_datacreate_before,
          run_datacreate_after=run_datacreate_after,
          replace_package_data=replace_package_data,
          include_frs_update=include_frs_update,
          AWS_PROFILE=Sys.getenv("AWS_PROFILE"),
          AWS_REGION=Sys.getenv("AWS_REGION")
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
reuse_blockgroupstats <- NULL
get_reuse_blockgroupstats <- function() {
  if (!is.null(reuse_blockgroupstats)) {
    return(reuse_blockgroupstats)
  }

  pipeline_acs_version <- EJAM:::ejscreen_pipeline_acs_version_from_year(pipeline_yr)
  current <- data.table::as.data.table(data.table::copy(EJAM::blockgroupstats))
  current_acs_version <- EJAM:::ejscreen_pipeline_detect_acs_version(current)

  if (!is.na(current_acs_version) &&
      identical(current_acs_version, pipeline_acs_version)) {
    reuse_blockgroupstats <<- current
    return(reuse_blockgroupstats)
  }

  if (nzchar(prior_package_ref)) {
    prior <- tryCatch(
      EJAM:::ejscreen_pipeline_load_git_data_object(
        ref = prior_package_ref,
        path = prior_package_path
      ),
      error = function(e) {
        warning(
          "Could not load prior package blockgroupstats from ",
          prior_package_ref,
          ":",
          prior_package_path,
          " for same-vintage provisional reuse: ",
          conditionMessage(e),
          call. = FALSE
        )
        NULL
      }
    )
    if (!is.null(prior)) {
      prior_data <- data.table::as.data.table(data.table::copy(prior$data))
      if (!is.na(prior$acs_version) &&
          identical(prior$acs_version, pipeline_acs_version)) {
        reuse_blockgroupstats <<- prior_data
        return(reuse_blockgroupstats)
      }
      warning(
        "Prior package blockgroupstats ACS version is ",
        prior$acs_version,
        ", while this pipeline run is for ",
        pipeline_acs_version,
        "; not using that prior object for provisional reuse.",
        call. = FALSE
      )
    }
  }

  warning(
    "Using currently packaged EJAM::blockgroupstats for provisional reuse even though its ACS version is ",
    current_acs_version,
    " and this pipeline run is for ",
    pipeline_acs_version,
    ". Prefer a matching saved stage or set EJAM_PRIOR_PACKAGE_REF to a same-vintage package tag.",
    call. = FALSE
  )
  reuse_blockgroupstats <<- current
  reuse_blockgroupstats
}
####################### #
save_file_stage_formats <- function(x,
                                    stage,
                                    formats = stage_formats,
                                    object_name = stage,
                                    validate = TRUE) {
  saved <- stats::setNames(character(), character())
  for (fmt in formats) {
    if (is.null(x)) {
      next
    }
    saved[[fmt]] <- EJAM:::ejscreen_pipeline_save(
      x = x,
      stage = stage,
      pipeline_dir = pipeline_dir,
      format = fmt,
      object_name = object_name,
      overwrite = TRUE,
      validate = validate,
      yr = pipeline_yr,
      storage = pipeline_storage
    )
  }
  invisible(saved)
}
####################### #
save_secondary_stage_formats <- function(out, stages, primary_format = stage_format) {
  secondary_formats <- setdiff(stage_formats, primary_format)
  if (length(secondary_formats) == 0) {
    return(invisible(NULL))
  }
  for (stagename in intersect(stages, names(out))) {
    save_file_stage_formats(
      x = out[[stagename]],
      stage = stagename,
      formats = secondary_formats,
      validate = TRUE
    )
  }
  invisible(NULL)
}
####################### #
used_provisional_bg_envirodata <- FALSE
used_provisional_bg_extra_indicators <- FALSE
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
# ~ ----------------------------------------------- ####
###################################################### #
# Download ACS raw blockgroup data stage ####
###################################################### #

need_bg_acsdata <- force_bg_acsdata || include_islandareas_data || !stage_exists("bg_acsdata")
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
if (!is.null(bg_acs_raw)) {
  raw_object_formats <- setdiff(stage_formats, "csv")
  if (length(raw_object_formats) > 0) {
    save_file_stage_formats(
      x = bg_acs_raw,
      stage = stagename,
      formats = raw_object_formats,
      object_name = stagename,
      validate = FALSE
    )
  }
}
###################################################### #
# Prepare Island Areas blockgroup reference / optional Census DHC stages ####
###################################################### #

bg_islandareas_raw <- NULL
bg_islandareas_demographics <- NULL
bg_islandareas_reference <- NULL
if (isTRUE(include_islandareas_data) && isTRUE(need_bg_acsdata)) {
  if (!isTRUE(use_islandareas_demographics)) {
    message("Loading Island Areas rows from archived EPA EJScreen reference")
    bg_islandareas_reference <- EJAM:::load_islandareas_epa_reference(
      path = islandareas_reference_path,
      storage = pipeline_storage
    )
  } else {
    stagename <- "bg_islandareas_demographics"
    message(paste0("Stage: ", stagename))
    if (!isTRUE(force_acs) && stage_exists(stagename)) {
      message(paste0("Using provided/existing ", stagename))
      bg_islandareas_demographics <- load_file_stage(stagename)
      save_file_stage_formats(bg_islandareas_demographics, stage = stagename)
    } else {
      raw_stagename <- "bg_islandareas_raw"
      message(paste0("Stage: ", raw_stagename))
      if (!isTRUE(force_acs) && stage_exists(raw_stagename)) {
        message(paste0("Using provided/existing ", raw_stagename))
        bg_islandareas_raw <- load_file_stage(raw_stagename)
      } else {
        message("Creating bg_islandareas_raw from 2020 Island Areas Census DHC")
        bg_islandareas_raw <- EJAM:::download_bg_islandareas_raw()
        raw_object_formats <- intersect(stage_formats, c("rds", "rda"))
        if (length(raw_object_formats) > 0) {
          save_file_stage_formats(
            x = bg_islandareas_raw,
            stage = raw_stagename,
            formats = raw_object_formats,
            object_name = raw_stagename,
            validate = TRUE
          )
        }
      }

      message("Creating bg_islandareas_demographics from bg_islandareas_raw")
      bg_islandareas_demographics <- EJAM:::calc_bg_islandareasdata(bg_islandareas_raw)
      save_file_stage_formats(
        x = bg_islandareas_demographics,
        stage = stagename,
        formats = stage_formats,
        object_name = stagename,
        validate = TRUE
      )
    }
  }
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
    include_islandareas_data = include_islandareas_data,
    islandareas_raw = bg_islandareas_raw,
    islandareas_demographics = bg_islandareas_demographics,
    islandareas_reference = bg_islandareas_reference,
    use_islandareas_demographics = use_islandareas_demographics,
    tract_weight_source = tract_weight_source,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    overwrite = TRUE
  )
  save_file_stage_formats(bg_acsdata, stage = stagename)
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
  message(paste0("Creating PROVISIONAL bg_envirodata.", stage_format," from same-vintage blockgroupstats fallback"))
  used_provisional_bg_envirodata <- TRUE
  reusable_blockgroupstats <- get_reuse_blockgroupstats()
  package_blockgroupstats_acs_version <- EJAM:::ejscreen_pipeline_detect_acs_version(x = reusable_blockgroupstats)
  pipeline_acs_version <- EJAM:::ejscreen_pipeline_acs_version_from_year(pipeline_yr)
  if (!is.na(package_blockgroupstats_acs_version) &&
      !identical(package_blockgroupstats_acs_version, pipeline_acs_version)) {
    warning(
      "Provisional bg_envirodata is being copied from packaged EJAM::blockgroupstats with ACS version ",
      package_blockgroupstats_acs_version,
      ", while this pipeline run is for ACS version ",
      pipeline_acs_version,
      ". Replace this provisional file before final release use.",
      call. = FALSE
    )
  }
  if (!all(EJAM::names_e %in% names(reusable_blockgroupstats))) {
    warning("Provisional blockgroupstats fallback does not have all of expected env indicator columns as specified in EJAM::names_e")
  }
  env_cols <- intersect(EJAM::names_e, names(reusable_blockgroupstats))
  bg_envirodata <- as.data.table(reusable_blockgroupstats)[, c("bgfips", env_cols), with = FALSE]
  # validate the provisional copy
  if (!isTRUE(all.equal(
    as.data.table(reusable_blockgroupstats)[, env_cols, with = FALSE],
    bg_envirodata[, env_cols, with = FALSE],
    check.attributes = FALSE
  ))) {stop("Provisional bg_envirodata from blockgroupstats fallback does not have the same env indicator values as the fallback source")}
  write_pipeline_text(
    c(
      paste0("PROVISIONAL bg_envirodata.", stage_format),
      "This file was copied from the same-vintage blockgroupstats fallback.",
      paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
      paste("Pipeline ACS version:", pipeline_acs_version),
      "Replace it with updated environmental indicators and rerun data-raw/run_ejscreen_dataset_pipeline.R.",
      paste("Created:", Sys.time())
    ),
    "bg_envirodata_SOURCE.txt"
  )
} else {
  stop("Missing bg_envirodata file and use_provisional_bg_envirodata was set FALSE. Save updated environmental indicators there or set EJAM_USE_PROVISIONAL_BG_ENVIRODATA=TRUE")
}

if (nzchar(bg_envirodata_reference_path)) {
  if (length(bg_envirodata_reference_vars) == 0) {
    stop(
      "EJAM_BG_ENVIRODATA_REFERENCE_PATH was provided, but ",
      "EJAM_BG_ENVIRODATA_REFERENCE_VARS is empty. Specify the selected ",
      "rname or EJSCREEN field names to replace, such as drinking or DWATER."
    )
  }
  message("Applying selected EJSCREEN reference values to bg_envirodata: ",
          paste(bg_envirodata_reference_vars, collapse = ", "))
  bg_envirodata_reference <- EJAM:::ejscreen_pipeline_load(
    path = bg_envirodata_reference_path,
    format = tools::file_ext(bg_envirodata_reference_path),
    storage = "auto"
  )
  bg_envirodata <- EJAM:::ejscreen_reference_bg_envirodata_adjusted(
    bg_envirodata = bg_envirodata,
    reference = bg_envirodata_reference,
    vars = bg_envirodata_reference_vars
  )
  reference_adjustment <- attr(bg_envirodata, "ejscreen_reference_adjustment", exact = TRUE)
  write_pipeline_text(
    c(
      "EJSCREEN reference adjustment applied to bg_envirodata.",
      "Use this only when the reference file is the intended authoritative source for the selected fields.",
      "Missing reference values are preserved as NA values, not converted to zero.",
      paste("Reference path:", bg_envirodata_reference_path),
      paste("Requested vars:", paste(bg_envirodata_reference_vars, collapse = ", ")),
      "",
      EJAM:::ejscreen_pipeline_capture_output_wide(print(reference_adjustment)),
      "",
      paste("Created:", Sys.time())
    ),
    "bg_envirodata_REFERENCE_ADJUSTMENT.txt"
  )
}

if (isTRUE(include_islandareas_data)) {
  if (is.null(bg_islandareas_reference)) {
    message("Loading Island Areas rows from archived EPA EJScreen reference")
    bg_islandareas_reference <- EJAM:::load_islandareas_epa_reference(
      path = islandareas_reference_path,
      storage = pipeline_storage
    )
  }
  message("Adding Island Areas environmental rows from archived EPA EJScreen reference")
  bg_envirodata <- EJAM:::merge_islandareas_stage_data(
    bg_envirodata,
    EJAM:::islandareas_reference_envirodata(bg_islandareas_reference)
  )
}
save_file_stage_formats(bg_envirodata, stage = stagename)

###################################################### #
# Extra indicators stage - Read new or re-use existing data ####
###################################################### #

stagename <- "bg_extra_indicators"
message(paste0("Stage: ", stagename))

if (stage_exists(stagename)) {
  message(paste0("Using provided/existing ", stagename))
  bg_extra_indicators <- load_file_stage(stagename)
  save_file_stage_formats(bg_extra_indicators, stage = stagename)
} else {
  message(paste0("Creating ", stagename, ".", stage_format," from same-vintage blockgroupstats fallback"))
  used_provisional_bg_extra_indicators <- TRUE
  reusable_blockgroupstats <- get_reuse_blockgroupstats()
  package_blockgroupstats_acs_version <- EJAM:::ejscreen_pipeline_detect_acs_version(x = reusable_blockgroupstats)
  pipeline_acs_version <- EJAM:::ejscreen_pipeline_acs_version_from_year(pipeline_yr)
  if (!is.na(package_blockgroupstats_acs_version) &&
      !identical(package_blockgroupstats_acs_version, pipeline_acs_version)) {
    warning(
      "Provisional bg_extra_indicators is being copied from packaged EJAM::blockgroupstats with ACS version ",
      package_blockgroupstats_acs_version,
      ", while this pipeline run is for ACS version ",
      pipeline_acs_version,
      ". Replace this provisional file before final release use.",
      call. = FALSE
    )
  }

  bg_extra_indicators <- EJAM:::calc_bg_extra_indicators(

    existing_blockgroupstats = reusable_blockgroupstats,
    reuse_existing_if_missing = TRUE,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    overwrite = TRUE
  )
  save_file_stage_formats(x = bg_extra_indicators, stage = stagename)
  write_pipeline_text(
    c(
      paste0("PROVISIONAL bg_extra_indicators.", stage_format),
      "This file was copied from the same-vintage blockgroupstats fallback.",
      paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
      paste("Pipeline ACS version:", pipeline_acs_version),
      "Replace it with updated non-ACS, non-environmental blockgroup indicators if available, then rerun.",
      paste("Created:", Sys.time())
    ),
    "bg_extra_indicators_SOURCE.txt"
  )
}

###################################################### #
# Census/TIGER blockgroup geography stage ####
###################################################### #

stagename <- "bg_geodata"
message(paste0("Stage: ", stagename))
geodata_bgfips <- if (blockgroup_universe_source == "acs") {
  unique(bg_acsdata$bgfips)
} else {
  unique(c(bg_acsdata$bgfips, bg_envirodata$bgfips, bg_extra_indicators$bgfips))
}

if (!isTRUE(force_bg_geodata) && stage_exists(stagename)) {
  message(paste0("Using provided/existing ", stagename))
  bg_geodata <- load_file_stage(stagename)
  if (isTRUE(include_islandareas_data)) {
    if (is.null(bg_islandareas_reference)) {
      message("Loading Island Areas rows from archived EPA EJScreen reference")
      bg_islandareas_reference <- EJAM:::load_islandareas_epa_reference(
        path = islandareas_reference_path,
        storage = pipeline_storage
      )
    }
    bg_geodata <- EJAM:::merge_islandareas_stage_data(
      bg_geodata,
      EJAM:::islandareas_reference_geodata(bg_islandareas_reference)
    )
  }
  bg_geodata <- EJAM:::complete_bg_geodata(
    bg_geodata = bg_geodata,
    bgfips = geodata_bgfips,
    existing_blockgroupstats = get_reuse_blockgroupstats(),
    reuse_existing_if_missing = TRUE,
    allow_partial_reuse = FALSE
  )
  save_file_stage_formats(bg_geodata, stage = stagename)
} else {
  message(paste0("Creating ", stagename, " from Census/TIGER blockgroup files"))
  geodata_download_bgfips <- if (isTRUE(include_islandareas_data)) {
    geodata_bgfips[!EJAM:::islandareas_is_bgfips(geodata_bgfips)]
  } else {
    geodata_bgfips
  }
  bg_geodata <- EJAM:::calc_bg_geodata(
    yr = yr,
    bgfips = geodata_download_bgfips,
    existing_blockgroupstats = get_reuse_blockgroupstats(),
    reuse_existing_if_missing = TRUE,
    allow_partial_reuse = FALSE,
    download = TRUE,
    geodata_source = "tiger",
    download_dir = tiger_bg_cache_dir,
    download_timeout = acs_download_timeout,
    download_retries = acs_download_retries,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    pipeline_storage = pipeline_storage
  )
  if (isTRUE(include_islandareas_data)) {
    if (is.null(bg_islandareas_reference)) {
      message("Loading Island Areas rows from archived EPA EJScreen reference")
      bg_islandareas_reference <- EJAM:::load_islandareas_epa_reference(
        path = islandareas_reference_path,
        storage = pipeline_storage
      )
    }
    bg_geodata <- EJAM:::merge_islandareas_stage_data(
      bg_geodata,
      EJAM:::islandareas_reference_geodata(bg_islandareas_reference)
    )
    bg_geodata <- EJAM:::complete_bg_geodata(
      bg_geodata = bg_geodata,
      bgfips = geodata_bgfips,
      existing_blockgroupstats = get_reuse_blockgroupstats(),
      reuse_existing_if_missing = TRUE,
      allow_partial_reuse = FALSE
    )
  }
  save_file_stage_formats(bg_geodata, stage = stagename)
}

###################################################### #
# * *Create blockgroupstats, bgej, usastats, & statestats ** ####
###################################################### #

message("Creating blockgroupstats, bgej, usastats, statestats",
        if (isTRUE(include_ejscreen_dataset_creator_input)) ", ejscreen_dataset_creator_input" else "",
        if (isTRUE(include_ejscreen_export)) ", ejscreen_export" else "",
        if (isTRUE(include_ejscreen_export_statepct)) ", ejscreen_export_statepct" else "",
        if (isTRUE(include_ejscreen_pctile_lookup_exports)) ", and EJScreen lookup exports" else "")
print(Sys.time())

out <- EJAM::calc_ejscreen_dataset(

  yr = yr,
  bg_acsdata = bg_acsdata,
  bg_envirodata = bg_envirodata,
  bg_extra_indicators = bg_extra_indicators,
  bg_geodata = bg_geodata,

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
  include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input,
  include_ejscreen_export = include_ejscreen_export,
  include_ejscreen_export_statepct = include_ejscreen_export_statepct,
  include_ejscreen_pctile_lookup_exports = include_ejscreen_pctile_lookup_exports,
  blockgroup_universe_source = blockgroup_universe_source,
  overwrite = TRUE
)

save_secondary_stage_formats(out, stages = names(out))

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
  "bg_geodata", # Census/TIGER blockgroup area and internal-point fields
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

if (isTRUE(include_islandareas_data) &&
    (isTRUE(use_islandareas_demographics) || stage_exists("bg_islandareas_demographics"))) {
  stages_to_validate <- c("bg_islandareas_demographics", stages_to_validate)
}

if (isTRUE(include_ejscreen_export)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_export")
}
if (isTRUE(include_ejscreen_export_statepct)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_export_statepct")
}
if (isTRUE(include_ejscreen_pctile_lookup_exports)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_us_pctile_lookup", "ejscreen_state_pctile_lookup")
}
if (isTRUE(include_ejscreen_dataset_creator_input)) {
  stages_to_validate <- c(stages_to_validate, "ejscreen_dataset_creator_input")
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

message("Validating dynamic geography Arrow files and saving report.")
dynamic_geography_arrow_report <- EJAM:::dynamic_geography_arrow_report(
  blockgroupstats_ref = out$blockgroupstats,
  silent = TRUE
)
write_pipeline_txt_or_csv(x = dynamic_geography_arrow_report,
                          filename = "dynamic_geography_arrow_report.csv",
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
if (isTRUE(include_ejscreen_export_statepct)) {
  filename <- paste0("ejscreen_export_statepct_schema_report.", "csv")
  ejscreen_statepct_schema_report <- EJAM:::calc_ejscreen_export_schema_report(
    ejscreen_export = out$ejscreen_export_statepct,
    expected_output_names = EJAM:::ejscreen_statepct_feature_server_fields()
  )
  write_pipeline_txt_or_csv(x = ejscreen_statepct_schema_report,
                            filename = filename,
                            pipeline_dir = pipeline_dir,
                            pipeline_storage = pipeline_storage)
}
if (isTRUE(include_ejscreen_dataset_creator_input)) {
  dataset_creator_report <- attr(
    out$ejscreen_dataset_creator_input,
    "ejscreen_dataset_creator_input_report",
    exact = TRUE
  )
  if (!is.null(dataset_creator_report)) {
    write_pipeline_txt_or_csv(x = dataset_creator_report,
                              filename = "ejscreen_dataset_creator_input_report.csv",
                              pipeline_dir = pipeline_dir,
                              pipeline_storage = pipeline_storage)
  }
}
print(Sys.time())
###################################################### #
# > Optional validation versus prior or currently packaged datasets ####
###################################################### #

if (isTRUE(validate_vs_prior)) {

  if (nzchar(prior_package_ref)) {
    message("Comparing selected stages to explicit prior package Git object: ",
            prior_package_ref, ":", prior_package_path)
    prior_validation_comparisons <- list(
      bg_acsdata_vs_prior_package_blockgroupstats =
        EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
          stage = paste0("bg_acsdata_vs_", prior_package_ref, "_blockgroupstats"),
          new_pipeline_dir = pipeline_dir,
          new_stage = "bg_acsdata",
          git_ref = prior_package_ref,
          git_path = prior_package_path,
          format = stage_format,
          storage = pipeline_storage,
          shared_only = TRUE,
          output_dir = pipeline_dir,
          write_files = TRUE,
          use_waldo = validate_vs_prior_waldo
        ),
      blockgroupstats_vs_prior_package_blockgroupstats =
        EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
          stage = paste0("blockgroupstats_vs_", prior_package_ref, "_blockgroupstats"),
          new_pipeline_dir = pipeline_dir,
          new_stage = "blockgroupstats",
          git_ref = prior_package_ref,
          git_path = prior_package_path,
          format = stage_format,
          storage = pipeline_storage,
          output_dir = pipeline_dir,
          write_files = TRUE,
          use_waldo = validate_vs_prior_waldo
        ),
      usastats_vs_prior_package_usastats =
        EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
          stage = paste0("usastats_vs_", prior_package_ref, "_usastats"),
          new_pipeline_dir = pipeline_dir,
          new_stage = "usastats",
          git_ref = prior_package_ref,
          git_path = "data/usastats.rda",
          format = stage_format,
          storage = pipeline_storage,
          output_dir = pipeline_dir,
          write_files = TRUE,
          use_waldo = validate_vs_prior_waldo
        ),
      statestats_vs_prior_package_statestats =
        EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
          stage = paste0("statestats_vs_", prior_package_ref, "_statestats"),
          new_pipeline_dir = pipeline_dir,
          new_stage = "statestats",
          git_ref = prior_package_ref,
          git_path = "data/statestats.rda",
          format = stage_format,
          storage = pipeline_storage,
          output_dir = pipeline_dir,
          write_files = TRUE,
          use_waldo = validate_vs_prior_waldo
        )
    )
    prior_validation_summary <- data.table::rbindlist(
      lapply(prior_validation_comparisons, function(x) x$summary),
      fill = TRUE
    )
    EJAM:::ejscreen_pipeline_write_text_or_csv(
      prior_validation_summary,
      "prior_validation_summary.csv",
      pipeline_dir = pipeline_dir,
      storage = pipeline_storage
    )
    prior_validation <- list(
      summary = prior_validation_summary,
      comparisons = prior_validation_comparisons,
      new_pipeline_dir = pipeline_dir,
      old_git_ref = prior_package_ref,
      old_git_path = prior_package_path,
      output_dir = pipeline_dir
    )
  } else {
    message("Comparing selected stages to prior saved pipeline version: ", prior_pipeline_dir)
    prior_validation <- EJAM:::ejscreen_pipeline_compare_versions(
      new_yr = pipeline_yr,
      old_yr = prior_pipeline_yr,
      stages = c(
        "bg_acsdata",
        "bg_envirodata",
        "bg_geodata",
        "bg_extra_indicators",
        "blockgroupstats",
        "bgej",
        "usastats",
        "statestats"
      ),
      pipeline_root = pipeline_root,
      new_pipeline_dir = pipeline_dir,
      old_pipeline_dir = prior_pipeline_dir,
      format = stage_format,
      storage = pipeline_storage,
      output_dir = pipeline_dir,
      write_files = TRUE,
      use_waldo = validate_vs_prior_waldo
    )
  }
  prior_validation_summary <- prior_validation$summary
  message("Prior-version validation summary:")
  prior_validation_print_cols <- intersect(
    c("stage", "rows_new", "rows_old", "columns_new", "columns_old",
      "bgfips_set_equal", "shared_data_equal", "not_replicated_n", "error"),
    names(prior_validation_summary)
  )
  print(prior_validation_summary[, ..prior_validation_print_cols])
}

if (isTRUE(include_ejscreen_export) &&
    isTRUE(validate_ejscreen_export_reference) &&
    nzchar(ejscreen_export_reference_path)) {
  message("Comparing ejscreen_export stage to reference export: ",
          ejscreen_export_reference_path)
  ejscreen_export_reference_prefix <- if (grepl(
    "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI",
    ejscreen_export_reference_path,
    fixed = TRUE
  )) {
    "prior_validation_ejscreen_export_vs_epa_2024_acs2022"
  } else {
    "prior_validation_ejscreen_export_vs_reference"
  }
  ejscreen_export_reference_validation <- EJAM:::calc_ejscreen_export_reference_report(
    ejscreen_export = out$ejscreen_export,
    reference_path = ejscreen_export_reference_path,
    reference_format = tools::file_ext(ejscreen_export_reference_path),
    storage = pipeline_storage,
    reference_label = basename(ejscreen_export_reference_path),
    note = if (identical(as.character(pipeline_yr), "2022")) {
      "Reference is named 2024 but treated here as ACS 2022 based on user knowledge."
    } else {
      NULL
    },
    output_dir = pipeline_dir,
    output_prefix = ejscreen_export_reference_prefix,
    write_files = TRUE
  )
  message("EJSCREEN export reference validation summary:")
  print(ejscreen_export_reference_validation$summary)
}

if (isTRUE(include_ejscreen_export_statepct) &&
    isTRUE(validate_ejscreen_export_reference) &&
    nzchar(ejscreen_export_statepct_reference_path)) {
  message("Comparing ejscreen_export_statepct stage to reference export: ",
          ejscreen_export_statepct_reference_path)
  ejscreen_export_statepct_reference_prefix <- if (grepl(
    "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI",
    ejscreen_export_statepct_reference_path,
    fixed = TRUE
  )) {
    "prior_validation_ejscreen_export_statepct_vs_epa_2024_acs2022"
  } else {
    "prior_validation_ejscreen_export_statepct_vs_reference"
  }
  ejscreen_export_statepct_reference_validation <- EJAM:::calc_ejscreen_export_reference_report(
    ejscreen_export = out$ejscreen_export_statepct,
    reference_path = ejscreen_export_statepct_reference_path,
    reference_format = tools::file_ext(ejscreen_export_statepct_reference_path),
    storage = pipeline_storage,
    reference_label = basename(ejscreen_export_statepct_reference_path),
    note = if (identical(as.character(pipeline_yr), "2022")) {
      "Reference is named 2024 but treated here as ACS 2022 based on user knowledge. This is EPA's StatePct-style export, so state values are expected in generic EPA field names."
    } else {
      NULL
    },
    output_dir = pipeline_dir,
    output_prefix = ejscreen_export_statepct_reference_prefix,
    write_files = TRUE
  )
  message("EJSCREEN StatePct export reference validation summary:")
  print(ejscreen_export_statepct_reference_validation$summary)
}

manifest_status <- if (any(nzchar(validation_summary$errors))) "validation_failed" else "completed"
pipeline_run_manifest_path <- EJAM:::ejscreen_pipeline_write_run_manifest(
  pipeline_dir = pipeline_dir,
  storage = pipeline_storage,
  pipeline_yr = pipeline_yr,
  pipeline_storage = pipeline_storage,
  stage_format = stage_format,
  settings = Sys.getenv(pipeline_setting_names),
  provisional_inputs = c(
    bg_envirodata = used_provisional_bg_envirodata,
    bg_extra_indicators = used_provisional_bg_extra_indicators,
    bg_islandareas_demographics_used_in_bg_acsdata = use_islandareas_demographics
  ),
  run_started_at = run_started_at,
  run_finished_at = Sys.time(),
  status = manifest_status
)
message("Pipeline run manifest: ", pipeline_run_manifest_path)

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

should_replace_package_data <- isTRUE(replace_package_data)
if (!should_replace_package_data && interactive()) {
  should_replace_package_data <- isTRUE(askYesNo(
    "ready to REPLACE data/blockgroupstats.rda, data/usastats.rda, data/statestats.rda, and any selected helper package .rda datasets ? "
  ))
}

if (isTRUE(should_replace_package_data)) {
  blockgroupstats <- out$blockgroupstats
  bgej <- out$bgej
  usastats <- out$usastats
  statestats <- out$statestats

  EJAM:::metadata_add_and_use_this("blockgroupstats")
  EJAM:::metadata_add_and_use_this("usastats")
  EJAM:::metadata_add_and_use_this("statestats")

  ## bgej is not package .rda data. Save the refreshed bgej pipeline artifacts
  ## to the pipeline folder for release/data-repository publication.
  EJAM:::ejscreen_pipeline_save(x = bgej, format = "rda", validate = FALSE, storage = "s3", pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR"), stage = "bgej", yr = pipeline_yr)
  EJAM:::ejscreen_pipeline_save(x = bgej, format = "arrow", validate = FALSE, storage = "s3", pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR"), stage = "bgej", yr = pipeline_yr)

  ## Optional maintainer step, disabled by default: publish the refreshed
  ## bgej.arrow as an ejamdata release asset. Always dry-run first.
  ## also see run_arrow_publish_v2.5.0.R to publish all .arrow files in 1 step
  # bgej_arrow_publish_path <- file.path(tempdir(), "bgej.arrow")
  # arrow::write_ipc_file(bgej, sink = bgej_arrow_publish_path)
  # EJAM:::datasets_arrow_publish(
  #   files = bgej_arrow_publish_path,
  #   tag = EJAM:::ejamdata_required_tag(),
  #   release_date = Sys.Date(),
  #   dry_run = TRUE,    # change when ready
  #   overwrite = FALSE,  # change when ready
  #   mark_latest = FALSE   # change when ready
  # )
} else {
  message("Skipping package-data replacement because EJAM_REPLACE_PACKAGE_DATA is FALSE.")
}

###################################################### #
# Create OTHER datasets  ####
#
# mostly must be done AFTER new blockgroup datasets are created !

if (isTRUE(run_datacreate_after)) {
  for (fpath in datacreate_scripts_to_run_after_pipeline) {
    cat("sourcing the script in", fpath, "...\n")
    source(fpath)
  }
} else {
  message("Skipping post-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_AFTER is FALSE.")
}

# restart, reinstall

###################################################### #
# cat("REBUILD/INSTALL THE PACKAGE NOW \n")
###################################################### #
