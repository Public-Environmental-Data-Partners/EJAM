###################################################### #

#' Download raw ACS tables for the blockgroup ACS pipeline
#'
#' @details This creates the raw ACS checkpoint for the annual EJSCREEN/EJAM
#' data update pipeline. It downloads the Census Bureau ACS table-based summary
#' file tables with `ACSdownload::get_acs_new()`. By default, the saved
#' checkpoint uses a folder-plus-manifest layout: one file per ACS table in
#' `bg_acs_raw/blockgroup/` and `bg_acs_raw/tract/`, plus manifest files that
#' describe the checkpoint. That is easier to inspect and extend than one large
#' list object, while still being loadable as the same `ejam_bg_acs_raw` list
#' object used by downstream functions.
#'
#' This stage is deliberately before EJAM formula calculations. The downloaded
#' tables are the parsed ACSdownload output, including Census table columns,
#' `GEO_ID`, `fips`, and `SUMLEVEL`.
#'
#' @param yr end year of the ACS 5-year survey to use.
#' @param blockgroup_tables ACS tables to download at blockgroup resolution.
#' @param tract_tables ACS tables to download at tract resolution for later
#'   blockgroup apportionment.
#' @param include_tract_data logical, whether to download `tract_tables`.
#' @param fiveorone ACS sample length, `"5"` by default.
#' @param pipeline_dir folder for saving the pipeline stage.
#' @param save_stage logical, whether to save the `bg_acs_raw` stage.
#' @param stage_format file format for saved object stages: `"rds"`, `"rda"`,
#'   `"csv"`, or `"arrow"`. Raw ACS folder checkpoints use
#'   `raw_table_format` for the per-table files.
#' @param raw_acs_storage raw ACS checkpoint storage pattern. `"folder"` saves
#'   one ACS table per file plus a manifest. `"object"` saves the historical
#'   single `bg_acs_raw` list object.
#' @param raw_table_format file format for per-table raw ACS files when
#'   `raw_acs_storage = "folder"`.
#' @param overwrite logical, whether to overwrite an existing saved stage.
#' @param validation_strict logical passed to [ejscreen_pipeline_save()].
#' @param storage raw ACS checkpoint storage backend: `"auto"`, `"local"`, or
#'   `"s3"`.
#' @param download_fun ACSdownload-compatible function used to obtain a single
#'   ACS table for a given `yr`, `tables`, `fips`, and `fiveorone`. Defaults to
#'   [ACSdownload::get_acs_new()]. Supply a wrapper if you need to pin a legacy
#'   ACS source implementation.
#' @param download_timeout timeout in seconds to use while downloading ACS
#'   table files. This is increased above R's usual 60 second default because
#'   some Census table-based summary files are hundreds of MB.
#' @param download_retries number of times to retry a failed ACS table download
#'   after the initial attempt.
#'
#' @return list with raw `blockgroup` and `tract` ACS table lists plus metadata.
#'
#' @export
#' @keywords internal
#'
download_bg_acs_raw <- function(yr,
                                blockgroup_tables = setdiff(as.vector(EJAM::tables_ejscreen_acs), tract_tables),
                                tract_tables = c("B18101", "C16001"),
                                include_tract_data = TRUE,
                                fiveorone = "5",
                                pipeline_dir = NULL,
                                save_stage = FALSE,
                                stage_format = c("csv", "rds", "rda", "arrow"),
                                raw_acs_storage = c("folder", "object"),
                                raw_table_format = stage_format,
                                overwrite = TRUE,
                                validation_strict = TRUE,
                                storage = c("auto", "local", "s3"),
                                download_fun = ACSdownload::get_acs_new,
                                download_timeout = 3600,
                                download_retries = 2) {
  stage_format <- match.arg(stage_format)
  raw_acs_storage <- match.arg(raw_acs_storage)
  raw_table_format <- match.arg(raw_table_format, c("rds", "rda", "csv", "arrow"))
  storage <- match.arg(storage)

  if (missing(yr)) {
    yr <- acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)
  }

  download_fun_label <- paste(deparse(substitute(download_fun)), collapse = " ")
  download_fun <- match.fun(download_fun)

  blockgroup_tables <- unique(as.vector(blockgroup_tables))
  tract_tables <- unique(as.vector(tract_tables))

  blockgroup <- download_acs_raw_tables(
    yr = yr,
    tables = blockgroup_tables,
    fips = "blockgroup",
    fiveorone = fiveorone,
    download_fun = download_fun,
    download_timeout = download_timeout,
    download_retries = download_retries
  )
  tract <- list()
  if (include_tract_data && length(tract_tables) > 0) {
    tract <- download_acs_raw_tables(
      yr = yr,
      tables = tract_tables,
      fips = "tract",
      fiveorone = fiveorone,
      download_fun = download_fun,
      download_timeout = download_timeout,
      download_retries = download_retries
    )
  }

  out <- list(
    stage = "bg_acs_raw",
    yr = yr,
    fiveorone = as.character(fiveorone),
    downloaded_at = as.character(Sys.time()),
    source = paste0("Census Bureau ACS table-based summary files via ", download_fun_label, "()"),
    download_fun = download_fun_label,
    raw_acs_storage = raw_acs_storage,
    blockgroup_tables = blockgroup_tables,
    tract_tables = if (include_tract_data) tract_tables else character(),
    blockgroup = blockgroup,
    tract = tract
  )
  class(out) <- c("ejam_bg_acs_raw", class(out))

  if (save_stage) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stage is TRUE")
    }
    if (raw_acs_storage == "folder") {
      saved_path <- save_bg_acs_raw_folder(
        out,
        pipeline_dir = pipeline_dir,
        table_format = raw_table_format,
        overwrite = overwrite,
        validation_strict = validation_strict,
        storage = storage
      )
    } else {
      saved_path <- ejscreen_pipeline_save(
        out,
        stage = "bg_acs_raw",
        pipeline_dir = pipeline_dir,
        format = stage_format,
        overwrite = overwrite,
        validation_strict = validation_strict,
        storage = storage
      )
    }
    attr(out, "saved_stage_path") <- saved_path
  } else {
    ejscreen_pipeline_validate(out, stage = "bg_acs_raw", strict = validation_strict)
  }

  out
}

