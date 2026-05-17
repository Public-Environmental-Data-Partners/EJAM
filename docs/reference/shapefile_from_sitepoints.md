# Convert table of lat,lon points/sites into spatial data.frame / shapefile

Creates a simple feature (sf) class spatial data.frame from points

## Usage

``` r
shapefile_from_sitepoints(sitepoints, crs = 4269, ...)
```

## Arguments

- sitepoints:

  a table in [data.table](https://r-datatable.com) format or data.frame
  with columns called lat,lon (or aliases of those)

- crs:

  used in st_as_sf() default is crs = 4269 or Geodetic CRS NAD83

- ...:

  passed to
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame via
[`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html).
Note other columns get returned, and the lat,lon columns do get returned
but as "lat" and "lon" even if they were provided as aliases of those

## See also

[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
`shapefile_from_sitepoints()`
[`shape_buffered_from_shapefile_points()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape_buffered_from_shapefile_points.md)
