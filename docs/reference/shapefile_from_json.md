# read .json or .geojson shapefile data

read .json or .geojson shapefile data

## Usage

``` r
shapefile_from_json(path, cleanit = TRUE, crs = 4269, layer = NULL, ...)
```

## Arguments

- path:

  path and filename

- cleanit:

  optional, whether to use
  [`shapefile_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_clean.md)

- crs:

  passed to helper functions and default is crs = 4269 or Geodetic CRS
  NAD83

- layer:

  optional layer name passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame like output of
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
