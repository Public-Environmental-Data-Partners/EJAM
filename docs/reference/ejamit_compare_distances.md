# Compare EJAM results overall for more than one radius Run ejamit() once per radius, get a summary table with a row per radius

Compare EJAM results overall for more than one radius Run ejamit() once
per radius, get a summary table with a row per radius

## Usage

``` r
ejamit_compare_distances(
  sitepoints,
  radii = c(1, 2, 3),
  donuts_not_cumulative = FALSE,
  quiet = TRUE,
  silentinteractive = TRUE,
  plot = TRUE,
  myvars = names_d_subgroups_ratio_to_state_avg,
  ylab = "Ratio of Avg. within X miles to Avg. Statewide or Nationwide",
  ylim = c(0, 5),
  n = 1,
  ...
)
```

## Arguments

- sitepoints:

  like for
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- radii:

  optional, vector of radius values like 1:3 for
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- donuts_not_cumulative:

  optional, when implemented, if set TRUE, would return results on areas
  in each "donut" or ring that is a distance bin, such as for
  ` 0 < R <= radii[1] radii[1] < R <= radii[2] ` etc.

- quiet:

  optional, passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- silentinteractive:

  optional, passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- plot:

  optional logical, set FALSE to avoid plotting

- myvars:

  optional, for plot, see default value

- ylab:

  optional, for plot, see default value

- ylim:

  optional, for plot, see default value

- n:

  optional, how many of the indicators to report on (printed to
  console), when reporting which indicators most strongly increase as
  radius decreases.

- ...:

  optional, passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

## Value

table in [data.table](https://r-datatable.com) format you can call
results_bydistance, like ejamit()\$results_overall but with one row per
radius

## See also

[`ejam2barplot_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_distances.md)
[`plot_distance_by_pctd()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_by_pctd.md),
[`distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md),
and
[`ejamit_compare_distances_fulloutput()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)

## Examples

``` r
  radii <- c(convert_units(5,"km","miles"), convert_units(50,"km","miles"))
  radii <- 1:10
  radii <- c(1, 10)
  pts <- testpoints_100
  pts <- testpoints_10

  bydist <- ejamit_compare_distances(pts, radii = radii)
  EJAM:::ejamit_compare_distances2plot(bydist, myvars = c(
    "ratio.to.avg.pctlowinc", "ratio.to.avg.pcthisp", "ratio.to.avg.pctnhba"))

  names(bydist) <- fixcolnames(names(bydist), "r", "shortlabel")
```
