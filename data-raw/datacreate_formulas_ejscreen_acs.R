
# script to make a set of formulas that can convert raw ACS5 data into ejscreen indicators

# this script was used once 11/2025 to update and save the formulas, but would not be used again in this form for annual updates of formulas
# which would be done manually if necessary at all - sometimes table numbering changes in the ACS vs prior years



############################################################## #


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

  # Formulas etc. are documented at pages/docs linked here:  and  EJAM::url_ejscreentechdoc()

  ########################################################################################## #

  formulas_ejscreen_acs <- structure(list(

    rname = c("pop",
              "ageunder5m", "age5to9m", "age10to14m",
              "age15to17m", "age65to66m", "age6769m", "age7074m", "age7579m",
              "age8084m", "age85upm", "ageunder5f", "age5to9f", "age10to14f",
              "age15to17f", "age65to66f", "age6769f", "age7074f", "age7579f",
              "age8084f", "age85upf",

              "hisp", "pop3002", "nonhisp", "nhwa", "nhba", "nhaiana", "nhaa", "nhnhpia", "nhotheralone", "nhmulti",
              "povknownratio", "pov50", "pov99", "pov124", "pov149", "pov184", "pov199", "pov2plus",
              "age25up",
              "m0", "m4", "m6", "m8", "m9", "m10", "m11", "m12",
              "f0", "f4", "f6", "f8", "f9", "f10", "f11", "f12",

              "lingisospanish", "lingisoeuro", "lingisoasian", "lingisoother",

              "hhlds", "builtunits", "built1950to1959", "built1940to1949", "builtpre1940",
              "unemployedbase", "unemployed",
              "under5", "pctunder5",
              "over64", "pctover64",

              "nonmins", "pcthisp", "pctnhwa", "pctnhba", "pctnhaiana", "pctnhaa", "pctnhnhpia", "pctnhotheralone", "pctnhmulti", "mins", "pctmin",

              "num1pov", "num15pov", "num2pov", "num2pov.alt",
              "pct1pov", "pct15pov", "pct2pov", "pct2pov.alt", "lowinc", "pctlowinc",

              "lths", "pctlths",
              "lingiso", "pctlingiso",
              "pre1960", "pctpre1960",
              "pctunemployed", "pctover17", "pctunder18",
              "pctfire", "pctfire30", "pctflood", "pctflood30",
              "pctfemale", "pctmale",
              "pctownedunits", "pctnobroadband", "pctnohealthinsurance",
              "pctpoor",
              #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #

              "pctlan_api", "pctlan_arabic", "pctlan_english", "pctlan_french", "pctlan_ie",
              "pctlan_nonenglish", "pctlan_other", "pctlan_other_asian", "pctlan_other_ie",
              "pctlan_rus_pol_slav", "pctlan_spanish", "pctlan_vietnamese",

              "pctapi_li", "pctie_li", "pctother_li", "pctspanish_li",

              #### ##### ##### ##### ##### ##### ##### ##### ##### #
              "pctaa", "pctaiana", "pctba", "pctmulti", "pctnhpia", "pctotheralone", "pctwa",

              "EJ.DISPARITY.pctpre1960.eo", "state.EJ.DISPARITY.pctpre1960.eo", "EJ.DISPARITY.pctpre1960.supp", "state.EJ.DISPARITY.pctpre1960.supp",

              "pctdisability", "bgid", "countyname", "statename", "ST", "REGION",
              "under18", "over17", "female", "male", "ownedhhlds", "occupiedhhlds",
              "pctownedhhlds", "ownedunits", "occupiedunits", "nobroadband",
              "nohealthinsurance", "poor", "wa", "ba", "aa", "aiana", "nhpia",
              "otheralone", "multi", "percapincome",
              #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #

              "lan_eng_na", "lan_spanish", "lan_api", "lan_other", "lan_other_ie", "lan_universe",

              "lan_english",  "pctlan_english",
              "lan_french", "pctlan_french",
              "lan_german", "pctlan_german",
              "lan_rus_pol_slav", "pctlan_rus_pol_slav",
              "lan_other_ie", "pctlan_other_ie",
              "lan_korean", "pctlan_korean",
              "lan_chinese", "pctlan_chinese",
              "lan_vietnamese", "pctlan_vietnamese",
              "lan_other_asian", "pctlan_other_asian",
              "lan_tagalog", "pctlan_tagalog",
              "lan_arabic", "pctlan_arabic",
              "lan_other_and_unspecified", "pctlan_other_and_unspecified"

              #### ##### ##### ##### ##### ##### ##### ##### ##### #
    ),
    formula = c("pop = B01001_001",
                "ageunder5m = B01001_003", "age5to9m = B01001_004", "age10to14m = B01001_005", "age15to17m = B01001_006", "age65to66m = B01001_020", "age6769m = B01001_021", "age7074m = B01001_022", "age7579m = B01001_023", "age8084m = B01001_024", "age85upm = B01001_025",
                "ageunder5f = B01001_027", "age5to9f = B01001_028", "age10to14f = B01001_029", "age15to17f = B01001_030", "age65to66f = B01001_044", "age6769f = B01001_045", "age7074f = B01001_046", "age7579f = B01001_047", "age8084f = B01001_048", "age85upf = B01001_049",

                "hisp = B03002_012", "pop3002 = B03002_001", "nonhisp = B03002_002", "nhwa = B03002_003", "nhba = B03002_004", "nhaiana = B03002_005", "nhaa = B03002_006", "nhnhpia = B03002_007", "nhotheralone = B03002_008", "nhmulti = B03002_009",
                "povknownratio = C17002_001", "pov50 = C17002_002", "pov99 = C17002_003", "pov124 = C17002_004", "pov149 = C17002_005", "pov184 = C17002_006", "pov199 = C17002_007", "pov2plus = C17002_008",
                "age25up = B15002_001",
                "m0 = B15002_003", "m4 = B15002_004", "m6 = B15002_005", "m8 = B15002_006", "m9 = B15002_007", "m10 = B15002_008", "m11 = B15002_009", "m12 = B15002_010",
                "f0 = B15002_020", "f4 = B15002_021", "f6 = B15002_022", "f8 = B15002_023", "f9 = B15002_024", "f10 = B15002_025", "f11 = B15002_026", "f12 = B15002_027",

                "lingisospanish = C16002_004", "lingisoeuro = C16002_007", "lingisoasian = C16002_010", "lingisoother = C16002_013",

                "hhlds = B16002_001", "builtunits = B25034_001", "built1950to1959 = B25034_008", "built1940to1949 = B25034_009", "builtpre1940 = B25034_010",
                "unemployedbase = B23025_003", "unemployed = B23025_005",
                "under5 <- ageunder5m + ageunder5f", "pctunder5 <- ifelse( pop==0, 0, under5 / pop)",
                "over64 <- age65to66m + age6769m + age7074m + age7579m + age8084m + age85upm +   age65to66f + age6769f + age7074f + age7579f + age8084f + age85upf", "pctover64 <- ifelse( pop==0, 0, over64 / pop)",

                "nonmins <- nhwa",
                "pcthisp <- ifelse(pop==0, 0, as.numeric(hisp ) / pop)", "pctnhwa <- ifelse(pop==0, 0, as.numeric(nhwa ) / pop)",
                "pctnhba <- ifelse(pop==0, 0, as.numeric(nhba ) / pop)", "pctnhaiana <- ifelse(pop==0, 0, as.numeric(nhaiana ) / pop)",
                "pctnhaa <- ifelse(pop==0, 0, as.numeric(nhaa ) / pop)", "pctnhnhpia <- ifelse(pop==0, 0, as.numeric(nhnhpia ) / pop)",
                "pctnhotheralone <- ifelse(pop==0, 0, as.numeric(nhotheralone ) / pop)",
                "pctnhmulti <- ifelse(pop==0, 0, as.numeric(nhmulti ) / pop)",
                "mins <- pop - nhwa", "pctmin <- ifelse(pop==0, 0, as.numeric(mins ) / pop)",

                "num1pov <- pov50 + pov99",
                "num15pov <- num1pov + pov124 + pov149",
                "num2pov <- num1pov + pov124 + pov149 + pov184 + pov199",
                "num2pov.alt <- povknownratio - pov2plus",
                "pct1pov <- ifelse( povknownratio==0, 0, num1pov / povknownratio)",
                "pct15pov <- ifelse( povknownratio==0, 0, num15pov / povknownratio)",
                "pct2pov <- ifelse( povknownratio==0, 0, num2pov / povknownratio)",
                "pct2pov.alt <- ifelse( povknownratio==0, 0, num2pov.alt / povknownratio)",
                "lowinc = povknownratio - pov2plus",
                "pctlowinc = ifelse( povknownratio==0, 0, lowinc / povknownratio)",

                "lths <- m0 + m4 + m6 + m8 + m9 + m10 + m11 + m12 +   f0 + f4 + f6 + f8 + f9 + f10 + f11 + f12",
                "pctlths <- ifelse(age25up==0, 0, as.numeric(lths ) / age25up)",
                "lingiso <- lingisospanish + lingisoeuro + lingisoasian + lingisoother",
                "pctlingiso <- ifelse( hhlds==0, 0, lingiso / hhlds)",
                "pre1960 <- builtpre1940 + built1940to1949 + built1950to1959",
                "pctpre1960 <- ifelse( builtunits==0, 0, pre1960 / builtunits)",
                "pctunemployed <- ifelse(unemployedbase==0, 0, as.numeric(unemployed) / unemployedbase)",
                "pctover17      <- ifelse(pop == 0, 0, as.numeric(over17) / pop)",
                "pctunder18      <- ifelse(pop == 0, 0, as.numeric(under18) / pop)",
                "pctfire      <- ifelse(pop == 0, 0, as.numeric(fire) / pop)",
                "pctfire30      <- ifelse(pop == 0, 0, as.numeric(fire30) / pop)",
                "pctflood      <- ifelse(pop == 0, 0, as.numeric(flood) / pop)",
                "pctflood30      <- ifelse(pop == 0, 0, as.numeric(flood30) / pop)",
                "pctfemale      <- ifelse(pop == 0, 0, as.numeric(female) / pop)",
                "pctmale      <- ifelse(pop == 0, 0, as.numeric(male) / pop)",
                "pctownedunits      <- ifelse(occupiedunits == 0, 0, as.numeric(ownedunits) / occupiedunits)",
                "pctnobroadband      <- ifelse(hhlds == 0, 0, as.numeric(nobroadband) / hhlds)",
                "pctnohealthinsurance      <- ifelse(hhlds == 0, 0, as.numeric(nohealthinsurance) / hhlds)",
                "pctpoor      <- ifelse(hhlds == 0, 0, as.numeric(poor) / hhlds)",
                #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #


                "pctlan_api      <- ifelse(lan_universe == 0, 0, as.numeric(lan_api) / lan_universe)",
                "pctlan_arabic      <- ifelse(lan_universe == 0, 0, as.numeric(lan_arabic) / lan_universe)",
                "pctlan_english      <- ifelse(lan_universe == 0, 0, as.numeric(lan_english) / lan_universe)",
                "pctlan_french      <- ifelse(lan_universe == 0, 0, as.numeric(lan_french) / lan_universe)",
                "pctlan_ie      <- ifelse(lan_universe == 0, 0, as.numeric(lan_ie) / lan_universe)",
                "pctlan_nonenglish      <- ifelse(lan_universe == 0, 0, as.numeric(lan_nonenglish) / lan_universe)",
                "pctlan_other      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other) / lan_universe)",
                "pctlan_other_asian      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_asian) / lan_universe)",
                "pctlan_other_ie      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_ie) / lan_universe)",
                "pctlan_rus_pol_slav      <- ifelse(lan_universe == 0, 0, as.numeric(lan_rus_pol_slav) / lan_universe)",
                "pctlan_spanish      <- ifelse(lan_universe == 0, 0, as.numeric(lan_spanish) / lan_universe)",
                "pctlan_vietnamese      <- ifelse(lan_universe == 0, 0, as.numeric(lan_vietnamese) / lan_universe)",

                "pctapi_li      <- ifelse(lingiso == 0, 0, as.numeric(api_li) / lingiso)",
                "pctie_li      <- ifelse(lingiso == 0, 0, as.numeric(ie_li) / lingiso)",
                "pctother_li      <- ifelse(lingiso == 0, 0, as.numeric(other_li) / lingiso)",
                "pctspanish_li      <- ifelse(lingiso == 0, 0, as.numeric(spanish_li) / lingiso)",

                ####---------------------------------------- #
                "pctaa      <- ifelse(pop == 0, 0, as.numeric(aa) / pop)",
                "pctaiana      <- ifelse(pop == 0, 0, as.numeric(aiana) / pop)",
                "pctba      <- ifelse(pop == 0, 0, as.numeric(ba) / pop)",
                "pctmulti      <- ifelse(pop == 0, 0, as.numeric(multi) / pop)",
                "pctnhpia      <- ifelse(pop == 0, 0, as.numeric(nhpia) / pop)",
                "pctotheralone      <- ifelse(pop == 0, 0, as.numeric(otheralone) / pop)",
                "pctwa      <- ifelse(pop == 0, 0, as.numeric(wa) / pop)",

                "EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.eo) / pop)",
                "state.EJ.DISPARITY.pctpre1960.eo      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.eo) / pop)",
                "EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(EJ.DISPARITY.pre1960.supp) / pop)",
                "state.EJ.DISPARITY.pctpre1960.supp      <- ifelse(pop == 0, 0, as.numeric(state.EJ.DISPARITY.pre1960.supp) / pop)",

                "pctdisability      <- ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)",

                "bgid = EJAM::bgpts[match(fips, bgfips), bgid]",
                "countyname = fips2countyname(fips, includestate = FALSE)",
                "statename = fips2statename(fips)", "ST = fips2stateabbrev(fips)",
                "REGION = EJAM:::fips_st2eparegion(fips_state_from_state_abbrev(ST))",

                "under18 <- ageunder5m + age5to9m + age10to14m + age15to17m + ageunder5m + age5to9f + age10to14f + age15to17f",
                "over17 <- pop - under18",
                "female = B01001_026", "male = B01001_002",
                "ownedhhlds    = B25003_002", "occupiedhhlds = B25003_001", "pctownedhhlds <- ifelse(occupied == 0, 0, ownedhhlds / occupiedhhlds)",
                "ownedunits    = B25032_002", "occupiedunits = B25032_001",
                "nobroadband = B28003_001 - B28003_004",
                "nohealthinsurance = B27010_017 + B27010_033 + B27010_050 + B27010_066",
                "poor = pov50 + pov99",
                "wa = B02001_002", "ba = B02001_003", "aa = B02001_005", "aiana = B02001_004", "nhpia = B02001_006", "otheralone = B02001_007", "multi = B02001_008",
                "percapincome = B19301_001",
                #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #


                "lan_eng_na = B16004_008 + B16004_013 + B16004_018 + B16004_023 + B16004_030 + B16004_035 + B16004_040 + B16004_045 + B16004_052 + B16004_057 + B16004_062 + B16004_067",
                "lan_spanish  = B16004_004 + B16004_026 + B16004_048",
                "lan_api = B16004_014 + B16004_036 + B16004_058",
                "lan_other = B16004_019 + B16004_041 + B16004_063",
                "lan_other_ie = B16004_009 + B16004_031 + B16004_053",
                "lan_universe = C16001_001",

                "lan_english = C16001_002", "pctlan_english <- ifelse(lan_universe == 0, 0, as.numeric(lan_english) / lan_universe)",
                "lan_french = C16001_006", "pctlan_french <- ifelse(lan_universe == 0, 0, as.numeric(lan_french) / lan_universe)",
                "lan_german = C16001_009", "pctlan_german <- ifelse(lan_universe == 0, 0, as.numeric(lan_german) / lan_universe)",
                "lan_rus_pol_slav = C16001_012", "pctlan_rus_pol_slav <- ifelse(lan_universe == 0, 0, as.numeric(lan_rus_pol_slav) / lan_universe)",
                "lan_other_ie = C16001_015", "pctlan_other_ie <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_ie) / lan_universe)",
                "lan_korean = C16001_018", "pctlan_korean <- ifelse(lan_universe == 0, 0, as.numeric(lan_korean) / lan_universe)",
                "lan_chinese = C16001_021", "pctlan_chinese <- ifelse(lan_universe == 0, 0, as.numeric(lan_chinese) / lan_universe)",
                "lan_vietnamese = C16001_024", "pctlan_vietnamese <- ifelse(lan_universe == 0, 0, as.numeric(lan_vietnamese) / lan_universe)",
                "lan_other_asian = C16001_030", "pctlan_other_asian <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_asian) / lan_universe)",
                "lan_tagalog = C16001_027", "pctlan_tagalog <- ifelse(lan_universe == 0, 0, as.numeric(lan_tagalog) / lan_universe)",
                "lan_arabic = C16001_033", "pctlan_arabic <- ifelse(lan_universe == 0, 0, as.numeric(lan_arabic) / lan_universe)",
                "lan_other_and_unspecified = C16001_036", "pctlan_other_and_unspecified <- ifelse(lan_universe == 0, 0, as.numeric(lan_other_and_unspecified) / lan_universe)"
                ####---------------------------------------- #
    ),
    longname_old = c("Total population",
                     "Count of males age Under 5 years", "Count of males age 5 to 9 years", "Count of males age 10 to 14 years",
                     "Count of males age 15 to 17 years", "Count of males age 65 and 66 years","Count of males age 67 to 69 years", "Count of males age 70 to 74 years",
                     "Count of males age 75 to 79 years", "Count of males age 80 to 84 years","Count of males age 85 years and over", "Count of females age Under 5 years",
                     "Count of females age 5 to 9 years", "Count of females age 10 to 14 years","Count of females age 15 to 17 years", "Count of females age 65 and 66 years",
                     "Count of females age 67 to 69 years", "Count of females age 70 to 74 years","Count of females age 75 to 79 years", "Count of females age 80 to 84 years",
                     "Count of females age 85 years and over",

                     "Count of Hispanic or Latino (of any race)",
                     "Count of Total Population", "Count of Not Hispanic or Latino",
                     "Count of White alone (including Hispanic/Latino)", "Count of Black or African American alone",
                     "Count of American Indian and Alaska Native alone", "Count of Asian alone",
                     "Count of Native Hawaiian and Other Pacific Islander alone",
                     "Count of people who are Some other race alone", "Count of people who are Two or more races",

                     "Population for whom poverty status is determined", "Population with income under 50% of poverty level",
                     "Population with income 50%-100% of poverty level", "Population with income 100%-124% of poverty level",
                     "Population with income 125%-149% of poverty level", "Population with income 150%-184% of poverty level",
                     "Population with income 185%-199% of poverty level", "Population with income at least twice the poverty level",

                     "Population 25 years and over",
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,


                     #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #

                     "Spanish - Limited English speaking household",
                     "Other Indo-European languages - Limited English speaking household",
                     "Asian and Pacific Island languages - Limited English speaking household",
                     "Other languages - Limited English speaking household", "Households (for linguistic isolation)",
                     ####---------------------------------------- #
                     "Housing units (for % built pre-1960)", "Built 1950 to 1959", "Built 1940 to 1949", "Built 1939 or earlier",
                     "Count of denominator for % unemployed", "Count of people unemployed",
                     "count of individuals under age 5", "% under age 5", "count of individuals over age 64", "% over age 64",

                     "Count not people of color (aka non-minority) i.e. not Hispanic or Latino White alone",
                     "Percent Hispanic or Latino", "(percent Not Hispanic or Latino White alone)",
                     "(percent Not Hispanic or Latino Black or African American alone)",
                     "(percent Not Hispanic or Latino American Indian and Alaska Native alone)",
                     "(percent Not Hispanic or Latino Asian alone)",
                     "(percent Not Hispanic or Latino Native Hawaiian and Other Pacific Islander alone)",
                     "(percent Not Hispanic or Latino Some other race alone)",
                     "(percent Not Hispanic or Latino Two or more races)",
                     "count of people of color (aka minority)", "% people of color (aka minority)",

                     "Population with income below poverty level",
                     "Population with income below 150% of poverty level",
                     "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                     "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                     "Percent of Population with income below poverty level", "Percent of Population with income below 150% of poverty level",
                     "% low-income (i.e., with income below 2 times poverty level)",
                     "% low-income (i.e., with income below 2 times poverty level)",
                     "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                     "% low-income (i.e., with income below 2 times poverty level)",

                     "count of individuals age 25 or over with less than high school degree",
                     "% less than high school", "Count of Limited English speaking households",
                     "% of households that are limited English speaking", "count of housing units built before 1960",
                     "% pre-1960 housing (lead paint indicator)",
                     "% Unemployed",
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA),

    longname = c("Total Population",
                 "Count of males age Under 5 years", "Count of males age 5 to 9 years", "Count of males age 10 to 14 years",
                 "Count of males age 15 to 17 years", "Count of males age 65 and 66 years",
                 "Count of males age 67 to 69 years", "Count of males age 70 to 74 years",
                 "Count of males age 75 to 79 years", "Count of males age 80 to 84 years",
                 "Count of males age 85 years and over", "Count of females age Under 5 years",
                 "Count of females age 5 to 9 years", "Count of females age 10 to 14 years",
                 "Count of females age 15 to 17 years", "Count of females age 65 and 66 years",
                 "Count of females age 67 to 69 years", "Count of females age 70 to 74 years",
                 "Count of females age 75 to 79 years", "Count of females age 80 to 84 years", "Count of females age 85 years and over",

                 "Count of Hispanic or Latino", "Count of Total Population",  "Count of Not Hispanic or Latino",
                 "Count of White (non-Hispanic, single race)", "Count of Black or African American (non-Hispanic, single race)",
                 "Count of American Indian and Alaska Native (non-Hispanic, single race)",
                 "Count of Asian (non-Hispanic, single race)", "Count of Native Hawaiian and Other Pacific Islander (non-Hispanic, single race)",
                 "Count of Other race (non-Hispanic, single race)", "Count of Two or more races (non-Hispanic)",

                 "Count of Population for whom Poverty Status is Determined",
                 "Population with income under 50% of poverty level", "Population with income 50%-100% of poverty level",
                 "Population with income 100%-124% of poverty level", "Population with income 125%-149% of poverty level",
                 "Population with income 150%-184% of poverty level", "Population with income 185%-199% of poverty level",
                 "Population with income at least twice the poverty level",
                 "Count of Population Age 25 up",
                 "m0", "m4", "m6", "m8", "m9", "m10", "m11", "m12",
                 "f0", "f4", "f6", "f8", "f9", "f10", "f11", "f12",
                 #### ##### ##### ##### ##### ##### ##### ##### ##### #              #### ##### ##### ##### ##### ##### ##### ##### ##### #

                 "Spanish - Limited English speaking household",
                 "Other Indo-European languages - Limited English speaking household",
                 "Asian and Pacific Island languages - Limited English speaking household",
                 "Other languages - Limited English speaking household",
                 "Count of Households",

                 ####---------------------------------------- #

                 "Built housing units count (denominator for % pre 1960)",
                 "Built 1950 to 1959", "Built 1940 to 1949", "Built 1939 or earlier",
                 "Universe for % unemployed (denominator, count)", "Unemployed resident count",
                 "Under Age 5 resident count", "% under Age 5", "Over Age 64 resident count",
                 "% over Age 64", "Non-POC resident count", "% Hispanic or Latino",
                 "% White (non-Hispanic, single race)", "% Black or African American (non-Hispanic, single race)",
                 "% American Indian and Alaska Native (non-Hispanic, single race)",
                 "% Asian (non-Hispanic, single race)", "% Native Hawaiian and Other Pacific Islander (non-Hispanic, single race)",
                 "% Other race (non-Hispanic, single race)", "% Two or more races (non-Hispanic)",
                 "People of Color resident count", "% People of Color", "Population with income below poverty level",
                 "Population with income below 150% of poverty level", "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                 "Count of low-income individuals (i.e., with income below 2 times poverty level)",
                 "Percent of Population with income below poverty level",
                 "Percent of Population with income below 150% of poverty level",
                 "% low-income (i.e., with income below 2 times poverty level)",
                 "% low-income (i.e., with income below 2 times poverty level)",
                 "Low income resident count", "% Low Income", "Less Than High School Education resident count",
                 "% with Less Than High School Education", "Limited English-speaking Households",
                 "% in limited English-speaking Households", "Count of Housing Units Built Pre 1960",
                 "Lead Paint Indicator (% pre-1960s housing)", "% Unemployed",
                 "% above age 17", "% under age 18", "Estimated Current Fire Risk",
                 "Estimated Fire Risk in 30 Years", "Estimated Current Flood Risk",
                 "Estimated Flood Risk in 30 Years", "% Females", "% Males",
                 "% Owner Occupied households", "% Households without Broadband Internet",
                 "% Households without Health Insurance", "% of Households below Poverty Level",
                 ####---------------------------------------- #

                 "% speaking Asian and Pacific Island languages at home",
                 "% speaking Arabic at home", "% speaking English at home",
                 "% speaking French at home", "% speaking Other Indo-European at home",
                 "% speaking Non English languages at home", "% speaking Other and Unspecified languages at home",
                 "% speaking Other Asian and Pacific Island languages at home",
                 "% speaking Indo-European at home", "% speaking Russian, Polish or Other Slavic at home",
                 "% speaking Spanish at home", "% speaking Vietnamese at home",
                 "% speaking Asian-Pacific Island languages (as % of limited English households)",
                 "% speaking Other Indo-European languages (as % of limited English households)",
                 "% speaking Other languages (as % of limited English households)",
                 "% speaking Spanish (as % of limited English households)",

                 ####---------------------------------------- #
                 "% Asian (single race, includes Hispanic)", "% American Indian and Alaska Native (single race, includes Hispanic)",
                 "% Black or African American (single race, includes Hispanic)",
                 "% Two or more races (includes Hispanic)", "% Native Hawaiian and Other Pacific Islander (single race, includes Hispanic)",
                 "% Other race (single race, includes Hispanic)", "% White (single race, includes Hispanic)",

                 "US type of raw score for Lead Paint Summary Index", "State type of raw score for Lead Paint Summary Index",
                 "US type of raw score for Lead Paint Supplemental Summary Index",
                 "State type of raw score for Lead Paint Supplemental Summary Index",
                 "% with Disabilities", "bgid", "County name", "State Name",
                 "State Abbreviation", "EPA Region", "Population Under Age 18",
                 "Population Over Age 17", "Female Population", "Male Population",
                 "ownedhhlds", "occupiedhhlds", "pctownedhhlds", "Count of Owner Occupied Housing Units",
                 "Occupied Housing Units", "nobroadband", "nohealthinsurance",
                 "Households below Poverty Level",

                 "Count of White (single race, includes Hispanic)",
                 "Count of Black or African American (single race, includes Hispanic)",
                 "Count of Asian (single race, includes Hispanic)", "Count of American Indian and Alaska Native (single race, includes Hispanic)",
                 "Count of Native Hawaiian and Other Pacific Islander (single race, includes Hispanic)",
                 "Count of Other race (single race, includes Hispanic)", "Count of Two or more races (includes Hispanic)",

                 "Per Capita Income",
                 ####---------------------------------------- #

                 "Number speaking English Not at All",
                 "Number speaking Spanish at Home", "Number speaking Asian-Pacific Island language at Home",
                 "Number speaking Other and Unspecified languages at home",
                 "lan_other_ie", "Number of Persons for whom Language Ability is Determined--age 5 and above.",
                 "lan_english", "% speaking English at home", "lan_french",
                 "% speaking French at home", "lan_german", "pctlan_german",
                 "lan_rus_pol_slav", "% speaking Russian, Polish or Other Slavic at home",
                 "lan_other_ie", "% speaking Indo-European at home", "lan_korean",
                 "pctlan_korean", "lan_chinese", "pctlan_chinese", "lan_vietnamese",
                 "% speaking Vietnamese at home", "lan_other_asian", "% speaking Other Asian and Pacific Island languages at home",
                 "lan_tagalog", "pctlan_tagalog", "lan_arabic", "% speaking Arabic at home",
                 "lan_other_and_unspecified", "pctlan_other_and_unspecified"

                 ####---------------------------------------- #
    ),
    varlist = c("names_d_other_count", NA, NA, NA, NA, NA,
                NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                "names_d_subgroups_count", NA, NA, "names_d_subgroups_count",
                "names_d_subgroups_count", "names_d_subgroups_count", "names_d_subgroups_count",
                "names_d_subgroups_count", "names_d_subgroups_count", "names_d_subgroups_count",
                "names_d_other_count", NA, NA, NA, NA, NA, NA, NA, "names_d_other_count",
                NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
                NA, NA, NA, NA, NA, "names_d_other_count", "names_d_other_count",
                NA, NA, NA, "names_d_other_count",
                "names_d_count", "names_d_count",
                "names_d", "names_d_count", "names_d", "names_d_other_count",
                "names_d_subgroups", "names_d_subgroups", "names_d_subgroups",
                "names_d_subgroups", "names_d_subgroups", "names_d_subgroups",
                "names_d_subgroups", "names_d_subgroups", "names_d_count",
                "names_d", NA, NA, NA, NA, NA, NA, NA, NA, "names_d_count",
                "names_d", "names_d_count", "names_d", "names_d_count", "names_d",
                "names_d_other_count", "names_e", "names_d", "names_age",
                "names_age", "names_climate", "names_climate", "names_climate",
                "names_climate", "names_community", "names_community", "names_community",
                "names_criticalservice", "names_criticalservice", "names_d_extra",

                "names_d_language", "names_d_language", "names_d_language",
                "names_d_language", "names_d_language", "names_d_language",
                "names_d_language", "names_d_language", "names_d_language",
                "names_d_language", "names_d_language", "names_d_language",

                "names_d_languageli", "names_d_languageli", "names_d_languageli",
                "names_d_languageli",

                "names_d_subgroups_alone", "names_d_subgroups_alone",
                "names_d_subgroups_alone", "names_d_subgroups_alone", "names_d_subgroups_alone",
                "names_d_subgroups_alone", "names_d_subgroups_alone", "names_ej",
                "names_ej_state", "names_ej_supp", "names_ej_supp_state",
                "names_health", NA, "names_geo", "names_geo", "names_geo",
                "names_geo", "names_age_count", "names_age_count", "names_community_count",
                "names_community_count", NA, NA, NA, "names_d_extra_count",
                "names_community", NA, NA, "names_d_extra_count", "names_d_subgroups_alone_count",
                "names_d_subgroups_alone_count", "names_d_subgroups_alone_count",
                "names_d_subgroups_alone_count", "names_d_subgroups_alone_count",
                "names_d_subgroups_alone_count", "names_d_subgroups_alone_count",
                "names_community",

                "names_d_language_count", "names_d_language_count",
                "names_d_language_count", "names_d_language_count", NA, "names_d_language_count",
                NA, "names_d_language", NA, "names_d_language", NA, NA, NA,
                "names_d_language", NA, "names_d_language", NA, NA, NA, NA,
                NA, "names_d_language", NA, "names_d_language", NA, NA, NA,
                "names_d_language", NA, NA)
  ),

  ejam_package_version = "2.4.0",
  ejscreen_version = c(VersionEJSCREEN = "2.4"),
  ejscreen_releasedate = c(ReleaseDateEJSCREEN = "2025-2026"),
  acs_releasedate = c(ReleaseDateACS = "2024-12-12"),
  acs_version = c(VersionACS = "2019-2023"),
  census_version = c(VersionCensus = "2020"),
  date_saved_in_package = "2025-12-01",

  row.names = c(NA, -194L),
  class = "data.frame")

  ## fix duplicates from above

  formulas_ejscreen_acs[formulas_ejscreen_acs$rname %in% formulas_ejscreen_acs$rname[(duplicated(formulas_ejscreen_acs$rname))],]




  ##   tables search
  # endyr = acsendyear(guess_census_has_published = T)
  # x <- tidycensus::load_variables(endyr, "acs5")
  # x[grepl("B28003", x$name) & "block group" == x$geography & !is.na(x$geography), ] |> print(n=10 )
  # # health insurance tables/variables
  # x[grepl("no health insurance", x$label, ignore.case = T) & "block group" == x$geography & !is.na(x$geography), ] |> print(n=100 )
  #
    #
    # # ######################### ## ######################### ## ######################### #
    # ## see the list of relevant tables
    # # ######################### ## ######################### ## ######################### #
    # ?tables_ejscreen_acs
    #
    # # ######################### ## ######################### ## ######################### #

  ############################################################## ############################################################### #

  ##   ADD MORE LANGUAGE VARIABLES AND FORMULAS

  ## NOTES ON PROBLEMS IN LANGUAGE VARIABLES FROM 2022 DATA USED IN 2024-2025
  # PCT_LAN_SPANISH  is what comm report on ejscreen site calls "languages spoken at home"
  # and is clearly the ratio of
  # LAN_SPANISH  / LAN_UNIVERSE
  # so that is already available as PCT_LAN_SPANISH aka  pctlan_spanish in EJAM
  # or generally as
  # fixcolnames(names_d_language,'r','long')
  #
  # This is in the dataset and we initially tried to use it but it is not the stat we actually want to show on the report:
  # in the ACS table from the ejscreen team,
  # although the resulting percentage is NOT shown anywhere in the community report,
  # this is clearly the formula they used for that dataset:
  # PCT_HLI_SPANISH_LI = HLI_SPANISH_LI / HSHOLDS
  #
  # What is actually shown on a community report from the ejscreen site:
  # LIMITED ENGLISH SPEAKING BREAKDOWN
  # % speak Spanish (as % of lingiso hhlds) =  HLI_SPANISH_LI  /  LINGISO
  # should be called PCT_HLI_SPANISH_LI, but ACS22 used that variable name to mean something else
  #   or essentially used the wrong formula for that variable (wrong denominator).
  #

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

  ##
  ## spanish exists as part of groups and detailed languages - in both tables
  # 122      pctlan_spanish           pctlan_spanish      <- ifelse(lan_universe == 0, 0, as.numeric(lan_spanish) / lan_universe)         <NA>                                  % speaking Spanish at home

  ## fix: ***
  # is this part of groups or part of detailed languages?
  # 118        pctlan_other               pctlan_other      <- ifelse(lan_universe == 0, 0, as.numeric(lan_other) / lan_universe)         <NA>          % speaking Other and Unspecified languages at home

  ## fix: ***
  ## clarify this is any non-english (as opposed to only non-english)
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
  #  # note formulas have  pctlan_other_ie  and also  pctlan_ie, an alias to drop probably. ?? ***
  # lan_other                     lan_other                                                                           Number speaking Other and Unspecified languages at home

  # pctlan_english           pctlan_english lan_universe              Languages Spoken at Home                                                     % speaking English at home
  # pctlan_nonenglish     pctlan_nonenglish lan_universe              Languages Spoken at Home                                       % speaking Non English languages at home
  # pctlan_spanish           pctlan_spanish lan_universe              Languages Spoken at Home                                                     % speaking Spanish at home
  # pctlan_api                   pctlan_api lan_universe              Languages Spoken at Home                          % speaking Asian and Pacific Island languages at home
  # pctlan_ie                     pctlan_ie lan_universe              Languages Spoken at Home                                         % speaking Other Indo-European at home
  #  # note formulas have  pctlan_other_ie  and also  pctlan_ie, an alias to drop probably. ?? ***
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

  #################################################################### #################################### #

  ## save

  ## fixed like this
