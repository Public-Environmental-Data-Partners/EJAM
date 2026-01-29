# helper - Barplot of ratios of residential population percentages (or other scores) to averages (or other references)

helper - Barplot of ratios of residential population percentages (or
other scores) to averages (or other references)

## Usage

``` r
plot_barplot_ratios(
  ratio.to.us.d.overall,
  shortlabels = NULL,
  mycolorsavailable = c("gray", "yellow", "orange", "red"),
  main = "Residential Populations at the Analyzed Locations Compared to US Overall",
  ylab = "Ratio vs. Average",
  caption = "NH = \"non-Hispanic\"\nNHA = \"non-Hispanic alone, aka single race\""
)
```

## Arguments

- ratio.to.us.d.overall:

  named list of a few ratios to plot, but see
  [`ejam2barplot()`](https://ejanalysis.github.io/EJAM/reference/ejam2barplot.md)
  for an easier way to specify which indicator to show.

- shortlabels:

  optional, names to use for plot - should be same length as named list
  ratio.to.us.d.overall

- mycolorsavailable:

  optional (best to leave as default)

- main:

  optional, title for plot, like "Analyzed Locations Compared to US
  Overall", or if using state ratios, include the word "State" to have
  it try to infer what the legend should be

- ylab:

  optional, label for y axis

- caption:

  text for a key defining some terms that are abbreviations

## Value

ggplot should be returned

## Details

See `plot_barplot_ratios_ez()` which is easier to use, or
[`ejam2barplot()`](https://ejanalysis.github.io/EJAM/reference/ejam2barplot.md)
which is even easier.

If the parameter called main has the word "State" in it, then the legend
will refer to "State Average" instead of "US Average" – You cannot plot
both types at the same time, so the ratio.to.us.d.overall parameter
should be either just ratios to average in US or just ratios to average
in State.

## See also

[`ejam2ratios()`](https://ejanalysis.github.io/EJAM/reference/ejam2ratios.md)
[`ejam2barplot()`](https://ejanalysis.github.io/EJAM/reference/ejam2barplot.md)
`plot_barplot_ratios_ez()`
[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)

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
