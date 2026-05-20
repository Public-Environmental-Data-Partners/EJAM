################################################### #

# Helpers for file-backed EJSCREEN/EJAM data update pipeline stages
# see also calc_ejscreen_dataset()

################################################### #
# read from file ####
################################################### #

# reads data from a file and returns the data itself
# wraps / uses ejscreen_pipeline_load()


#' Helpers for file-backed EJSCREEN/EJAM data update pipeline stages
#'
#' @details These helpers are intended for annual update functions that should be
#' usable either as in-memory calculations or as resumable file-backed pipeline
#' steps. They intentionally use base R formats by default and only use Arrow
#' when explicitly requested. The helpers construct file paths, save files,
#' load files, and normalize compatibility stage aliases to canonical names.
#'
#' @param stage pipeline stage name.
#' @param pipeline_dir folder for pipeline stage files.
#' @param format file format: `"rds"`, `"rda"`, `"csv"`, or `"arrow"`.
#' @param storage stage storage backend: `"auto"`, `"local"`, or `"s3"`.
#'   `"auto"` treats `s3://...` pipeline directories or paths as S3 and
#'   everything else as local file storage. S3 support uses the AWS CLI and does
#'   not add an R package dependency.
#' @param x object to save or object supplied directly as pipeline input.
#' @param object_name object name to use inside `.rda` files.
#' @param overwrite logical. If FALSE, refuse to overwrite an existing stage
#'   file.
#' @param validate logical. If TRUE, validate known stages before saving.
#' @param validation_strict logical passed to `EJAM:::ejscreen_pipeline_validate()`.
#' @param yr optional ACS end year used to set metadata on R-native saved
#'   stages. If omitted, the helper tries `EJAM_PIPELINE_YR` and then the
#'   `ejscreen_acs_YYYY` suffix in `pipeline_dir`.
#' @param metadata optional named list of metadata attributes to apply before
#'   saving R-native stages.
#' @param add_metadata logical. If TRUE, add or update metadata attributes for
#'   known non-atomic pipeline stages and for objects that already have metadata
#'   attributes. Atomic vectors without existing metadata attributes are left
#'   unchanged.
#' @param path optional explicit file path to load.
#' @param return_data_table logical passed to Arrow reads.
#' @param input_name label used in error messages when an input is missing.
#' @seealso [calc_ejscreen_dataset()]
#' @return
#'   `ejscreen_pipeline_stage_names()` returns vector of allowed stage names and aliases, such as "bg_envirodata" etc., so that `EJAM:::ejscreen_pipeline_validate()` can check if a specified stage name is valid and apply the specific validation rules for that stage
#'
#'   `ejscreen_pipeline_stage_canonical()` returns the character string input unchanged (if unrecognized) or returns the canonical version of a stage name, mapping any recognized alias like "envirodata" to the canonical name like "bg_envirodata"
#'
#'   `EJAM:::ejscreen_pipeline_stage_path()` returns a path, with pipeline_dir as the folder(s) and filename based on stage and format (file extension), such as "some/temp/dir/ejscreen_acs_2024/bg_envirodata.csv"
#'
#'   `EJAM:::ejscreen_pipeline_save()` writes data to files and returns the path, with many options for file format, local vs s3, validation, etc.
#'
#'   `EJAM:::ejscreen_pipeline_input()` & helper `EJAM:::ejscreen_pipeline_load()` reads data from files or input, returns the data object
#'
#'   `EJAM:::ejscreen_pipeline_storage_backend()` checks if using AWS s3 or local folder storage, returns one of "auto", "local", "s3"
#'
#' @keywords internal
#'
ejscreen_pipeline_input <- function(x = NULL,
                                    stage = NULL,
                                    pipeline_dir = NULL,
                                    path = NULL,
                                    format = NULL,
                                    object_name = NULL,
                                    storage = c("auto", "local", "s3"),
                                    input_name = "input") {
  if (!is.null(x)) {
    return(x)
  }
  if (!is.null(path) || (!is.null(stage) && !is.null(pipeline_dir))) {
    return(ejscreen_pipeline_load(
      stage = stage,
      pipeline_dir = pipeline_dir,
      path = path,
      format = format,
      object_name = object_name,
      storage = storage
    ))
  }
  stop(input_name, " must be supplied as an object or as a saved pipeline stage")
}
################################################### #

