map_headernames_review_artifact_dir <- function(date = Sys.Date()) {
  env_dir <- Sys.getenv("EJAM_MAP_HEADERNAMES_AUDIT_DIR", unset = "")
  if (nzchar(env_dir)) {
    return(env_dir)
  }
  file.path(tempdir(), paste0("map_headernames_review_artifacts_", format(date, "%Y-%m-%d")))
}

datacreate_map_headernames_review_artifacts <- function(
    current_csv = file.path("data-raw", "map_headernames.csv"),
    old_csv = NULL,
    rda_path = file.path("data", "map_headernames.rda"),
    output_dir = map_headernames_review_artifact_dir(),
    write_redline_xlsx = !is.null(old_csv),
    quiet = FALSE) {

  current <- read_map_headernames_audit_csv(current_csv)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  files <- list(
    summary = file.path(output_dir, "map_headernames_audit_summary.md"),
    duplicates = file.path(output_dir, "map_headernames_duplicate_rnames.csv"),
    sparse_columns = file.path(output_dir, "map_headernames_sparse_columns.csv"),
    column_usage = file.path(output_dir, "map_headernames_column_usage.csv"),
    varlist_counts = file.path(output_dir, "map_headernames_varlist_counts.csv"),
    required_rows = file.path(output_dir, "map_headernames_required_ejscreen_rows.csv"),
    left_side_gaps = file.path(output_dir, "map_headernames_left_side_metadata_gaps.csv"),
    consistency_flags = file.path(output_dir, "map_headernames_consistency_flags.csv"),
    column_classification = file.path(output_dir, "map_headernames_column_classification.csv"),
    row_counts = file.path(output_dir, "map_headernames_counts.csv"),
    csv_rda_comparison = file.path(output_dir, "map_headernames_csv_rda_comparison.csv")
  )

  duplicates <- map_headernames_duplicate_rnames(current)
  sparse_columns <- map_headernames_sparse_columns(current)
  column_usage <- map_headernames_column_usage(names(current))
  varlist_counts <- map_headernames_varlist_counts(current)
  required_rows <- map_headernames_required_rows(current)
  left_side_gaps <- map_headernames_left_side_gaps(current)
  consistency_flags <- map_headernames_consistency_flags(current)
  column_classification <- map_headernames_column_classification(names(current))
  row_counts <- map_headernames_row_counts(current, required_rows)
  csv_rda_comparison <- map_headernames_csv_rda_comparison(current, rda_path)

  write_audit_csv(duplicates, files$duplicates)
  write_audit_csv(sparse_columns, files$sparse_columns)
  write_audit_csv(column_usage, files$column_usage)
  write_audit_csv(varlist_counts, files$varlist_counts)
  write_audit_csv(required_rows, files$required_rows)
  write_audit_csv(left_side_gaps, files$left_side_gaps)
  write_audit_csv(consistency_flags, files$consistency_flags)
  write_audit_csv(column_classification, files$column_classification)
  write_audit_csv(row_counts, files$row_counts)
  write_audit_csv(csv_rda_comparison, files$csv_rda_comparison)

  if (!is.null(old_csv)) {
    old <- read_map_headernames_audit_csv(old_csv)
    redline <- map_headernames_redline_tables(old, current)
    files$cell_changes <- file.path(output_dir, "map_headernames_cell_changes.csv")
    write_audit_csv(redline$cell_changes, files$cell_changes)
    if (isTRUE(write_redline_xlsx)) {
      files$redline_xlsx <- file.path(output_dir, "map_headernames_redline.xlsx")
      write_map_headernames_redline_xlsx(redline, files$redline_xlsx)
    }
  } else {
    files$cell_changes <- NA_character_
    files$redline_xlsx <- NA_character_
  }

  write_map_headernames_audit_summary(
    file = files$summary,
    current_csv = current_csv,
    output_dir = output_dir,
    row_counts = row_counts,
    csv_rda_comparison = csv_rda_comparison,
    files = files
  )

  if (!isTRUE(quiet)) {
    message("Wrote map_headernames review artifacts to: ", normalizePath(output_dir, mustWork = FALSE))
  }

  invisible(list(output_dir = output_dir, files = files))
}

read_map_headernames_audit_csv <- function(path) {
  if (is.null(path) || length(path) != 1 || !nzchar(path) || !file.exists(path)) {
    stop("Cannot find map_headernames CSV: ", path, call. = FALSE)
  }
  x <- utils::read.csv(
    path,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = c(""),
    colClasses = "character"
  )
  x[is.na(x)] <- ""
  x
}

write_audit_csv <- function(x, path) {
  utils::write.csv(as.data.frame(x, stringsAsFactors = FALSE), path, row.names = FALSE, na = "")
  invisible(path)
}

