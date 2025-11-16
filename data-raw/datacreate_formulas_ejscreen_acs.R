
# script to make a set of formulas that can convert raw ACS5 data into ejscreen indicators

acstabs <- c("B01001", # sex and age / basic population counts
             "B03002", # race with hispanic ethnicity
             "B02001", # race without hispanic ethnicity
             "B15002", # education
             "C16002", # language/ lingiso
             "C17002", # low income, poor, etc.
             "B25034", # pre1960, for lead paint indicator
             "B23025", # unemployed
             "B18101", # disability -- at tract resolution only ########### #
             "B25032", # owned units vs rented units
             "B28003", # no broadband
             "B27010"  # no health insurance
)
## get metadata about tables and variables using an API key and the tidycensus package

# v22 = tidycensus::load_variables(year = 2022, dataset = "acs5"); v22$table = gsub("_.*$", "", v22$name)
# v23 = tidycensus::load_variables(year = 2023, dataset = "acs5"); v23$table = gsub("_.*$", "", v23$name)
# v24 = tidycensus::load_variables(year = 2024, dataset = "acs5"); v24$table = gsub("_.*$", "", v24$name)

## get the topic (concept) of each table

# concept = v22$concept[match(acstabs, v22$table)]
# cbind(acstabs, concept = v22$concept[match(acstabs, v22$table)] )

##       acstabs  concept
## [1,] "B01001" "Sex by Age"
## [2,] "B03002" "Hispanic or Latino Origin by Race"
## [3,] "B02001" "Race"
## [4,] "B15002" "Sex by Educational Attainment for the Population 25 Years and Over"
## [5,] "C16002" "Household Language by Household Limited English Speaking Status"
## [6,] "C17002" "Ratio of Income to Poverty Level in the Past 12 Months"
## [7,] "B25034" "Year Structure Built"
## [8,] "B23025" "Employment Status for the Population 16 Years and Over"
## [9,] "B18101" "Sex by Age by Disability Status"
## [10,] "B25032" "Tenure by Units in Structure"
## [11,] "B28003" "Presence of a Computer and Type of Internet Subscription in Household"
## [12,] "B27010" "Types of Health Insurance Coverage by Age"

# unique(v22$table) # over 1,000 tables if all geo scales counted
# unique(v22$table[v22$geography == "block group"]) #  about 400 tables for just bg data
## to list just blockgroup and tract tables:
# v22 = v22[v22$geography %in% c("tract", "block group"), ]
# unique(v22$table) # almost 1,000 tables if bg and tract scales kept
## confirmed all tables listed as ejscreen relevant are in fact found in this list of all acs5 tables
# cbind(acstabs, acs2022 = acstabs %in% v22$table, acs2023 = acstabs %in% v23$table)

########################################################################################## #

# Formulas as documented by EPA archived at
# https://web.archive.org/web/20250118134239/https://www.epa.gov/system/files/documents/2024-07/ejscreen-tech-doc-version-2-3.pdf
# and more links recorded at EJAM/data-raw/EJSCREEN_archived_pages/EJSCREEN_archived_pages_and_docs.md

# start from partially done table, that had some formulas but not all:

