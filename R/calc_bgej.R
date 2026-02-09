# calc_bgej

#' recalculate EJSCREEN EJ Indexes for all US blockgroups, as for an annual data update
#'
#' @param bgstats like [blockgroupstats], a new data.table with one row per blockgroup,
#'  and columns that include c('bgid', 'bgfips', 'ST', 'pop'),
#'  environmental indicators with colnames defined in vnames_e,
#'  and the 4 types of demographic indexes.
#' @param vnames_e names of columns in bgstats that have envt indicators, assumed if missing
#' @param vnames_e_pctile optional, just must be same length as vnames_e
#' @param vnames_e_state_pctile  optional, just must be same length as vnames_e
#'
#' @param vnames_ej optional, names of one set of the EJ Index columns in returned table
#' @param vnames_ej_supp  optional, names of one set of the EJ Index columns in returned table
#' @param vnames_ej_state  optional, names of one set of the EJ Index columns in returned table
#' @param vnames_ej_supp_state  optional, names of one set of the EJ Index columns in returned table
#'
#' @param vnames_d_demogindex name of 1 column in bgstats (that has this 1 type of Demographic Index)
#' @param vnames_d_demogindex_supp name of 1 column in bgstats
#' @param vnames_d_demogindex_state name of 1 column in bgstats
#' @param vnames_d_demogindex_supp_state name of 1 column in bgstats
#'
#' @param vnames_ST name of column in bgstats that has the 2-character State abbreviation to use in
#'   finding envt percentiles in the [statestats] table used by [calc_pctile_columns()]
#'
#' @return data.table like [bgej]
#'
#' @export
#' @keywords internal
#'
calc_bgej <- function(bgstats,
                      vnames_e        = names_e,
                      vnames_e_pctile       = names_e_pctile,
                      vnames_e_state_pctile = names_e_state_pctile,

                      vnames_ej       = names_ej,
                      vnames_ej_supp  = names_ej_supp,
                      vnames_ej_state      = names_ej_state,
                      vnames_ej_supp_state = names_ej_supp_state,

                      vnames_d_demogindex      = "Demog.Index",
                      vnames_d_demogindex_supp = "Demog.Index.Supp",
                      vnames_d_demogindex_state      = "Demog.Index.State",
                      vnames_d_demogindex_supp_state = "Demog.Index.Supp.State",

                      vnames_ST = "ST"

) {

  ## GET ENVT DATA AS PERCENTILES

  bge <- data.table::copy(bgstats[, ..vnames_e])

  cat("calculating envt US percentiles\n")
  epctiles <-
    calc_pctile_columns(bge,
                        varnames        = vnames_e,
                        varnames_pctile = vnames_e_pctile,
                        zones = "USA")

  cat("calculating envt State percentiles\n")
  state_epctiles <-
    calc_pctile_columns(bge,
                        varnames              = vnames_e,
                        varnames_state_pctile = vnames_e_state_pctile,
                        zones = as.vector(unlist(bgstats[, ..vnames_ST])))

  colnames(epctiles)       <- vnames_e_pctile
  colnames(state_epctiles) <- vnames_e_state_pctile

  data.table::setDT(epctiles)
  data.table::setDT(state_epctiles)

  ## CALC EJ INDEXES AS ENVT PCTILE X DEMOG INDEX of correct type

  bg <- data.table::copy(bgstats[, c(vnames_d_demogindex, vnames_d_demogindex_supp, vnames_d_demogindex_state, vnames_d_demogindex_supp_state), with = FALSE])

  cat("calculating EJ Indexes from demog indexes and envt percentiles \n")

  bgej_new = cbind(
    bg[, lapply(.SD, function(z) z * epctiles), .SDcols = vnames_d_demogindex],
    bg[, lapply(.SD, function(z) z * epctiles), .SDcols = vnames_d_demogindex_supp],
    bg[, lapply(.SD, function(z) z * state_epctiles), .SDcols = vnames_d_demogindex_state],
    bg[, lapply(.SD, function(z) z * state_epctiles), .SDcols = vnames_d_demogindex_supp_state]
  )

  names(bgej_new) <- c(
    vnames_ej,
    vnames_ej_supp,
    vnames_ej_state,
    vnames_ej_supp_state
  )

  otheravailable = c('bgid', 'bgfips', 'ST', 'pop')
  otheravailable = otheravailable[otheravailable %in% names(bgstats)]
  bgej_new = cbind(bgstats[, ..otheravailable],
                   bgej_new)

  return(bgej_new)
}
################################################################################### #
################################################################################### #
if (FALSE) {
  # ## VALIDATE FOR EXISTING YEAR

  dataload_dynamic("bgej")
  bgej_old <- bgej[ST %in% c("RI", "DE"), ]
  bgej_new <- EJAM:::calc_bgej(blockgroupstats[ST %in% c("RI", "DE"), ])
  #  dim(bgej_old)
  ## [1] 1498   56
  #  dim(bgej_new)
  ## [1] 1498   56
  # all.equal(bgej_new, bgej_old, check.attributes=FALSE )
  ## [1] "Column 'EJ.DISPARITY.no2.eo': Mean relative difference: 7.250982e-05"
  all.equal(bgej_new, bgej_old, check.attributes=FALSE, tolerance = 0.001)
  ## [1] "Column 'EJ.DISPARITY.drinking.eo': 'is.NA' value mismatch: 285 in current 0 in target"

  EJAM:::nacounts(bgej_old)
  EJAM:::nacounts(bgej_new)
  x = data.frame(old = t(bgej_old[bgid == '43899', ]),
                 new = t(bgej_new[bgid == '43899', ]))
  x[x$old != x$new & !is.na(x$old), ]
  ##                            old      new
  # state.EJ.DISPARITY.pm.eo     0  1.23877
  # state.EJ.DISPARITY.pm.supp   0 1.510684
  x[  is.na(x$old), ]
  ##                                   old new
  # EJ.DISPARITY.drinking.eo         <NA>   0
  # EJ.DISPARITY.drinking.supp       <NA>   0
  # state.EJ.DISPARITY.drinking.eo   <NA>   0
  # state.EJ.DISPARITY.drinking.supp <NA>   0
  x[x$new == 0,]
  ##                                          old new
  # EJ.DISPARITY.proximity.npdes.eo            0   0
  # EJ.DISPARITY.drinking.eo                <NA>   0
  # EJ.DISPARITY.proximity.npdes.supp          0   0
  # EJ.DISPARITY.drinking.supp              <NA>   0
  # state.EJ.DISPARITY.proximity.npdes.eo      0   0
  # state.EJ.DISPARITY.drinking.eo          <NA>   0
  # state.EJ.DISPARITY.proximity.npdes.supp    0   0
  # state.EJ.DISPARITY.drinking.supp        <NA>   0

}
