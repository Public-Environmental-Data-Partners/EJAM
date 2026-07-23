
#  see table or plot, of ratios of flagged areas and features / US ####

################## #

#' barplot of summary stats on special areas and features at the sites
#' @description Summary of whether residents at the analyzed locations are more likely to have
#' certain types of features (schools) or special areas (Tribal, nonattainment, etc.)
#' @details  See
#' `varinfo(c(names_featuresinarea, names_flag, names_criticalservice))[,c("longname", "varlist")]`
#'
#' These are the indicator summary stats shown:
#'
#'  -  "Number of Schools"
#'
#'  -  "Number of Hospitals"
#'
#'  -  "Number of Worship Places"
#'
#'  -  "Flag for Overlapping with Tribes"
#'
#'  -  "Flag for Overlapping with Non-Attainment Areas"
#'
#'  -  "Flag for Overlapping with Impaired Waters"
#'
#'  -  "Flag for Overlapping with CEJST Disadvantaged Communities"
#'
#'  -  "Flag for Overlapping with EPA IRA Disadvantaged Communities"
#'
#'  -  "Flag for Overlapping with Housing Burden Communities"
#'
#'  -  "Flag for Overlapping with Transportation Disadvantaged Communities"
#'
#'  -  "Flag for Overlapping with Food Desert Areas"
#'
#'  -  "% Households without Broadband Internet"
#'
#'  -  "% Households without Health Insurance"
#'
#'
#' @param ejamitout output from ejamit()
#' @param main optional title for plot. If NULL (default), a title is chosen
#'   based on the `vs` parameter.
#' @param ylab optional y axis label. If NULL (default), a label is chosen
#'   based on the `vs` parameter.
#' @param shortlabels optional alternative labels for the bars
#' @param vs "us" (default) to plot ratios to the US average,
#'   or "state" to plot ratios to the average in the State(s) analyzed
#'   (population-weighted across the states of the residents analyzed).
#'   "state" requires ejamitout to have the ratio_to_state_avg column
#'   in results_summarized$flagged_areas (from a current version of ejamit()).
#' @seealso [ejam2areafeatures()] [batch.summarize()]
#' @examples
#' out <- testoutput_ejamit_1000pts_1miles
#' ejam2barplot_areafeatures(out)
#'
#' shortlabels = EJAM:::flagged_areas_shortlabels_from_ejam(out)
#' ejam2barplot_areafeatures(out, shortlabels = shortlabels)
#'
#' # ratios to State averages instead of US averages:
#' if ("ratio_to_state_avg" %in% names(ejam2areafeatures(out))) {
#'   ejam2barplot_areafeatures(out, vs = "state")
#' }
#'
#' @return ggplot2 plot
#'
#' @export
#'
ejam2barplot_areafeatures <- function(ejamitout,
                                      main = NULL,
                                      ylab = NULL,
                                      shortlabels = NULL,
                                      vs = c("us", "state")) {

  vs <- match.arg(tolower(vs[1]), c("us", "state"))
  if (vs == "state") {
    fa <- ejamitout$results_summarized$flagged_areas
    if (is.null(fa) || !("ratio_to_state_avg" %in% names(fa)) || all(is.na(fa$ratio_to_state_avg))) {
      stop("No ratios to State averages found in ejamitout$results_summarized$flagged_areas - ",
           "re-run ejamit() with a current version of EJAM to get the ratio_to_state_avg column, or use vs = 'us'")
    }
    ratiocolname <- "ratio_to_state_avg"
    # note plot_barplot_ratios() keys its legend text off the word "State" appearing in main
    if (is.null(main)) {main <- paste0(
      "% of analyzed population",
      " that lives in blockgroups with given features",
      " or that overlap given area type, vs State averages")}
    if (is.null(ylab)) {ylab <- "Ratio of Indicator in Analyzed Locations / in State(s) Analyzed"}
  } else {
    ratiocolname <- "ratio"
    if (is.null(main)) {main <- paste0(
      "% of analyzed population",
      " that lives in blockgroups with given features",
      " or that overlap given area type")}
    if (is.null(ylab)) {ylab <- "Ratio of Indicator in Analyzed Locations / in US Overall"}
  }

  ratios <- flagged_areas_ratios_from_ejam(ejamitout, ratiocolname = ratiocolname)
  plot_barplot_ratios(ratios, main = main, ylab = ylab,
                      shortlabels = shortlabels,
                      caption = "")
}
######################################################### # ######################################################### #
######################################################### # ######################################################### #

