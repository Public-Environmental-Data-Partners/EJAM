# Use site name text search to see FRS Facility Registry Service data on those EPA-regulated sites

VERY SLOW search within PRIMARY_NAME of facilities for matching text

## Usage

``` r
frs_from_sitename(sitenames, ignore.case = TRUE, fixed = FALSE)
```

## Arguments

- sitenames:

  one or more strings in a vector, which can be regular expressions or
  query for exact match using fixed=TRUE

- ignore.case:

  logical, search is not case sensitive by default (unlike
  [`grepl()`](https://rdrr.io/r/base/grep.html) default)

- fixed:

  see [`grepl()`](https://rdrr.io/r/base/grep.html), if set to TRUE it
  looks for only exact matches

## Value

relevant rows of the table in [data.table](https://r-datatable.com)
format called [frs](https://ejanalysis.github.io/EJAM/reference/frs.md),
which has column names that are "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME"
"NAICS" "PGM_SYS_ACRNMS"

## Examples

``` r
# \donttest{
 # very slow
 x=frs_from_sitename
 nrow(x)
 head(x)
# }
```
