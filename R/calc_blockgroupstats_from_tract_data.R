

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
#'  For ACS 2022 and later, Connecticut ACS tract FIPS use planning-region
#'  county equivalents while 2020 Decennial blockgroup FIPS use the older county
#'  equivalents. When `tract_weight_source = "decennial2020"` and `acs_raw` is
#'  available, the function detects this mismatch and repairs Connecticut
#'  weights with same-vintage ACS blockgroup population weights.
#'
#' @param yr endyear of ACS 5-year survey to use, inferred if omitted
#' @param tables ACS tract tables used for tract-derived indicators, typically
#'   `"B18101"`, `"C16001"`, and `"B27010"` for disability, detailed language,
#'   and health insurance.
#' @param formulas default includes formulas for disability-related and language-related indicators
#'  calculated from tract-level ACS variables. This is a vector of string formulas.
#' @param dropMOE logical, whether to drop not retain the margin of error information for each ACS variable
#' @param acs_raw optional raw ACS table list or `bg_acs_raw` pipeline object
#'   previously created by [download_bg_acs_raw()]. If supplied, no ACS download
#'   is performed for tract-resolution tables.
#' @param tract_weight_source source for blockgroup-to-tract apportionment
#'   weights. `"decennial2020"` uses 2020 Decennial Census population weights,
#'   matching the legacy EJSCREEN approach. `"acs"` uses same-vintage ACS
#'   blockgroup population from `acs_raw` or downloads it when needed.
#'
#' @return data.table, one row per blockgroup (not tract)
#'
#' @keywords internal
#'
calc_blockgroupstats_from_tract_data <- function(yr,
                                                 tables = c("B18101", "C16001", "B27010"),
                                                 formulas = NULL,
                                                 dropMOE = TRUE,
                                                 acs_raw = NULL,
                                                 tract_weight_source = c("decennial2020", "acs")) {

  tract_weight_source <- match.arg(tract_weight_source)
  if (missing(yr)) {
    yr = acs_endyear(guess_census_has_published = TRUE, guess_always = T)
  }  # 2022, 2023, or 2024
  cat("end year to use: ", yr, '\n')

  bgwts <- calc_blockgroupstats_bgwts(
    acs_raw = acs_raw,
    env = parent.frame(),
    yr = yr,
    weight_source = tract_weight_source
  )
  ###################################################### #
  if (missing(formulas) || is.null(formulas)) {
    formulas <- c(
      formulas_ejscreen_acs_disability$formula,
      formulas_ejscreen_acs$formula[grepl("lan_", formulas_ejscreen_acs$formula)],
      formulas_ejscreen_acs$formula[
        formulas_ejscreen_acs$rname %in% c(
          "healthinsurance_universe",
          "nohealthinsurance",
          "pctnohealthinsurance"
        )
      ]
    )

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
  if ("healthinsurance_universe" %in% names(tracts)) {
    data.table::setnames(tracts, old = "healthinsurance_universe", new = "tract_healthinsurance_universe")
  }
  if ("nohealthinsurance" %in% names(tracts)) {
    data.table::setnames(tracts, old = "nohealthinsurance", new = "tract_nohealthinsurance")
  }

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
                 intersect(c("tract_healthinsurance_universe", "tract_nohealthinsurance"), names(tracts)),
                 lanvars_found
  )

  bg_from_tracts <- tracts[bgwts, ..neededvars, on = "tractfips"]


  # - create blockgroup count in each bg, for each count variable, calculated from tractwide count times the bgwt

  bg_from_tracts[, disability     := tract_disability * bgwt]
  bg_from_tracts[, disab_universe := tract_disab_universe * bgwt]
  if ("tract_healthinsurance_universe" %in% names(bg_from_tracts)) {
    bg_from_tracts[, healthinsurance_universe := tract_healthinsurance_universe * bgwt]
  }
  if ("tract_nohealthinsurance" %in% names(bg_from_tracts)) {
    bg_from_tracts[, nohealthinsurance := tract_nohealthinsurance * bgwt]
  }

  tract_lan_cols <- grep("^tract_lan_", names(bg_from_tracts), value = TRUE)
  lan_counts_bg <- bg_from_tracts[, lapply(.SD, function(x) x * bgwt),
                                  .SDcols = tract_lan_cols]
  bg_from_tracts <- cbind(bg_from_tracts, lan_counts_bg)
  bg_from_tracts[, c(
    "tract_disability",
    "tract_disab_universe",
    intersect(c("tract_healthinsurance_universe", "tract_nohealthinsurance"), names(bg_from_tracts)),
    tract_lan_cols
  ) := NULL]
  ############################################################### #

  ## CHANGE NAMES NOW FROM tract_ to normal bg names

  names(bg_from_tracts) <- gsub("tract_", "", names(bg_from_tracts))


  # round to nearest person in each blockgroup only after calculating percent with disability
  ############################################################### #

  ## - finally take that bg_from_tracts table and
  ## apply formulas to it, to calculate bg scale percentages
  ## or just use the formula directly:

  bg_from_tracts[, pctdisability := ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)]
  if (all(c("healthinsurance_universe", "nohealthinsurance") %in% names(bg_from_tracts))) {
    bg_from_tracts[, pctnohealthinsurance := ifelse(
      healthinsurance_universe == 0,
      0,
      as.numeric(nohealthinsurance) / healthinsurance_universe
    )]
  }



  ### *** creates duplicate names...


  pct_language_formulas <- formulas[grepl("^pctlan_|^pct_chinese|^pct_korean", trimws(formulas))]
  bg_from_tracts <- calc_ejam(bg_from_tracts,
                              formulas = pct_language_formulas,
                              keep.old = c("bgfips",
                                           "disability",  "disab_universe",   "pctdisability",
                                           intersect(c("healthinsurance_universe", "nohealthinsurance", "pctnohealthinsurance"), names(bg_from_tracts)),
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
  if ("healthinsurance_universe" %in% names(bg_from_tracts)) {
    bg_from_tracts[, healthinsurance_universe := round(healthinsurance_universe, 0)]
  }
  if ("nohealthinsurance" %in% names(bg_from_tracts)) {
    bg_from_tracts[, nohealthinsurance := round(nohealthinsurance, 0)]
  }

  ## round the language or other counts here too...   ***





  ##################################################################### #
  setorder(bg_from_tracts, bgfips)

  ##################################################################### #
  if (FALSE) {
    # for acs2022, optional code to validate against old ejscreen release from late 2024...

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
  }
  ##################################################################### #
  print("## note that it does include Puerto Rico:")
  print(  table(fips2stateabbrev(   bg_from_tracts$bgfips) ))

  ##################################################################### #
  return(bg_from_tracts)
}
##################################################################### ###################################################################### #

calc_bgwts_from_acs_raw <- function(acs_raw, pop_col = "B01001_001") {
  if (is.null(acs_raw)) {
    return(NULL)
  }

  blockgroup_tables <- tryCatch(
    acs_raw_component(acs_raw, "blockgroup"),
    error = function(e) NULL
  )
  if (is.null(blockgroup_tables) || length(blockgroup_tables) == 0) {
    return(NULL)
  }

  bg_pop <- NULL
  if ("B01001" %in% names(blockgroup_tables) &&
      all(c("fips", pop_col) %in% names(blockgroup_tables$B01001))) {
    bg_pop <- blockgroup_tables$B01001
  } else {
    has_pop <- vapply(blockgroup_tables, function(x) {
      is.data.frame(x) && all(c("fips", pop_col) %in% names(x))
    }, logical(1))
    if (any(has_pop)) {
      bg_pop <- blockgroup_tables[[which(has_pop)[1]]]
    }
  }
  if (is.null(bg_pop)) {
    return(NULL)
  }

  bgwts <- data.table::as.data.table(data.table::copy(bg_pop))[
    ,
    .(
      bgfips = as.character(fips),
      pop = suppressWarnings(as.numeric(.SD[[pop_col]]))
    ),
    .SDcols = pop_col
  ]
  bgwts <- bgwts[nchar(bgfips) == 12]
  bgwts[, tractfips := substr(bgfips, 1, 11)]
  bgwts[, tractpop := sum(pop, na.rm = TRUE), by = "tractfips"]
  bgwts[, bgwt := data.table::fifelse(is.na(pop), NA_real_,
                                      data.table::fifelse(tractpop == 0, 0, pop / tractpop))]
  bgwts[, c("pop", "tractpop") := NULL]
  data.table::setorder(bgwts, bgfips)
  bgwts
}
###################################################### #

calc_blockgroupstats_bgwts <- function(acs_raw = NULL,
                                       env = parent.frame(),
                                       yr = NULL,
                                       weight_source = c("decennial2020", "acs")) {
  weight_source <- match.arg(weight_source)
  bgwts <- NULL
  if (exists("bgwts", envir = env, inherits = FALSE)) {
    return(get("bgwts", envir = env, inherits = FALSE))
  }

  if (weight_source == "acs") {
    if (!is.null(acs_raw)) {
      bgwts <- calc_bgwts_from_acs_raw(acs_raw)
    }
    if (!is.null(bgwts)) {
      return(bgwts)
    }
    if (!is.null(yr) && requireNamespace("ACSdownload", quietly = TRUE)) {
      bgwts <- tryCatch(
        calc_bgwts_from_acs_bg_population(yr = yr),
        error = function(e) {
          warning(
            "Could not create same-vintage ACS blockgroup-to-tract weights for ",
            yr, "; falling back to 2020 Decennial Census weights: ",
            conditionMessage(e),
            call. = FALSE
          )
          NULL
        }
      )
      if (!is.null(bgwts)) {
        return(bgwts)
      }
    }
  }

  tryCatch(
    {
      bgwts <- calc_bgwts_from_bg_cenpop2020()
      if (is.null(bgwts)) {
        bgwts <- calc_bgwts_nationwide(year = 2020)
      }
      repair_decennial_weights_with_acs_mismatched_states(bgwts, acs_raw = acs_raw)
    },
    error = function(e) {
      stop(
        "Could not create 2020 Decennial Census blockgroup-to-tract weights. ",
        "Use tract_weight_source = 'acs' to use same-vintage ACS population ",
        "weights instead. Error: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
}
###################################################### #

repair_decennial_weights_with_acs_mismatched_states <- function(bgwts, acs_raw = NULL) {
  if (is.null(acs_raw)) {
    return(bgwts)
  }
  acs_bgwts <- calc_bgwts_from_acs_raw(acs_raw)
  if (is.null(acs_bgwts) || nrow(acs_bgwts) == 0) {
    return(bgwts)
  }

  bgwts <- data.table::as.data.table(data.table::copy(bgwts))
  acs_bgwts <- data.table::as.data.table(data.table::copy(acs_bgwts))
  bgwts[, bgfips := as.character(bgfips)]
  bgwts[, tractfips := as.character(tractfips)]
  acs_bgwts[, bgfips := as.character(bgfips)]
  acs_bgwts[, tractfips := as.character(tractfips)]

  acs_states <- unique(substr(acs_bgwts$bgfips, 1, 2))
  mismatch_states <- acs_states[vapply(acs_states, function(st) {
    acs_tracts <- unique(acs_bgwts$tractfips[substr(acs_bgwts$bgfips, 1, 2) == st])
    decennial_tracts <- unique(bgwts$tractfips[substr(bgwts$bgfips, 1, 2) == st])
    length(decennial_tracts) > 0 && length(intersect(acs_tracts, decennial_tracts)) == 0
  }, logical(1))]

  incomplete_tracts <- setdiff(acs_bgwts$bgfips, bgwts$bgfips)
  incomplete_tracts <- unique(acs_bgwts$tractfips[acs_bgwts$bgfips %in% incomplete_tracts])
  incomplete_tracts <- setdiff(incomplete_tracts, acs_bgwts$tractfips[substr(acs_bgwts$bgfips, 1, 2) %in% mismatch_states])

  if (length(mismatch_states) == 0 && length(incomplete_tracts) == 0) {
    return(bgwts)
  }

  if (length(mismatch_states) > 0) {
    warning(
      "Using same-vintage ACS blockgroup population weights for state FIPS ",
      paste(mismatch_states, collapse = ", "),
      " because 2020 Decennial tract FIPS do not overlap the ACS tract FIPS. ",
      "This occurs for Connecticut in ACS 2022+ after Census adopted planning regions as county equivalents.",
      call. = FALSE
    )
  }
  if (length(incomplete_tracts) > 0) {
    warning(
      "Using same-vintage ACS blockgroup population weights for ",
      length(incomplete_tracts),
      " tract(s) because the decennial weight table is missing one or more ACS blockgroups.",
      call. = FALSE
    )
  }

  bgwts <- bgwts[
    !substr(bgfips, 1, 2) %in% mismatch_states &
      !tractfips %in% incomplete_tracts
  ]
  bgwts <- data.table::rbindlist(
    list(
      bgwts,
      acs_bgwts[
        substr(bgfips, 1, 2) %in% mismatch_states |
          tractfips %in% incomplete_tracts
      ]
    ),
    use.names = TRUE
  )
  data.table::setorder(bgwts, bgfips)
  bgwts
}
###################################################### #

calc_bgwts_from_bg_cenpop2020 <- function(bg_cenpop = EJAM::bg_cenpop2020) {
  if (is.null(bg_cenpop) || !is.data.frame(bg_cenpop)) {
    return(NULL)
  }
  required <- c("bgfips", "pop2020")
  if (!all(required %in% names(bg_cenpop))) {
    return(NULL)
  }

  bgwts <- data.table::as.data.table(data.table::copy(bg_cenpop))[
    ,
    .(
      bgfips = as.character(bgfips),
      pop = suppressWarnings(as.numeric(pop2020))
    )
  ]
  bgwts <- bgwts[nchar(bgfips) == 12]
  if (nrow(bgwts) == 0) {
    return(NULL)
  }
  bgwts[, tractfips := substr(bgfips, 1, 11)]
  bgwts[, tractpop := sum(pop, na.rm = TRUE), by = "tractfips"]
  bgwts[, bgwt := data.table::fifelse(
    is.na(pop),
    NA_real_,
    data.table::fifelse(tractpop == 0, 0, pop / tractpop)
  )]
  bgwts[, c("pop", "tractpop") := NULL]
  data.table::setorder(bgwts, bgfips)
  bgwts
}
###################################################### #

calc_bgwts_from_acs_bg_population <- function(yr, pop_col = "B01001_001") {
  bg_pop <- ACSdownload::get_acs_new(
    yr = yr,
    tables = "B01001",
    fips = "blockgroup",
    return_list_not_merged = TRUE
  )
  calc_bgwts_from_acs_raw(
    list(blockgroup = list(B01001 = bg_pop$B01001)),
    pop_col = pop_col
  )
}
###################################################### #
