# URL functions - Get URLs of useful report(s) on County containing the given fips, from countyhealthrankings.org

URL functions - Get URLs of useful report(s) on County containing the
given fips, from countyhealthrankings.org

## Usage

``` r
url_county_equityatlas(
  fips = NULL,
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  as_html = FALSE,
  linktext = "County (Equity Atlas)",
  ifna = "https://nationalequityatlas.org",
  baseurl = "https://nationalequityatlas.org/research/data_summary",
  statereport = FALSE,
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

  Do not use directly. Used by
  [`url_state_equityatlas()`](https://ejanalysis.github.io/EJAM/reference/url_state_equityatlas.md).
  if TRUE, gets report on enclosing State/DC/PR, not county. if FALSE,
  returns NA when given a State fips, otherwise return report on
  enclosing county.

- ...:

  unused

## Value

vector of URLs to reports on enclosing counties (or generic link if
necessary, like when input was a state fips)

## Examples

``` r
 url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
 # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
```