# x <- ejscreen::ejscreenformulasnoej
# # or
# > dput(ejscreen::ejscreenformulasnoej)
x <- structure(list(
  gdbfieldname = c("OBJECTID", "ID", "ACSTOTPOP",
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, "UNDER5", "UNDER5PCT", "OVER64", "OVER64PCT",
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, "MINORPOP", "MINORPCT", "ACSIPOVBAS", NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "LOWINCOME",
                   "LOWINCPCT", "ACSEDUCBAS", NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, "LESSHS", NA, NA, NA, NA, "ACSTOTHH",
                   "LESSHSPCT", "LINGISO", "LINGISOPCT", NA, "VULEOPCT", "VULEO",
                   "DISPEO", "ACSTOTHU", NA, NA, NA, "PRE1960", "PRE1960PCT", "DSLPM",
                   "CANCER", "RESP", "EXAMPLEINDICATOR", "PTRAF", "PWDIS", "PNPL",
                   "PRMP", "PTSDF", "OZONE", "PM25", "STATE_NAME", "ST_ABBREV",
                   "REGION", "P_MINORPCT", "P_LWINCPCT", "P_LESHSPCT", "P_LNGISPCT",
                   "P_UNDR5PCT", "P_OVR64PCT", "P_LDPNT", "P_VULEOPCT", "P_DSLPM",
                   "P_CANCR", "P_RESP", "P_EXAMPLEINDICATOR", "P_PTRAF", "P_PWDIS",
                   "P_PNPL", "P_PRMP", "P_PTSDF", "P_OZONE", "P_PM25", "B_MINORPCT",
                   "B_LWINCPCT", "B_LESHSPCT", "B_LNGISPCT", "B_UNDR5PCT", "B_OVR64PCT",
                   "B_LDPNT", "B_VULEOPCT", "B_DSLPM", "B_CANCR", "B_RESP", "B_EXAMPLEINDICATOR",
                   "B_PTRAF", "B_PWDIS", "B_PNPL", "B_PRMP", "B_PTSDF", "B_OZONE",
                   "B_PM25", "Shape_Length", "Shape_Area", "T_MINORPCT", "T_LWINCPCT",
                   "T_LESHSPCT", "T_LNGISPCT", "T_UNDR5PCT", "T_OVR64PCT", "T_VULEOPCT",
                   "T_LDPNT", "T_DSLPM", "T_CANCR", "T_RESP", "T_EXAMPLEINDICATOR",
                   "T_PTRAF", "T_PWDIS", "T_PNPL", "T_PRMP", "T_PTSDF", "T_OZONE",
                   "T_PM25", NA, NA, NA, "AREALAND", "AREAWATER", "NPL_CNT", "TSDF_CNT",
                   "countyname", "flagged", "lat", "lon", "ACSUNEMPBAS", "UNEMPLOYED",
                   "UNEMPPCT", "P_UNEMPPCT", "B_UNEMPPCT", "T_UNEMPPCT", "UST",
                   "P_UST", "B_UST", "T_UST"),
  Rfieldname = c("OBJECTID", "FIPS",
                 "pop", "ageunder5m", "age5to9m", "age10to14m", "age15to17m",
                 "age65to66m", "age6769m", "age7074m", "age7579m", "age8084m",
                 "age85upm", "ageunder5f", "age5to9f", "age10to14f", "age15to17f",
                 "age65to66f", "age6769f", "age7074f", "age7579f", "age8084f",
                 "age85upf", "under5", "pctunder5", "over64", "pctover64", "hisp",
                 "pop3002", "nonhisp", "nhwa", "nhba", "nhaiana", "nhaa", "nhnhpia",
                 "nhotheralone", "nhmulti", "nonmins", "pcthisp", "pctnhwa", "pctnhba",
                 "pctnhaiana", "pctnhaa", "pctnhnhpia", "pctnhotheralone", "pctnhmulti",
                 "mins", "pctmin", "povknownratio", "pov50", "pov99", "pov124",
                 "pov149", "pov184", "pov199", "pov2plus", "num1pov", "num15pov",
                 "num2pov", "num2pov.alt", "pct1pov", "pct15pov", "pct2pov", "pct2pov.alt",
                 "lowinc", "pctlowinc", "age25up", "m0", "m4", "m6", "m8", "m9",
                 "m10", "m11", "m12", "f0", "f4", "f6", "f8", "f9", "f10", "f11",
                 "f12", "lths", "lingisospanish", "lingisoeuro", "lingisoasian",
                 "lingisoother", "hhlds", "pctlths", "lingiso", "pctlingiso",
                 "VSI.eo.US", "VSI.eo", "VNI.eo", "VDI.eo", "builtunits", "built1950to1959",
                 "built1940to1949", "builtpre1940", "pre1960", "pctpre1960", "dpm",
                 "cancer", "resp", "EXAMPLEINDICATOR", "traffic.score", "proximity.npdes",
                 "proximity.npl", "proximity.rmp", "proximity.tsdf", "o3", "pm",
                 "statename", "ST", "REGION", "pctile.pctmin", "pctile.pctlowinc",
                 "pctile.pctlths", "pctile.pctlingiso", "pctile.pctunder5", "pctile.pctover64",
                 "pctile.pctpre1960", "pctile.VSI.eo", "pctile.dpm", "pctile.cancer",
                 "pctile.resp", "pctile.EXAMPLEINDICATOR", "pctile.traffic.score",
                 "pctile.proximity.npdes", "pctile.proximity.npl", "pctile.proximity.rmp",
                 "pctile.proximity.tsdf", "pctile.o3", "pctile.pm", "bin.pctmin",
                 "bin.pctlowinc", "bin.pctlths", "bin.pctlingiso", "bin.pctunder5",
                 "bin.pctover64", "bin.pctpre1960", "bin.VSI.eo", "bin.dpm", "bin.cancer",
                 "bin.resp", "bin.EXAMPLEINDICATOR", "bin.traffic.score", "bin.proximity.npdes",
                 "bin.proximity.npl", "bin.proximity.rmp", "bin.proximity.tsdf",
                 "bin.o3", "bin.pm", "Shape_Length", "area", "pctile.text.pctmin",
                 "pctile.text.pctlowinc", "pctile.text.pctlths", "pctile.text.pctlingiso",
                 "pctile.text.pctunder5", "pctile.text.pctover64", "pctile.text.VSI.eo",
                 "pctile.text.pctpre1960", "pctile.text.dpm", "pctile.text.cancer",
                 "pctile.text.resp", "pctile.text.EXAMPLEINDICATOR", "pctile.text.traffic.score",
                 "pctile.text.proximity.npdes", "pctile.text.proximity.npl", "pctile.text.proximity.rmp",
                 "pctile.text.proximity.tsdf", "pctile.text.o3", "pctile.text.pm",
                 "FIPS.TRACT", "FIPS.COUNTY", "FIPS.ST", "arealand", "areawater",
                 "count.NPL", "count.TSDF", "countyname", "flagged", "lat", "lon",
                 "unemployedbase", "unemployed", "pctunemployed", "pctile.pctunemployed",
                 "bin.unemployed", "pctile.text.unemployed", "ust", "pctile.ust",
                 "bin.ust", "pctile.text.ust"),
  acsfieldname = c(NA, NA, "B01001.001",
                   "B01001.003", "B01001.004", "B01001.005", "B01001.006", "B01001.020",
                   "B01001.021", "B01001.022", "B01001.023", "B01001.024", "B01001.025",
                   "B01001.027", "B01001.028", "B01001.029", "B01001.030", "B01001.044",
                   "B01001.045", "B01001.046", "B01001.047", "B01001.048", "B01001.049",
                   NA, NA, NA, NA, "B03002.012", "B03002.001", "B03002.002", "B03002.003",
                   "B03002.004", "B03002.005", "B03002.006", "B03002.007", "B03002.008",
                   "B03002.009", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "C17002.001",
                   "C17002.002", "C17002.003", "C17002.004", "C17002.005", "C17002.006",
                   "C17002.007", "C17002.008", NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, "B15002.001", "B15002.003", "B15002.004", "B15002.005", "B15002.006",
                   "B15002.007", "B15002.008", "B15002.009", "B15002.010", "B15002.020",
                   "B15002.021", "B15002.022", "B15002.023", "B15002.024", "B15002.025",
                   "B15002.026", "B15002.027", NA, "C16002.004", "C16002.007", "C16002.010",
                   "C16002.013", "B16002.001", NA, NA, NA, NA, NA, NA, NA, "B25034.001",
                   "B25034.008", "B25034.009", "B25034.010", NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                   NA, "B23025.003", "B23025.005", NA, NA, NA, NA, NA, NA, NA, NA
  ),
  type = c("Geographic", "Geographic", "Demographic", "ACS",
           "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS",
           "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS",
           "ACS", "Demographic Supplementary", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic Supplementary", "ACS",
           "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS",
           "Calc from ACS", "Calc from ACS", "Calc from ACS", "Calc from ACS",
           "Calc from ACS", "Calc from ACS", "Calc from ACS", "Calc from ACS",
           "Calc from ACS", "Demographic", "Demographic", "Demographic",
           "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "Calc from ACS",
           "Calc from ACS", "Calc from ACS", "Calc from ACS", "Calc from ACS",
           "Calc from ACS", "Calc from ACS", "Calc from ACS", "Demographic",
           "Demographic", "Demographic Supplementary", "ACS", "ACS", "ACS",
           "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS", "ACS",
           "ACS", "ACS", "ACS", "ACS", "Demographic Supplementary", "ACS",
           "ACS", "ACS", "ACS", "Demographic Supplementary", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic Supplementary", "Calc from ACS",
           "Demographic", "Demographic Supplementary", "Demographic", "Environmental",
           "ACS", "ACS", "ACS", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Geographic", "Geographic",
           "Geographic", "Demographic", "Demographic", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic Supplementary", "Demographic Supplementary",
           "Environmental", "Demographic", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Demographic", "Demographic", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic Supplementary", "Demographic Supplementary",
           "Environmental", "Demographic", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Geographic", "Geographic", "Demographic", "Demographic",
           "Demographic Supplementary", "Demographic Supplementary", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Environmental",
           "Environmental", "Environmental", "Environmental", "Geographic",
           "Geographic", "Geographic", "Geographic", "Geographic", "Environmental",
           "Environmental", "Geographic", "EJ", "Geographic", "Geographic",
           "Demographic Supplementary", "Demographic Supplementary", "Demographic Supplementary",
           "Demographic Supplementary", "Demographic Supplementary", "Demographic Supplementary",
           "Environmental", "Environmental", "Environmental", "Environmental"
  ),
  glossaryfieldname = c("unique ID for block group in geodatabase",
                        "Census FIPS code for block group", "Total population", "Count of males age Under 5 years",
                        "Count of males age 5 to 9 years", "Count of males age 10 to 14 years",
                        "Count of males age 15 to 17 years", "Count of males age 65 and 66 years",
                        "Count of males age 67 to 69 years", "Count of males age 70 to 74 years",
                        "Count of males age 75 to 79 years", "Count of males age 80 to 84 years",
                        "Count of males age 85 years and over", "Count of females age Under 5 years",
                        "Count of females age 5 to 9 years", "Count of females age 10 to 14 years",
                        "Count of females age 15 to 17 years", "Count of females age 65 and 66 years",
                        "Count of females age 67 to 69 years", "Count of females age 70 to 74 years",
                        "Count of females age 75 to 79 years", "Count of females age 80 to 84 years",
                        "Count of females age 85 years and over", "count of individuals under age 5",
                        "% under age 5", "count of individuals over age 64", "% over age 64",
                        "Count of Hispanic or Latino (of any race)", "Count of Total Population",
                        "Count of Not Hispanic or Latino", "Count of White alone (including Hispanic/Latino)",
                        "Count of Black or African American alone", "Count of American Indian and Alaska Native alone",
                        "Count of Asian alone", "Count of Native Hawaiian and Other Pacific Islander alone",
                        "Count of people who are Some other race alone", "Count of people who are Two or more races",
                        "Count not people of color (aka non-minority) i.e. not Hispanic or Latino White alone",
                        "Percent Hispanic or Latino", "(percent Not Hispanic or Latino White alone)",
                        "(percent Not Hispanic or Latino Black or African American alone)",
                        "(percent Not Hispanic or Latino American Indian and Alaska Native alone)",
                        "(percent Not Hispanic or Latino Asian alone)", "(percent Not Hispanic or Latino Native Hawaiian and Other Pacific Islander alone)",
                        "(percent Not Hispanic or Latino Some other race alone)", "(percent Not Hispanic or Latino Two or more races)",
                        "count of people of color (aka minority)", "% people of color (aka minority)",
                        "Population for whom poverty status is determined", "Population with income under 50% of poverty level",
                        "Population with income 50%-100% of poverty level", "Population with income 100%-124% of poverty level",
                        "Population with income 125%-149% of poverty level", "Population with income 150%-184% of poverty level",
                        "Population with income 185%-199% of poverty level", "Population with income at least twice the poverty level",
                        "Population with income below poverty level", "Population with income below 150% of poverty level",
                        "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                        "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                        "Percent of Population with income below poverty level", "Percent of Population with income below 150% of poverty level",
                        "% low-income (i.e., with income below 2 times poverty level)",
                        "% low-income (i.e., with income below 2 times poverty level)",
                        "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                        "% low-income (i.e., with income below 2 times poverty level)",
                        "Population 25 years and over", NA, NA, NA, NA, NA, NA, NA, NA,
                        NA, NA, NA, NA, NA, NA, NA, NA, "count of individuals age 25 or over with less than high school degree",
                        "Spanish - Limited English speaking household", "Other Indo-European languages - Limited English speaking household",
                        "Asian and Pacific Island languages - Limited English speaking household",
                        "Other languages - Limited English speaking household", "Households (for linguistic isolation)",
                        "% less than high school", "Count of Limited English speaking households",
                        "% of households that are limited English speaking", "Overall US Demographic Index -- avg of percent low-income and percent people of color (aka minority)",
                        "Demographic Index (based on 2 factors, % low-income and % people of color (aka minority)",
                        "intermediate variable used for a supplementary EJ Index", "intermediate variable used for the EJ Index",
                        "Housing units (for % built pre-1960)", "Built 1950 to 1959",
                        "Built 1940 to 1949", "Built 1939 or earlier", "count of housing units built before 1960",
                        "% pre-1960 housing (lead paint indicator)", "Diesel particulate matter level in air",
                        "Air toxics cancer risk per mill.", "Air toxics respiratory hazard index",
                        "EXAMPLEINDICATOR", "Traffic proximity and volume", "Indicator for major direct dischargers to water",
                        "Proximity to National Priorities List (NPL) sites", "Proximity to Risk Management Plan (RMP) facilities",
                        "Proximity to Treatment Storage and Disposal (TSDF) facilities",
                        "Ozone ppm in air", "PM2.5 ug/m3 in air", "State", "State abbrev",
                        "US EPA Region number", "Percentile for % people of color (aka minority)",
                        "Percentile for % low-income", "Percentile for % less than high school",
                        "Percentile for % of households that are limited English speaking",
                        "Percentile for % under age 5", "Percentile for % over age 64",
                        "Percentile for % pre-1960 housing (lead paint indicator)", "Percentile for Demographic Index (based on 2 factors, % low-income and % people of color (aka minority))",
                        "Percentile for Diesel particulate matter level in air", "Percentile for Air toxics cancer risk",
                        "Percentile for Air toxics respiratory hazard index", "Percentile for EXAMPLEINDICATOR",
                        "Percentile for Traffic proximity and volume", "Percentile for Indicator for major direct dischargers to water",
                        "Percentile for Proximity to National Priorities List (NPL) sites",
                        "Percentile for Proximity to Risk Management Plan (RMP) facilities",
                        "Percentile for Proximity to Treatment Storage and Disposal (TSDF) facilities",
                        "Percentile for Ozone level in air", "Percentile for PM2.5 level in air",
                        "Map color bin for % people of color (aka minority)", "Map color bin for % low-income",
                        "Map color bin for % less than high school", "Map color bin for % of households that are limited English speaking",
                        "Map color bin for % under age 5", "Map color bin for % over age 64",
                        "Map color bin for % pre-1960 housing (lead paint indicator)",
                        "Map color bin for Demographic Index (based on 2 factors, % low-income and % people of color (aka minority))",
                        "Map color bin for Diesel particulate matter level in air", "Map color bin for Air toxics cancer risk",
                        "Map color bin for Air toxics respiratory hazard index", "Map color bin for EXAMPLEINDICATOR",
                        "Map color bin for Traffic proximity and volume", "Map color bin for Indicator for major direct dischargers to water",
                        "Map color bin for Proximity to National Priorities List (NPL) sites",
                        "Map color bin for Proximity to Risk Management Plan (RMP) facilities",
                        "Map color bin for Proximity to Treatment Storage and Disposal (TSDF) facilities",
                        "Map color bin for Ozone level in air", "Map color bin for PM2.5 level in air",
                        "Shape length for block group in geodatabase", "Area of block group in geodatabase",
                        "Map popup text for % people of color (aka minority)", "Map popup text for % low-income",
                        "Map popup text for % less than high school", "Map popup text for % of households that are limited English speaking",
                        "Map popup text for % under age 5", "Map popup text for % over age 64",
                        "Map popup text for Demographic Index (based on 2 factors, % low-income and % people of color (aka minority))",
                        "Map popup text for % pre-1960 housing (lead paint indicator)",
                        "Map popup text for Diesel particulate matter level in air",
                        "Map popup text for Air toxics cancer risk", "Map popup text for Air toxics respiratory hazard index",
                        "Map popup text for EXAMPLEINDICATOR", "Map popup text for Traffic proximity and volume",
                        "Map popup text for Indicator for major direct dischargers to water",
                        "Map popup text for Proximity to National Priorities List (NPL) sites",
                        "Map popup text for Proximity to Risk Management Plan (RMP) facilities",
                        "Map popup text for Proximity to Treatment Storage and Disposal (TSDF) facilities",
                        "Map popup text for Ozone level in air", "Map popup text for PM2.5 level in air",
                        "Tract FIPS", "County FIPS", "State FIPS", "Land area of block group in geodatabase",
                        "Water area of block group in geodatabase", "Count of National Priority List Superfund sites nearby",
                        "Count of Treatment Storage Disposal Facilities (TSDF) nearby",
                        "County name", "Flagged as having one or more EJ Indexes at or above 80th percentile nationwide",
                        "Latitude of the block group internal point (approx center)",
                        "Longitude of the block group internal point (approx center)",
                        "Count of denominator for % unemployed", "Count of people unemployed",
                        "% Unemployed", "Percentile for % unemployed", "Map color bin for % unemployed",
                        "Map popup text for % unemployed", "Underground Storage Tanks Indicator",
                        "Percentile for Underground Storage Tanks Indicator", "Map color bin for Underground Storage Tanks Indicator",
                        "Map popup text for Underground Storage Tanks Indicator"),
  formula = c(NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, "under5 <- ageunder5m + ageunder5f",
              "pctunder5 <- ifelse( pop==0, 0, under5 / pop)", "over64 <- age65to66m + age6769m + age7074m + age7579m + age8084m + age85upm +   age65to66f + age6769f + age7074f + age7579f + age8084f + age85upf",
              "pctover64 <- ifelse( pop==0, 0, over64 / pop)", NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, "nonmins <- nhwa", "pcthisp <- ifelse(pop==0, 0, as.numeric(hisp ) / pop)",
              "pctnhwa <- ifelse(pop==0, 0, as.numeric(nhwa ) / pop)", "pctnhba <- ifelse(pop==0, 0, as.numeric(nhba ) / pop)",
              "pctnhaiana <- ifelse(pop==0, 0, as.numeric(nhaiana ) / pop)",
              "pctnhaa <- ifelse(pop==0, 0, as.numeric(nhaa ) / pop)", "pctnhnhpia <- ifelse(pop==0, 0, as.numeric(nhnhpia ) / pop)",
              "pctnhotheralone <- ifelse(pop==0, 0, as.numeric(nhotheralone ) / pop)",
              "pctnhmulti <- ifelse(pop==0, 0, as.numeric(nhmulti ) / pop)",
              "mins <- pop - nhwa", "pctmin <- ifelse(pop==0, 0, as.numeric(mins ) / pop)",
              NA, NA, NA, NA, NA, NA, NA, NA, "num1pov <- pov50 + pov99", "num15pov <- num1pov + pov124 + pov149",
              "num2pov <- num1pov + pov124 + pov149 + pov184 + pov199", "num2pov.alt <- povknownratio - pov2plus",
              "pct1pov <- ifelse( povknownratio==0, 0, num1pov / povknownratio)",
              "pct15pov <- ifelse( povknownratio==0, 0, num15pov / povknownratio)",
              "pct2pov <- ifelse( povknownratio==0, 0, num2pov / povknownratio)",
              "pct2pov.alt <- ifelse( povknownratio==0, 0, num2pov.alt / povknownratio)",
              "lowinc <- num2pov", "pctlowinc <- pct2pov", NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "lths <- m0 + m4 + m6 + m8 + m9 + m10 + m11 + m12 +   f0 + f4 + f6 + f8 + f9 + f10 + f11 + f12",
              NA, NA, NA, NA, NA, "pctlths <- ifelse(age25up==0, 0, as.numeric(lths ) / age25up)",
              "lingiso <- lingisospanish + lingisoeuro + lingisoasian + lingisoother",
              "pctlingiso <- ifelse( hhlds==0, 0, lingiso / hhlds)", "VSI.eo.US <- ( sum(mins) / sum(pop)  +  sum(lowinc) / sum(povknownratio) ) / 2",
              "VSI.eo <- (pctlowinc + pctmin) / 2", "VNI.eo <- VSI.eo * pop",
              "VDI.eo <- (VSI.eo - VSI.eo.US) * pop", NA, NA, NA, NA, "pre1960 <- builtpre1940 + built1940to1949 + built1950to1959",
              "pctpre1960 <- ifelse( builtunits==0, 0, pre1960 / builtunits)",
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
              NA, NA, NA, NA, NA, NA, "pctunemployed <- ifelse(unemployedbase==0, 0, as.numeric(unemployed) / unemployedbase)",
              NA, NA, NA, NA, NA, NA, NA),
  acsfieldnamelong = c(NA, NA, "Total:|SEX BY AGE",
                       "Under 5 years|SEX BY AGE", "5 to 9 years|SEX BY AGE", "10 to 14 years|SEX BY AGE",
                       "15 to 17 years|SEX BY AGE", "65 and 66 years|SEX BY AGE", "67 to 69 years|SEX BY AGE",
                       "70 to 74 years|SEX BY AGE", "75 to 79 years|SEX BY AGE", "80 to 84 years|SEX BY AGE",
                       "85 years and over|SEX BY AGE", "Under 5 years|SEX BY AGE", "5 to 9 years|SEX BY AGE",
                       "10 to 14 years|SEX BY AGE", "15 to 17 years|SEX BY AGE", "65 and 66 years|SEX BY AGE",
                       "67 to 69 years|SEX BY AGE", "70 to 74 years|SEX BY AGE", "75 to 79 years|SEX BY AGE",
                       "80 to 84 years|SEX BY AGE", "85 years and over|SEX BY AGE",
                       NA, NA, NA, NA, "Hispanic or Latino:|HISPANIC OR LATINO ORIGIN BY RACE",
                       "Total:|HISPANIC OR LATINO ORIGIN BY RACE", "Not Hispanic or Latino:|HISPANIC OR LATINO ORIGIN BY RACE",
                       "White alone|HISPANIC OR LATINO ORIGIN BY RACE", "Black or African American alone|HISPANIC OR LATINO ORIGIN BY RACE",
                       "American Indian and Alaska Native alone|HISPANIC OR LATINO ORIGIN BY RACE",
                       "Asian alone|HISPANIC OR LATINO ORIGIN BY RACE", "Native Hawaiian and Other Pacific Islander alone|HISPANIC OR LATINO ORIGIN BY RACE",
                       "Some other race alone|HISPANIC OR LATINO ORIGIN BY RACE", "Two or more races:|HISPANIC OR LATINO ORIGIN BY RACE",
                       "Count not people of color (aka non-minority) i.e. not Hispanic or Latino White alone",
                       "(percent Hispanic or Latino)", "(percent Not Hispanic or Latino White alone)",
                       "(percent Not Hispanic or Latino Black or African American alone)",
                       "(percent Not Hispanic or Latino American Indian and Alaska Native alone)",
                       "(percent Not Hispanic or Latino Asian alone)", "(percent Not Hispanic or Latino Native Hawaiian and Other Pacific Islander alone)",
                       "(percent Not Hispanic or Latino Some other race alone)", "(percent Not Hispanic or Latino Two or more races)",
                       NA, NA, "Total:|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "Under .50|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       ".50 to .99|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "1.00 to 1.24|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "1.25 to 1.49|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "1.50 to 1.84|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "1.85 to 1.99|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "2.00 and over|RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS",
                       "(count in poverty -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 1)",
                       "(count below 1.5 times poverty level -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 1.5)",
                       "(count of low-income -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 2)",
                       "(count of low-income -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 2)",
                       "(percent in poverty -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 1)",
                       "(percent below 1.5 times poverty level -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 1.5)",
                       "(percent low-income -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 2)",
                       "(percent low-income -- RATIO OF INCOME TO POVERTY LEVEL IN THE PAST 12 MONTHS was less than 2)",
                       NA, NA, "Total:|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "No schooling completed|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "Nursery to 4th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "5th and 6th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "7th and 8th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "9th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "10th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "11th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "12th grade, no diploma|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "No schooling completed|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "Nursery to 4th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "5th and 6th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "7th and 8th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "9th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "10th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "11th grade|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       "12th grade, no diploma|SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER",
                       NA, "Spanish - Limited English speaking household", "Other Indo-European languages - Limited English speaking household",
                       "Asian and Pacific Island languages - Limited English speaking household",
                       "Other languages - Limited English speaking household", "Total:|HOUSEHOLD LANGUAGE BY HOUSEHOLDS IN WHICH NO ONE 14 AND OVER SPEAKS ENGLISH ONLY OR SPEAKS A LANGUAGE OTHER THAN ENGLISH AT HOME AND SPEAKS ENGLISH \"VERY WELL\"",
                       NA, "Count of Limited English speaking households", "% of households that are limited English speaking",
                       "Overall US Demographic Index -- avg of percent low-income and percent people of color (aka minority)",
                       NA, NA, NA, "Total:|YEAR STRUCTURE BUILT", "Built 1950 to 1959|YEAR STRUCTURE BUILT",
                       "Built 1940 to 1949|YEAR STRUCTURE BUILT", "Built 1939 or earlier|YEAR STRUCTURE BUILT",
                       NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                       NA, NA, NA, "Percentile for % of households that are limited English speaking",
                       NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                       NA, NA, "Map color bin for % of households that are limited English speaking",
                       NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                       NA, NA, NA, NA, "Map popup text for % of households that are limited English speaking",
                       NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                       NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "Civilian labor force|EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER",
                       "Unemployed|EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER",
                       NA, NA, NA, NA, NA, NA, NA, NA),
  universe = c(NA, NA, "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               NA, NA, NA, NA, "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               "Universe:  Total population", "Universe:  Total population",
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               "Universe:  Population for whom poverty status is determined",
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               "Universe:  Population 25 years and over", "Universe:  Population 25 years and over",
               NA, "Universe:  Households", "Universe:  Households", "Universe:  Households",
               "Universe:  Households", "Universe:  Households", NA, NA, NA,
               NA, NA, NA, NA, "Universe:  Housing units", "Universe:  Housing units",
               "Universe:  Housing units", "Universe:  Housing units", NA, NA,
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
               NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
               NA, NA, NA, NA, "Universe:  Population 16 years and over", "Universe:  Population 16 years and over",
               "Universe:  Population 16 years and over", "Universe:  Population 16 years and over",
               "Universe:  Population 16 years and over", "Universe:  Population 16 years and over",
               NA, NA, NA, NA)
),
census_version = 2020, acs_version = "2016-2020", acs_releasedate = "3/17/2022",
ejscreen_version = "2.1", ejscreen_releasedate = "October 2022", ejscreen_pkg_data = "bg22",
row.names = c("1",
              "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13",
              "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
              "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35",
              "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46",
              "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57",
              "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68",
              "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79",
              "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
              "91", "92", "93", "95", "97", "99", "101", "102", "103", "104",
              "105", "106", "107", "108", "109", "110", "111", "112", "113",
              "114", "115", "116", "117", "118", "119", "120", "193", "194",
              "195", "196", "197", "198", "199", "200", "202", "203", "204",
              "205", "206", "207", "208", "209", "210", "211", "212", "285",
              "286", "287", "288", "289", "290", "291", "292", "294", "295",
              "296", "297", "298", "299", "300", "301", "302", "303", "304",
              "377", "378", "379", "380", "381", "382", "383", "384", "385",
              "387", "394", "401", "408", "415", "422", "429", "436", "443",
              "450", "457", "464", "471", "472", "473", "474", "475", "476",
              "477", "478", "479", "480", "481", "1100", "2100", "3100", "610",
              "910", "1210", "482", "710", "1010", "1310"),
class = "data.frame")
######################################## #

