
# Vectorized version of pctile_from_raw_lookup()
#
# as needed in doaggregate() lines 1200 or 1290 up to 1340 (and even for EJ indexes up to line 1400 or so?) ***

#' Convert raw indicator values to percentiles, for a table of indicators and places
#'
#' @details Note each percentile is not "calculated" per se, but is actually looked up in a table of percentiles and raw cutoffs
#' @param mytable data.frame with one indicator per column, one row per place
#' @param varnames optional vector of indicators with raw scores to convert to percentiles,
#'   such as names_these or "pm" - must be among colnames of mytable and lookup
#'   (typically usastats or statestats)
#' @param varnames_pctile optional vector as long as varnames, what to name the output columns of US percentiles
#' @param varnames_state_pctile optional vector as long as varnames, what to name the output columns of State percentiles
#' @param zones optional vector of 2-character state abbreviations, or else just "USA",
#'   but not a mixture of both at once
#' @param lookup optional, in case custom indicators are used
#' @param quiet passed to [pctile_from_raw_lookup()]
#'
#' @returns  data.frame of percentiles for a table of indicators and places
#'  one indicator per column, one place per row
#' @seealso [pctile_from_raw_lookup()] [calc_avg_columns()]
#'
#' @examples
#' # examples of getting pctiles, averages, and ratios to averages
#' # via functions that do parts of what is done in doaggregate()
#'
#' #############################
#' #  using ejamit() which uses doaggregate()
#'
#' testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
#' testfips = blockgroupstats$bgfips[ testrows ]
#' out = ejamit(fips = testfips)
#' x = out$results_bysite
#' # look at the averages, ratios, and percentiles
#' names_these_pctile       = paste0("pctile.",      names_these)
#' names_these_state_pctile = paste0("state.pctile.", names_these)
#' avgs0    = x[ , c(..names_these_avg,          ..names_these_state_avg)]
#' ratios0  = x[ , c(..names_these_ratio_to_avg, ..names_these_ratio_to_state_avg)]
#' pctiles0 = x[ , c(..names_these_pctile,       ..names_these_state_pctile)]
#' # outputs are tables in [data.table](https://r-datatable.com) format, 1 row per site, 1 col per indicator
#' names(avgs0); dim(avgs0)
#' names(ratios0); dim(ratios0)
#' names(pctiles0); dim(pctiles0)
#'
#' #############################
#' ##  using just parts of what doaggregate() does
#'
#' testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
#' ## if missing names_d_demogindexstate, cannot do correct ratios  ***
#' testvars = c("ST", names_these, names_d_demogindexstate)
#' testbgs = blockgroupstats[testrows, ..testvars]
#'
#' #   ----------------- AVERAGES -----------------
#'
#' avgs <- cbind(
#'   EJAM:::calc_avg_columns(varnames = names_these, zones = "USA"),
#'   EJAM:::calc_avg_columns(varnames = names_these, zones = testbgs$ST)
#' )
#' data.table::setDT(avgs)
#' t(avgs)
#' all.equal(avgs, avgs0)
#' testbgs <- cbind(testbgs, avgs) # need these averages to calculate the ratios
#'
#' #   ----------------- RATIOS TO AVERAGES -----------------
#'
#' ratios <- EJAM:::calc_ratio_columns(testbgs)  # needs raw and avg cols be in 1 dt
#' data.table::setDT(ratios)
#' t(ratios)
#' all.equal(ratios, ratios0)
#'
#' #   ----------------- PERCENTILES -----------------
#'
#' pctiles <- cbind(
#'   EJAM:::calc_pctile_columns(testbgs, varnames = names_these, zones = "USA"),
#'   EJAM:::calc_pctile_columns(testbgs, varnames = names_these, zones = testbgs$ST)
#' )
#' data.table::setDT(pctiles)
#' all.equal(pctiles, pctiles0)
#' t(pctiles)
#'
#' ############################# ############################## #
#'
#' @export
#'
calc_pctile_columns <- function(mytable,
                                        varnames = intersect(names(mytable),  names(EJAM::usastats)),
                                        # varnames = names_these,
                                        # varnames = c(names_these, names_d_demogindexstate),

                                        varnames_pctile = paste0(      "pctile.", varnames), # names_these_pctile is not defined by the package, unlike names_these_avg
                                        varnames_state_pctile = paste0("state.pctile.", varnames),

                                        zones = "USA",
                                        lookup = NULL,
                                        quiet = TRUE) {
  ############### #
  # avoid modifying by reference the mytable in the calling environment ! make a copy even though that is not efficient it is safer:
  mytable <- data.table::copy(mytable)
  data.table::setDT(mytable)

  if (all(zones %in% "USA")) {

    # loop over the indicators (via lapply)

    if (!is.null(lookup)) {usastats <- lookup} # substitute locally a custom user-provided lookup table here

    pctiles <- mytable[,  lapply(varnames, function(var) {
      pctile_from_raw_lookup(
        mytable[[var]],
        varname.in.lookup.table = var,
        lookup = usastats,
        quiet = quiet
      )
    })]
    names(pctiles) <- varnames_pctile

  } else {
    ############### #
    # state percentiles not usa percentiles


    if (!is.null(lookup)) {statestats <- lookup} # substitute locally a custom user-provided lookup table here

    #   Summary Indexes do not follow that naming scheme and are handled with separate code
    varnames.state.pctile <- varnames_state_pctile # but Summary Indexes do not follow that naming scheme and are handled with separate code

    # swap out which colnames used for special cases where correct raw data must be used for state pctiles
    if (all(c("Demog.Index.State", "Demog.Index.Supp.State") %in% names(mytable))) { # may be redundant but ok
      myvars_to_use <- ifelse(varnames %in% c("Demog.Index", "Demog.Index.Supp"),
                              paste0(varnames, ".State"), varnames)
    } else {
      myvars_to_use <- varnames
    }
    valid_state_vars       <- varnames[             varnames %in% colnames(statestats) & myvars_to_use %in% colnames(mytable)]
    valid_state_pctl_names <- varnames.state.pctile[varnames %in% colnames(statestats) & myvars_to_use %in% colnames(mytable)]
    valid_state_vars_to_use <- myvars_to_use[       varnames %in% colnames(statestats) & myvars_to_use %in% colnames(mytable)]
    # "Demog.Index",                  "Demog.Index.Supp"       are in valid_state_vars
    # "state.pctile.Demog.Index"      "state.pctile.Demog.Index.Supp"       are in valid_state_pctl_names
    # "Demog.Index.State"             "Demog.Index.Supp.State" are in valid_state_vars_to_use




    ######################################## #
    # loop over the indicators (via mapply)
    # because
    #   pctile_from_raw_lookup() could handle only these options for inputs:
    #
    #   A. a vector of scores and vector of corresponding zones (States),
    #     for only 1 indicator (e.g., pctlowinc)
    #     i.e., call it inside a loop over say 32 indicators.
    #
    #   B. a vector of scores and vector of corresponding indicator names,
    #     in only 1 zone (e.g. 1 State).
    #     You would need to use it within a loop over 1 to 50+ "states"
    ######################################## #

    columns_bysite_state <- as.list(mytable[, ..myvars_to_use])
    st_vector <- zones # mytable$ST
    idx_not_na_st <- !is.na(st_vector)

    mytable[!idx_not_na_st, (varnames.state.pctile) := NA_real_]

    pctiles <- mytable[idx_not_na_st,  mapply(function(var, var_to_use) {

      pctile_from_raw_lookup(
        columns_bysite_state[[var_to_use]][idx_not_na_st],
        varname.in.lookup.table = var,
        lookup = statestats,
        zone = st_vector[idx_not_na_st], # ST must be already limited to non_na values !
        quiet = quiet
      )
    }, valid_state_vars, valid_state_vars_to_use, SIMPLIFY = FALSE)]
    ######################################## #

    names(pctiles) <- valid_state_pctl_names
  }
  setDF(pctiles)
  rownames(pctiles) <- NULL
  return(pctiles)
}
######################################################################### #
