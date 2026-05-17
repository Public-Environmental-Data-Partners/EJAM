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

  default is `"latest"` for dynamic Arrow data. Package- coupled annual
  datasets such as `bgej` override `"latest"` internally and use
  `paste0("v", packageVersion("EJAM"))` as their release tag.

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

Arrow files do not all follow the same release rule. Facility and most
geography Arrow files are still treated as dynamic data and normally
come from the latest applicable `ejamdata` release, tracked with the
local `ejamdata_version.txt` marker. Annual EJSCREEN/EJAM data files
such as `bgej.arrow` are package-coupled: they are pinned to the
installed EJAM package version, so EJAM 2.5.0 looks for `bgej.arrow` in
the `ejamdata` release tagged `v2.5.0` rather than in the latest
data-repository release.
