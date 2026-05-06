# Download latest release of arrow datasets if user doesn't have them already

Used when EJAM package is attached

## Usage

``` r
download_latest_arrow_data(
  varnames = .arrow_ds_names,
  repository = NULL,
  envir = globalenv(),
  piggybacktag = "latest"
)
```

## Arguments

- varnames:

  use defaults, or vector of names like "bgej" or use "all" to get all
  available

- repository:

  repository owner/name such as
  Public-Environmental-Data-Partners/ejamdata or "XYZ/ejamdata"
  (wherever the ejamdata repo is hosted, as specified in the DESCRIPTION
  file of this package)

- envir:

  if needed to specify environment other than default, e.g., globalenv()
  or parent.frame()

- piggybacktag:

  default is "latest" but if a different release were needed this could
  be changed.

## Details

Checks to see what is the latest release of datasets available according
to the data repository's latest release tag. Compares that to what
version was last saved locally (as stored in the installed package's
ejamdata_version.txt file).

Relies on
[`piggyback::pb_releases()`](https://docs.ropensci.org/piggyback/reference/pb_releases.html)
to track / update / store / download data files as assets of a specific
release on the data repository. For details, see [technical details of
how datasets are
updated](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.html)
