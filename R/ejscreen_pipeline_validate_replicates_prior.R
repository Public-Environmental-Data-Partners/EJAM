#' Compare a new pipeline dataset to a prior version
#'
#' @details
#' This diagnostic helper is intended for annual EJSCREEN/EJAM data updates. It
#' compares a newly created table, such as `bg_acsdata`, `blockgroupstats`,
#' `usastats`, or `statestats`, with a prior or reference version of the same
#' table. It reports row/column count differences, column-name differences,
#' `bgfips` set/order differences when `bgfips` is available, metadata gaps in
#' [map_headernames], and value differences in shared columns.
#'
#' Differences are reported as warnings and in the returned object. They are not
#' fatal unless the inputs are invalid.
#'
#' @param new_dt data.frame or data.table created by the new pipeline.
#' @param old_dt prior or reference data.frame or data.table to compare against.
#' @param use_waldo logical. If TRUE and the `waldo` package is installed, also
#'   include `waldo::compare(old_dt, new_dt)` output in the returned object.
#' @param verbose logical. If TRUE, print a concise text summary.
#'
#' @return Invisibly returns a list with class
#'   `ejam_pipeline_prior_validation`.
#'
#' @keywords internal
#'
ejscreen_pipeline_validate_vs_prior <- function(new_dt,
                                                old_dt,
                                                use_waldo = FALSE,
                                                verbose = TRUE) {

  if (missing(new_dt)) {
    stop("must provide new_dt", call. = FALSE)
  }
  if (missing(old_dt)) {
    stop("must provide old_dt", call. = FALSE)
  }
  if (is.null(new_dt)) {
    stop("new_dt is NULL", call. = FALSE)
  }
  if (is.null(old_dt)) {
    stop("old_dt is NULL", call. = FALSE)
  }
  if (!is.data.frame(new_dt) || !is.data.frame(old_dt)) {
    stop("both must be at least data.frame class, and optionally can be data.table as well", call. = FALSE)
  }

  class_equal <- identical(class(new_dt), class(old_dt))
  if (!class_equal) {
    warning(
      "class(new_dt) and class(old_dt) are not the same: ",
      "new_dt is ", paste0(class(new_dt), collapse = ", "),
      " and old_dt is ", paste0(class(old_dt), collapse = ", "),
      call. = FALSE
    )
  }

  new_dt <- data.table::as.data.table(data.table::copy(new_dt))
  old_dt <- data.table::as.data.table(data.table::copy(old_dt))

  newnames <- names(new_dt)
  oldnames <- names(old_dt)
  sharednames <- intersect(newnames, oldnames)
  uniquely_new <- setdiff(newnames, oldnames)
  uniquely_old <- setdiff(oldnames, newnames)

  result <- list(
    row_count = c(new = NROW(new_dt), old = NROW(old_dt)),
    column_count = c(new = NCOL(new_dt), old = NCOL(old_dt)),
    class_equal = class_equal,
    columns = list(
      shared = sharednames,
      only_new = uniquely_new,
      only_old = uniquely_old
    ),
    metadata = list(
      not_in_map_headernames = character(),
      missing_varlist = character()
    ),
    bgfips = list(
      has_bgfips = all(c("bgfips") %in% names(new_dt)) && all(c("bgfips") %in% names(old_dt)),
      set_equal = NA,
      order_equal = NA
    ),
    shared_data_equal = NA,
    shared_data_difference = character(),
    missing_expected = data.frame(rname = character(), varlist = character(), stringsAsFactors = FALSE),
    not_replicated = data.frame(rname = character(), equal = logical(), problem = character(), stringsAsFactors = FALSE),
    waldo_compare = character()
  )
  class(result) <- c("ejam_pipeline_prior_validation", "list")

  if (verbose) {
    if (NROW(old_dt) == NROW(new_dt)) {
      cat("Row counts match, both have ", NROW(new_dt), "\n", sep = "")
    } else {
      cat("Row counts differ: new_dt has ", NROW(new_dt), " and old_dt has ", NROW(old_dt), "\n", sep = "")
    }
    if (NCOL(old_dt) == NCOL(new_dt)) {
      cat("Column counts match, both have ", NCOL(new_dt), "\n", sep = "")
    } else {
      cat("Column counts differ: new_dt has ", NCOL(new_dt), " and old_dt has ", NCOL(old_dt), "\n", sep = "")
    }
    cat(length(sharednames), " column names are shared by both\n", sep = "")
    cat(length(uniquely_old), " are unique to old", if (length(uniquely_old) > 0) paste0(": ", paste0(uniquely_old, collapse = ", ")) else "", "\n", sep = "")
    cat(length(uniquely_new), " are unique to new", if (length(uniquely_new) > 0) paste0(": ", paste0(uniquely_new, collapse = ", ")) else "", "\n", sep = "")
  }

  if (NROW(old_dt) != NROW(new_dt)) {
    warning("Row counts differ: new_dt has ", NROW(new_dt), " and old_dt has ", NROW(old_dt), call. = FALSE)
  }
  if (NCOL(old_dt) != NCOL(new_dt)) {
    warning("Column counts differ: new_dt has ", NCOL(new_dt), " and old_dt has ", NCOL(old_dt), call. = FALSE)
  }
  if (length(sharednames) == 0) {
    warning("zero column names are shared between new_dt and old_dt", call. = FALSE)
    return(invisible(result))
  }

  if (exists("map_headernames", inherits = TRUE)) {
    not_in_mh <- newnames[!(newnames %in% map_headernames$rname)]
    result$metadata$not_in_map_headernames <- not_in_mh
    if (length(not_in_mh) > 0) {
      warning("some columns in new_dt not found in map_headernames", call. = FALSE)
      if (verbose) {
        cat(
          "Columns in new_dt not found in map_headernames, so may need metadata: ",
          paste0(not_in_mh, collapse = ", "),
          "\n",
          sep = ""
        )
      }
    }

    varlists <- rep(NA_character_, length(newnames))
    if (exists("varinfo", inherits = TRUE)) {
      varlists <- suppressWarnings(varinfo(newnames)$varlist)
    }
    missing_varlist <- newnames[is.na(varlists)]
    result$metadata$missing_varlist <- missing_varlist
    if (length(missing_varlist) > 0) {
      warning("some columns in new_dt are not part of a varlist according to map_headernames", call. = FALSE)
      if (verbose) {
        cat(
          "Columns in new_dt missing varlist metadata: ",
          paste0(missing_varlist, collapse = ", "),
          "\n",
          sep = ""
        )
      }
    }
  } else {
    warning("map_headernames is unavailable, so metadata checks were skipped", call. = FALSE)
  }

  if (isTRUE(result$bgfips$has_bgfips)) {
    result$bgfips$set_equal <- setequal(old_dt$bgfips, new_dt$bgfips)
    bgfips_order_equal_result <- all.equal(old_dt$bgfips, new_dt$bgfips)
    result$bgfips$order_equal <- isTRUE(bgfips_order_equal_result)

    if (verbose) {
      cat("bgfips column found in each\n")
      cat("Are bgfips identical ignoring sort order? ", result$bgfips$set_equal, "\n", sep = "")
      cat("Are bgfips identical and in same order? ", if (result$bgfips$order_equal) "TRUE" else paste(bgfips_order_equal_result, collapse = "; "), "\n", sep = "")
    }
    if (!isTRUE(result$bgfips$set_equal)) {
      warning("different set of bgfips values in new_dt vs old_dt", call. = FALSE)
      return(invisible(result))
    }
    if (!isTRUE(result$bgfips$order_equal)) {
      warning("bgfips are not identical in same sort order in old_dt and new_dt, so value comparisons were skipped", call. = FALSE)
      return(invisible(result))
    }
  } else {
    warning("cannot confirm row alignment because one or both inputs lack a bgfips column", call. = FALSE)
  }

  shared_equal_result <- all.equal(old_dt[, ..sharednames], new_dt[, ..sharednames], check.attributes = FALSE)
  result$shared_data_equal <- isTRUE(shared_equal_result)
  if (!result$shared_data_equal) {
    result$shared_data_difference <- as.character(shared_equal_result)
    warning("data are not identical even for the shared column names", call. = FALSE)
  }
  if (verbose) {
    cat("Are the data identical in shared column names? ",
        if (result$shared_data_equal) "TRUE" else paste(result$shared_data_difference, collapse = "; "),
        "\n",
        sep = "")
  }

  notmade_names <- setdiff(oldnames, newnames)
  if (length(notmade_names) > 0) {
    vlistinfo <- rep(NA_character_, length(notmade_names))
    if (exists("varinfo", inherits = TRUE)) {
      vlistinfo <- suppressWarnings(varinfo(notmade_names)$varlist)
    }
    notmade <- data.frame(rname = notmade_names, varlist = vlistinfo, stringsAsFactors = FALSE)
    should_check <- grepl("names_d|names_countabove", notmade$varlist)
    should_check[is.na(should_check)] <- FALSE
    notmade <- notmade[should_check, , drop = FALSE]
    if (NROW(notmade) > 0 && exists("formulas_ejscreen_acs", inherits = TRUE)) {
      notmade$hasformula <- notmade$rname %in% formulas_ejscreen_acs$rname
    }
    result$missing_expected <- notmade[order(notmade$varlist, notmade$rname), , drop = FALSE]
    if (NROW(result$missing_expected) > 0) {
      warning("some expected columns are in old_dt but are not in new_dt", call. = FALSE)
      if (verbose) {
        cat(
          "Expected columns in old_dt that are not in new_dt: ",
          paste0(result$missing_expected$rname, collapse = ", "),
          "\n",
          sep = ""
        )
      }
    }
  }

  column_compare <- lapply(sharednames, function(namex) {
    comparison <- all.equal(new_dt[[namex]], old_dt[[namex]], check.attributes = FALSE)
    data.frame(
      rname = namex,
      equal = isTRUE(comparison),
      problem = if (isTRUE(comparison)) "" else paste(as.character(comparison), collapse = "; "),
      stringsAsFactors = FALSE
    )
  })
  notreplicated <- data.table::rbindlist(column_compare)
  notreplicated <- as.data.frame(notreplicated[!notreplicated$equal, , drop = FALSE])
  if (NROW(notreplicated) > 0 && exists("varinfo", inherits = TRUE)) {
    notreplicated$varlist <- suppressWarnings(varinfo(notreplicated$rname)$varlist)
    notreplicated <- notreplicated[order(notreplicated$varlist, notreplicated$rname), , drop = FALSE]
    notreplicated <- notreplicated[, c("varlist", "rname", "equal", "problem"), drop = FALSE]
  }
  result$not_replicated <- notreplicated
  if (NROW(result$not_replicated) > 0) {
    warning("some columns in old_dt do not exactly replicate in new_dt", call. = FALSE)
    if (verbose) {
      cat(
        "Columns in shared data that do not exactly replicate: ",
        paste0(result$not_replicated$rname, collapse = ", "),
        "\n",
        sep = ""
      )
    }
  }

  if (isTRUE(use_waldo)) {
    if (requireNamespace("waldo", quietly = TRUE)) {
      x <- try({result$waldo_compare <- waldo::compare(old_dt, new_dt)})
      if (inherits(x, "try-error")) {
        result$waldo_compare <- paste0("waldo::compare() failed with error: ", as.character(x))
        warning("waldo::compare() failed with error: ", as.character(x), call. = FALSE)
      }
    } else {
      result$waldo_compare <- "waldo package not available, so waldo::compare() was skipped"
    }
  }

  invisible(result)
}
###################################################### #

