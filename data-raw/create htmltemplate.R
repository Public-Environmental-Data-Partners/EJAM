## collecting the htmltemplate ejscreen variable names
## to be able to provide parameters in those terms from EJAM

## had first manually find/replaced statHash and also other HTML/javascript to
## have all relevant variables show up as {{VARIABLENAME}}
## and manually changed report date and created by and removed logo, etc.

library(EJAM)

## collect the 207 ejscreen variable names that now are in the htmltemplate
x = readLines("~/Documents/R PACKAGES/EJAM/inst/report/community_report/ejscreen_soe_template.html")
y = grep("\\{\\{.*\\}\\}", x, value = T)
z = gsub("^.*\\{\\{(.*)\\}\\}.*$", "\\1", y)
length(z)
rm(x,y)

## map_headernames$apiname has most of what is in htmltemplate based on EJSCREEN aspx

zz=fixcolnames(z, "api", "r"); sum(zz != z)      # fixes 161/207
zz=fixcolnames(z, "apiname", "r"); sum(zz != z)  # fixes 161/207
zz=fixcolnames(z, "oldname", "r"); sum(zz != z)  # fixes 150
zz=fixcolnames(z, "api_synonym", "r"); sum(zz != z) # fixes 9
zz=fixcolnames(z, "acsname", "r"); sum(zz != z)     # fixes 6
zz=fixcolnames(z, "csv", "r"); sum(zz != z)          # fixes 2
zz=fixcolnames(z, "csvname", "r"); sum(zz != z)      # fixes 2
zz=fixcolnames(z, "csvname2.2", "r"); sum(zz != z)   # fixes 2
zz=fixcolnames(z, "ejscreen_csv", "r"); sum(zz != z) # fixes 2
zz=fixcolnames(z, "csv_descriptions_name", "r"); sum(zz != z)  # fixes  none

## what is not yet renamed by just using the map_headernames$api column of variable names?
csvname_missing_in_map_headernames <- z[z == fixcolnames(z, "api", "r")]
## These are not renamed by "api" column of metadata:
# csvname_missing_in_map_headernames <- c(" headContent() ", "TOTALPOP", "inputAreaMiles", "P_GERMAN",
#                                         "P_KOREAN", "P_CHINESE", "P_TAGALOG", "P_LOWINC", "PCT_MINORITY",
#                                         "P_EDU_LTHS", "P_LIMITED_ENG_HH", "P_EMP_STAT_UNEMPLOYED", "P_DISABILITY",
#                                         "P_AGE_LT5", "P_AGE_GT64", "P_HLI_SPANISH_LI", "P_HLI_IE_LI",
#                                         "P_HLI_API_LI", "P_HLI_OTHER_LI", "RAW_D_DISABLED", "S_D_DISABLED",
#                                         "S_D_DISABLED_PER", "N_D_DISABLED", "N_D_DISABLED_PER", "P_LOWINC",
#                                         "PCT_MINORITY", "P_EDU_LTHS", "P_LIMITED_ENG_HH", "P_EMP_STAT_UNEMPLOYED",
#                                         "P_DISABILITY", "P_MALES", "P_FEMALES", "P_OWN_OCCUPIED", "P_NHWHITE",
#                                         "P_NHBLACK", "P_NHAMERIND", "P_NHASIAN", "P_NHHAWPAC", "P_NHOTHER_RACE",
#                                         "P_NHTWOMORE", "P_HISP", "P_AGE_LT5", "P_AGE_LT18", "P_AGE_GT17",
#                                         "P_AGE_GT64", "P_AGE_GT64")

## of the not easily renamed ones, which are still possibly fixable via mapping info in map_headernames from other columns?
 fixable = varin_map_headernames(csvname_missing_in_map_headernames )
 cbind(rowSums(fixable))
# [,1]   this shows which columns of map_headernames have how many of the not-yet-renamed variables:
# oldname           15
# apiname           28
# api_synonym       17
# acsname            4
# csvname            6
# ejscreen_csv       6
# rname              1
# topic_root_term    2
# basevarname        1

 # additional ones we can rename using "apiname"
 dput(csvname_missing_in_map_headernames[csvname_missing_in_map_headernames
                                         != fixcolnames(csvname_missing_in_map_headernames,
                                                        "apiname", "r")])
