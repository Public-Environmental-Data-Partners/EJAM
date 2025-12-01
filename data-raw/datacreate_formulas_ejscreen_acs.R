
# script to make a set of formulas that can convert raw ACS5 data into ejscreen indicators

# this script was used once 11/2025 to update and save the formulas, but would not be used again in this form for annual updates of formulas
# which would be done manually if necessary at all - sometimes table numbering changes in the ACS vs prior years

if (FALSE) {
############################################################## ############################################################### #
{
  # ######################### ## ######################### ## ######################### #
  ## see the list of relevant tables
  # ######################### ## ######################### ## ######################### #


  # ejscreen_acs_tables <- c(
  #
  #   "B25034", # pre1960, for lead paint indicator (environmental not demographic per se)
  #
  #   "B01001", # sex and age / basic population counts
  #   "B03002", # race with breakdown by hispanic ethnicity
  #   "B02001", # race without breakdown by hispanic ethnicity
  #   "B15002", # education (less than high school)
  #   "B23025", # unemployed
  #   "C17002", # low income, poor, etc.
  #   "B19301", # per capita income
  #   "B25032", # owned units vs rented units (occupied housing units, same universe as B25003)
  #   "B28003", # no broadband
  #   "B27010", # no health insurance
  #   "C16002", # (language category and) % of households limited English speaking (lingiso) "https://data.census.gov/table/ACSDT5Y2023.C16002"
  #   "B16004", # (language category and) % of residents (not hhlds) speak no English at all "https://data.census.gov/table/ACSDT5Y2023.B16004"
  #   ####### TRACT ONLY:
  #   #   Note some tables used by EJSCREEN are only available at tract resolution, namely
  #   #   C16001 for detailed specific languages as % of residents, and B18101 for % with disability
  #   "C16001", # languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc.  "https://data.census.gov/table/ACSDT5Y2023.C16001"
  #   "B18101" # disability -- at tract resolution only ########### #
  # )
  ## ######################### #

  tables <- tables_ejscreen_acs
  ## ######################### #

  ## from    tidycensus::load_variables(year = 2023, dataset = "acs5")
  #         name        label       concept                                                                                        table

  # 9 B25034_001 Estimate!!Total:   Year Structure Built                                                                           B25034

  # 1 B01001_001 Estimate!!Total:   Sex by Age                                                                                     B01001
  # 3 B03002_001 Estimate!!Total:   Hispanic or Latino Origin by Race                                                              B03002
  # 2 B02001_001 Estimate!!Total:   Race                                                                                           B02001
  # 4 B15002_001 Estimate!!Total:   Sex by Educational Attainment for the Population 25 Years and Over                             B15002
  # 7 B23025_001 Estimate!!Total:   Employment Status for the Population 16 Years and Over                                         B23025
  #13 C17002_001 Estimate!!Total:   Ratio of Income to Poverty Level in the Past 12 Months                                         C17002
  # 6 B19301_001 Estimate!!Per capita income in the past 12 months (in 2023 inflation-adjusted dollars) Per Capita Income in the Past 12 Months (in 2023 Inflation-Adjusted Dollars)  B19301
  # 8 B25032_001 Estimate!!Total:   Tenure by Units in Structure                                                                   B25032
  #11 B28003_001 Estimate!!Total:   Presence of a Computer and Type of Internet Subscription in Household                          B28003
  #10 B27010_001 Estimate!!Total:   Types of Health Insurance Coverage by Age                                                      B27010
  #12 C16002_001 Estimate!!Total:   Household Language by Household Limited English Speaking Status                                C16002
  # 5 B16004_001 Estimate!!Total:    for no english at all
  ####### TRACT ONLY:
  #   C16001_001 Estimate!!Total:   Language Spoken at Home for the Population 5 Years and Over         C16001
  #   B18101_001 Estimate!!Total:   Sex by Age by Disability Status                                     B18101
############################################################## #

#  "B16002", # NOT USED. by tract. languages (e.g., Chinese, slavic), "Detailed Household Language by Household Limited English Speaking Status"

## to get metadata about tables and variables using an API key and the tidycensus package

# v22 = tidycensus::load_variables(year = 2022, dataset = "acs5"); v22$table = gsub("_.*$", "", v22$name)
# v23 = tidycensus::load_variables(year = 2023, dataset = "acs5"); v23$table = gsub("_.*$", "", v23$name)
## v24 = tidycensus::load_variables(year = 2024, dataset = "acs5"); v24$table = gsub("_.*$", "", v24$name)

## get the topic (concept) of each table

# concept = v22$concept[match(tables, v22$table)]
# cbind(tables, concept = v22$concept[match(tables, v22$table)] )

# unique(v22$table) # over 1,000 tables if all geo scales counted
# unique(v22$table[v22$geography == "block group"]) #  about 400 tables for just bg data
## to list just blockgroup and tract tables:
# v22 = v22[v22$geography %in% c("tract", "block group"), ]
# unique(v22$table) # almost 1,000 tables if bg and tract scales kept
## confirmed all tables listed as ejscreen relevant are in fact found in this list of all acs5 tables
# cbind(tables, acs2022 = tables %in% v22$table, acs2023 = tables %in% v23$table)

}
########################################################################################## #

# Formulas as documented by EPA archived at
# https://web.archive.org/web/20250118134239/https://www.epa.gov/system/files/documents/2024-07/ejscreen-tech-doc-version-2-3.pdf
# and more links recorded at
# https://github.com/ejanalysis/EJAM/blob/main/data-raw/EJSCREEN_archived_pages/EJSCREEN_archived_pages_and_docs.md
# and list of indicators at
# https://github.com/ejanalysis/EJAM/blob/formulas_ejscreen_acs/data-raw/EJSCREEN_archived_pages/ejscreen_sources_plaintext.md
########################################################################################## #
# started from partially done table, that had some formulas but not all:
{
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
}


# see datacreate_formulas.R

######################################## #
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

#  fixed errors in these 4:
# > x[!x$agg & !grepl("^pct", x$var),]
#       agg                                var             varlist                                                                                                           formula
# 15  FALSE         EJ.DISPARITY.pctpre1960.eo            names_ej                 EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.eo) / pop)
# 16  FALSE       EJ.DISPARITY.pctpre1960.supp       names_ej_supp             EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.supp) / pop)
# 111 FALSE   state.EJ.DISPARITY.pctpre1960.eo      names_ej_state     state.EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.eo) / pop)
# 112 FALSE state.EJ.DISPARITY.pctpre1960.supp names_ej_supp_state state.EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.supp) / pop)

# formulas_d <- gsub("EJ.DISPARITY.pre1960", "EJ.DISPARITY.pctpre1960", formulas_d)
#
# EJAM:::metadata_add_and_use_this("formulas_d")  # to re-save it
######################################## #
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

    "ownedhhlds    = B25003_002", # per ACS5 metadata via tidycensus for 2022yr  ***
    "occupiedhhlds = B25003_001",
    "pctownedhhlds <- ifelse(occupied == 0, 0, ownedhhlds / occupiedhhlds)",
    ##
    "ownedunits    = B25032_002", # (housing units)
    "occupiedunits = B25032_001", # (housing units)
    # "pctownedunits      <- ifelse(occupiedunits == 0, 0, as.numeric(ownedunits) / occupiedunits)" # already was in the formulas


    ## B28002 ?
    "nobroadband = B28003_001 - B28003_004", # ie, all minue "Has a computer:!!With a broadband Internet subscription" *** ##  NEED TO CONFIRM THIS IS WHAT EJSCREEN USED

    "nohealthinsurance = B27010_017 + B27010_033 + B27010_050 + B27010_066",  ##  NEED TO CONFIRM THIS IS WHAT EJSCREEN USED

    "poor = pov50 + pov99"
  ),
  longname_old = NA,
  longname = NA
)
formulas_ejscreen_acs_newrows$rname = EJAM:::formula_varname(formulas_ejscreen_acs_newrows$formula)
formulas_ejscreen_acs_newrows$longname <- EJAM:::fixcolnames(formulas_ejscreen_acs_newrows$rname, 'rname', 'long')

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
formulas_ejscreen_acs_newrows$rname = EJAM:::formula_varname(formulas_ejscreen_acs_newrows$formula)
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
############################################################## ############################################################### #
{
  # ######################### ## ######################### ## ######################### #
  ## see the list of relevant tables
  # ######################### ## ######################### ## ######################### #

  # ejscreen_acs_tables <- c(
  #
  #   "B25034", # pre1960, for lead paint indicator (environmental not demographic per se)
  #
  #   "B01001", # sex and age / basic population counts
  #   "B03002", # race with breakdown by hispanic ethnicity
  #   "B02001", # race without breakdown by hispanic ethnicity
  #   "B15002", # education (less than high school)
  #   "B23025", # unemployed
  #   "C17002", # low income, poor, etc.
  #   "B19301", # per capita income
  #   "B25032", # owned units vs rented units (occupied housing units, same universe as B25003)
  #   "B28003", # no broadband
  #   "B27010", # no health insurance
  #   "C16002", # (language category and) % of households limited English speaking (lingiso) "https://data.census.gov/table/ACSDT5Y2023.C16002"
  #   "B16004", # (language category and) % of residents (not hhlds) speak no English at all "https://data.census.gov/table/ACSDT5Y2023.B16004"
  #   ####### TRACT ONLY:
  #   #   Note some tables used by EJSCREEN are only available at tract resolution, namely
  #   #   C16001 for detailed specific languages as % of residents, and B18101 for % with disability
  #   "C16001", # languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc.  "https://data.census.gov/table/ACSDT5Y2023.C16001"
  #   "B18101" # disability -- at tract resolution only ########### #
  # )
  #         name        label       concept                                                                                        table

  # 9 B25034_001 Estimate!!Total:   Year Structure Built                                                                           B25034

  # 1 B01001_001 Estimate!!Total:   Sex by Age                                                                                     B01001
  # 3 B03002_001 Estimate!!Total:   Hispanic or Latino Origin by Race                                                              B03002
  # 2 B02001_001 Estimate!!Total:   Race                                                                                           B02001
  # 4 B15002_001 Estimate!!Total:   Sex by Educational Attainment for the Population 25 Years and Over                             B15002
  # 7 B23025_001 Estimate!!Total:   Employment Status for the Population 16 Years and Over                                         B23025
  #13 C17002_001 Estimate!!Total:   Ratio of Income to Poverty Level in the Past 12 Months                                         C17002
  # 6 B19301_001 Estimate!!Per capita income in the past 12 months (in 2023 inflation-adjusted dollars) Per Capita Income in the Past 12 Months (in 2023 Inflation-Adjusted Dollars)  B19301
  # 8 B25032_001 Estimate!!Total:   Tenure by Units in Structure                                                                   B25032
  #11 B28003_001 Estimate!!Total:   Presence of a Computer and Type of Internet Subscription in Household                          B28003
  #10 B27010_001 Estimate!!Total:   Types of Health Insurance Coverage by Age                                                      B27010
  #12 C16002_001 Estimate!!Total:   Household Language by Household Limited English Speaking Status                                C16002
  # 5 B16004_001 Estimate!!Total:    for no english at all
  ####### TRACT ONLY:
  #   C16001_001 Estimate!!Total:   Language Spoken at Home for the Population 5 Years and Over         C16001
  #   B18101_001 Estimate!!Total:   Sex by Age by Disability Status                                     B18101

  # ######################### ## ######################### ## ######################### #
}
############################################################## ############################################################### #

