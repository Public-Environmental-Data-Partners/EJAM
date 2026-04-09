# Write a residential population subgroup indicator to an html table row

Write a residential population subgroup indicator to an html table row

## Usage

``` r
fill_tbl_row_subgroups(
  output_df,
  Rname,
  longname,
  extratable_show_ratios_in_report
)
```

## Arguments

- output_df, :

  single row of results table from doaggregate - either results_overall
  or one row of bysite

- Rname, :

  variable name of indicator to pull from results, such as 'pm',
  'pctlowinc', 'Demog.Index'

- longname, :

  nicer name of indicator to use in table row; can include HTML
  sub/superscripts

- extratable_show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values

## See also

used by
[`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md)
