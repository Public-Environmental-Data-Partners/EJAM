###################################################### #

#' Download raw ACS tables for the blockgroup ACS pipeline
#'
#' @details This creates the raw ACS checkpoint for the annual EJSCREEN/EJAM
#' data update pipeline. It downloads the Census Bureau ACS table-based summary
#' file tables with `ACSdownload::get_acs_new()` and stores them as a single
#' list object with separate `blockgroup` and `tract` table lists.
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
#' @param stage_format file format for saved stages: `"rds"`, `"rda"`, or
#'   `"arrow"`.
#' @param overwrite logical, whether to overwrite an existing saved stage.
#' @param validation_strict logical passed to [ejscreen_pipeline_save()].
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
                                stage_format = "rds",
                                overwrite = TRUE,
                                validation_strict = TRUE) {
  if (missing(yr)) {
    yr <- acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)
  }

  blockgroup_tables <- unique(as.vector(blockgroup_tables))
  tract_tables <- unique(as.vector(tract_tables))

  blockgroup <- download_acs_raw_tables(
    yr = yr,
    tables = blockgroup_tables,
    fips = "blockgroup",
    fiveorone = fiveorone
  )
  tract <- list()
  if (include_tract_data && length(tract_tables) > 0) {
    tract <- download_acs_raw_tables(
      yr = yr,
      tables = tract_tables,
      fips = "tract",
      fiveorone = fiveorone
    )
  }

  out <- list(
    stage = "bg_acs_raw",
    yr = yr,
    fiveorone = as.character(fiveorone),
    downloaded_at = as.character(Sys.time()),
    source = "Census Bureau ACS table-based summary files via ACSdownload::get_acs_new()",
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
    ejscreen_pipeline_save(
      out,
      stage = "bg_acs_raw",
      pipeline_dir = pipeline_dir,
      format = stage_format,
      overwrite = overwrite,
      validation_strict = validation_strict
    )
  } else {
    ejscreen_pipeline_validate(out, stage = "bg_acs_raw", strict = validation_strict)
  }

  out
}

download_acs_raw_tables <- function(yr, tables, fips, fiveorone = "5") {
  if (!requireNamespace("ACSdownload", quietly = TRUE)) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload and documented at https://ejanalysis.github.io/ACSdownload/")
  }
  ACSdownload::get_acs_new(
    yr = yr,
    tables = tables,
    fips = fips,
    fiveorone = fiveorone,
    return_list_not_merged = TRUE
  )
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
      out <- merge(out, x, by = "fips")
    }
  }
  out
}

###################################################### #
