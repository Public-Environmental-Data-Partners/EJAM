# Helper - Barplot of ratios of indicators (at a site or all sites overall) to US or State average

Helper - Barplot of ratios of indicators (at a site or all sites
overall) to US or State average

## Usage

``` r
plot_barplot_ratios_ez(
  out,
  varnames = c(names_d_ratio_to_avg, names_d_subgroups_ratio_to_avg),
  main = "Residential Populations at the Analyzed Locations Compared to US Overall",
  single_location = FALSE,
  row_index = NULL,
  ...
)
```

## Arguments

- out:

  the list of tables that is the output of ejamit() or a related
  function

- varnames:

  vector of indicator names that are colnames in out\$results_overall or
  out\$results_bysite, like names_d_ratio_to_state_avg or
  names_d_subgroups_ratio_to_state_avg, but not a mix of US and State
  ratios.

- main:

  title of plot - change this if you want to plot State ratios. If using
  state ratios, include the word "State" to have it try to infer what
  the legend should be

- single_location:

  set to TRUE and provide row_index to view one site, set to FALSE to
  view overall results from out\$results_overall

- row_index:

  the number of the row to use from out\$results_bysite, if
  single_location = TRUE.

- ...:

  passed to
  [`plot_barplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios.md),
  to change color scheme etc.

## Details

Used by and similar to
[`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md),
which is an easier way to do this!

This function requires you to specify single_location = TRUE when using
the row_index param. The
[`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
function just uses a sitenumber parameter.

This function is more flexible than
[`plot_barplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios.md),
which it relies on, since this lets you specify whether to use overall
results from ejamit()\$results_overall or just one site from
ejamit()\$results_bysite

## Examples

``` r
out <- testoutput_ejamit_100pts_1miles
ejam2barplot(out)

out <- testoutput_ejamit_100pts_1miles
plot_barplot_ratios_ez(
  out,
  varnames = c(names_d_ratio_to_avg , names_d_subgroups_ratio_to_avg)
)

out <- testoutput_ejamit_100pts_1miles
plot_barplot_ratios(
  unlist(out$results_overall[ ,
     c(..names_d_ratio_to_avg , ..names_d_subgroups_ratio_to_avg) ])
)
```
