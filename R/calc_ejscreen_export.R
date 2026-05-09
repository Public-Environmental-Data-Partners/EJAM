###################################################### #

#' Combine EJAM blockgroup datasets and rename fields for EJSCREEN
#'
#' @details This helper prepares a tabular export by merging a
#' `blockgroupstats`-like table with a `bgej`-like table and renaming available
#' columns through [map_headernames]. By default it uses `ejscreen_indicator`, which
#' is the column intended to represent the current EJSCREEN app/export numeric
#' field name. It also creates EJSCREEN app map helper fields from exported
#' percentile fields: `B_...` map color-bin columns and `T_...` popup-text
#' columns. The `B_...` bins use the historical EJSCREEN/ejanalysis cutpoints:
#' 0-9th percentile is bin 1, 10-19 is bin 2, ..., 80-89 is bin 9,
#' 90-94 is bin 10, and 95-100 is bin 11. Missing or out-of-range percentiles
#' are assigned bin 0. The `T_...` fields use the current EJSCREEN service text
#' style, such as `"95 %ile"`.
#'
#' @param blockgroupstats blockgroupstats-like data.frame, or NULL if reading
#'   from a saved pipeline stage.
#' @param bgej bgej-like data.frame, or NULL if reading from a saved pipeline
#'   stage.
#' @param usastats_acs,usastats_envirodata ACS and environmental percentile
#'   lookup tables. These are used to add `P_...` fields before creating
#'   EJSCREEN map helper fields.
#' @param pipeline_dir folder for reading saved pipeline stages.
#' @param blockgroupstats_stage,bgej_stage stage names to read when objects are
#'   not supplied.
#' @param usastats_ej,statestats_ej EJ-index percentile lookup tables. These
#'   are used to add `P_D2_...`/`P_D5_...` fields before creating EJSCREEN map
#'   helper fields.
#' @param usastats_acs_stage,usastats_envirodata_stage,usastats_ej_stage,statestats_ej_stage
#'   stage names to read for percentile lookup tables when objects are not
#'   supplied.
#' @param blockgroupstats_path,bgej_path,usastats_acs_path,usastats_envirodata_path,usastats_ej_path,statestats_ej_path
#'   explicit paths to saved inputs.
#' @param stage_format input file format when reading pipeline stages.
#' @param by key column used to merge `blockgroupstats` and `bgej`.
#' @param output_vars optional EJAM `rname` columns to keep before renaming.
#'   Defaults to all available columns after the merge.
#' @param rename_newtype target naming column in [map_headernames]. Defaults to
#'   `"ejscreen_indicator"`.
#' @param mapping_for_names map_headernames-like crosswalk.
#' @param required_output_names optional final EJSCREEN field names that must be
#'   present after renaming.
#' @param include_ej_percentiles logical. If TRUE, add missing national EJ-index
#'   percentile columns from `usastats_ej`.
#' @param include_state_ej_percentiles logical. If TRUE, add missing state
#'   EJ-index percentile columns from `statestats_ej`.
#' @param ej_percentile_vars,ej_percentile_output_vars raw national EJ-index
#'   variables and corresponding percentile variables to add.
#' @param ej_state_percentile_vars,ej_state_percentile_output_vars raw state
#'   EJ-index variables and corresponding percentile variables to add.
#' @param include_ejscreen_map_fields logical. If TRUE, create EJSCREEN app
#'   `B_...` map color-bin columns and `T_...` popup-text columns from exported
#'   `P_...` percentile columns.
#' @param map_field_pctile_names optional final EJSCREEN percentile field names
#'   to use when creating map helper fields. Defaults to all exported `P_...`
#'   fields known to `mapping_for_names`, plus any other exported fields whose
#'   names start with `P_`.
#' @param overwrite_ejscreen_map_fields logical. If TRUE, recalculate existing
#'   `B_...` and `T_...` fields from the matching percentile fields.
#' @param feature_server_fields optional final EJSCREEN FeatureServer field
#'   names. When supplied, missing schema fields are added when possible and the
#'   export is returned in exactly this field order.
#' @param save_path optional file path to save the export.
#' @param save_format optional save format. Guessed from `save_path` when NULL.
#'   Supported values are `"csv"`, `"rds"`, `"rda"`, and `"arrow"`.
#' @param overwrite logical. If FALSE, refuse to overwrite `save_path`.
#'
#' @return data.frame with EJSCREEN-ready column names.
#'
#' @keywords internal
#' @export
#'
calc_ejscreen_export <- function(blockgroupstats = NULL,
                                 bgej = NULL,
                                 usastats_acs = NULL,
                                 usastats_envirodata = NULL,
                                 usastats_ej = NULL,
                                 statestats_ej = NULL,
                                 pipeline_dir = NULL,
                                 blockgroupstats_stage = "blockgroupstats",
                                 bgej_stage = "bgej",
                                 usastats_acs_stage = "usastats_acs",
                                 usastats_envirodata_stage = "usastats_envirodata",
                                 usastats_ej_stage = "usastats_ej",
                                 statestats_ej_stage = "statestats_ej",
                                 blockgroupstats_path = NULL,
                                 bgej_path = NULL,
                                 usastats_acs_path = NULL,
                                 usastats_envirodata_path = NULL,
                                 usastats_ej_path = NULL,
                                 statestats_ej_path = NULL,
                                 stage_format = c("csv", "rds", "rda", "arrow"),
                                 by = "bgfips",
                                 output_vars = NULL,
                                 rename_newtype = "ejscreen_indicator",
                                 mapping_for_names = map_headernames,
                                 required_output_names = NULL,
                                 include_ej_percentiles = TRUE,
                                 include_state_ej_percentiles = TRUE,
                                 ej_percentile_vars = c(names_ej, names_ej_supp),
                                 ej_percentile_output_vars = c(names_ej_pctile, names_ej_supp_pctile),
                                 ej_state_percentile_vars = c(names_ej_state, names_ej_supp_state),
                                 ej_state_percentile_output_vars = c(names_ej_state_pctile, names_ej_supp_state_pctile),
                                 include_ejscreen_map_fields = TRUE,
                                 map_field_pctile_names = NULL,
                                 overwrite_ejscreen_map_fields = TRUE,
                                 feature_server_fields = NULL,
                                 save_path = NULL,
                                 save_format = NULL,
                                 overwrite = TRUE) {

  stage_format <- match.arg(stage_format)

  bg <- ejscreen_pipeline_input(
    x = blockgroupstats,
    stage = blockgroupstats_stage,
    pipeline_dir = pipeline_dir,
    path = blockgroupstats_path,
    format = stage_format,
    input_name = "blockgroupstats"
  )
  bg <- data.table::as.data.table(data.table::copy(bg))

  have_ej_in_bg <- exists("names_ej") &&
    length(intersect(c(names_ej, names_ej_supp, names_ej_state, names_ej_supp_state), names(bg))) > 0
  if (!is.null(bgej) || !is.null(bgej_path) || !is.null(pipeline_dir) || !have_ej_in_bg) {
    ej <- ejscreen_pipeline_input(
      x = bgej,
      stage = bgej_stage,
      pipeline_dir = pipeline_dir,
      path = bgej_path,
      format = stage_format,
      input_name = "bgej"
    )
    ej <- data.table::as.data.table(data.table::copy(ej))
    if (!by %in% names(bg)) {
      stop("blockgroupstats is missing merge key: ", by)
    }
    if (!by %in% names(ej)) {
      stop("bgej is missing merge key: ", by)
    }
    ej_cols <- setdiff(names(ej), c(by, setdiff(intersect(names(ej), names(bg)), by)))
    bg <- merge(bg, ej[, c(by, ej_cols), with = FALSE], by = by, all.x = TRUE, sort = FALSE)
  }

  mapping_for_names <- augment_map_headernames_ejscreen_names(mapping_for_names)

  load_optional_lookup <- function(x, stage, path, input_name) {
    if (!is.null(x)) {
      return(data.table::as.data.table(data.table::copy(x)))
    }
    if (!is.null(path)) {
      return(data.table::as.data.table(data.table::copy(ejscreen_pipeline_input(
        stage = stage,
        path = path,
        format = stage_format,
        input_name = input_name
      ))))
    }
    if (!is.null(pipeline_dir) && ejscreen_pipeline_stage_exists(stage, pipeline_dir, stage_format)) {
      return(data.table::as.data.table(data.table::copy(ejscreen_pipeline_input(
        stage = stage,
        pipeline_dir = pipeline_dir,
        format = stage_format,
        input_name = input_name
      ))))
    }
    NULL
  }

  add_ej_pctiles_from_lookup <- function(raw_vars,
                                         pctile_vars,
                                         lookup,
                                         lookup_name,
                                         zones = "USA") {
    if (length(raw_vars) != length(pctile_vars)) {
      stop(lookup_name, " raw and percentile variable vectors must have the same length")
    }
    needed <- raw_vars %in% names(bg) & !pctile_vars %in% names(bg)
    if (!any(needed)) {
      return(invisible(NULL))
    }
    if (is.null(lookup)) {
      warning(
        "Cannot add missing EJ percentile export columns because ",
        lookup_name,
        " was not supplied or found as a saved pipeline stage",
        call. = FALSE
      )
      return(invisible(NULL))
    }
    lookup <- data.frame(lookup, check.names = FALSE)
    missing_lookup <- raw_vars[needed & !raw_vars %in% names(lookup)]
    if (length(missing_lookup) > 0) {
      warning(
        lookup_name,
        " is missing EJ index columns needed for export percentiles: ",
        paste(missing_lookup, collapse = ", "),
        call. = FALSE
      )
    }
    todo <- needed & raw_vars %in% names(lookup)
    if (!any(todo)) {
      return(invisible(NULL))
    }
    for (i in which(todo)) {
      bg[[pctile_vars[[i]]]] <<- pctile_from_raw_lookup(
        myvector = bg[[raw_vars[[i]]]],
        varname.in.lookup.table = raw_vars[[i]],
        lookup = lookup,
        zone = zones,
        quiet = TRUE
      )
    }
    invisible(NULL)
  }

  add_mapped_pctiles_from_lookup <- function(lookup,
                                             lookup_name,
                                             zones = "USA",
                                             pctile_fields = NULL) {
    if (is.null(lookup)) {
      return(invisible(NULL))
    }
    lookup <- data.frame(lookup, check.names = FALSE)
    if (!all(c("REGION", "PCTILE") %in% names(lookup))) {
      warning(lookup_name, " must have REGION and PCTILE columns to add mapped percentile fields", call. = FALSE)
      return(invisible(NULL))
    }

    mh <- mapping_for_names
    if (is.null(pctile_fields)) {
      pctile_fields <- unique(mh$ejscreen_pctile[!is_blank_string(mh$ejscreen_pctile)])
    }
    pctile_fields <- pctile_fields[grepl("^P_", pctile_fields)]

    for (pctile_field in unique(pctile_fields)) {
      pctile_rows <- mh[mh$ejscreen_indicator == pctile_field, , drop = FALSE]
      pctile_rname <- pctile_rows$rname[!is_blank_string(pctile_rows$rname)][1]
      if (is.na(pctile_rname) || is_blank_string(pctile_rname) || pctile_rname %in% names(bg)) {
        next
      }

      raw_rows <- mh[
        mh$ejscreen_pctile == pctile_field &
          mh$ejscreen_indicator != pctile_field &
          mh$rname %in% names(bg) &
          mh$rname %in% names(lookup),
        ,
        drop = FALSE
      ]
      if (NROW(raw_rows) == 0) {
        next
      }

      raw_var <- raw_rows$rname[1]
      bg[[pctile_rname]] <<- pctile_from_raw_lookup(
        myvector = bg[[raw_var]],
        varname.in.lookup.table = raw_var,
        lookup = lookup,
        zone = zones,
        quiet = TRUE
      )
    }
    invisible(NULL)
  }

  if (!is.null(feature_server_fields)) {
    feature_server_fields <- unique(as.character(feature_server_fields))
    feature_server_fields <- feature_server_fields[!is_blank_string(feature_server_fields)]
  }
  feature_server_pctile_fields <- feature_server_fields[grepl("^P_", feature_server_fields)]

  us_acs_lookup <- load_optional_lookup(
    usastats_acs,
    stage = usastats_acs_stage,
    path = usastats_acs_path,
    input_name = "usastats_acs"
  )
  add_mapped_pctiles_from_lookup(
    lookup = us_acs_lookup,
    lookup_name = "usastats_acs",
    zones = "USA",
    pctile_fields = feature_server_pctile_fields
  )

  us_env_lookup <- load_optional_lookup(
    usastats_envirodata,
    stage = usastats_envirodata_stage,
    path = usastats_envirodata_path,
    input_name = "usastats_envirodata"
  )
  add_mapped_pctiles_from_lookup(
    lookup = us_env_lookup,
    lookup_name = "usastats_envirodata",
    zones = "USA",
    pctile_fields = feature_server_pctile_fields
  )

  if (isTRUE(include_ej_percentiles)) {
    us_ej_lookup <- load_optional_lookup(
      usastats_ej,
      stage = usastats_ej_stage,
      path = usastats_ej_path,
      input_name = "usastats_ej"
    )
    add_ej_pctiles_from_lookup(
      raw_vars = ej_percentile_vars,
      pctile_vars = ej_percentile_output_vars,
      lookup = us_ej_lookup,
      lookup_name = "usastats_ej",
      zones = "USA"
    )
  }

  if (isTRUE(include_state_ej_percentiles)) {
    needs_state_pctiles <- any(ej_state_percentile_vars %in% names(bg) &
                                 !ej_state_percentile_output_vars %in% names(bg))
    if (!needs_state_pctiles) {
      invisible(NULL)
    } else if (!"ST" %in% names(bg)) {
      warning("Cannot add state EJ percentile export columns because the combined table has no ST column", call. = FALSE)
    } else {
      state_ej_lookup <- load_optional_lookup(
        statestats_ej,
        stage = statestats_ej_stage,
        path = statestats_ej_path,
        input_name = "statestats_ej"
      )
      add_ej_pctiles_from_lookup(
        raw_vars = ej_state_percentile_vars,
        pctile_vars = ej_state_percentile_output_vars,
        lookup = state_ej_lookup,
        lookup_name = "statestats_ej",
        zones = bg$ST
      )
    }
  }

  is_non_output_name <- function(x) {
    x <- as.character(x)
    is_blank_string(x) |
      grepl("use for pctile|do not report|don.?t report", x, ignore.case = TRUE)
  }

  if (is.null(output_vars)) {
    target_names <- mapping_for_names[[rename_newtype]][match(names(bg), mapping_for_names$rname)]
    output_vars <- names(bg)[!is.na(target_names) & !is_non_output_name(target_names)]
  }
  missing_output_vars <- setdiff(output_vars, names(bg))
  if (length(missing_output_vars) > 0) {
    stop("Output variables are missing from the combined table: ",
         paste(missing_output_vars, collapse = ", "))
  }
  out <- data.frame(bg[, ..output_vars])

  new_names <- fixcolnames(
    names(out),
    oldtype = "r",
    newtype = rename_newtype,
    mapping_for_names = mapping_for_names
  )
  if (any(duplicated(new_names))) {
    dupes <- unique(new_names[duplicated(new_names)])
    stop("Renaming would create duplicate output column names: ",
         paste(dupes, collapse = ", "))
  }
  non_output_vars <- output_vars[is_non_output_name(new_names)]
  if (length(non_output_vars) > 0) {
    stop("Output variables do not have usable EJSCREEN output names: ",
         paste(non_output_vars, collapse = ", "))
  }
  names(out) <- new_names

  if (isTRUE(include_ejscreen_map_fields)) {
    out <- calc_ejscreen_map_fields_added(
      out,
      mapping_for_names = mapping_for_names,
      pctile_names = map_field_pctile_names,
      overwrite = overwrite_ejscreen_map_fields
    )
  }

  if (!is.null(feature_server_fields)) {
    out <- calc_ejscreen_feature_server_fields_added(out, feature_server_fields = feature_server_fields)
  }

  if (!is.null(required_output_names)) {
    missing_required <- setdiff(required_output_names, names(out))
    if (length(missing_required) > 0) {
      stop("Export is missing required EJSCREEN output fields: ",
           paste(missing_required, collapse = ", "))
    }
  }

  ##################################### #
  # helper for calc_ejscreen_export()

  ejscreen_export_save <- function(x, save_path, save_format = NULL, overwrite = TRUE) {

    if (file.exists(save_path) && !overwrite) {
      stop("Refusing to overwrite existing file: ", save_path)
    }
    if (is.null(save_format)) {
      save_format <- tolower(sub("^.*\\.([^.]+)$", "\\1", save_path))
    }
    dir.create(dirname(save_path), recursive = TRUE, showWarnings = FALSE)

    if (save_format == "csv") {
      data.table::fwrite(x, save_path)
    } else if (save_format == "rds") {
      saveRDS(x, save_path)
    } else if (save_format == "rda") {
      ejscreen_export <- x
      save(ejscreen_export, file = save_path)
    } else if (save_format == "arrow") {
      if (!requireNamespace("arrow", quietly = TRUE)) {
        stop("The arrow package is required to save Arrow export files")
      }
      arrow::write_ipc_file(x, sink = save_path)
    } else {
      stop("Unsupported export save format: ", save_format)
    }
    invisible(normalizePath(save_path, mustWork = FALSE))
  }
  ##################################### #

  if (!is.null(save_path)) {
    ejscreen_export_save(out, save_path, save_format = save_format, overwrite = overwrite)
  }
  out
}
###################################################### #
# . ####

