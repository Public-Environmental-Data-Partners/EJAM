# Reformat frs datatable to look up by NAICS

Reformat frs datatable to look up by NAICS

## Usage

``` r
frs_make_naics_lookup(x)
```

## Arguments

- x:

  data.table [frs](https://ejanalysis.github.io/EJAM/reference/frs.md)
  from
  [`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)

## Value

table in [data.table](https://r-datatable.com) format with columns
NAICS, REGISTRY_ID, etc.

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
which uses
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md) to
create
[frs_by_naics](https://ejanalysis.github.io/EJAM/reference/frs_by_naics.md)
