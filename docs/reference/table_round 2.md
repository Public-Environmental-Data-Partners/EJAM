# Round numbers in a table, each column to appropriate number of decimal places

Round numbers in a table, each column to appropriate number of decimal
places

## Usage

``` r
table_round(x, var = names(x), varnametype = "rname", ...)
```

## Arguments

- x:

  data.frame, table in [data.table](https://r-datatable.com) format, or
  vector with at least some numerical columns, like the results of
  ejamit()\$results_bysite

- var:

  optional, but assumed to be names(x) by default, specifies colnames of
  table or names of vector elements, within x

- varnametype:

  optional, name of column in map_headernames that is looked in for var

- ...:

  passed to
  [`is.numericish()`](https://ejanalysis.github.io/EJAM/reference/is.numericish.md)

## Value

Returns the original x but with appropriate cells rounded off.

## Details

Percentages stored as 0 to 1 rather than 0 to 100 will not be shown
correctly unless adjusted, because rounding info says 0 digits when the
intent is to show 0 digits after the 0-100 percent number.

## See also

[`is.numericish()`](https://ejanalysis.github.io/EJAM/reference/is.numericish.md)
[`table_rounding_info()`](https://ejanalysis.github.io/EJAM/reference/table_rounding_info.md)

## Examples

``` r
  EJAM:::table_round(c(12.123456, 9, NA ), 'pm')

 x <- testoutput_ejamit_10pts_1miles$results_bysite[
   1:2, c('lat','lon', 'pop', names_these, names_these_ratio_to_avg, names_e_pctile),
   with = FALSE
 ]

 EJAM:::table_rounding_info(names(x))

 EJAM:::table_round(x)
```
