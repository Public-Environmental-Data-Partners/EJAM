############################################################################### #
# Script to create new version of usastats and statestats datasets
# and has to create EJ indexes as bgej in the middle of that

# Calculate percentiles baed raw ACS data in blockgroupstats and in bgej datasets

message("note: must have already updated blockgroupstats via  /data-raw/datacreate_blockgroupstats_acs.R  before doing this")

mydir <- tempdir()

############################################################################### #

# specify colnames (indicators) to calculate percentiles of ####

# > setdiff(c(names_d, names_e, names_ej, names_ej_supp, names_d_subgroups, names_d_subgroups_alone, names_health),  names(usastats))
# [1] "rateheartdisease" "rateasthma"       "ratecancer"
# > EJAM:::setdiff_yx(c(names_d, names_e, names_ej, names_ej_supp, names_d_subgroups, names_d_subgroups_alone, names_health),  names(usastats))
# [1] "PCTILE" "REGION"
# >

# > cbind(names(usastats), varlist = varinfo(names(usastats))$varlist)
# varlist
# [1,] "PCTILE"                            NA
# [2,] "REGION"                            "names_geo"
# [3,] "Demog.Index"                       "names_d"
# [4,] "Demog.Index.Supp"                  "names_d"
# [5,] "pctmin"                            "names_d"
# [6,] "pctlowinc"                         "names_d"
# [7,] "pctunemployed"                     "names_d"
# [8,] "pctdisability"                     "names_health"
# [9,] "pctlingiso"                        "names_d"
# [10,] "pctlths"                           "names_d"
# [11,] "pctunder5"                         "names_d"
# [12,] "pctover64"                         "names_d"
# [13,] "lowlifex"                          "names_health"
# [14,] "pm"                                "names_e"
# [15,] "o3"                                "names_e"
# [16,] "dpm"                               "names_e"
# [17,] "rsei"                              "names_e"
# [18,] "traffic.score"                     "names_e"
# [19,] "pctpre1960"                        "names_e"
# [20,] "proximity.npl"                     "names_e"
# [21,] "proximity.rmp"                     "names_e"
# [22,] "proximity.tsdf"                    "names_e"
# [23,] "ust"                               "names_e"
# [24,] "proximity.npdes"                   "names_e"
# [25,] "drinking"                          "names_e"
# [26,] "no2"                               "names_e"
# [27,] "EJ.DISPARITY.pm.eo"                "names_ej"
# [28,] "EJ.DISPARITY.o3.eo"                "names_ej"
# [29,] "EJ.DISPARITY.dpm.eo"               "names_ej"
# [30,] "EJ.DISPARITY.rsei.eo"              "names_ej"
# [31,] "EJ.DISPARITY.traffic.score.eo"     "names_ej"
# [32,] "EJ.DISPARITY.pctpre1960.eo"        "names_ej"
# [33,] "EJ.DISPARITY.proximity.npl.eo"     "names_ej"
# [34,] "EJ.DISPARITY.proximity.rmp.eo"     "names_ej"
# [35,] "EJ.DISPARITY.proximity.tsdf.eo"    "names_ej"
# [36,] "EJ.DISPARITY.ust.eo"               "names_ej"
# [37,] "EJ.DISPARITY.proximity.npdes.eo"   "names_ej"
# [38,] "EJ.DISPARITY.drinking.eo"          "names_ej"
# [39,] "EJ.DISPARITY.no2.eo"               "names_ej"
# [40,] "EJ.DISPARITY.pm.supp"              "names_ej_supp"
# [41,] "EJ.DISPARITY.o3.supp"              "names_ej_supp"
# [42,] "EJ.DISPARITY.dpm.supp"             "names_ej_supp"
# [43,] "EJ.DISPARITY.rsei.supp"            "names_ej_supp"
# [44,] "EJ.DISPARITY.traffic.score.supp"   "names_ej_supp"
# [45,] "EJ.DISPARITY.pctpre1960.supp"      "names_ej_supp"
# [46,] "EJ.DISPARITY.proximity.npl.supp"   "names_ej_supp"
# [47,] "EJ.DISPARITY.proximity.rmp.supp"   "names_ej_supp"
# [48,] "EJ.DISPARITY.proximity.tsdf.supp"  "names_ej_supp"
# [49,] "EJ.DISPARITY.ust.supp"             "names_ej_supp"
# [50,] "EJ.DISPARITY.proximity.npdes.supp" "names_ej_supp"
# [51,] "EJ.DISPARITY.drinking.supp"        "names_ej_supp"
# [52,] "EJ.DISPARITY.no2.supp"             "names_ej_supp"
# [53,] "pcthisp"                           "names_d_subgroups"
# [54,] "pctnhba"                           "names_d_subgroups"
# [55,] "pctnhaa"                           "names_d_subgroups"
# [56,] "pctnhaiana"                        "names_d_subgroups"
# [57,] "pctnhnhpia"                        "names_d_subgroups"
# [58,] "pctnhotheralone"                   "names_d_subgroups"
# [59,] "pctnhmulti"                        "names_d_subgroups"
# [60,] "pctnhwa"                           "names_d_subgroups"
# [61,] "pctba"                             "names_d_subgroups_alone"
# [62,] "pctaa"                             "names_d_subgroups_alone"
# [63,] "pctaiana"                          "names_d_subgroups_alone"
# [64,] "pctnhpia"                          "names_d_subgroups_alone"
# [65,] "pctotheralone"                     "names_d_subgroups_alone"
# [66,] "pctmulti"                          "names_d_subgroups_alone"
# [67,] "pctwa"                             "names_d_subgroups_alone"

