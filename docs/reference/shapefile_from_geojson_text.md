# read text string that is geojson, return spatial data.frame helper for [`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)

read text string that is geojson, return spatial data.frame helper for
[`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)

## Usage

``` r
shapefile_from_geojson_text(x, quiet = FALSE)
```

## Arguments

- x:

  single text string like from
  [`shape2geojson()`](https://ejanalysis.github.io/EJAM/reference/shape2geojson.md)

- quiet:

  whether to avoid warning on failure

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame like from
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## See also

[`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)
