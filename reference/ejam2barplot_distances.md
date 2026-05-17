# Barplot comparing ejamit_compare_distances() results for more than one radius

Barplot comparing ejamit_compare_distances() results for more than one
radius

## Usage

``` r
ejam2barplot_distances(
  results_bydistance,
  myvars = names_d_subgroups_ratio_to_state_avg,
  ylab = "Ratio of Avg. within X miles to Avg. Statewide or Nationwide",
  ylim = c(0, 5),
  n = 1,
  ...
)
```

## Arguments

- results_bydistance:

  output of
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md),
  table similar to ejamit()\$results_overall except it has one row per
  distance.

- myvars:

  optional, see
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

- ylab:

  optional, see
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

- ylim:

  optional, see
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

- n:

  optional, see
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)

- ...:

  optional, other parameters passed to plot

## Value

text vector length n, naming which indicators most strongly increase as
you get closer to the site(s)

## Examples

``` r
if (FALSE) { # \dontrun{
out = ejamit_compare_distances(testpoints_10, radii = 1:2, plot = FALSE)
ejam2barplot_distances(out)
} # }
```
