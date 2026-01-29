# Get URL(s) for (new) EJSCREEN app with map centered at given point(s)

Get URL(s) for (new) EJSCREEN app with map centered at given point(s)

## Usage

``` r
url_ejscreenmap(
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  fips = NULL,
  wherestr = NULL,
  as_html = FALSE,
  linktext = "EJSCREEN",
  ifna = "https://pedp-ejscreen.azurewebsites.net/index.html",
  baseurl = "https://pedp-ejscreen.azurewebsites.net/index.html",
  ...
)
```

## Arguments

- sitepoints:

  data.frame with colnames lat, lon (or lat, lon parameters can be
  provided separately)

- lat, lon:

  vectors of coordinates, ignored if sitepoints provided, can be used
  otherwise, if shapefile and fips not used

- shapefile:

  shows URL of a EJSCREEN app map centered on the centroid of a given
  polygon, but does not actually show the polygon.

- fips:

  The FIPS code of a place to center map on (blockgroup, tract,
  city/cdp, county, state FIPS). It gets translated into the right
  wherestr parameter if fips is provided.

- wherestr:

  If fips and sitepoints (or lat and lon) are not provided, wherestr
  should be the street address, zip code, or place name (not FIPS
  code!).

  Note that nearly half of all county fips codes are impossible to
  distinguish from 5-digit zipcodes because the same numbers are used
  for both purposes.

  For zipcode 10001, use url_ejscreenmap(wherestr = '10001')

  For County FIPS code 10001, use url_ejscreenmap(fips = "10001")

  This parameter is passed to the API as wherestr= , if point and fips
  are not specified.

  Can be State abbrev like "NY" or full state name, or city like "New
  Rochelle, NY" as from fips2name() – using fips2name() works for state,
  county, or city FIPS code converted to name, but using the fips
  parameter is probably a better idea.

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
`url_ejscreenmap()`
[`url_echo_facility()`](https://ejanalysis.github.io/EJAM/reference/url_echo_facility.md)
[`url_frs_facility()`](https://ejanalysis.github.io/EJAM/reference/url_frs_facility.md)
[`url_enviromapper()`](https://ejanalysis.github.io/EJAM/reference/url_enviromapper.md)

## Examples

``` r
# browseURL(url_ejscreenmap(fips = '10001'))
# browseURL(url_ejscreenmap(sitepoints = testpoints_10[1,]))
# shp = shapefile_from_any(  testdata("portland.*zip")[1])[1, ]
shp = testinput_shapes_2[1,]
 url_ejscreenmap(shapefile = shp)
```