# helps read data from a file and returns the data itself
# used by ejscreen_pipeline_input()

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_load <- function(stage = NULL,
                                   pipeline_dir = NULL,
                                   path = NULL,
                                   format = NULL,
                                   object_name = NULL,
                                   storage = c("auto", "local", "s3"),
                                   return_data_table = TRUE) {

  # This reads a file and returns the data itself

  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, path, storage)
  if (is.null(path)) {
    if (is.null(format)) {
      format <- "csv"
    }
    path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
    if (storage == "local" &&
        !file.exists(path) &&
        identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
        bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage))) {
      return(load_bg_acs_raw_folder(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage)))
    }
  } else if (is.null(format)) {
    format <- sub("^.*\\.([^.]+)$", "\\1", path)
  }

  load_path <- path
  if (storage == "s3") {
    if (!ejscreen_pipeline_is_s3_uri(path)) {
      stop("S3 pipeline storage requires an s3:// stage path")
    }
    if (identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
        bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage), storage = "s3")) {
      return(load_bg_acs_raw_folder(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage), storage = "s3"))
    }
    load_path <- tempfile(fileext = paste0(".", format))
    ejscreen_pipeline_s3_download(path, load_path)
  }

  if (!file.exists(load_path)) {
    stop("Pipeline stage file not found: ", path)
  }

  if (format == "rds") {
    return(readRDS(load_path))
  }
  if (format == "rda") {
    env <- new.env(parent = emptyenv())
    loaded <- load(load_path, envir = env)
    if (is.null(object_name)) {
      object_name <- loaded[1]
    }
    return(get(object_name, envir = env))
  }
  if (format == "csv") {
    return(ejscreen_read_csv_table(load_path))
  }
  if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to load pipeline stages in Arrow format")
    }
    return(arrow::read_ipc_file(file = load_path, as_data_frame = return_data_table))
  }

  stop("Unsupported pipeline stage format: ", format)
}
###################################################### #

# helps read data from a csv file and returns the data itself
# used by ejscreen_pipeline_load() etc.

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_read_csv_table <- function(path) {
  header <- names(data.table::fread(path, nrows = 0))
  character_cols <- intersect(
    c(
      "bgfips", "blockid", "blockfips", "tractfips",
      "fips", "GEO_ID", "SUMLEVEL", "ST", "PCTILE",
      "statename", "countyname"
    ),
    header
  )
  if (length(character_cols) > 0) {
    return(data.table::fread(path, colClasses = list(character = character_cols)))
  }
  data.table::fread(path)
}
###################################################### #

# write to file ####

