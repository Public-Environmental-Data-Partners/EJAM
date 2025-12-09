# Round numbers in a table, each column to appropriate number of significant digits

Round numbers in a table, each column to appropriate number of
significant digits

## Usage

``` r
table_signif(dat, digits = NULL)
```

## Arguments

- dat:

  data.frame or table in [data.table](https://r-datatable.com) format of
  numbers

- digits:

  vector as long as number of columns in dat, or use default which is to
  get the number of significant digits from varinfo(colnames(dat),
  'sigfigs')\$sigfigs which gets it from map_headernames dataset of
  metadata on EJAM / EJSCREEN indicators.

## Value

table same size as dat

## See also

[`table_signif_round_x100()`](https://ejanalysis.github.io/EJAM/reference/table_signif_round_x100.md)
`table_signif()`
[`table_round()`](https://ejanalysis.github.io/EJAM/reference/table_round.md)
[`table_x100()`](https://ejanalysis.github.io/EJAM/reference/table_x100.md)

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
```
