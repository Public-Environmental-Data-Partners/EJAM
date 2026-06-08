################################################# ################################### #

#' Aggregate block-group ACS indicators up to tract, county, and state
#'
#' Part (c) of issue #395: roll block-group ACS demographic values up to tract,
#' county, and state for the EJSCREEN web app's "additional demographics" (and
#' side-by-side) layers.
#'
#' @details
#' Aggregation follows the same metadata that [doaggregate()] uses, stored in
#' `map_headernames`:
#' \itemize{
#'   \item `calculation_type == "sum of counts"` columns are summed within each
#'     geography (population counts, the ACS universes/denominators, etc.).
#'   \item `calculation_type == "wtdmean"` columns are recomputed as a
#'     denominator-weighted mean, `sum(value * denominator) / sum(denominator)`,
#'     where each indicator's weight is its `map_headernames$denominator` count
#'     column. A block group is left out of a given indicator's weight where its
#'     value is `NA`, so the weighted mean is taken only over block groups that
#'     have that indicator.
#' }
#' Percentile (`lookedup`), `ratio to avg`, and map bin/text columns are **not**
#' recomputed here -- those need geography-level distributions / lookups and are a
#' separate step (see issue #395). The geography id is the leading FIPS digits of
#' `bgfips`: 12 = block group, 11 = tract, 5 = county, 2 = state.
#'
#' @param bg Block-group table with `id_col` and ACS indicator columns. Defaults
#'   to [blockgroupstats].
#' @param id_col Block-group FIPS column name. Default `"bgfips"`.
#' @param levels Any of `"blockgroup"`, `"tract"`, `"county"`, `"state"`.
#' @param mapping Metadata table with `rname`, `calculation_type`, and
#'   `denominator` columns. Defaults to [map_headernames].
#' @param out_dir Optional directory; if set, each level is written there as
#'   `acs_by_<level>.csv`.
#' @return A named list of data.frames, one per requested level: the geography
#'   FIPS id column, the summed count columns, and the recomputed weighted-mean
#'   indicator columns.
#' @seealso [doaggregate()] [calc_ejscreen_export()] [calc_ejscreen_threshold_layers()]
#' @export
#'
calc_acs_by_geography <- function(
    bg = blockgroupstats,
    id_col = "bgfips",
    levels = c("blockgroup", "tract", "county", "state"),
    mapping = map_headernames,
    out_dir = NULL) {

  levels  <- match.arg(levels, several.ok = TRUE)
  stopifnot(id_col %in% names(bg))
  mapping <- as.data.frame(mapping)

  DT   <- data.table::as.data.table(bg)
  fips <- as.character(DT[[id_col]])

  # Which columns to sum vs weighted-mean, from the same metadata doaggregate uses.
  sumcols <- intersect(unique(mapping$rname[mapping$calculation_type == "sum of counts"]),
                       names(DT))
  wsel <- mapping$calculation_type == "wtdmean" &
          mapping$rname %in% names(DT) &
          mapping$denominator %in% names(DT) &
          nzchar(mapping$denominator)
  wmap <- unique(mapping[wsel, c("rname", "denominator")])

  # Per weighted-mean indicator: numerator product (value * denominator) and an
  # effective weight (the denominator, but only where the value is present).
  # Summed per geography, then divided, this yields sum(v*d)/sum(d) over the
  # block groups that actually have the indicator.
  numnames <- paste0("..num..", wmap$rname)
  wgtnames <- paste0("..wgt..", wmap$rname)
  for (i in seq_len(nrow(wmap))) {
    cc <- as.numeric(DT[[wmap$rname[i]]])
    dd <- as.numeric(DT[[wmap$denominator[i]]])
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
    for (i in seq_len(nrow(wmap))) {
      w <- agg[[wgtnames[i]]]
      data.table::set(agg, j = wmap$rname[i],
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
  DT[, ".geoid" := NULL]
  result
}
################################################# ################################### #