################## #

#' simple way to see the table of summary stats on special areas and features like schools
#'
#' @param ejamitout output from ejamit()
#' @details
#' In this table, summary stats mean the following:
#'
#' - The "flag" or "yesno" indicators here are population weighted sums, so they show
#'   how many people from the analysis live in blockgroups
#'   that overlap with the given special type of area, such as
#'   non-attainment areas under the Clean Air Act.
#'
#' - The "number" indicators are counts for each site in the
#'   `ejamit()$results_overall` table, but here are summarized as
#'   what percent of residents overall in the analysis have
#'   AT LEAST ONE OR MORE of that type of site in
#'   the blockgroup they live in.
#'
#' - The "pctno" or % indicators are summarized as what % of the
#'   residents analyzed lack the critical service.
#'
#' The columns of the table are:
#'
#' - `Indicator` - plain-English name of the indicator
#' - `Percent_of_these_Sites` - % of the analyzed sites where the indicator is
#'   present/flagged (or the average of the site-level percentages, for the two % indicators)
#' - `Percent_of_these_People` - % of the analyzed residents living in a
#'   blockgroup with the feature or overlap
#' - `Percent_of_all_People_Nationwide` - the same % but among all US residents
#' - `ratio` - Percent_of_these_People / Percent_of_all_People_Nationwide
#' - `Percent_of_all_People_Statewide` - the same % but among all residents of the
#'   state(s) analyzed. Where sites span multiple states, this is the average of
#'   the state-level percentages weighted by the analyzed population in each state
#'   (i.e., the average among all the residents at these sites, using the statewide
#'   value in each resident's state), analogous to how ratios to State averages
#'   are calculated for other indicators in `results_overall`.
#' - `ratio_to_state_avg` - Percent_of_these_People / Percent_of_all_People_Statewide
#' - `rname` - the variable name of the indicator, like "num_school" or "yesno_tribal"
#'
#' @return a data frame with the summary of flagged areas
#' @seealso [ejam2barplot_areafeatures()] [batch.summarize()]
#'
#' @export
#'
ejam2areafeatures <- function(ejamitout) {

  ejamitout$results_summarized$flagged_areas
}
################## #
# same as ejam2areafeatures - just a more consistent but less easy-to-type/recall name, used by other internal functions

#' get flagged areas summary table from ejamit() output
#' @param ejamitout output from ejamit()
#' @return data.frame, same as [ejam2areafeatures()]
#' @keywords internal
#' @noRd
flagged_areas_from_ejam <- function(ejamitout) {
  ejamitout$results_summarized$flagged_areas
}
################## #

# count certain areas overlapped & if certain features are here ####

# Helper functions used by batch.summarize() to summarize info from these indicators:
#
#  c(names_featuresinarea, names_flag, names_criticalservice) # the varlists
#
# > varinfo(c(names_featuresinarea, names_flag, names_criticalservice))[,c("longname", "varlist")]
#                                                                                longname               varlist
# num_school                                                            Number of Schools  names_featuresinarea
# num_hospital                                                        Number of Hospitals  names_featuresinarea
# num_church                                                     Number of Worship Places  names_featuresinarea
# yesno_tribal                                           Flag for Overlapping with Tribes            names_flag
# yesno_airnonatt                          Flag for Overlapping with Non-Attainment Areas            names_flag
# yesno_impwaters                               Flag for Overlapping with Impaired Waters            names_flag
# yesno_cejstdis                Flag for Overlapping with CEJST Disadvantaged Communities            names_flag
# yesno_iradis                Flag for Overlapping with EPA IRA Disadvantaged Communities            names_flag
# yesno_houseburden                  Flag for Overlapping with Housing Burden Communities names_criticalservice
# yesno_transdis       Flag for Overlapping with Transportation Disadvantaged Communities names_criticalservice
# yesno_fooddesert                            Flag for Overlapping with Food Desert Areas names_criticalservice
# pctnobroadband                                  % Households without Broadband Internet names_criticalservice
# pctnohealthinsurance                              % Households without Health Insurance names_criticalservice

######################################################### #

