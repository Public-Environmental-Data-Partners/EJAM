
#' Weighted means of several indicators at once, where each can have its own weight
#'
#' @description For each group (such as each site), calculates the weighted
#'   mean of each indicator across blockgroups. The weight for an indicator in a
#'   blockgroup is the blockgroup weight (the share of the blockgroup that is
#'   included) times that indicator's own weight, such as population or number
#'   of households.
#'
#' @details A blockgroup is used for an indicator only if the indicator, its
#'   weight, and the blockgroup weight all have a value there. If the weights
#'   used for a group add up to zero, the result is NA.
#'
#'   dt is not changed.
#'
#' @param dt data.frame or data.table with one row per blockgroup in each group
#' @param score_colnames names of the columns of dt to average. Default is the
#'   weighted-mean indicators built into EJAM that are columns of dt.
#' @param wts_bg_colname name of the column of dt with the blockgroup weight
#' @param wts_denom_colnames name of the column of dt to use as the weight for
#'   each indicator, one per element of score_colnames (or a single name to use
#'   for all). Default is the weight EJAM uses for each, from [calcweight()].
#' @param by_colname name of the column of dt that identifies the group, such
#'   as "ejam_uniq_id". Use NULL to get one overall row.
#'
#' @return data.table with one row per group, with the by_colname column
#'   (unless NULL) and one column per indicator
#'
#' @examples
#' dt <- data.frame(ejam_uniq_id = c(1, 1, 2), bgwt = c(1, 0.5, 1),
#'   pop = c(100, 200, 50), hhlds = c(40, 80, 20),
#'   score_a = c(0.2, 0.4, 0.9), score_b = c(10, 20, NA))
#' EJAM:::calc_wtdmeans(dt, c("score_a", "score_b"), wts_denom_colnames = c("pop", "hhlds"))
#'
#' @seealso [mydata_doaggregate()] [calcweight()]
#'
#' @keywords internal
#'
calc_wtdmeans <- function(dt,
                          score_colnames = NULL,
                          wts_bg_colname = "bgwt",
                          wts_denom_colnames = NULL,
                          by_colname = "ejam_uniq_id") {

  if (is.null(score_colnames)) {
    score_colnames <- intersect(names_all_r[calctype(names_all_r) %in% c("wtdmean")], names(dt))
  }
  if (is.null(wts_denom_colnames)) {
    wts_denom_colnames <- calcweight(score_colnames)
  }
  if (length(wts_denom_colnames) == 1) {
    wts_denom_colnames <- rep(wts_denom_colnames, length(score_colnames))
  }
  if (length(wts_denom_colnames) != length(score_colnames)) {
    stop("wts_denom_colnames must have one weight column name per indicator in score_colnames")
  }
  needed <- unique(c(score_colnames, wts_bg_colname, wts_denom_colnames, by_colname))
  if (!all(needed %in% names(dt))) {
    stop("columns not found in dt: ", paste0(setdiff(needed, names(dt)), collapse = ", "))
  }
  if (is.null(by_colname)) {
    groups <- rep(1L, NROW(dt))
    group_ids <- NULL
  } else {
    group_ids <- unique(dt[[by_colname]])
    groups <- match(dt[[by_colname]], group_ids)
  }
  ngroups <- max(1L, length(group_ids))
  bgwt <- dt[[wts_bg_colname]]
  out <- lapply(seq_along(score_colnames), function(i) {
    x <- dt[[score_colnames[i]]]
    w <- bgwt * dt[[wts_denom_colnames[i]]]
    ok <- !is.na(x) & !is.na(w)
    num <- den <- rep(0, ngroups)
    if (any(ok)) {
      sums <- rowsum(cbind(x[ok] * w[ok], w[ok]), groups[ok], reorder = FALSE)
      here <- as.integer(rownames(sums))
      num[here] <- sums[, 1]
      den[here] <- sums[, 2]
    }
    ifelse(den > 0, num / den, NA_real_)
  })
  names(out) <- score_colnames
  out <- data.table::as.data.table(out)
  if (!is.null(by_colname)) {
    out <- cbind(stats::setNames(data.table::data.table(group_ids), by_colname), out)
  }
  return(out)
}
