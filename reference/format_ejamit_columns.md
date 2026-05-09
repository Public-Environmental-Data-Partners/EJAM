# Format ejamit results for use in tables, charts, etc.

Applies rounding, sigfig, and percentage info to display columns of
ejamit using map_headernames

## Usage

``` r
format_ejamit_columns(df, nms = c())
```

## Arguments

- df:

  table in [data.table](https://r-datatable.com) format of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  results,

- nms, :

  name(s) of columns referring to EJAM indicators, such as "Demog.Index'

## Value

a named vector with formatted values, corresponding to valid column
names provided

## See also

Note: \*\*\* overlaps with/could replace with
[`table_signif_round_x100()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_signif_round_x100.md)

## Examples

``` r
  # x <- ejamit(testpoints_10, radius = 1)
  x <- testoutput_ejamit_10pts_1miles
  EJAM:::format_ejamit_columns(x$results_overall, 'Demog.Index')
  EJAM:::format_ejamit_columns(x$results_overall, c('Demog.Index', 'no2'))
  EJAM:::format_ejamit_columns(x$results_overall, names_d)
```
