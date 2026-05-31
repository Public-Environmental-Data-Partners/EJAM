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
#      EJScreen_2024_BG_State_Lookup.csv. This is off by default because the
#      live EJScreen app maps from blockgroup exports that already contain
#      percentile, bin, and popup fields, while reports are served through
#      EJAM-API/EJAM rather than these exported lookup tables.
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
skip_package_load <- toupper(Sys.getenv("EJAM_PIPELINE_SKIP_PACKAGE_LOAD", unset = "FALSE")) %in% c("1", "TRUE", "YES", "Y")
if (!skip_package_load) {
  if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
    pkgload::load_all(export_all = TRUE)
  } else {
    library(EJAM)
  }
}
library(data.table)

run_started_at <- Sys.time()

# Leave these defaults here, and then
# Override by setting environment variables further BELOW before sourcing this script.
# note that right here the EJAM_PIPELINE_DIR is based on type of EJAM_PIPELINE_STORAGE but
# if EJAM_PIPELINE_STORAGE is set to "auto" here, then it gets figured out later based on EJAM_PIPELINE_DIR

EJAM:::ejscreen_pipeline_set_env_defaults()

###################################################### ####################################################### #

run_datacreate_before <- EJAM:::ejscreen_pipeline_env_flag("EJAM_RUN_DATACREATE_BEFORE", TRUE)
run_datacreate_after <- EJAM:::ejscreen_pipeline_env_flag("EJAM_RUN_DATACREATE_AFTER", TRUE)
replace_package_data <- EJAM:::ejscreen_pipeline_env_flag("EJAM_REPLACE_PACKAGE_DATA", FALSE)
include_frs_update <- EJAM:::ejscreen_pipeline_env_flag("EJAM_INCLUDE_FRS_UPDATE", FALSE)

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

EJAM:::ejscreen_pipeline_source_scripts(
  datacreate_scripts_to_run_before_pipeline,
  enabled = run_datacreate_before,
  skip_message = "Skipping pre-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_BEFORE is FALSE."
)
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
  cbind(current_setting = Sys.getenv(EJAM:::ejscreen_pipeline_setting_names()))
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

pipeline_config <- EJAM:::ejscreen_pipeline_config_from_env()

yr <- pipeline_config$yr
pipeline_yr <- pipeline_config$yr
pipeline_root <- pipeline_config$pipeline_root
pipeline_dir <- pipeline_config$pipeline_dir
pipeline_storage <- pipeline_config$pipeline_storage
if (pipeline_storage == "local") {
  dir.create(pipeline_dir, recursive = TRUE, showWarnings = FALSE)
}
stage_format <- pipeline_config$stage_format
stage_formats <- pipeline_config$stage_formats
blockgroup_universe_source <- pipeline_config$blockgroup_universe_source
tract_weight_source <- pipeline_config$tract_weight_source

message("Year: ", pipeline_yr)
message("Pipeline folder: ", pipeline_dir)
message("Pipeline storage: ", pipeline_storage)
message("File format aka stage_format: ", stage_format)
message("Saved stage formats: ", paste(stage_formats, collapse = ", "))
message("Blockgroup universe source: ", blockgroup_universe_source)
message("Tract apportionment weight source: ", tract_weight_source)

### ACS DEMOGRAPHIC DATA settings ####

force_acs <- pipeline_config$force_acs
force_bg_acsdata <- pipeline_config$force_bg_acsdata
force_bg_geodata <- pipeline_config$force_bg_geodata
tiger_bg_cache_dir <- pipeline_config$tiger_bg_cache_dir
acs_download_timeout <- pipeline_config$acs_download_timeout
acs_download_retries <- pipeline_config$acs_download_retries
include_islandareas_data <- pipeline_config$include_islandareas_data
islandareas_reference_path <- pipeline_config$islandareas_reference_path
use_islandareas_demographics <- pipeline_config$use_islandareas_demographics

### ENVIRONMENTAL DATA settings ####

use_provisional_bg_envirodata <- pipeline_config$use_provisional_bg_envirodata
bg_envirodata_reference_path <- pipeline_config$bg_envirodata_reference_path
bg_envirodata_reference_vars <- pipeline_config$bg_envirodata_reference_vars

### EJSCREEN DATASET EXPORT settings ####

include_ejscreen_export <- pipeline_config$include_ejscreen_export
include_ejscreen_export_statepct <- pipeline_config$include_ejscreen_export_statepct
include_ejscreen_pctile_lookup_exports <- pipeline_config$include_ejscreen_pctile_lookup_exports
include_ejscreen_dataset_creator_input <- pipeline_config$include_ejscreen_dataset_creator_input

### validation vs prior data  ####

