################### #################### #################### #################### #################### #################### #################### #

#' Check whether raw scores meet a percentile cutoff (e.g., to see which blockgroups are at high percentiles)
#'
#' @description
#' Compares one or more raw indicator values to the raw-score threshold that
#' corresponds to a specified percentile cutoff in [usastats] or [statestats].
#'
#' @details
#' To save space, blockgroupstats does not store the US and State percentiles
#' of all US blockgroups for all indicators -- it just has the raw scores.
#' Therefore one cannot easily check which blockgroups have raw scores that are
#' at or above a given percentile cutoff, without first converting the raw scores to percentiles
#'  with [lookup_pctile()] and then checking which percentiles are at or above the cutoff.
#' This function does that in a more efficient way by just looking up the raw score
#' that corresponds to the cutoff percentile in usastats or statestats,
#' and then comparing all the raw scores to that cutoff raw score.
#' It is a fast alternative to converting every raw score to a percentile with
#' [lookup_pctile()] and then checking whether that percentile is at or above the
#' requested cutoff.
#'
#' If `score` is omitted, values are taken from `blockgroupstats[[raw_score_name]]`.
#' If `ST = TRUE`, the function also takes states from `blockgroupstats$ST` and
#' ignores any user-supplied `score`.
#'
#' @param raw_score_name Character scalar. Name of the raw indicator column to
#'   evaluate, such as `"pctlowinc"` or `"o3"`. It must exist in
#'   [usastats] and [blockgroupstats].
#' @param cutoff Numeric scalar from 0 to 1. Percentile cutoff expressed as a
#'   fraction, for example `0.90` for the 90th percentile.
#' @param score Optional numeric vector of raw values to compare to the cutoff.
#'   If omitted or `NULL`, the function uses the column named by
#'   `raw_score_name` from [blockgroupstats].
#' @param ST Either `FALSE`/`NULL` for nationwide percentiles, `TRUE` to use
#'   `blockgroupstats$ST`, or a character vector of state abbreviations the same
#'   length as `score` for state-specific comparisons.
#'
#' @return Logical vector the same length as `score`, indicating if each raw
#'   score is at or above the requested percentile cutoff.
#'
#' @seealso [lookup_pctile()] [pctile_from_raw_lookup()] [calc_pctile_columns()]
#'
#' @examples \donttest{
#'
#'   # Which blockgroups have a raw score at/above a specified raw score cutoff?
#'
#'    # Which ones have % unemployed of at least 99%?
#'    blockgroupstats[  pctunemployed >= 0.99, 1:12]
#'
#'  # What % of blockgroups have a raw score at/above a specified raw score cutoff?
#'
#'    # What % of places have % unemployed of at least 50%?
#'    round(table(
#'      pct.with.at.least.50pct.unemployed =
#'      blockgroupstats$pctunemployed >= 0.50) /
#'      nrow(blockgroupstats)*100, 2)
#'
#'
#'   # Which blockgroups have a raw score at/above a specified percentile?
#'
#'     these <- pctile_x_is_hit_by_score("pctunemployed", cutoff = 0.95)
#'     blockgroupstats[these, 1:12]
#'
#'   # What % of blockgroups have a raw score at/above a specified percentile?
#'
#'     these <- pctile_x_is_hit_by_score("pctunemployed", cutoff = 0.95)
#'     round(table(percent.that.are.high = these)/NROW(these) * 100, 2)
#'     # About 5% of US blockgroups are at/above 95th percentile as expected
#'
#'
#' pctile_x_is_hit_by_score("pctlowinc", cutoff = 0.80, score = c(0.1, 0.33, 0.50))
#'
#' testrows <- c(14840L, 96520L, 105100L)
#' pctile_x_is_hit_by_score(
#'   "pctlowinc",
#'   cutoff = 0.80,
#'   score = EJAM::blockgroupstats$pctlowinc[testrows],
#'   ST = EJAM::blockgroupstats$ST[testrows]
#' )
#' blockgroupstats[testrows, .(bgfips, ST, pop, pctlowinc)]
#'
#' }
#'
#' @keywords internal
#'
#' @export

