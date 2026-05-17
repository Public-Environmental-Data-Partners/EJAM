# Load datasets from local disk folder

Utility for analysts / developers to store large block / other data
locally instead of re-downloading

## Usage

``` r
dataload_from_local(
  varnames = .arrow_ds_names[1:3],
  envir = globalenv(),
  folder_local_source = NULL,
  justchecking = FALSE,
  testing = FALSE,
  silent = FALSE,
  return_data_table = TRUE
)
```

## Arguments

- varnames:

  use defaults, or vector of names like "bgej" or use "all" to get all
  available

- envir:

  use defaults. see
  [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)

- folder_local_source:

  Your local folder path. see
  [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)

- justchecking:

  use defaults. DEPRECATED

- testing:

  use defaults

- silent:

  set to TRUE to stop cat() printing to console like when running tests

- return_data_table:

  whether the
  [`read_ipc_file()`](https://arrow.apache.org/docs/r/reference/read_feather.html)
  should return a table in [data.table](https://r-datatable.com) format
  (T, the default), or arrow (F)

## Value

vector of paths to files (as derived from varnames) that were actually
found in folder_local_source, but only for those not already in memory,
so it is just the ones loaded from disk because not already in memory
and found on disk locally.

## Details

See
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
also. dataload_dynamic rm(bgid2fips, blockid2fips, blockpoints,
blockwts, quaddata)

dataload_from_local(folder_local_source = '.')
