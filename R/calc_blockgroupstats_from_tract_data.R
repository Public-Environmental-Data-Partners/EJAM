

## compare / reconcile with  /data-raw/datacreate_blockgroup_pctdisability.R ***


###################################################### #

#' utility to calculate annually for EJSCREEN the updated ACS data available at only tract resolution (% disability & language detail)
#' @details
#' This is now typically orchestrated by [calc_ejscreen_dataset()] and by the
#' staged pipeline runner script `data-raw/run_ejscreen_acs2024_pipeline.R`.
#'
#'  Relies on the function get_acs_new() which is available from the package ACSdownload (on github) as ACSdownload::get_acs_new()
#'
#'  Needs Census API key for [tidycensus::get_decennial()].
#'
#'  Takes some time to download data for every State!
#'
#'  First get tract counts,
#'  then apportion into blockgroup counts,
#'  then calculate percents in blockgroups via formulas.
#'
#' @param yr endyear of ACS 5-year survey to use, inferred if omitted
#' @param tables "B18101" and "C16001", e.g., for disability and detailed language spoken
#' @param formulas default includes formulas for disability-related and language-related indicators
#'  calculated from ACS variables found in tables "B18101" and "C16001" - This is a vector of string formulas.
#' @param dropMOE logical, whether to drop not retain the margin of error information for each ACS variable
#' @param acs_raw optional raw ACS table list or `bg_acs_raw` pipeline object
#'   previously created by [download_bg_acs_raw()]. If supplied, no ACS download
#'   is performed for tract-resolution tables.
#'
#' @return data.table, one row per blockgroup (not tract)
#'
#' @export
#' @keywords internal
#'
calc_blockgroupstats_from_tract_data <- function(yr,
                                                 tables = c("B18101", "C16001"),
                                                 formulas = NULL,
                                                 dropMOE = TRUE,
                                                 acs_raw = NULL) {

  if (!exists("bgwts")) { # so that we can create this once while testing and not have to download each time this overall function is used
    bgwts <- calc_bgwts_nationwide()
  }

  if (missing(yr)) {
    yr = acs_endyear(guess_census_has_published = TRUE, guess_always = T)
  }  # 2022, 2023, or 2024
  cat("end year to use: ", yr, '\n')
  ###################################################### #
  if (missing(formulas) || is.null(formulas)) {
    formulas <- c(formulas_ejscreen_acs_disability$formula,
                  formulas_ejscreen_acs$formula[grepl("lan_", formulas_ejscreen_acs$formula)] )

    ## e.g., # formulas_ejscreen_acs_disability[c(3,2,1),]
    # disab_universe <- B18101_001
    # disability <- B18101_004 + B18101_007 + B18101_010 + B18101_013 + B18101_016 + B18101_019 + B18101_023 + B18101_026 + B18101_029 + B18101_032 + B18101_035 + B18101_038
    # etc.

    ## all the language details indicator calculations:
    # x = acs_table_info(tables_acs = "C16001")
    # print(x, n=40)
    # formulas_ejscreen_acs[grepl("lan_", formulas_ejscreen_acs$formula), 'formula']
    ## or leave out the pctlan_ calculations and just see the counts:
    # > formulas_ejscreen_acs[grepl("^lan_", formulas_ejscreen_acs$formula), 'formula']
    # uses C16001 for language-at-home counts whose percentages use lan_universe.
    # B16004 is still used separately for lan_eng_na, "Speak English not at all."

  }
  ###################################################### #
  # - download tract level acs for B18101 and C16001, e.g.

  if (is.null(acs_raw)) {
    tracts <- suppressWarnings({
      ACSdownload::get_acs_new(tables = tables, fips = "tract", yr = yr, return_list_not_merged = F)
    })
  } else {
    tracts <- merge_acs_raw_tables(acs_raw_component(acs_raw, "tract"))
  }
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

  lanvars <- unique(calc_varname_from_formula(formulas[grepl("^lan_", trimws(formulas))]))
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

  tract_lan_cols <- grep("^tract_lan_", names(bg_from_tracts), value = TRUE)
  lan_counts_bg <- bg_from_tracts[, lapply(.SD, function(x) x * bgwt),
                                  .SDcols = tract_lan_cols]
  bg_from_tracts <- cbind(bg_from_tracts, lan_counts_bg)
  bg_from_tracts[, c("tract_disability", "tract_disab_universe", tract_lan_cols) := NULL]
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


  pct_language_formulas <- formulas[grepl("^pctlan_|^pct_chinese|^pct_korean", trimws(formulas))]
  bg_from_tracts <- calc_ejam(bg_from_tracts,
                              formulas = pct_language_formulas,
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
