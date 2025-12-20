# DRAFT EXPERIMENTAL - attempt to make table more flexible / any indicators

Based on just indicator names and a value for each, it tries to fill in
the rest of a summary table's data. and formats this as a data.frame
ready for the next step

## Usage

``` r
table4gt_from_scorevectors(
  varnames_r = names_e,
  varnames_shown = fixcolnames(varnames_r, "r", "long"),
  value = as.vector(usastats_means(varnames_r)),
  state_avg = NULL,
  state_pctile = NULL,
  usa_avg = NULL,
  usa_pctile = NULL,
  state_ratio = NULL,
  usa_ratio = NULL,
  ST = "NY"
)
```

## Arguments

- varnames_r:

  vector of variable names like names_d

- varnames_shown:

  vector like fixcolnames(names_d,'r','short')

- value:

  indicator values for a place or overall

- state_avg:

  indicator values average in State

- state_pctile:

  indicator values as State percentiles

- usa_avg:

  indicator values US average

- usa_pctile:

  indicator values as US percentiles

- state_ratio:

  indicator values as ratio to State average

- usa_ratio:

  indicator values as ratio to US average

- ST:

  State abbreviation like "NY"

## Value

data.frame ready for table_gt_format_step2 ???

## See also

[`table_gt_from_ejamit()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit.md)
[`table_gt_from_ejamit_overall()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit_overall.md)
[`table_gt_from_ejamit_1site()`](https://ejanalysis.github.io/EJAM/reference/table_gt_from_ejamit_1site.md)
[`table_validated_ejamit_row()`](https://ejanalysis.github.io/EJAM/reference/table_validated_ejamit_row.md)
[`table_gt_format_step1()`](https://ejanalysis.github.io/EJAM/reference/table_gt_format_step1.md)
[`table_gt_format_step2()`](https://ejanalysis.github.io/EJAM/reference/table_gt_format_step2.md)
