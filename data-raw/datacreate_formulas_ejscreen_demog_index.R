
############################################################## #

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
# pctdisabiilty
# pct low life expectancy.
# Z-score is a statistical measurement that tells how far a value is from the mean of a group of values.
# Negative values are smaller than the mean, and positive values are greater than the mean. Using μ for
# the mean and σ for the standard deviation, a Z-score value can be calculated as follows:
#   z = (x - μ) / σ

# After calculation, the absolute value of
# the smallest demographic index value was added to individual demographic indexes to make them non-
#   negative. This shift was applied to national and state levels.

## # incomplete:  ***

stop("not done with writing this script yet")

avg.pctlowlifex = mean(blockgroupstats$lowlifex, na.rm=TRUE)
# etc.
# etc.

sd.pctlowlifex = sd(blockgroupstats$lowlifex, na.rm = TRUE)
# etc.
# etc.

# These formulas below can only be used after all the other ones are run, because they need avg and SD, where
# avg.* and sd.* will be nationwide constants calculated after pct indicators are calculated at each bg in US.


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
    "Demog.Index.Supp = (z.pctlowinc + z.pctlingiso + z.pctlths + z.pctlowlifex + z.pctdisability) / 5",

    "Demog.Index.State = NA",
    "Demog.Index.Supp.State = NA"
  ),
  longname_old = NA,
  longname = NA
)
formulas_ejscreen_demog_index$rname = formula_varname(formulas_ejscreen_demog_index$formula)
formulas_ejscreen_demog_index$longname <- fixcolnames(formulas_ejscreen_demog_index$rname, 'rname', 'long')


stop("not done with writing this script yet")

x = calc_ejam(blockgroupstats,

          )

## after those formulas are used, a final separate adjustment must be made per the EJSCREEN Tech Doc:
# "After calculation, the absolute value of
# the smallest demographic index value was added to individual demographic indexes to make them non-
#   negative. This shift was applied to national and state levels."




############################################################## #

EJAM:::metadata_add_and_use_this("formulas_ejscreen_demog_index")
dataset_documenter(
  "formulas_ejscreen_demog_index",
  title = "formulas_ejscreen_demog_index (DATA) special formulas for the Demog.Index annual update"
)


############################################################## #
