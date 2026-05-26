# Utility to download / load datasets (other than typical datasets, which get lazy-loaded from the data folder)

Utility to download / load datasets (other than typical datasets, which
get lazy-loaded from the data folder)

## Usage

``` r
dataload_dynamic(
  varnames = .arrow_ds_names[1:3],
  envir = globalenv(),
  folder_local_source = NULL,
  silent = FALSE,
  return_data_table = TRUE,
  onAttach = FALSE,
  piggybacktag = "latest"
)
```

## Arguments

- varnames:

  character vector of names of R objects to get from board, or set this
  to "all" to load all of them

- envir:

  if needed to specify environment other than default, e.g., globalenv()
  or parent.frame()

- folder_local_source:

  path of local folder to look in for locally saved copies

- silent:

  set to TRUE to suppress cat() msgs to console

- return_data_table:

  whether the
  [`read_ipc_file()`](https://arrow.apache.org/docs/r/reference/read_feather.html)
  should return a table in [data.table](https://r-datatable.com) format
  (T, the default), or arrow (F). Passed to
  [`dataload_from_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_from_local.md)

- onAttach:

  Indicates whether the function is being called from onAttach. IF so,
  it will download all arrow files if necessary

- piggybacktag:

  default is `"latest"`, which resolves internally to the DESCRIPTION
  `ejamdata_required_tag` field. Pass a specific tag such as `"v2.32.8"`
  only for explicit maintenance or diagnostic work.

## Value

returns vector of names of objects now in memory in specified envir,
either because

1.  already in memory or

2.  loaded from local disk or

3.  successfully downloaded.

## Details

First checks memory, then the installed package's data folder. When the
package is first loaded, Arrow files are downloaded from the package's
data repository, normally called `ejamdata`, into the package's data
directory.

By default, Arrow files are loaded from the `ejamdata` release tag
recorded in DESCRIPTION as `ejamdata_required_tag`. The local
`ejamdata_version.txt` marker records which `ejamdata` release tag is
currently saved in the installed package's data folder.