is_blank_audit_value <- function(x) {
  is.na(x) | !nzchar(trimws(as.character(x)))
}

map_headernames_duplicate_rnames <- function(mh) {
  if (!"rname" %in% names(mh)) {
    return(data.frame())
  }
  out <- mh[duplicated(mh$rname) | duplicated(mh$rname, fromLast = TRUE), , drop = FALSE]
  out[order(out$rname), , drop = FALSE]
}

map_headernames_sparse_columns <- function(mh) {
  data.frame(
    column = names(mh),
    nonblank_n = vapply(mh, function(x) sum(!is_blank_audit_value(x)), integer(1)),
    blank_n = vapply(mh, function(x) sum(is_blank_audit_value(x)), integer(1)),
    blank_pct = round(vapply(mh, function(x) mean(is_blank_audit_value(x)), numeric(1)) * 100, 1),
    stringsAsFactors = FALSE
  )
}

map_headernames_column_usage <- function(columns) {
  paths <- c("R", "data-raw", "tests", "vignettes", "man")
  paths <- paths[dir.exists(paths)]
  has_rg <- nzchar(Sys.which("rg"))

  counts <- vapply(columns, function(col) {
    if (!has_rg || length(paths) == 0) {
      return(NA_integer_)
    }
    args <- c(
      "--fixed-strings", "--count-matches",
      "--glob", "!data-raw/map_headernames.csv",
      "--glob", "!data/map_headernames.rda",
      col,
      paths
    )
    out <- suppressWarnings(system2("rg", args, stdout = TRUE, stderr = FALSE))
    if (!length(out)) {
      return(0L)
    }
    sum(as.integer(sub("^.*:([0-9]+)$", "\\1", out)), na.rm = TRUE)
  }, integer(1))

  data.frame(column = columns, rg_match_count = counts, stringsAsFactors = FALSE)
}

map_headernames_varlist_counts <- function(mh) {
  if (!"varlist" %in% names(mh)) {
    return(data.frame())
  }
  x <- data.frame(varlist = mh$varlist, stringsAsFactors = FALSE)
  out <- as.data.frame(table(x$varlist), stringsAsFactors = FALSE)
  names(out) <- c("varlist", "row_n")
  out[order(out$varlist), , drop = FALSE]
}

map_headernames_required_rows <- function(mh) {
  required <- c(
    "bgfips", "OBJECTID", "EXCEED_COUNT_90", "EXCEED_COUNT_90_SUP",
    "SYMBOLOGY_EXCEED_COUNT_80", "Shape__Area", "Shape__Length"
  )
  found <- if ("rname" %in% names(mh)) required %in% mh$rname else rep(FALSE, length(required))
  data.frame(rname = required, present = found, stringsAsFactors = FALSE)
}

map_headernames_left_side_gaps <- function(mh) {
  cols <- intersect(
    c("rname", "longname", "shortlabel", "varlist", "vartype", "varcategory",
      "calculation_type", "denominator"),
    names(mh)
  )
  if (!length(cols)) {
    return(data.frame())
  }
  missing <- apply(mh[, cols, drop = FALSE], 1, function(row) {
    paste(cols[is_blank_audit_value(row)], collapse = "; ")
  })
  keep <- nzchar(missing)
  data.frame(
    row = which(keep),
    rname = if ("rname" %in% names(mh)) mh$rname[keep] else "",
    missing_fields = missing[keep],
    stringsAsFactors = FALSE
  )
}

map_headernames_consistency_flags <- function(mh) {
  out <- list()
  add_flags <- function(flag, rows) {
    if (length(rows)) {
      out[[length(out) + 1L]] <<- data.frame(
        flag = flag,
        row = rows,
        rname = if ("rname" %in% names(mh)) mh$rname[rows] else "",
        stringsAsFactors = FALSE
      )
    }
  }

  flag_cols <- intersect(c("percentage", "pct_as_fraction_ejamit",
                           "pct_as_fraction_blockgroupstats",
                           "pct_as_fraction_ejscreenit"), names(mh))
  for (col in flag_cols) {
    x <- trimws(as.character(mh[[col]]))
    ok <- is_blank_audit_value(x) | tolower(x) %in% c("0", "1", "false", "true", "f", "t", "no", "yes", "n", "y")
    add_flags(paste0(col, "_nonflag_value"), which(!ok))
  }

  if (all(c("calculation_type", "denominator") %in% names(mh))) {
    add_flags(
      "wtdmean_blank_denominator",
      which(tolower(mh$calculation_type) == "wtdmean" & is_blank_audit_value(mh$denominator))
    )
  }
  if ("shortlabel" %in% names(mh)) {
    add_flags("shortlabel_language_word", grep("\\blanguage\\b", mh$shortlabel, ignore.case = TRUE))
    add_flags("shortlabel_speak_spacing", grep("%speak|% speaking", mh$shortlabel, ignore.case = TRUE))
    add_flags("shortlabel_at_home", grep("\\bat home\\b", mh$shortlabel, ignore.case = TRUE))
  }
  if ("longname" %in% names(mh)) {
    add_flags("longname_avg_abbreviation", grep("\\bavg\\b", mh$longname, ignore.case = TRUE))
  }

  if (!length(out)) {
    return(data.frame())
  }
  do.call(rbind, out)
}

