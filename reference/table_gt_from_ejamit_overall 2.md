# Create a formatted table of results from EJAM overall summary stats

Uses the results_overall element of ejamit() output

## Usage

``` r
table_gt_from_ejamit_overall(
  ejamit_results_1row = NULL,
  type = c("demog", "envt")[1]
)
```

## Arguments

- ejamit_results_1row:

  1-row table in [data.table](https://r-datatable.com) format like
  testoutput_ejamit_100pts_1miles\$results_overall, as would come from
  ejamit(testpoints_10)\$results_overall

- type:

  Must be "demog" or "envt" – Creates one of these at a time

## Value

Provides table in gt format from the R package called gt

## Examples

``` r
 x <- table_gt_from_ejamit_overall(testoutput_ejamit_100pts_1miles$results_overall)
```
