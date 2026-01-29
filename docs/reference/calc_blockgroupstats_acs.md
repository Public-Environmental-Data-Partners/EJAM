# utility to calculate annually for EJSCREEN the updated blockgroupstats dataset, by 1st creating blockgroupstats_acs

utility to calculate annually for EJSCREEN the updated blockgroupstats
dataset, by 1st creating blockgroupstats_acs

## Usage

``` r
calc_blockgroupstats_acs(
  yr,
  formulas = EJAM::formulas_ejscreen_acs$formula,
  tables = as.vector(EJAM::tables_ejscreen_acs),
  dropMOE = TRUE
)
```

## Arguments

- yr:

  end year of 5-year ACS dataset, guesses if not specified

## Value

data.table, one row per blockgroup, columns bgfips, etc.