map_headernames_column_classification <- function(columns) {
  legacy <- c("names_friendly", "csv_example", "api_example", "csv_description",
              "csv_descriptions_name", "oldname_is_what", "agree", "errornote")
  public <- c("rname", "longname", "shortlabel", "varlist", "varcategory",
              "vartype", "calculation_type", "denominator", "units", "decimals",
              "percentage")
  export <- c("csvname", "acsname", "ejscreen_indicator", "ejscreen_ftp_names",
              "ejscreen_apinames_old", "ejam_apinames", "pctile.", "bin.", "text.")
  sort_display <- c("n", "newsort", "sort_by_varlist", "sort_within_varlist",
                    "ejscreensort", "reportsort")

  category <- rep("unclassified", length(columns))
  category[columns %in% public] <- "public metadata"
  category[columns %in% export] <- "export/schema metadata"
  category[columns %in% sort_display] <- "sort/display metadata"
  category[grepl("^pct_as_fraction", columns)] <- "percentage display metadata"
  category[columns %in% legacy] <- "legacy cleanup candidate"

  data.frame(column = columns, classification = category, stringsAsFactors = FALSE)
}

map_headernames_row_counts <- function(mh, required_rows) {
  dup_values <- if ("rname" %in% names(mh)) unique(mh$rname[duplicated(mh$rname)]) else character()
  data.frame(
    metric = c(
      "rows", "columns", "duplicate_rname_values", "duplicate_rname_rows",
      "varlist_values", "required_rows_present", "required_rows_missing"
    ),
    value = c(
      nrow(mh),
      ncol(mh),
      length(dup_values),
      if ("rname" %in% names(mh)) sum(duplicated(mh$rname) | duplicated(mh$rname, fromLast = TRUE)) else NA_integer_,
      if ("varlist" %in% names(mh)) length(unique(mh$varlist)) else NA_integer_,
      sum(required_rows$present),
      sum(!required_rows$present)
    ),
    stringsAsFactors = FALSE
  )
}

map_headernames_csv_rda_comparison <- function(current, rda_path) {
  if (is.null(rda_path) || !file.exists(rda_path)) {
    return(data.frame(metric = "rda_found", value = "FALSE", stringsAsFactors = FALSE))
  }
  env <- new.env(parent = emptyenv())
  loaded <- load(rda_path, envir = env)
  object_name <- if ("map_headernames" %in% loaded) "map_headernames" else loaded[[1]]
  rda <- as.data.frame(env[[object_name]], stringsAsFactors = FALSE, check.names = FALSE)
  rda[is.na(rda)] <- ""

  common <- intersect(names(current), names(rda))
  cell_diffs <- NA_integer_
  if (identical(names(current), names(rda)) && nrow(current) == nrow(rda)) {
    cell_diffs <- sum(vapply(common, function(col) {
      sum(as.character(current[[col]]) != as.character(rda[[col]]))
    }, integer(1)))
  }

  data.frame(
    metric = c("rda_found", "object_name", "same_columns", "same_row_count", "cell_differences_when_aligned"),
    value = c(
      "TRUE",
      object_name,
      as.character(identical(names(current), names(rda))),
      as.character(nrow(current) == nrow(rda)),
      as.character(cell_diffs)
    ),
    stringsAsFactors = FALSE
  )
}