#' count sites flagged for each feature/flag indicator
#' @param bysite data.table like ejamit()$results_bysite
#' @param flagvarnames names of indicator columns to summarize
#' @return 1-row table of counts of sites with each indicator > 0
#'   (sums, for the percentage indicators)
#' @keywords internal
#' @noRd
flagged_count_sites <- function(bysite = testoutput_ejamit_1000pts_1miles$results_bysite, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice)) {

  if (!is.data.table(bysite)) {
    wasnt = TRUE
    setDT(bysite)
  } else {
    wasnt = FALSE
  }
  stopifnot(all(flagvarnames %in% colnames(bysite)))
  x <- bysite[, lapply(.SD, function(z) {sum(z > 0, na.rm = TRUE)}),
              .SDcols = flagvarnames]

  #  note these 2 indicators are %, not count or 1/0:  "pctnobroadband", "pctnohealthinsurance"
  pctvars = c( 'pctnobroadband' , 'pctnohealthinsurance')
  x[, pctvars] <- bysite[, lapply(.SD, function(z) {sum(z, na.rm = TRUE)}),
                         .SDcols = pctvars]  ## THIS SUM OF PERCENTAGES OF PEOPLE HERE DOES NOT MAKE SENSE AS IT DOES FOR POPULATION
  if (interactive()) {
    # message("Note that for ", paste0(pctvars, collapse = ","), " the SUM OVER SITES OF PERCENTAGES OF PEOPLE HERE DOES NOT MAKE SENSE AS IT WOULD FOR POPULATION")
  }
  if (wasnt) {
    setDF(bysite)
  }
  return(x)
}
######################################################### #

#' percent of sites flagged for each feature/flag indicator
#' @param bysite data.table like ejamit()$results_bysite
#' @param flagvarnames names of indicator columns to summarize
#' @param digits rounding digits
#' @return 1-row table of percentages of sites with each indicator > 0
#' @keywords internal
#' @noRd
flagged_pct_sites <- function(bysite = testoutput_ejamit_1000pts_1miles$results_bysite, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice), digits = 1) {

  if (!is.data.table(bysite)) {
    wasnt = TRUE
    setDT(bysite)
  } else {
    wasnt = FALSE
  }
  stopifnot(all(flagvarnames %in% colnames(bysite)))
  x <- flagged_count_sites(bysite = bysite, flagvarnames = flagvarnames)
  x <- round(100 * x / NROW(bysite), digits = digits)
  if (interactive()) {
    cat("Site count total: ", prettyNum(NROW(bysite), big.mark = ","), "\n")
  }
  if (wasnt) {
    setDF(bysite)
  }
  return(x)
}
######################################################### #

#' count analyzed population in blockgroups flagged for each indicator
#' @param bybg_people data.table like ejamit()$results_bybg_people
#' @param flagvarnames names of indicator columns to summarize
#' @return 1-row table of population counts (population-weighted sums,
#'   for the percentage indicators)
#' @keywords internal
#' @noRd
flagged_count_pop <- function(bybg_people = testoutput_ejamit_1000pts_1miles$results_bybg_people, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice)) {

  if (!is.data.table(bybg_people)) {
    wasnt = TRUE
    setDT(bybg_people)
  } else {
    wasnt = FALSE
  }
  neededvars = c("pop", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_people)))
  x <- bybg_people[, lapply(.SD, function(z) {sum((z > 0) * pop * bgwt, na.rm = TRUE)}),
                   .SDcols = flagvarnames]
  pctvars = c( 'pctnobroadband' , 'pctnohealthinsurance')
  x[, pctvars] <- bybg_people[, lapply(.SD, function(z) {sum(z * pop * bgwt, na.rm = TRUE)}),
                              .SDcols = pctvars]
  if (interactive()) {
    print("POP COUNT that has overlap = yes, or has 1+ features, or is in the relevant pct, in their blockgroup:")
    print(x)
    cat("\n\n")
  }
  if (wasnt) {
    setDF(bybg_people)
  }
  return(x)
}
######################################################### #