##   ADD MORE LANGUAGE VARIABLES AND FORMULAS

############################################################## ############################################################### #

# these counts, inputs, need to be added to map_headernames$rname: ***
#
#   c("lan_arabic", "lan_english", "lan_french", "lan_other_asian",  "lan_other_ie", "lan_rus_pol_slav", "lan_vietnamese")
formulas_ejscreen_acs[grepl("lan_", formulas_ejscreen_acs$formula),]
#                  rname                                                                                               formula longname_old                                                    longname

# 112          pctlan_api                   pctlan_api      <- ifelse(lan_universe == 0, 0, as.numeric(lan_api) / lan_universe)         <NA>       % speaking Asian and Pacific Island languages at home

## fix: ***
# is this part of groups or part of detailed languages?
# 120     pctlan_other_ie         pctlan_other_ie      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_ie) / lan_universe)         <NA>                            % speaking Indo-European at home
# 116           pctlan_ie                     pctlan_ie      <- ifelse(lan_universe == 0, 0, as.numeric(lan_ie) / lan_universe)         <NA>                      % speaking Other Indo-European at home

## fix: ***
## spanish exists as part of groups and detailed languages - in both tables
# 122      pctlan_spanish           pctlan_spanish      <- ifelse(lan_universe == 0, 0, as.numeric(lan_spanish) / lan_universe)         <NA>                                  % speaking Spanish at home

