###################################################### #

#' Complete EJSCREEN name columns in map_headernames
#'
#' @details `map_headernames` has historically kept several naming systems:
#' `rname` for EJAM, `acsname` for ACS-derived variables, `apiname` for the old
#' offline EJSCREEN report/API names, and `csvname` for the older EJSCREEN staff
#' CSV/FTP-style download fields. Current EJSCREEN map services use
#' geodatabase/download field names for numeric fields, plus related `P_`,
#' `B_`, and `T_` fields for percentiles, map bins, and popup text. This helper
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
#'   - `ejscreen_csv`
#'   - `ejscreen_gdb`
#'   - `ejscreen_api`
#'   - `ejscreen_pctile`
#'   - `ejscreen_bin`
#'   - `ejscreen_text`
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
  for (col in c(
    "rname", "csvname", "apiname", "ejscreen_indicator",
    "ejscreen_ftp_names", "ejscreen_apinames_old", "ejam_apinames",
    "ejscreen_csv", "ejscreen_gdb", "ejscreen_api", "ejscreen_pctile",
    "ejscreen_bin", "ejscreen_text"
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
  special_marker_cols <- c(
    "ejscreen_indicator", "ejscreen_csv", "ejscreen_gdb",
    "ejscreen_pctile", "ejscreen_bin", "ejscreen_text"
  )
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
      ejscreen_csv = field,
      ejscreen_gdb = field,
      ejam_apinames = field
    ))
  }

  add_default_name_row(c(
    rname = "bgfips",
    longname = "Block group FIPS",
    csvname = "ID",
    ejscreen_indicator = "ID",
    ejscreen_ftp_names = "ID",
    ejam_apinames = "bgfips",
    ejscreen_csv = "ID",
    ejscreen_gdb = "ID"
  ))

  state_demog_idx <- mh$rname == "Demog.Index.State"
  mh$ejscreen_indicator[state_demog_idx] <- "DEMOGIDX_2ST"
  mh$ejscreen_ftp_names[state_demog_idx] <- "DEMOGIDX_2ST"
  mh$ejscreen_csv[state_demog_idx] <- "DEMOGIDX_2ST"
  mh$ejscreen_gdb[state_demog_idx] <- "DEMOGIDX_2ST"

  state_demog_idx_supp <- mh$rname == "Demog.Index.Supp.State"
  mh$ejscreen_indicator[state_demog_idx_supp] <- "DEMOGIDX_5ST"
  mh$ejscreen_ftp_names[state_demog_idx_supp] <- "DEMOGIDX_5ST"
  mh$ejscreen_csv[state_demog_idx_supp] <- "DEMOGIDX_5ST"
  mh$ejscreen_gdb[state_demog_idx_supp] <- "DEMOGIDX_5ST"

  objectid_rows <- mh$rname == "OBJECTID"
  mh$ejscreen_indicator[objectid_rows] <- "OBJECTID"
  mh$ejscreen_ftp_names[objectid_rows] <- "OBJECTID"
  mh$ejscreen_csv[objectid_rows] <- "OBJECTID"
  mh$ejscreen_gdb[objectid_rows] <- "OBJECTID"

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
  fill_blank("ejscreen_apinames_old", mh$apiname)
  fill_blank("ejam_apinames", mh$rname)
  fill_blank("ejscreen_indicator", mh$ejscreen_csv)
  fill_blank("ejscreen_indicator", mh$ejscreen_ftp_names)
  fill_blank("ejscreen_csv", mh$ejscreen_ftp_names)
  fill_blank("ejscreen_gdb", mh$ejscreen_indicator)
  fill_blank("ejscreen_api", mh$ejscreen_apinames_old)

  ejscreen_field <- mh$ejscreen_indicator
  app_code <- ejscreen_code_from_field(ejscreen_field)
  has_app_code <- !is_blank_string(app_code)

  pctile_field <- paste0("P_", app_code)
  pctile_field[grepl("^P_", ejscreen_field)] <- ejscreen_field[grepl("^P_", ejscreen_field)]
  fill_blank("ejscreen_pctile", ifelse(has_app_code, pctile_field, ""))
  fill_blank("ejscreen_bin", ifelse(has_app_code, paste0("B_", app_code), ""))
  fill_blank("ejscreen_text", ifelse(has_app_code, paste0("T_", app_code), ""))
  no_app_code <- !has_app_code
  mh$ejscreen_pctile[no_app_code] <- ""
  mh$ejscreen_bin[no_app_code] <- ""
  mh$ejscreen_text[no_app_code] <- ""

  mh
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
