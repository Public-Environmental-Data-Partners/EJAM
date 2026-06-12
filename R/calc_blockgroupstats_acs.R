################################################# ################################################### #

#' utility to download and print some info about each variable in each ACS 5yr table
#'
#' @param yr end year of 5-year ACS dataset, guesses if not specified
#' @param tables_acs optional, vector of table names like "B01001" or default, [tables_ejscreen_acs]
#' @param dataset optional, tested for "acs5" but see [tidycensus::load_variables()]
#' @return invisibly returns data.table of all variables in specified tables,
#'   and also prints to console the first variable of each table
#' @seealso [url_acs_table_info()]
#'
acs_table_info <- function(yr, tables_acs, dataset = 'acs5') {

  if (missing(tables_acs)) {tables_acs <- as.vector(tables_ejscreen_acs)}
  if (missing(yr)) {yr <- acs_endyear(guess_census_has_published = T)}
  # Census API key is now mandatory: tidycensus (>= 1.8) errors (no longer warns) without
  # a key, INCLUDING for metadata via load_variables(). Fail fast with an actionable message.
  if (nchar(Sys.getenv("CENSUS_API_KEY")) == 0) {
    stop("A Census API key is required: tidycensus (>= 1.8) now errors without one, ",
         "including for metadata via tidycensus::load_variables(). Set one once with ",
         'tidycensus::census_api_key("YOUR KEY", install = TRUE), then restart R. ',
         "See ?tidycensus::census_api_key")
  }
  x = tidycensus::load_variables(yr, dataset = dataset, cache = T)
  x$table = gsub("^(.*)_.*$", "\\1", x$name)
  x = x[x$table %in% tables_acs, ]
  # dim(x)
  # x = x[x$geography %in% c('tract', 'block group'), ]
  x1strows <- data.table::rbindlist(lapply(tables_acs, function(z) x[x$table == z, ][1,]))
  x1strows$label = NULL
  print(x1strows)
  # x |> print(n = 400)
  invisible(x)
}
################################################# ################################################### #


