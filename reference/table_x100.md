# utility to multiply certain percentage columns by 100 to convert 0-1.00 into 0-100

multiplies some data to rescale percentages stored as 0 to 1, into 0-100

## Usage

``` r
table_x100(df, cnames = names_pct_as_fraction_ejamit)
```

## Arguments

- df:

  data.frame but can be data.table

- cnames:

  colnames in df of indicators to multiply by 100, like those in

  names_pct_as_fraction_ejamit,

  names_pct_as_fraction_blockgroupstats

## Value

df with data in specified columns multiplied by 100

## See also

[`table_signif_round_x100()`](https://ejanalysis.github.io/EJAM/reference/table_signif_round_x100.md)
[`table_signif()`](https://ejanalysis.github.io/EJAM/reference/table_signif.md)
[`table_round()`](https://ejanalysis.github.io/EJAM/reference/table_round.md)
`table_x100()`

## Examples

``` r
out <- testoutput_ejamit_10pts_1miles
mytable <- out$results_bysite[1:2, ..names_these]
EJAM:::table_signif_round_x100(mytable)
# same as this:
EJAM:::table_signif(
  EJAM:::table_round(
    EJAM:::table_x100(
      mytable, names_pct_as_fraction_ejamit
    )
  )
)

 y = data.frame(pctlowinc = 1:2, pctpre1960 = 1:2, avg.pctunemployed = 1:2, avg.pctpre1960 = 1:2)

 EJAM:::table_x100(y, names_pct_as_fraction_blockgroupstats)
 EJAM:::table_x100(y, names_pct_as_fraction_ejamit)
 cat("\n\n")
 names_pct_as_fraction_blockgroupstats
 names_pct_as_fraction_ejamit
 cat("\n\n")
 ytable = data.table::data.table(pctlowinc = 1:2, pctpre1960 = 1:2,
                     avg.pctunemployed = 1:2,
                     avg.pctpre1960 = 1:2)

 EJAM:::table_x100(ytable, names_pct_as_fraction_blockgroupstats)
 EJAM:::table_x100(ytable, names_pct_as_fraction_ejamit)
 cat("\n\n")
 y
 ytable
```