validate_vs_prior <- pipeline_config$validate_vs_prior
validate_vs_prior_waldo <- pipeline_config$validate_vs_prior_waldo
ejscreen_export_reference_path <- pipeline_config$ejscreen_export_reference_path
ejscreen_export_statepct_reference_path <- pipeline_config$ejscreen_export_statepct_reference_path
validate_ejscreen_export_reference <- pipeline_config$validate_ejscreen_export_reference
prior_pipeline_yr <- pipeline_config$prior_pipeline_yr
prior_pipeline_dir <- pipeline_config$prior_pipeline_dir
prior_package_ref <- pipeline_config$prior_package_ref
prior_package_path <- pipeline_config$prior_package_path

pipeline_setting_names <- EJAM:::ejscreen_pipeline_setting_names()

#################################################### #
print(EJAM:::ejscreen_pipeline_config_summary(pipeline_config))
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

stage_io <- EJAM:::ejscreen_pipeline_stage_io(
  pipeline_dir = pipeline_dir,
  stage_format = stage_format,
  stage_formats = stage_formats,
  pipeline_yr = pipeline_yr,
  storage = pipeline_storage,
  prior_package_ref = prior_package_ref,
  prior_package_path = prior_package_path
)
load_file_stage <- stage_io$load_stage
stage_exists <- stage_io$stage_exists
get_reuse_blockgroupstats <- stage_io$get_reuse_blockgroupstats
save_file_stage_formats <- stage_io$save_stage_formats
save_secondary_stage_formats <- stage_io$save_secondary_stage_formats
####################### #
used_provisional_bg_envirodata <- FALSE
used_provisional_bg_extra_indicators <- FALSE
####################### #
# ~ ----------------------------------------------- ####
###################################################### #
# Download ACS raw blockgroup data stage ####
###################################################### #

bg_acs_raw_stage <- EJAM:::ejscreen_pipeline_stage_bg_acs_raw(
  yr = yr,
  force_acs = force_acs,
  force_bg_acsdata = force_bg_acsdata,
  include_islandareas_data = include_islandareas_data,
  stage_io = stage_io,
  pipeline_dir = pipeline_dir,
  stage_format = stage_format,
  stage_formats = stage_formats,
  pipeline_storage = pipeline_storage,
  acs_download_timeout = acs_download_timeout,
  acs_download_retries = acs_download_retries
)
bg_acs_raw <- bg_acs_raw_stage$bg_acs_raw
need_bg_acsdata <- bg_acs_raw_stage$need_bg_acsdata
need_bg_acs_raw <- bg_acs_raw_stage$need_bg_acs_raw
###################################################### #
# Prepare Island Areas blockgroup reference / optional Census DHC stages ####
###################################################### #

islandareas_stage <- EJAM:::ejscreen_pipeline_prepare_islandareas(
  include_islandareas_data = include_islandareas_data,
  need_bg_acsdata = need_bg_acsdata,
  use_islandareas_demographics = use_islandareas_demographics,
  force_acs = force_acs,
  stage_io = stage_io,
  islandareas_reference_path = islandareas_reference_path,
  stage_formats = stage_formats,
  pipeline_storage = pipeline_storage
)
bg_islandareas_raw <- islandareas_stage$bg_islandareas_raw
bg_islandareas_demographics <- islandareas_stage$bg_islandareas_demographics
bg_islandareas_reference <- islandareas_stage$bg_islandareas_reference
###################################################### #
# Calculate ACS-based indicators, bg_acsdata stage ####
###################################################### #

# bg_acsdata  is the cleaned/processed version of the raw ACS data that is used for calculating indicators and stats.
# This is a separate stage because it can be time consuming to download ACS in the prior stage and you may want to manually add other raw scores here,
# but if you have already calculated it and saved it, you can reuse it even if you want to recalculate downstream stages like blockgroupstats or bgej.

