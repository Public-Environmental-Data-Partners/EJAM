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
#' In the annual pipeline these layers are produced by the `ejscreen_export` stage
#' of [calc_ejscreen_dataset()] when `include_ejscreen_export` is `TRUE`: it calls
#' [calc_ejscreen_threshold_layers_from_exports()] on the national and state
#' exports and saves them under the registered stage names
#' `ejscreen_threshold_us_ejindexes`, `ejscreen_threshold_us_supplemental`,
#' `ejscreen_threshold_state_ejindexes`, and
#' `ejscreen_threshold_state_supplemental`. (Issue #395 part (a) — the US/State
#' percentile CSVs — is the existing `ejscreen_export` / `ejscreen_export_statepct`;
#' part (c) — the ACS-by-geography layers — is [calc_acs_by_geography()].)
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

#' Build the four EJSCREEN threshold layers from the national + state exports
#'
#' Convenience wrapper used by the pipeline's `ejscreen_export` stage: it builds
#' the four web-app threshold layers (issue #395 part b) directly from the
#' per-block-group EJ-index percentile-rank columns that [calc_ejscreen_export()]
#' already placed in the national export (`ejscreen_export`) and the
#' state-percentile export (`ejscreen_export_statepct`).
#'
#' @details
#' The EJ-index percentile ranks are the `P_D2_*` columns (national/state EJ
#' indexes) and the `P_D5_*` columns (supplemental). The national export supplies
#' the US layers and the state-percentile export supplies the State layers (its
#' `P_D2_*`/`P_D5_*` fields hold state percentiles). Each layer is passed through
#' [calc_ejscreen_threshold_layers()] to add the `P1`..`P100` hit-count columns.
#'
#' @param national The `ejscreen_export` (national-percentile) data.frame.
#' @param statepct The `ejscreen_export_statepct` (state-percentile) data.frame.
#'   If `NULL`, only the US layers are built.
#' @param id_col Optional id column name; auto-detected from `c("ID","bgfips","bgid")`.
#' @return A named list with the available members of `us_ejindexes`,
#'   `us_supplemental`, `state_ejindexes`, `state_supplemental`.
#' @seealso [calc_ejscreen_threshold_layers()] [calc_ejscreen_export()]
#' @export
#'
calc_ejscreen_threshold_layers_from_exports <- function(national = NULL,
                                                        statepct = NULL,
                                                        id_col = NULL) {
  pick_id <- function(df) {
    if (!is.null(id_col) && id_col %in% names(df)) return(id_col)
    for (cand in c("ID", "bgfips", "bgid")) if (cand %in% names(df)) return(cand)
    names(df)[1]
  }
  result <- list()
  if (!is.null(national) && is.data.frame(national) && nrow(national) > 0) {
    idc <- pick_id(national)
    result <- c(result, calc_ejscreen_threshold_layers(
      pctiles = national, id_col = idc,
      layers = c("us_ejindexes", "us_supplemental"),
      cols_us_ej   = grep("^P_D2_", names(national), value = TRUE),
      cols_us_supp = grep("^P_D5_", names(national), value = TRUE),
      cols_state_ej = character(0), cols_state_supp = character(0)
    ))
  }
  if (!is.null(statepct) && is.data.frame(statepct) && nrow(statepct) > 0) {
    idc <- pick_id(statepct)
    result <- c(result, calc_ejscreen_threshold_layers(
      pctiles = statepct, id_col = idc,
      layers = c("state_ejindexes", "state_supplemental"),
      cols_state_ej   = grep("^P_D2_", names(statepct), value = TRUE),
      cols_state_supp = grep("^P_D5_", names(statepct), value = TRUE),
      cols_us_ej = character(0), cols_us_supp = character(0)
    ))
  }
  result
}
################################################# ################################### #