ejscreen_feature_server_fields <- function() {
  c(
    "OBJECTID", "ID", "STATE_NAME", "ST_ABBREV", "CNTY_NAME", "REGION",
    "ACSTOTPOP", "ACSIPOVBAS", "ACSEDUCBAS", "ACSTOTHH", "ACSTOTHU",
    "ACSUNEMPBAS", "ACSDISABBAS", "DEMOGIDX_2", "DEMOGIDX_5",
    "PEOPCOLOR", "PEOPCOLORPCT", "LOWINCOME", "LOWINCPCT", "UNEMPLOYED",
    "UNEMPPCT", "DISABILITY", "DISABILITYPCT", "LINGISO", "LINGISOPCT",
    "LESSHS", "LESSHSPCT", "UNDER5", "UNDER5PCT", "OVER64", "OVER64PCT",
    "LIFEEXPPCT", "PM25", "OZONE", "DSLPM", "RSEI_AIR", "PTRAF",
    "PRE1960", "PRE1960PCT", "PNPL", "PRMP", "PTSDF", "UST", "PWDIS",
    "NO2", "DWATER", "D2_PM25", "D5_PM25", "D2_OZONE", "D5_OZONE",
    "D2_DSLPM", "D5_DSLPM", "D2_RSEI_AIR", "D5_RSEI_AIR", "D2_PTRAF",
    "D5_PTRAF", "D2_LDPNT", "D5_LDPNT", "D2_PNPL", "D5_PNPL",
    "D2_PRMP", "D5_PRMP", "D2_PTSDF", "D5_PTSDF", "D2_UST", "D5_UST",
    "D2_PWDIS", "D5_PWDIS", "D2_NO2", "D5_NO2", "D2_DWATER",
    "D5_DWATER", "P_DEMOGIDX_2", "P_DEMOGIDX_5", "P_PEOPCOLORPCT",
    "P_LOWINCPCT", "P_UNEMPPCT", "P_DISABILITYPCT", "P_LINGISOPCT",
    "P_LESSHSPCT", "P_UNDER5PCT", "P_OVER64PCT", "P_LIFEEXPPCT",
    "P_PM25", "P_OZONE", "P_DSLPM", "P_RSEI_AIR", "P_PTRAF", "P_LDPNT",
    "P_PNPL", "P_PRMP", "P_PTSDF", "P_UST", "P_PWDIS", "P_NO2",
    "P_DWATER", "P_D2_PM25", "P_D5_PM25", "P_D2_OZONE", "P_D5_OZONE",
    "P_D2_DSLPM", "P_D5_DSLPM", "P_D2_RSEI_AIR", "P_D5_RSEI_AIR",
    "P_D2_PTRAF", "P_D5_PTRAF", "P_D2_LDPNT", "P_D5_LDPNT", "P_D2_PNPL",
    "P_D5_PNPL", "P_D2_PRMP", "P_D5_PRMP", "P_D2_PTSDF", "P_D5_PTSDF",
    "P_D2_UST", "P_D5_UST", "P_D2_PWDIS", "P_D5_PWDIS", "P_D2_NO2",
    "P_D5_NO2", "P_D2_DWATER", "P_D5_DWATER", "B_DEMOGIDX_2",
    "B_DEMOGIDX_5", "B_PEOPCOLORPCT", "B_LOWINCPCT", "B_UNEMPPCT",
    "B_DISABILITYPCT", "B_LINGISOPCT", "B_LESSHSPCT", "B_UNDER5PCT",
    "B_OVER64PCT", "B_LIFEEXPPCT", "B_PM25", "B_OZONE", "B_DSLPM",
    "B_RSEI_AIR", "B_PTRAF", "B_LDPNT", "B_PNPL", "B_PRMP", "B_PTSDF",
    "B_UST", "B_PWDIS", "B_NO2", "B_DWATER", "B_D2_PM25", "B_D5_PM25",
    "B_D2_OZONE", "B_D5_OZONE", "B_D2_DSLPM", "B_D5_DSLPM",
    "B_D2_RSEI_AIR", "B_D5_RSEI_AIR", "B_D2_PTRAF", "B_D5_PTRAF",
    "B_D2_LDPNT", "B_D5_LDPNT", "B_D2_PNPL", "B_D5_PNPL", "B_D2_PRMP",
    "B_D5_PRMP", "B_D2_PTSDF", "B_D5_PTSDF", "B_D2_UST", "B_D5_UST",
    "B_D2_PWDIS", "B_D5_PWDIS", "B_D2_NO2", "B_D5_NO2", "B_D2_DWATER",
    "B_D5_DWATER", "T_DEMOGIDX_2", "T_DEMOGIDX_5", "T_PEOPCOLORPCT",
    "T_LOWINCPCT", "T_UNEMPPCT", "T_DISABILITYPCT", "T_LINGISOPCT",
    "T_LESSHSPCT", "T_UNDER5PCT", "T_OVER64PCT", "T_LIFEEXPPCT",
    "T_PM25", "T_OZONE", "T_DSLPM", "T_RSEI_AIR", "T_PTRAF", "T_LDPNT",
    "T_PNPL", "T_PRMP", "T_PTSDF", "T_UST", "T_PWDIS", "T_NO2",
    "T_DWATER", "T_D2_PM25", "T_D5_PM25", "T_D2_OZONE", "T_D5_OZONE",
    "T_D2_DSLPM", "T_D5_DSLPM", "T_D2_RSEI_AIR", "T_D5_RSEI_AIR",
    "T_D2_PTRAF", "T_D5_PTRAF", "T_D2_LDPNT", "T_D5_LDPNT", "T_D2_PNPL",
    "T_D5_PNPL", "T_D2_PRMP", "T_D5_PRMP", "T_D2_PTSDF", "T_D5_PTSDF",
    "T_D2_UST", "T_D5_UST", "T_D2_PWDIS", "T_D5_PWDIS", "T_D2_NO2",
    "T_D5_NO2", "T_D2_DWATER", "T_D5_DWATER", "AREALAND", "AREAWATER",
    "NPL_CNT", "TSDF_CNT", "EXCEED_COUNT_80", "EXCEED_COUNT_80_SUP",
    "DEMOGIDX_2ST", "DEMOGIDX_5ST", "EXCEED_COUNT_90",
    "EXCEED_COUNT_90_SUP", "SYMBOLOGY_EXCEED_COUNT_80", "Shape__Area",
    "Shape__Length"
  )
}

