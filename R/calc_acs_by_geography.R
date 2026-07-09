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
#' Island Areas (American Samoa, Guam, the Northern Mariana Islands, the U.S.
#' Virgin Islands) have no standard ACS demographics, so by default
#' (`exclude_islandareas = TRUE`) their block groups are dropped before
#' aggregating. This matches EJAM's v3 decision that Island Area demographics are
#' unavailable by default (rather than emitting them with `na.rm` sums of `0`), and
#' matches EPA's ACS layer, which omits them. Puerto Rico is not an Island Area for
#' this purpose (it has standard ACS demographics) and is retained.
#'
#' @param bg Block-group table with `id_col` and ACS indicator columns. Defaults
#'   to [blockgroupstats]. Not modified (a copy is made internally).
#' @param id_col Block-group FIPS column name. Default `"bgfips"`; also used as the
#'   id column name in the block-group-level output. If the column is numeric, its
#'   leading zero is restored before parent GEOIDs are derived from it.
#' @param levels Any of `"blockgroup"`, `"tract"`, `"county"`, `"state"`.
#' @param pop_fallback If `TRUE` (default), weighted-mean indicators whose weight
#'   column is missing from the data fall back to population weighting, as in
#'   [doaggregate()]. If `FALSE`, such indicators are dropped.
#' @param exclude_islandareas If `TRUE` (default), drop Island Area block groups
#'   (AS/GU/MP/VI/UM) before aggregating -- identified by the `ST` column via
#'   [is.island()] when present (their FIPS are non-standard length). Set `FALSE`
#'   to keep them (they will have `0`/`NA` demographics).
#' @param out_dir Optional directory; if set, each level is written there as
#'   `acs_by_<level>.csv`.
#' @return A named list of data.frames, one per requested level: the geography
#'   FIPS id column, the summed count columns, and the recomputed weighted-mean
#'   indicator columns.
#' @seealso [doaggregate()] [calctype()] [calcweight()] [is.island()]
#'   [calc_ejscreen_export()] [calc_ejscreen_threshold_layers()]
#'
#' @keywords internal
#'
calc_acs_by_geography <- function(
    bg = blockgroupstats,
    id_col = "bgfips",
    levels = c("blockgroup", "tract", "county", "state"),
    pop_fallback = TRUE,
    exclude_islandareas = TRUE,
    out_dir = NULL) {

  levels <- match.arg(levels, several.ok = TRUE)
  stopifnot(id_col %in% names(bg))

  # Defensive copy so we never mutate a caller's data.table by reference (the
  # pipeline passes one). Block-group FIPS are character with leading zeros; do NOT
  # run fips_lead_zero() here -- Island Area FIPS are intentionally non-standard
  # (7-10 char) and it would turn them into NA.
  DT <- data.table::copy(data.table::as.data.table(bg))
  if (is.numeric(DT[[id_col]])) {
    # A numeric FIPS column has lost any leading zero (and as.character() can
    # yield scientific notation), so rebuild it: standard block-group FIPS are
    # 12 digits, meaning an 11-digit value is missing its leading zero. Island
    # Area FIPS are shorter (7-10 digits) and never start with 0, so unchanged.
    fips <- sprintf("%.0f", DT[[id_col]])
    fips[is.na(DT[[id_col]])] <- NA_character_
    fips <- data.table::fifelse(!is.na(fips) & nchar(fips) == 11L,
                                paste0("0", fips), fips)
  } else {
    fips <- as.character(DT[[id_col]])
  }

  # Exclude Island Areas (AS/GU/MP/VI/UM): non-standard FIPS, no standard ACS
  # demographics. Identify by the ST column when present (robust -- catches all of
  # them regardless of FIPS length), else by the 2-digit FIPS prefix.
  if (isTRUE(exclude_islandareas)) {
    isl <- if ("ST" %in% names(DT)) {
      is.island(ST = DT[["ST"]]) %in% TRUE
    } else {
      suppressWarnings(is.island(fips = substr(fips, 1L, 2L))) %in% TRUE
    }
    if (any(isl)) {
      DT   <- DT[!isl]
      fips <- fips[!isl]
    }
  }

  allcols <- names(DT)
  ctype   <- calctype(allcols)
  sumcols <- allcols[!is.na(ctype) & ctype == "sum of counts"]
  wtdcols <- allcols[!is.na(ctype) & ctype == "wtdmean"]
  wts     <- calcweight(wtdcols)   # each indicator's own denominator/weight column

  # Population-weight fallback for any weight column not present (matches doaggregate()).
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

  # Block-group output keeps the caller's id_col name; coarser levels get standard names.
  id_names <- c(blockgroup = id_col, tract = "tractfips",
                county = "countyfips", state = "statefips")
  nchars   <- c(blockgroup = 12L, tract = 11L, county = 5L, state = 2L)
  aggcols  <- intersect(c(sumcols, numnames, wgtnames), names(DT))

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
    drop_helpers <- intersect(c(numnames, wgtnames), names(agg))
    if (length(drop_helpers)) agg[, (drop_helpers) := NULL]
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
  # Drop helper/working columns from the internal copy before returning.
  if (".geoid" %in% names(DT)) DT[, ".geoid" := NULL]
  drop_helpers <- intersect(c(numnames, wgtnames), names(DT))
  if (length(drop_helpers)) DT[, (drop_helpers) := NULL]
  result
}
################################################# ################################### #