## fix: ***
# is this part of groups or part of detailed languages?
# 118        pctlan_other               pctlan_other      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other) / lan_universe)         <NA>          % speaking Other and Unspecified languages at home

## fix: ***
## clarify if this is NO English or any non-english:
# 117   pctlan_nonenglish     pctlan_nonenglish      <- ifelse(lan_universe == 0, 0, as.numeric(lan_nonenglish) / lan_universe)         <NA>                    % speaking Non English languages at home

dput(gsub("pct","", formulas_ejscreen_acs[grepl("lan_", formulas_ejscreen_acs$formula),]$rname))
setdiff(gsub("pct","", formulas_ejscreen_acs[grepl("lan_", formulas_ejscreen_acs$formula),]$rname), map_headernames$rname)
#  "lan_arabic"  "lan_english"  "lan_french"  "lan_other_asian"  "lan_other_ie"  "lan_rus_pol_slav"  "lan_vietnamese"
################################################## #

## these need denominator filled in within map_headernames: ***
#
#   z = (varinfo(grep("lan_|_li", names_all_r,value = T))[,c("rname", "denominator", "apisection","longname")])
#   z[z$denominator == "", ]
#
##  "api_li" "ie_li"   "other_li"       "spanish_li"
##  "lan_api" "lan_eng_na" "lan_ie" "lan_nonenglish" "lan_other" "lan_spanish"
##  "lan_universe"


#   (varinfo(grep("lan_|_li", names_all_r,value = T))[,c("rname", "denominator", "apisection","longname")])

#                                   rname  denominator                            apisection                                                                       longname

# spanish_li                   spanish_li                                                  0                         Number speaking Spanish (in limited English household)
# api_li                           api_li                                                  0            Number speaking Asian-Pacific Island (in limited English household)
# ie_li                             ie_li                                                  0             Number speaking Other Indo-European (in limited English household)
# other_li                       other_li                                                                              Number speaking Other (in limited English household)
#
# pctspanish_li             pctspanish_li      lingiso Breakdown by Limited English Speaking                        % speaking Spanish (as % of limited English households)
# pctapi_li                     pctapi_li      lingiso Breakdown by Limited English Speaking % speaking Asian-Pacific Island languages (as % of limited English households)
# pctie_li                       pctie_li      lingiso Breakdown by Limited English Speaking  % speaking Other Indo-European languages (as % of limited English households)
# pctother_li                 pctother_li      lingiso Breakdown by Limited English Speaking                % speaking Other languages (as % of limited English households)


