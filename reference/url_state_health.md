# URL functions - Get URLs of useful report(s) on STATES containing the given fips, from countyhealthrankings.org

URL functions - Get URLs of useful report(s) on STATES containing the
given fips, from countyhealthrankings.org

## Usage

``` r
url_state_health(
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
  statereport = TRUE,
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

  Do not use directly here. passed here by
  [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md)

- ...:

  unused

## Value

vector of URLs to reports on enclosing states (or generic link if fips
invalid)

## Examples

``` r
x = url_state_health(fips_state_from_state_abbrev(c("DE", "GA", "MS")))
url_state_health(testinput_fips_mix)
if (FALSE) { # \dontrun{
browseURL(x)
} # }
```
