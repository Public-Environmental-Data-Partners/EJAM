# Get EJScreen community report or data via the EJAM API

Get EJScreen community report or data via the EJAM API

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
  scale = c("blockgroup", "county"),
  baseurl = "https://ejamapi-84652557241.us-central1.run.app/",
  endpoint = c("data", "report", "query"),
  browse = TRUE,
  save_and_return_html = TRUE,
  ejamit_format = FALSE,
  fileextension = c("html", "pdf"),
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

  base API URL without the endpoint path

- endpoint:

  "data", "report", or "query".

  - "data" will return EJAM analysis data as a data.frame for one or
    more places, and

  - "report" will generate the EJAM report in HTML format for one place
    (or PDF format if fileextension = "pdf")

  - "query" returns a data.frame of blockgroups, filtered using
    parameters such as attribute="pctlowinc" for the variable name, and
    value=0.95 for the cutoff, filtering to only values at/above the
    cutoff.

- browse:

  for endpoint="report", set TRUE to launch a browser to view the report
  (in addition to getting the html as output of the function)

- save_and_return_html:

  For when endpoint="report" and fileextension="html".

  - Setting save_and_return_html=TRUE will return htmltools::HTML() text
    objects and
    [`htmltools::save_html()`](https://rstudio.github.io/htmltools/reference/save_html.html)
    can be used to save .html file(s)

  - Setting save_and_return_html=FALSE will just display the report(s)
    in the browser or RStudio viewer using
    [`browseURL()`](https://rdrr.io/r/utils/browseURL.html).

- ejamit_format:

  set TRUE to get output formatted more like output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  for convenience, so it can be used as input to
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  for example, but importantly note (until the API supports summary
  analysis over multiple locations) the API does not return a summary
  overall across sites, so results_overall will be just a placeholder,
  for the first site, not an overall summary across all sites.

- fileextension:

  can be "html" or "pdf", only relevant if endpoint = "report"

- dry_run:

  set to TRUE to see preview info about what the API call would look
  like.

- ...:

  other parameters, passed to
  [`httr2::req_body_json()`](https://httr2.r-lib.org/reference/req_body.html)
  in the "data" case, passed to
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
  in the "report" case, and used for the required `attribute` and
  `value` parameters in the "query" case

## Value

If dry_run=TRUE

- for the "report" endpoint, returns the URL(s) as vector.

- for the "data" or "query" endpoint, returns the (one) request itself,
  via the httr2 package.

If dry_run=FALSE

- for the "data" endpoint, returns a data.frame, one row per site
  (unless ejamit_format=TRUE, in which case it returns a named list
  somewhat like output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  so it can work in some functions like
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)).

- for the "query" endpoint, returns a data.frame, one row per matching
  blockgroup.

- for the "report" endpoint,

  - if fileextension is "html" and save_and_return_html=TRUE, invisibly
    returns a list of html reports

  - if fileextension is "html" and save_and_return_html=FALSE, invisibly
    returns a list of URLs

  - if fileextension is "pdf", invisibly returns a list of file paths

## Details

This is a utility, a wrapper function to make API calls for data or
report from the EJAM API. Note this function would be most useful to an
R user who does NOT have EJAM installed. Anyone who already has the EJAM
package installed can more quickly and flexibly get reports directly
locally via
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
for the "data", and
[`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
for the "report". The API call provides fewer features/options.

This function requires the geojsonsf, httr2, jsonlite, htmltools, rlang,
and utils packages.

For the "report" endpoint, the EJAM package version of this function
uses
[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
and related helper functions to convert the parameters to a URL for the
API as a GET request to obtain an HTML report.

## See also

[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

## Examples

``` r
# also see ?EJAM::url_ejamapi()
eg <- TRUE

# one blockgroup
xbg1 = ejamapi(fips="050014801001", endpoint='report',
 dry_run=eg, browse = FALSE)
if (interactive()) {htmltools::html_print(xbg1)}

# attribute-based query endpoint examples in live EJAM API
qreq1 <- ejamapi(
  endpoint = "query", attribute = "pctunemployed", value = 0.90,
  dry_run = eg)

qreq2 <- ejamapi(
  endpoint = "query", attribute = "pctlowinc", value = 0.80,
  dry_run = eg)
if (!eg) {
# all blockgroups in 1 county
xcounty = ejamapi(fips="10001", scale="blockgroup", endpoint = "data", dry_run=eg)
t(xcounty[1:4,3:100])

# one point, report endpoint
xpoint1 = ejamapi(lat = 45, lon = -118,
  endpoint = 'report', buffer = 3.1,
  dry_run = eg, browse=FALSE)
htmltools::html_print(xpoint1[[1]])

# multiple points, data endpoint
pts = data.frame(lat = c(44,45), lon = c(-117,-118))
y2a = ejamapi(sites = pts, buffer = 3.1, endpoint = 'data', dry_run=eg)
y2a[,3:14]

# map the results
mapview::mapview(sf::st_as_sf(
 y2a[,1:15],
 coords = c("lon", "lat"), crs = 4286))

# format like ejamit() output, to be able to use ejam2xyz functions
pts = data.frame(
  lat = c(37.64122, 43.92249),
  lon = c(-122.41065, -72.663705))
y2 = ejamapi(sites=pts, buffer=3.1, endpoint="data", dry_run=eg,
  ejamit_format = TRUE)
t(y2$results_bysite[,3:100])
# to map the results without using EJAM functions:
mapview::mapview(sf::st_as_sf(
  y2$results_bysite[,1:15],
  coords = c("lon", "lat"), crs = 4286))

# using EJAM functions to see a report even if data endpoint had been used:
EJAM::ejam2report(y2, sitenumber = 1)
EJAM::ejam2report(y2, sitenumber = 2)
zz = EJAM::ejam2table_tall(y2, sitenumber = 2)
head(zz, 50)
}
```
