# top N sites account for what percent of residents?

What fraction of total population is accounted for by the top N places?

## Usage

``` r
popshare_at_top_n(pop, n = 10, astext = FALSE, dig = 0)
```

## Arguments

- pop:

  vector of population totals across places, like
  out\$results_bysite\$pop where out is the output of ejamit()

- n:

  the number of places to consider

- astext:

  if TRUE, return text of description of results

- dig:

  rounding digits for text output

## Value

A fraction of 1

## See also

[`popshare_at_top_x_pct()`](https://ejanalysis.github.io/EJAM/reference/popshare_at_top_x_pct.md)
`popshare_at_top_n()`
[`popshare_p_lives_at_what_n()`](https://ejanalysis.github.io/EJAM/reference/popshare_p_lives_at_what_n.md)
[`popshare_p_lives_at_what_pct()`](https://ejanalysis.github.io/EJAM/reference/popshare_p_lives_at_what_pct.md)

## Examples

``` r
 x <- testoutput_ejamit_100pts_1miles$results_bysite
 popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
 popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
 popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
 popshare_at_top_n(           x$pop, n = c(1, 5, 10))
```
