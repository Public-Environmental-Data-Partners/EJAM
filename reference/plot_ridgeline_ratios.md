# Make ridgeline plot of ratios of residential population percentage to its average

Make ridgeline plot of ratios of residential population percentage to
its average

## Usage

``` r
plot_ridgeline_ratios(
  ratio.to.us.d.bysite,
  shortlabels = NULL,
  main = "Variations among Sites",
  maxratio = 5
)
```

## Arguments

- ratio.to.us.d.bysite:

  named list of a few ratios to plot (data.frame)

- shortlabels:

  names to use for plot - should be same length as named list
  ratio.to.us.d.overall

- main:

  optional title for ggplot2

- maxratio:

  largest ratio to plot in case of outliers, so plot looks better

## Examples

``` r
 out <- testoutput_ejamit_1000pts_1miles
 ratio.to.us.d.bysite <- out$results_bysite[ ,  c(
   ..names_d_ratio_to_avg, ..names_d_subgroups_ratio_to_avg
   )]
 # plot_ridgeline_ratios(ratio.to.us.d.bysite)
 # cap the ratio, for better plot
 x <- as.matrix(ratio.to.us.d.bysite)
 plot_ridgeline_ratios(data.table::data.table(x))
```
