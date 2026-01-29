# Map - polygons - Create leaflet map from shapefile, in shiny app

Map - polygons - Create leaflet map from shapefile, in shiny app

## Usage

``` r
map_shapes_leaflet(
  shapes,
  color = "green",
  popup = NULL,
  fillOpacity = 0.5,
  ...
)
```

## Arguments

- shapes:

  like from
  shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE")),
  or at least a data.frame that can be interpreted as indicating points
  via
  [`shapefile_from_sitepoints()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_sitepoints.md)

- color:

  passed to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html)

- popup:

  passed to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html)

- fillOpacity:

  passed to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html)

- ...:

  passed to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html),
  such as opacity=1

## Value

html widget from leaflet::leaflet()

## Examples

``` r
out = testoutput_ejamit_10pts_1miles
out$results_bysite = out$results_bysite[1:2,]
map_shapes_leaflet(
  ejam2shapefile(out, save=F),
  popup = popup_from_ejscreen(out$results_bysite)
)
```
