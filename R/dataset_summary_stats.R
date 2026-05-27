

#' Get summary stats for selected dataset columns
#'
#' @param vars vector of colnames found in dt
#' @param dt data.frame (can be data.table) to summarize
#' @param print logical. If TRUE, print the table.
#' @param commas logical. If TRUE, format numeric values with commas in the
#'   printed table. The returned data are not formatted.
#'
#' @return data.table, 1 row per variable name in vars. Invisibly returned.
#'
#' @examples
#' \dontrun{
#' dt = data.frame(
#'   traffic.score = c(726317, 645688, NA),
#'   pctunemployed = c(0, 0, 0.24))
#' vars = c('traffic.score', 'pctunemployed')
#' dataset_summary_stats(vars, dt)
#' }
#'
#' @noRd
#' @keywords internal
#'
dataset_summary_stats = function(vars = NULL,
                                  dt = NULL,
                                  print = TRUE,
                                  commas = print) {
  if (is.null(dt)) {
    stop("dt must be supplied", call. = FALSE)
  }
  if (is.null(vars)) {
    stop("vars must be supplied", call. = FALSE)
  }

  if (!data.table::is.data.table(dt)) {
    dt <- data.table::as.data.table(dt)
  }
  vars <- unique(as.character(vars))
  vars <- vars[nzchar(vars) & vars %in% names(dt)]

  if (length(vars) == 0) {
    out <- data.table::data.table(
      varlist = character(),
      rname = character(),
      NA_values = integer(),
      zero = integer(),
      non0nonNA = integer(),
      pctnon0nonNA = numeric(),
      length = integer(),
      uniques = integer()
    )
    if (isTRUE(print)) print(out)
    return(invisible(out))
  }

  stats_NA_values <- function(x) sum(is.na(x))
  stats_zero <- function(x) {
    if (!is.numeric(x) && !is.integer(x) && !is.logical(x)) {
      return(0L)
    }
    sum(!is.na(x) & x == 0)
  }
  stats_non0nonNA <- function(x) {
    if (!is.numeric(x) && !is.integer(x) && !is.logical(x)) {
      return(sum(!is.na(x)))
    }
    sum(!is.na(x) & x != 0)
  }
  stats_length <- function(x) length(x)
  stats_uniques <- function(x) length(unique(x))
  stats_pctnon0nonNA <- function(x) {
    if (length(x) == 0) {
      return(NA_real_)
    }
    round(stats_non0nonNA(x) / length(x), 3)
  }

  varlists <- rep(NA_character_, length(vars))
  if (exists("varinfo", inherits = TRUE)) {
    varlists <- suppressWarnings(varinfo(vars)$varlist)
  }

  out <- data.table::data.table(
    varlist = varlists,
    rname = vars,
    NA_values = vapply(dt[, ..vars], stats_NA_values, integer(1)),
    zero = vapply(dt[, ..vars], stats_zero, integer(1)),
    non0nonNA = vapply(dt[, ..vars], stats_non0nonNA, integer(1)),
    pctnon0nonNA = vapply(dt[, ..vars], stats_pctnon0nonNA, numeric(1)),
    length = vapply(dt[, ..vars], stats_length, integer(1)),
    uniques = vapply(dt[, ..vars], stats_uniques, integer(1))
  )

  if (isTRUE(print)) {
    out_print <- data.table::copy(out)
    if (isTRUE(commas)) {
      numeric_cols <- names(out_print)[vapply(out_print, is.numeric, logical(1))]
      out_print[, (numeric_cols) := lapply(.SD, prettyNum, big.mark = ","), .SDcols = numeric_cols]
    }
    print(out_print)
  }
  invisible(out)
}