#  formulas_ejscreen_acs$formula[formulas_ejscreen_acs$rname == "REGION"] <-
#    "REGION = EJAM:::fips_st2eparegion(EJAM:::fips_state_from_state_abbrev(ST))"
## updated:
#    attr(formulas_ejscreen_acs, "date_saved_in_package") <- as.character(Sys.Date())

  usethis::use_data(formulas_ejscreen_acs, overwrite = TRUE)

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

  yr = acsendyear(guess_census_has_published = T)
  # yr = acsendyear()

  x1 = acs_table_info(yr = yr)

  x = tidycensus::load_variables(yr, "acs5")
  # x = x[x$geography %in% "block group", ] # BUT THAT EXCLUDES C16001, B18101
  x = x[x$geography %in% c("tract", "block group"), ] # INCL C16001, B18101
  # x$geography <- NULL
  x$table = gsub("_.*$", "", x$name)
  x = x[x$table %in% ejscreen_acs_tables, ]
  # x |> print(n=320)
  ## language variables:
  # x[x$table %in% c("C16002","B16004", "C16001"), ] |> print(n=120)
  ############ #################################### #

  # C16001  tract only ####

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

  # C16002 ####

  x[x$table %in% "C16002",] |> print(n=40)   ## by block group

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

  # B16004  ####
  # by block group

  x[grepl("B16004", x$name, ignore.case = T) & grepl("not at all", x$label, ignore.case = T)  & "block group" == x$geography & !is.na(x$geography), ] |> print(n=100 )
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
  url_acs_table_info()


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


