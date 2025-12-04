# see which indicators / variables are in the template file
## collecting the htmltemplate ejscreen variable names
## to be able to provide parameters in those terms from EJAM

## had first manually find/replaced statHash and also other HTML/javascript to
## have all relevant variables show up as {{VARIABLENAME}}
## and manually changed report date and created by and removed logo, etc.

library(EJAM)



## collect the 207 ejscreen variable names that now are in the htmltemplate
fpath = "~/Documents/R PACKAGES/EJAM/inst/report/community_report/ejscreen_soe_template.html"
z = varnames_from_template(fpath)
# x = readLines(fpath)
# y = grep("\\{\\{.*\\}\\}", x, value = T)
# z = gsub("^.*\\{\\{(.*)\\}\\}.*$", "\\1", y)
# z= trimws(z)
# length(z)
# rm(x,y)
# z = unique(z)# 181 unique

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
{
  #
# ## what is not yet renamed by just using the map_headernames$api column of variable names?
# csvname_missing_in_map_headernames <- z[z == fixcolnames(z, "api", "r")]
# ## These are not renamed by "api" column of metadata:
# # csvname_missing_in_map_headernames <- ("headContent()", "TOTALPOP", "inputAreaMiles", "P_GERMAN",
# # "P_KOREAN", "P_CHINESE", "P_TAGALOG", "P_LOWINC", "PCT_MINORITY",
# # "P_EDU_LTHS", "P_LIMITED_ENG_HH", "P_EMP_STAT_UNEMPLOYED", "P_DISABILITY",
# # "P_AGE_LT5", "P_AGE_GT64", "RAW_D_DISABLED", "S_D_DISABLED",
# # "S_D_DISABLED_PER", "N_D_DISABLED", "N_D_DISABLED_PER")
#
# ## of the not easily renamed ones, which are still possibly fixable via mapping info in map_headernames from other columns?
#  fixable = varin_map_headernames(csvname_missing_in_map_headernames )
#  cbind(rowSums(fixable))
# # [,1]   this shows which columns of map_headernames have how many of the not-yet-renamed variables:
# # oldname           15
# # apiname           28
# # api_synonym       17
# # acsname            4
# # csvname            6
# # ejscreen_csv       6
# # rname              1
# # topic_root_term    2
# # basevarname        1
#
#  # no additional ones we can rename using "apiname"
#  dput(csvname_missing_in_map_headernames[csvname_missing_in_map_headernames
#                                          != fixcolnames(csvname_missing_in_map_headernames,
#                                                         "apiname", "r")])
# # extrafixed =  c("P_HLI_SPANISH_LI", "P_HLI_IE_LI", "P_HLI_API_LI", "P_HLI_OTHER_LI",
# #            "P_MALES", "P_FEMALES", "P_OWN_OCCUPIED", "P_NHWHITE", "P_NHBLACK",
# #            "P_NHAMERIND", "P_NHASIAN", "P_NHHAWPAC", "P_NHOTHER_RACE", "P_NHTWOMORE",
# #            "P_HISP", "P_AGE_LT18", "P_AGE_GT17")
# # cbind(extrafixed,
# #       fixcolnames(extrafixed,
# #                   "api", "r"))
# # extrafixed
# # [1,] "P_HLI_SPANISH_LI" "pctspanish_li"
# # [2,] "P_HLI_IE_LI"      "pctie_li"
# # [3,] "P_HLI_API_LI"     "pctapi_li"
# # [4,] "P_HLI_OTHER_LI"   "pctother_li"
# # [5,] "P_MALES"          "pctmale"
# # [6,] "P_FEMALES"        "pctfemale"
# # [7,] "P_OWN_OCCUPIED"   "pctownedunits"
# # [8,] "P_NHWHITE"        "pctnhwa"
# # [9,] "P_NHBLACK"        "pctnhba"
# # [10,] "P_NHAMERIND"      "pctnhaiana"
# # [11,] "P_NHASIAN"        "pctnhaa"
# # [12,] "P_NHHAWPAC"       "pctnhnhpia"
# # [13,] "P_NHOTHER_RACE"   "pctnhotheralone"
# # [14,] "P_NHTWOMORE"      "pctnhmulti"
# # [15,] "P_HISP"           "pcthisp"
# # [16,] "P_AGE_LT18"       "pctunder18"
# # [17,] "P_AGE_GT17"       "pctover17"
}

