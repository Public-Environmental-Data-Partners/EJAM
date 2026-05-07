###################################################### #

#' Extra blockgroup indicators used by the EJSCREEN/EJAM pipeline
#'
#' @details `bg_extra_indicators` is for blockgroup-level fields that are not
#' ACS-derived `bg_acsdata` columns and are not environmental raw-score
#' `bg_envirodata` columns. Examples include low life expectancy, health
#' outcome rates, site/feature counts, climate indicators, and flag fields.
#'
#' By default, missing extra indicators are errors. Set
#' `reuse_existing_if_missing = TRUE` only when you intentionally want to carry
#' forward columns from the currently packaged [blockgroupstats] data.
#'
#' @param bg_extra_indicators optional data.frame or data.table with `bgfips`
#'   and extra indicator columns.
#' @param extra_indicator_vars expected extra indicator columns.
#' @param reuse_existing_if_missing logical, whether missing extra indicators
#'   should be copied from `existing_blockgroupstats`.
#' @param existing_blockgroupstats optional blockgroupstats-like table to use
#'   when `reuse_existing_if_missing` is TRUE. Defaults to current package data.
#' @param pipeline_dir folder for saving the pipeline stage.
#' @param save_stage logical, whether to save the `bg_extra_indicators` stage.
#' @param stage_format file format for saved stages: `"csv"`, `"rds"`,
#'   `"rda"`, or `"arrow"`.
#' @param overwrite logical, whether to overwrite an existing saved stage.
#' @param validation_strict logical passed to [ejscreen_pipeline_save()].
#'
#' @return data.table with `bgfips` and extra indicator columns.
#'
#' @export
#' @keywords internal
#'
calc_bg_extra_indicators <- function(bg_extra_indicators = NULL,
                                     extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
                                     reuse_existing_if_missing = FALSE,
                                     existing_blockgroupstats = NULL,
                                     pipeline_dir = NULL,
                                     save_stage = FALSE,
                                     stage_format = c("csv", "rds", "rda", "arrow"),
                                     overwrite = TRUE,
                                     validation_strict = TRUE) {
  stage_format <- match.arg(stage_format)

  out <- complete_bg_extra_indicators(
    bg_extra_indicators = bg_extra_indicators,
    extra_indicator_vars = extra_indicator_vars,
    reuse_existing_if_missing = reuse_existing_if_missing,
    existing_blockgroupstats = existing_blockgroupstats
  )

  if (save_stage) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stage is TRUE")
    }
    ejscreen_pipeline_save(
      out,
      stage = "bg_extra_indicators",
      pipeline_dir = pipeline_dir,
      format = stage_format,
      overwrite = overwrite,
      validation_strict = validation_strict
    )
  } else {
    ejscreen_pipeline_validate(out, stage = "bg_extra_indicators", strict = validation_strict)
  }

  out
}

#' @rdname calc_bg_extra_indicators
#' @export
ejscreen_default_extra_indicator_vars <- function() {
  vars <- namesbyvarlist(
    varlist = ejscreen_default_extra_indicator_varlists(),
    nametype = "rname",
    exclude = c("pctdisability", "pctnobroadband", "pctnohealthinsurance"),
    available_vars = names(EJAM::blockgroupstats)
  )$rname
  unique(vars)
}

#' @rdname calc_bg_extra_indicators
#' @export
ejscreen_default_extra_indicator_varlists <- function() {
  c(
    "names_health",
    "names_sitesinarea",
    "names_countabove",
    "names_climate",
    "names_featuresinarea",
    "names_criticalservice",
    "names_flag"
  )
}

