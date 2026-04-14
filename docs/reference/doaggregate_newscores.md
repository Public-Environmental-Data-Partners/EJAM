# For user-provided indicators and formulas, aggregate at each site and overall

Like doaggregate() but for any user-provided indicator available for all
blockgroups (nationwide so that US percentiles make sense, or at least
statewide)

## Usage

``` r
doaggregate_newscores(
  sites2blocks,
  userstats,
  formulas = NULL,
  sites2states_or_latlon = NA,
  radius = NULL,
  countcols = "pop",
  popmeancols = NULL,
  calculatedcols = NULL,
  varsneedpctiles = NULL,
  usastats_newscores = NULL,
  statestats_newscores = NULL,
  ...
)
```

## Arguments

- sites2blocks:

  output of
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
  as for
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- userstats:

  like blockgroupstats but data.frame or
  [data.table](https://r-datatable.com) of all US blockgroups and one or
  more columns of user provided raw indicator scores and any other
  variables needed for formulas to aggregate indicators across
  blockgroups in each site.

- formulas:

  a character vector of formulas in R code (see formulas_d for an
  example), that use variables in userstats to calculate any derived
  indicators or aggregated ones, for cases where just a sum or a
  population weighted mean is not the right way to aggregate some
  indicator. Formulas can include intermediate steps, or can aggregate
  across all places.

  For example one formula might be

  "pctover64 = ifelse(pop == 0, 0, over64 / pop)"

- sites2states_or_latlon:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- radius:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- countcols:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- popmeancols:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- calculatedcols:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- varsneedpctiles:

  see
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- usastats_newscores:

  calculated if not provided

- statestats_newscores:

  calculated if not provided

- ...:

  not used

## Value

see
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