# check how many are left unfixed after applying all the possible sources of info on synonyms:
still_not_fixed = z
length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "api",         "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "apiname",     "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "api_synonym", "r")] ; length(still_not_fixed)
still_not_fixed = still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "oldname",     "r")] ; length(still_not_fixed) # just 10
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "ejscreen_csv", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csvname", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csv", "r")] ; length(still_not_fixed)
# still_not_fixed= still_not_fixed[still_not_fixed == fixcolnames(still_not_fixed, "csvname2.2", "r")] ; length(still_not_fixed)

still_not_fixed
# [1] " headContent() "  "inputAreaMiles"
# "P_GERMAN" "P_TAGALOG"   # but not  "P_KOREAN" "P_CHINESE"
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
# none




# additional ones fixed via only
fixcolnames(csvname_missing_in_map_headernames, "api", "r")


############################################### # ############################################### #
############################################### # ############################################### #

x = readLines("~/Documents/R PACKAGES/EJAM/inst/report/community_report/ejscreen_soe_template.html")
x = x[grepl("\\{\\{", x)]
y = trimws(gsub("^.*\\{\\{(.*)\\}\\}.*$", "\\1", x))
left = y
  cat(length(left), "left unrenamed incl dupes \n")
# 207 incl dupes
  which(duplicated(left)) # 46  47  48  49 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207
y = unique(y)
  left = unique(left)
# length(left) # 181 unique

renamed = fixcolnames(left, "api", "r")          ; left = left[left == renamed ]; cat(length(left), "left unrenamed \n") # 20 left unrenamed
renamed = fixcolnames(left, "api_synonym", 'r')  ; left = left[left == renamed ]; cat(length(left), "left unrenamed \n") # 12 left unrenamed
# renamed = fixcolnames(left, "csvname", 'r')      ; left = left[left == renamed ]; cat(length(left), "left unrenamed \n") # 12 left unrenamed
renamed = fixcolnames(left, "ejscreen_csv", 'r') ; left = left[left == renamed ]; cat(length(left), "left unrenamed \n") # 10 left unrenamed

left
# [1] "headContent()"    "inputAreaMiles"
# "P_GERMAN"     "P_TAGALOG"   #   probably also chinese and korean and others but not in this particular example of template??
# "P_DISABILITY" "RAW_D_DISABLED"
# "S_D_DISABLED" "S_D_DISABLED_PER"
# "N_D_DISABLED" "N_D_DISABLED_PER"

y
ynew =  fixcolnames( fixcolnames( fixcolnames(y, "api", "r"), "api_synonym", "r"), "ejscreen_csv", "r")
cbind(y,ynew)

