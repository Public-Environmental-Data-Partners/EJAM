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
#' @param root root folder where the pipeline folder should be created.
#' @param yr optional ACS end year or other year label to append to the pipeline
#'   folder name.
#' @param pipeline_name short pipeline folder name.
#' @param stage pipeline stage name.
#' @param pipeline_dir folder for pipeline stage files.
#' @param format file format: `"rds"`, `"rda"`, `"csv"`, or `"arrow"`.
#' @param x object to save or object supplied directly as pipeline input.
#' @param object_name object name to use inside `.rda` files.
#' @param overwrite logical. If FALSE, refuse to overwrite an existing stage
#'   file.
#' @param validate logical. If TRUE, validate known stages before saving.
#' @param validation_strict logical passed to [ejscreen_pipeline_validate()].
#' @param path optional explicit file path to load.
#' @param return_data_table logical passed to Arrow reads.
#' @param input_name label used in error messages when an input is missing.
#' @seealso [calc_ejscreen_dataset()]
#' @return
#'   - `EJAM:::ejscreen_pipeline_stage_names()` returns known stage names.
#'   - `EJAM:::ejscreen_pipeline_dir()` & `EJAM:::ejscreen_pipeline_stage_path()` return paths.
#'   - `EJAM:::ejscreen_pipeline_save()` writes data to files and returns the path.
#'   - `ejscreen_pipeline_input()` & helper `EJAM:::ejscreen_pipeline_load()` read data from files
#'   & return the loaded or supplied object.
#'
#' @keywords internal
#'
#' @keywords internal
#'
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

# helps read data from a file and returns the data itself
# used by ejscreen_pipeline_load() etc.

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_read_csv_table <- function(path) {
  header <- names(data.table::fread(path, nrows = 0))
  character_cols <- intersect(
    c(
      "bgfips", "bgid", "blockid", "blockfips", "tractfips",
      "fips", "GEO_ID", "SUMLEVEL", "ST", "REGION", "PCTILE",
      "statename", "countyname"
    ),
    header
  )
  if (length(character_cols) > 0) {
    return(data.table::fread(path, colClasses = list(character = character_cols)))
  }
  data.table::fread(path)
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
                                   return_data_table = TRUE) {

  # This reads a file and returns the data itself

  if (is.null(path)) {
    if (is.null(format)) {
      format <- "csv"
    }
    path <- ejscreen_pipeline_stage_path(stage, pipeline_dir, format)
    if (!file.exists(path) &&
        identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
        bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage))) {
      return(load_bg_acs_raw_folder(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage)))
    }
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
  if (format == "csv") {
    return(ejscreen_read_csv_table(path))
  }
  if (format == "arrow") {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to load pipeline stages in Arrow format")
    }
    return(arrow::read_ipc_file(file = path, as_data_frame = return_data_table))
  }

  stop("Unsupported pipeline stage format: ", format)
}
################################################### #

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
  } else if (format == "csv") {
    if (!is.data.frame(x)) {
      stop("CSV pipeline stages must be data.frame or data.table objects")
    }
    data.table::fwrite(x, file = path)
  } else {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to save pipeline stages in Arrow format")
    }
    arrow::write_ipc_file(x, sink = path)
  }

  normalizePath(path, mustWork = FALSE)
}
################################################### #

################################################### #
# check path and name of a stage ####
################################################### #

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_stage_names <- function() {
  c(
    acs_raw =       "acs_raw",
    bg_acs_raw = "bg_acs_raw",    # canonical

    blockgroupstats_acs = "blockgroupstats_acs",
    bg_acsdata = "bg_acsdata",    # canonical

    envirodata =       "envirodata",
    bg_envirodata = "bg_envirodata", # canonical

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
    bg_ejscreen =     "bg_ejscreen"
  )
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
         blockgroupstats_acs = "bg_acsdata",
         envirodata =          "bg_envirodata",
         extra_indicators =    "bg_extra_indicators",
         bg_ejindexes =        "bgej",
         bg_ej =               "bgej",
         bg_ejscreen =         "ejscreen_export",
         stage
  )
}
###################################################### #
# was unused but could be helpful for future pipeline stages that need to check for a folder of files instead of a single file

#' @rdname ejscreen_pipeline_input
#' @keywords internal
#'
ejscreen_pipeline_dir <- function(root = tempdir(), yr = NULL, pipeline_name = "ejscreen_acs") {
  if (!is.null(yr)) {
    pipeline_name <- paste0(pipeline_name, "_", yr)
  }
  file.path(root, pipeline_name)
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
                                           format = "csv") {
  if (missing(stage) || is.null(stage) || !nzchar(stage) ||
      missing(pipeline_dir) || is.null(pipeline_dir)) {
    return(FALSE)
  }
  if (file.exists(ejscreen_pipeline_stage_path(stage, pipeline_dir, format))) {
    return(TRUE)
  }
  identical(ejscreen_pipeline_stage_canonical(stage), "bg_acs_raw") &&
    bg_acs_raw_folder_exists(pipeline_dir, stage = ejscreen_pipeline_stage_canonical(stage))
}
################################################### #
