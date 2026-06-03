###################################################### #
# . ####

#' Create EJScreen-style percentile lookup exports
#'
#' @details This helper converts EJAM percentile lookup tables such as
#' [usastats] and [statestats] to the EJScreen CSV shape used by files such as
#' `EJScreen_2024_BG_National_Lookup.csv` and
#' `EJScreen_2024_BG_State_Lookup.csv`. The package lookup tables keep EJAM
#' `rname` columns and include `0:100` percentile rows plus `mean`. This export
#' writes `PCTILE` then `REGION`, renames indicator columns to EJScreen field
#' names, and can append a `std` row after the `mean` row for each region.
#'
#' The `std` row is calculated from `values`, not from the percentile lookup
#' table itself. For the annual pipeline, `values` is the matching
#' `blockgroupstats` plus `bgej` raw-score table.
#'
#' @param lookup `usastats`- or `statestats`-like lookup table.
#' @param values optional raw-score data used to calculate `std` rows.
#' @param scope `"national"` for a USA lookup or `"state"` for state lookups.
#' @param output_fields optional EJScreen output fields. Defaults to the fields
#'   used by EPA's archived national/state lookup CSVs.
#' @param mapping_for_names map_headernames-like crosswalk.
#' @param rename_newtype target EJScreen naming column in `mapping_for_names`.
#' @param include_std logical. If TRUE, append or replace one `std` row per
#'   region. When `values` is NULL, `std` rows are included with missing values.
#' @param save_path optional path where the export should be written.
#' @param save_format optional file format. Guessed from `save_path` when NULL.
#' @param pipeline_storage storage backend: `"auto"`, `"local"`, or `"s3"`.
#' @param overwrite logical. If FALSE, refuse to overwrite `save_path`.
#'
#' @return data.frame with EJScreen lookup CSV columns.
#'
#' @keywords internal
#'
calc_ejscreen_pctile_lookup_export <- function(lookup,
                                               values = NULL,
                                               scope = c("national", "state"),
                                               output_fields = ejscreen_pctile_lookup_fields(),
                                               mapping_for_names = map_headernames,
                                               rename_newtype = "ejscreen_indicator",
                                               include_std = TRUE,
                                               save_path = NULL,
                                               save_format = NULL,
                                               pipeline_storage = c("auto", "local", "s3"),
                                               overwrite = TRUE) {
  scope <- match.arg(scope)
  pipeline_storage <- match.arg(pipeline_storage)

  if (missing(lookup) || is.null(lookup)) {
    stop("lookup must be provided")
  }
  lookup_dt <- data.table::as.data.table(data.table::copy(lookup))
  if (!all(c("REGION", "PCTILE") %in% names(lookup_dt))) {
    stop("lookup must include REGION and PCTILE columns")
  }

  data.table::set(lookup_dt, j = "REGION", value = as.character(lookup_dt$REGION))
  data.table::set(lookup_dt, j = "PCTILE", value = as.character(lookup_dt$PCTILE))
  if ("OBJECTID" %in% names(lookup_dt)) {
    lookup_dt[, OBJECTID := NULL]
  }
  if (identical(scope, "state")) {
    lookup_dt <- ejscreen_statepct_values_into_epa_fields(lookup_dt)
  }

  values_dt <- NULL
  if (!is.null(values)) {
    values_dt <- data.table::as.data.table(data.table::copy(values))
    if (identical(scope, "state")) {
      values_dt <- ejscreen_statepct_values_into_epa_fields(values_dt)
      if ("ST" %in% names(values_dt)) {
        data.table::set(values_dt, j = "REGION", value = as.character(values_dt$ST))
      } else if ("REGION" %in% names(values_dt)) {
        data.table::set(values_dt, j = "REGION", value = as.character(values_dt$REGION))
      } else {
        stop("state lookup std rows require values with ST or REGION")
      }
    }
  }

  mapping <- ejscreen_pctile_lookup_mapping(
    lookup = lookup_dt,
    values = values_dt,
    output_fields = output_fields,
    mapping_for_names = mapping_for_names,
    rename_newtype = rename_newtype
  )

  out <- data.table::data.table(
    PCTILE = lookup_dt$PCTILE,
    REGION = lookup_dt$REGION
  )
  for (i in seq_len(NROW(mapping))) {
    field <- mapping$output_field[[i]]
    source <- mapping$source_name[[i]]
    if (!is.na(source) && source %in% names(lookup_dt)) {
      out[[field]] <- lookup_dt[[source]]
    } else if (field %in% names(lookup_dt)) {
      out[[field]] <- lookup_dt[[field]]
    } else {
      out[[field]] <- NA_real_
    }
  }

  if (isTRUE(include_std)) {
    out <- ejscreen_pctile_lookup_std_rows_added(
      out = out,
      values = values_dt,
      mapping = mapping,
      scope = scope
    )
  }

  out <- data.frame(out, check.names = FALSE, stringsAsFactors = FALSE)

  if (!is.null(save_path)) {
    ejscreen_pctile_lookup_export_save(
      out,
      path = save_path,
      format = save_format,
      overwrite = overwrite,
      storage = pipeline_storage
    )
  }

  out
}