#' percent of analyzed population in blockgroups flagged for each indicator
#' @param bybg_people data.table like ejamit()$results_bybg_people
#' @param flagvarnames names of indicator columns to summarize
#' @param digits rounding digits
#' @return 1-row table of percentages of analyzed population
#' @keywords internal
#' @noRd
flagged_pct_pop <- function(bybg_people = testoutput_ejamit_1000pts_1miles$results_bybg_people, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice), digits = 1) {

  if (!is.data.table(bybg_people)) {
    wasnt = TRUE
    setDT(bybg_people)
  } else {
    wasnt = FALSE
  }
  neededvars = c("pop", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_people)))
  x <- flagged_count_pop(bybg_people = bybg_people, flagvarnames = flagvarnames)
  x <- round(100 * x / sum(bybg_people$pop * bybg_people$bgwt, na.rm = TRUE), digits = digits)
  if (interactive()) {
    cat("Population total: ", prettyNum(sum(bybg_people$pop * bybg_people$bgwt, na.rm = TRUE), big.mark = ","), "\n")
  }
  if (wasnt) {
    setDF(bybg_people)
  }
  return(x)
}
######################################################### #
######################################################### #

#' count US population in blockgroups flagged for each indicator
#' @param bybg_us data.table of US blockgroups, like blockgroupstats
#' @param flagvarnames names of indicator columns to summarize
#' @return 1-row table of US population counts (population-weighted sums,
#'   for the percentage indicators)
#' @keywords internal
#' @noRd
flagged_count_pop_us <- function(bybg_us = blockgroupstats, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice)) {

  neededvars = c("pop", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_us)))
  x <- bybg_us[, lapply(.SD, function(z) {sum((z > 0) * pop, na.rm = TRUE)}),
               .SDcols = flagvarnames]
  pctvars = c( 'pctnobroadband' , 'pctnohealthinsurance')
  x[, pctvars] <- bybg_us[, lapply(.SD, function(z) {sum(z * pop, na.rm = TRUE)}),
                          .SDcols = pctvars]
  if (interactive()) {
    print("POP COUNT that has overlap = yes, or has 1+ features, or is in the relevant pct, in their blockgroup:")
    print(x)
    cat("\n\n")
  }
  return(x)
}
######################################################### #

#' percent of US population in blockgroups flagged for each indicator
#' @param bybg_us data.table of US blockgroups, like blockgroupstats
#' @param flagvarnames names of indicator columns to summarize
#' @param digits rounding digits
#' @return 1-row table of percentages of US population
#' @keywords internal
#' @noRd
flagged_pct_pop_us <- function(bybg_us = blockgroupstats, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice), digits = 1) {

  neededvars = c("pop", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_us)))
  x <- flagged_count_pop_us(bybg_us = bybg_us, flagvarnames = flagvarnames)
  x <- round(100 * x / sum(bybg_us$pop, na.rm = TRUE), digits = digits)
  if (interactive()) {
    cat("Population total: ", prettyNum(sum(bybg_us$pop, na.rm = TRUE), big.mark = ","), "\n")
  }
  # results_overall$pop  is a bit different as denominator than  sum(bybg_us$pop, na.rm = TRUE)
  return(x)
}
######################################################### #

#' count state population in blockgroups flagged for each indicator
#' @param ST state abbreviation(s), e.g., c("pr", "dc")
#' @param bybg_st data.table of blockgroups with ST column, like blockgroupstats
#' @param flagvarnames names of indicator columns to summarize
#' @return 1-row table of population counts in the given state(s)
#' @keywords internal
#' @noRd
flagged_count_pop_st <- function(ST = stateinfo$ST, bybg_st = blockgroupstats, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice)) {

  # e.g.,
  # flagged_count_pop_st(c('pr', 'dc'))
  # flagged_count_pop_st('dc') + flagged_count_pop_st('pr')

  neededvars = c("pop", "ST", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_st)))
  st <- tolower(ST)
  rm(ST)
  bybg_st <- bybg_st[tolower(ST) %in% st, ..neededvars]
  if (interactive()) {
    cat("Population total: ", prettyNum(sum(bybg_st$pop, na.rm = TRUE), big.mark = ","), "\n")
    cat("\n\n")
  }
  x <- bybg_st[, lapply(.SD, function(z) {sum(z * pop, na.rm = TRUE)}),
               .SDcols = flagvarnames]
  # if (interactive()) {
  #   print("POP COUNT x FEATURE COUNT, summed over blockgroups (makes sense for pctnobroadband or pctnohealthinsurance):")
  #   print(x)
  #   cat("\n\n")
  # }
  x <- bybg_st[, lapply(.SD, function(z) {sum((z > 0) * pop, na.rm = TRUE)}),
               .SDcols = flagvarnames]
  pctvars = c( 'pctnobroadband' , 'pctnohealthinsurance')
  x[, pctvars] <- bybg_st[, lapply(.SD, function(z) {sum(z * pop, na.rm = TRUE)}),
                          .SDcols = pctvars]
  if (interactive()) {
    print("POP COUNT that has overlap = yes, or has 1+ features, or is in the relevant pct, in their blockgroup:")
    print(x)
    cat("\n\n")
  }
  return(x)
}
######################################################### #

