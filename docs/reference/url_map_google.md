# Map - get URL(s) that would display map(s) on maps.google.com

Map - get URL(s) that would display map(s) on maps.google.com

## Usage

``` r
url_map_google(lat, lon, zoom = 13, point = TRUE)
```

## Arguments

- lat:

  - Anything that can be handled by
    [`sitepoints_from_any()`](https://ejanalysis.github.io/EJAM/reference/sitepoints_from_any.md).
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

  logical, if TRUE, URL will have a marker at the point and zoom
  parameter is ignored. Otherwise just the map.

## Value

URL(s) vector one per point

## See also

[`map_google()`](https://ejanalysis.github.io/EJAM/reference/map_google.md)
