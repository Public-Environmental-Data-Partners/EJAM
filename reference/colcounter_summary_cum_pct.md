# Summarize what percent of rows have AT LEAST N columns at or above (or below) various thresholds

Summarize what percent of rows have AT LEAST N columns at or above (or
below) various thresholds

## Usage

``` r
colcounter_summary_cum_pct(x, thresholdlist, ...)
```

## Arguments

- x:

  Data.frame or matrix of numbers to be compared to threshold value,
  like percentiles for example.

- thresholdlist:

  vector of numeric threshold values to compare to

- ...:

  passed to colcounter_summary_cum() like or.tied=TRUE, na.rm=TRUE,
  below=FALSE, one.cut.per.col=FALSE

## See also

[`colcounter_summary_all()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_all.md)
[`colcounter_summary()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary.md)
[`colcounter_summary_cum()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_cum.md)
[`colcounter_summary_pct()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_pct.md)
`colcounter_summary_cum_pct()`
