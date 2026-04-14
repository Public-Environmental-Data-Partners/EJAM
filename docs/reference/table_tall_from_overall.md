# Format the results_overall part of the output of ejamit() or doaggregate()

Take a quick look at results in the RStudio console

## Usage

``` r
table_tall_from_overall(results_overall, longnames = NULL)
```

## Arguments

- results_overall:

  table in [data.table](https://r-datatable.com) format of 1 row, from
  output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  or
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- longnames:

  vector of names of variables in results_overall, from output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  or doaggregate()

## Value

data.frame with one indicator per row

## Examples

``` r
 EJAM:::table_tall_from_overall(testoutput_ejamit_10pts_1miles$results_overall)
 EJAM:::table_tall_from_overall(testoutput_ejamit_10pts_1miles$results_bysite[1, ])
```
