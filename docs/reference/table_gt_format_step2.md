# Format a table of demog or envt scores, percentiles, etc. to look similar to EJSCREEN report tables

Format a table of demog or envt scores, percentiles, etc. to look
similar to EJSCREEN report tables

## Usage

``` r
table_gt_format_step2(
  df,
  type = c("demog", "envt")[1],
  my_cell_color = "#dce6f0",
  my_border_color = "#aaaaaa",
  digits_default = 2
)
```

## Arguments

- df:

  A data frame from table_gt_format_step1

  which is just a specific format of key EJAM results.

  It has these columns (but it still works if the first two are omitted
  and user-provided indicators are used - it just names them indicator
  1, indicator 2, etc.):

  varnames_r, varnames_shown, value, state_avg, state_pctile, usa_avg,
  usa_pctile

  and one row per indicator, where varnames_shown are longer indicator
  names for use in report.

  The sort order in this df is ignored! Instead, the variables are shown
  in the same order as shown in EJSCREEN reports, as recorded in
  map_headernames and checked here via varinfo(varnames_r,
  "reportsort"), etc.

  Uses gt R package for formatting.

- type:

  string - must be demog or envt

- my_cell_color:

  color for table cell fill backgrounds, can be given as string ('blue')
  or hex code ('#0070c0')

- my_border_color:

  color for table borders and boundaries, can be given as string
  ('blue') or hex code ('#0070c0')

- digits_default:

  number of digits to round to if not specified for a given indicator
  (rounding info is drawn from map_headernames\$decimals)

## Value

a gt-style table with formatting to closely match EJSCREEN standard
report formatting

## See also

[`table_gt_from_ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_gt_from_ejamit.md)
