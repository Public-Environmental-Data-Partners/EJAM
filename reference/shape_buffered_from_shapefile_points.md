# shape_buffered_from_shapefile_points - add buffer around shape (points, here)

shape_buffered_from_shapefile_points - add buffer around shape (points,
here)

## Usage

``` r
shape_buffered_from_shapefile_points(
  shapefile_points,
  radius.miles = NULL,
  crs = 4269,
  ...
)
```

## Arguments

- shapefile_points:

  spatial object like areas at high risk or areas with facilities to be
  analyzed

- radius.miles:

  width of buffer to add to shapefile_points (in case dist is a units
  object, it should be convertible to arc_degree if x has geographic
  coordinates, and to st_crs(x)\$units otherwise)

- crs:

  used in st_transform() default is crs = 4269 or Geodetic CRS NAD83

- ...:

  passed to st_buffer()

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame, same format as
[`sf::st_buffer()`](https://r-spatial.github.io/sf/reference/geos_unary.html)
returns

## Details

Just a wrapper for
[`sf::st_buffer()`](https://r-spatial.github.io/sf/reference/geos_unary.html)

## See also

[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
[`shapefile_from_sitepoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_sitepoints.md)
`shape_buffered_from_shapefile_points()`

## Examples

``` r
map_shapes_leaflet(
  shape_buffered_from_shapefile_points(
    shapefile_from_sitepoints(testpoints_100),
    radius.miles = 3
  )
)
# (ignoring projections for this example)
# compare to
mapfast(testpoints_100)
```