###################################################### #
# . ####

ejscreen_pctile_lookup_fields <- function() {
  c(
    "DEMOGIDX_2", "DEMOGIDX_5", "PEOPCOLORPCT", "LOWINCPCT",
    "UNEMPPCT", "DISABILITYPCT", "LINGISOPCT", "LESSHSPCT",
    "UNDER5PCT", "OVER64PCT", "LIFEEXPPCT",
    "PM25", "OZONE", "DSLPM", "RSEI_AIR", "PTRAF", "PRE1960PCT",
    "PNPL", "PRMP", "PTSDF", "UST", "PWDIS", "DWATER", "NO2",
    "D2_PM25", "D2_OZONE", "D2_DSLPM", "D2_RSEI_AIR", "D2_PTRAF",
    "D2_LDPNT", "D2_PNPL", "D2_PRMP", "D2_PTSDF", "D2_UST",
    "D2_PWDIS", "D2_DWATER", "D2_NO2",
    "D5_PM25", "D5_OZONE", "D5_DSLPM", "D5_RSEI_AIR", "D5_PTRAF",
    "D5_LDPNT", "D5_PNPL", "D5_PRMP", "D5_PTSDF", "D5_UST",
    "D5_PWDIS", "D5_DWATER", "D5_NO2"
  )
}

ejscreen_pctile_lookup_mapping <- function(lookup,
                                           values,
                                           output_fields,
                                           mapping_for_names,
                                           rename_newtype) {
  mh <- validate_map_headernames_ejscreen_names(mapping_for_names)
  if (!rename_newtype %in% names(mh)) {
    stop("rename_newtype is not a column in mapping_for_names: ", rename_newtype)
  }

  lookup_names <- names(lookup)
  values_names <- if (!is.null(values)) names(values) else character()

  mapped_source_for_field <- function(field, available_names) {
    candidates <- mh$rname[
      !is_blank_string(mh[[rename_newtype]]) &
        mh[[rename_newtype]] == field &
        !is_blank_string(mh$rname)
    ]
    candidates <- candidates[candidates %in% available_names]
    if (length(candidates) == 0) {
      return(NA_character_)
    }
    candidates[[1]]
  }

  lookup_source_for_field <- function(field) {
    lookup_source <- mapped_source_for_field(field, lookup_names)
    if (!is.na(lookup_source)) {
      return(lookup_source)
    }
    if (field %in% lookup_names) {
      return(field)
    }
    NA_character_
  }

  value_source_for_field <- function(field) {
    value_source <- mapped_source_for_field(field, values_names)
    if (!is.na(value_source)) {
      return(value_source)
    }
    if (field %in% values_names) {
      return(field)
    }
    NA_character_
  }

  lookup_source_name <- vapply(output_fields, lookup_source_for_field, character(1))
  value_source_name <- vapply(output_fields, value_source_for_field, character(1))
  source_name <- lookup_source_name
  source_name[is.na(source_name)] <- value_source_name[is.na(source_name)]

  data.frame(
    output_field = output_fields,
    source_name = source_name,
    lookup_source_name = lookup_source_name,
    value_source_name = value_source_name,
    stringsAsFactors = FALSE
  )
}

