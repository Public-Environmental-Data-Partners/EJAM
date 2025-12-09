# Map - polygons - Update leaflet map by adding shapefile data, in shiny app

Map - polygons - Update leaflet map by adding shapefile data, in shiny
app

## Usage

``` r
map_shapes_leaflet_proxy(mymap, shapes, color = "green", popup = shapes$NAME)
```

## Arguments

- mymap:

  map like from leafletProxy()

- shapes:

  like from
  shapes_counties_from_countyfips(fips_counties_from_state_abbrev("DE"))

- color:

  passed to leaflet::addPolygons()

- popup:

  passed to leaflet::addPolygons()

## Value

html widget like from leaflet::leafletProxy()
