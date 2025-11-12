
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

 formulas_ejscreen_acs[grepl("disab", formulas_ejscreen_acs$rname, ignore.case = T), ]

 # rname                                                                                       formula longname_old            longname in_mh
# 135 pctdisability pctdisability      <- ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)         <NA> % with Disabilities  TRUE

# to get counts, first need tract counts and then apportion to blockgroup counts using blockwts table


 ### to be continued



 stop("not done with writing this script yet")
