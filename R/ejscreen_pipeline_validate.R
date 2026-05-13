###################################################### #

#' Validate one pipeline stage before saving dataset at that stage, for EJSCREEN/EJAM data updates pipeline
#'
#' @details These checks are intentionally lightweight. They catch structural
#' problems that would make the next stage fail or make a saved checkpoint
#' misleading, without trying to be a full scientific validation report.
#'
#' @param x object to validate.
#' @param stage pipeline stage name, must be among known stages or aliases
#' as found in `EJAM:::ejscreen_pipeline_stage_names()` with canonical names such as
#' `r paste0(EJAM:::ejscreen_pipeline_stage_names(canonical_only = TRUE), collapse = ", ")`
#'
#' @param strict logical. If TRUE, errors stop execution. Warnings are still
#'   emitted as warnings.
#'
#' @return invisibly returns a list with `errors` and `warnings`.
#'
#' @keywords internal
#'
ejscreen_pipeline_validate <- function(x, stage, strict = TRUE) {

  if (missing(stage) || is.null(stage) || !nzchar(stage)) {
    return(invisible(list(stage = NA_character_, errors = character(), warnings = character())))
  }

  errors <- character()
  warnings <- character()
  # helper functions for validation ####
  add_error <- function(msg) {
    errors <<- c(errors, msg)
  }
  add_warning <- function(msg) {
    warnings <<- c(warnings, msg)
  }
  has_cols <- function(cols) {
    missing_cols <- setdiff(cols, names(x))
    if (length(missing_cols) > 0) {
      add_error(paste0("missing required columns: ", paste(missing_cols, collapse = ", ")))
      FALSE
    } else {
      TRUE
    }
  }
  warn_missing_cols <- function(cols) {
    missing_cols <- setdiff(cols, names(x))
    if (length(missing_cols) > 0) {
      add_warning(paste0("missing expected columns: ", paste(missing_cols, collapse = ", ")))
    }
  }
  check_bgfips <- function() {
    if (!"bgfips" %in% names(x)) {
      return(NULL)
    }
    if (any(is.na(x$bgfips) | !nzchar(as.character(x$bgfips)))) {
      add_error("bgfips has missing or blank values")
    }
    dup_count <- sum(duplicated(x$bgfips))
    if (dup_count > 0) {
      add_error(paste0("bgfips has ", dup_count, " duplicate rows"))
    }
    invisible(NULL)
  }
  check_id <- function() {
    if (!"ID" %in% names(x)) {
      add_error("missing required columns: ID")
      return(NULL)
    }
    if (any(is.na(x$ID) | !nzchar(as.character(x$ID)))) {
      add_error("ID has missing or blank values")
    }
    dup_count <- sum(duplicated(x$ID))
    if (dup_count > 0) {
      add_error(paste0("ID has ", dup_count, " duplicate rows"))
    }
    invisible(NULL)
  }
  check_no_blank_cols <- function(cols) {
    cols <- intersect(cols, names(x))
    bad <- cols[vapply(cols, function(col) {
      any(is.na(x[[col]]) | !nzchar(as.character(x[[col]])))
    }, logical(1))]
    if (length(bad) > 0) {
      add_error(paste0("columns have missing or blank values: ", paste(bad, collapse = ", ")))
    }
    invisible(NULL)
  }
  check_nonnegative <- function(cols) {
    cols <- intersect(cols, names(x))
    bad <- cols[vapply(cols, function(col) {
      is.numeric(x[[col]]) && any(x[[col]] < 0, na.rm = TRUE)
    }, logical(1))]
    if (length(bad) > 0) {
      add_warning(paste0("negative values found in expected nonnegative columns: ", paste(bad, collapse = ", ")))
    }
  }
  check_fraction_percent_cols <- function() {
    pct_cols <- grep("^pct", names(x), value = TRUE)
    pct_cols <- setdiff(pct_cols, grep("^pctile", pct_cols, value = TRUE))
    pct_cols <- pct_cols[vapply(pct_cols, function(col) is.numeric(x[[col]]), logical(1))]
    bad <- pct_cols[vapply(pct_cols, function(col) {
      any(x[[col]] < 0 | x[[col]] > 1, na.rm = TRUE)
    }, logical(1))]
    if (length(bad) > 0) {
      add_warning(paste0("percentage/fraction columns have values outside 0-1: ", paste(bad, collapse = ", ")))
    }
  }
  check_all_na_numeric <- function(cols) {
    cols <- intersect(cols, names(x))
    bad <- cols[vapply(cols, function(col) {
      is.numeric(x[[col]]) && all(is.na(x[[col]]))
    }, logical(1))]
    if (length(bad) > 0) {
      add_warning(paste0("numeric columns are entirely NA: ", paste(bad, collapse = ", ")))
    }
  }
  check_ejscreen_export_helpers <- function() {
    pctile_cols <- grep("^(P_|S_P_)", names(x), value = TRUE)
    bin_cols <- grep("^B_", names(x), value = TRUE)

    bad_pctile <- pctile_cols[vapply(pctile_cols, function(col) {
      vals <- suppressWarnings(as.numeric(x[[col]]))
      any(!is.na(vals) & (vals < 0 | vals > 100))
    }, logical(1))]
    if (length(bad_pctile) > 0) {
      add_error(paste0("EJSCREEN percentile columns have values outside 0-100: ",
                       paste(bad_pctile, collapse = ", ")))
    }

    bad_bins <- bin_cols[vapply(bin_cols, function(col) {
      vals <- suppressWarnings(as.numeric(x[[col]]))
      any(!is.na(vals) & (vals < 0 | vals > 11 | abs(vals - round(vals)) > .Machine$double.eps^0.5))
    }, logical(1))]
    if (length(bad_bins) > 0) {
      add_error(paste0("EJSCREEN map-bin columns have values outside integer bins 0-11: ",
                       paste(bad_bins, collapse = ", ")))
    }

    text_cols <- grep("^T_", names(x), value = TRUE)
    non_text <- text_cols[!vapply(text_cols, function(col) {
      is.character(x[[col]]) || is.factor(x[[col]])
    }, logical(1))]
    if (length(non_text) > 0) {
      add_warning(paste0("EJSCREEN popup-text columns are not character/factor: ",
                         paste(non_text, collapse = ", ")))
    }

    if (!any(grepl("^(D2_|D5_|P_D2_|P_D5_)", names(x)))) {
      add_warning("ejscreen_export has no D2/D5 EJ index fields")
    }
    invisible(NULL)
  }
  check_lookup <- function(expect_usa = NULL) {
    has_cols(c("REGION", "PCTILE"))
    if (!all(c("REGION", "PCTILE") %in% names(x))) {
      return(NULL)
    }
    if (any(duplicated(paste(x$REGION, x$PCTILE)))) {
      add_error("REGION/PCTILE combinations are duplicated")
    }
    if (!"mean" %in% as.character(x$PCTILE)) {
      add_warning("PCTILE does not include a mean row")
    }
    if (!"100" %in% as.character(x$PCTILE)) {
      add_warning("PCTILE does not include 100")
    }
    if (!"0" %in% as.character(x$PCTILE)) {
      add_warning("PCTILE does not include 0/min row; pctile_from_raw_lookup() expects that convention")
    }
    if (isTRUE(expect_usa) && !all(x$REGION %in% "USA")) {
      add_error("usastats REGION should be USA for all rows")
    }
    if (isFALSE(expect_usa) && all(x$REGION %in% "USA")) {
      add_error("statestats should include state/territory REGION values, not only USA")
    }
    indicator_cols <- setdiff(names(x), c("OBJECTID", "REGION", "PCTILE"))
    if (length(indicator_cols) == 0) {
      add_error("lookup table has no indicator columns")
    }
    invisible(NULL)
  }
  check_acs_raw_component <- function(component) {
    tables <- x[[component]]
    if (is.null(tables)) {
      add_error(paste0("missing ", component, " ACS table list"))
      return(NULL)
    }
    if (!is.list(tables)) {
      add_error(paste0(component, " ACS tables must be stored as a list"))
      return(NULL)
    }
    bad <- names(tables)[!vapply(tables, is.data.frame, logical(1))]
    if (length(bad) > 0) {
      add_error(paste0(component, " ACS tables are not data.frames: ", paste(bad, collapse = ", ")))
    }
    missing_fips <- names(tables)[vapply(tables, function(tab) {
      is.data.frame(tab) && !"fips" %in% names(tab)
    }, logical(1))]
    if (length(missing_fips) > 0) {
      add_error(paste0(component, " ACS tables are missing fips: ", paste(missing_fips, collapse = ", ")))
    }
    zero_rows <- names(tables)[vapply(tables, function(tab) {
      is.data.frame(tab) && NROW(tab) == 0
    }, logical(1))]
    if (length(zero_rows) > 0) {
      add_warning(paste0(component, " ACS tables have zero rows: ", paste(zero_rows, collapse = ", ")))
    }
    invisible(NULL)
  }

  # ~ ####
  ###################################################### #  ###################################################### #

  # Validate this stage, using helpers ####

  known_stages <- ejscreen_pipeline_stage_names()
  canonical_stage <- ejscreen_pipeline_stage_canonical(stage)
  us_lookup_stages <- c("usastats_acs", "usastats_envirodata", "usastats_ej", "usastats")
  state_lookup_stages <- c("statestats_acs", "statestats_envirodata", "statestats_ej", "statestats")
  if (!stage %in% known_stages) {
    return(invisible(list(stage = stage, errors = errors, warnings = warnings)))
  }
  ###################################################### #
  # basic check for all stages (except bg_acs_raw) ####

  if (canonical_stage != "bg_acs_raw") {

    if (!is.data.frame(x)) {
      add_error("stage object must be a data.frame or data.table")
    } else {
      if (NROW(x) == 0) {
        add_error("stage has zero rows")
      }
      if (NCOL(x) == 0) {
        add_error("stage has zero columns")
      }
    }
  }
  ###################################################### #
  # bg_acs_raw ####

  if (canonical_stage == "bg_acs_raw") {

    if (!is.list(x)) {
      add_error("bg_acs_raw must be a list")
    } else {
      for (required_name in c("yr", "blockgroup_tables", "blockgroup")) {
        if (is.null(x[[required_name]])) {
          add_error(paste0("bg_acs_raw is missing ", required_name))
        }
      }
      check_acs_raw_component("blockgroup")
      if (!is.null(x$tract) && length(x$tract) > 0) {
        check_acs_raw_component("tract")
      }
    }
  }
  ###################################################### #
  if (length(errors) == 0) {
    # passed very basic checks, so can now try stage-specific checks

    ###################################################### #
    # bg_acsdata ####

    if (canonical_stage == "bg_acsdata") {

      has_cols(c("bgfips", "pop"))
      warn_missing_cols(c("pctmin", "pctlowinc", "pctlingiso", "pctlths", "pctdisability"))
      check_bgfips()
      check_nonnegative(c("pop"))
      check_fraction_percent_cols()
      ###################################################### #
      # bg_envirodata ####

    } else if (canonical_stage == "bg_envirodata") {

      has_cols(c("bgfips", "pctpre1960"))
      check_bgfips()
      expected_env <- if (exists("names_e")) names_e else character()
      if (length(intersect(expected_env, names(x))) == 0) {
        add_warning("bg_envirodata has none of the expected environmental indicator columns in names_e")
      }
      check_all_na_numeric(setdiff(names(x), "bgfips"))
      ###################################################### #
      # bg_extra_indicators ####

    } else if (canonical_stage == "bg_extra_indicators") {

      has_cols(c("bgfips", "lowlifex"))
      check_bgfips()
      expected_extra <- attr(x, "extra_indicator_vars", exact = TRUE)
      if (is.null(expected_extra)) {
        expected_extra <- if (exists("ejscreen_default_extra_indicator_vars")) ejscreen_default_extra_indicator_vars() else character()
      }
      warn_missing_cols(expected_extra)
      check_all_na_numeric(setdiff(names(x), "bgfips"))
      ###################################################### #
      # blockgroupstats ####

    } else if (canonical_stage == "blockgroupstats") {

      required <- c(
        "bgfips", "bgid", "ST", "statename", "REGION", "pop",
        "Demog.Index", "Demog.Index.Supp",
        "Demog.Index.State", "Demog.Index.Supp.State"
      )
      has_cols(required)
      check_bgfips()
      check_no_blank_cols(c("bgid", "ST", "statename", "REGION"))
      check_nonnegative(c("pop", "Demog.Index", "Demog.Index.Supp",
                          "Demog.Index.State", "Demog.Index.Supp.State"))
      expected_env <- if (exists("names_e")) names_e else character()
      warn_missing_cols(expected_env)
      check_fraction_percent_cols()
      ###################################################### #
      # bgej ####

    } else if (canonical_stage == "bgej") {

      has_cols(c("bgfips", "ST", "pop"))
      check_bgfips()
      expected_ej <- c(
        if (exists("names_ej")) names_ej else character(),
        if (exists("names_ej_supp")) names_ej_supp else character(),
        if (exists("names_ej_state")) names_ej_state else character(),
        if (exists("names_ej_supp_state")) names_ej_supp_state else character()
      )
      warn_missing_cols(expected_ej)
      check_nonnegative(intersect(expected_ej, names(x)))
      ###################################################### #
      # ejscreen_export ####

    } else if (canonical_stage == "ejscreen_export") {

      check_id()
      warn_missing_cols(c("STATE_NAME", "ST_ABBREV", "CNTY_NAME", "REGION"))
      check_ejscreen_export_helpers()
      ###################################################### #
      # us_lookup_stages ####

    } else if (canonical_stage %in% us_lookup_stages) {

      check_lookup(expect_usa = TRUE)
      if (canonical_stage == "usastats_envirodata") {
        expected_env <- if (exists("names_e")) names_e else character()
        warn_missing_cols(expected_env)
      }
      ###################################################### #
      # state_lookup_stages ####

    } else if (canonical_stage %in% state_lookup_stages) {

      check_lookup(expect_usa = FALSE)
      if (canonical_stage == "statestats_envirodata") {
        expected_env <- if (exists("names_e")) names_e else character()
        warn_missing_cols(expected_env)
      }
    }
    ###################################################### #
  }

  if (length(warnings) > 0) {
    warning("Validation warnings for ", stage, ":\n- ", paste(warnings, collapse = "\n- "), call. = FALSE)
  }
  if (length(errors) > 0 && strict) {
    stop("Validation failed for ", stage, ":\n- ", paste(errors, collapse = "\n- "), call. = FALSE)
  }

  invisible(list(stage = stage, errors = errors, warnings = warnings))
}
###################################################### #
