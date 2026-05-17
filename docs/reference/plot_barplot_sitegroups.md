# barplot comparing groups of sites on 1 indicator, based on table of grouped site data

barplot comparing groups of sites on 1 indicator, based on table of
grouped site data

## Usage

``` r
plot_barplot_sitegroups(
  results_bytype,
  varname = "Demog.Index",
  names.arg = NULL,
  main = "Sites by Type",
  xlab = "Groups or Types of Sites",
  ylab = NULL,
  sortby = NULL,
  topn = 10,
  ...
)
```

## Arguments

- results_bytype:

  table like from ejamit_compare_types_of_places()\$results_bytype, a
  table of site groups, one row per type (group), column names at least
  varname (and "ejam_uniq_id" if names.arg not specified)

- varname:

  name of a column in results_bytype, bar height

- names.arg:

  optional vector of labels on the bars, like the types of sites
  represented by each group

- main:

  optional, for barplot

- xlab:

  optional, for barplot

- ylab:

  optional, for barplot, plain English version of varname, indicator
  that is bar height

- sortby:

  set to FALSE if you want to have no sorting, or to an increasing
  vector that provides the sort order

- topn:

  optional, show only the top n groups (site types) – Does not show all
  by default – only shows top n groups.

- ...:

  passed to barplot()

## Value

same as [`barplot()`](https://rdrr.io/r/graphics/barplot.html)

## See also

[`ejam2barplot_sitegroups()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_sitegroups.md)

## Examples

``` r
 out <- ejamit_compare_types_of_places(testpoints_10[1:4, ],
   typeofsite <- c("A", "B", "B", "C"))
   cbind(Rows_or_length = sapply(out, NROW))

 ejam2barplot_sitegroups(out, "sitecount_unique", topn = 3, sortby = FALSE)
```
