
# use the formulas_ejscreen_demog_index in creating updated Demog.Index indicators each year:

# This will use the indicators in a partially-created/partially-updated blockgroupstats table that has new pctlowinc, pctdisability, etc.
# to calculate and add columns for the Demog.Index (and related supplemental/State versions)
########################################################### #

## NATIONWIDE, USA

############################################################## #
##   CALCULATE US AVERAGE FOR EACH INDICATOR USED in demog indexes

avg.pctlowlifex   = mean(blockgroupstats$lowlifex,       na.rm=TRUE)
avg.pctmin        = mean(blockgroupstats$pctmin,         na.rm=TRUE)
avg.pctlowinc     = mean(blockgroupstats$pctlowinc,      na.rm=TRUE)
avg.pctlingiso    = mean(blockgroupstats$pctlingiso,     na.rm=TRUE)
avg.pctlths       = mean(blockgroupstats$pctlths ,       na.rm=TRUE)
avg.pctdisability = mean(blockgroupstats$pctdisability , na.rm=TRUE) # after calculated and added to blockgroupstats via datacreate_blockgroup_pctdisability.R

sd.pctlowlifex   = sd(blockgroupstats$lowlifex,       na.rm=TRUE)
sd.pctmin        = sd(blockgroupstats$pctmin,         na.rm=TRUE)
sd.pctlowinc     = sd(blockgroupstats$pctlowinc,      na.rm=TRUE)
sd.pctlingiso    = sd(blockgroupstats$pctlingiso,     na.rm=TRUE)
sd.pctlths       = sd(blockgroupstats$pctlths,        na.rm=TRUE)
sd.pctdisability = sd(blockgroupstats$pctdisability , na.rm=TRUE) # after calculated and added to blockgroupstats via datacreate_blockgroup_pctdisability.R

# These formulas  can only be used after all the other ones are run, because they need avg and SD, where
# avg.* and sd.* will be nationwide constants calculated after pct indicators are calculated at each bg in US.
############################################################## #

x <- calc_ejam(bg = blockgroupstats,
               formulas = formulas_ejscreen_demog_index,
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

x$Demog.Index            <- x$Demog.Index            + abs(min(x$Demog.Index,            na.rm = TRUE))
x$Demog.Index.Supp       <- x$Demog.Index.Supp       + abs(min(x$Demog.Index.Supp,       na.rm = TRUE))
data.table::setorder(x, "bgfips")
########################################################### #

## BY STATE

byst <- list()
states <- sort(unique(blockgroupstats$ST))
for (i in 1:length(states)) {

  bg_state <- blockgroupstats[blockgroupstats$ST == states[i]]
  ############################################################## #
  avg.pctlowlifex   = mean(bg_state$lowlifex,       na.rm=TRUE)
  avg.pctmin        = mean(bg_state$pctmin,         na.rm=TRUE)
  avg.pctlowinc     = mean(bg_state$pctlowinc,      na.rm=TRUE)
  avg.pctlingiso    = mean(bg_state$pctlingiso,     na.rm=TRUE)
  avg.pctlths       = mean(bg_state$pctlths ,       na.rm=TRUE)
  avg.pctdisability = mean(bg_state$pctdisability , na.rm=TRUE) # after calculated and added to blockgroupstats via datacreate_blockgroup_pctdisability.R

  sd.pctlowlifex   = sd(bg_state$lowlifex,       na.rm=TRUE)
  sd.pctmin        = sd(bg_state$pctmin,         na.rm=TRUE)
  sd.pctlowinc     = sd(bg_state$pctlowinc,      na.rm=TRUE)
  sd.pctlingiso    = sd(bg_state$pctlingiso,     na.rm=TRUE)
  sd.pctlths       = sd(bg_state$pctlths,        na.rm=TRUE)
  sd.pctdisability = sd(bg_state$pctdisability , na.rm=TRUE) # after calculated and added to blockgroupstats via datacreate_blockgroup_pctdisability.R
  ############################################################## #

  byst[[i]] <- calc_ejam(bg = bg_state,
                         formulas = formulas_ejscreen_demog_index,
                         keep.old = "bgfips",
                         keep.new = c(
                           # "Demog.Index", "Demog.Index.Supp",
                           "Demog.Index.State", "Demog.Index.Supp.State"  # ONLY IN GIVEN STATE
                         )

  )
  byst[[i]]$Demog.Index.State      <- byst[[i]]$Demog.Index.State      + abs(min(byst[[i]]$Demog.Index.State,      na.rm = TRUE))
  byst[[i]]$Demog.Index.Supp.State <- byst[[i]]$Demog.Index.Supp.State + abs(min(byst[[i]]$Demog.Index.Supp.State, na.rm = TRUE))

}

byst <- data.table::rbindlist(byst)
data.table::setorder(byst, "bgfips")
########################################################### #

# JOIN US AND STATE METRICS

blockgroup_demog_index <- merge(x, byst, by = "bgfips")
rm(byst, x)
########################################################### #

# SAVE work in progress

# save each for now
save(blockgroup_demog_index, file = "./data-raw/blockgroup_demog_index_2022.rda")
# save(blockgroup_demog_index, file = "./data-raw/blockgroup_demog_index_2023.rda")
# save(blockgroup_demog_index, file = "./data-raw/blockgroup_demog_index_2024.rda")

############################################################## #

# JOIN x and byst to the blockgroupstats object and resave that

btest <- merge(blockgroupstats, blockgroup_demog_index, by = "bgfips")


testfips = blockgroupstats$bgfips[sample(1:NROW(blockgroupstats), 1)] # "010010203001"
blockgroupstats[blockgroupstats$bgfips == testfips, .(bgfips, Demog.Index, Demog.Index.Supp, Demog.Index.State, Demog.Index.Supp.State)]
blockgroup_demog_index[blockgroup_demog_index$bgfips == testfips, ]



if (any(grepl("Demog.Index", colnames(blockgroupstats)))) {
  stop("blockgroupstats already has column(s) related to Demog.Index -- manually remove and replace them if that is what you intended")
}

blockgroupstats <- merge(blockgroupstats, blockgroup_demog_index, by = "bgfips")

warning('be sure you are ready to replace/update metadata and save in package')
############################################################## #

# METADATA / USE IN PACKAGE

EJAM:::metadata_add_and_use_this(blockgroupstats)

# already documented so no need for EJAM:::dataset_documenter()

############################################################## #
