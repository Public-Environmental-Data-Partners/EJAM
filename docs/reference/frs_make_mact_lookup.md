# Create updated version of frs_by_mact and mact_table

Create updated version of frs_by_mact and mact_table

## Usage

``` r
frs_make_mact_lookup(frs_by_programid, folder = NULL)
```

## Arguments

- frs_by_programid:

  from output of frs_make_programid_lookup()

- folder:

  optional, where to download ICIS-AIR_downloads.zip to, tempdir() by
  default

## Value

list, of
[frs_by_mact](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_mact.md)
table in [data.table](https://r-datatable.com) format and
[mact_table](https://public-environmental-data-partners.github.io/EJAM/reference/mact_table.md)
data.frame

## See also

[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
