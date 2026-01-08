
  ## could be redone to replace doaggregate() code for ratios, around line 1500

# related # calc_pctile_columns(), calc_avg_columns(), calc_ratio_columns()


#' Calculate ratios to US and State average for each indicator in each place
#'
#' @param mytable table in [data.table](https://r-datatable.com) format with 1 row per place, 1 column per raw data indicator values
#' @param varnames column names of mytable that contain the raw indicator values (numerators of ratios)
#' @param varnames_avg column names of mytable that contain the US averages (denominators of ratios to US avg)
#' @param varnames_state_avg column names of mytable that contain the State averages (denominators of ratios to State avg)
#' @param varnames_ratio_to_avg optional names to use for the calculated ratios to US avg
#' @param varnames_ratio_to_state_avg optional names to use for the calculated ratios to State avg
#' @seealso [doaggregate()] [calc_avg_columns()] [calc_pctile_columns()]
#' @param varnames_state_special handles special case of ratio to state avg for Demog.Index and Demog.Index.Supp needing
#'  special numerator that is state-specific version of the index
#' @returns data.frame with 1 row per row of mytable and set of columns for US ratios and set of columns for State ratios
#' @details
#' For examples, see [calc_pctile_columns()]
#'
#' Note how averages (or percentiles) are defined in EJSCREEN data --
#'   technically it has been defined as average blockgroup (or percentile across blockgroups) in US or State,
#'   not average resident in US or State, but those are in most cases almost the same.
#'   Average resident and average blockgroup can be very different for a single analyzed site, however, or for the
#'   overall aggregate of several analyzed sites, and in those situations EJSCREEN calculates the average local resident's
#'   blockgroup score, not the average blockgroup score. In reporting ratios,
#'   those local average resident's values are still compared to the US or State "average" that is
#'   the average blockgroup in the US or State, so technically they are not exactly comparable, but in practice the ratio
#'   would be almost the same if compared to a population weighted average of all US blockgroups (i.e., the average US resident).
#'
#' @export
#' @keywords internal
#'
calc_ratio_columns = function(mytable,
                            varnames = names_these,
                            varnames_avg       = paste0(      "avg.", varnames) ,
                            varnames_state_avg = paste0("state.avg.", varnames),
                            varnames_ratio_to_avg       = paste0("ratio.to.", varnames_avg ),
                            varnames_ratio_to_state_avg = paste0("ratio.to.", varnames_state_avg),
                            varnames_state_special = c("Demog.Index.State", "Demog.Index.Supp.State")
                            ) {

  ## use names in original doaggregate() code
  results_bysite <- setDT(mytable)
  names_these           <- varnames
  names_these_avg       <- varnames_avg
  names_these_state_avg <- varnames_state_avg
  names_these_ratio_to_avg       <- varnames_ratio_to_avg
  names_these_ratio_to_state_avg <- varnames_ratio_to_state_avg

  if (!all(varnames_state_special %in% names(mytable))) {
    stop("mytable must have columns ", paste0(varnames_state_special, collapse = ", "))
  }

  ## RATIOS TO US AVG ###
  ratios_to_avg_bysite  <-
    results_bysite[, ..names_these] /
    results_bysite[, ..names_these_avg]

  # ratios_to_avg_overall <-
  #   results_overall[, ..names_these] /          # AVERAGE PERSON score OVERALL, RIGHT?
  #   results_overall[, ..names_these_avg]

  ## RATIOS TO STATE AVG ###
  ratios_to_state_avg_bysite  <-
    results_bysite[, ..names_these] /
    results_bysite[, ..names_these_state_avg]

  # ratios_to_state_avg_overall <-
  #   results_overall[, ..names_these] /
  #   results_overall[, ..names_these_state_avg]

  # add those all to results tables
  colnames(ratios_to_avg_bysite)  <- names_these_ratio_to_avg
  # colnames(ratios_to_avg_overall) <- names_these_ratio_to_avg
  colnames(ratios_to_state_avg_bysite)  <- names_these_ratio_to_state_avg
  # colnames(ratios_to_state_avg_overall) <- names_these_ratio_to_state_avg

  ############################### #
  ###>>>Demog.Index SPECIAL CASE FOR STATE RATIOS ####
  # use the state-specific versions of demog indexes as numerators
  #  i.e., use c("Demog.Index.State", "Demog.Index.Supp.State")
  # instead of c("Demog.Index",       "Demog.Index.Supp")

  ratios_to_state_avg_bysite$ratio.to.state.avg.Demog.Index.Supp <-
    results_bysite$Demog.Index.Supp.State /
    results_bysite$state.avg.Demog.Index.Supp

  # ratios_to_state_avg_overall$ratio.to.state.avg.Demog.Index.Supp <-
  #   results_overall$Demog.Index.Supp.State /
  #   results_overall$state.avg.Demog.Index.Supp

  ratios_to_state_avg_bysite$ratio.to.state.avg.Demog.Index <-
    results_bysite$Demog.Index.State /
    results_bysite$state.avg.Demog.Index

  # ratios_to_state_avg_overall$ratio.to.state.avg.Demog.Index <-
  #   results_overall$Demog.Index.State /
  #   results_overall$state.avg.Demog.Index

  results_bysite  <- cbind(results_bysite,  ratios_to_avg_bysite,  ratios_to_state_avg_bysite)   # collapse:: has a faster way than cbind here!
  # results_overall <- cbind(results_overall, ratios_to_avg_overall, ratios_to_state_avg_overall)
  ratios_columns <- cbind(ratios_to_avg_bysite,  ratios_to_state_avg_bysite)
  return(as.data.frame(ratios_columns))

  ### as drawn out of doaggregate()
  #
  # if (calculate_ratios) {
  #   # RATIO to AVERAGE  ####
  #   #
  #   ## RATIOS TO US AVG ###
  #   ratios_to_avg_bysite  <-
  #     results_bysite[, ..names_these] /
  #     results_bysite[, ..names_these_avg]
  #
  #   ratios_to_avg_overall <-
  #     results_overall[, ..names_these] /          # AVERAGE PERSON score OVERALL, RIGHT?
  #     results_overall[, ..names_these_avg]
  #
  #   ## RATIOS TO STATE AVG ###
  #   ratios_to_state_avg_bysite  <-
  #     results_bysite[, ..names_these] /
  #     results_bysite[, ..names_these_state_avg]
  #
  #   ratios_to_state_avg_overall <-
  #     results_overall[, ..names_these] /
  #     results_overall[, ..names_these_state_avg]
  #
  #   # add those all to results tables
  #   colnames(ratios_to_avg_bysite)  <- names_these_ratio_to_avg
  #   colnames(ratios_to_avg_overall) <- names_these_ratio_to_avg
  #   colnames(ratios_to_state_avg_bysite)  <- names_these_ratio_to_state_avg
  #   colnames(ratios_to_state_avg_overall) <- names_these_ratio_to_state_avg
  #
  #   ############################### #
  #   ###>>>Demog.Index SPECIAL CASE ####
  #
  #   ratios_to_state_avg_bysite$ratio.to.state.avg.Demog.Index.Supp <-
  #     results_bysite$Demog.Index.Supp.State /
  #     results_bysite$state.avg.Demog.Index.Supp
  #
  #   ratios_to_state_avg_overall$ratio.to.state.avg.Demog.Index.Supp <-
  #     results_overall$Demog.Index.Supp.State /
  #     results_overall$state.avg.Demog.Index.Supp
  #
  #   ratios_to_state_avg_bysite$ratio.to.state.avg.Demog.Index <-
  #     results_bysite$Demog.Index.State /
  #     results_bysite$state.avg.Demog.Index
  #
  #   ratios_to_state_avg_overall$ratio.to.state.avg.Demog.Index <-
  #     results_overall$Demog.Index.State /
  #     results_overall$state.avg.Demog.Index
  #   results_bysite  <- cbind(results_bysite,  ratios_to_avg_bysite,  ratios_to_state_avg_bysite)   # collapse:: has a faster way than cbind here!
  #   results_overall <- cbind(results_overall, ratios_to_avg_overall, ratios_to_state_avg_overall)
  # }
}
############################################################################################ #
