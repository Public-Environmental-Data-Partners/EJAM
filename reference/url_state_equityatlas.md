# URL functions - Get URLs of useful report(s) on STATE containing the given fips, from equity atlas

URL functions - Get URLs of useful report(s) on STATE containing the
given fips, from equity atlas

## Usage

``` r
url_state_equityatlas(
  fips = NULL,
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  as_html = FALSE,
  linktext = "State (Equity Atlas)",
  ifna = "https://nationalequityatlas.org",
  baseurl = "https://nationalequityatlas.org/research/data_summary",
  statereport = TRUE,
  ...
)
```

## Arguments

- fips:

  vector of fips codes

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

  Do not use directly. passed to
  [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md).

- ...:

  unused

## Value

vector of URLs to reports on enclosing states (or generic link if fips
invalid)

## Examples

``` r
 url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
 # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
```
