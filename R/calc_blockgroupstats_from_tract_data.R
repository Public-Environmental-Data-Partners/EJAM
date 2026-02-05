
# calc_blockgroupstats_from_tract_data() -  TAKES A WHILE TO DOWNLOAD THE CENSUS DATA FOR EVERY STATE !!

###################################################### #

#' utility to calculate annually for EJSCREEN the updated ACS data available at only tract resolution (% disability & language detail)
#' @details
#'  Needs Census API key for [tidycensus::get_decennial()].
#'
#'  Takes some time to download data for every State.
#'
#'  First get tract counts,
#'  then apportion into blockgroup counts,
#'  then calculate percents in blockgroups via formulas.
#'
#' @param yr endyear of ACS 5-year survey to use, inferred if omitted
#' @param tables "B18101" and "C16001", e.g., for disability and detailed language spoken
#' @return data.table, one row per blockgroup (not tract)
#'
#' @export
#' @keywords internal
#'
calc_blockgroupstats_from_tract_data <- function(yr, tables = c("B18101", "C16001"), formulas,
                                                 dropMOE=TRUE) {

  if (!exists("bgwts")) { # so that we can create this once while testing and not have to download each time this overall function is used
    bgwts <- calc_bgwts_nationwide()
  }

  if (missing(yr)) {
    yr = acs_endyear(guess_census_has_published = TRUE, guess_always = T)
  }  # 2022, 2023, or 2024
  cat("end year to use: ", yr, '\n')
  ###################################################### #
  if (missing(formulas)) {
    formulas <- c(formulas_ejscreen_acs_disability$formula, formulas_ejscreen_acs$formula[grepl("lan_", formulas_ejscreen_acs$formula)] )

    ## e.g., # formulas_ejscreen_acs_disability[c(3,2,1),]
    # disab_universe <- B18101_001
    # disability <- B18101_004 + B18101_007 + B18101_010 + B18101_013 + B18101_016 + B18101_019 + B18101_023 + B18101_026 + B18101_029 + B18101_032 + B18101_035 + B18101_038
    # etc.

    ## all the language details indicators calculations:
    # x = acs_table_info(tables_acs = "C16001")
    # print(x, n=40)
    # formulas_ejscreen_acs[grepl("lan_", formulas_ejscreen_acs$formula), 'formula']
    ## or leave out the pctlan_ calculations and just see the counts:
    # > formulas_ejscreen_acs[grepl("^lan_", formulas_ejscreen_acs$formula), 'formula']
    # [1] "lan_eng_na = B16004_008 + B16004_013 + B16004_018 + B16004_023 + B16004_030 + B16004_035 + B16004_040 + B16004_045 + B16004_052 + B16004_057 + B16004_062 + B16004_067"
    # [2] "lan_spanish  = B16004_004 + B16004_026 + B16004_048"
    # [3] "lan_api = B16004_014 + B16004_036 + B16004_058"
    # [4] "lan_other = B16004_019 + B16004_041 + B16004_063"
    # [5] "lan_other_ie = B16004_009 + B16004_031 + B16004_053"
    # [6] "lan_universe = C16001_001"
    # [7] "lan_english = C16001_002"
    # [8] "lan_french = C16001_006"
    # [9] "lan_german = C16001_009"
    # [10] "lan_rus_pol_slav = C16001_012"
    # [11] "lan_other_ie = C16001_015"
    # [12] "lan_korean = C16001_018"
    # [13] "lan_chinese = C16001_021"
    # [14] "lan_vietnamese = C16001_024"
    # [15] "lan_other_asian = C16001_030"
    # [16] "lan_tagalog = C16001_027"
    # [17] "lan_arabic = C16001_033"
    # [18] "lan_other_and_unspecified = C16001_036"

  }
  ###################################################### #
  # - download tract level acs for B18101 and C16001, e.g.

  tracts <- suppressWarnings({
    ACSdownload::get_acs_new(tables = tables, fips = "tract", yr = yr, return_list_not_merged = F)
  })
  # tracts <- tracts[[1]]
  if (dropMOE) {
    tracts <- tracts[, !grepl("_M", names(tracts)), with = FALSE]
  }
  tracts$GEO_ID = NULL
  tracts$SUMLEVEL = NULL
  ###################################################### #

  # - 1st, use formulas to get ONLY COUNTS like disability and disab_universe, calculated in each tract,
  # NOT the percentages by tract, or at least we just drop or ignore % by tract

  tracts <- calc_ejam(tracts, formulas = formulas,
                      keep.old = "fips", keep.new = 'all')

  # tracts$pctdisability <- NULL
  tracts <- tracts[, !grepl("^pct", names(tracts)), with = FALSE]

  data.table::setnames(tracts, old = "fips", new = "tractfips")

  data.table::setnames(tracts, old = "disability", new = "tract_disability")
  data.table::setnames(tracts, old = "disab_universe", new = "tract_disab_universe")

  ## hard-coded for now, to assume indicator counts start with "lan_" here: ***

  names(tracts) <- gsub("^lan_", "tract_lan_", names(tracts))

  ####################################################################### #
  # - take the bgwt, bgfips, tractfips data.table and
  # join it to tract table of tractfips and disability counts,
  # to get bg_from_tracts table that has  tractwide counts of disability and disab_universe in each bg for each count variable

  # > dput(formulas_ejscreen_acs[grepl("^lan_", formulas_ejscreen_acs$formula),]$rname)

  ## hard-coded for now:
  lanvars = c("lan_eng_na", "lan_spanish", "lan_api", "lan_other", "lan_other_ie",
              "lan_universe", "lan_english", "lan_french", "lan_german", "lan_rus_pol_slav",
              "lan_other_ie", "lan_korean", "lan_chinese", "lan_vietnamese",
              "lan_other_asian", "lan_tagalog", "lan_arabic", "lan_other_and_unspecified"
  )
  #  tract_lan_eng_na, tract_lan_spanish, tract_lan_api, tract_lan_other, tract_lan_other_ie,
  # tract_lan_universe, tract_lan_english, tract_lan_french, tract_lan_german, tract_lan_rus_pol_slav,
  # tract_lan_other_ie, tract_lan_korean, tract_lan_chinese, tract_lan_vietnamese,
  # tract_lan_other_asian, tract_lan_tagalog, tract_lan_arabic, tract_lan_other_and_unspecified
  #
  lanvars_found = intersect(paste0("tract_", lanvars), names(tracts))
  neededvars = c('bgfips', 'bgwt',
                 'tract_disability', 'tract_disab_universe',
                 lanvars_found
  )

  bg_from_tracts <- tracts[bgwts, ..neededvars, on = "tractfips"]


  # - create blockgroup count in each bg, for each count variable, calculated from tractwide count times the bgwt

  bg_from_tracts[, disability     := tract_disability * bgwt]
  bg_from_tracts[, disab_universe := tract_disab_universe * bgwt]

  lan_counts_bg <- bg_from_tracts[, lapply(.SD, function(x) x * bgwt),
                 .SDcols = patterns("^tract_lan_")
  ]
  bg_from_tracts <- cbind(bg_from_tracts, lan_counts_bg)
  ############################################################### #

  ## CHANGE NAMES NOW FROM tract_ to normal bg names

  names(bg_from_tracts) <- gsub("tract_", "", names(bg_from_tracts))


  # round to nearest person in each blockgroup only after calculating percent with disability
  ############################################################### #

  ## - finally take that bg_from_tracts table and
  ## apply formulas to it, to calculate bg scale percentages
  ## or just use the formula directly:

  bg_from_tracts[, pctdisability := ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)]



  ### *** creates duplicate names...


  bg_from_tracts <- calc_ejam(bg_from_tracts,
                              formulas = formulas[grepl("^pctlan_", formulas)],
             keep.old = c("bgfips",
                            "disability",  "disab_universe",   "pctdisability",
                          grep("^lan_", names(bg_from_tracts) , value = TRUE)
                          )
             )


  ############################################################### #
  # drop extra columns now

  # bg_from_tracts$bgwt                 <- NULL
  # bg_from_tracts$tract_disab_universe <- NULL
  # bg_from_tracts$tract_disability     <- NULL
  # already gone:
  # bg_from_tracts <- bg_from_tracts[, !grepl("^tracts_", names(bg_from_tracts)), with = FALSE]


  # as.data.frame(bg_from_tracts)[bg_from_tracts$bgfips == "010730144081", grepl("disa", names(bg_from_tracts))]
  #      disability disab_universe pctdisability
  # 1866   103.5074        1945.26    0.05321009
  # > as.data.frame(blockgroupstats)[blockgroupstats$bgfips == "010730144081", grepl("disa", names(blockgroupstats))]
  #      disab_universe disability pctdisability
  # 1865           1945        104    0.05321009 # ok

  # > as.data.frame(blockgroupstats)[blockgroupstats$bgfips == "010730144082", grepl("disa", names(blockgroupstats))]
  # disab_universe disability pctdisability
  # 1866              0          0    0.05321009  # strange case - ejscreen data says 0.05 even though it shows 0/0
  # > as.data.frame(bg_from_tracts)[bg_from_tracts$bgfips == "010730144082", grepl("disa", names(bg_from_tracts))]
  # disability disab_universe pctdisability
  # 1867          0              0             0

  # ROUND NOW,
  bg_from_tracts[, disability := round(disability, 0)]
  bg_from_tracts[, disab_universe := round(disab_universe, 0)]

  ## round the language or other counts here too...   ***





  ##################################################################### #
  setorder(bg_from_tracts, bgfips)

  ##################################################################### #

  # for acs2022, validate against old ejscreen release from late 2024...

  # > dim(blockgroupstats)
  # [1] 242336    150
  # > dim(bg_from_tracts)
  # [1] 242335      4
  inboth = blockgroupstats$bgfips[bg_from_tracts$bgfips %in% blockgroupstats$bgfips]
  bs = blockgroupstats[blockgroupstats$bgfips %in% inboth, .(bgfips, pctdisability, disab_universe, disability)]
  bd = bg_from_tracts[bg_from_tracts$bgfips %in% inboth, ]

  ratios = bs$disab_universe / bd$disab_universe[match(bs$bgfips, bd$bgfips)]
  ratios[bs$disab_universe == 0]  <- 1
  # summary(ratios)
  #   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.9968  1.0000  1.0000  1.0000  1.0000  1.0034   not exact but essentially replicates

  ratios = bs$disability / bd$disability[match(bs$bgfips, bd$bgfips)]
  ratios[bs$disability == 0]  <- 1
  # summary(ratios)
  #    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.9861  1.0000  1.0000  1.0000  1.0000  1.0263    not exact but almost replicates

  ratios = bs$pctdisability / bd$pctdisability[match(bs$bgfips, bd$bgfips)]
  ratios[bs$pctdisability == 0]  <- 1
  # summary(ratios)
  # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 1       1       1     Inf       1     Inf   # IF ROUND BEFORE RATIO DONE, REPLICATES EXCEPT Inf glitch
  #   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.4899  0.9986  1.0000     Inf  1.0015     Inf   ## IF ROUNDED BEFORE RATIO, percentage calculation not replicated.   need to get ratio before rounding counts

  ##################################################################### #
  print("## note that it does include Puerto Rico:")
  print(  table(fips2stateabbrev(   bg_from_tracts$bgfips) ))

  ##################################################################### #
  return(bg_from_tracts)
}
##################################################################### ###################################################################### #