pctile_x_is_hit_by_score <- function(raw_score_name, cutoff = 0.90, score = NULL, ST = FALSE) {

  if (isFALSE(ST)) {ST <- NULL}
  if (isTRUE(ST)) {
    if (!missing(score) && !is.null(score)) {
      warning("ignoring score you specified! Should not specify score if ST = TRUE, because if ST=TRUE it assumes ST = blockgroupstats$ST and score will be taken from raw_score_name column of blockgroupstats")
      score <- NULL
    }
    ST <- EJAM::blockgroupstats$ST
  }

  stopifnot(!missing(raw_score_name), !is.null(raw_score_name), !all(is.na(raw_score_name)),
            length(raw_score_name) == 1, is.character(raw_score_name),
            raw_score_name %in% colnames(EJAM::usastats) & raw_score_name %in% colnames(EJAM::blockgroupstats) & raw_score_name != "REGION")
  # note bgej is a separate table that contains the raw EJ index scores, so this function will need to be modified to work with those
  # or you can specify score as a vector of raw EJ index scores since their percentiles are in usastats and statestats.

  stopifnot(!is.null(cutoff), !all(is.na(cutoff)),
            length(cutoff) == 1, is.numeric(cutoff))
  if (cutoff > 1 || cutoff < 0)  {
    stop("cutoff must be a percentile value given as a fraction 0 through 100")
  }
  if (cutoff != round(cutoff, 2)) {
    warning("cutoff should be rounded to 2 decimal places - must be like 0.90 or 0.91 so it is an integer when expressed as 0-100, since cutoffs are defined that way. using ", round(cutoff, 2), " instead.")
    cutoff <- round(cutoff, 2)
  }
  CUTOFF <- 100 * cutoff
  cutoff_label <- as.character(CUTOFF)

  if (missing(score) || is.null(score)) {
    score <- EJAM::blockgroupstats[[raw_score_name]]
  } else {
    stopifnot(!all(is.na(score)), is.numeric(score))
  }

  stopifnot(is.null(ST) || (is.character(ST) && all(ST %in% EJAM::statestats$REGION)))
  if (!is.null(ST)) {
    stopifnot(length(score) == length(ST))
  }

  if (is.null(ST)) {
    # look in usastats
    # in the row where the PCTILE column has a PCTILE == CUTOFF percentile specified,
    # and get the raw score that is in the column named raw_score_name.
    score_at_that_pctile_cutoff <- EJAM::usastats[
      as.character(EJAM::usastats$PCTILE) == cutoff_label,
      raw_score_name,
      drop = TRUE
    ][1]
    return(unname(score >= score_at_that_pctile_cutoff))
  } else {
    #
    # one approach would be to use EJAM::lookup_pctile() to get pctile for every element of score (typically >200k block groups)
    # and then compare all those to the cutoff to which ones do or do not hit the cutoff.
    # That can be a bit slow since it has to do a lookup for each element of score, grouped by ST,
    # but it is straightforward and uses the lookup_pctile() function that is used by EJAM to convert raw scores to pctiles for reports on places.

    # instead, we can just see what raw score the cutoff pctile corresponds to, and compare all scores to that cutoff, which probably is faster.
    # look in statestats
    # and see which unique ST values are found in parameter ST,
    # then for each of those, get the score_at_that_pctile_cutoff for that ST from statestats,
    # by using the statestats$REGION column to find the row for that ST, and
    # then the column named by the value of raw_score_name to
    # get the score at the cutoff percentile for that ST, and then compare the score vector to those cutoffs for each ST.
    ## That could, for each state, use the same code as above usastats used,
    # except here for each you use a subset of statestats where statestats$REGION == unique_ST[i]
    # and use that for all the elements of score where ST == unique_ST[i]

    unique_ST <- unique(ST)
    score_at_cutoff_for_each_ST <- sapply(unique_ST, function(st) {
      EJAM::statestats[
        EJAM::statestats$REGION == st &
          as.character(EJAM::statestats$PCTILE) == cutoff_label,
        raw_score_name,
        drop = TRUE
      ][1]
    })
    names(score_at_cutoff_for_each_ST) <- unique_ST
    # now we have a named vector of score_at_cutoff_for_each_ST, with names that are the unique ST values
    # now we can compare the score vector to the appropriate cutoff for each element of score,
    # by using the ST vector to match the appropriate cutoff for each element of score, and
    # return a logical vector of whether each element of score is >= the appropriate cutoff for its ST.
    return(unname(score >= score_at_cutoff_for_each_ST[ST]))
  }


}
################### #################### #################### #################### #################### #################### #################### #

# another way, to compare it to but probably slower

pctile_x_is_hit_by_score2 = function(raw_score_name, cutoff = 0.90, score=NULL, ST = FALSE) {

  if (isFALSE(ST)) {ST <- NULL}
  if (isTRUE(ST)) {
    if (!missing(score) && !is.null(score)) {
      warning("ignoring score you specified! Should not specify score if ST = TRUE, because if ST=TRUE it assumes ST = blockgroupstats$ST and score will be taken from raw_score_name column of blockgroupstats")
      score <- NULL
    }
    ST <- EJAM::blockgroupstats$ST
  }
  stopifnot(!missing(raw_score_name), !is.null(raw_score_name), !all(is.na(raw_score_name)),
            length(raw_score_name) == 1, is.character(raw_score_name),
            raw_score_name %in% colnames(EJAM::usastats) & raw_score_name %in% colnames(EJAM::blockgroupstats) & raw_score_name != "REGION")
  stopifnot(!is.null(cutoff), !all(is.na(cutoff)),
            length(cutoff) == 1, is.numeric(cutoff))
  if (cutoff > 1 || cutoff < 0)  {
    stop("cutoff must be a percentile value given as a fraction 0 through 100")
  }
  if (cutoff != round(cutoff, 2)) {
    warning("cutoff should be rounded to 2 decimal places - must be like 0.90 or 0.91 so it is an integer when expressed as 0-100, since cutoffs are defined that way. using ", round(cutoff, 2), " instead.")
    cutoff <- round(cutoff, 2)
  }
  CUTOFF <- 100 * cutoff

  if (missing(score) || is.null(score)) {
    score <- EJAM::blockgroupstats[[raw_score_name]]
  } else {
    stopifnot(!all(is.na(score)), is.numeric(score))
  }

  stopifnot(is.null(ST) || (is.character(ST) && all(ST %in% EJAM::statestats$REGION)))
  if (!is.null(ST)) {
    stopifnot(length(score) == length(ST))
  }
  if (is.null(ST))  {
    ST <- "USA" # for this version, which uses lookup_pctile()
    lookuptable <- usastats
  } else {
    lookuptable <- statestats
  }

  pctiles_of_scores <- EJAM::lookup_pctile(score, varname.in.lookup.table = raw_score_name, zone = ST, lookup = lookuptable)
  return(pctiles_of_scores >= CUTOFF)
}
################### #################### #################### #################### #################### #################### #################### #