#' Summarize a prior-version pipeline validation result
#'
#' @param result object returned by `ejscreen_pipeline_validate_vs_prior()`.
#' @param stage pipeline stage name being compared.
#' @param path optional saved stage path.
#' @param old_label label for the prior/reference object.
#' @param warnings character vector of warnings captured while comparing.
#'
#' @return A one-row data.table suitable for a CSV validation summary.
#' @noRd
#'
ejscreen_pipeline_prior_validation_as_row <- function(result,
                                                      stage,
                                                      path = NA_character_,
                                                      old_label = NA_character_,
                                                      warnings = character()) {
  if (!inherits(result, "ejam_pipeline_prior_validation")) {
    stop("result must be from ejscreen_pipeline_validate_vs_prior()", call. = FALSE)
  }

  collapse_values <- function(x) {
    x <- as.character(x)
    x <- x[nzchar(x)]
    if (length(x) == 0) {
      return("")
    }
    paste(x, collapse = " | ")
  }
  collapse_rnames <- function(x) {
    if (is.null(x) || NROW(x) == 0 || !"rname" %in% names(x)) {
      return("")
    }
    collapse_values(x$rname)
  }

  data.table::data.table(
    stage = stage,
    path = path,
    old_label = old_label,
    rows_new = unname(result$row_count["new"]),
    rows_old = unname(result$row_count["old"]),
    columns_new = unname(result$column_count["new"]),
    columns_old = unname(result$column_count["old"]),
    class_equal = isTRUE(result$class_equal),
    shared_n = length(result$columns$shared),
    only_new_n = length(result$columns$only_new),
    only_old_n = length(result$columns$only_old),
    only_new = collapse_values(result$columns$only_new),
    only_old = collapse_values(result$columns$only_old),
    not_in_map_headernames_n = length(result$metadata$not_in_map_headernames),
    not_in_map_headernames = collapse_values(result$metadata$not_in_map_headernames),
    missing_varlist_n = length(result$metadata$missing_varlist),
    missing_varlist = collapse_values(result$metadata$missing_varlist),
    has_bgfips = isTRUE(result$bgfips$has_bgfips),
    bgfips_set_equal = result$bgfips$set_equal,
    bgfips_order_equal = result$bgfips$order_equal,
    shared_data_equal = result$shared_data_equal,
    missing_expected_n = NROW(result$missing_expected),
    missing_expected = collapse_rnames(result$missing_expected),
    not_replicated_n = NROW(result$not_replicated),
    not_replicated = collapse_rnames(result$not_replicated),
    warnings = collapse_values(warnings)
  )
}
###################################################### #

