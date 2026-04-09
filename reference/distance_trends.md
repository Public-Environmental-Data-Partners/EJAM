# Which indicators fall most as proximity does? (i.e., are higher if closer to site) Which variables have strongest trend with distance based on slope of linear fit

Which indicators fall most as proximity does? (i.e., are higher if
closer to site) Which variables have strongest trend with distance based
on slope of linear fit

## Usage

``` r
distance_trends(
  results_bydistance,
  myvars = names_d_subgroups_ratio_to_state_avg,
  radii,
  n = 1
)
```

## Arguments

- results_bydistance:

  data.frame of a few indicators, no other columns, taken from output of
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

- myvars:

  optional, vector of some colnames of results_bydistance

- radii:

  optional vector - taken from results_bydistance\$radius.miles

- n:

  optional number of indicators to list. n=3 would mean show the top 3.

## Value

vector of text names of indicators

## Details

Used by
[`ejamit_compare_distances2plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances2plot.md)
which is used by
[`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

## Examples

``` r
EJAM:::distance_trends(ejamit_compare_distances(testpoints_10, radii = c(1,3)))
```
