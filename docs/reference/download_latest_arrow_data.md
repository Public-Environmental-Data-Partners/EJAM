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

  default is `"latest"`, which resolves internally to the DESCRIPTION
  `ejamdata_required_tag` field. Pass a specific tag such as `"v2.32.8"`
  only for explicit maintenance or diagnostic work.

- force:

  set TRUE to download requested files even if local copies exist.

## Details

Checks to see what `ejamdata` release tag should be used for requested
Arrow datasets. By default, EJAM uses the required `ejamdata` release
tag recorded in DESCRIPTION as `ejamdata_required_tag`. For example,
EJAM 2.5.0 currently looks for Arrow files in the `ejamdata` release
tagged `v2.5.0`, not in whichever data-repository release GitHub
currently marks as latest.

The installed package's `data/ejamdata_version.txt` marker records the
release tag for locally installed Arrow files.

Relies on
[`piggyback::pb_download()`](https://docs.ropensci.org/piggyback/reference/pb_download.html)
to download data files that have been stored as assets of a specific
release on the data repository. For details, see [technical details of
how datasets are
updated](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.html)