calc_ejscreen_feature_server_fields_added <- function(x, feature_server_fields = ejscreen_feature_server_fields()) {
  out <- as.data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
  n <- NROW(out)

  if ("OBJECTID" %in% feature_server_fields && !"OBJECTID" %in% names(out)) {
    out$OBJECTID <- seq_len(n)
  }
  for (field in intersect(c("Shape__Area", "Shape__Length"), feature_server_fields)) {
    if (!field %in% names(out)) {
      out[[field]] <- rep(NA_real_, n)
    }
  }

  add_exceed_count <- function(output_field, pattern, threshold) {
    if (!output_field %in% feature_server_fields || output_field %in% names(out)) {
      return(invisible(NULL))
    }
    pctile_fields <- grep(pattern, names(out), value = TRUE)
    if (length(pctile_fields) == 0) {
      out[[output_field]] <<- rep(NA_integer_, n)
    } else {
      vals <- as.data.frame(lapply(out[pctile_fields], function(z) suppressWarnings(as.numeric(z))))
      out[[output_field]] <<- as.integer(rowSums(!is.na(vals) & vals >= threshold))
    }
    invisible(NULL)
  }

  add_exceed_count("EXCEED_COUNT_80", "^P_D2_", 80)
  add_exceed_count("EXCEED_COUNT_80_SUP", "^P_D5_", 80)
  add_exceed_count("EXCEED_COUNT_90", "^P_D2_", 90)
  add_exceed_count("EXCEED_COUNT_90_SUP", "^P_D5_", 90)

  if ("SYMBOLOGY_EXCEED_COUNT_80" %in% feature_server_fields &&
      !"SYMBOLOGY_EXCEED_COUNT_80" %in% names(out)) {
    count80 <- suppressWarnings(as.numeric(out$EXCEED_COUNT_80))
    out$SYMBOLOGY_EXCEED_COUNT_80 <- ifelse(
      !is.na(count80) & count80 > 0,
      "1-13 EJ Indexes over 80th %tile",
      "0 EJ Indexes over 80th %tile"
    )
  }

  missing_fields <- setdiff(feature_server_fields, names(out))
  for (field in missing_fields) {
    out[[field]] <- NA
  }
  out[, feature_server_fields, drop = FALSE]
}

