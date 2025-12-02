
# data-raw/datacreate_bgej.R ?
# R/calc_bgej.R

################################################################################ #

# > bgej - Create bgej here.####

## old notes
# blockgroupstats_new_state <- blockgroupstats_new_state[, c("bgid", "bgfips", names_ej, names_ej_supp)]
# data.table::setDT(blockgroupstats_new_state)
# data.table::setDT(blockgroupstats_new)
# data.table::setnames(blockgroupstats_new_state,
#                      old =  c("bgid", "bgfips", names_ej, names_ej_supp),
#                      new =  c("bgid", "bgfips", c(names_ej_state, names_ej_supp_state))
# )
# # > all.equal(blockgroupstats_new$bgid, blockgroupstats_new_state$bgid)
# # [1] TRUE
# data.table::setDF(blockgroupstats_new)
# data.table::setDF(blockgroupstats_new_state)
#
#
# bgej_new <- data.table::data.table(
#   blockgroupstats_new[ , c("bgid", "bgfips",
#                            "ST", "pop",
#                            names_ej,
#                            names_ej_supp)],
#   blockgroupstats_new_state[, c(names_ej_state,
#                                 names_ej_supp_state)]
# )
########################################### # ############################################ # ############################################ #

# use blockgroupstats raw data on Envt indicators and
# Demog.Index, Demog.
# and formulas_ejscreen_ej to calculate EJ indexes in every blockgroup
# as US index, US supplemental (multiple demographics),
# and State index, State supplemental versions of EJ Index.


calc_bgej <- function(dat = blockgroupstats, formulas = formulas_bgej) {

  if (missing(formulas)) {formulas <- formulas_bgej} # $formula and $rname
  if (is.atomic(formulas) && is.vector(formulas)) {
    formulas = data.frame(rname = formula_varname(formulas), formula = formulas)
  } else {
    if (!all(c("rname", "formula") %in% names(formulas))) {
      stop("formulas must be a data.frame with elements 'rname' and 'formula' similar to formulas_bgej")
    }
  }

  if (missing(dat)) {
    if (!exists("blockgroupstats")) {
      stop("must provide dat or else blockgroupstats table must be available")
    } else {
      message("Using blockgroupstats dataset for raw envt and demog indicators specified in formulas")
    }
    # dat <- blockgroupstats[, c("bgid", "bgfips", "ST", names_e)] # just use formulas to determine what columns are needed
  }

  if (!("bgfips" %in% names(dat))) {
    warning("dat should contain at least 'bgfips' column, so this function can calculate State-based EJ indexes and later bgej can be joined to or matched up with blockgroupstats by functions in EJAM that use bgej")
  }
  if ("bgfips" %in% names(dat) && !("ST" %in% names(dat))) {
    dat$ST <- fips2state_abbrev(dat$bgfips)
  }

  # c(
  #   "bgid", "bgfips",
  #   "ST", "pop",
  #   names_ej,
  #   names_ej_supp,
  #   names_ej_state,
  #   names_ej_supp_state
  # )

  # > cbind(names_ej, names_ej_supp, names_ej_state, names_ej_supp_state)
  #      names_ej                          names_ej_supp                       names_ej_state                          names_ej_supp_state
  # [1,] "EJ.DISPARITY.pm.eo"              "EJ.DISPARITY.pm.supp"              "state.EJ.DISPARITY.pm.eo"              "state.EJ.DISPARITY.pm.supp"
  # [2,] "EJ.DISPARITY.o3.eo"              "EJ.DISPARITY.o3.supp"              "state.EJ.DISPARITY.o3.eo"              "state.EJ.DISPARITY.o3.supp"
  # [3,] "EJ.DISPARITY.no2.eo"             "EJ.DISPARITY.no2.supp"             "state.EJ.DISPARITY.no2.eo"             "state.EJ.DISPARITY.no2.supp"
  # [4,] "EJ.DISPARITY.dpm.eo"             "EJ.DISPARITY.dpm.supp"             "state.EJ.DISPARITY.dpm.eo"             "state.EJ.DISPARITY.dpm.supp"
  # [5,] "EJ.DISPARITY.rsei.eo"            "EJ.DISPARITY.rsei.supp"            "state.EJ.DISPARITY.rsei.eo"            "state.EJ.DISPARITY.rsei.supp"
  # [6,] "EJ.DISPARITY.traffic.score.eo"   "EJ.DISPARITY.traffic.score.supp"   "state.EJ.DISPARITY.traffic.score.eo"   "state.EJ.DISPARITY.traffic.score.supp"
  # [7,] "EJ.DISPARITY.pctpre1960.eo"      "EJ.DISPARITY.pctpre1960.supp"      "state.EJ.DISPARITY.pctpre1960.eo"      "state.EJ.DISPARITY.pctpre1960.supp"
  # [8,] "EJ.DISPARITY.proximity.npl.eo"   "EJ.DISPARITY.proximity.npl.supp"   "state.EJ.DISPARITY.proximity.npl.eo"   "state.EJ.DISPARITY.proximity.npl.supp"
  # [9,] "EJ.DISPARITY.proximity.rmp.eo"   "EJ.DISPARITY.proximity.rmp.supp"   "state.EJ.DISPARITY.proximity.rmp.eo"   "state.EJ.DISPARITY.proximity.rmp.supp"
  # [10,] "EJ.DISPARITY.proximity.tsdf.eo"  "EJ.DISPARITY.proximity.tsdf.supp"  "state.EJ.DISPARITY.proximity.tsdf.eo"  "state.EJ.DISPARITY.proximity.tsdf.supp"
  # [11,] "EJ.DISPARITY.ust.eo"             "EJ.DISPARITY.ust.supp"             "state.EJ.DISPARITY.ust.eo"             "state.EJ.DISPARITY.ust.supp"
  # [12,] "EJ.DISPARITY.proximity.npdes.eo" "EJ.DISPARITY.proximity.npdes.supp" "state.EJ.DISPARITY.proximity.npdes.eo" "state.EJ.DISPARITY.proximity.npdes.supp"
  # [13,] "EJ.DISPARITY.drinking.eo"        "EJ.DISPARITY.drinking.supp"        "state.EJ.DISPARITY.drinking.eo"        "state.EJ.DISPARITY.drinking.supp"


dataset_documenter("bgej",
                   title = "",
                   description = "bgej is a table of all blockgroups, with the raw scores of the Summary Indexes and Supplemental Summary Indexes for all the environmental indicators.",
                   details = "This file is not stored in the package.
#'
#' For documentation on the residential population and environmental data and indicators, see [EJSCREEN documentation](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen/understanding-ejscreen-results).
#'
#' The column names are these:
#'
#' c('bgfips', 'bgid', 'ST', 'pop',
#' names_ej,
#' names_ej_supp,
#' names_ej_state,
#' names_ej_supp_state
#' )" )



  return(bgej)
}
