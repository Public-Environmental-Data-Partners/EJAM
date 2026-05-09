# Cleans/validates EJAM results for 1 place or overall

This is a first step in formatting results in nice tables

## Usage

``` r
table_validated_ejamit_row(ejamit_results_1row = NULL)
```

## Arguments

- ejamit_results_1row:

  1-row table in [data.table](https://r-datatable.com) format like
  testoutput_ejamit_100pts_1miles\$results_overall,

  as would come from ejamit(testpoints_10)\$results_overall

  or a single row of testoutput_ejamit_100pts_1miles\$results_bysite

## Value

Returns the input as a 1-row data.table, indicators etc. in the columns.
If not a 1 row table, or colnames are not what is expected, it returns
correct structure filled with NA values.

## Examples

``` r
  x <- EJAM:::table_validated_ejamit_row(testoutput_ejamit_100pts_1miles$results_bysite[ 1, ])
  x <- EJAM:::table_validated_ejamit_row(testoutput_ejamit_100pts_1miles$results_overall)
```
