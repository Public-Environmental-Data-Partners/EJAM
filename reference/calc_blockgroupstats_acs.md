# utility to calculate annually for EJSCREEN the updated blockgroupstats dataset, by 1st creating blockgroupstats_acs

utility to calculate annually for EJSCREEN the updated blockgroupstats
dataset, by 1st creating blockgroupstats_acs

## Usage

``` r
calc_blockgroupstats_acs(
  yr,
  formulas = EJAM::formulas_ejscreen_acs$formula,
  tables = as.vector(EJAM::tables_ejscreen_acs),
  dropMOE = TRUE,
  acs_raw = NULL
)
```

## Arguments

- yr:

  end year of 5-year ACS dataset, guessed if not specified

- formulas:

  default is formulas used by EJAM/EJScreen. A vector of string formulas
  such as c("pop = B01001_001", "hisp = B03002_012", "pcthisp \<-
  ifelse(pop==0, 0, as.numeric(hisp ) / pop)")

- tables:

  default is the key ACS tables needed by EJAM/EJScreen. A vector of ACS
  table numbers, such as c("B01001", "B03002")

- dropMOE:

  logical, whether to drop and not retain the margin of error
  information on every ACS variable

- acs_raw:

  optional raw ACS table list or `bg_acs_raw` pipeline object previously
  created by
  [`download_bg_acs_raw()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_bg_acs_raw.md).
  If supplied, no ACS download is performed for blockgroup-resolution
  tables.

## Value

data.table, one row per blockgroup, columns bgfips, etc.

## Details

This is meant to be used annually for updating EJScreen demographic
indicators from the Census Bureau American Community Survey (ACS) 5-year
summary file, to update the datasets in the package. This would normally
be called from the script in `datacreate_blockgroupstats_acs.R`, which
is in the source package folder "data-raw"

Requires installed package ACSdownload from
https://github.com/ejanalysis/ACSdownload which is documented at
https://ejanalysis.github.io/ACSdownload

## See also

`calc_blockgroupstats_acs()`
[`calc_blockgroupstats_from_tract_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_from_tract_data.md)
[`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md)
[`formulas_ejscreen_acs()`](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md)
[`formulas_ejscreen_acs_disability()`](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs_disability.md)
[`formulas_ejscreen_demog_index()`](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_demog_index.md)