dropthese <- c("VSI.eo.US", "VSI.eo", "VDI.eo", "VNI.eo")
x <- x[!(x$Rfieldname %in% dropthese), ]
x$acsfieldname_ <-gsub("\\.", "_", x$acsfieldname)


formulas_ejscreen_acs2r <- paste0(x$Rfieldname, " = ", x$acsfieldname_)
formulas_ejscreen_acs2r <- formulas_ejscreen_acs2r[!is.na(x$acsfieldname_)]
formulas_ejscreen_r2r <- x$formula[!is.na(x$formula)]
formulas_ejscreen_acs <- c(formulas_ejscreen_acs2r, formulas_ejscreen_r2r)
formulas_ejscreen_acs <- data.frame(rname = EJAM:::formula_varname(formulas_ejscreen_acs), formula = formulas_ejscreen_acs)

formulas_ejscreen_acs$longname_old <- x$glossaryfieldname[match(formulas_ejscreen_acs$rname, x$Rfieldname)]
formulas_ejscreen_acs$longname <-  fixcolnames(formulas_ejscreen_acs$rname, "r", "long")

# pop3002 == pop


rm(x, formulas_ejscreen_acs2r, formulas_ejscreen_r2r)
######################################## #
print(as.matrix(formulas_ejscreen_acs)[1:69,])
######################################## #



