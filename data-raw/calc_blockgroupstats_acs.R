################################################# ################################################### #

# to update blockgroupstats by 1st creating blockgroupstats_acs

calc_blockgroupstats_acs <- function(yr = acsendyear(guess_always = T, guess_census_has_published = T))  {

  # library(EJAM)
  # library(dplyr)
  if (!(require(ACSdownload))) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload")
  }

  # define formulas for EJSCREEN ACS indicators
  formulas_ejscreen_acs <- EJAM::formulas_ejscreen_acs
  tables_acs <- as.vector(tables_ejscreen_acs)  # as.vector(ACSdownload::ejscreen_acs_tables)

# - get new ACS data for most indicators using
bg <- ACSdownload::get_acs_new(
  yr = yr,
  return_list_not_merged = FALSE,
  fips = "blockgroup",
  tables = tables_acs
    # c("B25034", "B01001", "B03002", "B02001", "B15002", "B23025",
             # "C17002", "B19301", "B25032", "B28003", "B27010", "C16002", "B16004",
             # "C16001", "B18101")
) # tables_ejscreen_acs) # most variables

#   clarify how language variables work at tract level applied to bg table - similar to how disability was done?
tracts_acs <-  ACSdownload::get_acs_new(
  fips = "blockgroup",
  tables = "C16001_001") # language at tract scale
tracts_acs = tracts_acs[[1]]
tracts_ejscreen <- calc_ejam(tracts, formulas = formulas_ejscreen_acs)

 cat(  "assign language from tract to bg scale ?? \n")
 # bg = ???

blockgroupstats_acs <- calc_ejam(bg, formulas = formulas_ejscreen_acs)

## THESE WILL REPLACE THE blockgroupstats dataset in the package:

# - use  datacreate_blockgroup_pctdisability.R  to add disability columns to new blockgroupstats
source("./data-raw/datacreate_blockgroup_pctdisability.R")

# - use  datacreate_blockgroup_demog_index.R to add demog index columns to blockgroupstats
source("./data-raw/datacreate_blockgroup_demog_index.R")

# - check/update metadata about ACS release, EJAM / EJSCREEN version numbers,
return(blockgroupstats_acs)
}
################################################# ################################################### #

# use function to create new version of just the ACS variables

yr_desc <- as.vector(gsub("(^20..-)(20..)$", "\\2", desc::desc_get("VersionACS")))
yr_guess <- EJAM:::acsendyear(guess_census_has_published = TRUE)
if (!all.equal(yr_desc, yr_guess)) {stop("Need to confirm the ACS year to use for blockgroupstats_acs update")}

blockgroupstats_acs <- calc_blockgroupstats_acs(yr = 2023)

# - save and document
EJAM:::metadata_add_and_use_this("blockgroupstats_acs")
cat("Metadata was updated, and new object added to /data/ folder for use in packqge \n")

cat("update documentation for blockgroupstats_acs now if relevant \n")
#  EJAM:::dataset_documenter("blockgroupstats_acs")  # manually for now

cat("update usestats and statestats etc. now \n")
# FORMERLY used datacreate_blockgroupstats2.32.R" WHICH started making usastats,statestats

################################################## ################################################### #