download_acs_raw_tables <- function(yr,
                                    tables,
                                    fips,
                                    fiveorone = "5",
                                    download_fun = ACSdownload::get_acs_new,
                                    download_timeout = 3600,
                                    download_retries = 2) {
  if (!requireNamespace("ACSdownload", quietly = TRUE)) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload and documented at https://ejanalysis.github.io/ACSdownload/")
  }
  if (!is.numeric(download_timeout) || length(download_timeout) != 1 || is.na(download_timeout) || download_timeout <= 0) {
    stop("download_timeout must be a single positive number of seconds")
  }
  if (!is.numeric(download_retries) || length(download_retries) != 1 || is.na(download_retries) || download_retries < 0) {
    stop("download_retries must be a single non-negative number")
  }

  old_timeout <- getOption("timeout")
  new_timeout <- max(as.numeric(old_timeout), download_timeout, na.rm = TRUE)
  options(timeout = new_timeout)
  on.exit(options(timeout = old_timeout), add = TRUE)

  tables <- unique(toupper(as.vector(tables)))
  download_fun <- match.fun(download_fun)
  out <- vector("list", length(tables))
  names(out) <- toupper(tables)

  for (table in tables) {
    out[[table]] <- download_acs_raw_table_with_retry(
      yr = yr,
      table = table,
      fips = fips,
      fiveorone = fiveorone,
      download_fun = download_fun,
      download_retries = download_retries
    )
  }

  out
}

download_acs_raw_table_with_retry <- function(yr,
                                              table,
                                              fips,
                                              fiveorone = "5",
                                              download_fun = ACSdownload::get_acs_new,
                                              download_retries = 2) {
  table_name <- toupper(table)
  download_fun <- match.fun(download_fun)
  last_error <- NULL
  attempts <- seq_len(as.integer(download_retries) + 1L)

  for (attempt in attempts) {
    if (attempt > 1L) {
      message(
        "Retrying ACS table ", table_name, " for ", fips,
        " (attempt ", attempt, " of ", length(attempts), ")"
      )
    }

    result <- tryCatch(
      download_fun(
        yr = yr,
        tables = table,
        fips = fips,
        fiveorone = fiveorone,
        return_list_not_merged = TRUE
      ),
      error = function(e) {
        last_error <<- e
        NULL
      }
    )

    if (!is.null(result)) {
      if (!table_name %in% names(result)) {
        stop("ACSdownload did not return requested table ", table_name)
      }
      return(result[[table_name]])
    }
  }

  stop(
    "Failed to download ACS table ", table_name, " for ", fips,
    " after ", length(attempts), " attempts. Last error: ",
    if (is.null(last_error)) "ACSdownload returned NULL" else conditionMessage(last_error),
    call. = FALSE
  )
}

