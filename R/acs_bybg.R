
### Adding these functions would require the tidycensus pkg and scales and stringr
# ## not already required by EJAM:
# library(tidycensus) # About 2MB (+ other pkgs it uses)
# library(scales)
# library(stringr)
#   and tidycensus imports these:
# httr, (sf), (stringr), tigris, jsonlite,
# purrr, rvest,  rappdirs, readr, xml2, units, utils, rlang, crayon, tidyselect
################################# #




################################# ################################## #


#' download ACS 5year data from Census API, at blockgroup resolution (slowly if for entire US)
#' @details
#'
#' Probably requires [getting and specifying an API key for Census Bureau](https://api.census.gov/data/key_signup.html) ! (at least if query is large).
#'   see [tidycensus package help](https://walker-data.com/tidycensus/)  envt var CENSUS_API_KEY
#'
#' NOTES ON KEY TABLES IN ACS THAT ARE RELEVANT TO EJSCREEN:
#' ```
#' x <- tidycensus::load_variables(2022, "acs5")
#'
#' tables = c(
#'   "B25034", # pre1960, for lead paint indicator (environmental not demographic per se)
#'   "B01001", # sex and age / basic population counts
#'   "B03002", # race with hispanic ethnicity
#'   "B02001", # race without hispanic ethnicity
#'   "B15002", # education
#'   "B23025", # unemployed
#'   "C17002", # low income, poor, etc.
#'   "B19301", # per capita income
#'   "B25032", # owned units vs rented units (occupied housing units, same universe as B25003)
#'   "B28003", # no broadband
#'   "B27010", # no health insurance
#'   "C16002", # (language category and) % of households limited English speaking (lingiso) "https://data.census.gov/table/ACSDT5Y2023.C16002"
#'   "B16004", # (language category and) % of residents (not hhlds) speak no English at all "https://data.census.gov/table/ACSDT5Y2023.B16004"
#'   ####### TRACT ONLY:
#'   #   used by EJSCREEN but only available at tract resolution:
#'   "C16001", # languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc.  "https://data.census.gov/table/ACSDT5Y2023.C16001"
#'   "B18101" # disability -- at tract resolution only ########### #
#' )
#' acstabs2 <- paste0(tables, "_")
#' mytables <- data.table::rbindlist(lapply(acstabs2, function(z) {
#'   x[substr(x$name,1,7) %in% z, ][1, ]
#'   }))
#' print(mytables)
#'
#'   # see details of ALL the variables in these tables
#' # for (i in 1:NROW(mytables)) {
#' #    x[substr(x$name,1,7) %in% substr(mytables[i,]$name,1,7), ] |> print(n=50)
#' # }
#'
#'  # disability is by tract only:
#'
#'  cbind(unique(grep("disab", x$concept, value = T, ignore.case = T) ))
#'  # x[substr(x$name,1,6) %in% "B18101" & x$geography %in% "block group", ] |> print(n=50) # none
#'  x[substr(x$name,1,7) %in% "B18101_"  , ] |> print(n=50)
#'  ```
#' @param variables Vector of variables - see get_acs from tidycensus package
#' @param table  see get_acs from tidycensus package.
#'
#'   EJSCREEN-relevant key tables are listed in the details section here.
#'
#' @param year optional, e.g., 2024 means ACS5 data covering 2020-2024.
#'   Tries to use the most recent available if not specified.
#' @param cache_table  see [tidycensus::get_acs()]
#' @param output   see get_acs from tidycensus package
#' @param state Default is 2-character abbreviations, vector of all US States, DC, and PR.
#' @param county   see get_acs from tidycensus package
#' @param zcta   see get_acs from tidycensus package
#' @param geometry   see get_acs from tidycensus package
#' @param keep_geo_vars   see get_acs from tidycensus package
#' @param summary_var   see get_acs from tidycensus package
#' @param key   see get_acs from tidycensus package
#' @param moe_level   see get_acs from tidycensus package
#' @param survey   see get_acs from tidycensus package
#' @param show_call   see get_acs from tidycensus package
#' @param geography "block group"
#'   (but it also will recognize you meant "block group" or "tract"
#'    if you omit the space or capitalize by accident)
#' @param dropname whether to drop the column called NAME
#' @param ...   see get_acs from tidycensus package
#'
#' @examples
#' \dontrun{
#' ## All states, full table
#' # newvars <- acs_bybg(table = "B01001")
#'
#' ## One state, some variables
#' newvars <- acs_bybg(c(pop = "B01001_001", y = "B01001_002"), state = "DC")
#'
#' ## Format new data to match rows of blockgroupstats
#'
#' data.table::setnames(newvars, "GEOID", "bgfips")
#' dim(newvars)
#' newvars <- newvars[blockgroupstats[,.(bgfips, ST)], ,  on = "bgfips"]
#' dim(blockgroupstats)
#' dim(newvars)
#' newvars
#' newvars[ST == "DC", ]
#'
#' ## Calculate a new indicator for each blockgroup, using ACS data
#'
#' mystates = c("DC", 'RI')
#' newvars <- acs_bybg(variables = c("B01001_001", paste0("B01001_0", 31:39)),
#'   state = mystates)
#' data.table::setnames(newvars, "GEOID", "bgfips")
#' newvars[, ST := fips2stateabbrev(bgfips)]
#' names(newvars) <- gsub("E$", "", names(newvars))
#'
#' # provide formulas for calculating new indicators from ACS raw data:
#' formula1 <- c(
#'  " pop = B01001_001",
#'  " age1849female = (B01001_031 + B01001_032 + B01001_033 + B01001_034 +
#'       B01001_035 + B01001_036 + B01001_037 + B01001_038 + B01001_039)",
#'  " pct1849female = ifelse(pop == 0, 0, age1849female / pop)"
#'  )
#' newvars <- calc_ejam(newvars, formulas = formula1,
#'   keep.old = c("bgid", "ST", "pop", 'bgfips'))
#'
#' newvars[, pct1849female := round(100 * pct1849female, 1)]
#' mapfast(newvars[1:10,], column_names = colnames(newvars),
#'      labels = gsub('pct1849female', 'Women 18-49 as % of residents',
#'               gsub('age1849female', 'Count of women ages 18-49',
#'              fixcolnames(colnames(newvars), 'r', 'long'))))
#'
#'
#' ## ACS tables and variables most relevant to EJSCREEN
#'
#' acsinfo <- tidycensus::load_variables(2022, "acs5")
#' ejscreentables <- c("B01001", # sex and age / basic population counts
#'             "B03002", # race with hispanic ethnicity
#'             "B02001", # race without hispanic ethnicity
#'             "B15002", # education
#'
#'             "C16002", # language/ lingiso
#'             "B16004", # language category and English not at all
#'
#'             "C17002", # low income, poor, etc.
#'             "B25034", # pre1960, for lead paint indicator
#'             "B23025", # unemployed
#'
#'             "B25032", # owned units vs rented units # ***
#'             "B25003", # owned vs rented             # ***
#'
#'             "B28003", # no broadband
#'             "B27010" ,  # no health insurance
#'
#'           "B18101" # disability -- at tract resolution only ########### #
#' )
#'
#' acstabs2 <- paste0(ejscreentables, "_")
#' acsinfo$table = gsub("_.*", "", acsinfo$name)
#' myacsinfo <- acsinfo[acsinfo$table %in% ejscreentables, ]
#' mytables <- data.table::rbindlist(lapply(ejscreentables, function(z) {acsinfo[acsinfo$table %in% z, ][1,]}))
#' ejscreen_tables <-  mytables$table # same as ejscreentables
#'
#' myvars <- myacsinfo$name # 184 variables among 8 tables
#'
#' if ("want to run example that takes >15 minutes" == "yes") {
#'   # VERY SLOWLY download data for all these tables
#'   # in ALL STATES and DC and PR but not Island Areas
#'   mystates <- stateinfo2[stateinfo2$is.usa.plus.pr, ]$ST
#'   ## PR must be handled separately. see e.g., B05001PR
#'   mystates = mystates[mystates != "PR"]
#'   ### takes time to download each table for each state:
#'   system.time({
#'     newvars <- acs_bybg(variables = myvars, state = mystates)
#'   })
#'   data.table::setnames(newvars, "GEOID", "bgfips")
#'   newvars[, ST := fips2stateabbrev(bgfips)]
#'   names(newvars) <- gsub("E$", "", names(newvars))
#'   dim(newvars) #  239781 rows (bgs),   370 columns (variable estimates and margin of error values)
#'   t(head(newvars))
#'   ejscreen_acs = newvars
#'   save(ejscreen_acs, file="ejscreen_acs.rda")
#' }
#' }
#' @return A [data.table](https://r-datatable.com) (not tibble, and not just a data.frame)
#'
#' @export
#'
acs_bybg <- function(
    variables = c(pop = "B01001_001"),
    table = NULL, # can only specify one table per call, but can specify a vector of variables from multiple tables
    year = NULL,
    cache_table = FALSE,
    output = "wide",
    state = stateinfo$ST, # has DC, PR, but not "AS" "GU" "MP" "UM" "VI" # state.abb from datasets pkg would lack DC and PR # stateinfo2 would add "US"
    county = NULL,
    zcta = NULL,
    geometry = FALSE,
    keep_geo_vars = FALSE,
    summary_var = NULL,
    key = NULL, ######################## #
    moe_level = 90,
    survey = "acs5",
    show_call = FALSE,
    geography = "block group",
    dropname = TRUE,
    ...
)  {

  stopifnot(length(geography) == 1)
  if (tolower(geography) %in% c("blockgroup", "blockgroups", "block groups")) {geography <- "block group"}
  if (tolower(geography) %in% c("tract", "tracts")) {geography <- "tract"}
  if (missing(year) || is.null(year)) {
    year <- acs_endyear(guess_as_of = Sys.Date(), guess_always = TRUE, # to get the latest published by census bureau which may be newer than what is in latest release of EJSCREEN/EJAM
                       guess_census_has_published = TRUE)
    yr_was_inferred = TRUE
  } else {
    yr_was_inferred = FALSE
  }
  year <- as.numeric(year)
  default_available = formals(tidycensus::get_acs)$year
  if (year > default_available) {
    yr_source = ifelse(yr_was_inferred, "assumed/guessed to be available", "requested")
    msg = paste0("Data for the year ", year, " does not seem to be supported yet by tidycensus package, since the default year in tidycensus::get_acs() is only ", default_available, " which is not as recent as the ", year, " data that was ", yr_source, ".")
    if (!yr_was_inferred) {
      stop(msg)
    } else {
      warning(msg)
      message("Using data for the year ", default_available, " instead of the guessed year of ", year, ".")
      year <- default_available
    }
  }

  # NEED API KEY POSSIBLY, FOR LARGE QUERIES AT LEAST

  if (nchar(Sys.getenv("CENSUS_API_KEY")) == 0) {
    warning("envt var CENSUS_API_KEY not found - tidycensus::get_acs() may require having set up a census api key - see ?tidycensus::census_api_key  ")
  }

  # if (!exists("get_acs")) {  # now in Imports of DESCRIPTION file
  #   stop('requires the tidycensus package be installed and attached')
  #   } else {
  if (!is.null(table) && !is.null(variables)) {
    warning( "Specify either variables or table parameter; they cannot be combined. Using variables and ignoring table parameter")
    table = NULL
  }
  # x <- load_variables(year, survey) # slow and requires tidycensus package
  # print(x[grepl("b01001_", x$name, ignore.case = T) & grepl("Female", x$label) & grepl("group", x$geography), ], n = 25)
  allstates <- list()

  for (i in 1:length(state)) {
    MYST <- state[i]
    ## probably will stop/error if we try this and no key exists. NULL probably tries to use default key assuming one is set
    bgs <- tidycensus::get_acs(geography = geography,   # requires tidycensus package - refer to it like this
                               variables = variables,
                               table = table, # Only one table may be requested per call.
                               cache_table = cache_table,
                               year = year,
                               output = output,
                               state = MYST,
                               county = county,
                               zcta = zcta,
                               geometry = geometry,
                               keep_geo_vars = keep_geo_vars,
                               summary_var = summary_var,
                               key = key,
                               moe_level = moe_level,
                               survey = survey,
                               show_call = show_call,
                               ...)
    data.table::setDT(bgs)
    if (dropname) {
      bgs[, NAME := NULL]
    }
    # bgs[ , pct1849f := age1849 / pop]
    # bgs[is.na(pct1849f), pct1849f := NA] # to be NA instead of NaN
    allstates[[i]] <- bgs
  }

  allstates <- data.table::rbindlist(allstates)
  return(allstates)
  # }
  # ?get_acs
}
##################################################################### #


