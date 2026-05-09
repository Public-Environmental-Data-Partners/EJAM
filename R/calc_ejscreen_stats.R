###################################################### #

#' Calculate bgej, usastats, and statestats from a blockgroupstats-like table
#'
#' @details This is a reusable pipeline step. It can take `bgstats` directly, or
#' read it from a saved pipeline stage via `bgstats_path` or `bgstats_stage` plus
#' `pipeline_dir`. If requested, it writes named pipeline stage files for the
#' ACS, environmental, EJ-index, and combined `usastats`/`statestats` lookup
#' tables plus `bgej`.
#'
#' `pctpre1960` is handled as an environmental indicator for EJ-index
#' calculations and lookup tables. The upstream envirodata stage can create it
#' from the saved ACS stage before this function is called.
#'
#' @param bgstats data.frame or data.table like [blockgroupstats].
#' @param bgstats_path optional path to a saved pipeline stage containing
#'   `bgstats`.
#' @param bgstats_stage optional stage name to read from `pipeline_dir`.
#' @param pipeline_dir folder for reading/writing pipeline stage files.
#' @param save_stages logical, whether to save outputs to `pipeline_dir`.
#' @param stage_format file format for saved stages: `"csv"`, `"rds"`,
#'   `"rda"`, or `"arrow"`.
#' @param acs_vars variables to include in the ACS-only lookup stages. Defaults
#'   to current EJSCREEN/EJAM ACS indicators found in `bgstats`.
#' @param enviro_vars variables to include in the environmental lookup stages.
#'   Defaults to current environmental, health, site, climate, and feature
#'   variables found in `bgstats`.
#' @param ej_indicator_vars environmental indicators to use when calculating EJ
#'   indexes. Defaults to [names_e], but can be replaced for custom indicators.
#' @param ej_indicator_pctile_vars,ej_indicator_state_pctile_vars names for
#'   national/state environmental percentile columns used internally by
#'   [calc_bgej()].
#' @param ej_index_vars,ej_index_supp_vars,ej_index_state_vars,ej_index_supp_state_vars
#'   names for the four EJ-index families created by [calc_bgej()].
#' @param demog_index_var,demog_index_supp_var,demog_index_state_var,demog_index_supp_state_var
#'   demographic index column names used by [calc_bgej()].
#'
#' @return list with interim lookup tables,
#'   `bgej`, `usastats`, and `statestats`.
#'
#' @keywords internal
#'
calc_ejscreen_stats <- function(bgstats = NULL,
                                bgstats_path = NULL,
                                bgstats_stage = NULL,
                                pipeline_dir = NULL,
                                save_stages = FALSE,
                                stage_format = c("csv", "rds", "rda", "arrow"),
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
  stage_format <- match.arg(stage_format)

  bg <- ejscreen_pipeline_input(
    x = bgstats,
    stage = bgstats_stage,
    pipeline_dir = pipeline_dir,
    path = bgstats_path,
    format = stage_format,
    input_name = "bgstats"
  )
  bg <- data.table::as.data.table(data.table::copy(bg))

  check_same_length <- function(...) {
    lens <- vapply(list(...), length, integer(1))
    if (length(unique(lens)) != 1) {
      stop("EJ indicator, percentile, and index name vectors must have the same length")
    }
    invisible(NULL)
  }
  check_same_length(
    ej_indicator_vars,
    ej_indicator_pctile_vars,
    ej_indicator_state_pctile_vars,
    ej_index_vars,
    ej_index_supp_vars,
    ej_index_state_vars,
    ej_index_supp_state_vars
  )

  demog_index_vars <- c(
    demog_index_var,
    demog_index_supp_var,
    demog_index_state_var,
    demog_index_supp_state_var
  )
  needed_cols <- c("bgfips", "ST", "pop", ej_indicator_vars, demog_index_vars)
  missing_cols <- setdiff(needed_cols, names(bg))
  if (length(missing_cols) > 0) {
    stop("bgstats is missing columns needed to calculate stats datasets: ",
         paste(missing_cols, collapse = ", "))
  }

  if (is.null(acs_vars)) {
    acs_vars <- c(
      names_d,
      names_d_demogindexstate,
      names_d_subgroups, names_d_subgroups_alone,
      names_age,
      names_community,
      names_d_extra,
      names_d_language,
      names_d_languageli,
      "pctnobroadband",
      "pctnohealthinsurance",
      "pctdisability"
    )
  }

  if (is.null(enviro_vars)) {
    enviro_vars <- c(
      ej_indicator_vars,
      setdiff(names_health, "pctdisability"),
      names_sitesinarea,
      names_climate,
      names_featuresinarea
    )
  }

  acs_vars <- unique(acs_vars)
  enviro_vars <- unique(c(enviro_vars, ej_indicator_vars))
  acs_vars <- acs_vars[acs_vars %in% names(bg)]
  enviro_vars <- enviro_vars[enviro_vars %in% names(bg)]

  if (length(acs_vars) == 0) {
    stop("bgstats does not have any ACS variables to use for lookup tables")
  }
  missing_env_for_ej <- setdiff(ej_indicator_vars, enviro_vars)
  if (length(missing_env_for_ej) > 0) {
    stop("bgstats is missing environmental indicators needed to calculate EJ indexes: ",
         paste(missing_env_for_ej, collapse = ", "))
  }

  usastats_acs <- pctiles_lookup_create(bg[, ..acs_vars])
  statestats_acs <- pctiles_lookup_create(bg[, ..acs_vars], zone.vector = bg$ST)
  usastats_envirodata <- pctiles_lookup_create(bg[, ..enviro_vars])
  statestats_envirodata <- pctiles_lookup_create(bg[, ..enviro_vars], zone.vector = bg$ST)

  bgej_new <- calc_bgej(
    bgstats = bg,
    vnames_e = ej_indicator_vars,
    vnames_e_pctile = ej_indicator_pctile_vars,
    vnames_e_state_pctile = ej_indicator_state_pctile_vars,
    vnames_ej = ej_index_vars,
    vnames_ej_supp = ej_index_supp_vars,
    vnames_ej_state = ej_index_state_vars,
    vnames_ej_supp_state = ej_index_supp_state_vars,
    vnames_d_demogindex = demog_index_var,
    vnames_d_demogindex_supp = demog_index_supp_var,
    vnames_d_demogindex_state = demog_index_state_var,
    vnames_d_demogindex_supp_state = demog_index_supp_state_var,
    usastats_lookup = usastats_envirodata,
    statestats_lookup = statestats_envirodata
  )

  myvars_us_ej <- intersect(c(ej_index_vars, ej_index_supp_vars), names(bgej_new))
  myvars_state_ej <- intersect(c(ej_index_state_vars, ej_index_supp_state_vars), names(bgej_new))
  if (length(myvars_us_ej) == 0 || length(myvars_state_ej) == 0) {
    stop("bgej does not have the expected EJ index columns needed for usastats/statestats")
  }

  usastats_ej <- pctiles_lookup_create(bgej_new[, ..myvars_us_ej])
  statestats_ej <- pctiles_lookup_create(
    bgej_new[, ..myvars_state_ej],
    zone.vector = bgej_new$ST
  )

  usastats_new <- merge_pctile_lookups(usastats_acs, usastats_envirodata)
  usastats_new <- merge_pctile_lookups(usastats_new, usastats_ej)
  statestats_new <- merge_pctile_lookups(statestats_acs, statestats_envirodata)
  statestats_new <- merge_pctile_lookups(statestats_new, statestats_ej)

  rownames(usastats_new) <- usastats_new$PCTILE
  rownames(statestats_new) <- paste0(statestats_new$REGION, statestats_new$PCTILE)

  out <- list(
    usastats_acs = data.frame(usastats_acs),
    statestats_acs = data.frame(statestats_acs),
    usastats_envirodata = data.frame(usastats_envirodata),
    statestats_envirodata = data.frame(statestats_envirodata),
    bgej = bgej_new,
    usastats_ej = data.frame(usastats_ej),
    statestats_ej = data.frame(statestats_ej),
    usastats = data.frame(usastats_new),
    statestats = data.frame(statestats_new)
  )

  if (save_stages) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stages is TRUE")
    }
    for (stage in names(out)) {
      ejscreen_pipeline_save(out[[stage]], stage, pipeline_dir, stage_format)
    }
  }

  out
}

merge_pctile_lookups <- function(x, y) {
  x <- data.table::as.data.table(x)
  y <- data.table::as.data.table(y)
  if ("OBJECTID" %in% names(y)) {
    y[, OBJECTID := NULL]
  }
  out <- merge(x, y, by = c("REGION", "PCTILE"), all.x = TRUE, sort = FALSE)
  data.table::setcolorder(out, c(
    "OBJECTID", "REGION", "PCTILE",
    setdiff(names(out), c("OBJECTID", "REGION", "PCTILE"))
  ))
  data.frame(out)
}

###################################################### #