# see datacreate_formulas.R


# fix errors in formulas_d
# and
# see which of the original so-called formulas_d were actually formulas for creating indicators based on raw counts or components
# as opposed to many that were simply trying to aggregate via wtd mean or were just wrong

formula_RHS1 = function(one_formula) {gsub(paste0("^", trimws(EJAM:::formula_varname(one_formula))), " ", one_formula)}
formula_was_for_aggregation1 = function(one_formula) {grepl(EJAM:::formula_varname(one_formula), formula_RHS1(one_formula))}
formula_was_for_aggregation = function(formulas) {sapply(formulas, FUN = formula_was_for_aggregation1)}

x = data.frame(agg = formula_was_for_aggregation(formulas_d))
x$var = EJAM:::formula_varname(rownames(x))
x$varlist = EJAM:::varinfo(x$var)$varlist
x$formula = rownames(x); rownames(x) <- NULL
x = x[order(x$agg,x$varlist, x$var), ]

#  fix errors in these 4:
# > x[!x$agg & !grepl("^pct", x$var),]
#       agg                                var             varlist                                                                                                           formula
# 15  FALSE         EJ.DISPARITY.pctpre1960.eo            names_ej                 EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.eo) / pop)
# 16  FALSE       EJ.DISPARITY.pctpre1960.supp       names_ej_supp             EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.supp) / pop)
# 111 FALSE   state.EJ.DISPARITY.pctpre1960.eo      names_ej_state     state.EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.eo) / pop)
# 112 FALSE state.EJ.DISPARITY.pctpre1960.supp names_ej_supp_state state.EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.supp) / pop)

