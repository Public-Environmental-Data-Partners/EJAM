#' Report consistency of dynamic geography Arrow datasets
#'
#' Checks the blockgroup- and block-level Arrow datasets that support proximity
#' analysis against a reference blockgroup universe. This is used during the
#' annual EJSCREEN data update to decide whether geography-coupled Arrow files
#' are still compatible with the current `blockgroupstats` data.
#'
#' @param folder_local_source folder containing `.arrow` files. Defaults to the
#'   installed EJAM package data folder.
#' @param blockgroupstats_ref optional data frame with at least `bgfips`; if
#'   omitted, the currently available package `blockgroupstats` is used.
#' @param datasets dynamic geography Arrow dataset names to check.
#' @param silent if `FALSE`, print the report.
#'
#' @return A data frame with one row per checked dataset and counts of missing
#'   or extra geography keys.
#'
#' @keywords internal
dynamic_geography_arrow_report <- function(
    folder_local_source = NULL,
    blockgroupstats_ref = NULL,
    datasets = c("bgid2fips", "blockwts", "blockpoints", "quaddata", "blockid2fips"),
    silent = TRUE
) {
  if (is.null(folder_local_source)) {
    folder_local_source <- app_sys("data")
  }
  datasets <- unique(datasets)

  allowed <- c("bgid2fips", "blockwts", "blockpoints", "quaddata", "blockid2fips")
  unknown <- setdiff(datasets, allowed)
  if (length(unknown) > 0) {
    stop("Unknown dynamic geography Arrow dataset(s): ", paste(unknown, collapse = ", "))
  }

  required_cols <- list(
    bgid2fips = c("bgid", "bgfips"),
    blockwts = c("blockid", "bgid", "blockwt", "block_radius_miles"),
    blockpoints = c("blockid", "lat", "lon"),
    quaddata = c("BLOCK_X", "BLOCK_Z", "BLOCK_Y", "blockid"),
    blockid2fips = c("blockid", "blockfips")
  )

  if (is.null(blockgroupstats_ref)) {
    blockgroupstats_ref <- dynamic_geography_blockgroupstats_ref()
  }
  ref_bgfips <- if (!is.null(blockgroupstats_ref) &&
                    "bgfips" %in% names(blockgroupstats_ref)) {
    unique(as.character(blockgroupstats_ref$bgfips))
  } else {
    character(0)
  }

  loaded <- list()
  base_report <- lapply(datasets, function(dataset) {
    fpath <- file.path(folder_local_source, paste0(dataset, ".arrow"))
    file_exists <- file.exists(fpath)
    read_error <- NA_character_
    n_rows <- NA_integer_
    n_cols <- NA_integer_
    has_required_columns <- FALSE

    if (file_exists) {
      x <- tryCatch(
        suppressWarnings(arrow::read_feather(fpath)),
        error = function(e) {
          read_error <<- conditionMessage(e)
          NULL
        }
      )
      if (!is.null(x)) {
        loaded[[dataset]] <<- as.data.frame(x)
        n_rows <- nrow(x)
        n_cols <- ncol(x)
        has_required_columns <- all(required_cols[[dataset]] %in% names(x))
      }
    }

    data.frame(
      dataset = dataset,
      update_group = unname(dynamic_data_group(dataset)),
      file = fpath,
      file_exists = file_exists,
      nrow = n_rows,
      ncol = n_cols,
      has_required_columns = has_required_columns,
      missing_bgfips_n = NA_integer_,
      extra_bgfips_n = NA_integer_,
      missing_bgid_n = NA_integer_,
      extra_bgid_n = NA_integer_,
      missing_blockid_n = NA_integer_,
      extra_blockid_n = NA_integer_,
      ok = file_exists && has_required_columns && is.na(read_error),
      note = if (is.na(read_error)) "" else read_error,
      stringsAsFactors = FALSE
    )
  })
  report <- do.call(rbind, base_report)

  if ("bgid2fips" %in% names(loaded) &&
      all(c("bgid", "bgfips") %in% names(loaded$bgid2fips)) &&
      length(ref_bgfips) > 0) {
    bgid2fips_bgfips <- unique(as.character(loaded$bgid2fips$bgfips))
    missing_bgfips <- setdiff(ref_bgfips, bgid2fips_bgfips)
    extra_bgfips <- setdiff(bgid2fips_bgfips, ref_bgfips)
    i <- report$dataset == "bgid2fips"
    report$missing_bgfips_n[i] <- length(missing_bgfips)
    report$extra_bgfips_n[i] <- length(extra_bgfips)
    report$ok[i] <- report$ok[i] && length(missing_bgfips) == 0
    if (length(extra_bgfips) > 0) {
      report$note[i] <- paste(
        trimws(report$note[i]),
        paste0(length(extra_bgfips), " bgfips values are not in blockgroupstats_ref.")
      )
    }
  }

  if ("blockwts" %in% names(loaded) &&
      "bgid2fips" %in% names(loaded) &&
      all(c("bgid", "bgfips") %in% names(loaded$bgid2fips)) &&
      "bgid" %in% names(loaded$blockwts) &&
      length(ref_bgfips) > 0) {
    needed_bgids <- unique(as.character(
      loaded$bgid2fips$bgid[as.character(loaded$bgid2fips$bgfips) %in% ref_bgfips]
    ))
    blockwts_bgids <- unique(as.character(loaded$blockwts$bgid))
    missing_bgids <- setdiff(needed_bgids, blockwts_bgids)
    extra_bgids <- setdiff(blockwts_bgids, needed_bgids)
    i <- report$dataset == "blockwts"
    report$missing_bgid_n[i] <- length(missing_bgids)
    report$extra_bgid_n[i] <- length(extra_bgids)
    report$ok[i] <- report$ok[i] && length(missing_bgids) == 0
  }

  if ("blockwts" %in% names(loaded) && "blockid" %in% names(loaded$blockwts)) {
    needed_blockids <- unique(as.character(loaded$blockwts$blockid))
    for (dataset in intersect(c("blockpoints", "quaddata", "blockid2fips"), names(loaded))) {
      if (!"blockid" %in% names(loaded[[dataset]])) {
        next
      }
      dataset_blockids <- unique(as.character(loaded[[dataset]]$blockid))
      missing_blockids <- setdiff(needed_blockids, dataset_blockids)
      extra_blockids <- setdiff(dataset_blockids, needed_blockids)
      i <- report$dataset == dataset
      report$missing_blockid_n[i] <- length(missing_blockids)
      report$extra_blockid_n[i] <- length(extra_blockids)
      report$ok[i] <- report$ok[i] && length(missing_blockids) == 0
    }
  }

  if (!silent) {
    print(report)
  }
  report
}

#' @keywords internal
#' @rdname dynamic_geography_arrow_report
dynamic_geography_blockgroupstats_ref <- function() {
  if ("package:EJAM" %in% search() &&
      exists("blockgroupstats", envir = as.environment("package:EJAM"), inherits = FALSE)) {
    return(get("blockgroupstats", envir = as.environment("package:EJAM"), inherits = FALSE))
  }

  tmp <- new.env(parent = emptyenv())
  loaded <- try(utils::data("blockgroupstats", package = "EJAM", envir = tmp), silent = TRUE)
  if (!inherits(loaded, "try-error") &&
      exists("blockgroupstats", envir = tmp, inherits = FALSE)) {
    return(get("blockgroupstats", envir = tmp, inherits = FALSE))
  }

  NULL
}
