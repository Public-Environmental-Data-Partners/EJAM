# helper for using the EJAM API, a wrapper function to make API calls for data or report Note this function would be most useful to an R user who does NOT have EJAM installed.

helper for using the EJAM API, a wrapper function to make API calls for
data or report Note this function would be most useful to an R user who
does NOT have EJAM installed.

## Usage

``` r
ejamapi(
  lat = NULL,
  lon = NULL,
  sites = NULL,
  sitepoints = NULL,
  shape = NULL,
  shapefile = NULL,
  fips = NULL,
  buffer = NULL,
  radius = NULL,
  geometries = FALSE,
  scale = "blockgroup",
  baseurl = "https://ejamapi-84652557241.us-central1.run.app/",
  endpoint = c("data", "report")[1],
  browse = TRUE,
  ejamit_format = FALSE,
  dry_run = FALSE,
  ...
)
```

## Arguments

- lat, lon:

  Coordinates of point(s) for analysis of residents nearby. To specify
  point(s), provide either lat and lon, or sites, or sitepoints – they
  are alternative ways to specify point(s). For the "report" endpoint,
  specify only one point (until the API supports summary analysis over
  multiple locations). For the "data" endpoint, specify one or more
  points.

- sites, sitepoints:

  Only one of these should be provided - they are synonymous.
  Coordinates of point(s) for analysis of residents nearby. sites or
  sitepoints, if provided, must be a data.frame with colnames "lat" and
  "lon", 1 row per point. Like the sitepoints param in
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

- shape, shapefile:

  Only one of these should be provided - they are synonymous. A GeoJSON
  string representing the area of interest, like shapefile param in
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

- fips:

  A FIPS code for a specific US Census geography, like "050014801001",
  and must be consistent with the scale parameter

- buffer, radius:

  Only one of these should be provided - they are synonymous. The buffer
  radius in miles, like radius param in
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

- geometries:

  A boolean to indicate whether to include geometries in the output,
  relevant only for the "data" endpoint

- scale:

  Only used if fips is provided and the endpoint is "data". Ignored for
  the endpoint "report". Assuming fips is provided: If scale is not
  specified, the API tries to return results for each of the fips. If
  scale is specified and is "county" or "blockgroup", the API tries to
  return one result for each "county" or "blockgroup" that is found
  within the specified fips. For example, all counties in specified
  State fips, or all blockgroups in specified County fips.

- baseurl:

  the URL and endpoint of the API

- endpoint:

  "data" or "report": "data" will return EJAM analysis data for one or
  more places, and "report" will generate one EJAM report in HTML format
  for one place (until the API supports summary analysis over multiple
  locations)

- browse:

  for endpoint="report", set TRUE to launch a browser to view the report
  (in addition to getting the html as output of the function)

- ejamit_format:

  set TRUE to get output formatted more like output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  for convenience, so it can be used as input to
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  for example, but importantly note (until the API supports summary
  analysis over multiple locations) the API does not return a summary
  overall across sites, so results_overall will be just a placeholder,
  for the first site, not an overall summary across all sites.

- dry_run:

  set to TRUE to see preview info about what the API call would look
  like.

- ...:

  other parameters, passed to
  [`httr2::req_body_json()`](https://httr2.r-lib.org/reference/req_body.html)
  in the "data" case, and passed to
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
  in the "report" case

## Value

data.frame if using data endpoint, list of html reports if using report
endpoint, or if ejamit_format=TRUE and "data" is the endpoint, returns a
named list somewhat like output of
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
so it can work in some functions like
[`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md).
If dry_run=TRUE, for the "data" endpoint, the request itself, via the
httr2 package, is returned, and for the "report" endpoint the URL is
returned.

## Details

Note this function would be most useful to an R user who does NOT have
EJAM installed. Anyone who already has the EJAM package installed can
more quickly and flexibly get reports directly locally via
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
for the "data", and
[`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
for the "report". The API call provides fewer features/options.

This function requires the geojsonsf, httr2, jsonlite, htmltools, and
rlang packages.

For the "report" endpoint, it additionally currently requires the EJAM
package just for the
[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
function that converts the parameters to a URL for the API as a GET
request to obtain an HTML report.

## See also

[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

## Examples

``` r
# also see ?EJAM::url_ejamapi()
eg <- TRUE
x1 = ejamapi(fips="050014801001", endpoint='report', dry_run=eg)
x2 = ejamapi(lat = 45, lon = -118, endpoint = 'report', buffer = 3.1, dry_run=eg)
htmltools::html_print(x2)

y1 = ejamapi(sites = data.frame(lat = c(44,45), lon = c(-117,-118)),
  buffer = 3.1, endpoint = 'data', dry_run=eg)
y1[,3:14]

pts=data.frame(
  lat = c(37.64122, 43.92249),
  lon = c(-122.41065, -72.663705))
y2 = ejamapi(sites=pts, buffer=3.1, endpoint="data",
  ejamit_format=T, dry_run=eg)
EJAM::ejam2report(y2, sitenumber=1)
EJAM::ejam2report(y2, sitenumber=2)
EJAM::ejam2table_tall(y2, sitenumber=2)
```
