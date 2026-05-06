###################################################### #

#' Calculate the ACS-derived blockgroup pipeline stage
#'
#' @details This is the first step in the reusable ACS pipeline for annual
#' EJSCREEN/EJAM data updates. It downloads blockgroup-resolution ACS tables via
#' [calc_blockgroupstats_acs()], apportions tract-resolution-only ACS
#' tables to blockgroups with [calc_blockgroupstats_from_tract_data()], merges
#' those ACS-derived indicators, and can save the validated `bg_acsdata` stage.
#'
#' `bg_acsdata` is intentionally limited to data columns that can be created
#' using only ACS data. "Demographic index" columns are calculated later
#' by [calc_ejscreen_blockgroupstats()], after
#' `bg_envirodata` and extra indicators have been joined, because the
#' supplemental demographic index needs `lowlifex` which is not from the ACS.
#'
#' @param yr end year of the ACS 5-year survey to use.
#' @param formulas formulas used for blockgroup-resolution ACS tables.
#' @param tables ACS tables to inspect and download when available at
#'   blockgroup resolution.
#' @param include_tract_data logical, whether to add tract-resolution ACS
#'   indicators apportioned to blockgroups.
#' @param tract_tables ACS tables to obtain at tract resolution and apportion
#'   to blockgroups.
#' @param tract_formulas formulas used for tract-resolution ACS indicators.
#'   Defaults to [calc_blockgroupstats_from_tract_data()] defaults.
#' @param dropMOE logical, whether to drop ACS margin-of-error columns.
#' @param acs_raw optional raw ACS pipeline object from [download_bg_acs_raw()].
#' @param acs_raw_stage optional stage name to read from `pipeline_dir`.
#' @param pipeline_dir folder for saving the pipeline stage.
#' @param save_stage logical, whether to save the `bg_acsdata` stage.
#' @param stage_format file format for saved stages: `"csv"`, `"rds"`,
#'   `"rda"`, or `"arrow"`.
#' @param overwrite logical, whether to overwrite an existing saved stage.
#' @param validation_strict logical passed to [ejscreen_pipeline_save()].
#'
#' @return data.table, one row per blockgroup.
#'
#' @export
#' @keywords internal
#'
calc_bg_acsdata <- function(yr,
                            formulas = EJAM::formulas_ejscreen_acs$formula,
                            tables = as.vector(EJAM::tables_ejscreen_acs),
                            include_tract_data = TRUE,
                            tract_tables = c("B18101", "C16001"),
                            tract_formulas = NULL,
                            dropMOE = TRUE,
                            acs_raw = NULL,
                            acs_raw_stage = NULL,
                            pipeline_dir = NULL,
                            save_stage = FALSE,
                            stage_format = c("csv", "rds", "rda", "arrow"),
                            overwrite = TRUE,
                            validation_strict = TRUE) {
  stage_format <- match.arg(stage_format)

  if (missing(yr)) {
    yr <- acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)
  }
  if (is.null(acs_raw) && !is.null(acs_raw_stage)) {
    acs_raw <- ejscreen_pipeline_input(
      stage = acs_raw_stage,
      pipeline_dir = pipeline_dir,
      format = stage_format,
      input_name = "acs_raw"
    )
  }

  bg_acsdata <- calc_blockgroupstats_acs(
    yr = yr,
    formulas = formulas,
    tables = tables,
    dropMOE = dropMOE,
    acs_raw = acs_raw
  )

  if (include_tract_data) {
    bg_from_tracts <- calc_blockgroupstats_from_tract_data(
      yr = yr,
      tables = tract_tables,
      formulas = tract_formulas,
      dropMOE = dropMOE,
      acs_raw = acs_raw
    )
    bg_acsdata <- merge_bg_acsdata_tract_data(bg_acsdata, bg_from_tracts)
  }

  data.table::setDT(bg_acsdata)
  data.table::setorder(bg_acsdata, bgfips)

  if (save_stage) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stage is TRUE")
    }
    ejscreen_pipeline_save(
      bg_acsdata,
      stage = "bg_acsdata",
      pipeline_dir = pipeline_dir,
      format = stage_format,
      overwrite = overwrite,
      validation_strict = validation_strict
    )
  } else {
    ejscreen_pipeline_validate(bg_acsdata, stage = "bg_acsdata", strict = validation_strict)
  }

  bg_acsdata
}

merge_bg_acsdata_tract_data <- function(bg_acsdata, bg_from_tracts) {
  bg_acsdata <- data.table::as.data.table(data.table::copy(bg_acsdata))
  bg_from_tracts <- data.table::as.data.table(data.table::copy(bg_from_tracts))

  if (!"bgfips" %in% names(bg_acsdata)) {
    stop("bg_acsdata must have a bgfips column")
  }
  if (!"bgfips" %in% names(bg_from_tracts)) {
    stop("bg_from_tracts must have a bgfips column")
  }

  cols_to_add <- setdiff(names(bg_from_tracts), names(bg_acsdata))
  if (length(cols_to_add) == 0) {
    return(bg_acsdata)
  }

  out <- merge(
    bg_acsdata,
    bg_from_tracts[, c("bgfips", cols_to_add), with = FALSE],
    by = "bgfips",
    all.x = TRUE,
    sort = FALSE
  )
  data.table::setorder(out, bgfips)
  out
}

###################################################### #
