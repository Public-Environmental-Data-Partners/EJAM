###################################################### #

#' Complete EJSCREEN name columns in map_headernames
#'
#' @details `map_headernames` has historically kept several naming systems:
#' `rname` for EJAM, `acsname` for ACS-derived variables,
#' `ejscreen_apinames_old` for the old offline EJSCREEN report/API names, and
#' `csvname` for the older EJSCREEN staff CSV/FTP-style download fields. Current
#' EJSCREEN map services use geodatabase/download field names for numeric
#' fields, plus related `P_`,
#' `B_`, and `T_` fields for percentiles, map bins, and popup text. Percentile,
#' map-bin, and popup-text fields are represented as their own rows, with
#' `rname` values such as `pctile.pm`, `bin.pm`, and `text.pm`. This helper
#' fills explicit columns for each naming system so export code can use one
#' crosswalk without confusing old EJSCREEN API names with current EJAM API
#' names.
#'
#' The `ejscreen_ftp_names` values are intended to preserve the field names used
#' in EPA's old EJSCREEN FTP/download CSV and geodatabase files, such as the
#' archived 2024 v2.32 block-group files and the accompanying
#' `EJScreen_2024_BG_Percentiles_Columns.xlsx` and
#' `EJScreen_2024_BG_State_Percentiles_Columns.xlsx` column dictionaries. Those
#' names are usually the same as `ejscreen_indicator`, but both columns are kept so
#' old FTP/download provenance and current app/export naming can diverge later
#' if needed.
#'
#' @param mapping_for_names a data.frame like [map_headernames].
#'
#' @return A data.frame with these additional or completed columns:
#'   - `ejscreen_indicator`
#'   - `ejscreen_ftp_names`
#'   - `ejscreen_apinames_old`
#'   - `ejam_apinames`
#'   - `text.`
#'
#' Older `.text` input is renamed to `text.` when present. Retired sibling-name
#' columns are dropped when present because `P_`, `B_`, and `T_` fields are now
#' represented as ordinary metadata rows.
#'
#' @keywords internal
#'
augment_map_headernames_ejscreen_names <- function(mapping_for_names = map_headernames) {

  # note this may be the case already:  all.equal(map_headernames,   augment_map_headernames_ejscreen_names(map_headernames) )

  mh <- as.data.frame(mapping_for_names, stringsAsFactors = FALSE)
  if (!"ejscreen_indicator" %in% names(mh) && "ejscreen_names" %in% names(mh)) {
    mh$ejscreen_indicator <- mh$ejscreen_names
  }
  if ("ejscreen_names" %in% names(mh)) {
    mh$ejscreen_names <- NULL
  }
  if (".text" %in% names(mh)) {
    if (!"text." %in% names(mh)) {
      names(mh)[names(mh) == ".text"] <- "text."
    } else {
      mh[["text."]] <- as.integer(ejscreen_flag_true(mh[["text."]]) | ejscreen_flag_true(mh[[".text"]]))
      mh[[".text"]] <- NULL
    }
  }
  for (col in c("pctile.", "bin.", "text.")) {
    if (!col %in% names(mh)) {
      mh[[col]] <- 0L
    }
    mh[[col]] <- as.integer(ejscreen_flag_true(mh[[col]]))
  }
  for (col in c(
    "rname", "csvname", "ejscreen_indicator",
    "ejscreen_ftp_names", "ejscreen_apinames_old", "ejam_apinames",
    "acsname"
  )) {
    if (!col %in% names(mh)) {
      mh[[col]] <- ""
    }
    mh[[col]] <- as.character(mh[[col]])
    mh[[col]][is.na(mh[[col]])] <- ""
  }
  is_non_output_marker <- function(x) {
    grepl("***special", x, fixed = TRUE) |
      grepl("use for pctile|do not report|don.?t report", x, ignore.case = TRUE)
  }
  special_marker_cols <- "ejscreen_indicator"
  for (col in special_marker_cols) {
    mh[[col]][is_non_output_marker(mh[[col]])] <- ""
  }

  add_default_name_row <- function(values) {
    if (any(mh$rname == values[["rname"]])) {
      return(invisible(NULL))
    }
    newrow <- as.data.frame(
      stats::setNames(as.list(rep("", length(names(mh)))), names(mh)),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    for (col in intersect(names(values), names(newrow))) {
      newrow[[col]] <- values[[col]]
    }
    mh <<- rbind(mh, newrow)
    invisible(NULL)
  }

  # Keep the block-group identifier in EJSCREEN exports even if map_headernames
  # does not carry a data row for this package-internal key field.
  add_ejscreen_schema_extra_row <- function(field, longname, varlist = "ejscreen_schema_extra") {
    add_default_name_row(c(
      rname = field,
      longname = longname,
      varlist = varlist,
      ejscreen_indicator = field,
      ejscreen_ftp_names = field,
      ejam_apinames = field
    ))
  }

  add_default_name_row(c(
    rname = "bgfips",
    longname = "Block group FIPS",
    csvname = "ID",
    ejscreen_indicator = "ID",
    ejscreen_ftp_names = "ID",
    ejam_apinames = "bgfips"
  ))

  state_demog_idx <- mh$rname == "Demog.Index.State"
  mh$ejscreen_indicator[state_demog_idx] <- "DEMOGIDX_2ST"
  mh$ejscreen_ftp_names[state_demog_idx] <- "DEMOGIDX_2ST"

  state_demog_idx_supp <- mh$rname == "Demog.Index.Supp.State"
  mh$ejscreen_indicator[state_demog_idx_supp] <- "DEMOGIDX_5ST"
  mh$ejscreen_ftp_names[state_demog_idx_supp] <- "DEMOGIDX_5ST"

  objectid_rows <- mh$rname == "OBJECTID"
  mh$ejscreen_indicator[objectid_rows] <- "OBJECTID"
  mh$ejscreen_ftp_names[objectid_rows] <- "OBJECTID"

  # These are documented fields in the EJSCREEN FeatureServer schema that are
  # not ordinary EJAM indicator names. Keep them in the name crosswalk so schema
  # reports can distinguish expected-but-not-produced fields from true extras.
  add_ejscreen_schema_extra_row("OBJECTID", "ArcGIS service object identifier field", "ejscreen_arcgis_service_field")
  add_ejscreen_schema_extra_row("EXCEED_COUNT_90", "Count of EJ indexes at or above the 90th percentile")
  add_ejscreen_schema_extra_row("EXCEED_COUNT_90_SUP", "Count of supplemental EJ indexes at or above the 90th percentile")
  add_ejscreen_schema_extra_row("SYMBOLOGY_EXCEED_COUNT_80", "EJSCREEN symbology category for exceedance count")
  add_ejscreen_schema_extra_row("Shape__Area", "ArcGIS service geometry area field", "ejscreen_arcgis_service_field")
  add_ejscreen_schema_extra_row("Shape__Length", "ArcGIS service geometry length field", "ejscreen_arcgis_service_field")

  fill_blank <- function(target, value) {
    ok <- is_blank_string(mh[[target]]) & !is_blank_string(value) & !is_non_output_marker(value)
    mh[[target]][ok] <<- value[ok]
    invisible(NULL)
  }

  fill_blank("ejscreen_ftp_names", mh$csvname)
  fill_blank("ejam_apinames", mh$rname)
  fill_blank("ejscreen_indicator", mh$ejscreen_ftp_names)

  mh[["pctile."]] <- as.integer(ejscreen_flag_true(mh[["pctile."]]) | grepl("^(pctile|state[.]pctile)[.]", mh$rname))
  mh[["bin."]] <- as.integer(ejscreen_flag_true(mh[["bin."]]) | grepl("^bin[.]", mh$rname))
  mh[["text."]] <- as.integer(ejscreen_flag_true(mh[["text."]]) | grepl("^text[.]", mh$rname))

  add_map_helper_row <- function(source_row, helper_type, helper_field) {
    if (is_blank_string(helper_field)) {
      return(invisible(NULL))
    }
    base_rname <- ejscreen_base_rname_from_pctile_rname(source_row$rname)
    if (is_blank_string(base_rname)) {
      return(invisible(NULL))
    }
    helper_rname <- paste0(helper_type, ".", base_rname)
    if (any(mh$rname == helper_rname)) {
      helper_i <- which(mh$rname == helper_rname)[1]
      if (is_blank_string(mh$ejscreen_indicator[helper_i])) {
        mh$ejscreen_indicator[helper_i] <<- helper_field
      }
      if (is_blank_string(mh$ejscreen_ftp_names[helper_i])) {
        mh$ejscreen_ftp_names[helper_i] <<- helper_field
      }
      mh[[paste0(helper_type, ".")]][helper_i] <<- 1L
      return(invisible(NULL))
    }

    newrow <- source_row
    newrow[,] <- ""
    for (flag_col in c("pctile.", "bin.", "text.")) {
      if (flag_col %in% names(newrow)) {
        newrow[[flag_col]] <- 0L
      }
    }
    newrow$rname <- helper_rname
    if ("longname" %in% names(newrow)) {
      suffix <- if (helper_type == "bin") " map bin" else " popup text"
      newrow$longname <- paste0(source_row$longname, suffix)
    }
    if ("varcategory" %in% names(newrow)) {
      newrow$varcategory <- source_row$varcategory
    }
    if ("vartype" %in% names(newrow)) {
      newrow$vartype <- if (helper_type == "bin") "map_bin" else "map_text"
    }
    if ("calculation_type" %in% names(newrow)) {
      newrow$calculation_type <- if (helper_type == "bin") "map_bin" else "map_text"
    }
    newrow$ejscreen_indicator <- helper_field
    newrow$ejscreen_ftp_names <- helper_field
    newrow$ejam_apinames <- helper_rname
    newrow[[paste0(helper_type, ".")]] <- 1L
    mh <<- rbind(mh, newrow)
    invisible(NULL)
  }

  pctile_rows <- which(map_headernames_pctile_row(mh) & grepl("^P_", mh$ejscreen_indicator))
  for (i in pctile_rows) {
    app_code <- ejscreen_code_from_field(mh$ejscreen_indicator[i])
    if (is_blank_string(app_code)) {
      next
    }
    bin_field <- paste0("B_", app_code)
    text_field <- paste0("T_", app_code)
    add_map_helper_row(mh[i, , drop = FALSE], "bin", bin_field)
    add_map_helper_row(mh[i, , drop = FALSE], "text", text_field)
  }

  retired_sibling_cols <- c(
    paste0("ejscreen_", c("pctile", "bin", "text")),
    "apiname", "ejscreen_api", "ejscreen_csv", "ejscreen_gdb"
  )
  for (col in intersect(retired_sibling_cols, names(mh))) {
    mh[[col]] <- NULL
  }

  mh
}

ejscreen_flag_true <- function(x) {
  if (is.null(x)) {
    return(logical(0))
  }
  x_chr <- trimws(as.character(x))
  x_num <- suppressWarnings(as.numeric(x_chr))
  (!is.na(x_num) & x_num != 0) |
    tolower(x_chr) %in% c("true", "t", "yes", "y")
}

map_headernames_pctile_row <- function(mh) {
  ejscreen_flag_true(mh[["pctile."]]) |
    grepl("^(pctile|state[.]pctile)[.]", as.character(mh$rname))
}

map_headernames_bin_row <- function(mh) {
  ejscreen_flag_true(mh[["bin."]]) |
    grepl("^bin[.]", as.character(mh$rname))
}

map_headernames_text_row <- function(mh) {
  ejscreen_flag_true(mh[["text."]]) |
    grepl("^text[.]", as.character(mh$rname))
}

ejscreen_base_rname_from_pctile_rname <- function(rname) {
  rname <- as.character(rname)
  rname <- sub("^state[.]pctile[.]", "", rname)
  rname <- sub("^pctile[.]", "", rname)
  rname
}

is_blank_string <- function(x) {
  is.na(x) | !nzchar(trimws(as.character(x)))
}

ejscreen_code_from_field <- function(field) {
  field <- as.character(field)
  field[is.na(field)] <- ""
  code <- field
  code <- sub("^P_", "", code)

  # The raw lead-paint field is PRE1960PCT, but the current EJSCREEN app uses
  # LDPNT for map-bin and popup-text fields.
  code[code == "PRE1960PCT"] <- "LDPNT"

  non_map_fields <- c(
    "", "OBJECTID", "Shape", "Shape__Area", "Shape__Length",
    "ID", "STATE_NAME", "ST_ABBREV", "CNTY_NAME", "REGION",
    "ACSTOTPOP", "ACSIPOVBAS", "ACSEDUCBAS", "ACSTOTHH",
    "ACSTOTHU", "ACSUNEMPBAS", "ACSDISABBAS", "AREALAND",
    "AREAWATER", "EXCEED_COUNT_80", "EXCEED_COUNT_80_SUP",
    "EXCEED_COUNT_90", "EXCEED_COUNT_90_SUP",
    "SYMBOLOGY_EXCEED_COUNT_80", "DEMOGIDX_2ST", "DEMOGIDX_5ST"
  )
  code[code %in% non_map_fields] <- ""
  code
}

###################################################### #
