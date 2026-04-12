# get coordinates of each polygon centroid, using INTPTLAT,INTPTLON if those columns already exist

get coordinates of each polygon centroid, using INTPTLAT,INTPTLON if
those columns already exist

## Usage

``` r
latlon_from_shapefile_centroids(shapefile)
```

## Arguments

- shapefile:

  spatial data.frame of polygons

## Value

data.frame with columns lat,lon

## See also

[`latlon_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_fips.md)
[`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md)