# lan_universe               lan_universe                                                  0    Number of Persons for whom Language Ability is Determined--age 5 and above.

# lan_eng_na                   lan_eng_na                                                  0                                             Number speaking English Not at All

# missing? lan_english, count speaking english at home.

# lan_nonenglish           lan_nonenglish                                                  0                                            Number speaking non-English at home
# lan_spanish                 lan_spanish                                                  0                                                Number speaking Spanish at Home
# lan_api                         lan_api                                                  0                          Number speaking Asian-Pacific Island language at Home
# lan_ie                           lan_ie                                                  0                                    Number speaking Other Indo-European at Home
#  # note formulas have  pctlan_other_ie  and also  pctlan_ie, an alias to drop probably.
# lan_other                     lan_other                                                                           Number speaking Other and Unspecified languages at home

# pctlan_english           pctlan_english lan_universe              Languages Spoken at Home                                                     % speaking English at home
# pctlan_nonenglish     pctlan_nonenglish lan_universe              Languages Spoken at Home                                       % speaking Non English languages at home
# pctlan_spanish           pctlan_spanish lan_universe              Languages Spoken at Home                                                     % speaking Spanish at home
# pctlan_api                   pctlan_api lan_universe              Languages Spoken at Home                          % speaking Asian and Pacific Island languages at home
# pctlan_ie                     pctlan_ie lan_universe              Languages Spoken at Home                                         % speaking Other Indo-European at home
#  # note formulas have  pctlan_other_ie  and also  pctlan_ie, an alias to drop probably.
# pctlan_other               pctlan_other lan_universe              Languages Spoken at Home                             % speaking Other and Unspecified languages at home


# pctlan_arabic             pctlan_arabic lan_universe              Languages Spoken at Home                                                      % speaking Arabic at home
# pctlan_french             pctlan_french lan_universe              Languages Spoken at Home                                                      % speaking French at home