bg_acsdata <- EJAM:::ejscreen_pipeline_stage_bg_acsdata(
  yr = yr,
  need_bg_acsdata = need_bg_acsdata,
  bg_acs_raw = bg_acs_raw,
  bg_islandareas_raw = bg_islandareas_raw,
  bg_islandareas_demographics = bg_islandareas_demographics,
  bg_islandareas_reference = bg_islandareas_reference,
  include_islandareas_data = include_islandareas_data,
  use_islandareas_demographics = use_islandareas_demographics,
  tract_weight_source = tract_weight_source,
  pipeline_dir = pipeline_dir,
  stage_format = stage_format,
  stage_io = stage_io
)
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
  EJAM:::ejscreen_pipeline_write_text(
    lines = c(
      paste0("PROVISIONAL bg_envirodata.", stage_format),
      "This file was copied from the same-vintage blockgroupstats fallback.",
      paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
      paste("Pipeline ACS version:", pipeline_acs_version),
      "Replace it with updated environmental indicators and rerun data-raw/run_ejscreen_dataset_pipeline.R.",
      paste("Created:", Sys.time())
    ),
    filename = "bg_envirodata_SOURCE.txt",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
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
  EJAM:::ejscreen_pipeline_write_text(
    lines = c(
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
    filename = "bg_envirodata_REFERENCE_ADJUSTMENT.txt",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
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
  EJAM:::ejscreen_pipeline_write_text(
    lines = c(
      paste0("PROVISIONAL bg_extra_indicators.", stage_format),
      "This file was copied from the same-vintage blockgroupstats fallback.",
      paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
      paste("Pipeline ACS version:", pipeline_acs_version),
      "Replace it with updated non-ACS, non-environmental blockgroup indicators if available, then rerun.",
      paste("Created:", Sys.time())
    ),
    filename = "bg_extra_indicators_SOURCE.txt",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
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

stages_to_validate <- EJAM:::ejscreen_pipeline_validation_stages(
  include_islandareas_data = include_islandareas_data,
  use_islandareas_demographics = use_islandareas_demographics,
  has_bg_islandareas_demographics = stage_exists("bg_islandareas_demographics"),
  include_ejscreen_export = include_ejscreen_export,
  include_ejscreen_export_statepct = include_ejscreen_export_statepct,
  include_ejscreen_pctile_lookup_exports = include_ejscreen_pctile_lookup_exports,
  include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input
)
validation_summary <- EJAM:::ejscreen_pipeline_validation_summary(
  stages = stages_to_validate,
  pipeline_dir = pipeline_dir,
  stage_format = stage_format,
  pipeline_storage = pipeline_storage,
  load_stage_fun = load_file_stage
)

message("Validating dynamic geography Arrow files and saving report.")
EJAM:::ejscreen_pipeline_dynamic_geography_report(
  blockgroupstats = out$blockgroupstats,
  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage
)

EJAM:::ejscreen_pipeline_export_schema_reports(
  outputs = out,
  include_ejscreen_export = include_ejscreen_export,
  include_ejscreen_export_statepct = include_ejscreen_export_statepct,
  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage
)

EJAM:::ejscreen_pipeline_dataset_creator_report(
  outputs = out,
  include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input,
  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage
)

print(Sys.time())
###################################################### #
# > Optional validation versus prior or currently packaged datasets ####
###################################################### #

if (isTRUE(validate_vs_prior)) {

  prior_validation <- EJAM:::ejscreen_pipeline_prior_validation(
    validate_vs_prior = validate_vs_prior,
    prior_package_ref = prior_package_ref,
    prior_package_path = prior_package_path,
    pipeline_yr = pipeline_yr,
    prior_pipeline_yr = prior_pipeline_yr,
    pipeline_root = pipeline_root,
    pipeline_dir = pipeline_dir,
    prior_pipeline_dir = prior_pipeline_dir,
    stage_format = stage_format,
    pipeline_storage = pipeline_storage,
    validate_vs_prior_waldo = validate_vs_prior_waldo
  )
  prior_validation_summary <- prior_validation$summary
  message("Prior-version validation summary:")
  prior_validation_print_cols <- EJAM:::ejscreen_pipeline_prior_validation_print_columns(prior_validation_summary)
  print(prior_validation_summary[, ..prior_validation_print_cols])
}

ejscreen_export_reference_validations <- EJAM:::ejscreen_pipeline_export_reference_validations(
  outputs = out,
  include_ejscreen_export = include_ejscreen_export,
  include_ejscreen_export_statepct = include_ejscreen_export_statepct,
  validate_ejscreen_export_reference = validate_ejscreen_export_reference,
  ejscreen_export_reference_path = ejscreen_export_reference_path,
  ejscreen_export_statepct_reference_path = ejscreen_export_statepct_reference_path,
  pipeline_yr = pipeline_yr,
  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage
)

pipeline_finalization <- EJAM:::ejscreen_pipeline_finalize_run(
  validation_summary = validation_summary,
  pipeline_dir = pipeline_dir,
  pipeline_storage = pipeline_storage,
  pipeline_yr = pipeline_yr,
  stage_format = stage_format,
  settings = Sys.getenv(pipeline_setting_names),
  provisional_inputs = c(
    bg_envirodata = used_provisional_bg_envirodata,
    bg_extra_indicators = used_provisional_bg_extra_indicators,
    bg_islandareas_demographics_used_in_bg_acsdata = use_islandareas_demographics
  ),
  run_started_at = run_started_at
)

invisible(out)

# ~ ----------------------------------------------- ####
###################################################### #

# Package-data replacement remains opt-in. bgej is not package .rda data, so
# the helper saves refreshed bgej pipeline artifacts for release-asset publishing.
package_data_replacement <- EJAM:::ejscreen_pipeline_replace_package_data(
  outputs = out,
  replace_package_data = replace_package_data,
  pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR"),
  pipeline_yr = pipeline_yr
)

###################################################### #
# Create OTHER datasets  ####
#
# mostly must be done AFTER new blockgroup datasets are created !

EJAM:::ejscreen_pipeline_source_scripts(
  datacreate_scripts_to_run_after_pipeline,
  enabled = run_datacreate_after,
  skip_message = "Skipping post-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_AFTER is FALSE."
)

# restart, reinstall

###################################################### #
# cat("REBUILD/INSTALL THE PACKAGE NOW \n")
###################################################### #