#' percent of state population in blockgroups flagged for each indicator
#' @param ST state abbreviation(s), e.g., c("pr", "dc")
#' @param bybg_st data.table of blockgroups with ST column, like blockgroupstats
#' @param flagvarnames names of indicator columns to summarize
#' @param digits rounding digits
#' @return 1-row table of percentages of population in the given state(s)
#' @keywords internal
#' @noRd
flagged_pct_pop_st <- function(ST = stateinfo$ST, bybg_st = blockgroupstats, flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice), digits = 1) {

  neededvars = c("pop", "ST", flagvarnames)
  stopifnot(all(neededvars %in% colnames(bybg_st)))
  st <- tolower(ST)
  rm(ST)
  bybg_st <- bybg_st[tolower(ST) %in% st, ..neededvars]
  x <- flagged_count_pop_st(ST = st, bybg_st = bybg_st, flagvarnames = flagvarnames)
  x <- round(100 * x / sum(bybg_st$pop, na.rm = TRUE), digits = digits)
  # results_overall$pop  is a bit different as denominator than  sum(bybg_st$pop, na.rm = TRUE)
  return(x)
}
######################################################### #

#' analyzed-population-weighted average of state-level percent flagged, per indicator
#'
#' For each indicator, computes each relevant state's percent of residents living in
#' blockgroups with the feature or overlap (or the popwtd mean, for the two percentage
#' indicators), then averages those state-level baselines weighted by the ANALYZED
#' population in each state (sum(pop * bgwt) by ST from results_bybg_people).
#' This is analogous to how doaggregate() calculates state.avg.cols_overall
#' (popwtd mean of each site's state average), and is NOT the same as
#' \code{flagged_pct_pop_st()}, which POOLS the given states into one combined denominator.
#' State baselines are computed directly from blockgroupstats (not statestats,
#' which lacks the yesno_ indicators).
#' @param bybg_people data.table like ejamit()$results_bybg_people (needs ST, pop, bgwt)
#' @param bybg_us data.table of all US blockgroups, like blockgroupstats (needs ST, pop, and the indicators)
#' @param flagvarnames names of indicator columns to summarize
#' @param digits rounding digits (rounded once, at the end)
#' @return 1-row data.table of percentages (0-100), one column per flagvarname;
#'   all NA (with a warning) if bybg_people lacks usable ST/pop/bgwt info
#' @keywords internal
#' @noRd
flagged_pct_pop_st_avg <- function(bybg_people = testoutput_ejamit_1000pts_1miles$results_bybg_people,
                                   bybg_us = blockgroupstats,
                                   flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice),
                                   digits = 1) {

  na_row <- function() {
    x <- data.table::as.data.table(as.list(rep(NA_real_, length(flagvarnames))))
    data.table::setnames(x, flagvarnames)
    x
  }
  if (!is.data.frame(bybg_people) || !all(c("pop", "bgwt") %in% colnames(bybg_people))) {
    warning("bybg_people must have pop and bgwt columns - returning NA for statewide baselines")
    return(na_row())
  }
  if (!("ST" %in% colnames(bybg_people)) || all(is.na(bybg_people$ST))) {
    warning("bybg_people lacks a usable ST column - returning NA for statewide baselines")
    return(na_row())
  }
  stopifnot(all(c("pop", "ST", flagvarnames) %in% colnames(bybg_us)))

  # use a local data.table (not setDT/setDF, which would modify the caller's object
  # by reference); if already a data.table it is only queried, never modified
  bybg_people_dt <- if (is.data.table(bybg_people)) bybg_people else as.data.table(bybg_people)
  # weight for each state = ANALYZED population in that state
  # ("wtd by analyzed people from each state", as done for ratios to State averages overall)
  wts <- bybg_people_dt[!is.na(ST), .(analyzed_pop = sum(pop * bgwt, na.rm = TRUE)), keyby = ST]
  wts <- wts[analyzed_pop > 0, ]
  if (NROW(wts) == 0) {
    warning("no analyzed population by state found - returning NA for statewide baselines")
    return(na_row())
  }

  # state-level baseline percent for each relevant state, over ALL blockgroups in that state,
  # using the same logic as flagged_pct_pop_us():
  # percent of pop living in blockgroups with indicator > 0,
  # EXCEPT popwtd mean for the two percentage indicators (z * pop, not (z > 0) * pop)
  sts <- wts$ST
  perst <- bybg_us[ST %in% sts,
                   lapply(.SD, function(z) {100 * sum((z > 0) * pop, na.rm = TRUE) / sum(pop, na.rm = TRUE)}),
                   keyby = ST, .SDcols = flagvarnames]
  pctvars = intersect(c('pctnobroadband', 'pctnohealthinsurance'), flagvarnames)
  if (length(pctvars) > 0) {
    perst[, (pctvars)] <- bybg_us[ST %in% sts,
                                  lapply(.SD, function(z) {100 * sum(z * pop, na.rm = TRUE) / sum(pop, na.rm = TRUE)}),
                                  keyby = ST, .SDcols = pctvars][, ..pctvars]
  }

  m <- merge(wts, perst, by = "ST") # inner join: a state with analyzed people but absent from bybg_us drops out
  x <- m[, lapply(.SD, function(z) {round(collapse::fmean(z, w = analyzed_pop), digits = digits)}),
         .SDcols = flagvarnames]
  return(x)
}
######################################################### #