# pctlan_other_asian   pctlan_other_asian lan_universe              Languages Spoken at Home                    % speaking Other Asian and Pacific Island languages at home
# pctlan_other_ie         pctlan_other_ie lan_universe              Languages Spoken at Home                                               % speaking Indo-European at home
# pctlan_rus_pol_slav pctlan_rus_pol_slav lan_universe              Languages Spoken at Home                             % speaking Russian, Polish or Other Slavic at home
# pctlan_vietnamese     pctlan_vietnamese lan_universe              Languages Spoken at Home                                                  % speaking Vietnamese at home
################################################## #
# add language formulas:
################################################## #
# complete list of variables available from C16001, based on download from e.g, https://data.census.gov/table/ACSDT5Y2022.C16001?q=c16001&g=1400000US42091203500&y=2022
## COUNTS OF RESIDENTS BY TRACT
c16001_vars <- data.frame(
  varname = c("C16001_001", "C16001_002", "C16001_003",
              "C16001_006", "C16001_009", "C16001_012", "C16001_015", "C16001_018",
              "C16001_021", "C16001_024", "C16001_027", "C16001_030", "C16001_033",
              "C16001_036"),
  label = c("Total", "Speak only English", "Spanish",
            "French, Haitian, or Cajun", "German or other West Germanic languages",
            "Russian, Polish, or other Slavic languages", "Other Indo-European languages",
            "Korean", "Chinese (incl. Mandarin, Cantonese)", "Vietnamese",
            "Tagalog (incl. Filipino)", "Other Asian and Pacific Island languages",
            "Arabic", "Other and unspecified languages")
)
#       varname                                      label
# 1  C16001_001                                      Total
# 2  C16001_002                         Speak only English
# 3  C16001_003                                    Spanish
# 4  C16001_006                  French, Haitian, or Cajun
# 5  C16001_009    German or other West Germanic languages
# 6  C16001_012 Russian, Polish, or other Slavic languages
# 7  C16001_015              Other Indo-European languages
# 8  C16001_018                                     Korean
# 9  C16001_021        Chinese (incl. Mandarin, Cantonese)
# 10 C16001_024                                 Vietnamese
# 11 C16001_027                   Tagalog (incl. Filipino)
# 12 C16001_030   Other Asian and Pacific Island languages
# 13 C16001_033                                     Arabic
# 14 C16001_036            Other and unspecified languages
################################################## ################################################### #
formulas_ejscreen_acs_newrows <- data.frame(
  rname = NA,
  formula = c(

    "percapincome = B19301_001",

    ### count of RESIDENTS in BG   (in limited english hhlds)
    # "spanish_li = C16002_004",  #  lingisospanish  "names_d_languageli_count"  seems duplicative
    # "ie_li = C16002_007",       #  lingisoeuro     "names_d_languageli_count"
    # "api_li = C16002_010",      #  lingisoasian    "names_d_languageli_count"
    # "other_li = C16002_013",    #  lingisoother    "names_d_languageli_count"

    #    "lan_nonenglish = ",  # ??      # "names_d_language_count"

    # count of RESIDENTS in BG
    ## english not at all:
    "lan_eng_na = B16004_008 + B16004_013 + B16004_018 + B16004_023 + B16004_030 + B16004_035 + B16004_040 + B16004_045 + B16004_052 + B16004_057 + B16004_062 + B16004_067",            # "names_d_language_count"

    "lan_spanish  = B16004_004 + B16004_026 + B16004_048", # would be count of RESIDENTS in BG         #  "names_d_language_count"
    "lan_api = B16004_014 + B16004_036 + B16004_058",               # "names_d_language_count"
    "lan_other = B16004_019 + B16004_041 + B16004_063",             # "names_d_language_count"
    "lan_other_ie = B16004_009 + B16004_031 + B16004_053",    #    tract only version is C16001_015
    # "lan_ie = ",   # dupe?             # "names_d_language_count"

    ###################### #
    ### THESE ARE ## COUNTS OF RESIDENTS BY TRACT
    "lan_universe = C16001_001", # total in TRACT, was saved for each bg.  # B16004_001", # for % of residents (not hhlds)

    "lan_english = C16001_002", # only English would be C16001_002
    "pctlan_english <- ifelse(lan_universe == 0, 0, as.numeric(lan_english) / lan_universe)",  # was already there
    "lan_french = C16001_006",
    "pctlan_french <- ifelse(lan_universe == 0, 0, as.numeric(lan_french) / lan_universe)",  # was already there
    "lan_german = C16001_009",
    "pctlan_german <- ifelse(lan_universe == 0, 0, as.numeric(lan_german) / lan_universe)",
    "lan_rus_pol_slav = C16001_012",
    "pctlan_rus_pol_slav <- ifelse(lan_universe == 0, 0, as.numeric(lan_rus_pol_slav) / lan_universe)",  # was already there
    "lan_other_ie = C16001_015",  # pctlan_other_ie goes here
    "pctlan_other_ie <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_ie) / lan_universe)",
    "lan_korean = C16001_018",
    "pctlan_korean <- ifelse(lan_universe == 0, 0, as.numeric(lan_korean) / lan_universe)",
    "lan_chinese = C16001_021",
    "pctlan_chinese <- ifelse(lan_universe == 0, 0, as.numeric(lan_chinese) / lan_universe)",
    "lan_vietnamese = C16001_024",
    "pctlan_vietnamese <- ifelse(lan_universe == 0, 0, as.numeric(lan_vietnamese) / lan_universe)",   # was already there
    "lan_other_asian = C16001_030",
    "pctlan_other_asian <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_asian) / lan_universe)",   # was already there
    "lan_tagalog = C16001_027",
    "pctlan_tagalog <- ifelse(lan_universe == 0, 0, as.numeric(lan_tagalog) / lan_universe)",
    "lan_arabic = C16001_033",
    "pctlan_arabic <- ifelse(lan_universe == 0, 0, as.numeric(lan_arabic) / lan_universe)",   # was already there
    "lan_other_and_unspecified = C16001_036",
    "pctlan_other_and_unspecified <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_and_unspecified) / lan_universe)"
  ),
  longname_old = NA,
  longname = NA
)
formulas_ejscreen_acs_newrows$rname = EJAM:::formula_varname(formulas_ejscreen_acs_newrows$formula)
formulas_ejscreen_acs_newrows$longname <- fixcolnames(formulas_ejscreen_acs_newrows$rname, 'rname', 'long')

# data.frame(need_longname_in_map_headernames = formulas_ejscreen_acs_newrows[formulas_ejscreen_acs_newrows$rname == formulas_ejscreen_acs_newrows$longname,'longname'])
#    need_longname_in_map_headernames
# 1                      lan_other_ie
# 2                       lan_english
# 3                        lan_french
# 4                        lan_german
# 5                     pctlan_german
# 6                  lan_rus_pol_slav
# 7                      lan_other_ie
# 8                        lan_korean
# 9                     pctlan_korean
# 10                      lan_chinese
# 11                   pctlan_chinese
# 12                   lan_vietnamese
# 13                  lan_other_asian
# 14                      lan_tagalog
# 15                   pctlan_tagalog
# 16                       lan_arabic
# 17                        lan_other
### from C16001
info_for_map_headernames <- data.frame(rname  = formulas_ejscreen_acs_newrows[formulas_ejscreen_acs_newrows$rname == formulas_ejscreen_acs_newrows$longname,'longname'],
                                       longname = gsub("lan_", "People speaking ", gsub("pctlan_", "% speaking ", formulas_ejscreen_acs_newrows[formulas_ejscreen_acs_newrows$rname == formulas_ejscreen_acs_newrows$longname,'longname']))
)

c16001_vars <- data.frame(
  varname = c("C16001_001", "C16001_002", "C16001_003",
              "C16001_006", "C16001_009", "C16001_012", "C16001_015", "C16001_018",
              "C16001_021", "C16001_024", "C16001_027", "C16001_030", "C16001_033",
              "C16001_036"),
  label = c("Total", "Speak only English", "Spanish",
            "French, Haitian, or Cajun", "German or other West Germanic languages",
            "Russian, Polish, or other Slavic languages", "Other Indo-European languages",
            "Korean", "Chinese (incl. Mandarin, Cantonese)", "Vietnamese",
            "Tagalog (incl. Filipino)", "Other Asian and Pacific Island languages",
            "Arabic", "Other and unspecified languages")
)