###################################################### #
# . ####

#' Report which EJSCREEN export fields are expected, missing, or extra
#'
#' @details This helper compares a proposed EJSCREEN export table with the
#' names implied by [map_headernames] or another mapping table. It is used by
#' the annual data-update pipeline to write `ejscreen_export_schema_report.csv`.
#'
#' @param ejscreen_export optional data.frame containing an EJSCREEN export.
#' @param export_path optional path to a saved export CSV.
#' @param mapping_for_names map_headernames-like crosswalk.
#' @param rename_newtype naming column in `mapping_for_names` to check.
#' @param expected_output_names optional extra expected output field names.
#' @param include_map_helper_fields logical. If TRUE, include expected `B_...`
#'   and `T_...` helper fields associated with percentile fields.
#'
#' @return data.frame describing present/missing/extra export fields.
#'
#' @keywords internal
#'
calc_ejscreen_export_schema_report <- function(ejscreen_export = NULL,
                                               export_path = NULL,
                                               mapping_for_names = map_headernames,
                                               rename_newtype = "ejscreen_indicator",
                                               expected_output_names = NULL,
                                               include_map_helper_fields = TRUE) {

  if (is.null(ejscreen_export) && is.null(export_path)) {
    stop("ejscreen_export or export_path must be supplied")
  }
  if (!is.null(ejscreen_export)) {
    export_names <- names(ejscreen_export)
  } else {
    if (!file.exists(export_path)) {
      stop("Export file not found: ", export_path)
    }
    export_names <- names(data.table::fread(export_path, nrows = 0))
  }

  mh <- augment_map_headernames_ejscreen_names(mapping_for_names)
  if (!rename_newtype %in% names(mh)) {
    stop("rename_newtype is not a column in mapping_for_names: ", rename_newtype)
  }

  is_non_output_name <- function(x) {
    x <- as.character(x)
    is_blank_string(x) |
      grepl("use for pctile|do not report|don.?t report", x, ignore.case = TRUE)
  }

  mapped_name <- mh[[rename_newtype]]
  expected_from_mapping <- unique(mapped_name[!is_non_output_name(mapped_name)])
  if (isTRUE(include_map_helper_fields)) {
    pctile_fields <- unique(c(
      expected_from_mapping[grepl("^P_", expected_from_mapping)],
      export_names[grepl("^P_", export_names)]
    ))
    helper_rows <- mh[mh$ejscreen_pctile %in% pctile_fields, , drop = FALSE]
    helper_fields <- unique(c(helper_rows$ejscreen_bin, helper_rows$ejscreen_text))
    expected_from_mapping <- unique(c(
      expected_from_mapping,
      helper_fields[!is_non_output_name(helper_fields)]
    ))
  }
  feature_server_fields <- ejscreen_feature_server_fields()
  if (is.null(expected_output_names) && all(feature_server_fields %in% export_names)) {
    expected_names <- feature_server_fields
  } else if (!is.null(expected_output_names) && identical(as.character(expected_output_names), feature_server_fields)) {
    expected_names <- feature_server_fields
  } else {
    expected_names <- unique(c(expected_from_mapping, expected_output_names))
  }
  expected_names <- expected_names[!is_non_output_name(expected_names)]

  report_names <- unique(c(expected_names, export_names))
  export_position <- match(report_names, export_names)

  collapse_unique <- function(x) {
    x <- unique(as.character(x[!is_blank_string(x)]))
    if (length(x) == 0) {
      return("")
    }
    paste(x, collapse = "; ")
  }

  mapped_rnames <- vapply(report_names, function(name) {
    collapse_unique(mh$rname[mapped_name == name])
  }, character(1))
  mapped_longnames <- if ("longname" %in% names(mh)) {
    vapply(report_names, function(name) {
      collapse_unique(mh$longname[mapped_name == name])
    }, character(1))
  } else {
    rep("", length(report_names))
  }

  field_type <- ifelse(report_names == "ID", "id",
                       ifelse(grepl("^P_", report_names), "percentile",
                              ifelse(grepl("^S_P_", report_names), "state_percentile",
                                     ifelse(grepl("^B_", report_names), "map_bin",
                                            ifelse(grepl("^T_", report_names), "map_text",
                                                   ifelse(grepl("^(D2_|D5_|S_D2_|S_D5_)", report_names),
                                                          "ej_index", "field"))))))

  out <- data.frame(
    ejscreen_name = report_names,
    present_in_export = report_names %in% export_names,
    expected_from_mapping = report_names %in% expected_names,
    export_position = export_position,
    field_type = field_type,
    rname = mapped_rnames,
    longname = mapped_longnames,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  out$status <- ifelse(
    out$present_in_export & out$expected_from_mapping,
    "present_expected",
    ifelse(out$present_in_export, "present_extra", "missing_expected")
  )
  out[order(is.na(out$export_position), out$export_position, out$ejscreen_name), ]
}
###################################################### #
# . ####

###################################################### #

#' Calculate EJSCREEN map color bins
#'
#' @details EJSCREEN shows color-coded maps based on percentile bins.
#'  This helper calculates those bin numbers so the can be stored in EJSCREEN's dataset of blockgroups.
#'  Percentiles are expected to be represented on a 0-100 scale. Bins match the
#' historical EJSCREEN thresholds: 0-9th percentile is bin 1,
#' 10-19 is bin 2, ..., 80-89 is bin 9, 90-94 is bin 10, and 95-100 is bin 11.
#' Missing or out-of-range percentiles are assigned bin 0.
#'
#' @param x numeric vector of percentiles on a 0-100 scale.
#'
#' @return integer vector of bin numbers from 0 to 11.
#'
#' @keywords internal
#'
calc_ejscreen_map_bin <- function(x) {

  x_num <- suppressWarnings(as.numeric(x))
  bins <- rep(0L, length(x_num))
  valid <- !is.na(x_num) & x_num >= 0 & x_num <= 100
  bins[valid] <- findInterval(x_num[valid], c(10, 20, 30, 40, 50, 60, 70, 80, 90, 95)) + 1L
  bins
}
###################################################### #

#' Calculate EJSCREEN percentile popup text
#'
#' @details Percentiles are expected on EJSCREEN's 0-100 scale. The returned
#' strings follow the current EJSCREEN app service style, such as `"95 %ile"`.
#' Missing or out-of-range percentiles return `NA_character_`.
#'
#' @param x numeric vector of percentiles on a 0-100 scale.
#'
#' @return character vector.
#'
#' @keywords internal
#'
calc_ejscreen_map_pctile_text <- function(x) {

  x_num <- suppressWarnings(as.numeric(x))
  txt <- rep(NA_character_, length(x_num))
  valid <- !is.na(x_num) & x_num >= 0 & x_num <= 100
  txt[valid] <- paste0(floor(x_num[valid]), " %ile")
  txt
}
###################################################### #

#' Add EJSCREEN map bin and pctile text fields
#'
#' @details EJSCREEN app datasets include map helper fields that EJAM does not
#' otherwise need: `B_...` small-integer color-bin fields and `T_...` popup-text
#' fields. This helper creates those fields from exported `P_...` percentile
#' columns.
#'
#' The bin logic is adapted from the obsolete `ejanalysis::assign.map.bins()`
#' helper, but implemented directly in EJAM. Percentiles must be on EJSCREEN's
#' 0-100 scale, not 0-1. Current EJSCREEN services use popup text like
#' `"95 %ile"`, so that is the text format used here.
#'
#' @param x data.frame with EJSCREEN-named percentile fields such as
#'   `P_D2_NO2`.
#' @param mapping_for_names map_headernames-like crosswalk.
#' @param pctile_names optional vector of EJSCREEN percentile field names to
#'   use. Defaults to all exported `P_...` fields known to `mapping_for_names`,
#'   plus any other exported fields whose names start with `P_`.
#' @param overwrite logical. If TRUE, recalculate existing `B_...` and `T_...`
#'   fields from the matching percentile fields.
#'
#' @return data.frame with added or updated `B_...` and `T_...` fields.
#'
#' @keywords internal
#'
calc_ejscreen_map_fields_added <- function(x,
                                           mapping_for_names = map_headernames,
                                           pctile_names = NULL,
                                           overwrite = TRUE) {

  out <- as.data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
  mh <- augment_map_headernames_ejscreen_names(mapping_for_names)

  if (is.null(pctile_names)) {
    pctile_names <- unique(c(
      mh$ejscreen_pctile[!is_blank_string(mh$ejscreen_pctile)],
      grep("^P_", names(out), value = TRUE)
    ))
  }
  pctile_names <- intersect(pctile_names, names(out))
  ############################## #
  first_nonblank <- function(x) {
    x <- as.character(x)
    x <- x[!is_blank_string(x)]
    if (length(x) == 0) {
      return("")
    }
    x[1]
  }
  ############################## #

  for (pctile_name in pctile_names) {
    map_info <- mh[mh$ejscreen_pctile == pctile_name, , drop = FALSE]
    bin_name <- first_nonblank(map_info$ejscreen_bin)
    text_name <- first_nonblank(map_info$ejscreen_text)
    if (is_blank_string(bin_name) || is_blank_string(text_name)) {
      app_code <- sub("^P_", "", pctile_name)
      if (is_blank_string(bin_name)) {
        bin_name <- paste0("B_", app_code)
      }
      if (is_blank_string(text_name)) {
        text_name <- paste0("T_", app_code)
      }
    }

    if (!bin_name %in% names(out) || isTRUE(overwrite)) {
      out[[bin_name]] <- calc_ejscreen_map_bin(out[[pctile_name]])
    }
    if (!text_name %in% names(out) || isTRUE(overwrite)) {
      out[[text_name]] <- calc_ejscreen_map_pctile_text(out[[pctile_name]])
    }
  }

  out
}
