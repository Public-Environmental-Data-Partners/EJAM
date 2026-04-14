# Clean EPA FRS SIC info

Clean EPA FRS SIC info

## Usage

``` r
frs_clean_sic(
  frs,
  usefulcolumns = c("lat", "lon", "SIC", "LATITUDE83", "LONGITUDE83", "REGISTRY_ID",
    "PRIMARY_NAME", "SIC_CODES", "PGM_SYS_ACRNMS")
)
```

## Arguments

- frs:

  the frs data object from frs_read()

- usefulcolumns:

  optional

## Value

frs data.table

## Details

works just like
[`frs_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_clean.md)
but for SIC codes instead of NAICS

## See also

[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
