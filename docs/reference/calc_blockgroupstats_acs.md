# Calculate the ACS-derived blockgroup stage for EJSCREEN annual updates

Calculate the ACS-derived blockgroup stage for EJSCREEN annual updates

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

This lower-level helper calculates ACS-derived blockgroup indicators
from the Census Bureau American Community Survey (ACS) 5-year summary
file. In the current annual pipeline it is called through
[`calc_bg_acsdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bg_acsdata.md),
which is in turn orchestrated by
[`calc_ejscreen_dataset()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset.md)
and by the staged runner script
`data-raw/run_ejscreen_dataset_pipeline.R`.

Requires installed package ACSdownload from
https://github.com/ejanalysis/ACSdownload which is documented at
https://ejanalysis.github.io/ACSdownload

## See also

[`calc_bg_acsdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bg_acsdata.md)
[`calc_blockgroupstats_from_tract_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_from_tract_data.md)
[`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md)
[formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md)
[formulas_ejscreen_acs_disability](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs_disability.md)
[formulas_ejscreen_demog_index](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_demog_index.md)
