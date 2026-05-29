###################################################### #

#' Validate EJSCREEN name columns in map_headernames
#'
#' @details `map_headernames` has historically kept several naming systems:
#' `rname` for EJAM, `acsname` for ACS-derived variables,
#' `ejscreen_apinames_old` for the old offline EJSCREEN report/API names, and
#' `csvname` for the older EJSCREEN staff CSV/FTP-style download fields. Current
#' EJSCREEN map services use geodatabase/download field names for numeric
#' fields, plus related `P_`, `B_`, and `T_` fields for percentiles, map bins,
#' and popup text. Percentile, map-bin, and popup-text fields are represented as
#' their own rows, with `rname` values such as `pctile.pm`, `bin.pm`, and
#' `text.pm`.
#'
#' `data-raw/map_headernames.csv` is now the authoritative editable source for
#' this metadata. Build scripts should read that CSV, validate it, and save
#' `data/map_headernames.rda` without creating or changing metadata rows in
#' code. This validator exists to keep export code explicit about the metadata
#' it requires; it should not be used as a hidden augmentation step.
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
#' @param strict logical. If `TRUE`, validate the complete committed
#'   `map_headernames` source, including required columns, schema rows, and
#'   bin/text helper rows.
#' @param source_name character label used in error messages.
#'
#' @return The input as a plain data.frame. No metadata rows or columns are
#'   added, removed, or changed.
#'
#' @keywords internal
#'
validate_map_headernames_ejscreen_names <- function(mapping_for_names = map_headernames,
                                                    strict = FALSE,
                                                    source_name = "map_headernames") {
  mh <- as.data.frame(mapping_for_names, stringsAsFactors = FALSE, check.names = FALSE)
  problems <- character()
  add_problem <- function(x) {
    problems <<- c(problems, x)
    invisible(NULL)
  }

  required_cols <- c("rname", "ejscreen_indicator")
  if (isTRUE(strict)) {
    required_cols <- c(
      "rname", "longname", "varlist", "csvname", "acsname",
      "ejscreen_indicator", "ejscreen_ftp_names",
      "ejscreen_apinames_old", "ejam_apinames",
      "pctile.", "bin.", "text."
    )
  }
  missing_cols <- setdiff(required_cols, names(mh))
  if (length(missing_cols) > 0) {
    add_problem(paste0(
      "missing required column(s): ",
      paste(missing_cols, collapse = ", ")
    ))
  }
  if (anyDuplicated(names(mh))) {
    add_problem("column names must be unique")
  }

  if (isTRUE(strict)) {
    retired_cols <- c(
      ".text", "ejscreen_names",
      paste0("ejscreen_", c("pctile", "bin", "text")),
      "apiname", "ejscreen_api", "ejscreen_csv", "ejscreen_gdb"
    )
    retired_found <- intersect(retired_cols, names(mh))
    if (length(retired_found) > 0) {
      add_problem(paste0(
        "retired column(s) are present; move any still-needed values into ",
        "data-raw/map_headernames.csv current-schema columns: ",
        paste(retired_found, collapse = ", ")
      ))
    }
  }

  if ("rname" %in% names(mh)) {
    blank_rname <- which(is_blank_string(mh$rname))
    if (length(blank_rname) > 0) {
      add_problem(paste0(
        "rname must not be blank; blank row(s): ",
        paste(utils::head(blank_rname, 10), collapse = ", ")
      ))
    }
  }

  flag_cols <- intersect(c("pctile.", "bin.", "text."), names(mh))
  for (col in flag_cols) {
    x <- trimws(as.character(mh[[col]]))
    ok <- is_blank_string(x) |
      tolower(x) %in% c("0", "1", "false", "true", "f", "t", "no", "yes", "n", "y")
    if (any(!ok)) {
      add_problem(paste0(
        col, " has non-flag value(s): ",
        paste(utils::head(unique(x[!ok]), 10), collapse = ", ")
      ))
    }
  }

  if (isTRUE(strict) && length(missing_cols) == 0 && "rname" %in% names(mh)) {
    required_rows <- c(
      "bgfips", "OBJECTID", "EXCEED_COUNT_90", "EXCEED_COUNT_90_SUP",
      "SYMBOLOGY_EXCEED_COUNT_80", "Shape__Area", "Shape__Length"
    )
    missing_rows <- setdiff(required_rows, mh$rname)
    if (length(missing_rows) > 0) {
      add_problem(paste0(
        "missing required explicit row(s): ",
        paste(missing_rows, collapse = ", ")
      ))
    }

    expected_current_names <- c(
      "Demog.Index.State" = "DEMOGIDX_2ST",
      "Demog.Index.Supp.State" = "DEMOGIDX_5ST",
      "OBJECTID" = "OBJECTID"
    )
    for (rname in names(expected_current_names)) {
      idx <- which(mh$rname == rname)
      if (length(idx) == 0) {
        add_problem(paste0("missing required explicit row: ", rname))
      } else if (!expected_current_names[[rname]] %in% mh$ejscreen_indicator[idx]) {
        add_problem(paste0(
          "row ", rname, " must carry ejscreen_indicator ",
          expected_current_names[[rname]]
        ))
      }
    }

    non_output_marker <- grepl("***special", mh$ejscreen_indicator, fixed = TRUE) |
      grepl("use for pctile|do not report|don.?t report",
            mh$ejscreen_indicator, ignore.case = TRUE)
    if (any(non_output_marker)) {
      add_problem(paste0(
        "ejscreen_indicator has old non-output marker text in row(s): ",
        paste(utils::head(which(non_output_marker), 10), collapse = ", ")
      ))
    }

    pctile_rows <- which(
      map_headernames_pctile_row(mh) &
        grepl("^P_", mh$ejscreen_indicator)
    )
    for (i in pctile_rows) {
      base_rname <- ejscreen_base_rname_from_pctile_rname(mh$rname[i])
      if (is_blank_string(base_rname)) {
        next
      }
      helper_rnames <- paste0(c("bin.", "text."), base_rname)
      missing_helpers <- setdiff(helper_rnames, mh$rname)
      if (length(missing_helpers) > 0) {
        add_problem(paste0(
          "percentile row ", mh$rname[i],
          " is missing explicit helper row(s): ",
          paste(missing_helpers, collapse = ", ")
        ))
      }
    }
  }

  if (length(problems) > 0) {
    stop(
      paste0(
        source_name,
        " validation failed:\n- ",
        paste(problems, collapse = "\n- ")
      ),
      call. = FALSE
    )
  }

  invisible(mh)
}

#' @rdname validate_map_headernames_ejscreen_names
#' @keywords internal
augment_map_headernames_ejscreen_names <- function(mapping_for_names = map_headernames) {
  validate_map_headernames_ejscreen_names(
    mapping_for_names = mapping_for_names,
    strict = FALSE,
    source_name = "mapping_for_names"
  )
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
  flag <- if ("pctile." %in% names(mh)) {
    ejscreen_flag_true(mh[["pctile."]])
  } else {
    rep(FALSE, NROW(mh))
  }
  flag | grepl("^(pctile|state[.]pctile)[.]", as.character(mh$rname))
}

map_headernames_bin_row <- function(mh) {
  flag <- if ("bin." %in% names(mh)) {
    ejscreen_flag_true(mh[["bin."]])
  } else {
    rep(FALSE, NROW(mh))
  }
  flag | grepl("^bin[.]", as.character(mh$rname))
}

map_headernames_text_row <- function(mh) {
  flag <- if ("text." %in% names(mh)) {
    ejscreen_flag_true(mh[["text."]])
  } else {
    rep(FALSE, NROW(mh))
  }
  flag | grepl("^text[.]", as.character(mh$rname))
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
