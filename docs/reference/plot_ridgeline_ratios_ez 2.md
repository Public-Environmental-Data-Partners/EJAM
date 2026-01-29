# Make ridgeline plot of ratios of residential population percentage to its average

Make ridgeline plot of ratios of residential population percentage to
its average

## Usage

``` r
plot_ridgeline_ratios_ez(
  out,
  varnames = c(names_d_ratio_to_avg, names_d_subgroups_ratio_to_avg),
  main = "Variations among Sites",
  maxratio = 5
)
```

## Arguments

- out:

  like from ejamit()

- varnames:

  vector of colnames in out\$results_bysite, the ratio variables

- main:

  optional alternative title for plot

- maxratio:

  largest ratio to plot in case of outliers, so plot looks better

## Examples

``` r
 out <- testoutput_ejamit_1000pts_1miles
 plot_ridgeline_ratios_ez(out)
```
