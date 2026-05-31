###################################################### #

#' Run calculations for the staged EJSCREEN/EJAM dataset update pipeline
#'
#' @details
#'
#' See the runner script `data-raw/run_ejscreen_dataset_pipeline.R`
#' to run the whole pipeline from start to finish with minimal manual intervention.
#'
#' `calc_ejscreen_dataset()` is a high-level wrapper around the staged
#' annual update helpers. It is intentionally an orchestrator rather than a
#' replacement for the individual stage functions. Each major input or output can
#' be supplied as an R object, read from a saved stage in `pipeline_dir`, or
#' created and saved by this function.
#'
#' The default stage order is:
#'
#' 1. download raw ACS tables of demographic data into `bg_acs_raw`
#' 2. when enabled, append Island Areas AS/GU/MP/VI placeholder rows using the
#'    archived EPA EJScreen ACS2022 reference for row IDs, area fields, and
#'    available environmental fields; optional Island Areas Census DHC
#'    demographics can still be saved/reviewed separately but are not used
#'    downstream unless explicitly requested
#' 3. calculate ACS-based demographic indicators (and lead paint indicator) as `bg_acsdata`
#' 4. validate/save `bg_envirodata` (key environmental indicators)
#' 5. validate/save `bg_extra_indicators` (e.g., % low life expectancy)
#' 6. create or validate `bg_geodata`, the Census/TIGER blockgroup geography
#'    attributes used for `arealand`, `areawater`, and internal-point fields
#' 7. calculate demographic indexes (using % low life expectancy, etc.)
#' 8. combine those blockgroup demog., envt., extra, and geography indicators
#'    as [blockgroupstats]
#' 9. create intermediate percentile lookup tables `usastats_acs`,
#'    `statestats_acs`, `usastats_envirodata`, `statestats_envirodata`
#' 10. calculate EJ indexes (from envt. percentiles and demog. indexes) and save
#'    as [bgej] table
#' 11. create intermediate percentile lookup tables `usastats_ej`,
#'     `statestats_ej`
#' 12. combine those as [usastats] and [statestats]
#' 13. create an EJScreen-ready export file and/or EPA Python dataset-creator
#'     input file (optionally)
#'
#' `bg_envirodata` must include `pctpre1960`. That column may be produced by an
#' upstream environmental-data step that reads the saved `bg_acsdata` stage.
#' For EJAM v2.5.0, Island Areas are supported at the blockgroup dataset,
#' EJSCREEN export, and map-data visibility level when
#' `include_islandareas_data = TRUE`. The default path keeps AS/GU/MP/VI
#' demographic fields as `NA`, uses archived EPA EJScreen reference rows for
#' row IDs and available environmental/area fields, and does not add AS/GU/MP/VI
#' blocks to the block helper files. Radius/buffer analyses in those areas
#' should therefore return no-data results rather than block-weighted estimates.
#'
#' The annual pipeline creates the `bgej` stage, and the package-level dynamic
#' Arrow loader obtains `bgej.arrow` from the `ejamdata` release tag recorded in
#' DESCRIPTION as `ejamdata_required_tag`. For EJAM 2.5.0 this is currently
#' `v2.5.0`, but the package version and required data tag can differ for patch
#' releases. [dataload_dynamic()] and [download_latest_arrow_data()] do not use
#' whichever data-repository release GitHub currently marks as latest.
#'
#' Note that the runner script can use several settings stored as environment variables:
#'
#'  - EJAM_PIPELINE_YR
#'
#'  - EJAM_PIPELINE_DIR: override output folder.
#'  - EJAM_PIPELINE_STORAGE: auto, local, or s3. auto treats s3:// paths as S3.
#'  - EJAM_STAGE_FORMAT: primary stage format used for loading, usually csv.
#'  - EJAM_STAGE_FORMATS: comma-separated formats saved by the runner, usually csv,rda.
#'  - EJAM_BLOCKGROUP_UNIVERSE_SOURCE: acs or union. acs is recommended.
#'  - EJAM_TRACT_WEIGHT_SOURCE: decennial2020 or acs. decennial2020 matches
#'    legacy EJSCREEN tract-to-blockgroup apportionment.
#'  - AWS_PROFILE and AWS_REGION: used when pipeline_storage is s3
#'  - CENSUS_API_KEY: used by functions that download ACS data (or that download boundaries/shapefiles for FIPS from some sources)
#'  - EJAM_FORCE_ACS: TRUE to redownload/recalculate raw ACS and bg_acsdata.
#'  - EJAM_FORCE_BG_ACSDATA: TRUE to rebuild bg_acsdata from saved raw ACS.
#'  - EJAM_FORCE_BG_GEODATA: TRUE to redownload/recalculate Census/TIGER blockgroup geodata.
#'  - EJAM_ACS_DOWNLOAD_TIMEOUT
#'  - EJAM_ACS_DOWNLOAD_RETRIES
#'  - EJAM_INCLUDE_ISLANDAREAS_DATA: TRUE to save AS/GU/MP/VI rows. The
#'    annual/release runner enables this by default unless explicitly set
#'    otherwise.
#'  - EJAM_ISLANDAREAS_REFERENCE_PATH: archived EPA EJScreen reference CSV used
#'    for Island Areas row IDs, area fields, and available environmental fields.
#'  - EJAM_USE_ISLANDAREAS_DEMOGRAPHICS: TRUE only for an intentional
#'    mixed-source supplemental dataset using 2020 Island Areas Census DHC
#'    demographics in `bg_acsdata`.
#'
#'  - EJAM_USE_PROVISIONAL_BG_ENVIRODATA: FALSE to require bg_envirodata.csv.
#'  - EJAM_BG_ENVIRODATA_REFERENCE_PATH and
#'    EJAM_BG_ENVIRODATA_REFERENCE_VARS: optional runner-only settings for
#'    deliberately creating or repairing a `bg_envirodata` source stage from an
#'    EJSCREEN-style reference CSV. Normal annual and replication runs should use
#'    corrected `bg_envirodata` as-is. Missing reference values are preserved as
#'    `NA`, not converted to zero. This matters for drinking water: EJAM versions
#'    after v2.32.8.001 should not convert missing drinking-water scores to zero
#'    unless the source explicitly reports zero.
#'
#'  - EJAM_INCLUDE_EJSCREEN_EXPORT: TRUE to create ejscreen_export.csv.
#'  - EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT: TRUE to create
#'    ejscreen_export_statepct.csv.
#'  - EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS: TRUE to create
#'    ejscreen_us_pctile_lookup.csv and ejscreen_state_pctile_lookup.csv.
#'    This is off by default because current EJScreen maps use the blockgroup
#'    exports that already contain percentile, bin, and popup fields, while
#'    reports are served through EJAM-API/EJAM.
#'  - EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT: TRUE to create the smaller
#'    input table expected by EPA's Python dataset-creator workflow.
#'
#'  - EJAM_VALIDATE_VS_PRIOR and related EJAM_PRIOR_* settings control prior-version comparisons.
#'
#' The annual runner also writes `pipeline_run_manifest.csv`, which records the
#' package version, Git branch/SHA, ACS vintage, run settings, and whether
#' provisional environmental or extra-indicator inputs were reused.
#'
#' Census/TIGER geography can occasionally include valid blockgroup features
#' that are not present in the ACS summary-file tables for the same ACS vintage.
#' For example, a draft ACS 2020-2024 build found 39 Suffolk County, New York
#' blockgroups in TIGER geography but not in the relevant ACS blockgroup or
#' tract tables. The default `blockgroup_universe_source = "acs"` therefore
#' treats `bg_acsdata` as the authoritative final blockgroup universe and uses
#' `bg_geodata` only to annotate those rows.
#'
#' To check them:
#' ```
#' print(
#' cbind(current_setting = Sys.getenv(c(
#'   "EJAM_PIPELINE_YR",
#'   "EJAM_PIPELINE_DIR", "EJAM_PIPELINE_STORAGE",
#'   "EJAM_STAGE_FORMAT", "EJAM_STAGE_FORMATS",
#'   "EJAM_BLOCKGROUP_UNIVERSE_SOURCE",
#'   "AWS_PROFILE", "AWS_REGION",
#'   "CENSUS_API_KEY",
#'   "EJAM_FORCE_ACS", "EJAM_FORCE_BG_ACSDATA", "EJAM_FORCE_BG_GEODATA",
#'   "EJAM_ACS_DOWNLOAD_TIMEOUT", "EJAM_ACS_DOWNLOAD_RETRIES",
#'   "EJAM_INCLUDE_ISLANDAREAS_DATA", "EJAM_ISLANDAREAS_REFERENCE_PATH",
#'   "EJAM_USE_ISLANDAREAS_DEMOGRAPHICS",
#'   "EJAM_BG_ENVIRODATA_REFERENCE_PATH", "EJAM_BG_ENVIRODATA_REFERENCE_VARS",
#'   "EJAM_USE_PROVISIONAL_BG_ENVIRODATA",
#'   "EJAM_INCLUDE_EJSCREEN_EXPORT", "EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT",
#'   "EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS",
#'   "EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT",
#'   "EJAM_VALIDATE_VS_PRIOR", "EJAM_PRIOR_PIPELINE_YR",
#'   "EJAM_PRIOR_PIPELINE_DIR", "EJAM_PRIOR_PACKAGE_REF"
#' )))
#' )
#' ```
#'
#'
#' @param yr end year of the ACS 5-year survey to use.
#' @param bg_envirodata environmental blockgroup table. If NULL, the wrapper
#'   tries to read the saved `bg_envirodata` stage when `use_saved_stages` is
#'   TRUE.
#' @param bg_extra_indicators non-ACS, non-enviro blockgroup indicators such as
#'   `lowlifex`, or NULL to read/reuse/create that stage.
#' @param bg_geodata Census/TIGER blockgroup geography stage, with
#'   square-meter `arealand` and `areawater` fields.
#' @param bg_acs_raw optional raw ACS pipeline object from
#'   [download_bg_acs_raw()].
#' @param bg_acsdata optional ACS-derived blockgroup table from
#'   [calc_bg_acsdata()].
#' @param blockgroupstats optional already-combined blockgroupstats-like table.
#' @param pipeline_dir folder or `s3://...` URI for reading/writing pipeline
#'   stage files.
#' @param pipeline_storage stage storage backend: `"auto"`, `"local"`, or
#'   `"s3"`. `"auto"` uses S3 when `pipeline_dir` starts with `s3://` and local
#'   file storage otherwise.
#' @param save_stages logical, whether to save each stage as it is created.
#' @param use_saved_stages logical, whether missing inputs may be read from
#'   existing files in `pipeline_dir`.
#' @param stage_format file format for saved/read tabular stages: `"csv"`,
#'   `"rds"`, `"rda"`, or `"arrow"`. The wrapper defaults to CSV so every
#'   pipeline checkpoint is easy to inspect outside R.
#' @param overwrite logical, whether to overwrite saved stage files.
#' @param validation_strict logical passed to stage validators.
#' @param download_acs_raw logical, whether to download raw ACS tables when
#'   neither `bg_acsdata` nor saved ACS stages are available.
#' @param download_bg_geodata logical, whether to download Census/TIGER
#'   blockgroup geography when `bg_geodata` is not supplied or saved.
#' @param blockgroup_universe_source passed to [calc_ejscreen_blockgroupstats()].
#'   The default `"acs"` uses the ACS table rows as the authoritative
#'   blockgroup universe for the requested ACS vintage.
#' @param acs_download_fun ACSdownload-compatible function used by
#'   [download_bg_acs_raw()] when raw ACS tables need to be downloaded. The
#'   default is [ACSdownload::get_acs_new()]. Supply a wrapper if you need a
#'   legacy ACS source implementation.
#' @param return_intermediate logical. If TRUE, return key interim stage objects
#'   in addition to final datasets.
#' @param include_ejscreen_export logical. If TRUE, also create the ordinary
#'   EJSCREEN-ready national-percentile export using [calc_ejscreen_export()].
#' @param include_ejscreen_export_statepct logical or NULL. If TRUE, also
#'   create an EPA `StatePct`-style export where state raw scores and state
#'   percentiles are written into the generic EPA field names. When NULL, this
#'   follows `include_ejscreen_export`.
#' @param include_ejscreen_pctile_lookup_exports logical or NULL. If TRUE,
#'   create EJScreen-style national and state percentile lookup CSV stages,
#'   `ejscreen_us_pctile_lookup` and `ejscreen_state_pctile_lookup`, from
#'   `usastats` and `statestats`. These use EJScreen field names and append a
#'   `std` row for each region. When NULL, these stages are created only when
#'   an explicit lookup-export save path is supplied.
#' @param include_ejscreen_dataset_creator_input logical. If TRUE, also create
#'   the smaller pre-index input table expected by EPA's
#'   `ejscreen-dataset-creator-2.3` Python tool.
#' @param ejscreen_export_path optional file path for the EJSCREEN national
#'   percentile export.
#' @param ejscreen_export_statepct_path optional file path for the EJSCREEN
#'   state-percentile export.
#' @param ejscreen_us_pctile_lookup_path,ejscreen_state_pctile_lookup_path
#'   optional file paths for the EJScreen-style national and state percentile
#'   lookup exports.
#' @param ejscreen_dataset_creator_input_path optional file path for the
#'   EJScreen dataset-creator input table.
#' @param ejscreen_export_vars optional EJAM `rname` columns to keep in the
#'   EJSCREEN export before renaming.
#' @param ejscreen_export_required_names optional final EJSCREEN field names
#'   that must be present.
#' @param ejscreen_export_rename_newtype naming column in [map_headernames] to
#'   use when renaming the EJSCREEN export.
#' @param ejscreen_export_feature_server_fields optional final EJSCREEN
#'   FeatureServer field list. Defaults to the current EJSCREEN v2.32 block
#'   group FeatureServer schema when an EJSCREEN export is requested.
#' @param ejscreen_pctile_lookup_output_fields optional EJScreen lookup-table
#'   field names. Defaults to the fields used by EPA's archived national/state
#'   lookup CSVs.
#' @inheritParams download_bg_acs_raw
#' @inheritParams calc_bg_acsdata
#' @inheritParams calc_bg_extra_indicators
#' @inheritParams calc_ejscreen_stats
#'
#' @return named list containing final datasets (`blockgroupstats`, `bgej`,
#'   `usastats`, and `statestats`) plus interim stages when
#'   `return_intermediate` is TRUE. Attributes record `pipeline_dir`,
#'   `stage_format`, and saved stage paths.
#'
#' @export
#' @keywords internal
#'
calc_ejscreen_dataset <- function(yr,
                                  bg_envirodata = NULL,
                                  bg_extra_indicators = NULL,
                                  bg_geodata = NULL,
                                  bg_acs_raw = NULL,
                                  bg_acsdata = NULL,
                                  blockgroupstats = NULL,
                                  pipeline_dir = NULL,
                                  pipeline_storage = c("auto", "local", "s3"),
                                  save_stages = FALSE,
                                  use_saved_stages = TRUE,
                                  stage_format = c("csv", "rds", "rda", "arrow"),
                                  raw_acs_storage = c("folder", "object"),
                                  raw_table_format = stage_format,
                                  overwrite = TRUE,
                                  validation_strict = TRUE,
                                  download_acs_raw = TRUE,
                                  acs_download_fun = ACSdownload::get_acs_new,
                                  return_intermediate = TRUE,
                                  include_ejscreen_export = FALSE,
                                  include_ejscreen_export_statepct = NULL,
                                  include_ejscreen_pctile_lookup_exports = NULL,
                                  include_ejscreen_dataset_creator_input = FALSE,
                                  ejscreen_export_path = NULL,
                                  ejscreen_export_statepct_path = NULL,
                                  ejscreen_us_pctile_lookup_path = NULL,
                                  ejscreen_state_pctile_lookup_path = NULL,
                                  ejscreen_dataset_creator_input_path = NULL,
                                  ejscreen_export_vars = NULL,
                                  ejscreen_export_required_names = NULL,
                                  ejscreen_export_rename_newtype = "ejscreen_indicator",
                                  ejscreen_export_feature_server_fields = NULL,
                                  ejscreen_pctile_lookup_output_fields = ejscreen_pctile_lookup_fields(),
                                  blockgroup_tables = setdiff(as.vector(EJAM::tables_ejscreen_acs), tract_tables),
                                  tract_tables = c("B18101", "C16001", "B27010"),
                                  tract_weight_source = c("decennial2020", "acs"),
                                  include_tract_data = TRUE,
                                  include_islandareas_data = FALSE,
                                  islandareas_raw = NULL,
                                  islandareas_demographics = NULL,
                                  islandareas_reference = NULL,
                                  islandareas_tables = islandareas_tables_for_bg_acsdata(),
                                  use_islandareas_demographics = FALSE,
                                  fiveorone = "5",
                                  download_timeout = 3600,
                                  download_retries = 2,
                                  download_bg_geodata = FALSE,
                                  blockgroup_universe_source = c("acs", "union"),
                                  formulas = EJAM::formulas_ejscreen_acs$formula,
                                  tract_formulas = NULL,
                                  dropMOE = TRUE,
                                  extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
                                  reuse_existing_if_missing = FALSE,
                                  existing_blockgroupstats = NULL,
                                  acs_vars = NULL,
                                  enviro_vars = NULL,
                                  ej_indicator_vars = names_e,
                                  ej_indicator_pctile_vars = names_e_pctile,
                                  ej_indicator_state_pctile_vars = names_e_state_pctile,
                                  ej_index_vars = names_ej,
                                  ej_index_supp_vars = names_ej_supp,
                                  ej_index_state_vars = names_ej_state,
                                  ej_index_supp_state_vars = names_ej_supp_state,
                                  demog_index_var = "Demog.Index",
                                  demog_index_supp_var = "Demog.Index.Supp",
                                  demog_index_state_var = "Demog.Index.State",
                                  demog_index_supp_state_var = "Demog.Index.Supp.State") {
  # validate parameters ####
  stage_format <- match.arg(stage_format)
  pipeline_storage <- match.arg(pipeline_storage)
  blockgroup_universe_source <- match.arg(blockgroup_universe_source)
  tract_weight_source <- match.arg(tract_weight_source)
  raw_acs_storage <- match.arg(raw_acs_storage)
  raw_table_format <- match.arg(raw_table_format, c("rds", "rda", "csv", "arrow"))

  if (missing(yr)) {
    yr <- acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)
  }
  if (isTRUE(save_stages) && is.null(pipeline_dir)) {
    stop("pipeline_dir must be provided when save_stages is TRUE")
  }
  if (isTRUE(use_saved_stages) && is.null(pipeline_dir)) {
    use_saved_stages <- FALSE
  }
  if (is.null(include_ejscreen_export_statepct)) {
    include_ejscreen_export_statepct <- isTRUE(include_ejscreen_export) ||
      !is.null(ejscreen_export_statepct_path)
  }
  if (is.null(include_ejscreen_pctile_lookup_exports)) {
    include_ejscreen_pctile_lookup_exports <- !is.null(ejscreen_us_pctile_lookup_path) ||
      !is.null(ejscreen_state_pctile_lookup_path)
  }
  # define helpers ####
  saved_paths <- character()
  stage_exists <- function(stage) {
    ejscreen_pipeline_stage_exists(stage, pipeline_dir, stage_format, storage = pipeline_storage)
  }
  load_stage <- function(stage) {
    ejscreen_pipeline_load(stage = stage, pipeline_dir = pipeline_dir, format = stage_format, storage = pipeline_storage)
  }
  save_stage <- function(x, stage, object_name = stage) {
    if (!isTRUE(save_stages)) {
      return(invisible(NULL))
    }
    saved_paths[[stage]] <<- ejscreen_pipeline_save(
      x = x,
      stage = stage,
      pipeline_dir = pipeline_dir,
      format = stage_format,
      object_name = object_name,
      overwrite = overwrite,
      validation_strict = validation_strict,
      yr = yr,
      storage = pipeline_storage
    )
    invisible(saved_paths[[stage]])
  }
  save_raw_acs_stage <- function(x) {
    if (!isTRUE(save_stages)) {
      return(invisible(NULL))
    }
    if (raw_acs_storage == "folder") {
      saved_paths[["bg_acs_raw"]] <<- save_bg_acs_raw_folder(
        x,
        pipeline_dir = pipeline_dir,
        table_format = raw_table_format,
        overwrite = overwrite,
        validation_strict = validation_strict,
        storage = pipeline_storage
      )
    } else {
      saved_paths[["bg_acs_raw"]] <<- ejscreen_pipeline_save(
        x = x,
        stage = "bg_acs_raw",
        pipeline_dir = pipeline_dir,
        format = stage_format,
        overwrite = overwrite,
        validation_strict = validation_strict,
        yr = yr,
        storage = pipeline_storage
      )
    }
    invisible(saved_paths[["bg_acs_raw"]])
  }

  # check which datasets are here ####
  bg_acs_raw_was_loaded <- FALSE
  bg_acsdata_was_loaded <- FALSE
  bg_envirodata_was_loaded <- FALSE
  bg_extra_was_loaded <- FALSE
  bg_geodata_was_loaded <- FALSE
  blockgroupstats_was_loaded <- FALSE
  upstream_inputs_supplied <- any(vapply(
    list(bg_acs_raw, bg_acsdata, bg_envirodata, bg_extra_indicators),
    Negate(is.null),
    logical(1)
  ))
  # ~ ----------------------------------------- ####
  # BLOCKGROUP DATA (Envt, Demog, Extra) ####
  # blockgroupstats ####
  ## read blockgroupstats if not provided as param  ####
  # potentially confusing since it is the parameter name and a lazy-loaded dataset in /data/
  if (is.null(blockgroupstats) &&
      !isTRUE(upstream_inputs_supplied) &&
      isTRUE(use_saved_stages) &&
      stage_exists("blockgroupstats")) {
    blockgroupstats <- load_stage("blockgroupstats")
    blockgroupstats_was_loaded <- TRUE
  }
  ## or create blockgroupstats if necessary ####
  if (is.null(blockgroupstats)) {

    if (is.null(bg_acsdata)) {
      ## 1._need bg_acsdata ####
      if (is.null(bg_acs_raw) && isTRUE(use_saved_stages) && stage_exists("bg_acsdata")) {
        ## _read bg_acsdata if can ####
        bg_acsdata <- load_stage("bg_acsdata")
        bg_acsdata_was_loaded <- TRUE
      } else {

        if (is.null(bg_acs_raw)) {
          ### _or try calc_bg_acsdata if necessary ####
          #### _need bg_acs_raw ####
          if (isTRUE(use_saved_stages) && stage_exists("bg_acs_raw")) {
            #### _read bg_acs_raw if can ####
            bg_acs_raw <- load_stage("bg_acs_raw")
            bg_acs_raw_was_loaded <- TRUE
          } else if (isTRUE(download_acs_raw)) {
            #### __or download bg_acsdata if necessary ####
            bg_acs_raw <- download_bg_acs_raw(
              yr = yr,
              blockgroup_tables = blockgroup_tables,
              tract_tables = tract_tables,
              include_tract_data = include_tract_data,
              fiveorone = fiveorone,
              download_timeout = download_timeout,
              download_retries = download_retries,
              download_fun = acs_download_fun,
              pipeline_dir = pipeline_dir,
              save_stage = save_stages,
              stage_format = stage_format,
              raw_acs_storage = raw_acs_storage,
              raw_table_format = raw_table_format,
              overwrite = overwrite,
              validation_strict = validation_strict,
              storage = pipeline_storage
            )
            if (isTRUE(save_stages)) {
              saved_path <- attr(bg_acs_raw, "saved_stage_path", exact = TRUE)
              if (is.null(saved_path)) {
                saved_path <- if (raw_acs_storage == "folder") {
                  bg_acs_raw_folder_path(pipeline_dir)
                } else {
                  ejscreen_pipeline_stage_path("bg_acs_raw", pipeline_dir, stage_format)
                }
              }
              saved_paths[["bg_acs_raw"]] <- saved_path
            }
          }
        } else {
          ejscreen_pipeline_validate(bg_acs_raw, stage = "bg_acs_raw", strict = validation_strict)
          save_raw_acs_stage(bg_acs_raw)
        }

        if (is.null(bg_acs_raw) && !isTRUE(download_acs_raw)) {
          stop("bg_acsdata must be supplied, read from a saved stage, or created by setting download_acs_raw = TRUE")
        }
        ####__ >>  calc_bg_acsdata << ####
        bg_acsdata <- calc_bg_acsdata(
          yr = yr,
          formulas = formulas,
          tables = blockgroup_tables,
          include_tract_data = include_tract_data,
          tract_tables = tract_tables,
          tract_formulas = tract_formulas,
          tract_weight_source = tract_weight_source,
          dropMOE = dropMOE,
          acs_raw = bg_acs_raw,
          include_islandareas_data = include_islandareas_data,
          islandareas_raw = islandareas_raw,
          islandareas_demographics = islandareas_demographics,
          islandareas_reference = islandareas_reference,
          islandareas_tables = islandareas_tables,
          use_islandareas_demographics = use_islandareas_demographics,
          pipeline_dir = pipeline_dir,
          save_stage = FALSE,
          stage_format = stage_format,
          overwrite = overwrite,
          validation_strict = validation_strict
        )
        save_stage(bg_acsdata, "bg_acsdata")
      }
    } else {
      ejscreen_pipeline_validate(bg_acsdata, stage = "bg_acsdata", strict = validation_strict)
      save_stage(bg_acsdata, "bg_acsdata")
    }

    if (is.null(bg_envirodata)) {
      ###  __ 2. need bg_envirodata ####
      if (isTRUE(use_saved_stages) && stage_exists("bg_envirodata")) {
        ## __ >> read bg_envirodata  <<  if can ####
        bg_envirodata <- load_stage("bg_envirodata")
        bg_envirodata_was_loaded <- TRUE
      } else {
        ## __or stop - missing bg_envirodata ####
        stop("bg_envirodata must be supplied or available as a saved bg_envirodata stage")
      }
    } else {
      ejscreen_pipeline_validate(bg_envirodata, stage = "bg_envirodata", strict = validation_strict)
      save_stage(bg_envirodata, "bg_envirodata")
    }

    if (is.null(bg_extra_indicators) &&
        isTRUE(use_saved_stages) &&
        stage_exists("bg_extra_indicators")) {
      ### __ 3. need bg_extra_indicators ####

      ###__ read bg_extra_indicators ####
      bg_extra_indicators <- load_stage("bg_extra_indicators")
      bg_extra_was_loaded <- TRUE
    }
    if (!isTRUE(bg_extra_was_loaded)) {
      ###  __or >> calc_bg_extra_indicators << #####
      bg_extra_indicators <- calc_bg_extra_indicators(
        bg_extra_indicators = bg_extra_indicators,
        extra_indicator_vars = extra_indicator_vars,
        reuse_existing_if_missing = reuse_existing_if_missing,
        existing_blockgroupstats = existing_blockgroupstats,
        pipeline_dir = pipeline_dir,
        save_stage = FALSE,
        stage_format = stage_format,
        overwrite = overwrite,
        validation_strict = validation_strict
      )
      save_stage(bg_extra_indicators, "bg_extra_indicators")
    } else {
      ejscreen_pipeline_validate(bg_extra_indicators, stage = "bg_extra_indicators", strict = validation_strict)
    }

    geodata_bgfips <- if (blockgroup_universe_source == "acs") {
      unique(bg_acsdata$bgfips)
    } else {
      unique(c(bg_acsdata$bgfips, bg_envirodata$bgfips, bg_extra_indicators$bgfips))
    }

    if (is.null(bg_geodata) &&
        isTRUE(use_saved_stages) &&
        stage_exists("bg_geodata")) {
      bg_geodata <- load_stage("bg_geodata")
      bg_geodata_was_loaded <- TRUE
    }
    if (is.null(bg_geodata) && isTRUE(download_bg_geodata)) {
      bg_geodata <- calc_bg_geodata(
        yr = yr,
        bgfips = geodata_bgfips,
        reuse_existing_if_missing = reuse_existing_if_missing,
        existing_blockgroupstats = existing_blockgroupstats,
        download_timeout = download_timeout,
        download_retries = download_retries,
        pipeline_dir = pipeline_dir,
        save_stage = FALSE,
        stage_format = stage_format,
        pipeline_storage = pipeline_storage,
        validation_strict = validation_strict
      )
      save_stage(bg_geodata, "bg_geodata")
    } else if (!is.null(bg_geodata)) {
      bg_geodata <- complete_bg_geodata(
        bg_geodata = bg_geodata,
        bgfips = geodata_bgfips,
        existing_blockgroupstats = existing_blockgroupstats,
        reuse_existing_if_missing = reuse_existing_if_missing
      )
      ejscreen_pipeline_validate(bg_geodata, stage = "bg_geodata", strict = validation_strict)
      save_stage(bg_geodata, "bg_geodata")
    }
    # __>> calc_ejscreen_blockgroupstats ####

    blockgroupstats <- calc_ejscreen_blockgroupstats(
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      bg_extra_indicators = bg_extra_indicators,
      bg_geodata = bg_geodata,
      blockgroup_universe_source = blockgroup_universe_source,
      pipeline_dir = pipeline_dir,
      extra_indicator_vars = extra_indicator_vars,
      reuse_existing_extra_if_missing = reuse_existing_if_missing,
      existing_blockgroupstats = existing_blockgroupstats,
      save_stage = FALSE,
      pipeline_storage = pipeline_storage,
      stage_format = stage_format,
      yr = yr
    )

    # save blockgroupstats ####

    save_stage(blockgroupstats, "blockgroupstats")
  } else {
    ejscreen_pipeline_validate(blockgroupstats, stage = "blockgroupstats", strict = validation_strict)
    if (!isTRUE(blockgroupstats_was_loaded)) {
      save_stage(blockgroupstats, "blockgroupstats")
    }
  }
  # ~ ----------------------------------------- ####
  # EJ INDEXES + PERCENTILE LOOKUPS ####
  # * bgej, usastats, statestats (& intermed tables) ####
  # i.e.,  EJ Indexes + percentile lookup tables
  ## > calc_ejscreen_stats ####
  stats <- calc_ejscreen_stats(
    bgstats = blockgroupstats,
    pipeline_dir = pipeline_dir,
    save_stages = FALSE, # stages will be saved individually in this wrapper, in loop below
    stage_format = stage_format,
    yr = yr,
    acs_vars = acs_vars,
    enviro_vars = enviro_vars,
    ej_indicator_vars = ej_indicator_vars,
    ej_indicator_pctile_vars = ej_indicator_pctile_vars,
    ej_indicator_state_pctile_vars = ej_indicator_state_pctile_vars,
    ej_index_vars = ej_index_vars,
    ej_index_supp_vars = ej_index_supp_vars,
    ej_index_state_vars = ej_index_state_vars,
    ej_index_supp_state_vars = ej_index_supp_state_vars,
    demog_index_var = demog_index_var,
    demog_index_supp_var = demog_index_supp_var,
    demog_index_state_var = demog_index_state_var,
    demog_index_supp_state_var = demog_index_supp_state_var
  )
  # save bgej, usastats, statestats ####
  if (isTRUE(save_stages)) {
    for (stage in names(stats)) {
      save_stage(stats[[stage]], stage)
    }
  }

  # ~ ----------------------------------------- ####

  ## Return 4 key tables ####
  ## (blockgroupstats, bgej, usastats, statestats) ####
  out <- list(
    blockgroupstats = blockgroupstats,
    bgej = stats$bgej,
    usastats = stats$usastats,
    statestats = stats$statestats
  )

  ## + maybe intermediate tables ####
  if (isTRUE(return_intermediate)) {
    out <- c(list(
      bg_acs_raw = bg_acs_raw,
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      bg_extra_indicators = bg_extra_indicators,
      bg_geodata = bg_geodata,

      usastats_acs = stats$usastats_acs,
      statestats_acs = stats$statestats_acs,
      usastats_envirodata = stats$usastats_envirodata,
      statestats_envirodata = stats$statestats_envirodata,
      usastats_ej = stats$usastats_ej,
      statestats_ej = stats$statestats_ej

    ), out)
  }
  # ~ ----------------------------------------- ####
  # EJSCREEN PYTHON DATASET-CREATOR INPUT FILE ####
  # * Smaller pre-index input for ejscreen-dataset-creator-2.3 ####
  # ~ ----------------------------------------- ####
  if (isTRUE(include_ejscreen_dataset_creator_input) ||
      !is.null(ejscreen_dataset_creator_input_path)) {
    dataset_creator_input <- calc_ejscreen_dataset_creator_input(
      blockgroupstats = blockgroupstats,
      save_path = ejscreen_dataset_creator_input_path,
      pipeline_storage = pipeline_storage,
      overwrite = overwrite
    )
    out$ejscreen_dataset_creator_input <- dataset_creator_input
    if (isTRUE(save_stages)) {
      save_stage(out$ejscreen_dataset_creator_input, "ejscreen_dataset_creator_input")
    }
  }
  # ~ ----------------------------------------- ####
  # EJSCREEN FILE ####
  # * EJScreen dataset format for EJScreen app ####
  ## > calc_ejscreen_export ####
  # ~ ----------------------------------------- ####
  if (isTRUE(include_ejscreen_export) || !is.null(ejscreen_export_path) ||
      isTRUE(include_ejscreen_export_statepct) || !is.null(ejscreen_export_statepct_path)) {
    if (is.null(ejscreen_export_feature_server_fields)) {
      ejscreen_export_feature_server_fields <- ejscreen_feature_server_fields()
    }
  }
  if (isTRUE(include_ejscreen_export) || !is.null(ejscreen_export_path)) {
    # Return 1 ejscreen_export table  ####
    out$ejscreen_export <- calc_ejscreen_export(
      blockgroupstats = blockgroupstats,
      bgej = stats$bgej,
      usastats_acs = stats$usastats_acs,
      usastats_envirodata = stats$usastats_envirodata,
      usastats_ej = stats$usastats_ej,
      statestats_ej = stats$statestats_ej,
      export_percentile_scope = "national",
      output_vars =           ejscreen_export_vars,
      rename_newtype =        ejscreen_export_rename_newtype,
      required_output_names = ejscreen_export_required_names,
      feature_server_fields = ejscreen_export_feature_server_fields,
      save_path =             ejscreen_export_path,
      pipeline_storage = pipeline_storage,
      overwrite = overwrite
    )
    if (isTRUE(save_stages)) {
      save_stage(out$ejscreen_export, "ejscreen_export")
    }
  }
  if (isTRUE(include_ejscreen_export_statepct) || !is.null(ejscreen_export_statepct_path)) {
    # Return EPA StatePct-style export table, with state values in generic EPA fields. ####
    out$ejscreen_export_statepct <- calc_ejscreen_export(
      blockgroupstats = blockgroupstats,
      bgej = stats$bgej,
      statestats_acs = stats$statestats_acs,
      statestats_envirodata = stats$statestats_envirodata,
      statestats_ej = stats$statestats_ej,
      export_percentile_scope = "state",
      output_vars =           ejscreen_export_vars,
      rename_newtype =        ejscreen_export_rename_newtype,
      required_output_names = ejscreen_export_required_names,
      feature_server_fields = ejscreen_statepct_feature_server_fields(ejscreen_export_feature_server_fields),
      save_path =             ejscreen_export_statepct_path,
      pipeline_storage = pipeline_storage,
      overwrite = overwrite
    )
    if (isTRUE(save_stages)) {
      save_stage(out$ejscreen_export_statepct, "ejscreen_export_statepct")
    }
  }
  # ~ ----------------------------------------- ####
  # EJSCREEN PERCENTILE LOOKUP FILES ####
  # * EPA-shaped lookup files corresponding to usastats/statestats ####
  # ~ ----------------------------------------- ####
  if (isTRUE(include_ejscreen_pctile_lookup_exports) ||
      !is.null(ejscreen_us_pctile_lookup_path) ||
      !is.null(ejscreen_state_pctile_lookup_path)) {
    lookup_values <- data.table::as.data.table(data.table::copy(blockgroupstats))
    bgej_for_lookup <- data.table::as.data.table(data.table::copy(stats$bgej))
    if ("bgfips" %in% names(lookup_values) && "bgfips" %in% names(bgej_for_lookup)) {
      bgej_extra_cols <- setdiff(names(bgej_for_lookup), names(lookup_values))
      if (length(bgej_extra_cols) > 0) {
        bgej_extra <- bgej_for_lookup[, c("bgfips", bgej_extra_cols), with = FALSE]
        lookup_values <- merge(lookup_values, bgej_extra, by = "bgfips", all.x = TRUE, sort = FALSE)
      }
    }

    out$ejscreen_us_pctile_lookup <- calc_ejscreen_pctile_lookup_export(
      lookup = stats$usastats,
      values = lookup_values,
      scope = "national",
      output_fields = ejscreen_pctile_lookup_output_fields,
      rename_newtype = ejscreen_export_rename_newtype,
      save_path = ejscreen_us_pctile_lookup_path,
      pipeline_storage = pipeline_storage,
      overwrite = overwrite
    )
    out$ejscreen_state_pctile_lookup <- calc_ejscreen_pctile_lookup_export(
      lookup = stats$statestats,
      values = lookup_values,
      scope = "state",
      output_fields = ejscreen_pctile_lookup_output_fields,
      rename_newtype = ejscreen_export_rename_newtype,
      save_path = ejscreen_state_pctile_lookup_path,
      pipeline_storage = pipeline_storage,
      overwrite = overwrite
    )
    if (isTRUE(save_stages)) {
      save_stage(out$ejscreen_us_pctile_lookup, "ejscreen_us_pctile_lookup")
      save_stage(out$ejscreen_state_pctile_lookup, "ejscreen_state_pctile_lookup")
    }
  }
  # ~ ----------------------------------------- ####
  ## set attributes & return list of tables ####
  attr(out, "pipeline_dir") <- pipeline_dir
  attr(out, "pipeline_storage") <- ejscreen_pipeline_storage_backend(pipeline_dir, storage = pipeline_storage)
  attr(out, "stage_format") <- stage_format
  attr(out, "saved_stage_paths") <- saved_paths
  attr(out, "loaded_stages") <- c(
    bg_acs_raw = bg_acs_raw_was_loaded,
    bg_acsdata = bg_acsdata_was_loaded,
    bg_envirodata = bg_envirodata_was_loaded,
    bg_extra_indicators = bg_extra_was_loaded,
    bg_geodata = bg_geodata_was_loaded,
    blockgroupstats = blockgroupstats_was_loaded
  )
  class(out) <- c("ejam_ejscreen_dataset", class(out))
  out
}

###################################################### #
