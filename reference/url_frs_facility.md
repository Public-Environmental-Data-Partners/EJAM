# Get URLs of FRS reports

Get URL(s) for reports on facilities from EPA FRS (facility registry
service)

## Usage

``` r
url_frs_facility(
  regid = NULL,
  validate_regids = FALSE,
  as_html = FALSE,
  linktext = "FRS",
  ifna = "https://www.epa.gov/frs",
  baseurl =
    "https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id=",
  ...
)
```

## Arguments

- regid:

  one or more EPA FRS Registry IDs.

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

  unused

## Value

URL(s)

## See also

[`url_ejamapi()`](https://ejanalysis.github.io/EJAM/reference/url_ejamapi.md)
[`url_ejscreenmap()`](https://ejanalysis.github.io/EJAM/reference/url_ejscreenmap.md)
[`url_echo_facility()`](https://ejanalysis.github.io/EJAM/reference/url_echo_facility.md)
`url_frs_facility()`
[`url_enviromapper()`](https://ejanalysis.github.io/EJAM/reference/url_enviromapper.md)

## Examples

``` r
x = url_frs_facility(testinput_regid)
# \donttest{
browseURL(x[1])
# }
url_frs_facility(testinput_registry_id)
```