# dput(names(usastats)) # see old version's colnames

# myvars <- c("PCTILE", "REGION",
#             "Demog.Index", "Demog.Index.Supp",
#             "pctmin", "pctlowinc", "pctunemployed", "pctdisability", "pctlingiso",
#   "pctlths", "pctunder5", "pctover64", "lowlifex", "pm", "o3",
#   "dpm", "rsei", "traffic.score", "pctpre1960", "proximity.npl",
#   "proximity.rmp", "proximity.tsdf", "ust", "proximity.npdes",
#   "drinking", "no2", "EJ.DISPARITY.pm.eo", "EJ.DISPARITY.o3.eo",
#   "EJ.DISPARITY.dpm.eo", "EJ.DISPARITY.rsei.eo", "EJ.DISPARITY.traffic.score.eo",
#   "EJ.DISPARITY.pctpre1960.eo", "EJ.DISPARITY.proximity.npl.eo",
#   "EJ.DISPARITY.proximity.rmp.eo", "EJ.DISPARITY.proximity.tsdf.eo",
#   "EJ.DISPARITY.ust.eo", "EJ.DISPARITY.proximity.npdes.eo", "EJ.DISPARITY.drinking.eo",
#   "EJ.DISPARITY.no2.eo", "EJ.DISPARITY.pm.supp", "EJ.DISPARITY.o3.supp",
#   "EJ.DISPARITY.dpm.supp", "EJ.DISPARITY.rsei.supp", "EJ.DISPARITY.traffic.score.supp",
#   "EJ.DISPARITY.pctpre1960.supp", "EJ.DISPARITY.proximity.npl.supp",
#   "EJ.DISPARITY.proximity.rmp.supp", "EJ.DISPARITY.proximity.tsdf.supp",
#   "EJ.DISPARITY.ust.supp", "EJ.DISPARITY.proximity.npdes.supp",
#   "EJ.DISPARITY.drinking.supp", "EJ.DISPARITY.no2.supp", "pcthisp",
#   "pctnhba", "pctnhaa", "pctnhaiana", "pctnhnhpia", "pctnhotheralone",
#   "pctnhmulti", "pctnhwa", "pctba", "pctaa", "pctaiana", "pctnhpia",
#   "pctotheralone", "pctmulti", "pctwa")

