# Make boxplot of ratios to US averages

Make boxplot of ratios to US averages

## Usage

``` r
ejam2boxplot_ratios(
  ejamitout,
  radius,
  varnames = c(names_d, names_d_subgroups),
  main = NULL,
  maxratio = 5
)
```

## Arguments

- ejamitout:

  output from an EJAM analysis, like from
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- radius:

  buffer radius used for an analysis

- varnames:

  currently only works with names_d and names_d_subgroups

- main:

  can specify a main title to use instead of default

- maxratio:

  largest ratio to plot in case of outliers, so plot looks better

## Value

ggplot object

## Details

IMPORTANT: NOTE this uses the ratio at each site USING THE AVERAGE
RESIDENT AT THAT SITE, SO A BOXPLOT SHOWS ONE DOT PER SITE AND THE
BOXPLOT IS NOT POP WTD MEANING IT SHOWS THE MEDIAN AND 75TH PERCENTILE
SITE NOT RESIDENT, ETC.

## Examples

``` r
ejam2boxplot_ratios(testoutput_ejamit_1000pts_1miles, radius=1)

out <- testoutput_ejamit_100pts_1miles
ejam2boxplot_ratios(out, radius=1)
ejam2boxplot_ratios(out)
## not ## ejam2boxplot_ratios(out$results_bysite)
```
