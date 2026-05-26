# Plot distribution of indicator values at analyzed sites against a reference area

Visualize one indicator from `ejamit()$results_bysite` against the same
indicator in a reference dataset such as `blockgroupstats`.

## Usage

``` r
plot_boxplot_vs_ref(
  bysite = NULL,
  varname = "pctlowinc",
  type = "ggplot",
  refarealabel = "All Blockgroups Nationwide",
  siteslabel = "At Sites Analyzed",
  siteidlabel = NULL,
  refdata = NULL,
  nsample = 5000,
  fix_pctcols = TRUE,
  colorfills = c("lightblue", "yellow"),
  box.cex.ref = 0.6,
  box.cex.here = 2.2,
  box.pch.ref = 20,
  box.pch.here = 2,
  ...
)

plot_vs_us(
  bysite = NULL,
  varname = "pctlowinc",
  type = "ggplot",
  refarealabel = "All Blockgroups Nationwide",
  siteslabel = "At Sites Analyzed",
  siteidlabel = NULL,
  refdata = NULL,
  nsample = 5000,
  fix_pctcols = TRUE,
  colorfills = c("lightblue", "yellow"),
  box.cex.ref = 0.6,
  box.cex.here = 2.2,
  box.pch.ref = 20,
  box.pch.here = 2,
  ...
)
```

## Arguments

- bysite:

  Table of results from `ejamit()$results_bysite`, or a full
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  output list with a `results_bysite` element.

- varname:

  Single column name to plot, such as `"pctlowinc"`.

- type:

  Plot type. One of `"ggplot"`, `"box"`, or `"plotly"`.

- refarealabel:

  Label used for the reference-area rows.

- siteslabel:

  Label used for the analyzed-site rows.

- siteidlabel:

  Optional vector of labels, one per analyzed site, used only when
  `type = "box"`. Defaults to `ejam_uniq_id`.

- refdata:

  Reference-area data with columns `pop` and `varname`. Defaults to
  `blockgroupstats`.

- nsample:

  Maximum number of reference rows to draw as points in sampled plot
  layers. If `refdata` has fewer rows, all reference rows are used.

- fix_pctcols:

  Whether to rescale known percent-as-fraction columns to percent units
  before plotting.

- colorfills:

  Two colors: first for the reference area, second for analyzed sites.

- box.cex.ref:

  Point size for sampled reference rows when `type = "box"`.

- box.cex.here:

  Point size for analyzed-site rows when `type = "box"`.

- box.pch.ref:

  Point symbol for sampled reference rows when `type = "box"`.

- box.pch.here:

  Point symbol for analyzed-site rows when `type = "box"`.

- ...:

  Additional arguments passed to
  [`boxplot()`](https://rdrr.io/r/graphics/boxplot.html) when
  `type = "box"`.

## Value

For `type = "ggplot"`, a
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object. For `type = "plotly"`, a plotly htmlwidget. For `type = "box"`,
draws a base R plot and invisibly returns a list containing the boxplot
result, plotted data, mean values, and explanatory plot notes, including
the per-location mean labels shown under the x-axis categories and the
location-aligned color mappings used by the base plot.

## Details

`bysite` is expected to be `ejamit()$results_bysite` or a full
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
output list containing `results_bysite`. The table must contain `pop`,
`ejam_uniq_id`, and the indicator column named by `varname`.

`refdata` must contain `pop` and the same indicator column. When
`refdata` is omitted, all rows from `blockgroupstats` with non-missing
population and indicator values are used.

Percentage columns in EJAM site output and `blockgroupstats`
historically use different scales for some variables. With
`fix_pctcols = TRUE`, those columns are rescaled to percent units before
plotting.

## See also

See
[`plot_boxplot_pctiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_boxplot_pctiles.md)
for percentile indicators compared in one plot. See
[`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md)
and
[`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
for ratio indicators.

## Examples

``` r
# \donttest{
out <- testoutput_ejamit_1000pts_1miles
plot_vs_us(out$results_bysite, type = "ggplot")
plot_vs_us(out$results_bysite, varname = "pctlingiso", type = "box", ylim = c(0, 20))

td <- testoutput_ejamit_1000pts_1miles$results_bysite
plot_vs_us(
  td[td$ST %in% "DE", ],
  "pcthisp",
  refdata = blockgroupstats[ST %in% "DE", .(pop, pcthisp)],
  refarealabel = "Delaware Blockgroups"
)
# }
```