# writes data to a file and returns path

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_save <- function(x,
                                   stage,
                                   pipeline_dir,
                                   format = c("csv", "rds", "rda", "arrow"),
                                   object_name = stage,
                                   overwrite = TRUE,
                                   validate = TRUE,
                                   validation_strict = TRUE,
                                   yr = NULL,
                                   metadata = NULL,
                                   add_metadata = TRUE,
                                   storage = c("auto", "local", "s3")) {
  format <- match.arg(format)
  path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, path, storage)
  if (storage == "local" && file.exists(path) && !overwrite) {
    stop("Refusing to overwrite existing pipeline stage: ", path)
  }
  if (storage == "s3" && ejscreen_pipeline_s3_uri_exists(path) && !overwrite) {
    stop("Refusing to overwrite existing pipeline stage: ", path)
  }
  if (validate) {
    ejscreen_pipeline_validate(x, stage = stage, strict = validation_strict)
  }
  x_to_save <- ejscreen_pipeline_add_stage_metadata(
    x = x,
    stage = stage,
    pipeline_dir = pipeline_dir,
    yr = yr,
    metadata = metadata,
    add_metadata = add_metadata
  )
  save_path <- path
  if (storage == "local") {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  } else {
    save_path <- tempfile(fileext = paste0(".", format))
  }

  if (format == "rds") {
    saveRDS(x_to_save, file = save_path)

  } else if (format == "rda") {
    env <- list2env(setNames(list(x_to_save), object_name), parent = emptyenv())
    save(list = object_name, file = save_path, envir = env)

  } else if (format == "csv") {
    if (!is.data.frame(x_to_save)) {stop("CSV pipeline stages must be data.frame or data.table objects")}
    data.table::fwrite(x_to_save, file = save_path)

  } else { # format == "arrow"
    if (!requireNamespace("arrow", quietly = TRUE)) {stop("The arrow package is required to save pipeline stages in Arrow format")}
    arrow::write_ipc_file(x_to_save, sink = save_path)
  }

  if (storage == "s3") {
    return(ejscreen_pipeline_s3_upload(save_path, path))
  }

  normalizePath(path, mustWork = FALSE)
}
################################################### #

ejscreen_pipeline_add_stage_metadata <- function(x,
                                                 stage,
                                                 pipeline_dir = NULL,
                                                 yr = NULL,
                                                 metadata = NULL,
                                                 add_metadata = TRUE) {
  if (!isTRUE(add_metadata)) {
    return(x)
  }

  metadata_attr_names <- c(
    "ejam_package_version",
    "date_saved_in_package",
    "date_downloaded",
    "ejscreen_version",
    "ejscreen_releasedate",
    "acs_releasedate",
    "acs_version",
    "census_version"
  )
  existing_metadata <- intersect(metadata_attr_names, names(attributes(x)))
  atomic_vector_without_metadata <- is.atomic(x) && is.vector(x) && length(existing_metadata) == 0L
  if (atomic_vector_without_metadata) {
    return(x)
  }

  stage_canonical <- ejscreen_pipeline_stage_canonical(stage)
  known_stage <- stage_canonical %in% ejscreen_pipeline_stage_names(canonical_only = TRUE)
  if (!known_stage && length(existing_metadata) == 0L && is.null(metadata)) {
    return(x)
  }

  metadata_to_use <- metadata
  if (is.null(metadata_to_use)) {
    metadata_to_use <- get_metadata_mapping(stage_canonical)
  }
  if (is.null(metadata_to_use)) {
    metadata_to_use <- get_metadata_mapping("default")
  }
  if (!is.list(metadata_to_use)) {
    stop("metadata must be a named list", call. = FALSE)
  }

  metadata_to_use$date_saved_in_package <- as.character(Sys.Date())
  metadata_to_use$ejam_package_version <- ejam_package_version_current()

  yr_for_metadata <- ejscreen_pipeline_metadata_year(yr = yr, pipeline_dir = pipeline_dir)
  if (!is.na(yr_for_metadata)) {
    metadata_to_use$acs_version <- ejscreen_pipeline_acs_version_from_year(yr_for_metadata)
    metadata_to_use$acs_releasedate <- ejscreen_pipeline_acs_releasedate_from_year(
      yr_for_metadata,
      fallback = metadata_to_use$acs_releasedate
    )
  }

  for (nm in names(metadata_to_use)) {
    attr(x, nm) <- ejscreen_pipeline_scalar_metadata(metadata_to_use[[nm]])
  }
  x
}
################################################### #

ejscreen_pipeline_scalar_metadata <- function(value) {
  if (is.null(value)) {
    return(NULL)
  }
  value <- unname(as.vector(value))
  if (length(value) == 0L) {
    return(NA_character_)
  }
  value[[1]]
}
################################################### #