ejscreen_pctile_lookup_std_rows_added <- function(out,
                                                  values,
                                                  mapping,
                                                  scope) {
  out <- data.table::as.data.table(out)
  out <- out[PCTILE != "std"]
  regions <- unique(out$REGION)

  std_by_region <- lapply(regions, function(region) {
    row <- as.list(stats::setNames(rep(NA_real_, NROW(mapping)), mapping$output_field))
    row$PCTILE <- "std"
    row$REGION <- region
    if (!is.null(values)) {
      value_subset <- if (identical(scope, "state")) {
        values[REGION == region]
      } else {
        values
      }
      for (i in seq_len(NROW(mapping))) {
        source <- if ("value_source_name" %in% names(mapping)) {
          mapping$value_source_name[[i]]
        } else {
          mapping$source_name[[i]]
        }
        field <- mapping$output_field[[i]]
        if (!is.na(source) && source %in% names(value_subset)) {
          x <- suppressWarnings(as.numeric(value_subset[[source]]))
          row[[field]] <- if (sum(!is.na(x)) >= 2) stats::sd(x, na.rm = TRUE) else NA_real_
        }
      }
    }
    data.table::as.data.table(row)
  })
  std_dt <- data.table::rbindlist(std_by_region, fill = TRUE)

  out_parts <- lapply(regions, function(region) {
    region_rows <- out[REGION == region]
    std_row <- std_dt[REGION == region]
    mean_idx <- which(region_rows$PCTILE == "mean")
    if (length(mean_idx) == 0) {
      return(data.table::rbindlist(list(region_rows, std_row), fill = TRUE))
    }
    idx <- mean_idx[[length(mean_idx)]]
    before <- region_rows[seq_len(idx)]
    after <- if (idx < NROW(region_rows)) region_rows[(idx + 1L):NROW(region_rows)] else region_rows[0]
    data.table::rbindlist(list(before, std_row, after), fill = TRUE)
  })
  out <- data.table::rbindlist(out_parts, fill = TRUE)
  data.table::setcolorder(out, c("PCTILE", "REGION", setdiff(names(out), c("PCTILE", "REGION"))))
  out
}

ejscreen_pctile_lookup_export_save <- function(x,
                                               path,
                                               format = NULL,
                                               overwrite = TRUE,
                                               storage = c("auto", "local", "s3")) {
  storage <- ejscreen_pipeline_storage_backend(path = path, storage = storage)
  if (storage == "local" && file.exists(path) && !overwrite) {
    stop("Refusing to overwrite existing file: ", path)
  }
  if (storage == "s3" && ejscreen_pipeline_s3_uri_exists(path) && !overwrite) {
    stop("Refusing to overwrite existing file: ", path)
  }
  if (is.null(format)) {
    format <- tolower(sub("^.*\\.([^.]+)$", "\\1", path))
  }
  write_path <- path
  if (storage == "local") {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  } else {
    write_path <- tempfile(fileext = paste0(".", format))
  }

  if (format == "csv") {
    data.table::fwrite(x, write_path)
  } else if (format == "rds") {
    saveRDS(x, write_path)
  } else if (format == "rda") {
    ejscreen_pctile_lookup_export <- x
    save(ejscreen_pctile_lookup_export, file = write_path)
  } else if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to save Arrow lookup export files")
    }
    arrow::write_ipc_file(x, sink = write_path)
  } else {
    stop("Unsupported lookup export save format: ", format)
  }

  if (storage == "s3") {
    return(invisible(ejscreen_pipeline_s3_upload(write_path, path)))
  }
  invisible(normalizePath(path, mustWork = FALSE))
}
