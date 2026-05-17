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

  Vector of variables - see
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)

- table:

  see
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)

  EJSCREEN-relevant key tables are listed in the details section here.

- year:

  optional, e.g., 2024 means ACS5 data covering 2020-2024. Tries to use
  the most recent available if not specified.

- cache_table:

  see
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)

- output:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- state:

  Default is 2-character abbreviations, vector of all US States, DC, and
  PR.

- county:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- zcta:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- geometry:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- keep_geo_vars:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- summary_var:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- key:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- moe_level:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- survey:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- show_call:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

- geography:

  "block group" (but it also will recognize you meant "block group" or
  "tract" if you omit the space or capitalize by accident)

- dropname:

  whether to drop the column called NAME

- ...:

  see get_acs() from the [tidycensus
  package](https://walker-data.com/tidycensus/)

## Value

A [data.table](https://r-datatable.com) (not tibble, and not just a
data.frame)

## Details

See newer ACSdownload::get_acs_new() as used in
calc_blockgroupstats_acs() etc., which will download ACS nationwide data
by table instead of using acs_bybg(), which queried the API
state-by-state.

acs_bybg() probably requires [getting and specifying an API key for
Census Bureau](https://api.census.gov/data/key_signup.html) ! (at least
if query is large). see [tidycensus package
help](https://walker-data.com/tidycensus/) envt var CENSUS_API_KEY

NOTES ON KEY TABLES IN ACS THAT ARE RELEVANT TO EJSCREEN:

    x <- tidycensus::load_variables(acs_endyear(guess_census_has_published = TRUE), "acs5")
      ## tables_ejscreen_acs
    tables = tables_ejscreen_acs
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

     cbind(unique(grep("disab", x$concept, value = TRUE, ignore.case = TRUE) ))
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

acsinfo <- tidycensus::load_variables(acs_endyear(guess_census_has_published = TRUE), "acs5")
# or x = EJAM:::acs_table_info()
ejscreentables <-  as.vector(tables_ejscreen_acs)

acstabs2 <- paste0(ejscreentables, "_")
acsinfo$table = gsub("_.*", "", acsinfo$name)
myacsinfo <- acsinfo[acsinfo$table %in% ejscreentables, ]
mytables <- data.table::rbindlist(lapply(ejscreentables, function(z) {acsinfo[acsinfo$table %in% z, ][1,]}))
ejscreen_tables <-  mytables$table # same as ejscreentables

myvars <- myacsinfo$name #

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
