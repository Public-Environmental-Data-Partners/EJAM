################################################### #

# This file is now mostly superseded by data-raw/run_ejscreen_acs2024_pipeline.R plus the calc_* functions.
# see pipeline and script at data-raw/run_ejscreen_acs2024_pipeline.R

if (FALSE) { # BECAUSE OBSOLETE

  # The was a drafted Overarching/wrapper Script to create new version of
# just the ACS-based indicators (% demographics)

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
# download raw ACS data, then calculate ACS-derived bg_acsdata stage ####

# requires ACSdownload package
# requires having first created formulas_ejscreen_acs via  /data-raw/datacreate_formulas_ejscreen_acs_pctdisability.R

bg_acs_raw <- download_bg_acs_raw(
  yr = yr,
  pipeline_dir = mydir,
  save_stage = TRUE,
  stage_format = "csv"
)

bg_acsdata <- calc_bg_acsdata(
  yr = yr,
  acs_raw_stage = "bg_acs_raw",
  pipeline_dir = mydir,
  save_stage = TRUE,
  stage_format = "csv"
)
blockgroupstats_acs <- bg_acsdata
################################################### #

# ENVIRONMENTAL and EXTRA NON-ACS columns ####

# The new environmental raw scores data would be provided by an upstream
# bg_envirodata stage, which can use saved ACS data to include pctpre1960.
# For now, use the old/existing environmental and non-ACS health scores for testing this
# code with new ACS data and old non-ACS data.
external_indicator_cols <- unique(names_e)
external_indicator_cols <- external_indicator_cols[external_indicator_cols %in% names(blockgroupstats)]
bg_envirodata <- blockgroupstats[, c("bgfips", external_indicator_cols), with = FALSE]

bg_extra_indicators <- calc_bg_extra_indicators(
  existing_blockgroupstats = blockgroupstats,
  reuse_existing_if_missing = TRUE,
  pipeline_dir = mydir,
  save_stage = TRUE,
  stage_format = "csv"
)

if (!"pctpre1960" %in% names(bg_envirodata)) {
  stop("Need pctpre1960 in bg_envirodata before calculating EJ indexes")
}
blockgroupstats_acs <- merge(
  blockgroupstats_acs,
  bg_extra_indicators[, .(bgfips, lowlifex)],
  by = "bgfips",
  all.x = TRUE
)

data.table::fwrite(blockgroupstats_acs, file = file.path(mydir, "blockgroupstats_acs_step2.csv"))
message("saved interim CSV file in ", mydir)

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

## The clean ACS-only bg_acsdata stage was already saved by calc_bg_acsdata()
## above, before lowlifex and Demog.Index columns were added.

# EJAM:::metadata_add_and_use_this("bg_acsdata")
# EJAM:::dataset_documenter("bg_acsdata")
############################################################## #

ejscreen_pipeline_save(bg_envirodata, "bg_envirodata", mydir, format = "csv")
message("saved interim file",    file.path(mydir, "bg_envirodata.csv"))

############################################################## #
# CREATE new version of blockgroupstats ####

cols_to_add <- setdiff(names(bg_envirodata), c("bgfips", names(blockgroupstats_acs)))
blockgroupstats_new <- merge(
  blockgroupstats_acs,
  bg_envirodata[, c("bgfips", cols_to_add), with = FALSE],
  by = "bgfips",
  all.x = TRUE
)

data.table::fwrite(blockgroupstats_new, file = file.path(mydir, "blockgroupstats_new.csv"))
message("saved interim file",    file.path(mydir, "blockgroupstats_new.csv"))

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
}
