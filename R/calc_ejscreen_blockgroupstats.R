###################################################### #

#' Combine ACS and environmental inputs into blockgroupstats
#'
#' @details This is a reusable pipeline step. It combines an ACS-derived
#' blockgroup table with environmental and other non-ACS indicator columns,
#' calculates demographic indexes, and optionally saves the final
#' [blockgroupstats] stage.
#'
#' The environmental input is expected to include `pctpre1960`. That indicator
#' can be created by an upstream envirodata step from the saved ACS stage, even
#' though EJAM treats it as an environmental indicator for EJ-index calculations.
#'
#' @param bg_acsdata ACS-derived blockgroup table, or NULL if reading from a
#'   saved pipeline stage.
#' @param bg_envirodata environmental/non-ACS blockgroup table, or NULL if
#'   reading from a saved pipeline stage such as `"bg_envirodata"`.
#' @param bg_extra_indicators non-ACS, non-enviro blockgroup indicators such as
#'   `lowlifex`, health outcome rates, site/feature counts, climate indicators,
#'   and flag fields.
#' @param pipeline_dir folder for reading/writing pipeline stage files.
#' @param pipeline_storage stage storage backend: `"auto"`, `"local"`, or
#'   `"s3"`.
#' @param bg_acsdata_stage stage name for ACS input.
#' @param bg_envirodata_stage stage name for environmental input.
#' @param bg_extra_indicators_stage stage name for extra-indicator input.
#' @param extra_indicator_vars expected extra indicator columns.
#' @param reuse_existing_extra_if_missing logical. If TRUE, missing
#'   `bg_extra_indicators` columns are copied from `existing_blockgroupstats`
#'   with a warning. The default FALSE errors on missing extra inputs.
#' @param existing_blockgroupstats optional source for reuse when
#'   `reuse_existing_extra_if_missing` is TRUE. Defaults to current package data.
#' @param save_stage logical, whether to save the final `blockgroupstats` stage.
#' @param stage_format file format for saved/read stages: `"csv"`, `"rds"`,
#'   `"rda"`, or `"arrow"`.
#' @param blockgroupstats_acs,blockgroupstats_acs_stage old names retained as
#'   aliases for draft scripts.
#'
#' @return data.table like [blockgroupstats].
#'
#' @keywords internal
#'
calc_ejscreen_blockgroupstats <- function(bg_acsdata = NULL,
                                          bg_envirodata = NULL,
                                          bg_extra_indicators = NULL,
                                          pipeline_dir = NULL,
                                          bg_acsdata_stage = "bg_acsdata",
                                          bg_envirodata_stage = "bg_envirodata",
                                          bg_extra_indicators_stage = "bg_extra_indicators",
                                          extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
                                          reuse_existing_extra_if_missing = FALSE,
                                          existing_blockgroupstats = NULL,
                                          save_stage = FALSE,
                                          pipeline_storage = c("auto", "local", "s3"),
                                          stage_format = c("csv", "rds", "rda", "arrow"),
                                          blockgroupstats_acs = NULL,
                                          blockgroupstats_acs_stage = NULL) {
  stage_format <- match.arg(stage_format)
  pipeline_storage <- match.arg(pipeline_storage)

  if (is.null(bg_acsdata) && !is.null(blockgroupstats_acs)) {
    bg_acsdata <- blockgroupstats_acs
  }
  if (!is.null(blockgroupstats_acs_stage)) {
    bg_acsdata_stage <- blockgroupstats_acs_stage
  }

  acs <- ejscreen_pipeline_input(
    x = bg_acsdata,
    stage = bg_acsdata_stage,
    pipeline_dir = pipeline_dir,
    format = stage_format,
    storage = pipeline_storage,
    input_name = "bg_acsdata"
  )
  enviro <- ejscreen_pipeline_input(
    x = bg_envirodata,
    stage = bg_envirodata_stage,
    pipeline_dir = pipeline_dir,
    format = stage_format,
    storage = pipeline_storage,
    input_name = "bg_envirodata"
  )
  if (is.null(bg_extra_indicators) && !is.null(pipeline_dir) &&
      !is.null(bg_extra_indicators_stage) &&
      ejscreen_pipeline_stage_exists(
        bg_extra_indicators_stage,
        pipeline_dir = pipeline_dir,
        format = stage_format,
        storage = pipeline_storage
      )) {
    bg_extra_indicators <- ejscreen_pipeline_input(
      stage = bg_extra_indicators_stage,
      pipeline_dir = pipeline_dir,
      format = stage_format,
      storage = pipeline_storage,
      input_name = "bg_extra_indicators"
    )
  }

  acs    <- data.table::as.data.table(data.table::copy(acs))
  enviro <- data.table::as.data.table(data.table::copy(enviro))
  extra <- complete_bg_extra_indicators(
    bg_extra_indicators = bg_extra_indicators,
    extra_indicator_vars = extra_indicator_vars,
    reuse_existing_if_missing = reuse_existing_extra_if_missing,
    existing_blockgroupstats = existing_blockgroupstats
  )

  if (!"bgfips" %in% names(acs)) {
    stop("bg_acsdata must have a bgfips column")
  }
  if (!"bgfips" %in% names(enviro)) {
    stop("bg_envirodata must have a bgfips column")
  }
  if (!"pctpre1960" %in% names(enviro)) {
    stop("bg_envirodata must include pctpre1960, even if that column was created from the ACS stage")
  }
  blockgroup_universe <- unique(c(
    as.character(acs$bgfips),
    as.character(enviro$bgfips),
    as.character(extra$bgfips)
  ))
  blockgroup_universe <- blockgroup_universe[!is.na(blockgroup_universe) & nzchar(blockgroup_universe)]
  acs <- merge(
    data.table::data.table(bgfips = blockgroup_universe),
    acs,
    by = "bgfips",
    all.x = TRUE,
    sort = FALSE
  )
  acs <- add_bg_geography_columns(acs)
  cols_to_add <- setdiff(names(extra), c("bgfips", names(acs)))
  if (length(cols_to_add) > 0) {
    acs <- merge(acs, extra[, c("bgfips", cols_to_add), with = FALSE], by = "bgfips", all.x = TRUE)
  }

  if (any(grepl("Demog.Index", names(acs)))) {
    stop("bg_acsdata already has Demog.Index columns; remove or replace them before this step")
  }

  blockgroup_demog_index <- calc_blockgroup_demog_index(bgstats = acs)
  blockgroupstats_new <- merge(acs, blockgroup_demog_index, by = "bgfips", all.x = TRUE)

  cols_to_add <- setdiff(names(enviro), c("bgfips", names(blockgroupstats_new)))
  blockgroupstats_new <- merge(
    blockgroupstats_new,
    enviro[, c("bgfips", cols_to_add), with = FALSE],
    by = "bgfips",
    all.x = TRUE
  )

  preferred_first <- c(
    "bgid", "bgfips", "statename", "ST", "countyname", "REGION", "pop",
    names_d[names_d %in% names(blockgroupstats_new)]
  )
  preferred_first <- preferred_first[preferred_first %in% names(blockgroupstats_new)]
  data.table::setcolorder(blockgroupstats_new, preferred_first)
  data.table::setorder(blockgroupstats_new, bgfips)

  if (save_stage) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stage is TRUE")
    }
    ejscreen_pipeline_save(
      blockgroupstats_new,
      "blockgroupstats",
      pipeline_dir,
      stage_format,
      storage = pipeline_storage
    )
  }

  blockgroupstats_new
}

###################################################### #