ejscreen_pipeline_metadata_year <- function(yr = NULL, pipeline_dir = NULL) {
  if (!is.null(yr) && length(yr) > 0L && any(nzchar(as.character(yr)))) {
    out <- suppressWarnings(as.integer(yr[[1]]))
    if (!is.na(out)) {
      return(out)
    }
  }

  env_yr <- Sys.getenv("EJAM_PIPELINE_YR", unset = "")
  if (nzchar(env_yr)) {
    out <- suppressWarnings(as.integer(env_yr))
    if (!is.na(out)) {
      return(out)
    }
  }

  dir_yr <- ejscreen_pipeline_dir_year(pipeline_dir)
  if (!is.na(dir_yr)) {
    return(as.integer(dir_yr))
  }

  NA_integer_
}
################################################### #

ejscreen_pipeline_acs_releasedate_from_year <- function(yr, fallback = NA_character_) {
  yr <- as.character(as.integer(yr))
  out <- switch(
    yr,
    "2022" = "2023-12-07",
    "2023" = "2024-12-12",
    "2024" = "2026-01-29",
    NA_character_
  )
  if (is.na(out) || !nzchar(out)) {
    return(as.character(fallback)[1])
  }
  out
}
################################################### #

################################################### #
# check path and name of a stage ####
################################################### #

#' @rdname ejscreen_pipeline_input
#' @param canonical_only optional logical set to TRUE in ejscreen_pipeline_stage_names() to return only the canonical versions without any aliases
#' @keywords internal
#'
ejscreen_pipeline_stage_names <- function(canonical_only = FALSE) {
  x = c(
    acs_raw =       "acs_raw",
    bg_acs_raw = "bg_acs_raw",    # canonical
    islandareas_raw =       "islandareas_raw",
    bg_islandareas_raw = "bg_islandareas_raw",    # canonical

    blockgroupstats_acs = "blockgroupstats_acs",
    bg_acsdata = "bg_acsdata",    # canonical

    envirodata =       "envirodata",
    bg_envirodata = "bg_envirodata", # canonical

    area =       "area",
    bg_area =    "bg_area",
    geodata =    "geodata",
    bg_geodata = "bg_geodata", # canonical

    extra_indicators =       "extra_indicators",
    bg_extra_indicators = "bg_extra_indicators", # canonical

    blockgroupstats = "blockgroupstats",

    usastats_acs =     "usastats_acs",
    statestats_acs = "statestats_acs",

    usastats_envirodata =     "usastats_envirodata",
    statestats_envirodata = "statestats_envirodata",

    usastats_ej =      "usastats_ej",
    statestats_ej =  "statestats_ej",

    usastats =         "usastats",
    statestats =     "statestats",

    bgej =         "bgej", # canonical
    bg_ej =        "bg_ej",
    bg_ejindexes = "bg_ejindexes",

    ejscreen_export = "ejscreen_export", # canonical
    bg_ejscreen =     "bg_ejscreen",

    ejscreen_dataset_creator_input = "ejscreen_dataset_creator_input", # canonical
    dataset_creator_input =          "dataset_creator_input",
    ejscreen_python_input =          "ejscreen_python_input"
  )
  if (canonical_only) {
    return(unique(as.vector(sapply(ejscreen_pipeline_stage_names(), ejscreen_pipeline_stage_canonical))))
  } else {
    return(x)
  }
}
################################################### #

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_stage_canonical <- function(stage) {
  if (is.null(stage) || !nzchar(stage)) {
    return(stage)
  }
  switch(stage,
         acs_raw =             "bg_acs_raw",
         islandareas_raw =             "bg_islandareas_raw",
         blockgroupstats_acs = "bg_acsdata",
         envirodata =          "bg_envirodata",
         area =                "bg_geodata",
         bg_area =             "bg_geodata",
         geodata =             "bg_geodata",
         extra_indicators =    "bg_extra_indicators",
         bg_ejindexes =        "bgej",
         bg_ej =               "bgej",
         bg_ejscreen =         "ejscreen_export",
         dataset_creator_input = "ejscreen_dataset_creator_input",
         ejscreen_python_input = "ejscreen_dataset_creator_input",
         stage
  )
}
################################################### #

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_stage_path <- function(stage,
                                         pipeline_dir,
                                         format = c("csv", "rds", "rda", "arrow")) {
  format <- match.arg(format)
  if (missing(stage) || !nzchar(stage)) {
    stop("stage must be a non-empty character string")
  }
  if (missing(pipeline_dir) || is.null(pipeline_dir)) {
    stop("pipeline_dir must be provided")
  }
  stage <- ejscreen_pipeline_stage_canonical(stage)
  file.path(pipeline_dir, paste0(stage, ".", format))
}
################################################### #
#
# checks if the file/path exists for given stage

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_stage_exists <- function(stage,
                                           pipeline_dir,
                                           format = "csv",
                                           storage = c("auto", "local", "s3")) {
  if (missing(stage) || is.null(stage) || !nzchar(stage) ||
      missing(pipeline_dir) || is.null(pipeline_dir)) {
    return(FALSE)
  }
  path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
  storage <- ejscreen_pipeline_storage_backend(pipeline_dir, path, storage)
  if (storage == "s3") {
    if (ejscreen_pipeline_s3_uri_exists(path)) {
      return(TRUE)
    }
    return(identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
             bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage), storage = "s3"))
  }
  if (file.exists(path)) {
    return(TRUE)
  }
  identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
    bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage))
}
################################################### #

