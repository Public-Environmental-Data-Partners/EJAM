
# Script to create new version of just the ACS-based indicators (% demographics)

library(data.table)

################################################### #
# what year of ACS data? ####

yr_desc <- as.vector(gsub("(^20..-)(20..)$", "\\2", desc::desc_get("VersionACS")))
yr_guess <- EJAM:::acsendyear(guess_census_has_published = TRUE)
if (!all.equal(yr_desc, yr_guess)) {stop("Need to confirm the ACS year to use for blockgroupstats_acs update")}
yr <- yr_desc
rm(yr_desc, yr_guess)

################################################### #
# download ACS data, calc most demographics ####

blockgroupstats_acs <- calc_blockgroupstats_acs(yr = yr)

################################################### #
# calc pctdisability (from tract data) ####

bg_disability <- calc_blockgroup_pctdisability()

# join into blockgroupstats_acs
blockgroupstats_acs[bg_disability, disability     := disability,     on = "bgfips"]
blockgroupstats_acs[bg_disability, disab_universe := disab_universe, on = "bgfips"]
blockgroupstats_acs[bg_disability, pctdisability  := pctdisability,  on = "bgfips"]

################################################### #
# calc Demog.Index ####

blockgroup_demog_index <- calc_blockgroup_demog_index(yr = yr)

  # dry run of join
btest <- merge(blockgroupstats_acs, blockgroup_demog_index, by = "bgfips")
testfips = blockgroupstats_acs$bgfips[sample(1:NROW(blockgroupstats_acs), 1)] # "010010203001"
blockgroupstats_acs[blockgroupstats_acs$bgfips == testfips, .(bgfips, Demog.Index, Demog.Index.Supp, Demog.Index.State, Demog.Index.Supp.State)]
blockgroup_demog_index[blockgroup_demog_index$bgfips == testfips, ]

if (any(grepl("Demog.Index", colnames(blockgroupstats_acs)))) {
  stop("blockgroupstats_acs already has column(s) related to Demog.Index -- manually remove and replace them if that is what you intended")
}

# join into blockgroupstats_acs

blockgroupstats_acs <- merge(blockgroupstats_acs, blockgroup_demog_index, by = "bgfips")

############################################################## #
# note these were stored in bgej not in blockgroupstats:
#  c(names_ej, names_ej_supp)
setDT(blockgroupstats_acs)
setcolorder(blockgroupstats_acs, c("bgid", "bgfips", "statename", "ST", "countyname", "REGION",
                                   "pop",
                                   names_d), before = 1)
############################################################## #

# NON-Demographic columns ####

ecols <- c('bgfips', 'bgid', names_e)

blockgroupstats_env <-
  blockgroupstats[, ..ecols]



############################################################## #
# note bgej is needed also ####







############################################################## #
# set metadata, use in pkg ####

warning('be sure you are ready to replace/update metadata and save in package')

# EJAM:::metadata_add_and_use_this(blockgroupstats_acs)

usethis::use_data(blockgroupstats_acs, overwrite = TRUE)
# usethis::use_data(blockgroupstats, overwrite = TRUE)

cat("Metadata was updated, and new object added to /data/ folder for use in packqge \n")

cat("update documentation now if relevant \n")
#  EJAM:::dataset_documenter("blockgroupstats_acs")  # manually for now
#  EJAM:::dataset_documenter("blockgroupstats")      # manually for now



cat("update usestats and statestats, etc., next \n")
# FORMERLY used datacreate_blockgroupstats2.32.R" WHICH started making usastats,statestats
##################################################################### ###################################################################### #
