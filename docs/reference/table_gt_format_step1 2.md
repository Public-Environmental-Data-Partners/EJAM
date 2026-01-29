# Validate and reshape 1 row of ejamit results to prep for formatting as gt table/report

Reshapes a few columns of a 1 row data.table into a tall multirow
data.frame.

## Usage

``` r
table_gt_format_step1(ejamit_results_1row = NULL, type = "demog")
```

## Arguments

- ejamit_results_1row:

  table in [data.table](https://r-datatable.com) format (or data.frame)
  like testoutput_ejamit_100pts_1miles\$results_overall from something
  like ejamit(testpoints_100, radius = 1)\$results_overall

- type:

  demog or envt to specify which type of table

## See also

[`table_gt_from_ejamit()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit.md)
[`table_gt_from_ejamit_overall()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit_overall.md)
[`table_gt_from_ejamit_1site()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit_1site.md)
[`table_validated_ejamit_row()`](https://ejanalysis.github.io/EJAM/reference/table_validated_ejamit_row.md)
`table_gt_format_step1()`
[`table_gt_format_step2()`](https://ejanalysis.github.io/EJAM/reference/table_gt_format_step2.md)
