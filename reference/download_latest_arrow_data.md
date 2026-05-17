# Download package-compatible Arrow datasets if user does not have them already

Used when EJAM package is attached

## Usage

``` r
download_latest_arrow_data(
  varnames = .arrow_ds_names,
  repository = NULL,
  envir = globalenv(),
  piggybacktag = "latest",
  force = FALSE
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

  default is `"latest"` for dynamic Arrow data. Package- coupled annual
  datasets such as `bgej` override `"latest"` internally and use
  `paste0("v", packageVersion("EJAM"))` as their release tag.

- force:

  set TRUE to download requested files even if local copies exist.

## Details

Checks to see what release of each requested Arrow dataset should be
used. Facility and most geography Arrow files are treated as dynamic
data and normally come from the latest applicable data-repository
release, tracked with the installed package's
`data/ejamdata_version.txt` marker.

Annual EJSCREEN/EJAM data files such as `bgej.arrow` are
package-coupled. They are obtained from the `ejamdata` release tag that
matches the current EJAM package version as reported by
`packageVersion("EJAM")`. For example, EJAM 2.5.0 looks for `bgej.arrow`
in the `ejamdata` release tagged `v2.5.0`, not in the latest
data-repository release.

Relies on
[`piggyback::pb_releases()`](https://docs.ropensci.org/piggyback/reference/pb_releases.html)
to track / update / store / download data files as assets of a specific
release on the data repository. For details, see [technical details of
how datasets are
updated](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.html)
