
# Script to create new version of just the ACS-based indicators (% demographics)

mydir = '~/Downloads'
library(data.table)

################################################### #
# what year of ACS data? ####

yr_desc <- as.vector(gsub("(^20..-)(20..)$", "\\2", desc::desc_get("VersionACS")))
yr_guess <- acs_endyear(guess_census_has_published = TRUE)
if (!all.equal(yr_desc, yr_guess)) {stop("Need to confirm the ACS year to use for blockgroupstats_acs update")}
yr <- yr_desc
rm(yr_desc, yr_guess)

  yr = 2022 # for testing

################################################### #
# download ACS data, calc most demographics ####

blockgroupstats_acs <- calc_blockgroupstats_acs(yr = yr) # use defaults, otherwise

save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs step 1.rda"))
################################################### #
# calc pctdisability and language details indicators (from tract data) ####

# bg_disability <- calc_blockgroupstats_from_tract_data(yr = yr, tables = "B18101") # gets disability  from tract data
# bg_language   <- calc_blockgroupstats_from_tract_data(yr = yr, tables = "C16001") # gets detailed language from tract data
bgwts <- calc_bgwts_nationwide() # takes a minute to download each state Census 2020
save(bgwts, file = file.path(mydir, 'bgwts.rda'))
bg_from_tracts <- calc_blockgroupstats_from_tract_data(yr = yr, tables = c("B18101", "C16001"))

save(bg_from_tracts, file = file.path(mydir, "bg_from_tracts.rda"))

# # join into blockgroupstats_acs
# blockgroupstats_acs[bg_disability, disability     := disability,     on = "bgfips"]
# blockgroupstats_acs[bg_disability, disab_universe := disab_universe, on = "bgfips"]
# blockgroupstats_acs[bg_disability, pctdisability  := pctdisability,  on = "bgfips"]

# e.g., pctlan_vietnamese, etc. etc.
blockgroupstats_acs <- merge(blockgroupstats_acs, bg_from_tracts, on = "bgfips", all.x = TRUE)

save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs step 2.rda"))



################################################### #
# calc Demog.Index ####

blockgroup_demog_index <- calc_blockgroup_demog_index(yr = yr)

  # dry run of join
btest <- merge(blockgroupstats_acs, blockgroup_demog_index, by = "bgfips")
testfips = blockgroupstats_acs$bgfips[sample(1:NROW(blockgroupstats_acs), 1)] # "010010203001"

btest[btest$bgfips == testfips,
                    .(bgfips,
                      Demog.Index, Demog.Index.Supp,
                      Demog.Index.State, Demog.Index.Supp.State)]

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
                                   names_d[names_d %in% names(blockgroupstats_acs)]), before = 1)



save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs step 3.rda"))


stop('stop here')

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

cat("Metadata was updated, and new object added to /data/ folder for use in package \n")

cat("update documentation now if relevant \n")
#  EJAM:::dataset_documenter("blockgroupstats_acs")  # manually for now
#  EJAM:::dataset_documenter("blockgroupstats")      # manually for now



cat("update usestats and statestats, etc., next \n")
# FORMERLY used datacreate_blockgroupstats2.32.R" WHICH started making usastats,statestats
##################################################################### ###################################################################### #
