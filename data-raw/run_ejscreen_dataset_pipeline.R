###################################################### #
#
# Compatibility runner for the staged EJSCREEN/EJAM dataset pipeline.
#
# Preferred entry points for routine work are the recipe scripts:
#   source("data-raw/run_ejscreen_pipeline_annual.R")
#   source("data-raw/run_ejscreen_pipeline_release.R")
#   source("data-raw/run_ejscreen_pipeline_validation_only.R")
#   source("data-raw/run_ejscreen_pipeline_exports_only.R")
#
# Or call the validated config helpers directly:
#   cfg <- EJAM:::pipeline_config_annual(yr = 2024)
#   pipeline_run <- EJAM:::run_ejscreen_pipeline(cfg)
#
# This file remains as the long-standing source() compatibility runner. It
# reads environment-variable settings, builds a validated pipeline config, runs
# the package runner, and exposes the same script-level objects that older
# interactive workflows expected.
#
# The pipeline writes csv/rda checkpoints to the configured local folder or S3
# prefix, such as:
#   data-raw/pipeline_outputs/ejscreen_acs_2022
#   s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2024
#
# Related package-data and Arrow release assets remain explicit opt-in steps.
# Arrow assets later load through dataload_dynamic() using DESCRIPTION field
# ejamdata_required_tag, not whichever ejamdata release GitHub marks as latest.
#
###################################################### #

# Useful environment variables for compatibility-runner workflows:

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
#      in blockgroupstats, ejscreen_export, ejscreen_export_statepct, and
#      map-ready outputs. These
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

# Load package source ####

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

# Environment variables can be set before sourcing this file. The helper below
# fills unset values with current package defaults before building the config.

###################################################### ####################################################### #

# Specifying OTHER datasets to update ####

# The pipeline is primarily focused on updating
# blockgroupstats and bgej, percentile lookup tables, and the EJScreen file.
# Various other datasets generally need to be checked or updated
# just before or just after those main blockgroup datasets are updated.
# Some shown here are optional, though.
# To check the current list of such scripts:
# dput( dir(pattern = "^datacreate_", recursive = TRUE) )
# The default annual recipe intentionally excludes block helper refreshes
# (blockwts/blockpoints/bgid2fips/blockid2fips/quaddata) and map_headernames
# regeneration. Do those manually and review carefully when needed.
# The resolved pipeline config below controls whether those scripts run.
###################################################### #


###################################################### ####################################################### #

# Run from resolved settings ####

pipeline_env_run <- EJAM:::ejscreen_pipeline_run_from_env(
  run_started_at = run_started_at,
  package_data_pipeline_dir = Sys.getenv("EJAM_PIPELINE_DIR")
)
pipeline_config <- pipeline_env_run$pipeline_config
pipeline_run <- pipeline_env_run$pipeline_run
list2env(pipeline_run, envir = environment())

invisible(out)