formulas_d <- gsub("EJ.DISPARITY.pre1960", "EJ.DISPARITY.pctpre1960", formulas_d)

EJAM:::metadata_add_and_use_this("formulas_d")  # to re-save it

x$formula <- gsub("EJ.DISPARITY.pre1960", "EJ.DISPARITY.pctpre1960", x$formula)

x = data.frame(agg = formula_was_for_aggregation(formulas_d))
x$var = EJAM:::formula_varname(rownames(x))
x$varlist = EJAM:::varinfo(x$var)$varlist
x$formula = rownames(x); rownames(x) <- NULL
x = x[order(x$agg,x$varlist, x$var), ]
x

######################################## #
# added formulas to formulas_ejscreen_acs that were only in formulas_d
#
x = x[!x$agg,]
add = !(x$var %in% formulas_ejscreen_acs$rname)
formulas_ejscreen_acs_newrows = data.frame(rname = x$var[add], formula = x$formula[add], longname_old = NA, longname = fixcolnames(x$var[add], 'rname', 'long'))
formulas_ejscreen_acs <- rbind(formulas_ejscreen_acs, formulas_ejscreen_acs_newrows)

######################################## #


####  FORMULAS FOR GEOGRAPHIC INFO: bgid, etc., from fips
#
## e.g., ## fips = c("721537506021", "010010201002")

