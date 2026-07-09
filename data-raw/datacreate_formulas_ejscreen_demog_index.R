


### gets used by calc_blockgroup_demog_index(), now orchestrated by the staged
### pipeline and calc_ejscreen_dataset(); archived formula notes are reference only.



############################################################## ############################################################### #

# special case of Demog.Index creation yearly for entire US, all blockgroups

# create formulas_ejscreen_Demog_Index as special case

####  FORMULAS FOR DEMOG INDEXES -
## a special case - they rely on separate intermediate- & post- calculations
# of national mean() and sd() to get z scores, then these formulas will work, and then post that an adjustment see below.
#
# The two demographic indexes featured in EJScreen are:
#   • Demographic Index is based on the average of the Z-score values of the two socioeconomic
# indicators: percent low income and percent people of color.
# • Supplemental Demographic Index is based on the average of the Z-score values of the five
# socioeconomic and health indicators:
# percent low income,
# percent limited English speaking,
# percent less than high school education,
# pctdisability
# pct low life expectancy.
# Z-score is a statistical measurement that tells how far a value is from the mean of a group of values.
# Negative values are smaller than the mean, and positive values are greater than the mean. Using μ for
# the mean and σ for the standard deviation, a Z-score value can be calculated as follows:
#   z = (x - μ) / σ

# After calculation, the absolute value of
# the smallest demographic index value was added to individual demographic indexes to make them non-
#   negative. This shift was applied to national and state levels.
############################################################## ############################################################### #

formulas_ejscreen_demog_index <- data.frame(

  rname = NA,
  formula = c(

    "pctlowlifex = lowlifex", # alias

    "z.pctlowlifex = (pctlowlifex - avg.pctlowlifex) / sd.pctlowlifex",
    "z.pctmin      = (pctmin - avg.pctmin) / sd.pctmin",
    "z.pctlowinc   = (pctlowinc - avg.pctlowinc) / sd.pctlowinc",
    "z.pctlingiso  = (pctlingiso - avg.pctlingiso) / sd.pctlingiso",
    "z.pctlths     = (pctlths - avg.pctlths) / sd.pctlths",
    "z.pctdisability = (pctdisability - avg.pctdisability) / sd.pctdisability",

    "Demog.Index = (z.pctlowinc + z.pctmin) / 2",
    "Demog.Index.Supp = ifelse(is.na(z.pctlowlifex), (z.pctlowinc + z.pctlingiso + z.pctlths + z.pctdisability) / 4, (z.pctlowinc + z.pctlingiso + z.pctlths + z.pctlowlifex + z.pctdisability) / 5)",

    "Demog.Index.State      = (z.pctlowinc + z.pctmin) / 2", # # ??
    "Demog.Index.Supp.State = ifelse(is.na(z.pctlowlifex), (z.pctlowinc + z.pctlingiso + z.pctlths + z.pctdisability) / 4, (z.pctlowinc + z.pctlingiso + z.pctlths + z.pctlowlifex + z.pctdisability) / 5)"
  ),
  # longname_old = NA,
  longname = NA
)
formulas_ejscreen_demog_index$rname = EJAM:::calc_varname_from_formula(formulas_ejscreen_demog_index$formula)
formulas_ejscreen_demog_index$longname <- fixcolnames(formulas_ejscreen_demog_index$rname, 'rname', 'long')

########################################################## #

# formulas_ejscreen_demog_index <- EJAM:::metadata_add(formulas_ejscreen_demog_index)
# usethis::use_data(formulas_ejscreen_demog_index, overwrite = T)
EJAM:::metadata_add_and_use_this("formulas_ejscreen_demog_index")

EJAM:::dataset_documenter(
  "formulas_ejscreen_demog_index",
  title = "formulas_ejscreen_demog_index (DATA) special formulas for annually recalculating the Demog.Index annual update",
  seealso = "[formulas_ejscreen_acs] [formulas_ejscreen_acs_disability]"
)

########################################################## ########################################################### #
########################################################## ########################################################### #
