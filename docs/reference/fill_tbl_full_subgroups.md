# Create full demog subgroup/ language/ health/ community/ etc. HTML table of indicator rows

Create full demog subgroup/ language/ health/ community/ etc. HTML table
of indicator rows

## Usage

``` r
fill_tbl_full_subgroups(
  output_df,
  extratable_title = "",
  extratable_title_top_row = "ADDITIONAL INFORMATION",
  list_of_sections = NULL,
  extratable_show_ratios_in_report = TRUE,
  hide_missing_rows_for = names_d_language
)
```

## Arguments

- output_df:

  single row of results table from doaggregate or possibly ejamit(),
  either \$results_overall or one row of \$results_bysite, where
  colnames are indicators like pop, pctpoor, etc.

- extratable_title:

  Text of overall title text for report table, above the actual table
  not in the table

- extratable_title_top_row:

  title text inside the top left cell of the table, in the header row

- list_of_sections:

  named list of vectors, where each name is text phrase that is title of
  a section of the table, and each vector is the vector of colnames of
  output_df that are indicators to show in that section.

- extratable_show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values

- hide_missing_rows_for:

  only for the indicators named in this vector, leave out rows in table
  where raw value is NA, as with many of names_d_language

## See also

used by
[`build_community_report()`](https://ejanalysis.github.io/EJAM/reference/build_community_report.md)
