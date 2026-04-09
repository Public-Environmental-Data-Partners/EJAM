# Download Facility Registry Service (FRS) file national_single.zip

Download Facility Registry Service (FRS) file national_single.zip

## Usage

``` r
frs_download(
  folder = NULL,
  zfile = "national_single.zip",
  zipbaseurl = "https://ordsext.epa.gov/FLA/www3/state_files/"
)
```

## Arguments

- folder:

  path Default is NULL which means it is downloaded to a temp folder.

- zfile:

  filename

- zipbaseurl:

  url

## Value

The full path and file name of the downloaded zip file

## Details

See
<https://www.epa.gov/frs/epa-frs-facilities-state-single-file-csv-download>

and <https://echo.epa.gov/tools/data-downloads/frs-download-summary>

## See also

Used by
[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
which uses
[`frs_get()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_get.md)