formulas_ejscreen_acs_newrows = data.frame(
  rname = c(
    'bgid',
    'countyname',
    'statename',
    'ST',
    'REGION'
  ),
  formula = c(
    "bgid = EJAM::bgpts[match(fips, bgfips), bgid]",
    "countyname = fips2countyname(fips, includestate = FALSE)",
    "statename = fips2statename(fips)",
    "ST = fips2stateabbrev(fips)",
    "REGION = EJAM:::fips_st2eparegion(ST)"
  ),
  longname_old = NA,
  longname = NA
  )
formulas_ejscreen_acs_newrows$longname <- fixcolnames(formulas_ejscreen_acs_newrows$rname, 'rname', 'long')

formulas_ejscreen_acs <- rbind(formulas_ejscreen_acs, formulas_ejscreen_acs_newrows)
rm(formulas_ejscreen_acs_newrows)
######################################## #
# fill in 61 longname where had not been available

need <- formulas_ejscreen_acs$longname == formulas_ejscreen_acs$rname
formulas_ejscreen_acs$longname[need] <- formulas_ejscreen_acs$longname_old[need]
rm(need, formulas_ejscreen_acs_newrows, add )
######################################## #
# add a few more that were missing

## broadband tables search
endyr = 2022
x <- tidycensus::load_variables(endyr, "acs5")
x[grepl("B28003", x$name) & "block group" == x$geography & !is.na(x$geography), ] |> print(n=10 )
# health insurance tables/variables
x[grepl("no health insurance", x$label, ignore.case = T) & "block group" == x$geography & !is.na(x$geography), ] |> print(n=100 )