complete_bg_extra_indicators <- function(bg_extra_indicators = NULL,
                                         extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
                                         reuse_existing_if_missing = FALSE,
                                         existing_blockgroupstats = NULL) {
  extra_indicator_vars <- unique(extra_indicator_vars)
  if (!"lowlifex" %in% extra_indicator_vars) {
    extra_indicator_vars <- c("lowlifex", extra_indicator_vars)
  }

  existing <- NULL
  if (isTRUE(reuse_existing_if_missing)) {
    existing <- existing_blockgroupstats
    if (is.null(existing)) {
      existing <- EJAM::blockgroupstats
    }
    existing <- data.table::as.data.table(data.table::copy(existing))
    if (!"bgfips" %in% names(existing)) {
      stop("existing_blockgroupstats must have a bgfips column")
    }
  }

  if (is.null(bg_extra_indicators)) {
    if (!isTRUE(reuse_existing_if_missing)) {
      stop("bg_extra_indicators must be supplied. To intentionally reuse current package data, set reuse_existing_if_missing = TRUE")
    }
    available <- intersect(extra_indicator_vars, names(existing))
    missing_existing <- setdiff(extra_indicator_vars, available)
    if (length(missing_existing) > 0) {
      stop("existing_blockgroupstats is missing expected extra indicator columns: ",
           paste(missing_existing, collapse = ", "))
    }
    warning("Reusing current blockgroupstats data for bg_extra_indicators: ",
            paste(available, collapse = ", "), call. = FALSE)
    out <- existing[, c("bgfips", available), with = FALSE]
    attr(out, "extra_indicator_vars") <- extra_indicator_vars
    data.table::setorder(out, bgfips)
    return(out)
  }

  out <- data.table::as.data.table(data.table::copy(bg_extra_indicators))
  if (!"bgfips" %in% names(out)) {
    stop("bg_extra_indicators must have a bgfips column")
  }

  missing_vars <- setdiff(extra_indicator_vars, names(out))
  if (length(missing_vars) > 0) {
    if (!isTRUE(reuse_existing_if_missing)) {
      stop("bg_extra_indicators is missing expected extra indicator columns: ",
           paste(missing_vars, collapse = ", "),
           ". To intentionally reuse current package data for missing columns, set reuse_existing_if_missing = TRUE")
    }
    missing_existing <- setdiff(missing_vars, names(existing))
    if (length(missing_existing) > 0) {
      stop("existing_blockgroupstats is missing expected extra indicator columns: ",
           paste(missing_existing, collapse = ", "))
    }
    warning("Reusing current blockgroupstats data for missing bg_extra_indicators columns: ",
            paste(missing_vars, collapse = ", "), call. = FALSE)
    out <- merge(
      out,
      existing[, c("bgfips", missing_vars), with = FALSE],
      by = "bgfips",
      all.x = TRUE,
      sort = FALSE
    )
  }

  cols <- c("bgfips", intersect(extra_indicator_vars, names(out)))
  out <- out[, ..cols]
  attr(out, "extra_indicator_vars") <- extra_indicator_vars
  data.table::setorder(out, bgfips)
  out
}

add_bg_geography_columns <- function(x) {
  x <- data.table::as.data.table(data.table::copy(x))
  if (!"bgfips" %in% names(x)) {
    stop("x must have a bgfips column")
  }

  fill_missing <- function(col, values) {
    missing_col <- !col %in% names(x)
    if (missing_col) {
      x[, (col) := values]
      return(invisible(NULL))
    }
    missing_values <- is.na(x[[col]]) | !nzchar(as.character(x[[col]]))
    if (all(missing_values)) {
      x[, (col) := values]
    } else if (any(missing_values)) {
      x[missing_values, (col) := values[missing_values]]
    }
    invisible(NULL)
  }

  fill_missing("ST", fips2stateabbrev(x$bgfips))
  fill_missing("statename", fips2statename(x$bgfips))
  fill_missing("countyname", fips2countyname(x$bgfips, includestate = FALSE))
  fill_missing("REGION", fips_st2eparegion(fips2statefips(x$bgfips)))
  fill_missing("bgid", EJAM::bgpts$bgid[match(x$bgfips, EJAM::bgpts$bgfips)])
  x
}

###################################################### #
