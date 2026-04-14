# Reformat frs datatable to look up facilities by SIC code

Reformat frs datatable to look up facilities by SIC code

## Usage

``` r
frs_make_sic_lookup(x)
```

## Arguments

- x:

  table in [data.table](https://r-datatable.com) format
  [frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
  from
  [`frs_clean_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_clean_sic.md)

## Value

table in [data.table](https://r-datatable.com) format with lat, lon,
REGISTRY_ID, SIC columns

## See also

[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
[`frs_clean_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_clean_sic.md)
and the frs_by_sic data.table
