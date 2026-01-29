# Create a formatted table of results for 1 site from EJAM

Uses 1 row from the results_bysite part of ejamit() output

## Usage

``` r
table_gt_from_ejamit_1site(...)
```

## Arguments

- ...:

  passed to
  [`table_gt_from_ejamit_overall()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit_overall.md)

## Examples

``` r
 table_gt_from_ejamit_1site(testoutput_ejamit_100pts_1miles$results_bysite[ 1, ])
```