bg_acs_raw_folder_path <- function(pipeline_dir, stage = "bg_acs_raw") {
  if (missing(pipeline_dir) || is.null(pipeline_dir)) {
    stop("pipeline_dir must be provided")
  }
  file.path(pipeline_dir, stage)
}

bg_acs_raw_manifest_path <- function(pipeline_dir, stage = "bg_acs_raw") {
  file.path(bg_acs_raw_folder_path(pipeline_dir, stage), "manifest.rds")
}

bg_acs_raw_folder_exists <- function(pipeline_dir,
                                     stage = "bg_acs_raw",
                                     storage = c("auto", "local", "s3")) {
  raw_dir <- bg_acs_raw_folder_path(pipeline_dir, stage)
  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, raw_dir, storage)
  if (storage == "s3") {
    aws <- Sys.which("aws")
    if (!nzchar(aws)) {
      return(FALSE)
    }
    out <- suppressWarnings(system2(aws, args = c("s3", "ls", paste0(raw_dir, "/"), "--recursive"), stdout = TRUE, stderr = TRUE))
    status <- attr(out, "status")
    if (!is.null(status) || length(out) == 0) {
      return(FALSE)
    }
    return(any(grepl("\\.(rds|rda|csv|arrow)$", out, ignore.case = TRUE)))
  }
  dir.exists(raw_dir) && NROW(scan_bg_acs_raw_folder(raw_dir)) > 0
}

save_bg_acs_raw_folder <- function(acs_raw,
                                   pipeline_dir,
                                   stage = "bg_acs_raw",
                                   table_format = c("rds", "rda", "csv", "arrow"),
                                   overwrite = TRUE,
                                   validation_strict = TRUE,
                                   storage = c("auto", "local", "s3")) {
  table_format <- match.arg(table_format)
  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, bg_acs_raw_folder_path(pipeline_dir, stage), storage)
  ejscreen_pipeline_validate(acs_raw, stage = stage, strict = validation_strict)

  raw_dir <- bg_acs_raw_folder_path(pipeline_dir, stage)
  if (storage == "s3") {
    if (bg_acs_raw_folder_exists(pipeline_dir, stage, storage = "s3") && !overwrite) {
      stop("Refusing to overwrite existing raw ACS folder: ", raw_dir)
    }
    local_parent <- tempfile("bg_acs_raw_s3_")
    local_dir <- save_bg_acs_raw_folder(
      acs_raw,
      pipeline_dir = local_parent,
      stage = stage,
      table_format = table_format,
      overwrite = TRUE,
      validation_strict = validation_strict,
      storage = "local"
    )
    ejscreen_pipeline_aws(c("s3", "cp", local_dir, raw_dir, "--recursive"), stdout = FALSE, stderr = TRUE)
    return(raw_dir)
  }

  if (dir.exists(raw_dir)) {
    if (!overwrite) {
      stop("Refusing to overwrite existing raw ACS folder: ", raw_dir)
    }
    unlink(raw_dir, recursive = TRUE)
  }
  dir.create(file.path(raw_dir, "blockgroup"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(raw_dir, "tract"), recursive = TRUE, showWarnings = FALSE)

  manifest_rows <- list()
  for (component in c("blockgroup", "tract")) {
    tables <- acs_raw_component(acs_raw, component)
    if (is.null(tables) || length(tables) == 0) {
      next
    }
    table_names <- names(tables)
    if (is.null(table_names) || any(!nzchar(table_names))) {
      stop(component, " ACS tables must be named before saving as a folder checkpoint")
    }
    for (table_name in table_names) {
      if (grepl("[/\\\\]", table_name)) {
        stop("ACS table names cannot contain path separators: ", table_name)
      }
      rel_file <- file.path(component, paste0(table_name, ".", table_format))
      out_path <- file.path(raw_dir, rel_file)
      save_acs_raw_table_file(tables[[table_name]], out_path, table_format, object_name = table_name)
      manifest_rows[[length(manifest_rows) + 1L]] <- data.frame(
        component = component,
        table = table_name,
        file = rel_file,
        format = table_format,
        rows = NROW(tables[[table_name]]),
        columns = NCOL(tables[[table_name]]),
        has_fips = "fips" %in% names(tables[[table_name]]),
        stringsAsFactors = FALSE
      )
    }
  }

  manifest_tables <- if (length(manifest_rows) == 0) {
    data.frame(
      component = character(),
      table = character(),
      file = character(),
      format = character(),
      rows = integer(),
      columns = integer(),
      has_fips = logical(),
      stringsAsFactors = FALSE
    )
  } else {
    do.call(rbind, manifest_rows)
  }

  manifest <- list(
    stage = stage,
    yr = acs_raw$yr,
    fiveorone = as.character(acs_raw$fiveorone),
    downloaded_at = acs_raw$downloaded_at,
    source = acs_raw$source,
    raw_acs_storage = "folder",
    raw_table_format = table_format,
    blockgroup_tables = manifest_tables$table[manifest_tables$component == "blockgroup"],
    tract_tables = manifest_tables$table[manifest_tables$component == "tract"],
    tables = manifest_tables
  )
  saveRDS(manifest, file = file.path(raw_dir, "manifest.rds"))
  data.table::fwrite(manifest_tables, file = file.path(raw_dir, "manifest.csv"))

  normalizePath(raw_dir, mustWork = FALSE)
}

