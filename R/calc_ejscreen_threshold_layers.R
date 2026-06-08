################################################# ################################### #

#' Build the EJSCREEN web-app "thresholds" layers (P1..P100 hit counts)
#'
#' Produces the four "threshold map widget" layers requested for the EJSCREEN web
#' app in issue #395: `us_ejindexes`, `state_ejindexes`, `us_supplemental`, and
#' `state_supplemental`. Each layer has one row per block group containing the
#' per-index percentile ranks plus 100 columns `P1`..`P100` giving, for that block
#' group, how many of its EJ-index percentile ranks land at each integer
#' percentile (e.g. if a block group is at the 4th percentile for `P_D2_OZONE`
#' and no other D2 index rank is 4, then `P4 = 1`).
#'
#' @details
#' The `P1`..`P100` counts reuse the package's existing column-counting helper
#' [colcounter()]: for each integer percentile `k`, the per-block-group number of
#' indexes *equal to* `k` is the count at-or-above `k` minus the count at-or-above
#' `k + 1`, i.e. `colcounter(x, k) - colcounter(x, k + 1)` (percentile ranks are
#' rounded to integers first). This is the per-block-group analogue of the
#' `EXCEED_COUNT_*` fields in [calc_ejscreen_export()].
#'
#' The four layers differ only in which set of percentile columns they tabulate:
#' \itemize{
#'   \item `us_ejindexes` -> [names_ej_pctile] (national D2 EJ indexes)
#'   \item `state_ejindexes` -> [names_ej_state_pctile]
#'   \item `us_supplemental` -> [names_ej_supp_pctile] (national supplemental, D5)
#'   \item `state_supplemental` -> [names_ej_supp_state_pctile]
#' }
#'
#' To wire this into the annual pipeline as a stage: register stage names in
#' `ejscreen_pipeline_stage_names()`, gate it with an env var such as
#' `EJAM_INCLUDE_WEB_THRESHOLD_LAYERS`, and call this from
#' [calc_ejscreen_dataset()] after the export stages, saving each returned layer
#' with the pipeline IO helper. Parts (a) and (c) of issue #395 are out of scope
#' here (the US/State percentile CSVs largely reuse the existing
#' `ejscreen_us_pctile_lookup` / `ejscreen_state_pctile_lookup` exports; the
#' tract/county/state ACS layers need new aggregation of `blockgroupstats`).
#'
#' @param pctiles A data.frame, one row per block group, containing `id_col` and
#'   the EJ-index percentile-rank columns -- for example the output of
#'   [calc_ejscreen_export()] (which holds `P_D2_*` and `P_D5_*`), or a merge of
#'   the national and state exports so all four column sets are present.
#' @param id_col Name of the block-group id column to carry through. Default
#'   `"bgfips"`.
#' @param layers Which layers to build; any of `"us_ejindexes"`,
#'   `"state_ejindexes"`, `"us_supplemental"`, `"state_supplemental"`.
#' @param cols_us_ej,cols_state_ej,cols_us_supp,cols_state_supp Character vectors
#'   of the percentile-rank column names for each layer. Defaults are the EJAM
#'   name vectors [names_ej_pctile], [names_ej_state_pctile],
#'   [names_ej_supp_pctile], [names_ej_supp_state_pctile].
#' @param out_dir Optional directory; if supplied, each layer is written there as
#'   `<layer>.csv`.
#' @return A named list of data.frames, one per requested layer (the id column +
#'   the percentile-rank columns + `P1`..`P100`).
#' @seealso [colcounter()] [calc_ejscreen_export()] [calc_ejscreen_dataset()]
#' @export
#'
calc_ejscreen_threshold_layers <- function(
    pctiles,
    id_col = "bgfips",
    layers = c("us_ejindexes", "state_ejindexes",
               "us_supplemental", "state_supplemental"),
    cols_us_ej      = names_ej_pctile,
    cols_state_ej   = names_ej_state_pctile,
    cols_us_supp    = names_ej_supp_pctile,
    cols_state_supp = names_ej_supp_state_pctile,
    out_dir = NULL) {

  layers <- match.arg(layers, several.ok = TRUE)
  stopifnot(is.data.frame(pctiles), id_col %in% names(pctiles))

  layer_cols <- list(
    us_ejindexes       = cols_us_ej,
    state_ejindexes    = cols_state_ej,
    us_supplemental    = cols_us_supp,
    state_supplemental = cols_state_supp
  )

  result <- list()
  for (ly in layers) {
    want <- layer_cols[[ly]]
    have <- intersect(want, names(pctiles))
    miss <- setdiff(want, have)
    if (length(miss)) {
      warning("calc_ejscreen_threshold_layers: layer '", ly, "' is missing ",
              length(miss), " percentile column(s): ",
              paste(utils::head(miss, 5), collapse = ", "),
              if (length(miss) > 5) ", ..." else "")
    }
    if (!length(have)) {
      warning("calc_ejscreen_threshold_layers: no percentile columns found for ",
              "layer '", ly, "'; skipping.")
      next
    }
    # Per-block-group count AT each integer percentile k, derived from the
    # existing colcounter(): (# indexes >= k) - (# indexes >= k + 1).
    x  <- round(as.matrix(pctiles[, have, drop = FALSE]))
    ge <- vapply(
      1:101,
      function(k) colcounter(x, threshold = k, or.tied = TRUE, na.rm = TRUE),
      numeric(nrow(x))
    )
    if (is.null(dim(ge))) ge <- matrix(ge, nrow = nrow(x))  # 1-row edge case
    pcount <- ge[, 1:100, drop = FALSE] - ge[, 2:101, drop = FALSE]
    colnames(pcount) <- paste0("P", 1:100)

    layer_df <- cbind(pctiles[, c(id_col, have), drop = FALSE],
                      as.data.frame(pcount))
    result[[ly]] <- layer_df
    if (!is.null(out_dir)) {
      if (!dir.exists(out_dir)) {
        dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      }
      utils::write.csv(layer_df, file.path(out_dir, paste0(ly, ".csv")),
                       row.names = FALSE)
    }
  }
  result
}
################################################# ################################### #