# # EXAMPLE OF SCRIPT TO GET
# # PERCENT OF POPULATION THAT IS WOMEN OF CHILD BEARING AGE
# # FOR ALL US BLOCKGROUPS FROM ACS (but missing PR, VI, other Island Areas probably!)
# # Use ages 18-49, not the more widely used 16-49, since ages 15-17 are all in a single bin.
#
# library(data.table)
# library(tidycensus) # NEED API KEY, FOR LARGE QUERIES AT LEAST
#
# x <- tidycensus::load_variables(2022, "acs5")
# # print(x[grepl("b01001_", x$name, ignore.case = T) & grepl("Female", x$label) & grepl("group", x$geography), ], n = 25)
# allstates <- list()
#
# for (i in 1:length(stateinfo$ST)) {  # but it may not work for DC and PR ?
#   MYST <- stateinfo$ST[i]
#   y <- get_acs(geography = "block group",  output = "tidy",
#                variables = c(
#                  "B01001_001", paste0("B01001_0", 31:39)),
#                state = MYST)
#   setDT(y)
#   bgs     <-  y[variable != "B01001_001" , .(age1849 = sum(estimate)), by = "GEOID"]
#   totals  <-  y[variable == "B01001_001" , .(pop = sum(estimate)),     by = "GEOID"]
#   bgs <- merge(bgs, totals, by = "GEOID")
#   setDT(bgs)
#   bgs[ , pct1849f := age1849 / pop]
#   bgs[is.na(pct1849f), pct1849f := NA] # to be NA instead of NaN
#   allstates[[i]] <- bgs
# }
#
# allstates <- data.table::rbindlist(allstates)
# pctfemale_18_to_49 <- allstates
# rm(allstates, x, MYST, bgs, totals, i, y)
#
# save(pctfemale_18_to_49, file = "pctfemale_18_to_49.rda")
##################################################################### #


# #### COMPARE acs_bybg() TO USING
if (FALSE) {


  options( timeout= 60*3)

    x = list()
    for (i in 1:length(ejscreentables)) {
      print(system.time({
      x[[i]] =  try( ACSdownload::get_acs_new(tables = ejscreentables[i], yr = 2022, return_list_not_merged = FALSE))
      }))
      assign(paste0("x",i), x[[i]])
      assign('y', x[[i]])
      save(y, file = paste0('~/Downloads/', paste0("x",i),'.rda'))
      cat("did ", i, '\n')
    }




}