load_bg_acs_raw_folder <- function(pipeline_dir,
                                   stage = "bg_acs_raw",
                                   validation_strict = TRUE,
                                   storage = c("auto", "local", "s3")) {
  raw_dir <- bg_acs_raw_folder_path(pipeline_dir, stage)
  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, raw_dir, storage)
  if (storage == "s3") {
    if (!bg_acs_raw_folder_exists(pipeline_dir, stage, storage = "s3")) {
      stop("Raw ACS folder not found: ", raw_dir)
    }
    local_parent <- tempfile("bg_acs_raw_s3_")
    local_raw_dir <- bg_acs_raw_folder_path(local_parent, stage)
    dir.create(local_raw_dir, recursive = TRUE, showWarnings = FALSE)
    ejscreen_pipeline_aws(c("s3", "cp", raw_dir, local_raw_dir, "--recursive"), stdout = FALSE, stderr = TRUE)
    return(load_bg_acs_raw_folder(local_parent, stage = stage, validation_strict = validation_strict, storage = "local"))
  }

  if (!dir.exists(raw_dir)) {
    stop("Raw ACS folder not found: ", raw_dir)
  }

  manifest <- list()
  manifest_path <- file.path(raw_dir, "manifest.rds")
  if (file.exists(manifest_path)) {
    manifest <- readRDS(manifest_path)
  }

  table_files <- scan_bg_acs_raw_folder(raw_dir)
  if (NROW(table_files) == 0) {
    stop("Raw ACS folder has no table files: ", raw_dir)
  }

  manifest_value <- function(name, default) {
    value <- manifest[[name]]
    if (is.null(value)) {
      return(default)
    }
    value
  }

  out <- list(
    stage = stage,
    yr = manifest_value("yr", NA_integer_),
    fiveorone = as.character(manifest_value("fiveorone", NA_character_)),
    downloaded_at = manifest_value("downloaded_at", NA_character_),
    source = manifest_value("source", "Raw ACS table files from folder checkpoint"),
    raw_acs_storage = "folder",
    source_folder = normalizePath(raw_dir, mustWork = FALSE),
    blockgroup = list(),
    tract = list()
  )

  for (i in seq_len(NROW(table_files))) {
    component <- table_files$component[[i]]
    table_name <- table_files$table[[i]]
    table_path <- file.path(raw_dir, table_files$file[[i]])
    out[[component]][[table_name]] <- load_acs_raw_table_file(table_path, table_files$format[[i]])
  }
  out$blockgroup_tables <- names(out$blockgroup)
  out$tract_tables <- names(out$tract)
  class(out) <- c("ejam_bg_acs_raw", class(out))

  ejscreen_pipeline_validate(out, stage = stage, strict = validation_strict)
  out
}

