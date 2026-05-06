# utility to calculate annually for EJSCREEN the updated Demographic Indexes per blockgroup from ACS data

utility to calculate annually for EJSCREEN the updated Demographic
Indexes per blockgroup from ACS data

## Usage

``` r
calc_blockgroup_demog_index(bgstats, formulas = formulas_ejscreen_demog_index)
```

## Arguments

- bgstats:

  a data.frame or data.table like
  [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md),
  with one row per blockgroup and the columns used in the demographic
  index formulas.

- formulas:

  formulas used to calculate the demographic index columns.

## Value

data.table, one row per blockgroup, columns bgfips, etc.
