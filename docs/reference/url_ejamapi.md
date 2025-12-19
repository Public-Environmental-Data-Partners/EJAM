# Get URL(s) of HTML summary reports for use with EJAM-API

Get URL(s) of HTML summary reports for use with EJAM-API

## Usage

``` r
url_ejamapi(
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  radius = 3,
  fips = NULL,
  shapefile = NULL,
  dTolerance = 100,
  linktext = "Report",
  as_html = FALSE,
  ifna = "https://ejanalysis.com",
  baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?",
  sitenumber = "each",
  ...
)
```

## Arguments

- sitepoints:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- lat, lon:

  can be provided as vectors of coordinates instead of providing
  sitepoints table

- radius:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
  default is 0 if fips or shapefile specified

- fips:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  but this initial version only works for a blockgroup FIPS!

- shapefile:

  see
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
  but each polygon is encoded as geojson string which might get too long
  for encoding in a URL for the API using GET

- dTolerance:

  number of meters tolerance to use in
  [`sf::st_simplify()`](https://r-spatial.github.io/sf/reference/geos_unary.html)
  to simplify polygons to fit as url-encoded text geojson

- linktext:

  used as text for hyperlinks, if supplied and as_html=TRUE

- as_html:

  Whether to return as just the urls or as html hyperlinks to use in a
  DT::datatable() for example

- ifna:

  URL shown for missing, NA, NULL, bad input values

- baseurl:

  do not change unless endpoint actually changed

- sitenumber:

  - "each" (or -1) means return each site's URL

  - "overall" (or 0) means return one URL, combining all sites

  - N (a number \> 0) means return just the Nth site's URL

  Like with other url_xyz functions, the default is to output a vector
  of URLs, one per site. The default value for sitenumber is "each" or
  -1 which means we want one url for each site. Note there is no
  comparable value of sitenumber in the ejam2report() or ejam2map() or
  similar functions, which never return a vector of reports, maps, etc.
  Getting a vector of 1 per site is useful mainly for the url_xyz
  functions like url_ejamapi().

  Like the sitenumber parameter in
  [`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md),
  a value of NULL or 0 or "" or "overall" in url_ejamapi() means a
  single URL is returned that requests one overall summary report
  (assuming \>1 sites were provided).

  Specifying sitenumber as a number like 3 means a report based on the
  third site found in the inputs (third point or third fips or third
  polygon).

- ...:

  a named list of other query parameters passed to the API, to allow for
  expansion of allowed parameters

## Value

vector of character string URLs – see details on sitenumber parameter

## Details

- Work in progress - initial draft relied on API from
  https://github.com/edgi-govdata-archiving/EJAM-API

  (see parameter `baseurl` that used the /report endpoint)

- Another option in the future might be to construct a URL that is a
  link to the live EJAM app but has url-encoded parameters that are app
  settings, such as sitepoints, radius_default, etc.

- Will try to use the same input parameters as
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  does.

## Examples

``` r
 pts = data.frame(lat=37.64122, lon=-122.41065)
 pts2 = data.frame(lat = c(37.64122, 43.92249), lon = c(-122.41065, -72.663705))
 pts10 = testpoints_10
 pts_fname = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM")

  # vector of 1-site report URLs
 x = url_ejamapi(pts_fname)
 x = url_ejamapi(sitepoints = pts2)
 x_bysite = url_ejamapi(pts10, radius = 3.1, sitenumber = "each")

 ## 1 summary report URL - may not be implemented yet
 # x_overall = url_ejamapi(pts10, radius = 3.1, sitenumber = "overall")

 # FIPS Census units
 y = url_ejamapi(fips = c("050014801001", "050014802001"))
 ## blockgroups may not be implemented yet
 # y = url_ejamapi(fips = testinput_fips_mix)

 # Polygons
 shp = testinput_shapes_2[2, c("geometry", "FIPS", "NAME")]
 z = url_ejamapi(shapefile = shp)

 if (FALSE) { # \dontrun{
 browseURL("https://ejamapi-84652557241.us-central1.run.app/report?lat=33&lon=-112&buffer=4")

 browseURL(x[1])
 browseURL(y[1])
 browseURL(z[1])
} # }
```
