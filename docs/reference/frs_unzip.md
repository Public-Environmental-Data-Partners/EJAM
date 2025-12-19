# Unzip Facility Registry Service dataset

Unzip Facility Registry Service dataset

## Usage

``` r
frs_unzip(zfile = "national_single.zip", folder = ".", ...)
```

## Arguments

- zfile:

  zipfile obtained via frs_download

- folder:

  optional, folder to look in for zfile

- ...:

  passed to unzip

## Details

helper function used by frs_get() to create dataset for EJAM

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
which uses
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)
which uses
[`frs_download()`](https://ejanalysis.github.io/EJAM/reference/frs_download.md)
`frs_unzip()`
[`frs_read()`](https://ejanalysis.github.io/EJAM/reference/frs_read.md)
[`frs_clean()`](https://ejanalysis.github.io/EJAM/reference/frs_clean.md)
