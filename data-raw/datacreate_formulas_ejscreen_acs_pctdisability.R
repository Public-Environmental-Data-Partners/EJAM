
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


formulas_ejscreen_acs_disability <- formulas_ejscreen_acs[grepl("disab", formulas_ejscreen_acs$rname, ignore.case = T), ]

# rname                                                                                       formula longname_old            longname in_mh
# 135 pctdisability pctdisability      <- ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)         <NA> % with Disabilities  TRUE

## get metadata about tables and variables using an API key and the tidycensus package

 v22 = tidycensus::load_variables(year = 2022, dataset = "acs5"); v22$table = gsub("_.*$", "", v22$name)
# v23 = tidycensus::load_variables(year = 2023, dataset = "acs5"); v23$table = gsub("_.*$", "", v23$name)
# v24 = tidycensus::load_variables(year = 2024, dataset = "acs5"); v24$table = gsub("_.*$", "", v24$name)

## to list just  tract tables:
v22 = v22[v22$geography %in% c("tract"), ]


# > v22[v22$table == 'B18101' & grepl("With a", v22$label), c("name", "label")]
# A tibble: 12 × 2
# name       label
# <chr>      <chr>
# 1 B18101_004 Estimate!!Total:!!Male:!!Under 5 years:!!With a disability
# 2 B18101_007 Estimate!!Total:!!Male:!!5 to 17 years:!!With a disability
# 3 B18101_010 Estimate!!Total:!!Male:!!18 to 34 years:!!With a disability
# 4 B18101_013 Estimate!!Total:!!Male:!!35 to 64 years:!!With a disability
# 5 B18101_016 Estimate!!Total:!!Male:!!65 to 74 years:!!With a disability
# 6 B18101_019 Estimate!!Total:!!Male:!!75 years and over:!!With a disability
# 7 B18101_023 Estimate!!Total:!!Female:!!Under 5 years:!!With a disability
# 8 B18101_026 Estimate!!Total:!!Female:!!5 to 17 years:!!With a disability
# 9 B18101_029 Estimate!!Total:!!Female:!!18 to 34 years:!!With a disability
#10 B18101_032 Estimate!!Total:!!Female:!!35 to 64 years:!!With a disability
#11 B18101_035 Estimate!!Total:!!Female:!!65 to 74 years:!!With a disability
#12 B18101_038 Estimate!!Total:!!Female:!!75 years and over:!!With a disability
# > dput(as.vector(v22[v22$table == 'B18101' & grepl("With a", v22$label), c("name" )])[[1]])
# c("B18101_004", "B18101_007", "B18101_010", "B18101_013", "B18101_016",
#   "B18101_019", "B18101_023", "B18101_026", "B18101_029", "B18101_032",
#   "B18101_035", "B18101_038")

disab_formula <- paste0("disability <- ", paste0((as.vector(v22[v22$table == 'B18101' & grepl("With a", v22$label), c("name" )])[[1]]), collapse = " + "))

more <- data.frame(
  rname = c("disability", "disab_universe"),
  formula = c(disab_formula, "disab_universe <- B18101_001"),
  longname_old = NA
  )

more$longname = fixcolnames(more$rname, 'r', 'long')

formulas_ejscreen_acs_disability <- rbind(formulas_ejscreen_acs_disability,
                                          more)

EJAM:::dataset_documenter("formulas_ejscreen_acs_disability", description = "formulas for calculating count and percent with disability, from ACS raw data")
EJAM:::metadata_add_and_use_this("formulas_ejscreen_acs_disability")
