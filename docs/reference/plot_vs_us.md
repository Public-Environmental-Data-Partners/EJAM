# Plot boxplot distribution of data among residents at sites vs reference area (US, etc.)

Visualize indicator values (scores) as distributed across places

## Usage

``` r
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

  table of results from ejamit()\$results_bysite, like
  testoutput_ejamit_1000pts_1miles\$results_bysite

- varname:

  name of column in bysite, like "Demog.Index"

- type:

  "box", "plotly", or "ggplot"

- refarealabel:

  e.g., "All blockgroups in this State"

- siteslabel:

  e.g., "At Avg. Site Analyzed"

- siteidlabel:

  vector of text one per site to show if type 'box'

- refdata:

  reference area dataset, like blockgroupstats, but must have columns
  named 'pop' and varname. e.g.,

      refdata = blockgroupstats[ST %in% "DE", .(pop, pcthisp)]

- nsample:

  to limit dots on plot of ref area like all bg in US

- colorfills:

  two colors for boxplot

- box.cex.ref:

  use default

- box.cex.here:

  use default

- box.pch.ref:

  use default

- box.pch.here:

  description

- ...:

  passed to boxplot()

## Value

plots

## Details

Not population weighted, so it is the distribution across sites not
residents.

Could be edited to allow multiple types of sites and/or reference zones
more generally like for
[`ejamit_compare_types_of_places()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_types_of_places.md)

## See also

See
[`plot_boxplot_pctiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_boxplot_pctiles.md)
for Percentile indicators compared in one plot. See
[`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md)
See
[`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
for Ratio indicators compared in one plot. See `plot_boxplot_vs_ref()`
for a Raw indicator vs. a reference distribution.

## Examples

``` r
if (FALSE) { # \dontrun{
  out <- testoutput_ejamit_1000pts_1miles
  # ejam2boxplot(out)
  # plot_boxplot_vs_ref(out$results_bysite)
  EJAM:::plot_vs_us(out$results_bysite, type = 'box')
  EJAM:::plot_vs_us(out$results_bysite, varname = "pctlingiso", type =  'box', ylim=c(0, 20))
  EJAM:::plot_vs_us(out$results_bysite, varname = "pctlingiso", type =  'ggplot')
  EJAM:::plot_vs_us(out$results_bysite, varname = "pctnhaa", type =  'ggplot')
  EJAM:::plot_vs_us(out$results_bysite, varname = "pctnhaa", type = 'box', ylim = c(0, 20))

 # td = testoutput_ejamit_1000pts_1miles$results_bysite
 # EJAM:::plot_vs_us(, type = 'box')
 # EJAM:::plot_vs_us(td, varname = "pctlingiso", type =  'box', ylim=c(0,20))
 # EJAM:::plot_vs_us(td, varname = "pctlingiso", type =  'ggplot')
 # EJAM:::plot_vs_us(td, varname = "pctnhaa", type =  'ggplot')
 # EJAM:::plot_vs_us(td, varname = "pctnhaa", type = 'box', ylim = c(0,20))
 # EJAM:::plot_vs_us(td[td$ST %in% "DE", ], 'pcthisp', refdata = blockgroupstats[ST %in% "DE", .(pop, pcthisp)])
  } # }
```