#' calculate the flagged areas summary table (as in ejamit()$results_summarized$flagged_areas)
#'
#' Extracted from batch.summarize() so it can also be used for a single site
#' (pass a 1-row sitestats and the popstats rows for just that site's ejam_uniq_id),
#' as in the community report via ejam2report().
#' @param sitestats data.table like ejamit()$results_bysite (or 1 row of it)
#' @param popstats data.table like ejamit()$results_bybg_people (or the rows for one site)
#' @param flagvarnames names of indicator columns to summarize
#' @return data.frame with columns Indicator, Percent_of_these_Sites, Percent_of_these_People,
#'   Percent_of_all_People_Nationwide, ratio (to US), Percent_of_all_People_Statewide,
#'   ratio_to_state_avg, rname
#' @seealso [ejam2areafeatures()] [batch.summarize()]
#' @keywords internal
#' @noRd
calc_flagged_areas <- function(sitestats, popstats,
                               flagvarnames = c(names_featuresinarea, names_flag, names_criticalservice)) {

  zsites = flagged_pct_sites(sitestats, flagvarnames = flagvarnames)
  myrnames = names(zsites)
  names(zsites) <- gsub("num_school", "Any schools", names(zsites))
  names(zsites) <- gsub("num_hospital", "Any hospitals", names(zsites))
  names(zsites) <- gsub("num_church", "Any places of worship", names(zsites))
  longernames = fixcolnames(names(zsites), 'r', 'long')
  longernames = gsub("Flag for ", "", longernames)
  fa <- data.frame(

    data.frame(Indicator = longernames),
    data.frame(`Percent_of_these_Sites`  = t(zsites)),
    data.frame(`Percent_of_these_People` = t(flagged_pct_pop(popstats, flagvarnames = flagvarnames))),
    data.frame("Percent_of_all_People_Nationwide" = t(flagged_pct_pop_us(flagvarnames = flagvarnames)))
  )
  rownames(fa) <- NULL
  fa$ratio <- round(fa$Percent_of_these_People / fa$Percent_of_all_People_Nationwide, 2)
  # statewide baseline, wtd by analyzed people from each state (as done to get overall ratios to State averages)
  fa$Percent_of_all_People_Statewide <- as.vector(t(
    flagged_pct_pop_st_avg(bybg_people = popstats, flagvarnames = flagvarnames)
  ))
  fa$ratio_to_state_avg <- round(fa$Percent_of_these_People / fa$Percent_of_all_People_Statewide, 2)
  # a state baseline of 0% is plausible (e.g., yesno_tribal in some states), so avoid Inf here
  fa$ratio_to_state_avg[!is.finite(fa$ratio_to_state_avg)] <- NA_real_
  fa$rname = myrnames
  return(fa)
}
######################################################### # ######################################################### #
######################################################### # ######################################################### #

