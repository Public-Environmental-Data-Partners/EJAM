# Summarize how many rows have AT LEAST N columns at or above (or below) various thresholds

See colcounter_summary() for details and examples

## Usage

``` r
colcounter_summary_cum(
  x,
  thresholdlist,
  or.tied = TRUE,
  na.rm = TRUE,
  below = FALSE,
  one.cut.per.col = FALSE
)
```

## Arguments

- x:

  Data.frame or matrix of numbers to be compared to threshold value,
  like percentiles for example.

- thresholdlist:

  vector of numeric threshold values to compare to

- or.tied:

  if TRUE, include ties (value in x equals threshold)

- na.rm:

  if TRUE, used by colcounter to count only the non-NA columns in given
  row

- below:

  if TRUE, count x below threshold not above threshold

- one.cut.per.col:

  if FALSE, compare each threshold to all of x. If TRUE, specify one
  threshold to use for each column.

## See also

[`colcounter_summary_all()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_all.md)
[`colcounter_summary()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary.md)
`colcounter_summary_cum()`
[`colcounter_summary_pct()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_pct.md)
[`colcounter_summary_cum_pct()`](https://ejanalysis.github.io/EJAM/reference/colcounter_summary_cum_pct.md)