map_headernames_redline_tables <- function(old, new) {
  old_keyed <- add_map_headernames_row_key(old)
  new_keyed <- add_map_headernames_row_key(new)
  all_cols <- union(names(old_keyed), names(new_keyed))
  old_keyed <- fill_missing_columns(old_keyed, all_cols)
  new_keyed <- fill_missing_columns(new_keyed, all_cols)

  old_keys <- old_keyed$.row_key
  new_keys <- new_keyed$.row_key
  common <- intersect(old_keys, new_keys)
  added <- setdiff(new_keys, old_keys)
  removed <- setdiff(old_keys, new_keys)

  changed <- common[vapply(common, function(key) {
    old_row <- old_keyed[old_keyed$.row_key == key, all_cols, drop = FALSE]
    new_row <- new_keyed[new_keyed$.row_key == key, all_cols, drop = FALSE]
    any(as.character(old_row) != as.character(new_row))
  }, logical(1))]

  redline <- rbind(
    redline_rows(old_keyed, removed, "removed", all_cols),
    redline_rows(old_keyed, changed, "changed_old", all_cols),
    redline_rows(new_keyed, changed, "changed_new", all_cols),
    redline_rows(new_keyed, added, "added", all_cols)
  )

  cell_changes <- do.call(rbind, lapply(changed, function(key) {
    old_row <- old_keyed[old_keyed$.row_key == key, all_cols, drop = FALSE]
    new_row <- new_keyed[new_keyed$.row_key == key, all_cols, drop = FALSE]
    changed_cols <- all_cols[as.character(old_row[1, all_cols]) != as.character(new_row[1, all_cols])]
    data.frame(
      row_key = key,
      column = changed_cols,
      old_value = as.character(old_row[1, changed_cols]),
      new_value = as.character(new_row[1, changed_cols]),
      stringsAsFactors = FALSE
    )
  }))
  if (is.null(cell_changes)) {
    cell_changes <- data.frame(row_key = character(), column = character(),
                               old_value = character(), new_value = character())
  }

  list(redline = redline, cell_changes = cell_changes)
}

add_map_headernames_row_key <- function(x) {
  x <- as.data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
  if (!"rname" %in% names(x)) {
    x$rname <- paste0("row_", seq_len(nrow(x)))
  }
  occurrence <- ave(seq_len(nrow(x)), x$rname, FUN = seq_along)
  x$.row_key <- paste0(x$rname, "__", occurrence)
  x
}

fill_missing_columns <- function(x, columns) {
  missing <- setdiff(columns, names(x))
  for (col in missing) {
    x[[col]] <- ""
  }
  x[, columns, drop = FALSE]
}

redline_rows <- function(x, keys, change_type, columns) {
  if (!length(keys)) {
    out <- x[FALSE, columns, drop = FALSE]
  } else {
    out <- x[match(keys, x$.row_key), columns, drop = FALSE]
  }
  data.frame(
    change_type = rep(change_type, nrow(out)),
    out,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

write_map_headernames_redline_xlsx <- function(redline, path) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("openxlsx is required to write the redline workbook", call. = FALSE)
  }
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "redline")
  openxlsx::addWorksheet(wb, "cell_changes")
  openxlsx::writeData(wb, "redline", redline$redline)
  openxlsx::writeData(wb, "cell_changes", redline$cell_changes)

  old_rows <- which(redline$redline$change_type %in% c("removed", "changed_old")) + 1L
  new_rows <- which(redline$redline$change_type %in% c("added", "changed_new")) + 1L
  if (length(old_rows)) {
    old_style <- openxlsx::createStyle(fgFill = "#F4CCCC", textDecoration = "strikeout")
    openxlsx::addStyle(wb, "redline", old_style, rows = old_rows,
                       cols = seq_len(ncol(redline$redline)), gridExpand = TRUE, stack = TRUE)
  }
  if (length(new_rows)) {
    new_style <- openxlsx::createStyle(fgFill = "#D9EAD3")
    openxlsx::addStyle(wb, "redline", new_style, rows = new_rows,
                       cols = seq_len(ncol(redline$redline)), gridExpand = TRUE, stack = TRUE)
  }
  openxlsx::freezePane(wb, "redline", firstRow = TRUE, firstCol = TRUE)
  openxlsx::freezePane(wb, "cell_changes", firstRow = TRUE, firstCol = TRUE)
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}

write_map_headernames_audit_summary <- function(file, current_csv, output_dir,
                                                row_counts, csv_rda_comparison,
                                                files) {
  lines <- c(
    "# map_headernames Review Artifacts",
    "",
    paste0("- Current CSV: `", current_csv, "`"),
    paste0("- Output directory: `", output_dir, "`"),
    "",
    "## Counts",
    "",
    paste0("- ", row_counts$metric, ": ", row_counts$value),
    "",
    "## CSV vs RDA",
    "",
    paste0("- ", csv_rda_comparison$metric, ": ", csv_rda_comparison$value),
    "",
    "## Files",
    "",
    paste0("- ", names(files), ": `", unlist(files, use.names = FALSE), "`")
  )
  writeLines(lines, file)
  invisible(file)
}

if (identical(environment(), globalenv()) &&
    !isTRUE(getOption("map_headernames_review_artifacts.suppress_autorun", FALSE))) {
  datacreate_map_headernames_review_artifacts()
}
