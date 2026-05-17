# utility to check if a variable or term is in map_headernames and where

utility to check if a variable or term is in map_headernames and where

## Usage

``` r
varin_map_headernames(
  query = "lowinc",
  ignore.case = TRUE,
  exact = FALSE,
  cols_with_names = c("oldname", "ejscreen_apinames_old", "api_synonym", "acsname",
    "csvname", "ejscreen_ftp_names", "ejscreen_indicator", "rname", "topic_root_term",
    "basevarname", "denominator", "shortlabel", "longname", "api_description",
    "acs_description", "varlist")
)
```

## Arguments

- query:

  variable name or fragment (or regular expression) to look for in
  map_headernames columns, looking within just column names listed in
  cols_with_names. Or a vector of query terms in which case this returns
  one column per query term.

- ignore.case:

  optional, like in grepl()

- exact:

  set to TRUE for only exact matches

- cols_with_names:

  optional, colnames of map_headernames to check in

## Value

data.frame of info about where query was found and how many hits.

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)

## Examples

``` r
EJAM:::varin_map_headernames("spanish")
EJAM:::varin_map_headernames("lowinc")
EJAM:::varin_map_headernames("pop")
EJAM:::varin_map_headernames("POV", ignore.case = TRUE)
EJAM:::varin_map_headernames("POV", ignore.case = FALSE)

EJAM:::varin_map_headernames( "traffic.score", exact = TRUE)

EJAM:::varin_map_headernames( "traffic" )

t(EJAM:::varinfo("traffic.score",
  info = c("oldname", "ejscreen_apinames_old", "acsname" ,"csvname",
  "basevarname", 'shortlabel', 'longname', 'varlist')))
```
