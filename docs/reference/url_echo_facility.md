# Get URLs of ECHO reports

Get URL(s) for EPA ECHO webpage with facility information

## Usage

``` r
url_echo_facility(
  regid = NULL,
  validate_regids = TRUE,
  as_html = FALSE,
  linktext = "ECHO",
  ifna = "https://echo.epa.gov",
  baseurl = "https://echo.epa.gov/detailed-facility-report?fid=",
  ...
)
```

## Arguments

- regid:

  EPA FRS Registry ID

- validate_regids:

  if set TRUE, returns NA where a regid is not found in the FRS dataset
  that is currently being used by this package (which might not be the
  very latest from EPA). If set FALSE, faster since avoids checking but
  some links might not work and not warn about bad regid values.

- as_html:

  Whether to return as just the urls or as html hyperlinks to use in a
  DT::datatable() for example

- linktext:

  used as text for hyperlinks, if supplied and as_html=TRUE

- ifna:

  URL shown for missing, NA, NULL, bad input values

- baseurl:

  do not change unless endpoint actually changed

- ...:

  unused - allows it to ignore things like lat, lon, if called from
  [`url_columns_bysite()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_columns_bysite.md)

## Value

URL(s)

## Details

Additional details...

## See also

[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
[`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
`url_echo_facility()`
[`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md)
[`url_enviromapper()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_enviromapper.md)

[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
[`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
`url_echo_facility()`
[`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md)
[`url_enviromapper()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_enviromapper.md)

## Examples

``` r
 # \donttest{
 browseURL(url_echo_facility(110070874073))
 # }
```
