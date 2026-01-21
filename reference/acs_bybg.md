# download ACS 5year data from Census API, at blockgroup resolution (slowly if for entire US)

download ACS 5year data from Census API, at blockgroup resolution
(slowly if for entire US)

## Usage

``` r
acs_bybg(
  variables = c(pop = "B01001_001"),
  table = NULL,
  year = NULL,
  cache_table = FALSE,
  output = "wide",
  state = stateinfo$ST,
  county = NULL,
  zcta = NULL,
  geometry = FALSE,
  keep_geo_vars = FALSE,
  summary_var = NULL,
  key = NULL,
  moe_level = 90,
  survey = "acs5",
  show_call = FALSE,
  geography = "block group",
  dropname = TRUE,
  ...
)
```

## Arguments

- variables:

  Vector of variables - see get_acs from tidycensus package

- table:

  see get_acs from tidycensus package.

  EJSCREEN-relevant key tables are listed in the details section here.

- year:

  optional, e.g., 2024 means ACS5 data covering 2020-2024. Tries to use
  the most recent available if not specified.

- cache_table:

  see
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)

- output:

  see get_acs from tidycensus package

- state:

  Default is 2-character abbreviations, vector of all US States, DC, and
  PR.

- county:

  see get_acs from tidycensus package

- zcta:

  see get_acs from tidycensus package

- geometry:

  see get_acs from tidycensus package

- keep_geo_vars:

  see get_acs from tidycensus package

- summary_var:

  see get_acs from tidycensus package

- key:

  see get_acs from tidycensus package

- moe_level:

  see get_acs from tidycensus package

- survey:

  see get_acs from tidycensus package

- show_call:

  see get_acs from tidycensus package

- geography:

  "block group" (but it also will recognize you meant "block group" or
  "tract" if you omit the space or capitalize by accident)

- dropname:

  whether to drop the column called NAME

- ...:

  see get_acs from tidycensus package

## Value

A [data.table](https://r-datatable.com) (not tibble, and not just a
data.frame)

## Details

