###################################################### #

#' Combine ACS and environmental inputs into blockgroupstats
#'
#' @details This is a reusable pipeline step. It combines an ACS-derived
#' blockgroup table with environmental and other non-ACS indicator columns,
#' calculates demographic indexes, and optionally saves the final
#' `blockgroupstats` stage.
#'
#' The environmental input is expected to include `pctpre1960`. That indicator
#' can be created by an upstream envirodata step from the saved ACS stage, even
#' though EJAM treats it as an environmental indicator for EJ-index calculations.
#'
#' @param blockgroupstats_acs ACS-derived blockgroup table, or NULL if reading
#'   from a saved pipeline stage.
#' @param bg_envirodata environmental/non-ACS blockgroup table, or NULL if
#'   reading from a saved pipeline stage such as `"envirodata"`.
#' @param pipeline_dir folder for reading/writing pipeline stage files.
#' @param blockgroupstats_acs_stage stage name for ACS input.
#' @param bg_envirodata_stage stage name for environmental input.
#' @param save_stage logical, whether to save the final `blockgroupstats` stage.
#' @param stage_format file format for saved/read stages: "rds", "rda", or
#'   "arrow".
#'
#' @return data.table like [blockgroupstats].
#'
#' @keywords internal
#' @export
#'
calc_ejscreen_blockgroupstats <- function(blockgroupstats_acs = NULL,
                                          bg_envirodata = NULL,
                                          pipeline_dir = NULL,
                                          blockgroupstats_acs_stage = "blockgroupstats_acs",
                                          bg_envirodata_stage = "envirodata",
                                          save_stage = FALSE,
                                          stage_format = "rds") {
  acs <- ejscreen_pipeline_input(
    x = blockgroupstats_acs,
    stage = blockgroupstats_acs_stage,
    pipeline_dir = pipeline_dir,
    format = stage_format,
    input_name = "blockgroupstats_acs"
  )
  enviro <- ejscreen_pipeline_input(
    x = bg_envirodata,
    stage = bg_envirodata_stage,
    pipeline_dir = pipeline_dir,
    format = stage_format,
    input_name = "envirodata"
  )

  acs <- data.table::as.data.table(data.table::copy(acs))
  enviro <- data.table::as.data.table(data.table::copy(enviro))

  if (!"bgfips" %in% names(acs)) {
    stop("blockgroupstats_acs must have a bgfips column")
  }
  if (!"bgfips" %in% names(enviro)) {
    stop("envirodata must have a bgfips column")
  }
  if (!"pctpre1960" %in% names(enviro)) {
    stop("envirodata must include pctpre1960, even if that column was created from the ACS stage")
  }
  if (!"lowlifex" %in% names(acs)) {
    if (!"lowlifex" %in% names(enviro)) {
      stop("Need lowlifex in blockgroupstats_acs or envirodata before calculating Demog.Index.Supp")
    }
    acs <- merge(acs, enviro[, .(bgfips, lowlifex)], by = "bgfips", all.x = TRUE)
  }

  if (any(grepl("Demog.Index", names(acs)))) {
    stop("blockgroupstats_acs already has Demog.Index columns; remove or replace them before this step")
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
    ejscreen_pipeline_save(blockgroupstats_new, "blockgroupstats", pipeline_dir, stage_format)
  }

  blockgroupstats_new
}

###################################################### #
