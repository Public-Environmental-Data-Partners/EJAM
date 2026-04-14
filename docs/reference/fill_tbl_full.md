# Create full demog. or envt. HTML table of indicator rows

Create full demog. or envt. HTML table of indicator rows

## Usage

``` r
fill_tbl_full(
  output_df,
  title = "EJSCREEN environmental and socioeconomic indicators data",
  title_top_row = "",
  show_ratios_in_report = TRUE
)
```

## Arguments

- output_df, :

  single row of results table from doaggregate - either results_overall
  or one row of bysite

- title:

  Text of overall title of report table

- title_top_row:

  text for upper left cell, header row. Can be blank, or e.g., 'SELECTED
  VARIABLES'

- show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values

## See also

used by
[`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md)
