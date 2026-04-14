# Boxplots comparing a few indicators showing how each varies across sites Visualize mean median etc. for each of several percentile indicators

Boxplots comparing a few indicators showing how each varies across sites
Visualize mean median etc. for each of several percentile indicators

## Usage

``` r
plot_boxplot_pctiles(
  out,
  vars = names_d_state_pctile,
  ylab = "Percentile in State",
  ranked = TRUE,
  ...
)
```

## Arguments

- out:

  The output from ejamit() such as testoutput_ejamit_10pts_1miles

- vars:

  Typically would be one of these: names_d_pctile, names_d_state_pctile,
  names_d_subgroups_pctile, names_d_subgroups_state_pctile,
  names_e_pctile, names_e_state_pctile, and possibly ratios or others,
  but this is designed to plot pctiles.

- ylab:

  inferred from vars normally

- ranked:

  set FALSE to avoid sorting x axis on size of wtdmeans

- ...:

  passed to boxplot()

## Value

prints means etc. and plots

## Examples

``` r
# \donttest{
out <- testoutput_ejamit_1000pts_1miles
bplot = plot_boxplot_pctiles
bplot(out, names_d_state_pctile)
bplot(out, names_d_subgroups_state_pctile)
bplot(out, names_e_state_pctile)
bplot(out, names_d_pctile)
bplot(out, names_d_subgroups_pctile)
bplot(out, names_e_pctile)
# }
```