# helpers to format these summary stats for barplot ####

#' reshape flagged areas table into a named vector of ratios
#' @param flagged_areas data.frame like ejamit()$results_summarized$flagged_areas
#' @param ratiocolname which ratio column to use, "ratio" (vs US, the default)
#'   or "ratio_to_state_avg" (vs States analyzed)
#' @return named vector of ratios, ready for plot_barplot_ratios()
#' @keywords internal
#' @noRd
flagged_areas_ratiosvector_from_flagged_areas <- function(flagged_areas, ratiocolname = "ratio") {
  # reformat the table  ejamit()$results_summarized$flagged_areas
  stopifnot(length(ratiocolname) == 1, ratiocolname %in% names(flagged_areas))
  unlist(as.vector(
    tidyr::pivot_wider(
      data = flagged_areas[, c('Indicator', ratiocolname)],
      names_from = "Indicator",
      values_from = tidyr::all_of(ratiocolname)
    )
  ))
}
################## #

# this is mostly to make the barplot easier

#' get named vector of flagged areas ratios from ejamit() output
#' @param ejamitout output from ejamit()
#' @param ratiocolname which ratio column to use, "ratio" (vs US, the default)
#'   or "ratio_to_state_avg" (vs States analyzed)
#' @return named vector of ratios, ready for plot_barplot_ratios()
#' @keywords internal
#' @noRd
flagged_areas_ratios_from_ejam <- function(ejamitout, ratiocolname = "ratio") {
  # after ejamitout <- ejamit()
  # reformat the table   ejamitout$results_summarized$flagged_areas
  # into a named vector of ratios
  # ready for plot_barplot_ratios(), etc.
  flagged_areas_ratiosvector_from_flagged_areas(
    flagged_areas_from_ejam(ejamitout),
    ratiocolname = ratiocolname
  )
}
################## #
# these "shortlabels" functions are not much better than just letting it use the defaults

#' make short plot-friendly labels from indicator variable names
#' @param rnames indicator variable names, e.g., "yesno_tribal"
#' @param n maximum label length in characters
#' @param do_gsub whether to also abbreviate some words
#' @return character vector of shortened labels
#' @keywords internal
#' @noRd
flagged_areas_shrinklabels <- function(rnames, n = 30, do_gsub = TRUE) {
  longlabels <- fixcolnames(rnames, 'r', 'short')
  if (do_gsub) {
    mediumlabels <- gsub("without", "no", gsub("Overlaps ", "", longlabels))
  } else {
    mediumlabels <- longlabels
  }
  shortlabels <- substr(mediumlabels, 1, n)
  return(shortlabels)
}
## test flagged_areas_shrinklabels
# flagged_areas_testnames = c("num_school", "num_hospital", "num_church", "yesno_tribal",
#                             "yesno_airnonatt", "yesno_impwaters", "yesno_cejstdis", "yesno_iradis",
#                             "yesno_houseburden", "yesno_transdis", "yesno_fooddesert", "pctnobroadband",
#                             "pctnohealthinsurance")
# all.equal(flagged_areas_shrinklabels("yesno_houseburden"),
# "Housing Burden Commu"
# )
# all.equal(flagged_areas_shrinklabels(flagged_areas_testnames),
#           c("Schools", "Hospitals", "Worship Places", "Tribes", "Nonattainment Area",
#             "Impaired Waters", "CEJST Disadvantaged", "EPA IRA Disadvantage",
#             "Housing Burden Commu", "Transportation Disad", "Food Desert",
#             "% hhlds no Broadband", "% hhlds no Health In")
#           )
################## #

#' get short plot-friendly labels for flagged areas indicators from ejamit() output
#' @param ejamitout output from ejamit()
#' @param n maximum label length in characters
#' @param do_gsub whether to also abbreviate some words
#' @return character vector of shortened labels
#' @keywords internal
#' @noRd
flagged_areas_shortlabels_from_ejam <- function(ejamitout, n = 30, do_gsub = TRUE) {
  # after ejamitout <- ejamit()
  # get graph-friendy short labels for the indicators in ejamit()$results_summarized$flagged_areas
  flagged_areas_shrinklabels(
    flagged_areas_from_ejam(ejamitout)$rname,
    n = n,
    do_gsub = do_gsub
  )
}
################## #