Probably requires [getting and specifying an API key for Census
Bureau](https://api.census.gov/data/key_signup.html) ! (at least if
query is large). see [tidycensus package
help](https://walker-data.com/tidycensus/) envt var CENSUS_API_KEY

NOTES ON KEY TABLES IN ACS THAT ARE RELEVANT TO EJSCREEN:

    x <- tidycensus::load_variables(2022, "acs5")

    tables = c(
      "B25034", # pre1960, for lead paint indicator (environmental not demographic per se)
      "B01001", # sex and age / basic population counts
      "B03002", # race with hispanic ethnicity
      "B02001", # race without hispanic ethnicity
      "B15002", # education
      "B23025", # unemployed
      "C17002", # low income, poor, etc.
      "B19301", # per capita income
      "B25032", # owned units vs rented units (occupied housing units, same universe as B25003)
      "B28003", # no broadband
      "B27010", # no health insurance
      "C16002", # (language category and) % of households limited English speaking (lingiso) "https://data.census.gov/table/ACSDT5Y2023.C16002"
      "B16004", # (language category and) % of residents (not hhlds) speak no English at all "https://data.census.gov/table/ACSDT5Y2023.B16004"
      ####### TRACT ONLY:
      #   used by EJSCREEN but only available at tract resolution:
      "C16001", # languages detailed list: % of residents (not hhlds) IN TRACT speak Chinese, etc.  "https://data.census.gov/table/ACSDT5Y2023.C16001"
      "B18101" # disability -- at tract resolution only ########### #
    )
    acstabs2 <- paste0(tables, "_")
    mytables <- data.table::rbindlist(lapply(acstabs2, function(z) {
      x[substr(x$name,1,7) %in% z, ][1, ]
      }))
    print(mytables)

      # see details of ALL the variables in these tables
    # for (i in 1:NROW(mytables)) {
    #    x[substr(x$name,1,7) %in% substr(mytables[i,]$name,1,7), ] |> print(n=50)
    # }

     # disability is by tract only:

     cbind(unique(grep("disab", x$concept, value = T, ignore.case = T) ))
     # x[substr(x$name,1,6) %in% "B18101" & x$geography %in% "block group", ] |> print(n=50) # none
     x[substr(x$name,1,7) %in% "B18101_"  , ] |> print(n=50)

## Examples

``` r
if (FALSE) { # \dontrun{
## All states, full table
# newvars <- acs_bybg(table = "B01001")

## One state, some variables
newvars <- acs_bybg(c(pop = "B01001_001", y = "B01001_002"), state = "DC")

## Format new data to match rows of blockgroupstats

data.table::setnames(newvars, "GEOID", "bgfips")
dim(newvars)
newvars <- newvars[blockgroupstats[,.(bgfips, ST)], ,  on = "bgfips"]
dim(blockgroupstats)
dim(newvars)
newvars
newvars[ST == "DC", ]

## Calculate a new indicator for each blockgroup, using ACS data

mystates = c("DC", 'RI')
newvars <- acs_bybg(variables = c("B01001_001", paste0("B01001_0", 31:39)),
  state = mystates)
data.table::setnames(newvars, "GEOID", "bgfips")
newvars[, ST := fips2stateabbrev(bgfips)]
names(newvars) <- gsub("E$", "", names(newvars))

# provide formulas for calculating new indicators from ACS raw data:
formula1 <- c(
 " pop = B01001_001",
 " age1849female = (B01001_031 + B01001_032 + B01001_033 + B01001_034 +
      B01001_035 + B01001_036 + B01001_037 + B01001_038 + B01001_039)",
 " pct1849female = ifelse(pop == 0, 0, age1849female / pop)"
 )
newvars <- calc_ejam(newvars, formulas = formula1,
  keep.old = c("bgid", "ST", "pop", 'bgfips'))

newvars[, pct1849female := round(100 * pct1849female, 1)]
mapfast(newvars[1:10,], column_names = colnames(newvars),
     labels = gsub('pct1849female', 'Women 18-49 as % of residents',
              gsub('age1849female', 'Count of women ages 18-49',
             fixcolnames(colnames(newvars), 'r', 'long'))))


## ACS tables and variables most relevant to EJSCREEN

acsinfo <- tidycensus::load_variables(2022, "acs5")
ejscreentables <- c("B01001", # sex and age / basic population counts
            "B03002", # race with hispanic ethnicity
            "B02001", # race without hispanic ethnicity
            "B15002", # education

            "C16002", # language/ lingiso
            "B16004", # language category and English not at all

            "C17002", # low income, poor, etc.
            "B25034", # pre1960, for lead paint indicator
            "B23025", # unemployed

            "B25032", # owned units vs rented units # ***
            "B25003", # owned vs rented             # ***

            "B28003", # no broadband
            "B27010" ,  # no health insurance

          "B18101" # disability -- at tract resolution only ########### #
)

acstabs2 <- paste0(ejscreentables, "_")
acsinfo$table = gsub("_.*", "", acsinfo$name)
myacsinfo <- acsinfo[acsinfo$table %in% ejscreentables, ]
mytables <- data.table::rbindlist(lapply(ejscreentables, function(z) {acsinfo[acsinfo$table %in% z, ][1,]}))
ejscreen_tables <-  mytables$table # same as ejscreentables

myvars <- myacsinfo$name # 184 variables among 8 tables

if ("want to run example that takes >15 minutes" == "yes") {
  # VERY SLOWLY download data for all these tables
  # in ALL STATES and DC and PR but not Island Areas
  mystates <- stateinfo2[stateinfo2$is.usa.plus.pr, ]$ST
  ## PR must be handled separately. see e.g., B05001PR
  mystates = mystates[mystates != "PR"]
  ### takes time to download each table for each state:
  system.time({
    newvars <- acs_bybg(variables = myvars, state = mystates)
  })
  data.table::setnames(newvars, "GEOID", "bgfips")
  newvars[, ST := fips2stateabbrev(bgfips)]
  names(newvars) <- gsub("E$", "", names(newvars))
  dim(newvars) #  239781 rows (bgs),   370 columns (variable estimates and margin of error values)
  t(head(newvars))
  ejscreen_acs = newvars
  save(ejscreen_acs, file="ejscreen_acs.rda")
}
} # }
```
