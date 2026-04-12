# Download latest versions of arrow datasets if user doesn't have them already

Used when EJAM package is attached

## Usage

``` r
download_latest_arrow_data(
  varnames = .arrow_ds_names,
  repository = NULL,
  envir = globalenv()
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

## Details

Checks to see what is the latest version of datasets available according
to a repository's latest release tag. Compares that to what version was
last saved locally (as stored in the installed package's
ejamdata_version.txt file).

Relies on
[`piggyback::pb_releases()`](https://docs.ropensci.org/piggyback/reference/pb_releases.html)
to download data files from a specific release (version) of the package.