formulas_ejscreen_acs_newrows <- data.frame(
  rname = NA,
  formula = c(
  "under18 <- ageunder5m + age5to9m + age10to14m + age15to17m + ageunder5m + age5to9f + age10to14f + age15to17f",
  "over17 <- pop - under18",
  "female = B01001_026",
  "male = B01001_002",

  "ownedunits = B25032_002",
  "occupiedunits = ",

  ## B28002 ?
  "nobroadband = B28003_001 - B28003_004", # ie, all minue "Has a computer:!!With a broadband Internet subscription" *** ##  NEED TO CONFIRM THIS IS WHAT EJSCREEN USED

  "nohealthinsurance = B27010_017 + B27010_033 + B27010_050 + B27010_066",  ##  NEED TO CONFIRM THIS IS WHAT EJSCREEN USED

  "poor = pov50 + pov99"
  ),
  longname_old = NA,
  longname = NA
)
formulas_ejscreen_acs_newrows$rname = formula_varname(formulas_ejscreen_acs_newrows$formula)
formulas_ejscreen_acs_newrows$longname <- fixcolnames(formulas_ejscreen_acs_newrows$rname, 'rname', 'long')

formulas_ejscreen_acs <- rbind(formulas_ejscreen_acs, formulas_ejscreen_acs_newrows)
rm(formulas_ejscreen_acs_newrows)

