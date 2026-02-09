# datacreate_tables_ejscreen_acs.R

library(EJAM)
devtools::load_all()

# ######################### ## ######################### ## ######################### #
## see the list of relevant tables
# ######################### ## ######################### ## ######################### #

## like  (ACSdownload::ejscreen_acs_tables)

tables_ejscreen_acs <- c(

  "B25034",

  "B01001",
  "B03002",
  "B02001",
  "B15002",
  "B23025",
  "C17002",
  "B19301",
  "B25032",
  "B28003",
  "B27010",
  "C16002",
  "B16004",
  "C16001", # tract resolution only
  "B18101" # tract resolution only
)
## ######################### #

# version = paste0("v", desc::desc_get("Version"))
yr = acs_endyear(guess_always = T)
cat("SHOULD CONFIRM YEAR TO USE IS ", yr, "\n")

EJAM:::dataset_documenter("tables_ejscreen_acs", seealso = "[formulas_ejscreen_acs]",

                          details = paste0("See
#'
#'  ```
#'  yr = ", yr, "
#'  urls = paste0('https://data.census.gov/table/ACSDT5Y', yr, '.', tables_ejscreen_acs)
#'  sapply(urls, browseURL)
#'  acsinfo <- tidycensus::load_variables(acs_endyear(guess_census_has_published = TRUE), 'acs5')
#' ```
#'
#' Notes:
#'
#'  - B25034  pre1960, for lead paint indicator (environmental not demographic per se)
#'  - B01001  sex and age / basic population counts
#'  - B03002  race with hispanic ethnicity
#'  - B02001  race without hispanic ethnicity
#'  - B15002  education
#'  - B23025  unemployed
#'  - C17002  low income, poor, etc.
#'  - B19301  per capita income
#'  - B25032  owned units vs rented units (occupied housing units, same universe as B25003)
#'  - B28003  no broadband
#'  - B27010  no health insurance
#'  - C16002  (language category and) % of households limited English speaking (lingiso) <https://data.census.gov/table/ACSDT5Y",yr,".C16002>
#'  - B16004  (language category and) % of residents (not hhlds) speak no English at all <https://data.census.gov/table/ACSDT5Y",yr,".B16004>
#'
#'  TRACT ONLY, but also used by EJSCREEN:
#'  - C16001   languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc. <https://data.census.gov/table/ACSDT5Y",yr,".C16001>
#'  - B18101   disability")
)

## ######################### #

# EJAM:::metadata_add_and_use_this("tables_ejscreen_acs")
tables_ejscreen_acs <- EJAM:::metadata_add(tables_ejscreen_acs)
print(tables_ejscreen_acs)
print(as.vector(tables_ejscreen_acs))

usethis::use_data(tables_ejscreen_acs, overwrite = TRUE)

# then do devtools::document()
