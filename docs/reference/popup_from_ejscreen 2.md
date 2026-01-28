# Map popups - Create the popup text for maps of EJ results

This creates the HTML text that appears in map popups.

## Usage

``` r
popup_from_ejscreen(
  out,
  linkcolnames = sapply(EJAM:::global_or_param("default_reports"), function(x) x$header),
  verbose = FALSE,
  site_method = NULL
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

- site_method:

  optional word or phrase about the sites or how they were selected.

  The `site_method` parameter can be used as-is by
  [`create_filename()`](https://ejanalysis.github.io/EJAM/reference/create_filename.md)
  to be part of the saved file name. It can also be used by the shiny
  app to add informational text in the header of a report, via
  [`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)
  and related helper functions like
  [`report_residents_within_xyz()`](https://ejanalysis.github.io/EJAM/reference/report_residents_within_xyz.md)
  or via \[ejam2excel() and related helper functions.

  The `site_method` parameter provides more detailed info about how
  sites were specified in the web app, beyond what `sitetype` provides
  (e.g., from `ejamit()$sitetype` or `ejamitout$sitetype`):

  - sitetype can be "latlon", "fips", or "shp"

  - site_method can be one of these: "latlon", "SHP", "FIPS",
    "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT"

  The shiny app server provides `site_method` from the reactive called
  submitted_upload_method() which is much like the one called
  current_upload_method().

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