# unique(varinfo(names(blockgroupstats))$varlist)
# [1] NA                              "names_geo"                     "names_d_other_count"
# "names_d"    "names_e"
# "names_health_count"            "names_d_count"
# "names_health"
# [9] "names_sitesinarea"             "names_countabove"
# "names_d_demogindexstate"       "names_d_subgroups_alone_count"
# [13] "names_d_subgroups_alone"       "names_d_subgroups_count"       "names_d_subgroups"
# "names_age_count"   "names_age"
# "names_community_count"  "names_community"
# "names_d_extra_count"     "names_d_extra"
# "names_d_language_count"   "names_d_language"
# "names_d_languageli_count"   "names_d_languageli"
# "names_criticalservice"
# "names_climate"
# "names_featuresinarea"
# [29] "names_flag"

library(data.table)

myvars1 <- c(# "PCTILE", # created by function not from raw data
  # "REGION", # created by function not from raw data
  names_d,
  names_e,
  names_ej, names_ej_supp,
  names_d_subgroups, names_d_subgroups_alone,

  # "pctdisability", "lowlifex", # only these two were in usastats through v2.32, but now try to calc pctiles for all indicators available
  names_health
)

# maybe add these:
more <- c(
  names_d_demogindexstate,
  ##"Demog.Index.State"      "Demog.Index.Supp.State"
  names_age,
  names_sitesinarea,
  names_community, # "occupiedunits" "pctmale"       "pctfemale"     "lifexyears"    "percapincome"  "pctownedunits"
  names_d_extra,
  names_d_language,
  names_d_languageli,
  "pctnobroadband"    ,   "pctnohealthinsurance" , # others  in names_criticalservice are yesno
  names_climate,
  names_featuresinarea # count, but maybe pctile is relevant unlike demog counts
)
myvars <- c(myvars1, more)
myvars <- unique(myvars) # pcthisp dupe

############################################################################### #
# calculate percentiles for usastats_new, statestats_new ####

# dataload_dynamic("bgej")
# all.equal(blockgroupstats$bgfips, bgej$bgfips) # yes


## TO BE CONFIRMED BUT ....
##
## tricky step -- must create usastats and statestats for ENVIRONMENT and DEMOG
## before you can calculate EJ Indexes to create bgej
## but then you can finally create the EJ columns within usastats and statestats only after bgej has been created !


# bg = cbind(blockgroupstats, bgej) ### CANNOT HAVE bgej yet ?!
bg = data.table::copy(blockgroupstats)




myvars <- myvars[myvars %in% names(bg)]

# myvars <- myvars[(!myvars %in% c("Demog.Index.State", "Demog.Index.Supp.State"))]

usastats_new <- EJAM:::pctiles_lookup_create(bg[, ..myvars])

statestats_new <- EJAM:::pctiles_lookup_create(bg[, ..myvars], zone.vector = bg$ST)

# note they are still missing EJ index pctiles
################################################################################ #
# create bgej (EJ Indexes) ####

# source("./data-raw/datacreate_bgej.R")
## or do it directly here:

bgej <- calc_bgej(
  bgstats = bg,
  usastats_lookup = usastats_new,
  statestats_lookup = statestats_new
) # use new blockgroupstats and the new percentile lookup tables

# # This file is not stored in the package. It goes in the ejamdata repository. and probably as .arrow not .rda
save(bgej, file = file.path(mydir, "bgej.rda"))
message("saved interim file in ", mydir)
################################################################################ #

# calc pctiles of EJ indexes - add those columns to usastats, statestats ####

# now finish creating usastats_new and statestats_new to include the EJ INDEX columns in them.
# Use the national EJ index columns for usastats and the state EJ index columns for statestats.
myvars_us_ej <- intersect(c(names_ej, names_ej_supp), names(bgej))
myvars_state_ej <- intersect(c(names_ej_state, names_ej_supp_state), names(bgej))
if (length(myvars_us_ej) == 0 || length(myvars_state_ej) == 0) {
  stop("bgej does not have the expected EJ index columns needed for usastats/statestats")
}

