# Not used/OBSOLETE. For the outputs of the old ejscreenit function, was used to get boxplots of Residential Population Percentages across sites as ratios to US means

boxplots show range of scores here vs range in US overall

## Usage

``` r
plot_boxplot_ratios(
  x,
  selected_dvar_colname = varlist2names("names_d")[1],
  selected_dvar_nicename = selected_dvar_colname,
  towhat_nicename = "US average",
  maxratio = 5,
  wheretext = "Near"
)
```

## Arguments

- x:

  ratios derived from a data.frame that is the output of analysis, like
  from ejamit()\$results_bysite

- selected_dvar_colname:

  default is the first column name of x, such as "Demog.Index" if given
  a table with just ratios that are named as regular indicators, but it
  tries to figure out if ratios are available and what the base name is
  in case output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  was provided.

- selected_dvar_nicename:

  default is the "short" name of selected_dvar_colname as converted
  using
  [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)

- towhat_nicename:

  default is "US average"

- maxratio:

  largest ratio to plot in case of outliers, so plot looks better

- wheretext:

  Use in plot subtitle. Default is "Near" but could be "Within 5km of"
  for example. If it is a number, n, it will set wheretext to "Within n
  miles of"

## Value

same format as output of
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)

## Details

See
[`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md)
now for ratios plots.

See
[`plot_boxplot_pctiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_boxplot_pctiles.md)
now espec. for percentiles.

IMPORTANTLY, NOTE this used the ratio at each site USING THE AVERAGE
RESIDENT AT THAT SITE, SO A BOXPLOT SHOWED ONE DOT PER SITE AND THE
BOXPLOT WAS NOT POP WTD MEANING IT SHOWED THE MEDIAN AND 75TH PERCENTILE
SITE NOT RESIDENT, ETC.

To communicate whether this is skewed to the right (more high scores
than might expect) also could say that X% OF SITES OR PEOPLE have scores
in top Y% of US range, \>= 100-Y percentile. e.g., 20% of these sites
have scores at least in the top 5% of US scores (which is more/less than
one might expect

- leaving aside statistical significance ie whether this could be by
  chance if sites were randomly picked from US blockgroups or people's
  bg scores)