formulas_ejscreen_acs <- rbind(formulas_ejscreen_acs, formulas_ejscreen_acs_newrows)
rm(formulas_ejscreen_acs_newrows)
#################################################################### #################################### #

formulas_ejscreen_acs$varlist <- varinfo(formulas_ejscreen_acs$rname)$varlist


#################################################################### #################################### #

## language vars in EJAM
bg = data.table::copy(EJAM::blockgroupstats); bg= data.table::setDF(bg)
varnames = grep("lan_|_li", names(bg), value = T)
varnames = c("pop", "hhlds",  "bgfips", varnames)

cbind(t(bg[bg$bgfips == "440030205001", varnames]),
      varinfo(  varnames)$varlist)

## compare random blockgroup - data from census vs from EJAM/EJSCREEN dataset
if (FALSE) {
  fips = blockgroupstats$bgfips[sample(1:NROW(blockgroupstats), 1)]
  browseURL(paste0("https://data.census.gov/table?q=B01001&g=1500000US", fips, "&y=2022"))
  browseURL(paste0("https://data.census.gov/table?q=B16004&g=1500000US", fips,"&y=2022")) # browseURL(paste0("https://data.census.gov/table/ACSDT", fiveorone,"Y", 2022, ".", "B16004")
  browseURL(paste0("https://data.census.gov/table?q=c16002&g=1500000US", fips,"&y=2022"))
  browseURL(paste0("https://data.census.gov/table?q=c16001&g=1400000US", substr(fips, 1, 11),"&y=2022")) # TRACT
  cbind(t(bg[bg$bgfips == fips, varnames]), varinfo(varnames)$varlist) # BLOCKGROUP
  cbind(t(bg[substr(bg$bgfips, 1, 11) %in% substr(fips, 1, 11), varnames]), varinfo(varnames)$varlist) # TRACT
}

# english not at all, 1 bg:
# https://data.census.gov/table?q=B16004:+Age+by+Language+Spoken+at+Home+by+Ability+to+Speak+English+for+the+Population+5+Years+and+Over&g=1500000US040131042124&y=2022

# 5555
# pop                 "2239"         "names_d_other_count" # B01001 matches this
# hhlds               "732"          "names_d_other_count" # matches count in C16002 from https://data.census.gov/table?q=C16002:+Household+Language+by+Household+Limited+English+Speaking+Status&g=1500000US040131042124&y=2022&d=ACS+5-Year+Estimates+Detailed+Tables

# bgfips              "040131042124" NA
# lan_universe        "5733"         "names_d_language_count" EJSCREEN dataset had total count in TRACT, for each blockgroup entry in given tract. confirmed matches C16001_001

# lan_nonenglish      "1844"         "names_d_language_count"
# pctlan_nonenglish   "0.3216466"    "names_d_language"

# lan_eng_na          "0"            "names_d_language_count" # matches zero in B16004

# lan_spanish         "1429"         "names_d_language_count"
# pctlan_spanish      "0.2492587"    "names_d_language"

# lan_ie              "8"            "names_d_language_count"
# pctlan_ie           "0.00139543"   "names_d_language"

# lan_api             "369"          "names_d_language_count"
# pctlan_api          "0.06436421"   "names_d_language"

# lan_other           "38"           "names_d_language_count"
# pctlan_other        "0.006628292"  "names_d_language"


# spanish_li          "21"           "names_d_languageli_count" #  matches count in C16002 from https://data.census.gov/table?q=C16002:+Household+Language+by+Household+Limited+English+Speaking+Status&g=1500000US040131042124&y=2022&d=ACS+5-Year+Estimates+Detailed+Tables
# pctspanish_li       "1"            "names_d_languageli"

# ie_li               "0"            "names_d_languageli_count" #  matches 0 count in C16002
# pctie_li            "0"            "names_d_languageli"

# api_li              "0"            "names_d_languageli_count" #  matches 0 count in C16002
# pctapi_li           "0"            "names_d_languageli"

# other_li            "0"            "names_d_languageli_count" #  matches 0 count in C16002
# pctother_li         "0"            "names_d_languageli"

# pctlan_english      "0.68"         "names_d_language"
# pctlan_french       "0"            "names_d_language"
# pctlan_rus_pol_slav "0"            "names_d_language"
# pctlan_other_ie     "0"            "names_d_language"
# pctlan_vietnamese   "0.05"         "names_d_language"
# pctlan_other_asian  "0"            "names_d_language"
# pctlan_arabic       "0"            "names_d_language"

