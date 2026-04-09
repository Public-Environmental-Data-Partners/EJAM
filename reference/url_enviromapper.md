# Get URLs of EnviroMapper reports

Get URL(s) for EnviroMapper web-based tool, to open map at specified
point location(s)

## Usage

``` r
url_enviromapper(
  sitepoints = NULL,
  lon = NULL,
  lat = NULL,
  shapefile = NULL,
  fips = NULL,
  zoom = 13,
  as_html = FALSE,
  linktext = "EnviroMapper",
  ifna = "https://geopub.epa.gov/myem/efmap/",
  baseurl = "https://geopub.epa.gov/myem/efmap/index.html?ve=",
  ...
)
```

## Arguments

- sitepoints:

  data.frame with colnames lat, lon (or lat, lon parameters can be
  provided separately)

- lat, lon:

  ignored if sitepoints provided, can be used otherwise, if shapefile
  and fips not used

- shapefile:

  if provided function uses centroids of polygons for lat lon

- fips:

  ignored

- zoom:

  initial map zoom extent

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

URL of one webpage (that launches the mapping tool)

## Details

EnviroMapper lets you view EPA-regulated facilities and other
information on a map, given the lat,lon

## See also

[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
[`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
[`url_echo_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_echo_facility.md)
[`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md)
`url_enviromapper()`

## Examples

``` r
x = url_enviromapper(testpoints_10[1,])
if (FALSE) { # \dontrun{
 browseURL(x)
 browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))
} # }
```
