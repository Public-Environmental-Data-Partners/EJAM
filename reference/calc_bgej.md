# recalculate EJSCREEN EJ Indexes for all US blockgroups, as for an annual data update

recalculate EJSCREEN EJ Indexes for all US blockgroups, as for an annual
data update

## Usage

``` r
calc_bgej(
  bgstats,
  vnames_e = names_e,
  vnames_e_pctile = names_e_pctile,
  vnames_e_state_pctile = names_e_state_pctile,
  vnames_ej = names_ej,
  vnames_ej_supp = names_ej_supp,
  vnames_ej_state = names_ej_state,
  vnames_ej_supp_state = names_ej_supp_state,
  vnames_d_demogindex = "Demog.Index",
  vnames_d_demogindex_supp = "Demog.Index.Supp",
  vnames_d_demogindex_state = "Demog.Index.State",
  vnames_d_demogindex_supp_state = "Demog.Index.Supp.State",
  vnames_ST = "ST"
)
```

## Arguments

- bgstats:

  like
  [blockgroupstats](https://ejanalysis.github.io/EJAM/reference/blockgroupstats.md),
  a new data.table with one row per blockgroup, and columns that include
  c('bgid', 'bgfips', 'ST', 'pop'), environmental indicators with
  colnames defined in vnames_e, and the 4 types of demographic indexes.

- vnames_e:

  names of columns in bgstats that have envt indicators, assumed if
  missing

- vnames_e_pctile:

  optional, just must be same length as vnames_e

- vnames_e_state_pctile:

  optional, just must be same length as vnames_e

- vnames_ej:

  optional, names of one set of the EJ Index columns in returned table

- vnames_ej_supp:

  optional, names of one set of the EJ Index columns in returned table

- vnames_ej_state:

  optional, names of one set of the EJ Index columns in returned table

- vnames_ej_supp_state:

  optional, names of one set of the EJ Index columns in returned table

- vnames_d_demogindex:

  name of 1 column in bgstats (that has this 1 type of Demographic
  Index)

- vnames_d_demogindex_supp:

  name of 1 column in bgstats

- vnames_d_demogindex_state:

  name of 1 column in bgstats

- vnames_d_demogindex_supp_state:

  name of 1 column in bgstats

- vnames_ST:

  name of column in bgstats that has the 2-character State abbreviation
  to use in finding envt percentiles in the
  [statestats](https://ejanalysis.github.io/EJAM/reference/statestats.md)
  table used by
  [`calc_pctile_columns()`](https://ejanalysis.github.io/EJAM/reference/calc_pctile_columns.md)

## Value

data.table like
[bgej](https://ejanalysis.github.io/EJAM/reference/bgej.md)
