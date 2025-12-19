# Convert shapefile (class sf) to data.table of lat and lon columns Makes lat and lon columns, from a sfc_POINT class geometry field, or finds centroids of POLYGONS

Convert shapefile (class sf) to data.table of lat and lon columns Makes
lat and lon columns, from a sfc_POINT class geometry field, or finds
centroids of POLYGONS

## Usage

``` r
latlon_from_shapefile(shp, include_only_latlon = TRUE)
```

## Arguments

- shp:

  shapefile that is class sf, as from
  [`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)
  or
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
  with geometry column that has points so is class sfc_POINT

- include_only_latlon:

  set to FALSE to have function return lat lon columns plus all of
  columns in shp. If TRUE, just returns lat lon columns.

## Value

[data.table](https://r-datatable.com) with columns named lat and lon,
and optionally all from shp as well, as can be used as input to
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
[`mapfast()`](https://ejanalysis.github.io/EJAM/reference/mapfast.md),
etc.

## See also

[`latlon_from_shapefile_centroids()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_shapefile_centroids.md)