#       y                       ynew
# [1,] "headContent()"         "headContent()"       ##
# [2,] "P_HLI_SPANISH_LI"      "pctspanish_li"
# [3,] "P_HLI_IE_LI"           "pctie_li"
# [4,] "P_HLI_API_LI"          "pctapi_li"
# [5,] "P_HLI_OTHER_LI"        "pctother_li"
# [6,] "TOTALPOP"              "pop"
# [7,] "inputAreaMiles"        "inputAreaMiles"       ###
# [8,] "P_ENGLISH"             "pctlan_english"
# [9,] "P_SPANISH"             "pctlan_spanish"
# [10,] "P_FRENCH"              "pctlan_french"
# [11,] "P_GERMAN"              "P_GERMAN"               ##
# [12,] "P_RUS_POL_SLAV"        "pctlan_rus_pol_slav"
# [13,] "P_OTHER_IE"            "pctlan_ie"
# [14,] "P_KOREAN"              "pct_korean"
# [15,] "P_CHINESE"             "pct_chinese"
# [16,] "P_VIETNAMESE"          "pctlan_vietnamese"
# [17,] "P_TAGALOG"             "P_TAGALOG"               ##
# [18,] "P_OTHER_ASIAN"         "pctlan_api"
# [19,] "P_ARABIC"              "pctlan_arabic"
# [20,] "P_OTHER"               "pctlan_other"
# [21,] "P_NON_ENGLISH"         "pctlan_nonenglish"
# [22,] "P_LOWINC"              "pctlowinc"
# [23,] "PCT_MINORITY"          "pctmin"
# [24,] "P_EDU_LTHS"            "pctlths"
# [25,] "P_LIMITED_ENG_HH"      "pctlingiso"
# [26,] "P_EMP_STAT_UNEMPLOYED" "pctunemployed"
# [27,] "P_DISABILITY"          "P_DISABILITY"           ###
# [28,] "P_MALES"               "pctmale"
# [29,] "P_FEMALES"             "pctfemale"
# [30,] "LIFEEXP"               "lifexyears"
# [31,] "PER_CAP_INC"           "percapincome"
# [32,] "HSHOLDS"               "hhlds"
# [33,] "P_OWN_OCCUPIED"        "pctownedunits"
# [34,] "P_NHWHITE"             "pctnhwa"
# [35,] "P_NHBLACK"             "pctnhba"
# [36,] "P_NHAMERIND"           "pctnhaiana"
# [37,] "P_NHASIAN"             "pctnhaa"
# [38,] "P_NHHAWPAC"            "pctnhnhpia"
# [39,] "P_NHOTHER_RACE"        "pctnhotheralone"
# [40,] "P_NHTWOMORE"           "pctnhmulti"
# [41,] "P_HISP"                "pcthisp"
# [42,] "P_AGE_LT5"             "pctunder5"
# [43,] "P_AGE_LT18"            "pctunder18"
# [44,] "P_AGE_GT17"            "pctover17"
# [45,] "P_AGE_GT64"            "pctover64"
# [46,] "RAW_E_PM25"            "pm"
# [47,] "S_E_PM25"              "state.avg.pm"
# [48,] "S_E_PM25_PER"          "state.pctile.pm"
# [49,] "N_E_PM25"              "avg.pm"
# [50,] "N_E_PM25_PER"          "pctile.pm"
# [51,] "RAW_E_O3"              "o3"
# [52,] "S_E_O3"                "state.avg.o3"
# [53,] "S_E_O3_PER"            "state.pctile.o3"
# [54,] "N_E_O3"                "avg.o3"
# [55,] "N_E_O3_PER"            "pctile.o3"
# [56,] "RAW_E_NO2"             "no2"
# [57,] "S_E_NO2"               "state.avg.no2"
# [58,] "S_E_NO2_PER"           "state.pctile.no2"
# [59,] "N_E_NO2"               "avg.no2"
# [60,] "N_E_NO2_PER"           "pctile.no2"
# [61,] "RAW_E_DIESEL"          "dpm"
# [62,] "S_E_DIESEL"            "state.avg.dpm"
# [63,] "S_E_DIESEL_PER"        "state.pctile.dpm"
# [64,] "N_E_DIESEL"            "avg.dpm"
# [65,] "N_E_DIESEL_PER"        "pctile.dpm"
# [66,] "RAW_E_RSEI_AIR"        "rsei"
# [67,] "S_E_RSEI_AIR"          "state.avg.rsei"
# [68,] "S_E_RSEI_AIR_PER"      "state.pctile.rsei"
# [69,] "N_E_RSEI_AIR"          "avg.rsei"
# [70,] "N_E_RSEI_AIR_PER"      "pctile.rsei"
# [71,] "RAW_E_TRAFFIC"         "traffic.score"
# [72,] "S_E_TRAFFIC"           "state.avg.traffic.score"
# [73,] "S_E_TRAFFIC_PER"       "state.pctile.traffic.score"
# [74,] "N_E_TRAFFIC"           "avg.traffic.score"
# [75,] "N_E_TRAFFIC_PER"       "pctile.traffic.score"
# [76,] "RAW_E_LEAD"            "pctpre1960"
# [77,] "S_E_LEAD"              "state.avg.pctpre1960"
# [78,] "S_E_LEAD_PER"          "state.pctile.pctpre1960"
# [79,] "N_E_LEAD"              "avg.pctpre1960"
# [80,] "N_E_LEAD_PER"          "pctile.pctpre1960"
# [81,] "RAW_E_NPL"             "proximity.npl"
# [82,] "S_E_NPL"               "state.avg.proximity.npl"
# [83,] "S_E_NPL_PER"           "state.pctile.proximity.npl"
# [84,] "N_E_NPL"               "avg.proximity.npl"
# [85,] "N_E_NPL_PER"           "pctile.proximity.npl"
# [86,] "RAW_E_RMP"             "proximity.rmp"
# [87,] "S_E_RMP"               "state.avg.proximity.rmp"
# [88,] "S_E_RMP_PER"           "state.pctile.proximity.rmp"
# [89,] "N_E_RMP"               "avg.proximity.rmp"
# [90,] "N_E_RMP_PER"           "pctile.proximity.rmp"
# [91,] "RAW_E_TSDF"            "proximity.tsdf"
# [92,] "S_E_TSDF"              "state.avg.proximity.tsdf"
# [93,] "S_E_TSDF_PER"          "state.pctile.proximity.tsdf"
# [94,] "N_E_TSDF"              "avg.proximity.tsdf"
# [95,] "N_E_TSDF_PER"          "pctile.proximity.tsdf"
# [96,] "RAW_E_UST"             "ust"
# [97,] "S_E_UST"               "state.avg.ust"
# [98,] "S_E_UST_PER"           "state.pctile.ust"
# [99,] "N_E_UST"               "avg.ust"
# [100,] "N_E_UST_PER"           "pctile.ust"
# [101,] "RAW_E_NPDES"           "proximity.npdes"
# [102,] "S_E_NPDES"             "state.avg.proximity.npdes"
# [103,] "S_E_NPDES_PER"         "state.pctile.proximity.npdes"
# [104,] "N_E_NPDES"             "avg.proximity.npdes"
# [105,] "N_E_NPDES_PER"         "pctile.proximity.npdes"
# [106,] "RAW_E_DWATER"          "drinking"
# [107,] "S_E_DWATER"            "state.avg.drinking"
# [108,] "S_E_DWATER_PER"        "state.pctile.drinking"
# [109,] "N_E_DWATER"            "avg.drinking"
# [110,] "N_E_DWATER_PER"        "pctile.drinking"
# [111,] "RAW_D_DEMOGIDX2"       "Demog.Index"
# [112,] "N_D_DEMOGIDX2"         "avg.Demog.Index"
# [113,] "N_D_DEMOGIDX2_PER"     "pctile.Demog.Index"
# [114,] "RAW_D_DEMOGIDX5"       "Demog.Index.Supp"
# [115,] "N_D_DEMOGIDX5"         "avg.Demog.Index.Supp"
# [116,] "N_D_DEMOGIDX5_PER"     "pctile.Demog.Index.Supp"
# [117,] "RAW_D_DEMOGIDX2ST"     "Demog.Index.State"
# [118,] "S_D_DEMOGIDX2ST"       "state.avg.Demog.Index"
# [119,] "S_D_DEMOGIDX2ST_PER"   "state.pctile.Demog.Index"
# [120,] "RAW_D_DEMOGIDX5ST"     "Demog.Index.Supp.State"
# [121,] "S_D_DEMOGIDX5ST"       "state.avg.Demog.Index.Supp"
# [122,] "S_D_DEMOGIDX5ST_PER"   "state.pctile.Demog.Index.Supp"
# [123,] "RAW_D_PEOPCOLOR"       "pctmin"
# [124,] "S_D_PEOPCOLOR"         "state.avg.pctmin"
# [125,] "S_D_PEOPCOLOR_PER"     "state.pctile.pctmin"
# [126,] "N_D_PEOPCOLOR"         "avg.pctmin"
# [127,] "N_D_PEOPCOLOR_PER"     "pctile.pctmin"
# [128,] "RAW_D_INCOME"          "pctlowinc"
# [129,] "S_D_INCOME"            "state.avg.pctlowinc"
# [130,] "S_D_INCOME_PER"        "state.pctile.pctlowinc"
# [131,] "N_D_INCOME"            "avg.pctlowinc"
# [132,] "N_D_INCOME_PER"        "pctile.pctlowinc"
# [133,] "RAW_D_DISABLED"        "RAW_D_DISABLED"               ##
# [134,] "S_D_DISABLED"          "S_D_DISABLED"                 ##
# [135,] "S_D_DISABLED_PER"      "S_D_DISABLED_PER"             ##
# [136,] "N_D_DISABLED"          "N_D_DISABLED"                 ##
# [137,] "N_D_DISABLED_PER"      "N_D_DISABLED_PER"             ##
# [138,] "RAW_D_UNEMPLOYED"      "pctunemployed"
# [139,] "S_D_UNEMPLOYED"        "state.avg.pctunemployed"
# [140,] "S_D_UNEMPLOYED_PER"    "state.pctile.pctunemployed"
# [141,] "N_D_UNEMPLOYED"        "avg.pctunemployed"
# [142,] "N_D_UNEMPLOYED_PER"    "pctile.pctunemployed"
# [143,] "RAW_D_LING"            "pctlingiso"
# [144,] "S_D_LING"              "state.avg.pctlingiso"
# [145,] "S_D_LING_PER"          "state.pctile.pctlingiso"
# [146,] "N_D_LING"              "avg.pctlingiso"
# [147,] "N_D_LING_PER"          "pctile.pctlingiso"
# [148,] "RAW_D_LESSHS"          "pctlths"
# [149,] "S_D_LESSHS"            "state.avg.pctlths"
# [150,] "S_D_LESSHS_PER"        "state.pctile.pctlths"
# [151,] "N_D_LESSHS"            "avg.pctlths"
# [152,] "N_D_LESSHS_PER"        "pctile.pctlths"
# [153,] "RAW_D_UNDER5"          "pctunder5"
# [154,] "S_D_UNDER5"            "state.avg.pctunder5"
# [155,] "S_D_UNDER5_PER"        "state.pctile.pctunder5"
# [156,] "N_D_UNDER5"            "avg.pctunder5"
# [157,] "N_D_UNDER5_PER"        "pctile.pctunder5"
# [158,] "RAW_D_OVER64"          "pctover64"
# [159,] "S_D_OVER64"            "state.avg.pctover64"
# [160,] "S_D_OVER64_PER"        "state.pctile.pctover64"
# [161,] "N_D_OVER64"            "avg.pctover64"
# [162,] "N_D_OVER64_PER"        "pctile.pctover64"
# [163,] "RAW_D_LIFEEXP"         "lowlifex"
# [164,] "S_D_LIFEEXP"           "state.avg.lowlifex"
# [165,] "S_D_LIFEEXP_PER"       "state.pctile.lowlifex"
# [166,] "N_D_LIFEEXP"           "avg.lowlifex"
# [167,] "N_D_LIFEEXP_PER"       "pctile.lowlifex"
# [168,] "NUM_NPL"               "count.NPL"
# [169,] "NUM_TSDF"              "count.TSDF"
# [170,] "NUM_WATERDIS"          "num_waterdis"
# [171,] "NUM_AIRPOLL"           "num_airpoll"
# [172,] "NUM_BROWNFIELD"        "num_brownfield"
# [173,] "NUM_TRI"               "num_tri"
# [174,] "NUM_SCHOOL"            "num_school"
# [175,] "NUM_HOSPITAL"          "num_hospital"
# [176,] "NUM_CHURCH"            "num_church"
# [177,] "YESNO_AIRNONATT"       "yesno_airnonatt"
# [178,] "YESNO_IMPWATERS"       "yesno_impwaters"
# [179,] "YESNO_TRIBAL"          "yesno_tribal"
# [180,] "YESNO_CEJSTDIS"        "yesno_cejstdis"
# [181,] "YESNO_IRADIS"          "yesno_iradis"