scan_bg_acs_raw_folder <- function(raw_dir) {
  supported_ext <- c("rds", "rda", "csv", "arrow")
  rows <- list()
  for (component in c("blockgroup", "tract")) {
    component_dir <- file.path(raw_dir, component)
    if (!dir.exists(component_dir)) {
      next
    }
    files <- list.files(component_dir, full.names = FALSE, recursive = FALSE)
    files <- files[tolower(sub("^.*\\.([^.]+)$", "\\1", files)) %in% supported_ext]
    if (length(files) == 0) {
      next
    }
    for (file_name in files) {
      format <- tolower(sub("^.*\\.([^.]+)$", "\\1", file_name))
      rows[[length(rows) + 1L]] <- data.frame(
        component = component,
        table = sub("\\.[^.]+$", "", basename(file_name)),
        file = file.path(component, file_name),
        format = format,
        stringsAsFactors = FALSE
      )
    }
  }
  out <- if (length(rows) == 0) {
    data.frame(component = character(), table = character(), file = character(), format = character())
  } else {
    do.call(rbind, rows)
  }
  if (NROW(out) > 0 && any(duplicated(paste(out$component, out$table)))) {
    dupes <- out[duplicated(paste(out$component, out$table)) | duplicated(paste(out$component, out$table), fromLast = TRUE), ]
    stop("Duplicate raw ACS table files found for component/table combinations: ",
         paste(paste(dupes$component, dupes$table, sep = "/"), collapse = ", "))
  }
  out
}

save_acs_raw_table_file <- function(x, path, format, object_name) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (format == "rds") {
    saveRDS(x, file = path)
  } else if (format == "rda") {
    env <- list2env(setNames(list(x), object_name), parent = emptyenv())
    save(list = object_name, file = path, envir = env)
  } else if (format == "csv") {
    data.table::fwrite(x, file = path)
  } else if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to save raw ACS tables in Arrow format")
    }
    arrow::write_ipc_file(x, sink = path)
  } else {
    stop("Unsupported raw ACS table format: ", format)
  }
  invisible(normalizePath(path, mustWork = FALSE))
}

load_acs_raw_table_file <- function(path, format = NULL) {
  if (is.null(format)) {
    format <- tolower(sub("^.*\\.([^.]+)$", "\\1", path))
  }
  if (!file.exists(path)) {
    stop("Raw ACS table file not found: ", path)
  }
  if (format == "rds") {
    return(readRDS(path))
  }
  if (format == "rda") {
    env <- new.env(parent = emptyenv())
    loaded <- load(path, envir = env)
    return(get(loaded[1], envir = env))
  }
  if (format == "csv") {
    return(ejscreen_read_csv_table(path))
  }
  if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to load raw ACS tables in Arrow format")
    }
    return(arrow::read_ipc_file(file = path, as_data_frame = TRUE))
  }
  stop("Unsupported raw ACS table format: ", format)
}

acs_raw_component <- function(acs_raw, component = c("blockgroup", "tract")) {
  component <- match.arg(component)
  if (is.null(acs_raw)) {
    return(NULL)
  }
  if (!is.null(acs_raw[[component]])) {
    return(acs_raw[[component]])
  }
  if (all(vapply(acs_raw, is.data.frame, logical(1)))) {
    return(acs_raw)
  }
  stop("acs_raw must be a bg_acs_raw object or a named list of ACS table data.frames")
}

merge_acs_raw_tables <- function(acs_tables) {
  if (is.null(acs_tables) || length(acs_tables) == 0) {
    stop("acs_tables must contain at least one table")
  }
  if (!all(vapply(acs_tables, is.data.frame, logical(1)))) {
    stop("acs_tables must be a named list of data.frames")
  }

  rowcounts <- vapply(acs_tables, NROW, integer(1))
  if (any(rowcounts == 0)) {
    warning("Some ACS raw tables had zero rows and will be omitted: ",
            paste(names(acs_tables)[rowcounts == 0], collapse = ", "), call. = FALSE)
    acs_tables <- acs_tables[rowcounts > 0]
  }
  if (length(acs_tables) == 0) {
    stop("No ACS raw tables had rows to merge")
  }

  if (length(unique(vapply(acs_tables, NROW, integer(1)))) > 1) {
    warning("Not every ACS raw table has the same number of rows; merging by fips", call. = FALSE)
  }

  prepared <- lapply(acs_tables, function(x) {
    x <- data.table::as.data.table(data.table::copy(x))
    if (!"fips" %in% names(x)) {
      stop("ACS raw table is missing fips")
    }
    x
  })

  out <- prepared[[1]]
  if (length(prepared) > 1) {
    for (i in 2:length(prepared)) {
      x <- prepared[[i]]
      drop_shared <- intersect(c("GEO_ID", "SUMLEVEL"), names(x))
      x[, (drop_shared) := NULL]
      out <- merge(out, x, by = "fips", all = TRUE, sort = FALSE)
    }
  }
  out
}

###################################################### #
