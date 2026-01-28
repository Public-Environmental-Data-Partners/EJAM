################################################# ################################################### #

#' utility to download and print some info about each variable in each ACS 5yr table
#'
#' @param yr end year of 5-year ACS dataset, guesses if not specified
#' @param tables_acs optional, vector of table names like "B01001" or default, [tables_ejscreen_acs]
#' @param dataset optional, tested for "acs5" but see [tidycensus::load_variables()]
#' @returns invisibly returns data.table of all variables in specified tables,
#'   and also prints to console the first variable of each table
#'
#'
#' @export
#'
acs_table_info <- function(yr, tables_acs, dataset = 'acs5') {

  if (missing(tables_acs)) {tables_acs <- as.vector(EJAM::tables_ejscreen_acs)}
  if (missing(yr)) {yr <- acs_endyear(guess_census_has_published = T)}
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


#' utility to calculate annually for EJSCREEN the updated blockgroupstats dataset, by 1st creating blockgroupstats_acs
#'
#' @param yr end year of 5-year ACS dataset, guesses if not specified
#'
#' @returns data.table, one row per blockgroup, columns bgfips, etc.
#'
#' @export
#' @keywords internal
#'
calc_blockgroupstats_acs <- function(yr, formulas = EJAM::formulas_ejscreen_acs$formula,
                                     tables = as.vector(EJAM::tables_ejscreen_acs),
                                     dropMOE = TRUE) {

  if (!(require(ACSdownload))) {
    stop("requires installed package ACSdownload from https://github.com/ejanalysis/ACSdownload")
  }
  # library(EJAM); library(dplyr); library(data.table)

  if (missing(yr)) {
    yr <- acs_endyear(guess_always = T, guess_census_has_published = T)
  }
  ################################################### #
  ## BLOCK GROUP SURVEY DATA HANDLED DIFFERENTLY/ SEPARATELY FROM
  ## Tract resolution survey data that has to be allocated to blockgroups.
  ## Check available resolution of each table here.
  x <- acs_table_info(yr = yr, tables_acs = tables, dataset = "acs5")
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
      # "nobroadband", "nohealthinsurance",
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
