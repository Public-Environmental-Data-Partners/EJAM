# Map - points - Update leaflet map of points, in shiny app

update a leaflet map within the EJAM shiny app with uploaded points such
as facilities

## Usage

``` r
map_facilities_proxy(
  mymap,
  rad = 3,
  highlight = FALSE,
  clustered = FALSE,
  popup_vec = NULL,
  use_marker_clusters = FALSE
)
```

## Arguments

- mymap, :

  leafletProxy map object to be added to

- rad, :

  a size for drawing each circle (buffer search radius)

- highlight, :

  a logical for whether to highlight overlapping points (defaults to
  FALSE)

- clustered, :

  a vector of T/F values for each point, indicating if they overlap with
  another

- popup_vec, :

  a vector of popup values to display when points are clicked. Length
  should match number of rows in the dataset.

- use_marker_clusters, :

  boolean for whether to group points into markerClusters. Uses logic
  from shiny app to only implement when n \> 1000.

## Value

a leaflet map with circles, circleMarkers, and basic popup
