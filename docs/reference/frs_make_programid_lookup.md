# Reformat frs datatable to look up facilities by PGM_SYS_ACRNMS

Reformat frs datatable to look up facilities by PGM_SYS_ACRNMS

## Usage

``` r
frs_make_programid_lookup(x)
```

## Arguments

- x:

  [frs](https://ejanalysis.github.io/EJAM/reference/frs.md) table in
  [data.table](https://r-datatable.com) format from
  [`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)

## Value

table in [data.table](https://r-datatable.com) format with columns lat,
lon, REGISTRY_ID, program, pgm_sys_id

## Details

More information including definitions of the programs (full names) can
be found here:

- https://www.epa.gov/frs/frs-data-sources

- [2021-05/frs_program_abbreviations_and_names.xlsx](https://www.epa.gov/sites/default/files/2021-05/frs_program_abbreviations_and_names.xlsx)

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
