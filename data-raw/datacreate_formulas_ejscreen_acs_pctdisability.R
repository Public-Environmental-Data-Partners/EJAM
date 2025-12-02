
# special case of disability - need to downscale from tract to blockgroup counts using blockweights

#   offline/separate calculation is needed to convert ACS download into the count variable "disability"
# before pctdisability can be calculated using these formulas
# Persons with Disabilities—Percent of all persons with disabilities. This data is derived from 2022 ACS
#
# “Sex by Age by Disability Status” table (B18101) for Census tracts. Block group values are calculated
# by multiplying the tract value by the block group population weights. The weights are derived from
# the same Census source used by the EJScreen buffer reports and analysis—2020 Decennial Census
# P.L. 94-171 Redistricting data.

#"disab_universe" "disability" "pctdisability"

#  "B18101", # disability -- at tract resolution only

formulas_ejscreen_acs_disability <- structure(list(

  rname = c("pctdisability",
            "disability",
            "disab_universe"
  ),
  formula = c("pctdisability <- ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)",
              "disability <- B18101_004 + B18101_007 + B18101_010 + B18101_013 + B18101_016 + B18101_019 + B18101_023 + B18101_026 + B18101_029 + B18101_032 + B18101_035 + B18101_038",
              "disab_universe <- B18101_001"),

  longname_old = c(NA_character_,
                   NA_character_,
                   NA_character_),

  longname = c("% with Disabilities",
               "Count of Persons with Disability",
               "Civilian noninstitutionalized population (denominator for % disability)")
),

# ejam_package_version = "2.32.6.003",
# ejscreen_version = c(VersionEJSCREEN = "2.32"),
# ejscreen_releasedate = c(ReleaseDateEJSCREEN = "2024-08-12"),
# acs_releasedate = c(ReleaseDateACS = "2023-12-07"),
# acs_version = c(VersionACS = "2018-2022"),
# census_version = c(VersionCensus = "2020"),
# date_saved_in_package = "2025-11-15",

row.names = c(135L, 1L, 2L),
class = "data.frame")


# rname                                                                                       formula longname_old            longname in_mh
# 135 pctdisability pctdisability      <- ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)         <NA> % with Disabilities  TRUE

## get metadata about tables and variables using an API key and the tidycensus package

# v22 = tidycensus::load_variables(year = 2022, dataset = "acs5"); v22$table = gsub("_.*$", "", v22$name)
# v23 = tidycensus::load_variables(year = 2023, dataset = "acs5"); v23$table = gsub("_.*$", "", v23$name)
# v24 = tidycensus::load_variables(year = 2024, dataset = "acs5"); v24$table = gsub("_.*$", "", v24$name)

## to list just  tract tables:
# v22 = v22[v22$geography %in% c("tract"), ]


# > v22[v22$table == 'B18101' & grepl("With a", v22$label), c("name", "label")]


EJAM:::dataset_documenter("formulas_ejscreen_acs_disability",
                          description = "formulas for calculating count and percent with disability, from ACS raw data",
                          details = "Used for annual update of ACS-based indicators related to population with disabilities. See [calc_blockgroup_pctdisability()] and [calc_blockgroupstats_acs()]")

# EJAM:::metadata_add_and_use_this("formulas_ejscreen_acs_disability")
# formulas_ejscreen_acs_disability = EJAM:::metadata_add(formulas_ejscreen_acs_disability) # do not need
usethis::use_data(formulas_ejscreen_acs_disability, overwrite = T)
