# custom version of doaggregate(), to calculate user-provided indicators

custom version of doaggregate(), to calculate user-provided indicators

## Usage

``` r
custom_doaggregate(
  sites2blocks,
  custom_blockgroupstats = blockgroupstats,
  countcols = "pop",
  popmeancols = names_these,
  wtcols = "pop",
  custom_formulas = NULL,
  custom_cols = NULL,
  custom_map_headernames = map_headernames
)
```

## Arguments

- sites2blocks:

  see
  [`doaggregate()`](https://ejanalysis.github.io/EJAM/reference/doaggregate.md)

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

list of tables similar to what
[`doaggregate()`](https://ejanalysis.github.io/EJAM/reference/doaggregate.md)
returns
