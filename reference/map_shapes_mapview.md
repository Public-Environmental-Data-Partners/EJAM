# Map - polygons - Use mapview package if available

Map - polygons - Use mapview package if available

## Usage

``` r
map_shapes_mapview(
  shapes,
  col.regions = "green",
  map.types = "OpenStreetMap",
  ...
)
```

## Arguments

- shapes:

  like from
  shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE"))

- col.regions:

  passed to
  [`mapview::mapview()`](https://r-spatial.github.io/mapview/reference/mapView.html)

- map.types:

  passed to
  [`mapview::mapview()`](https://r-spatial.github.io/mapview/reference/mapView.html)

- ...:

  passed to mapview

## Value

like output of mapview function
[`mapview::mapview()`](https://r-spatial.github.io/mapview/reference/mapView.html),
if mapview package is installed, when used with an input that is a
spatial object as via
[`sf::read_sf()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Examples

``` r
 # \donttest{
  map_shapes_mapview(
    shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE"))
  )
# }

out = ejamit(testpoints_10[1,], radius = 20)
map_shapes_mapview(
  ejam2shapefile(out, save = FALSE),
  popup = popup_from_ejscreen(out$results_bysite)
)
```