# check if AWS s3 or local folder storage ####

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_storage_backend <- function(pipeline_dir = NULL,
                                              path = NULL,
                                              storage = c("auto", "local", "s3")) {
  storage <- match.arg(storage)
  if (storage != "auto") {
    return(storage)
  }
  if (ejscreen_pipeline_is_s3_uri(path) || ejscreen_pipeline_is_s3_uri(pipeline_dir)) {
    return("s3")
  }
  "local"
}
###################################################### #

###################################################### #
# AWS s3 helpers ####
###################################################### #

ejscreen_pipeline_is_s3_uri <- function(x) {
  is.character(x) && length(x) == 1L && grepl("^s3://", x)
}
###################################################### #
ejscreen_pipeline_require_aws_cli <- function() {
  aws <- Sys.which("aws")
  if (!nzchar(aws)) {
    stop(
      "The AWS CLI is required for S3-backed pipeline stages. ",
      "Install and configure `aws`, or use a local pipeline_dir.",
      call. = FALSE
    )
  }
  aws
}
###################################################### #
ejscreen_pipeline_aws <- function(args, stdout = TRUE, stderr = TRUE) {
  aws <- ejscreen_pipeline_require_aws_cli()
  suppressWarnings({status <- system2(aws, args = args, stdout = stdout, stderr = stderr)})
  if (is.integer(status) && !identical(status, 0L)) {
    stop("AWS CLI command failed: aws ", paste(args, collapse = " "), call. = FALSE)
  }
  status
}
###################################################### #
ejscreen_pipeline_s3_download <- function(uri, local_path) {
  dir.create(dirname(local_path), recursive = TRUE, showWarnings = FALSE)
  ejscreen_pipeline_aws(c("s3", "cp", uri, local_path), stdout = FALSE, stderr = TRUE)
  local_path
}
###################################################### #
ejscreen_pipeline_s3_upload <- function(local_path, uri) {
  ejscreen_pipeline_aws(c("s3", "cp", local_path, uri), stdout = FALSE, stderr = TRUE)
  uri
}
###################################################### #
ejscreen_pipeline_s3_uri_exists <- function(uri) {
  aws <- Sys.which("aws")
  if (!nzchar(aws)) {
    return(FALSE)
  }
  out <- suppressWarnings(system2(aws, args = c("s3", "ls", uri), stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status")
  is.null(status) && length(out) > 0
}
###################################################### #