#' Format a prior-version pipeline validation result as text
#'
#' @inheritParams ejscreen_pipeline_prior_validation_as_row
#'
#' @return Character vector suitable for `writeLines()`.
#' @noRd
#'
ejscreen_pipeline_prior_validation_text <- function(result,
                                                    stage,
                                                    old_label = NA_character_,
                                                    warnings = character()) {
  if (!inherits(result, "ejam_pipeline_prior_validation")) {
    stop("result must be from ejscreen_pipeline_validate_vs_prior()", call. = FALSE)
  }

  add_table <- function(label, x) {
    if (is.null(x) || NROW(x) == 0) {
      return(c(label, "  none"))
    }
    c(label, utils::capture.output(print(as.data.frame(x), row.names = FALSE)))
  }
  collapse_values <- function(x) {
    x <- as.character(x)
    x <- x[nzchar(x)]
    if (length(x) == 0) {
      return("none")
    }
    paste(x, collapse = ", ")
  }

  c(
    paste0("Prior-version validation for stage: ", stage),
    paste0("Reference object: ", old_label),
    paste0("Created: ", Sys.time()),
    "",
    paste0("Rows: new=", unname(result$row_count["new"]), ", old=", unname(result$row_count["old"])),
    paste0("Columns: new=", unname(result$column_count["new"]), ", old=", unname(result$column_count["old"])),
    paste0("Class equal: ", isTRUE(result$class_equal)),
    paste0("Shared columns: ", length(result$columns$shared)),
    paste0("Only in new: ", collapse_values(result$columns$only_new)),
    paste0("Only in old: ", collapse_values(result$columns$only_old)),
    "",
    paste0("Has bgfips in both: ", isTRUE(result$bgfips$has_bgfips)),
    paste0("bgfips set equal: ", result$bgfips$set_equal),
    paste0("bgfips order equal: ", result$bgfips$order_equal),
    paste0("Shared data equal: ", result$shared_data_equal),
    "",
    paste0("Columns not in map_headernames: ", collapse_values(result$metadata$not_in_map_headernames)),
    paste0("Columns missing varlist metadata: ", collapse_values(result$metadata$missing_varlist)),
    "",
    add_table("Missing expected columns:", result$missing_expected),
    "",
    add_table("Not replicated columns:", result$not_replicated),
    "",
    paste0("Warnings: ", collapse_values(warnings)),
    "",
    if (length(result$waldo_compare) > 0) {
      c("waldo_compare:", result$waldo_compare)
    } else {
      "waldo_compare: not requested"
    }
  )
}
###################################################### #