############################################################## #
# FORMULAS FOR RACE WITHOUT ETHNICITY

# B03002_003 Estimate!!Total:!!Not Hispanic or Latino:!!White alone
# is the non-hispanic version Census ACS table.
## B02001 is a different table than the NonHispanic Alone table


formulas_ejscreen_acs_newrows <- data.frame(
  rname = NA,
  formula = c(
    c(
      "wa = B02001_002",  # "pctwa = ifelse( pop"
      "ba = B02001_003",  #  "pctba"
      "aa = B02001_005",  #  "pctaa"
      "aiana = B02001_004",  #  "pctaiana"
      "nhpia = B02001_006",  # "pctnhpia"
      "otheralone = B02001_007", #  "pctotheralone"
      "multi = B02001_008"      # "pctmulti"
    )
    # ,   #   ALREADY HAD THESE:
    # c(
    #   "pctwa <- ifelse(pop==0, 0, as.numeric(wa ) / pop)",  #                (percent White alone)
    #   "pctba <- ifelse(pop==0, 0, as.numeric(ba ) / pop)",  #                (percent Black or African American alone)
    #   "pctaiana <- ifelse(pop==0, 0, as.numeric(aiana ) / pop)", #           (percent American Indian and Alaska Native alone)
    #   "pctaa <- ifelse(pop==0, 0, as.numeric(aa ) / pop)",       #           (percent Asian alone)
    #   "pctnhpia <- ifelse(pop==0, 0, as.numeric(nhpia ) / pop)", #           (percent Native Hawaiian and Other Pacific Islander alone)
    #   "pctotheralone <- ifelse(pop==0, 0, as.numeric(otheralone ) / pop)", # (percent Some other race alone)
    #   "pctmulti <- ifelse(pop==0, 0, as.numeric(multi ) / pop)"           # (percent Two or more races)
    # )
  ),
  longname_old = NA,
  longname = NA
)
formulas_ejscreen_acs_newrows$rname = formula_varname(formulas_ejscreen_acs_newrows$formula)
formulas_ejscreen_acs_newrows$longname <- fixcolnames(formulas_ejscreen_acs_newrows$rname, 'rname', 'long')

formulas_ejscreen_acs <- rbind(formulas_ejscreen_acs, formulas_ejscreen_acs_newrows)
rm(formulas_ejscreen_acs_newrows)
############################################################## #
# fill in more missing longname entries

formulas_ejscreen_acs$longname[is.na(formulas_ejscreen_acs$longname)  ] <- formulas_ejscreen_acs$rname[is.na(formulas_ejscreen_acs$longname)  ]

############################################################## #

## SIMPLIFY TWO KEY FORMULAS

formulas_ejscreen_acs$formula[formulas_ejscreen_acs$rname == "lowinc"] <-
  "lowinc = povknownratio - pov2plus"
# "lowinc = C17002_001 - C17002_008"

formulas_ejscreen_acs$formula[formulas_ejscreen_acs$rname == "pctlowinc"] <-
  "pctlowinc = ifelse( povknownratio==0, 0, lowinc / povknownratio)"

############################################################## #

##    CAN ADD THESE FORMULAS ASAP: ***   just need to confirm the ACS variable numbers/tables and add formulas here:

# [39,] "occupiedunits"          "names_community"
# [27,] "percapincome"           "names_community"

# [28,] "lan_universe"           "names_d_language_count"
# [29,] "lan_nonenglish"         "names_d_language_count"
# [30,] "lan_eng_na"             "names_d_language_count"
# [31,] "lan_spanish"            "names_d_language_count"
# [32,] "lan_ie"                 "names_d_language_count"
# [33,] "lan_api"                "names_d_language_count"
# [34,] "lan_other"              "names_d_language_count"

# [35,] "spanish_li"             "names_d_languageli_count"
# [36,] "ie_li"                  "names_d_languageli_count"
# [37,] "api_li"                 "names_d_languageli_count"
# [38,] "other_li"               "names_d_languageli_count"







############################################################## #

# the only other ones I could add now based on ACS?

# "percapincome"


############################################################## #

message("SAVING FORMULAS, AND CAN USE IN CREATING INITIAL blockgroupstats table from raw acs as with acs_bybg()
        or newer get_acs_new_dat() but  then need final steps for Demog.Index scores and for disability by blockgroup not tract")

### confirmed all of acstabs are mentioned among formulas created here
# for (i in 1:length(acstabs)) {cat(acstabs[i]); print( any(grepl(acstabs[i], EJAM::formulas_ejscreen_acs$formula))) }
# cbind(acstabs, concept = v22$concept[match(acstabs, v22$table)] )


# formulas_ejscreen_acs  saved for use in package

EJAM:::metadata_add_and_use_this("formulas_ejscreen_acs")
EJAM:::dataset_documenter("formulas_ejscreen_acs",
                          description = "Formulas and metadata about Census ACS variables and how to calculate indicators from those raw Census variables, such as creating pctunder5 starting from ACS table B01001 variables.",
                          details = "[Formulas as documented by EPA were archived here](https://web.archive.org/web/20250118134239/https://www.epa.gov/system/files/documents/2024-07/ejscreen-tech-doc-version-2-3.pdf)",
                          seealso = "`acs_bybg()`")




############################################################## #

# "lowlifex"  is from CDC so no formula here except possibly
# "lowlifex = 1 - (lifex / maxlifex)"
# but lifex by bg is imported from CDC 1st, not from ACS, and maxlifex is a US constant based on that source.
# % Low Life Expectancy is defined as “1 – (Life Expectancy / Max Life Expectancy)”
# Note: This is derived from the CDC life expectancy at birth data using the formula above.
############################################################## #