############################################################## #

message("SAVING FORMULAS, AND CAN USE IN CREATING INITIAL blockgroupstats table from raw acs as with acs_bybg()
        or newer get_acs_new_dat() but  then need final steps for Demog.Index scores and for disability by blockgroup not tract")

### confirmed all of tables are mentioned among formulas created here
# for (i in 1:length(tables)) {cat(tables[i]); print( any(grepl(tables[i], EJAM::formulas_ejscreen_acs$formula))) }
# cbind(tables, concept = v22$concept[match(tables, v22$table)] )


# formulas_ejscreen_acs  saved for use in package

# EJAM:::metadata_add_and_use_this("formulas_ejscreen_acs")
## or if that is not working right, do this way:

formulas_ejscreen_acs <- EJAM:::metadata_add(formulas_ejscreen_acs)
usethis::use_data(formulas_ejscreen_acs, overwrite = T)


EJAM:::dataset_documenter("formulas_ejscreen_acs",
                          description = "Formulas and metadata about Census ACS variables and how to calculate indicators from those raw Census variables, such as creating pctunder5 starting from ACS table B01001 variables.",
                          details = "[Formulas as documented by EPA were archived here](https://web.archive.org/web/20250118134239/https://www.epa.gov/system/files/documents/2024-07/ejscreen-tech-doc-version-2-3.pdf)",
                          seealso = "[tables_ejscreen_acs] ")
