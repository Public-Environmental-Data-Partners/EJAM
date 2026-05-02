########################################################### #
# This function will use the indicators in a partially-created/partially-updated blockgroupstats table
# that has new pctlowinc, pctdisability, etc.
# to calculate and add columns for the Demog.Index (and related supplemental/State versions)
########################################################### #

#' utility to calculate annually for EJSCREEN the updated Demographic Indexes per blockgroup from ACS data
#'
#' @param bgstats a data.frame or data.table like [blockgroupstats], with one row
#'   per blockgroup and the columns used in the demographic index formulas.
#' @param formulas formulas used to calculate the demographic index columns.
#'
#' @return data.table, one row per blockgroup, columns bgfips, etc.
#'
#' @keywords internal
#'
calc_blockgroup_demog_index <- function(bgstats,
                                        formulas = formulas_ejscreen_demog_index) {

if (missing(bgstats) || is.null(bgstats)) {
  stop("bgstats must be provided so demographic indexes are calculated from the updated blockgroup data")
}
if (is.data.frame(formulas)) {
  formulas <- formulas$formula
}

required_cols <- c("bgfips", "ST", "lowlifex", "pctmin", "pctlowinc",
                   "pctlingiso", "pctlths", "pctdisability")
missing_cols <- setdiff(required_cols, names(bgstats))
if (length(missing_cols) > 0) {
  stop("bgstats is missing columns needed to calculate demographic indexes: ",
       paste(missing_cols, collapse = ", "))
}

add_demog_index_constants <- function(x) {
  x <- data.table::copy(x)
  data.table::setDT(x)
  x[, avg.pctlowlifex := mean(lowlifex, na.rm = TRUE)]
  x[, avg.pctmin := mean(pctmin, na.rm = TRUE)]
  x[, avg.pctlowinc := mean(pctlowinc, na.rm = TRUE)]
  x[, avg.pctlingiso := mean(pctlingiso, na.rm = TRUE)]
  x[, avg.pctlths := mean(pctlths, na.rm = TRUE)]
  x[, avg.pctdisability := mean(pctdisability, na.rm = TRUE)]

  x[, sd.pctlowlifex := stats::sd(lowlifex, na.rm = TRUE)]
  x[, sd.pctmin := stats::sd(pctmin, na.rm = TRUE)]
  x[, sd.pctlowinc := stats::sd(pctlowinc, na.rm = TRUE)]
  x[, sd.pctlingiso := stats::sd(pctlingiso, na.rm = TRUE)]
  x[, sd.pctlths := stats::sd(pctlths, na.rm = TRUE)]
  x[, sd.pctdisability := stats::sd(pctdisability, na.rm = TRUE)]
  x
}

shift_nonnegative <- function(x) {
  shift <- min(x, na.rm = TRUE)
  if (!is.finite(shift)) {
    return(x)
  }
  x + abs(shift)
}

bgstats <- data.table::copy(bgstats)
data.table::setDT(bgstats)
existing_index_cols <- intersect(
  c("Demog.Index", "Demog.Index.Supp", "Demog.Index.State", "Demog.Index.Supp.State"),
  names(bgstats)
)
if (length(existing_index_cols) > 0) {
  bgstats[, (existing_index_cols) := NULL]
}

## NATIONWIDE, USA

############################################################## #
##   CALCULATE US AVERAGE FOR EACH INDICATOR USED in demog indexes

bg_usa <- add_demog_index_constants(bgstats)

# These formulas  can only be used after all the other ones are run, because they need avg and SD, where
# avg.* and sd.* will be nationwide constants calculated after pct indicators are calculated at each bg in US.
############################################################## #

x <- calc_ejam(bg = bg_usa,
               formulas = formulas,
               keep.old = "bgfips",
               keep.new = c(
                 "Demog.Index", "Demog.Index.Supp"    #  ONLY USA CALCULATIONS
                 # , "Demog.Index.State", "Demog.Index.Supp.State"
               )

)

## after those formulas are used, a final separate adjustment must be made per the EJSCREEN Tech Doc:
# "After calculation, the absolute value of
# the smallest demographic index value was added to individual demographic indexes to make them non-
#   negative. This shift was applied to national and state levels."

x$Demog.Index            <- shift_nonnegative(x$Demog.Index)
x$Demog.Index.Supp       <- shift_nonnegative(x$Demog.Index.Supp)
data.table::setorder(x, "bgfips")
########################################################### #

## BY STATE

byst <- list()
states <- sort(unique(bgstats$ST))
states <- states[!is.na(states)]
for (i in 1:length(states)) {

  bg_state <- bgstats[bgstats$ST == states[i]]
  ############################################################## #
  bg_state <- add_demog_index_constants(bg_state)
  ############################################################## #

  byst[[i]] <- calc_ejam(bg = bg_state,
                         formulas = formulas,
                         keep.old = "bgfips",
                         keep.new = c(
                           # "Demog.Index", "Demog.Index.Supp",
                           "Demog.Index.State", "Demog.Index.Supp.State"  # ONLY IN GIVEN STATE
                         )

  )
  byst[[i]]$Demog.Index.State      <- shift_nonnegative(byst[[i]]$Demog.Index.State)
  byst[[i]]$Demog.Index.Supp.State <- shift_nonnegative(byst[[i]]$Demog.Index.Supp.State)

}

byst <- data.table::rbindlist(byst)
data.table::setorder(byst, "bgfips")
########################################################### #

# JOIN US AND STATE METRICS

blockgroup_demog_index <- merge(x, byst, by = "bgfips")
# rm(byst, x)
return(blockgroup_demog_index)
}
