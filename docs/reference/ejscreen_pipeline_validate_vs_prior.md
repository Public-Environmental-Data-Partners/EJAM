# Compare a new pipeline dataset to a prior version

Compare a new pipeline dataset to a prior version

## Usage

``` r
ejscreen_pipeline_validate_vs_prior(
  new_dt,
  old_dt,
  use_waldo = FALSE,
  verbose = TRUE
)
```

## Arguments

- new_dt:

  data.frame or data.table created by the new pipeline.

- old_dt:

  prior or reference data.frame or data.table to compare against.

- use_waldo:

  logical. If TRUE and the `waldo` package is installed, also include
  `waldo::compare(old_dt, new_dt)` output in the returned object.

- verbose:

  logical. If TRUE, print a concise text summary.

## Value

Invisibly returns a list with class `ejam_pipeline_prior_validation`.

## Details

This diagnostic helper is intended for annual EJSCREEN/EJAM data
updates. It compares a newly created table, such as `bg_acsdata`,
`blockgroupstats`, `usastats`, or `statestats`, with a prior or
reference version of the same table. It reports row/column count
differences, column-name differences, `bgfips` set/order differences
when `bgfips` is available, metadata gaps in
[map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md),
and value differences in shared columns.

Differences are reported as warnings and in the returned object. They
are not fatal unless the inputs are invalid.
