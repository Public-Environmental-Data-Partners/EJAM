# URL functions - Get URLs of useful report(s) on Counties containing the given fips, from countyhealthrankings.org

URL functions - Get URLs of useful report(s) on Counties containing the
given fips, from countyhealthrankings.org

## Usage

``` r
url_county_health(
  fips = NULL,
  year = 2025,
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  as_html = FALSE,
  linktext = "County",
  ifna = "https://www.countyhealthrankings.org",
  baseurl = "https://www.countyhealthrankings.org/health-data/",
  statereport = FALSE,
  ...
)
```

## Arguments

- fips:

  vector of fips codes

- year:

  e.g., 2025

- sitepoints:

  if provided and fips is NULL, gets county fips from lat,lon columns of
  sitepoints

- lat, lon:

  ignored if sitepoints provided, can be used otherwise, if shapefile
  and fips not used

- shapefile:

  if provided and fips is NULL, gets county fips from lat,lon of polygon
  centroid

- as_html:

  Whether to return as just the urls or as html hyperlinks to use in a
  DT::datatable() for example

- linktext:

  used as text for hyperlinks, if supplied and as_html=TRUE

- ifna:

  URL shown for missing, NA, NULL, bad input values

- baseurl:

  do not change unless endpoint actually changed

- statereport:

  can be passed here by
  [`url_state_health()`](https://ejanalysis.github.io/EJAM/reference/url_state_health.md)
  if FALSE, returns NA when given a State fips, otherwise return report
  on enclosing county. if TRUE, gets report on enclosing State/DC/PR
  (not county).

- ...:

  unused

## Value

vector of URLs to reports on enclosing counties (or generic link if
necessary, like when input was a state fips)

## Examples

``` r
 url_county_health(fips_counties_from_state_abbrev("DE"))
 # browseURL(url_county_health(fips_counties_from_state_abbrev("DE"))[1])
```
