################################################### #

# Overarching/wrapper Script to create new version of
# just the ACS-based indicators (% demographics)




## need to reconcile datacreate_blockgroup_pctdisability()
#  as defined in  /data-raw/datacreate_blockgroup_pctdisability.R
# versus  calc_blockgroupstats_from_tract_data()
# as called from   datacreate_formulas_ejscreen_acs.R   ***




################################################### #

temporary_folder = tempdir()
mydir =  temporary_folder   # '~/Downloads'

library(data.table)

## if not using EJAM::: prefix for internal/un-exported functions below,
## then EJAM needs to be loaded like this to have access to internal functions
# devtools::load_all()

################################################### #
# DEMOGRAPHIC DATA ####
################################################### #
# what year of ACS data? ####

yr_desc <- as.vector(gsub("(^20..-)(20..)$", "\\2", desc::desc_get("VersionACS")))
yr_guess <- acs_endyear(guess_census_has_published = TRUE)
if (!all.equal(yr_desc, yr_guess)) {stop("Need to confirm the ACS year to use for blockgroupstats_acs update")}
yr <- yr_desc
# yr = 2022 # can use 2022 for testing
rm(yr_desc, yr_guess)

################################################### #
# download ACS data, calc most demographics ####

# requires ACSDownload package
# requires having first created formulas_ejscreen_acs via  /data-raw/datacreate_formulas_ejscreen_acs_pctdisability.R

blockgroupstats_acs <- calc_blockgroupstats_acs(yr = yr) # use defaults, otherwise

save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs step 1.rda"))
message("saved interim file in ", mydir)
################################################### #

# calc pctdisability and language details indicators (from tract data) ####

# bgwts <- EJAM:::calc_bgwts_nationwide() # takes a minute to download each state Census 2020
# save(bgwts, file = file.path(mydir, 'bgwts.rda'))
# message("saved bgwts file in ", temporary_folder)
## bgwts just gets used by calc_blockgroupstats_from_tract_data() which creates it if not found in search path ***

# bg_disability <- calc_blockgroupstats_from_tract_data(yr = yr, tables = "B18101") # gets disability  from tract data
# bg_language   <- calc_blockgroupstats_from_tract_data(yr = yr, tables = "C16001") # gets detailed language from tract data

bg_from_tracts <- calc_blockgroupstats_from_tract_data(yr = yr, tables = c("B18101", "C16001"))

save(bg_from_tracts, file = file.path(mydir, "bg_from_tracts.rda"))
message("saved interim file in ", mydir)

# # join into blockgroupstats_acs
# blockgroupstats_acs[bg_disability, disability     := disability,     on = "bgfips"]
# blockgroupstats_acs[bg_disability, disab_universe := disab_universe, on = "bgfips"]
# blockgroupstats_acs[bg_disability, pctdisability  := pctdisability,  on = "bgfips"]
# e.g., pctlan_vietnamese, etc. etc.
blockgroupstats_acs <- merge(blockgroupstats_acs, bg_from_tracts, by = "bgfips", all.x = TRUE)
################################################### #

# ENVIRONMENTAL, HEALTH, or other NON-ACS columns ####

# The new environmental raw scores data would be provided by an upstream
# envirodata stage, which can use saved ACS data to include pctpre1960.
# For now, use the old/existing environmental and non-ACS health scores for testing this
# code with new ACS data and old non-ACS data.
external_indicator_cols <- unique(c(names_e, setdiff(names_health, "pctdisability")))
external_indicator_cols <- external_indicator_cols[external_indicator_cols %in% names(blockgroupstats)]
envirodata <- blockgroupstats[, c("bgfips", external_indicator_cols), with = FALSE]
bg_envirodata <- envirodata

if (!"pctpre1960" %in% names(envirodata)) {
  stop("Need pctpre1960 in envirodata before calculating EJ indexes")
}
if (!"lowlifex" %in% names(envirodata)) {
  stop("Need lowlifex in envirodata before calculating Demog.Index.Supp")
}
blockgroupstats_acs <- merge(
  blockgroupstats_acs,
  envirodata[, .(bgfips, lowlifex)],
  by = "bgfips",
  all.x = TRUE
)

save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs step 2.rda"))
message("saved interim file in ", mydir)

################################################### #
# calc Demog.Index ####

# note first need to have done   /data-raw/datacreate_formulas_ejscreen_demog_index.R

blockgroup_demog_index <- calc_blockgroup_demog_index(bgstats = blockgroupstats_acs)

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
# reformat blockgroupstats_acs ####
# note these were stored in bgej not in blockgroupstats:
#  c(names_ej, names_ej_supp)

setDT(blockgroupstats_acs)
setcolorder(blockgroupstats_acs, c("bgid", "bgfips", "statename", "ST", "countyname", "REGION",
                                   "pop",
                                   names_d[names_d %in% names(blockgroupstats_acs)]), before = 1)

############################################################## #

## IF SAVING JUST THE DEMOGRAPHICS WITHOUT ENVT OR EJ ETC., DO THIS:

# save(blockgroupstats_acs, file = "./data-raw/blockgroupstats_acs.rda")
# or
# EJAM:::metadata_add_and_use_this("blockgroupstats_acs")
# EJAM:::dataset_documenter("blockgroupstats_acs")
# or
save(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs.rda"))
message("saved interim file",    file.path(mydir, "blockgroupstats_acs.rda"))
############################################################## #

save(envirodata, file = file.path(mydir, "envirodata.rda"))
message("saved interim file in ", mydir)

############################################################## #
# CREATE new version of blockgroupstats ####

cols_to_add <- setdiff(names(bg_envirodata), c("bgfips", names(blockgroupstats_acs)))
blockgroupstats_new <- merge(
  blockgroupstats_acs,
  bg_envirodata[, c("bgfips", cols_to_add), with = FALSE],
  by = "bgfips",
  all.x = TRUE
)

save(blockgroupstats_new, file = file.path(mydir, "blockgroupstats_new.rda"))
message("saved interim file",    file.path(mydir, "blockgroupstats_new.rda"))

## can add some validation here

t(blockgroupstats_new[1:3, ])
print(dim(bg_envirodata))
print(names(blockgroupstats_new))
print(setdiff(names(blockgroupstats), names(blockgroupstats_new)))
#
# ### *** I think the problem is the order of formulas matters -
# over17 <- pop - under18
# must come before
# pctover17 <- ifelse(pop == 0, 0, as.numeric(over17) / pop)
# for example.


stop(" DOING THE NEXT STEP MEANS blockgroupstats WITH OLDER ENVT DATA, ETC. would BE REPLACED IN THIS BRANCH - but we may want to keep it for purposes of trying to replicate it, etc.")

blockgroupstats <- data.table::copy(blockgroupstats_new)

rm(blockgroupstats_new)

############################################################## #
# set metadata, use in pkg ####

cat('be sure you are ready to replace/update metadata and save in package')
x = askYesNo("ready?")
if (is.na(x) || !x) {stop("stopped")}


EJAM:::metadata_add_and_use_this("blockgroupstats")
# usethis::use_data(blockgroupstats, overwrite = TRUE)
cat("Metadata was updated, and new object added to /data/ folder for use in package \n")

cat("update documentation now if necessary \n")
#  EJAM:::dataset_documenter("blockgroupstats")      # manually done, not via this function


cat("next, update usestats and statestats, and bgej,  via  /data-raw/datacreate_usastats.R\n")

##################################################################### ###################################################################### #
