# custom version of ejamit() for calculating user-provided indicators

custom version of ejamit() for calculating user-provided indicators

## Usage

``` r
custom_ejamit(
  sitepoints,
  radius = 3,
  fips = NULL,
  shapefile = NULL,
  custom_blockgroupstats = blockgroupstats,
  countcols = names_wts,
  popmeancols = names_these,
  wtcols = names_wts,
  custom_formulas = NULL,
  custom_cols = NULL,
  custom_map_headernames = map_headernames
)
```

## Arguments

- sitepoints:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- radius:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- fips:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- shapefile:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- custom_blockgroupstats:

  like blockgroupstats but with custom indicators, one value per
  blockgroup, with colnames bgid, bgfips, pop

- countcols:

  vector of colnames in custom_blockgroupstats to be aggregated as sums
  of counts, like population counts

- popmeancols:

  vector of colnames in custom_blockgroupstats to be aggregated as
  weighted means, population weighted or with other weights

- wtcols:

  vector of colnames to use as the weights for wtd means, same length as
  popmeancols, but not used yet

- custom_formulas:

  like formulas_all, not used yet

- custom_cols:

  not used yet

- custom_map_headernames:

  like map_headernames but for the custom indicators

## Value

returns the output of
[`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)
