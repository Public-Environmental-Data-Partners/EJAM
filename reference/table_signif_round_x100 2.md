# Clean table of EJAM numbers: signif digits, rounding, scaling as 0-100% Does table_signif() and table_round() and fix_pctcols_x100() in one call.

Clean table of EJAM numbers: signif digits, rounding, scaling as 0-100%
Does table_signif() and table_round() and fix_pctcols_x100() in one
call.

## Usage

``` r
table_signif_round_x100(x, cnames = names_pct_as_fraction_ejamit)
```

## Arguments

- x:

  data.frame or data.table

- cnames:

  use default when formatting output like ejamit()\$results_bysite

## Value

table of same shape as x

## See also

`table_signif_round_x100()`
[`table_signif()`](https://ejanalysis.github.io/EJAM/reference/table_signif.md)
[`table_round()`](https://ejanalysis.github.io/EJAM/reference/table_round.md)
[`table_x100()`](https://ejanalysis.github.io/EJAM/reference/table_x100.md)

## Examples

``` r
out <- testoutput_ejamit_10pts_1miles$results_bysite
EJAM:::table_signif_round_x100(
  out[1:2, ..names_these]
)
```
