################################################# ################################### #

#' Aggregate block-group ACS indicators up to tract, county, and state
#'
#' Part (c) of issue #395: roll block-group ACS demographic values up to tract,
#' county, and state for the EJSCREEN web app's "additional demographics" (and
#' side-by-side) layers, using the same per-indicator aggregation rules as
#' [doaggregate()].
#'
#' @details
#' Each indicator is aggregated by the method EJAM stores for it, looked up with
#' the same accessors [doaggregate()] uses:
#' \itemize{
#'   \item [calctype()] `== "sum of counts"` -> the column is **summed** within
#'     each geography (population, households, the ACS universes/denominators, raw
#'     counts, etc.).
#'   \item [calctype()] `== "wtdmean"` -> the column is a **weighted mean**, where
#'     the weight is the indicator's own denominator from [calcweight()] (for
#'     example `pop` for population fractions, `hhlds` / `occupiedunits` /
#'     `builtunits` for household-based indicators, `povknownratio` for the
#'     low-income fraction, `age25up` for educational attainment, and so on). The
#'     mean is `sum(value * weight) / sum(weight)`, taken only over block groups
#'     that have the indicator.
#' }
#' Following [doaggregate()], if an indicator's weight column is not present in
#' the data, the population weight `pop` is used as a fallback (with a message).
#' Percentile (`lookedup`), `ratio to avg`, and map bin/text columns are **not**
#' recomputed here -- those need geography-level distributions / lookups and are a
#' separate step (see issue #395). The geography id is the leading FIPS digits of
#' `bgfips`: 12 = block group, 11 = tract, 5 = county, 2 = state.
#'
#' @param bg Block-group table with `id_col` and ACS indicator columns. Defaults
#'   to [blockgroupstats].
#' @param id_col Block-group FIPS column name. Default `"bgfips"`.
#' @param levels Any of `"blockgroup"`, `"tract"`, `"county"`, `"state"`.
#' @param pop_fallback If `TRUE` (default), weighted-mean indicators whose weight
#'   column is missing from the data fall back to population weighting, as in
#'   [doaggregate()]. If `FALSE`, such indicators are dropped.
#' @param out_dir Optional directory; if set, each level is written there as
#'   `acs_by_<level>.csv`.
#' @return A named list of data.frames, one per requested level: the geography
#'   FIPS id column, the summed count columns, and the recomputed weighted-mean
#'   indicator columns.
#' @seealso [doaggregate()] [calctype()] [calcweight()] [calc_ejscreen_export()]
#'   [calc_ejscreen_threshold_layers()]
#' @export
#'
calc_acs_by_geography <- function(
    bg = blockgroupstats,
    id_col = "bgfips",
    levels = c("blockgroup", "tract", "county", "state"),
    pop_fallback = TRUE,
    out_dir = NULL) {

  levels <- match.arg(levels, several.ok = TRUE)
  stopifnot(id_col %in% names(bg))

  DT      <- data.table::as.data.table(data.table::copy(bg))
  fips    <- as.character(DT[[id_col]])
  allcols <- names(DT)

  # Per-indicator aggregation method + weight, via the same accessors doaggregate() uses.
  ctype   <- calctype(allcols)
  sumcols <- allcols[!is.na(ctype) & ctype == "sum of counts"]
  wtdcols <- allcols[!is.na(ctype) & ctype == "wtdmean"]
  wts     <- calcweight(wtdcols)   # each indicator's own denominator/weight column

  # Population-weight fallback for any weight column not present in the data (matches doaggregate()).
  missing_w <- is.na(wts) | !(wts %in% allcols)
  if (any(missing_w)) {
    if (isTRUE(pop_fallback)) {
      message("calc_acs_by_geography: weight column not in data; using population ",
              "weight for: ", paste(wtdcols[missing_w], collapse = ", "))
      wts[missing_w] <- "pop"
    }
  }
  keep    <- wts %in% allcols
  wtdcols <- wtdcols[keep]
  wts     <- wts[keep]

  # Per weighted-mean indicator: numerator product (value * weight) and an
  # effective weight (the weight, but only where the value is present).
  numnames <- paste0("..num..", wtdcols)
  wgtnames <- paste0("..wgt..", wtdcols)
  for (i in seq_along(wtdcols)) {
    cc <- as.numeric(DT[[wtdcols[i]]])
    dd <- as.numeric(DT[[wts[i]]])
    data.table::set(DT, j = numnames[i], value = cc * dd)
    data.table::set(DT, j = wgtnames[i],
                    value = data.table::fifelse(is.na(cc), NA_real_, dd))
  }

  id_names <- c(blockgroup = "bgfips", tract = "tractfips",
                county = "countyfips", state = "statefips")
  nchars   <- c(blockgroup = 12L, tract = 11L, county = 5L, state = 2L)
  aggcols  <- c(sumcols, numnames, wgtnames)

  result <- list()
  for (lv in levels) {
    DT[, ".geoid" := substr(fips, 1L, nchars[[lv]])]
    agg <- DT[, lapply(.SD, sum, na.rm = TRUE), by = ".geoid", .SDcols = aggcols]
    for (i in seq_along(wtdcols)) {
      w <- agg[[wgtnames[i]]]
      data.table::set(agg, j = wtdcols[i],
                      value = data.table::fifelse(!is.na(w) & w > 0,
                                                  agg[[numnames[i]]] / w, NA_real_))
    }
    if (length(numnames)) agg[, c(numnames, wgtnames) := NULL]
    data.table::setnames(agg, ".geoid", id_names[[lv]])
    df <- as.data.frame(agg)
    result[[lv]] <- df
    if (!is.null(out_dir)) {
      if (!dir.exists(out_dir)) {
        dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      }
      utils::write.csv(df, file.path(out_dir, paste0("acs_by_", lv, ".csv")),
                       row.names = FALSE)
    }
  }
  if (length(numnames)) DT[, c(numnames, wgtnames) := NULL]
  DT[, ".geoid" := NULL]
  result
}
################################################# ################################### #
