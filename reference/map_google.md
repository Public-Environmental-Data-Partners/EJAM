# Map - Open Google Maps in browser

Map - Open Google Maps in browser

## Usage

``` r
map_google(lat, lon, zoom = 12, point = TRUE, launch_browser = TRUE)
```

## Arguments

- lat:

  - Anything that can be handled by
    [`sitepoints_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md).
    Leave unspecified to interactively browse to a .xlsx file that has
    lat,lon columns, or lat can be a data.frame with lat,lon column
    names in which case longitude should not be provided, such as
    `lat = testpoints_10[1,]`, or lat and lon can be separately provided
    as vectors.

- lon:

  longitude, or omit this parameter to provide points as the first
  parameter.

- zoom:

  zoomed out value could be 3 or 5, zoomed in default is 12

- point:

  logical optional, passed to
  [`url_map_google()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_map_google.md)

- launch_browser:

  logical, whether to launch browser

## Value

opens a browser window with Google Maps centered on the specified lat,
lon

## Examples

``` r
# map_google(testpoints_10[1,])
```
