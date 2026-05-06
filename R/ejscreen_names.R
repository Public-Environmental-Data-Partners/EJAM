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
#' names are usually the same as `ejscreen_names`, but both columns are kept so
#' old FTP/download provenance and current app/export naming can diverge later
#' if needed.
#'
#' @param mapping_for_names a data.frame like [map_headernames].
#'
#' @return A data.frame with additional or completed `ejscreen_names`,
#'   `ejscreen_ftp_names`, `ejscreen_apinames_old`, `ejam_apinames`,
#'   `ejscreen_csv`, `ejscreen_gdb`, `ejscreen_app`, `ejscreen_api`,
#'   `ejscreen_pctile`, `ejscreen_bin`, and `ejscreen_text` columns.
#'
#' @keywords internal
#' @export
#'
augment_map_headernames_ejscreen_names <- function(mapping_for_names = map_headernames) {
  mh <- as.data.frame(mapping_for_names, stringsAsFactors = FALSE)
  for (col in c(
    "rname", "csvname", "apiname", "ejscreen_names",
    "ejscreen_ftp_names", "ejscreen_apinames_old", "ejam_apinames",
    "ejscreen_csv", "ejscreen_gdb", "ejscreen_app", "ejscreen_api", "ejscreen_pctile",
    "ejscreen_bin", "ejscreen_text"
  )) {
    if (!col %in% names(mh)) {
      mh[[col]] <- ""
    }
    mh[[col]] <- as.character(mh[[col]])
    mh[[col]][is.na(mh[[col]])] <- ""
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
  add_default_name_row(c(
    rname = "bgfips",
    longname = "Block group FIPS",
    csvname = "ID",
    ejscreen_names = "ID",
    ejscreen_ftp_names = "ID",
    ejam_apinames = "bgfips",
    ejscreen_csv = "ID",
    ejscreen_gdb = "ID",
    ejscreen_app = "ID"
  ))

  fill_blank <- function(target, value) {
    ok <- is_blank_string(mh[[target]]) & !is_blank_string(value)
    mh[[target]][ok] <<- value[ok]
    invisible(NULL)
  }

  fill_blank("ejscreen_ftp_names", mh$csvname)
  fill_blank("ejscreen_apinames_old", mh$apiname)
  fill_blank("ejam_apinames", mh$rname)
  fill_blank("ejscreen_names", mh$ejscreen_csv)
  fill_blank("ejscreen_names", mh$ejscreen_ftp_names)
  fill_blank("ejscreen_csv", mh$ejscreen_ftp_names)
  fill_blank("ejscreen_gdb", mh$ejscreen_names)
  fill_blank("ejscreen_app", mh$ejscreen_names)
  fill_blank("ejscreen_api", mh$ejscreen_apinames_old)

  app_field <- mh$ejscreen_app
  app_code <- ejscreen_app_code_from_field(app_field)
  has_app_code <- !is_blank_string(app_code)

  pctile_field <- paste0("P_", app_code)
  pctile_field[grepl("^P_", app_field)] <- app_field[grepl("^P_", app_field)]
  fill_blank("ejscreen_pctile", ifelse(has_app_code, pctile_field, ""))
  fill_blank("ejscreen_bin", ifelse(has_app_code, paste0("B_", app_code), ""))
  fill_blank("ejscreen_text", ifelse(has_app_code, paste0("T_", app_code), ""))

  mh
}

is_blank_string <- function(x) {
  is.na(x) | !nzchar(trimws(as.character(x)))
}

ejscreen_app_code_from_field <- function(field) {
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
    "AREAWATER"
  )
  code[code %in% non_map_fields] <- ""
  code
}

###################################################### #