#' Calculate the ACS-derived blockgroup stage for EJSCREEN annual updates
#'
#' @details
#' This lower-level helper calculates ACS-derived blockgroup indicators from
#' the Census Bureau American Community Survey (ACS) 5-year summary file. In the
#' current annual pipeline it is called through [calc_bg_acsdata()], which is in
#' turn orchestrated by [calc_ejscreen_dataset()] and the staged pipeline
#' recipe/config helpers documented in `data-raw/run_ejscreen_pipeline_*.R`.
#'
#' Requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload
#' which is documented at https://ejanalysis.github.io/ACSdownload
#'
#' @param yr end year of 5-year ACS dataset, guessed if not specified
#' @param formulas default is formulas used by EJAM/EJScreen.
#'   A vector of string formulas such as
#'   c("pop = B01001_001", "hisp = B03002_012", "pcthisp <- ifelse(pop==0, 0, as.numeric(hisp ) / pop)")
#' @param tables default is the key ACS tables needed by EJAM/EJScreen.
#'   A vector of ACS table numbers, such as c("B01001", "B03002")
#' @param dropMOE logical, whether to drop and not retain the margin of error information on every ACS variable
#' @param acs_raw optional raw ACS table list or `bg_acs_raw` pipeline object
#'   previously created by [download_bg_acs_raw()]. If supplied, no ACS download
#'   is performed for blockgroup-resolution tables.
#'
#' @return data.table, one row per blockgroup, columns bgfips, etc.
#' @seealso [calc_bg_acsdata()] [calc_blockgroupstats_from_tract_data()]
#'   [calc_bgej()] [formulas_ejscreen_acs]
#'   [formulas_ejscreen_acs_disability] [formulas_ejscreen_demog_index]
#'
#' @keywords internal
#'
calc_blockgroupstats_acs <- function(yr,
                                     formulas = EJAM::formulas_ejscreen_acs$formula,
                                     tables = as.vector(EJAM::tables_ejscreen_acs),
                                     dropMOE = TRUE,
                                     acs_raw = NULL) {

  if (!requireNamespace("ACSdownload", quietly = TRUE)) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload and documented at https://ejanalysis.github.io/ACSdownload/")
  }
  # library(EJAM); library(dplyr); library(data.table)

  if (missing(yr)) {
    yr <- acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)
  }
  if (is.null(acs_raw)) {
    # Fail fast on a missing Census API key: tidycensus (>= 1.8) errors without one, even
    # for the load_variables() metadata lookup used by acs_table_info() below. Checking
    # here (before the prior-year fallback ladder) means any later acs_table_info() error
    # is about data availability, not the key, so the ladder can safely treat it as "try a
    # prior year". The check belongs INSIDE this is.null(acs_raw) branch: when acs_raw is
    # supplied (e.g. the pipeline rebuilding bg_acsdata from the saved raw-ACS stage), no
    # tidycensus/Census-API call happens here, so a keyless environment must not be blocked.
    if (nchar(Sys.getenv("CENSUS_API_KEY")) == 0) {
      stop("A Census API key is required to build ACS data: tidycensus (>= 1.8) now errors ",
           "without one. Set it once with ",
           'tidycensus::census_api_key("YOUR KEY", install = TRUE), then restart R. ',
           "See ?tidycensus::census_api_key")
    }
    ################################################### #
    ## BLOCK GROUP SURVEY DATA HANDLED DIFFERENTLY/ SEPARATELY FROM
    ## Tract resolution survey data that has to be allocated to blockgroups.
    ## Check available resolution of each table here.
    # Get table geography metadata, falling back to a prior year if the newest vintage is
    # not yet served by tidycensus. tidycensus (>= 1.8) may *error* (not just return NA
    # geography) for a year it does not support, so catch errors here too and treat them
    # the same as all-NA geography. (A missing key already stopped us above, so an error
    # here is about data availability, not the key.) We assume table numbers + geography
    # resolution are unchanged from the prior year, which is usually but not always true.
    geo_info <- function(year) {
      tryCatch(acs_table_info(yr = year, tables_acs = tables, dataset = "acs5"),
               error = function(e) {
                 message("tidycensus could not return ACS table metadata for ", year,
                         " (", conditionMessage(e), "); will try a prior year.")
                 NULL
               })
    }
    needs_fallback <- function(x) is.null(x) || all(is.na(x$geography))
    x <- geo_info(yr)
    if (needs_fallback(x)) {
      x <- geo_info(as.numeric(yr) - 1)
      if (needs_fallback(x)) {
        # known available for the 2023 dataset
        x <- geo_info(2023)
      }
    }
    # If every attempted year failed (e.g. tidycensus/Census API unreachable), x is NULL or
    # all-NA. Stop with a clear message rather than letting the NULL/all-NA flow downstream,
    # where it would silently yield empty tables_bg/tables_tract and a confusing later error.
    if (needs_fallback(x)) {
      stop("Could not obtain ACS table geography metadata from tidycensus for ", yr, ", ",
           as.numeric(yr) - 1, ", or 2023, so block-group vs tract resolution per table ",
           "cannot be determined. Check the internet connection and that tidycensus can ",
           "reach the Census API (a valid CENSUS_API_KEY is required).")
    }
    tables_resolution = x$geography[ match(tables, x$table)] # geo res of first hit in x info, per table
    tables_bg    = tables[tables_resolution %in% "block group" ]
    tables_tract = tables[tables_resolution %in% "tract" ]
    ################################################### #
    # - get new ACS data for most indicators using downloads (not Census API)
    suppressWarnings({
      bg <- ACSdownload::get_acs_new(
        yr = yr,
        return_list_not_merged = FALSE,
        fips = "blockgroup",
        tables = tables_bg
      )
    })
  } else {
    bg <- merge_acs_raw_tables(acs_raw_component(acs_raw, "blockgroup"))
  }
  bg$bgfips = bg$fips
  bg$GEO_ID = NULL


  # dim(bg) #  242104    639
  if (dropMOE) {
    bg <- bg[, !grepl("_M", names(bg)), with = FALSE]
  }
  # dim(bg) #  321 columns left if drop MOE

  blockgroupstats_acs <- calc_ejam(bg, formulas = formulas,
                                   keep.old = c("bgfips", "bgid"),
  )

  ## hard coded for now - columns to drop that are intermediary values in calculations
  todrop =
    c("ageunder5m", "age5to9m", "age10to14m", "age15to17m", "age65to66m", "age6769m", "age7074m", "age7579m", "age8084m", "age85upm",
      "ageunder5f", "age5to9f", "age10to14f", "age15to17f", "age65to66f", "age6769f", "age7074f", "age7579f", "age8084f", "age85upf",
      "pop3002",
      "nonhisp",
      "pov50", "pov99", "pov124", "pov149", "pov184", "pov199", "pov2plus",
      "m0", "m4", "m6", "m8", "m9", "m10", "m11", "m12",
      "f0", "f4", "f6", "f8", "f9", "f10", "f11", "f12",
      # "lingisospanish", "lingisoeuro", "lingisoasian", "lingisoother",
      "built1950to1959", "built1940to1949", "builtpre1940",
      "num1pov", "num15pov", "num2pov", "num2pov.alt",
      "pct1pov", "pct15pov", "pct2pov", "pct2pov.alt",
      # "bgid",
      "nobroadband", "nohealthinsurance",
      # "lan_other_ie",
      "lan_other_ie.1"
    )
  # dim(blockgroupstats_acs)
  # [1] 242104    125
  blockgroupstats_acs <- blockgroupstats_acs[ , !names(blockgroupstats_acs) %in% todrop, with = FALSE]
  # dim(blockgroupstats_acs)
  # [1] 242104     68
  ################################################### #

  ## Tract resolution survey data that has to be allocated to blockgroups, next

  ################################################### #

  setorder(blockgroupstats_acs, bgfips)
  return(blockgroupstats_acs)
}
################################################# ################################################### #


# "lowlifex"  is from CDC so no formula here except possibly
# "lowlifex = 1 - (lifex / maxlifex)"
# but lifex by bg is imported from CDC 1st, not from ACS, and maxlifex is a US constant based on that source.
# % Low Life Expectancy is defined as “1 – (Life Expectancy / Max Life Expectancy)”
# Note: This is derived from the CDC life expectancy at birth data using the formula above.
############################################################## #
