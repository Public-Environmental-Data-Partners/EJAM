# datacreate_tables_ejscreen_acs.R
# is a script used to create/update tables_ejscreen_acs
# which is a list of Census Bureau ACS tables

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
  "B17017",
  "B19301",
  "B25032",
  "B28002",
  "B27010",
  "C16002",
  "B16004",
  "C16001", # tract resolution only
  "B18101" # tract resolution only
)
## ######################### #

# version = paste0("v", desc::desc_get("Version"))
yr = acs_endyear(guess_always = T, guess_census_has_published = TRUE)
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
#'  - C17002  low income, poverty ratio population universe, etc.
#'  - B17017  households below poverty level
#'  - B19301  per capita income
#'  - B25032  owned units vs rented units (occupied housing units, same universe as B25003)
#'  - B28002  no broadband internet subscription
#'  - B27010  no health insurance. B27010 is available at blockgroup resolution,
#'    but the annual EJSCREEN pipeline uses tract-level B27010 for
#'    `pctnohealthinsurance` to match the historical EJSCREEN-style derivation.
#'  - C16002  (language category and) % of households limited English speaking (lingiso) <https://data.census.gov/table/ACSDT5Y",yr,".C16002>
#'  - B16004  (language category and) % of residents (not hhlds) speak no English at all <https://data.census.gov/table/ACSDT5Y",yr,".B16004>
#'
#'  TRACT ONLY, but also used by EJSCREEN:
#'  - C16001   languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc.; EJSCREEN repeats these tract-level values on each blockgroup in the tract <https://data.census.gov/table/ACSDT5Y",yr,".C16001>
#'  - B18101   disability")
)

## ######################### #

EJAM:::metadata_add_and_use_this("tables_ejscreen_acs")
# tables_ejscreen_acs <- EJAM:::metadata_add(tables_ejscreen_acs)
# usethis::use_data(tables_ejscreen_acs, overwrite = TRUE)

print(tables_ejscreen_acs)
print(as.vector(tables_ejscreen_acs))

# then do devtools::document()