usastats_new_ej   <- EJAM:::pctiles_lookup_create(bgej[, ..myvars_us_ej])
statestats_new_ej <- EJAM:::pctiles_lookup_create(bgej[, ..myvars_state_ej], zone.vector = bgej$ST)

# merge with non-ej-index percentiles tables
merge_pctile_lookups <- function(x, y) {
  x <- data.table::as.data.table(x)
  y <- data.table::as.data.table(y)
  if ("OBJECTID" %in% names(y)) {
    y[, OBJECTID := NULL]
  }
  out <- merge(x, y, by = c("REGION", "PCTILE"), all.x = TRUE, sort = FALSE)
  data.table::setcolorder(out, c("OBJECTID", "REGION", "PCTILE",
                                 setdiff(names(out), c("OBJECTID", "REGION", "PCTILE"))))
  data.frame(out)
}

usastats_new   <- merge_pctile_lookups(usastats_new,   usastats_new_ej)
statestats_new <- merge_pctile_lookups(statestats_new, statestats_new_ej)

################################################################################ #

# fix rownames  ####

# make rownames less confusing since starting with 1 was for the row where PCTILE == 0,
# so make them match in USA one at least, but cannot same way for state one since they repeat for each state
rownames(usastats_new)     <- usastats_new$PCTILE
rownames(statestats_new) <- paste0(statestats_new$REGION, statestats_new$PCTILE)
################################################################################ #

# name them "usastats", "statestats" (from usastats_new, etc.)  ####

usastats   <- usastats_new
statestats <- statestats_new
rm(statestats_new, usastats_new, myvars1, myvars, more)
rm(bg)
gc()
######################################################################################## ################## #

# island areas? ####

message("Island Areas?")

#  no Island Areas here at all as rows - maybe add those but with only NA values for all pctiles and mean and all indicators?
#  should fix percentile lookup function to handle cases where a REGION is missing from lookup table.

################################################### ################## #

# metadata and use_data ####

setDF(usastats)    #   do we want it as data.frame? data.table?
setDF(statestats)  #   ditto

EJAM:::metadata_add_and_use_this("usastats")
EJAM:::metadata_add_and_use_this("statestats")

# usastats <- EJAM:::metadata_add(usastats)
# statestats <- EJAM:::metadata_add(statestats)
# usethis::use_data(usastats, overwrite = TRUE)
# usethis::use_data(statestats, overwrite = TRUE)

save(usastats, file = file.path(mydir, "usastats.rda"))
message("saved interim file in ", mydir)
save(statestats, file = file.path(mydir, "statestats.rda"))
message("saved interim file in ", mydir)

################################################### ################## #

#  update documentation ####

EJAM:::dataset_documenter("usastats",
                   "usastats (DATA) data.frame of 100 percentiles and means",
                   "data.frame of 100 percentiles and means (about 100 rows)
#'   in the USA overall, across all locations (e.g., blockgroups in [blockgroupstats])
#'   for a set of indicators such as percent low income.
#'   Each column is one indicator (or specifies the percentile).
#'
#'   This should be similar to the lookup tables in the gdb on the FTP site of EJSCREEN,
#'   except it also has data for additional population subgroups.
#'
#'   For details on how the table was made, see source package files in data-raw folder.
#'
#'   See also [statestats]")


EJAM:::dataset_documenter("statestats",
                   "statestats (DATA) data.frame of 100 percentiles and means for each US State and PR and DC.",
                   "data.frame of 100 percentiles and means
#'   for each US State and PR and DC
#'   for all the blockgroups in that zone (e.g., blockgroups in [blockgroupstats])
#'   for a set of indicators such as percent low income.
#'   Each column is one indicator (or specifies the percentile).
#'
#'   For details on how the table was made, see source package files in data-raw folder.
#'
#'   See also [usastats] for more details.")

################################################### ################## #
cat("FINISHED A SCRIPT\n")
cat("\n In globalenv() now: \n\n")
print(ls())


print('now need to rebuild EJAM package with those new datasets and push changes')
