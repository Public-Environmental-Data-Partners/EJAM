# how many sites account for P percent of residents?

how many sites account for P percent of residents?

## Usage

``` r
popshare_p_lives_at_what_n(pop, p, astext = FALSE, dig = 0)
```

## Arguments

- pop:

  vector of population totals across places, like
  out\$results_bysite\$pop where out is the output of ejamit()

- p:

  share of population (0-1, fraction), vector of one or more

- astext:

  if TRUE, return text of description of results

- dig:

  rounding digits for text output

## Value

vector of numbers of sites, or text about that

## See also

[`popshare_at_top_x_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_at_top_x_pct.md)
[`popshare_at_top_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_at_top_n.md)
`popshare_p_lives_at_what_n()`
[`popshare_p_lives_at_what_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_p_lives_at_what_pct.md)

## Examples

``` r
 x <- testoutput_ejamit_10pts_1miles$results_bysite[4:9, ]
 # x <- testoutput_ejamit_1000pts_1miles$results_bysite
 x <- x[!is.na(x$pop), ] # set pop to zero or just remove sites where pop was NA since area too small to determine accurately
 cbind(pctofsites = round((1:length(x$pop)) / length(x$pop), 2),
   pctofpop = round(cumsum(sort(x$pop, decreasing = T)) / sum(x$pop, na.rm=T), 2))

 popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
 popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE, atleast_not_exact=FALSE)
 popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=F)
 popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=F, atleast_not_exact=FALSE)

 ## for more than one p
 popshare_p_lives_at_what_pct(x$pop, p = c(0.50, 0.67, 0.80, 0.95) )

 popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
 popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
 popshare_at_top_n(           x$pop, n = c(1, 5, 10))
```