############ #################################### #
x = tidycensus::load_variables(2023, "acs5")
# x = x[x$geography %in% "block group", ] # BUT THAT EXCLUDES C16001, B18101
x = x[x$geography %in% c("tract", "block group"), ] # INCL C16001, B18101
x$geography <- NULL
x$table = gsub("_.*$", "", x$name)
x = x[x$table %in% ejscreen_acs_tables, ]
# x |> print(n=320)
## language variables:
# x[x$table %in% c("C16002","B16004", "C16001"), ] |> print(n=100)
############ #################################### #

# C16001  tract only

x[x$table %in% c( "C16001") & grepl(':$', x$label) & grepl("", x$label), ] |> print(n=100)

# C16001 is at tract resolution only ###########
#   https://data.census.gov/table/ACSDT5Y2023.C16001
# Universe: Population 5 years and over
# name       label                                                         concept                                                     table
# <chr>      <chr>                                                         <chr>                                                       <chr>
# 1 C16001_001 Estimate!!Total:                                              Language Spoken at Home for the Population 5 Years and Over C16001
# 2 C16001_003 Estimate!!Total:!!Spanish:                                    Language Spoken at Home for the Population 5 Years and Over C16001
# 3 C16001_006 Estimate!!Total:!!French, Haitian, or Cajun:                  Language Spoken at Home for the Population 5 Years and Over C16001
# 4 C16001_009 Estimate!!Total:!!German or other West Germanic languages:    Language Spoken at Home for the Population 5 Years and Over C16001
# 5 C16001_012 Estimate!!Total:!!Russian, Polish, or other Slavic languages: Language Spoken at Home for the Population 5 Years and Over C16001
# 6 C16001_015 Estimate!!Total:!!Other Indo-European languages:              Language Spoken at Home for the Population 5 Years and Over C16001
# 7 C16001_018 Estimate!!Total:!!Korean:                                     Language Spoken at Home for the Population 5 Years and Over C16001
# 8 C16001_021 Estimate!!Total:!!Chinese (incl. Mandarin, Cantonese):        Language Spoken at Home for the Population 5 Years and Over C16001
# 9 C16001_024 Estimate!!Total:!!Vietnamese:                                 Language Spoken at Home for the Population 5 Years and Over C16001
#10 C16001_027 Estimate!!Total:!!Tagalog (incl. Filipino):                   Language Spoken at Home for the Population 5 Years and Over C16001
#11 C16001_030 Estimate!!Total:!!Other Asian and Pacific Island languages:   Language Spoken at Home for the Population 5 Years and Over C16001
#12 C16001_033 Estimate!!Total:!!Arabic:                                     Language Spoken at Home for the Population 5 Years and Over C16001
#13 C16001_036 Estimate!!Total:!!Other and unspecified languages:            Language Spoken at Home for the Population 5 Years and Over C16001
############ #################################### #

# C16002

x[x$table %in% "C16002",] |> print(n=40)

# https://data.census.gov/table/ACSDT5Y2023.C16002 # Universe: Households
#https://data.census.gov/table?q=C16002:+Household+Language+by+Household+Limited+English+Speaking+Status&g=1500000US040050003001
# https://data.census.gov/table?q=C16002:+Household+Language+by+Household+Limited+English+Speaking+Status&g=1500000US040131042124

# 1 C16002_001 Estimate!!Total:                                                                                Household Language by Household Limite… block gr…
# 2 C16002_002 Estimate!!Total:!!English only                                                                  Household Language by Household Limite… block gr…

# 3 C16002_003 Estimate!!Total:!!Spanish:                                                                      Household Language by Household Limite… block gr…
# 4 C16002_004 Estimate!!Total:!!Spanish:!!Limited English speaking household                                  Household Language by Household Limite… block gr…

# 6 C16002_006 Estimate!!Total:!!Other Indo-European languages:                                                Household Language by Household Limite… block gr…
# 7 C16002_007 Estimate!!Total:!!Other Indo-European languages:!!Limited English speaking household            Household Language by Household Limite… block gr…

# 9 C16002_009 Estimate!!Total:!!Asian and Pacific Island languages:                                           Household Language by Household Limite… block gr…
#10 C16002_010 Estimate!!Total:!!Asian and Pacific Island languages:!!Limited English speaking household       Household Language by Household Limite… block gr…

#12 C16002_012 Estimate!!Total:!!Other languages:                                                              Household Language by Household Limite… block gr…
#13 C16002_013 Estimate!!Total:!!Other languages:!!Limited English speaking household                          Household Language by Household Limite… block gr…
############ #################################### #

# B16004

# x[grepl("B16004", x$name, ignore.case = T) & grepl("not at all", x$label, ignore.case = T)  & "block group" == x$geography & !is.na(x$geography), ] |> print(n=100 )
# A tibble: 12 × 4
# name       label                                                                                                           concept                 geography
# <chr>      <chr>                                                                                                           <chr>                   <chr>
# 1 B16004_008 "Estimate!!Total:!!5 to 17 years:!!Speak Spanish:!!Speak English \"not at all\""                                Age by Language Spoken… block gr…
# 2 B16004_013 "Estimate!!Total:!!5 to 17 years:!!Speak other Indo-European languages:!!Speak English \"not at all\""          Age by Language Spoken… block gr…
# 3 B16004_018 "Estimate!!Total:!!5 to 17 years:!!Speak Asian and Pacific Island languages:!!Speak English \"not at all\""     Age by Language Spoken… block gr…
# 4 B16004_023 "Estimate!!Total:!!5 to 17 years:!!Speak other languages:!!Speak English \"not at all\""                        Age by Language Spoken… block gr…

