################################################# ################################################### #

# to update blockgroupstats with this newer set of scripts and code:

# - get new ACS data for most indicators using
bg <- ACSdownload::get_acs_new(
  fips = "blockgroup",
  tables = c("B25034", "B01001", "B03002", "B02001" ,"B15002", "B23025" ,"C17002" ,"B19301", "B25032", "B28003" ,"B27010" ,"C16002" ,"B16004" )
) # ejscreen_acs_tables) # most variables

#   clarify how language variables work at tract level applied to bg table - similar to how disability was done?
tracts_acs <-  ACSdownload::get_acs_new(fips = "blockgroup", tables = "C16001_001") # language at tract scale
tracts_ejscreen <- calc_ejam(tracts, formulas = formulas_ejscreen_acs)
##  assign language from tract to bg scale ??

blockgroupstats <- calc_ejam(bg, formulas = formulas_ejscreen_acs)

## THESE WILL REPLACE THE blockgroupstats dataset in the package:

# - use  datacreate_blockgroup_pctdisability.R  to add disability columns to new blockgroupstats
source("./data-raw/datacreate_blockgroup_pctdisability.R")

# - use  datacreate_blockgroup_demog_index.R to add demog index columns to blockgroupstats
source("./data-raw/datacreate_blockgroup_demog_index.R")

# - check/update metadata about ACS release, EJAM / EJSCREEN version numbers,


# - save and document
EJAM:::metadata_add_and_use_this("blockgroupstats")


# then update the usastats, statestats to be able to use EJAM, run reports, etc.

################################################## ################################################### #
