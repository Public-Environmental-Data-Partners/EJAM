# Map popups - Create the popup text for maps of EJ results

This creates the HTML text that appears in map popups.

## Usage

``` r
popup_from_ejscreen(
  out,
  linkcolnames = sapply(EJAM:::global_or_param("default_reports"), function(x) x$header),
  verbose = FALSE
)
```

## Arguments

- out:

  like ejamit()\$results_bysite, but also it can be full list from
  ejamit(). The table of raw data in data.frame form, with results of EJ
  analysis.

- linkcolnames:

  Vector of column names in the table that have links to URLs like
  reports about single sites

- verbose:

  TRUE or FALSE, can see more details reported when function is used.

## Value

HTML ready to be used for map popups

## Details

Popup shows up in a window when you click on a site on the map, when
viewing the results of EJ analysis of each site.

THIS IS CURRENTLY HARD CODED TO USE EJSCREEN VARIABLE NAMES.

It provides raw scores (but not for summary indexes) and US and State
percentiles if available:

- some site id info fields if found

- latitude, longitude, and size of area around site

- Indicators like population count, Residential Population Demog.
  Indicator, etc.

- Environmental Indicators

- Summary Indexes

- web link(s) to map or report
