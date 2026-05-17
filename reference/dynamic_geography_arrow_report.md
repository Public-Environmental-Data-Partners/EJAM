# Report consistency of dynamic geography Arrow datasets

Checks the blockgroup- and block-level Arrow datasets that support
proximity analysis against a reference blockgroup universe. This is used
during the annual EJSCREEN data update to decide whether
geography-coupled Arrow files are still compatible with the current
`blockgroupstats` data.

## Usage

``` r
dynamic_geography_arrow_report(
  folder_local_source = NULL,
  blockgroupstats_ref = NULL,
  datasets = c("bgid2fips", "blockwts", "blockpoints", "quaddata", "blockid2fips"),
  silent = TRUE
)

dynamic_geography_blockgroupstats_ref()
```

## Arguments

- folder_local_source:

  folder containing `.arrow` files. Defaults to the installed EJAM
  package data folder.

- blockgroupstats_ref:

  optional data frame with at least `bgfips`; if omitted, the currently
  available package `blockgroupstats` is used.

- datasets:

  dynamic geography Arrow dataset names to check.

- silent:

  if `FALSE`, print the report.

## Value

A data frame with one row per checked dataset and counts of missing or
extra geography keys.
