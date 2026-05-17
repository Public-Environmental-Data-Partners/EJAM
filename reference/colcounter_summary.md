# Summarize how many rows have N columns at or above (or below) various thresholds?

Like colcounter() or cols.above.count() but will handle multiple
thresholds to compare to each indicator, etc.

Table of counts, percents, cumulative counts, cumulative percents of
places with N, or at least N, of the indicators at or above the
benchmark(s)

## Usage

``` r
colcounter_summary(
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

  if TRUE, used by
  [`colcounter()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter.md)
  to count only the non-NA columns in given row

- below:

  if TRUE, count x below threshold not above threshold

- one.cut.per.col:

  if FALSE, compare each threshold to all of x. If TRUE, specify one
  threshold to use for each column.

## Value

A table of frequency counts

## See also

[`colcounter_summary_all()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_all.md)
`colcounter_summary()`
[`colcounter_summary_cum()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_cum.md)
[`colcounter_summary_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_pct.md)
[`colcounter_summary_cum_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_cum_pct.md)
[`tablefixed()`](https://public-environmental-data-partners.github.io/EJAM/reference/tablefixed.md)

## Examples

``` r
 pdata <- data.frame(a=rep(80,4),b=rep(93,4), col3=c(49,98,100,100))
  ### pdata <- EJAM::blockgroupstats[ , names_e_pctile]
 pcuts <-  5 * (0:20)
EJAM:::colcounter_summary(        pdata, pcuts)
EJAM:::colcounter_summary_pct(    pdata, pcuts)
EJAM:::colcounter_summary_cum(    pdata, pcuts)
EJAM:::colcounter_summary_cum_pct(pdata, pcuts)
EJAM:::colcounter_summary_cum_pct(pdata, 5 * (10:20))
a3 <- colcounter_summary_all(    pdata, pcuts)

x80 <- colcounter(pdata, threshold = 80, or.tied = TRUE)
x95 <- colcounter(pdata, threshold = 95, or.tied = TRUE)
table(x95)
EJAM:::tablefixed(x95, NCOL(pdata))
cbind(at80=EJAM:::tablefixed(x80, NCOL(pdata)), at95=EJAM:::tablefixed(x95, NCOL(pdata)))
```
