###################################################### #

#' Run the staged EJSCREEN/EJAM dataset update pipeline
#'
#' @details
#' `calc_ejscreen_dataset()` can be called from a script each year.
#' See the runner script `data-raw/run_ejscreen_acs2024_pipeline.R`
#' for an example of how to call this function, and how it can be used
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
#' 2. calculate ACS-based demographic indicators (and lead paint indicator) as `bg_acsdata`
#' 3. validate/save `bg_envirodata` (key environmental indicators)
#' 4. validate/save `bg_extra_indicators` (e.g., % low life expectancy)
#' 5. calculate demographic indexes (using % low life expectancy, etc.)
#' 6. combine those blockgroup demog., envt., and extra indicators as [blockgroupstats]
#' 7. create intermediate percentile lookup tables `usastats_acs`, `statestats_acs`, `usastats_envirodata`, `statestats_envirodata`
#' 8. calculate EJ indexes (from envt. percentiles and demog. indexes) and save as [bgej] table
#' 9. create intermediate percentile lookup tables `usastats_ej`, `statestats_ej`
#' 10. combine those as [usastats] and [statestats]
#' 11. create an EJScreen-ready export file (optionally)
#'
#' `bg_envirodata` must include `pctpre1960`. That column may be produced by an
#' upstream environmental-data step that reads the saved `bg_acsdata` stage.
#'
#' Note that the runner script can use several settings stored as environment variables:
#'
#'  - EJAM_PIPELINE_YR
#'
#'  - EJAM_PIPELINE_DIR: override output folder.
#'  - EJAM_PIPELINE_STORAGE: auto, local, or s3. auto treats s3:// paths as S3.
#'  - AWS_PROFILE and AWS_REGION: used when pipeline_storage is s3
#'  - CENSUS_API_KEY: used by functions that download ACS data (or that download boundaries/shapefiles for FIPS from some sources)
#'  - EJAM_FORCE_ACS: TRUE to redownload/recalculate raw ACS and bg_acsdata.
#'  - EJAM_FORCE_BG_ACSDATA: TRUE to rebuild bg_acsdata from saved raw ACS.
#'  - EJAM_ACS_DOWNLOAD_TIMEOUT
#'  - EJAM_ACS_DOWNLOAD_RETRIES
#'
#'  - EJAM_USE_PROVISIONAL_BG_ENVIRODATA: FALSE to require bg_envirodata.csv.
#'
#'  - EJAM_INCLUDE_EJSCREEN_EXPORT: TRUE to create ejscreen_export.csv.
#'
#' To check them:
#' ```
#' print(
#' cbind(current_setting = Sys.getenv(c(
#'   "EJAM_PIPELINE_YR",
#'   "EJAM_PIPELINE_DIR", "EJAM_PIPELINE_STORAGE", "AWS_PROFILE", "AWS_REGION",
#'   "CENSUS_API_KEY",
#'   "EJAM_FORCE_ACS", "EJAM_FORCE_BG_ACSDATA",
#'   "EJAM_ACS_DOWNLOAD_TIMEOUT", "EJAM_ACS_DOWNLOAD_RETRIES",
#'   "EJAM_USE_PROVISIONAL_BG_ENVIRODATA",
#'   "EJAM_INCLUDE_EJSCREEN_EXPORT"
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
#' @param return_intermediate logical. If TRUE, return key interim stage objects
#'   in addition to final datasets.
#' @param include_ejscreen_export logical. If TRUE, also create an
#'   EJSCREEN-ready export using [calc_ejscreen_export()].
#' @param ejscreen_export_path optional file path for the EJSCREEN export.
#' @param ejscreen_export_vars optional EJAM `rname` columns to keep in the
#'   EJSCREEN export before renaming.
#' @param ejscreen_export_required_names optional final EJSCREEN field names
#'   that must be present.
#' @param ejscreen_export_rename_newtype naming column in [map_headernames] to
#'   use when renaming the EJSCREEN export.
#' @param ejscreen_export_feature_server_fields optional final EJSCREEN
#'   FeatureServer field list. Defaults to the current EJSCREEN v2.32 block
#'   group FeatureServer schema when an EJSCREEN export is requested.
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
                                  return_intermediate = TRUE,
                                  include_ejscreen_export = FALSE,
                                  ejscreen_export_path = NULL,
                                  ejscreen_export_vars = NULL,
                                  ejscreen_export_required_names = NULL,
                                  ejscreen_export_rename_newtype = "ejscreen_indicator",
                                  ejscreen_export_feature_server_fields = NULL,
                                  blockgroup_tables = setdiff(as.vector(EJAM::tables_ejscreen_acs), tract_tables),
                                  tract_tables = c("B18101", "C16001"),
                                  include_tract_data = TRUE,
                                  fiveorone = "5",
                                  download_timeout = 3600,
                                  download_retries = 2,
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
          dropMOE = dropMOE,
          acs_raw = bg_acs_raw,
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
    # __>> calc_ejscreen_blockgroupstats ####

    blockgroupstats <- calc_ejscreen_blockgroupstats(
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      bg_extra_indicators = bg_extra_indicators,
      pipeline_dir = pipeline_dir,
      extra_indicator_vars = extra_indicator_vars,
      reuse_existing_extra_if_missing = reuse_existing_if_missing,
      existing_blockgroupstats = existing_blockgroupstats,
      save_stage = FALSE,
      stage_format = stage_format
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
    save_stages = FALSE,
    stage_format = stage_format,
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

      usastats_acs = stats$usastats_acs,
      statestats_acs = stats$statestats_acs,
      usastats_envirodata = stats$usastats_envirodata,
      statestats_envirodata = stats$statestats_envirodata,
      usastats_ej = stats$usastats_ej,
      statestats_ej = stats$statestats_ej

    ), out)
  }
  # ~ ----------------------------------------- ####
  # EJSCREEN FILE ####
  # * EJScreen dataset format for EJScreen app ####
  ## > calc_ejscreen_export ####
  # ~ ----------------------------------------- ####
  if (isTRUE(include_ejscreen_export) || !is.null(ejscreen_export_path)) {
    if (is.null(ejscreen_export_feature_server_fields)) {
      ejscreen_export_feature_server_fields <- ejscreen_feature_server_fields()
    }
    # Return 1 ejscreen_export table  ####
    out$ejscreen_export <- calc_ejscreen_export(
      blockgroupstats = blockgroupstats,
      bgej = stats$bgej,
      usastats_acs = stats$usastats_acs,
      usastats_envirodata = stats$usastats_envirodata,
      usastats_ej = stats$usastats_ej,
      statestats_ej = stats$statestats_ej,
      output_vars =           ejscreen_export_vars,
      rename_newtype =        ejscreen_export_rename_newtype,
      required_output_names = ejscreen_export_required_names,
      feature_server_fields = ejscreen_export_feature_server_fields,
      save_path =             ejscreen_export_path,
      overwrite = overwrite
    )
    if (isTRUE(save_stages)) {
      save_stage(out$ejscreen_export, "ejscreen_export")
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
    blockgroupstats = blockgroupstats_was_loaded
  )
  class(out) <- c("ejam_ejscreen_dataset", class(out))
  out
}

###################################################### #
