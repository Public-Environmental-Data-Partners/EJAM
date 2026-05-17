# Count columns (indicators) with Value (at or) above (or below) threshold Counts high scores, by site

Count columns (indicators) with Value (at or) above (or below) threshold
Counts high scores, by site

## Usage

``` r
colcounter(
  x,
  threshold,
  or.tied = TRUE,
  na.rm = TRUE,
  below = FALSE,
  one.cut.per.col = FALSE
)
```

## Arguments

- x:

  Data.frame or matrix of numbers to be compared to threshold value.

- threshold:

  numeric threshold value to compare to

- or.tied:

  if TRUE, include ties (value in x equals threshold)

- na.rm:

  if TRUE, used by colcounter to count only the non-NA columns in given
  row

- below:

  if TRUE, count x below threshold not above threshold

- one.cut.per.col:

  if FALSE, compare 1 threshold to all of x. If TRUE, specify one
  threshold per column.

## Value

vector of counts as long as NROW(x)

## See also

[`colcounter_summary_all()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_all.md)
[`colcounter_summary()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary.md)
[`colcounter_summary_cum()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_cum.md)
[`colcounter_summary_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_pct.md)
[`colcounter_summary_cum_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_cum_pct.md)

## Examples

``` r
# \donttest{
  pdata <- data.frame(a=rep(80,4), b=rep(93,4), col3=c(49,98,100,100))
# pdata <- data.frame(testoutput_ejamit_10pts_1miles$results_bysite)[ , names_e_pctile]
 pcuts <-  5 * (0:20)
EJAM:::colcounter_summary(        pdata, pcuts)
EJAM:::colcounter_summary_pct(    pdata, pcuts)
EJAM:::colcounter_summary_cum(    pdata, pcuts)
EJAM:::colcounter_summary_cum_pct(pdata, pcuts)
EJAM:::colcounter_summary_cum_pct(pdata, 5 * (10:20))

x80 <- EJAM:::colcounter(pdata, threshold = 80, or.tied = TRUE)
x95 <- EJAM:::colcounter(pdata, threshold = 95, or.tied = TRUE)
table(x95)
EJAM:::tablefixed(x95, NCOL(pdata))
cbind(at80=EJAM:::tablefixed(x80, NCOL(pdata)),
      at95=EJAM:::tablefixed(x95, NCOL(pdata)))
  # }
```
