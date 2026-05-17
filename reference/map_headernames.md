# map_headernames provides metadata about all indicators in EJSCREEN / EJAM

map_headernames provides metadata about all indicators in EJSCREEN /
EJAM

## Usage

``` r
map_headernames
```

## Format

An object of class `data.frame` with 760 rows and 64 columns.

## Details

This is an IMPORTANT TABLE and many functions rely on it.

It provides metadata or information about each variable (indicator),
such as the following:

- names as used in the R code ("rname"), which is the "canonical" name
  for each variable, and is used in the R code and in the EJAM API

- names as used in short labels of graphics

- names as used in table headers (long versions to provide full
  descriptions of the variables)

- names as used in EJSCREEN-specific files/code/app
  (`ejscreen_indicator`)

- row-type flags that indicate if a variable is in various categories or
  types

- main category of variable or "varlist" for purposes of grouping
  similar ones like those in names_e, names_d, or names_d_pctile

- info about rounding decimal places, significant digits, percentage
  format, etc.

- method for aggregating the value across blockgroups (sum, weighted
  mean, what is the weight, etc.)

- other information like sort order for certain purposes, etc.

It was originally created from a spreadsheet of the same name in the
`data-raw` folder, but is now being updated or modified directly.

Several helper functions are used to query it, such as
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
and
[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md).

You can see examples of what it contains below.

`data.frame(t(map_headernames[1:2, ]))`

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
[`varin_map_headernames()`](https://public-environmental-data-partners.github.io/EJAM/reference/varin_map_headernames.md)
[`varlist2names()`](https://public-environmental-data-partners.github.io/EJAM/reference/namesbyvarlist.md)

## Examples

``` r
  #   See how many variables are on each list, for example:
  # \donttest{
  data.table::setDT(data.table::copy(map_headernames))[, .(
    variables = .N,
    has_csvname = sum(csvname != ""),
    has_ejscreen_indicator = sum(ejscreen_indicator != ""),
    has_ejscreen_apinames_old = sum(ejscreen_apinames_old != ""),
    has_ejam_apinames = sum(ejam_apinames != ""),
    has_acsname = sum(acsname != "")
    ),
 keyby = c("raw_pctile_avg", "DEJ", "ratio.to", "pctile.", "avg.",  "varlist" )]

 # Which sources provide which key variables or indicators?

 some <- unique(map_headernames$rname[map_headernames$varlist != ""
   & map_headernames$varlist != "x_anyother"])

 info <- cbind(
   varinfo(some, info = c('ejscreen_apinames_old', 'csv', 'acs', 'varlist')),
   usastats = some %in% names(usastats),
   statestats = some %in% names(statestats))
 info <- info[nchar(paste0(info$ejscreen_apinames_old, info$csv, info$acs)) > 0, ]
 info

 # any others

 some <- unique(map_headernames$rname[map_headernames$varlist != ""
   & map_headernames$varlist == "x_anyother"])

 info <- cbind(
   varinfo(some, info = c('ejscreen_apinames_old', 'csv', 'acs', 'varlist')),
   usastats = some %in% names(usastats),
   statestats = some %in% names(statestats))
 info <- info[nchar(paste0(info$ejscreen_apinames_old, info$csv, info$acs)) > 0, ]
 info
  # }
```