# 5 B16004_030 "Estimate!!Total:!!18 to 64 years:!!Speak Spanish:!!Speak English \"not at all\""                               Age by Language Spoken… block gr…
# 6 B16004_035 "Estimate!!Total:!!18 to 64 years:!!Speak other Indo-European languages:!!Speak English \"not at all\""         Age by Language Spoken… block gr…
# 7 B16004_040 "Estimate!!Total:!!18 to 64 years:!!Speak Asian and Pacific Island languages:!!Speak English \"not at all\""    Age by Language Spoken… block gr…
# 8 B16004_045 "Estimate!!Total:!!18 to 64 years:!!Speak other languages:!!Speak English \"not at all\""                       Age by Language Spoken… block gr…

#  9 B16004_052 "Estimate!!Total:!!65 years and over:!!Speak Spanish:!!Speak English \"not at all\""                            Age by Language Spoken… block gr…
# 10 B16004_057 "Estimate!!Total:!!65 years and over:!!Speak other Indo-European languages:!!Speak English \"not at all\""      Age by Language Spoken… block gr…
# 11 B16004_062 "Estimate!!Total:!!65 years and over:!!Speak Asian and Pacific Island languages:!!Speak English \"not at all\"" Age by Language Spoken… block gr…
# 12 B16004_067 "Estimate!!Total:!!65 years and over:!!Speak other languages:!!Speak English \"not at all\""                    Age by Language Spoken… block gr…
# ######################### #
x[!duplicated(x$table), ] # to see list of 1 table per row

# ######################### #
# url_acs_table_info <- function(tables = ejscreen_acs_tables, yr = acsendyear(guess_always = T, guess_census_has_published = T), fiveorone=5) {
#   paste0("https://data.census.gov/table/ACSDT", fiveorone,"Y", yr, ".", tables)
# }
# url_acs_table_info()  # but see ACSdownload::url_acs_table()
# ######################### #
# [1] "https://data.census.gov/table/ACSDT5Y2023.B25034"
# [2] "https://data.census.gov/table/ACSDT5Y2023.B01001"
# [3] "https://data.census.gov/table/ACSDT5Y2023.B03002"
# [4] "https://data.census.gov/table/ACSDT5Y2023.B02001"
# [5] "https://data.census.gov/table/ACSDT5Y2023.B15002"
# [6] "https://data.census.gov/table/ACSDT5Y2023.B23025"
# [7] "https://data.census.gov/table/ACSDT5Y2023.C17002"
# [8] "https://data.census.gov/table/ACSDT5Y2023.B19301"
# [9] "https://data.census.gov/table/ACSDT5Y2023.B25032"
# [10] "https://data.census.gov/table/ACSDT5Y2023.B28003"
# [11] "https://data.census.gov/table/ACSDT5Y2023.B27010"
# [12] "https://data.census.gov/table/ACSDT5Y2023.C16002"
# [13] "https://data.census.gov/table/ACSDT5Y2023.B16004"
# [14] "https://data.census.gov/table/ACSDT5Y2023.C16001" # by tract
# [15] "https://data.census.gov/table/ACSDT5Y2023.B18101" # by tract

}
############################################################## #

message("SAVING FORMULAS, AND CAN USE IN CREATING INITIAL blockgroupstats table from raw acs as with acs_bybg()
        or newer get_acs_new_dat() but  then need final steps for Demog.Index scores and for disability by blockgroup not tract")

### confirmed all of tables are mentioned among formulas created here
# for (i in 1:length(tables)) {cat(tables[i]); print( any(grepl(tables[i], EJAM::formulas_ejscreen_acs$formula))) }
# cbind(tables, concept = v22$concept[match(tables, v22$table)] )


# formulas_ejscreen_acs  saved for use in package

EJAM:::metadata_add_and_use_this("formulas_ejscreen_acs")

EJAM:::dataset_documenter("formulas_ejscreen_acs",
                          description = "Formulas and metadata about Census ACS variables and how to calculate indicators from those raw Census variables, such as creating pctunder5 starting from ACS table B01001 variables.",
                          details = "[Formulas as documented by EPA were archived here](https://web.archive.org/web/20250118134239/https://www.epa.gov/system/files/documents/2024-07/ejscreen-tech-doc-version-2-3.pdf)",
                          seealso = "[acs_bybg()] [tables_ejscreen_acs] [ACSdownload::get_acs_new()]")


############################################################## #

# "lowlifex"  is from CDC so no formula here except possibly
# "lowlifex = 1 - (lifex / maxlifex)"
# but lifex by bg is imported from CDC 1st, not from ACS, and maxlifex is a US constant based on that source.
# % Low Life Expectancy is defined as “1 – (Life Expectancy / Max Life Expectancy)”
# Note: This is derived from the CDC life expectancy at birth data using the formula above.
############################################################## #
