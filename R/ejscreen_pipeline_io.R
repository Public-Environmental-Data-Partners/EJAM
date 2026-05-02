###################################################### #

#' Helpers for file-backed EJSCREEN/EJAM data update pipeline stages
#'
#' @details These helpers are intended for annual update functions that should be
#' usable either as in-memory calculations or as resumable file-backed pipeline
#' steps. They intentionally use base R formats by default and only use Arrow
#' when explicitly requested.
#'
#' @param root root folder where the pipeline folder should be created.
#' @param yr optional ACS end year or other year label to append to the pipeline
#'   folder name.
#' @param pipeline_name short pipeline folder name.
#' @param stage pipeline stage name.
#' @param pipeline_dir folder for pipeline stage files.
#' @param format file format: `"rds"`, `"rda"`, or `"arrow"`.
#' @param x object to save or object supplied directly as pipeline input.
#' @param object_name object name to use inside `.rda` files.
#' @param overwrite logical. If FALSE, refuse to overwrite an existing stage
#'   file.
#' @param validate logical. If TRUE, validate known stages before saving.
#' @param validation_strict logical passed to [ejscreen_pipeline_validate()].
#' @param path optional explicit file path to load.
#' @param return_data_table logical passed to Arrow reads.
#' @param input_name label used in error messages when an input is missing.
#'
#' @return `ejscreen_pipeline_dir()` and `ejscreen_pipeline_stage_path()` return
#'   file paths. `ejscreen_pipeline_save()` returns the saved file path.
#'   `ejscreen_pipeline_load()` and `ejscreen_pipeline_input()` return the
#'   loaded or supplied object. `ejscreen_pipeline_stage_names()` returns known
#'   stage names.
#'
#' @keywords internal
#' @export
#'
ejscreen_pipeline_dir <- function(root = tempdir(), yr = NULL, pipeline_name = "ejscreen_acs") {
  if (!is.null(yr)) {
    pipeline_name <- paste0(pipeline_name, "_", yr)
  }
  file.path(root, pipeline_name)
}

#' @rdname ejscreen_pipeline_dir
#' @export
ejscreen_pipeline_stage_names <- function() {
  c(
    blockgroupstats_acs = "blockgroupstats_acs",
    envirodata = "envirodata",
    bg_envirodata = "bg_envirodata",
    usastats_acs = "usastats_acs",
    statestats_acs = "statestats_acs",
    usastats_envirodata = "usastats_envirodata",
    statestats_envirodata = "statestats_envirodata",
    bgej = "bgej",
    usastats_ej = "usastats_ej",
    statestats_ej = "statestats_ej",
    usastats = "usastats",
    statestats = "statestats",
    blockgroupstats = "blockgroupstats"
  )
}

#' @rdname ejscreen_pipeline_dir
#' @export
ejscreen_pipeline_stage_path <- function(stage,
                                         pipeline_dir,
                                         format = c("rds", "rda", "arrow")) {
  format <- match.arg(format)
  if (missing(stage) || !nzchar(stage)) {
    stop("stage must be a non-empty character string")
  }
  if (missing(pipeline_dir) || is.null(pipeline_dir)) {
    stop("pipeline_dir must be provided")
  }
  file.path(pipeline_dir, paste0(stage, ".", format))
}

#' @rdname ejscreen_pipeline_dir
#' @export
ejscreen_pipeline_save <- function(x,
                                   stage,
                                   pipeline_dir,
                                   format = c("rds", "rda", "arrow"),
                                   object_name = stage,
                                   overwrite = TRUE,
                                   validate = TRUE,
                                   validation_strict = TRUE) {
  format <- match.arg(format)
  path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
  if (file.exists(path) && !overwrite) {
    stop("Refusing to overwrite existing pipeline stage: ", path)
  }
  if (validate) {
    ejscreen_pipeline_validate(x, stage = stage, strict = validation_strict)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  if (format == "rds") {
    saveRDS(x, file = path)
  } else if (format == "rda") {
    env <- list2env(setNames(list(x), object_name), parent = emptyenv())
    save(list = object_name, file = path, envir = env)
  } else {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to save pipeline stages in Arrow format")
    }
    arrow::write_ipc_file(x, sink = path)
  }

  normalizePath(path, mustWork = FALSE)
}

#' @rdname ejscreen_pipeline_dir
#' @export
ejscreen_pipeline_load <- function(stage = NULL,
                                   pipeline_dir = NULL,
                                   path = NULL,
                                   format = NULL,
                                   object_name = NULL,
                                   return_data_table = TRUE) {
  if (is.null(path)) {
    if (is.null(format)) {
      format <- "rds"
    }
    path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
  } else if (is.null(format)) {
    format <- sub("^.*\\.([^.]+)$", "\\1", path)
  }

  if (!file.exists(path)) {
    stop("Pipeline stage file not found: ", path)
  }

  if (format == "rds") {
    return(readRDS(path))
  }
  if (format == "rda") {
    env <- new.env(parent = emptyenv())
    loaded <- load(path, envir = env)
    if (is.null(object_name)) {
      object_name <- loaded[1]
    }
    return(get(object_name, envir = env))
  }
  if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to load pipeline stages in Arrow format")
    }
    return(arrow::read_ipc_file(file = path, as_data_frame = return_data_table))
  }

  stop("Unsupported pipeline stage format: ", format)
}

#' @rdname ejscreen_pipeline_dir
#' @export
ejscreen_pipeline_input <- function(x = NULL,
                                    stage = NULL,
                                    pipeline_dir = NULL,
                                    path = NULL,
                                    format = NULL,
                                    object_name = NULL,
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
      object_name = object_name
    ))
  }
  stop(input_name, " must be supplied as an object or as a saved pipeline stage")
}

###################################################### #
