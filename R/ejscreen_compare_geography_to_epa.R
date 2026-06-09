################################################# ################################### #

#' Replication check: compare an EJAM by-geography table to an EPA EJScreen reference
#'
#' Used by the annual-update "replication" steps to compare a pipeline output such
#' as `acs_by_tract` (or the per-block-group EJ-index percentile-rank / threshold
#' layers) against EPA's published EJScreen values. EPA exposes these as ArcGIS
#' **FeatureServers** (e.g. the `EJScreen_Census` service's `by_Tract` layer), not
#' as archived CSVs in the S3 pipeline folders, so the EPA `reference` is typically
#' fetched live from a feature server rather than read from a stage file.
#'
#' @details
#' The comparison: (1) repair FIPS leading zeros on both id columns with
#' [fips_lead_zero()]; (2) map EPA's ACS-style column names (e.g. `TOTALPOP`,
#' `PCT_LOWINC`) to EJAM `rname`s with [fixcolnames()]; (3) inner-join on the id;
#' (4) for each shared indicator report n, correlation, and median absolute
#' difference. EPA stores percentages as 0-100 while EJAM stores fractions 0-1, so
#' percentage indicators are scaled by `pct_scale` (default 100) before comparison.
#' This only checks indicators EJAM actually has; EPA's extra "extensive ACS"
#' demographics are ignored. It is meaningful only when the pipeline build and the
#' EPA reference are the same ACS vintage (e.g. both ACS 2018-2022).
#'
#' @param ejam_table EJAM output (e.g. `acs_by_tract`) with `ejam_fips_col` and
#'   EJAM `rname` indicator columns.
#' @param reference EPA reference table (e.g. the `attributes` from a
#'   `EJScreen_Census/.../by_Tract` feature-server query) with `reference_fips_col`
#'   and EPA ACS-style column names.
#' @param ejam_fips_col,reference_fips_col Id columns. Defaults `"tractfips"` and
#'   `"STCNTR"` (EPA's full 11-digit tract GEOID field).
#' @param reference_cols EPA columns to compare; default is all non-id columns.
#' @param pct_scale Factor applied to EJAM percentage columns to match EPA's 0-100
#'   scale. Default `100`.
#' @return A data.frame, one row per compared indicator: `reference`, `rname`, `n`,
#'   `cor`, `median_absdiff` (sorted worst-agreement first), with attribute
#'   `"n_joined"`.
#' @seealso [calc_acs_by_geography()] [fixcolnames()] [fips_lead_zero()]
#' @export
#'
ejscreen_compare_geography_to_epa <- function(ejam_table,
                                              reference,
                                              ejam_fips_col = "tractfips",
                                              reference_fips_col = "STCNTR",
                                              reference_cols = NULL,
                                              pct_scale = 100) {
  ej <- as.data.frame(ejam_table)
  ep <- as.data.frame(reference)
  stopifnot(ejam_fips_col %in% names(ej), reference_fips_col %in% names(ep))

  ej$.key <- fips_lead_zero(as.character(ej[[ejam_fips_col]]))
  ep$.key <- fips_lead_zero(as.character(ep[[reference_fips_col]]))
  if (is.null(reference_cols)) {
    reference_cols <- setdiff(names(reference), c(reference_fips_col, ".key"))
  }
  rn <- fixcolnames(reference_cols, "acs", "r")  # EPA ACS names -> EJAM rnames

  m <- merge(ej, ep, by = ".key")
  rows <- list()
  for (i in seq_along(reference_cols)) {
    rname <- rn[i]
    if (is.na(rname) || !(rname %in% names(ej))) next
    e <- suppressWarnings(as.numeric(m[[reference_cols[i]]]))
    g <- suppressWarnings(as.numeric(m[[rname]]))
    is_pct <- grepl("PCT", reference_cols[i], ignore.case = TRUE) ||
              grepl("^pct", rname)
    if (isTRUE(is_pct)) g <- g * pct_scale
    ok <- is.finite(e) & is.finite(g)
    if (sum(ok) < 2L) next
    rows[[length(rows) + 1L]] <- data.frame(
      reference = reference_cols[i], rname = rname, n = sum(ok),
      cor = stats::cor(e[ok], g[ok]),
      median_absdiff = stats::median(abs(g[ok] - e[ok])),
      stringsAsFactors = FALSE
    )
  }
  out <- if (length(rows)) do.call(rbind, rows) else
    data.frame(reference = character(), rname = character(), n = integer(),
               cor = numeric(), median_absdiff = numeric())
  out <- out[order(out$cor), , drop = FALSE]
  attr(out, "n_joined") <- nrow(m)
  out
}
################################################# ################################### #
