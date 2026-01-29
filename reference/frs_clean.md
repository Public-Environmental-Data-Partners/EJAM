# Clean Facility Registry Service (FRS) dataset when updating copy for use in EJAM

Clean Facility Registry Service (FRS) dataset when updating copy for use
in EJAM

## Usage

``` r
frs_clean(
  frs,
  usefulcolumns = c("LATITUDE83", "LONGITUDE83", "REGISTRY_ID", "PRIMARY_NAME",
    "NAICS_CODES", "SIC_CODES", "PGM_SYS_ACRNMS")
)
```

## Arguments

- frs:

  data.table that is the output of frs_read()

- usefulcolumns:

  optional, drops all columns except those in this vector of character
  colnames

## Value

data.table with columns as defined by usefulcolumns parameter like
REGISTRY_ID, and some renamed to for example lat, lon, NAICS, SIC

## Details

Used by
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)
This renames some columns (lat, lon, NAICS are new names) and it drops
rows lacking lat/lon location info in the LATITUDE83 or LONGITUDE83
columns

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
