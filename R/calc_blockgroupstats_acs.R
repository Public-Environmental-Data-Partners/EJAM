################################################# ################################################### #

# to update blockgroupstats by 1st creating blockgroupstats_acs

#' update blockgroupstats dataset yearly, by 1st creating blockgroupstats_acs
#'
#' @param yr end year of 5-year ACS dataset, guesses if not specified
#'
#' @returns data.table, one row per blockgroup, columns bgfips, etc.
#'
#' @export
#'
calc_blockgroupstats_acs <- function(yr) {

  # library(EJAM)
  # library(dplyr)
  if (!(require(ACSdownload))) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload")
  }

  if (missing(yr)) {
    yr <- EJAM::acsendyear(guess_always = T, guess_census_has_published = T)
  }

  # define formulas for EJSCREEN ACS indicators
  formulas_ejscreen_acs <- EJAM::formulas_ejscreen_acs
  tables_acs <- as.vector(tables_ejscreen_acs)  # as.vector(ACSdownload::ejscreen_acs_tables)

  # - get new ACS data for most indicators using downloads not Census API
  bg <- ACSdownload::get_acs_new(
    yr = yr,
    return_list_not_merged = FALSE,
    fips = "blockgroup",
    tables = tables_acs
    # c("B25034", "B01001", "B03002", "B02001", "B15002", "B23025",
    # "C17002", "B19301", "B25032", "B28003", "B27010", "C16002", "B16004",
    # "C16001", "B18101")
  )

  #   clarify how language variables work at tract level applied to bg table - similar to how disability was done?
  tracts_acs <-  ACSdownload::get_acs_new(
    fips = "blockgroup",
    tables = "C16001_001") # language at tract scale
  tracts_acs = tracts_acs[[1]]
  tracts_ejscreen <- calc_ejam(tracts_acs, formulas = formulas_ejscreen_acs)


  cat(  "assign language from tract to bg scale ?? \n")
  # bg = ???


  blockgroupstats_acs <- calc_ejam(bg, formulas = formulas_ejscreen_acs)


  ## THESE would REPLACE THE blockgroupstats dataset in the package:

  # - use  datacreate_blockgroup_pctdisability.R  to add disability columns to new blockgroupstats
  # source("./data-raw/datacreate_blockgroup_pctdisability.R")
  # calc_blockgroup_pctdisability()

  # - use  datacreate_blockgroup_demog_index.R to add demog index columns to blockgroupstats
  # source("./data-raw/datacreate_blockgroup_demog_index.R")


  # - check/update metadata about ACS release, EJAM / EJSCREEN version numbers,
  return(blockgroupstats_acs)
}
################################################# ################################################### #


# "lowlifex"  is from CDC so no formula here except possibly
# "lowlifex = 1 - (lifex / maxlifex)"
# but lifex by bg is imported from CDC 1st, not from ACS, and maxlifex is a US constant based on that source.
# % Low Life Expectancy is defined as “1 – (Life Expectancy / Max Life Expectancy)”
# Note: This is derived from the CDC life expectancy at birth data using the formula above.
############################################################## #
