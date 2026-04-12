# Compare ejamit() full results for more than one radius Helper used by ejamit_compare_distances() to run ejamit() once per radius, get FULL ejamit() output list per radius

Compare ejamit() full results for more than one radius Helper used by
ejamit_compare_distances() to run ejamit() once per radius, get FULL
ejamit() output list per radius

## Usage

``` r
ejamit_compare_distances_fulloutput(
  sitepoints,
  radii = c(1, 2, 3),
  donuts_not_cumulative = FALSE,
  quiet = TRUE,
  silentinteractive = TRUE,
  ...
)
```

## Arguments

- sitepoints:

  like for
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- radii:

  vector of radius values like 1:3 for
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- donuts_not_cumulative:

  set to TRUE to get results on each ring not each full circle

- quiet:

  passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- silentinteractive:

  passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- ...:

  passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

## Value

list you can think of as "out_bydistance" where each element is the full
output of
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
for 1 radius

## Details

You typically only need
[`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md),
which gives you just the summary overall at each distance, but if you
want to retain the full outputs of ejamit() at each distance, such as
results for every site at every distances, you can use
`ejamit_compare_distances_fulloutput()` and then to extract a slice of
results, use helper functions like

- [`out_bydistance2results_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bydistance.md)

- [`out_bydistance2results_bydistance_bysite()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bydistance_bysite.md)

- [`out_bydistance2results_bysite_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bysite_bydistance.md)

## See also

wrapper
[`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)
and helpers
[`out_bydistance2results_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bydistance.md)
[`out_bydistance2results_bydistance_bysite()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bydistance_bysite.md)
[`out_bydistance2results_bysite_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bysite_bydistance.md)

## Examples

``` r
  radii <- c(1,2,3,6,10)
  pts <- testpoints_10
  # \donttest{
  x <- ejamit_compare_distances_fulloutput(pts, radii = radii)
  # }
```