extrafixed =  c("P_HLI_SPANISH_LI", "P_HLI_IE_LI", "P_HLI_API_LI", "P_HLI_OTHER_LI",
           "P_MALES", "P_FEMALES", "P_OWN_OCCUPIED", "P_NHWHITE", "P_NHBLACK",
           "P_NHAMERIND", "P_NHASIAN", "P_NHHAWPAC", "P_NHOTHER_RACE", "P_NHTWOMORE",
           "P_HISP", "P_AGE_LT18", "P_AGE_GT17")
cbind(extrafixed,
      fixcolnames(extrafixed,
                  "api", "r"))
# extrafixed
# [1,] "P_HLI_SPANISH_LI" "pctspanish_li"
# [2,] "P_HLI_IE_LI"      "pctie_li"
# [3,] "P_HLI_API_LI"     "pctapi_li"
# [4,] "P_HLI_OTHER_LI"   "pctother_li"
# [5,] "P_MALES"          "pctmale"
# [6,] "P_FEMALES"        "pctfemale"
# [7,] "P_OWN_OCCUPIED"   "pctownedunits"
# [8,] "P_NHWHITE"        "pctnhwa"
# [9,] "P_NHBLACK"        "pctnhba"
# [10,] "P_NHAMERIND"      "pctnhaiana"
# [11,] "P_NHASIAN"        "pctnhaa"
# [12,] "P_NHHAWPAC"       "pctnhnhpia"
# [13,] "P_NHOTHER_RACE"   "pctnhotheralone"
# [14,] "P_NHTWOMORE"      "pctnhmulti"
# [15,] "P_HISP"           "pcthisp"
# [16,] "P_AGE_LT18"       "pctunder18"
# [17,] "P_AGE_GT17"       "pctover17"

# check how many are left unfixed after applying all the possible sources of info on synonyms:
still_not_fixed = z ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "api",         "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "apiname",     "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "api_synonym", "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "oldname",     "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "ejscreen_csv", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csvname", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csv", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csvname2.2", "r")] ; length(still_not_fixed)

still_not_fixed
# [1] " headContent() "  "inputAreaMiles"
# "P_GERMAN" "P_KOREAN" "P_CHINESE" "P_TAGALOG"
# "P_DISABILITY" "RAW_D_DISABLED" "S_D_DISABLED" "S_D_DISABLED_PER"  "N_D_DISABLED" "N_D_DISABLED_PER" "P_DISABILITY"


# rename using "ejscreen_csv"
dput(csvname_missing_in_map_headernames[csvname_missing_in_map_headernames
                                        != fixcolnames(csvname_missing_in_map_headernames,
                                                       "ejscreen_csv", "r")])
c("P_KOREAN", "P_CHINESE")
# and "P_KOREAN", "P_CHINESE" are in only map_headernames$ejscreen_csv


# rename using "api"
dput(csvname_missing_in_map_headernames[csvname_missing_in_map_headernames
                                        != fixcolnames(csvname_missing_in_map_headernames,
                                                       "api", "r")])

c("P_HLI_SPANISH_LI", "P_HLI_IE_LI", "P_HLI_API_LI", "P_HLI_OTHER_LI",
  "P_MALES", "P_FEMALES", "P_OWN_OCCUPIED", "P_NHWHITE", "P_NHBLACK",
  "P_NHAMERIND", "P_NHASIAN", "P_NHHAWPAC", "P_NHOTHER_RACE", "P_NHTWOMORE",
  "P_HISP", "P_AGE_LT18", "P_AGE_GT17")

# additional ones fixed via only
fixcolnames(csvname_missing_in_map_headernames, "api", "r")
c("P_HLI_SPANISH_LI", "P_HLI_IE_LI", "P_HLI_API_LI", "P_HLI_OTHER_LI",
  "P_MALES", "P_FEMALES", "P_OWN_OCCUPIED", "P_NHWHITE", "P_NHBLACK",
  "P_NHAMERIND", "P_NHASIAN", "P_NHHAWPAC", "P_NHOTHER_RACE", "P_NHTWOMORE",
  "P_HISP", "P_AGE_LT18", "P_AGE_GT17")



csv_descriptions_name

csvname2.2
