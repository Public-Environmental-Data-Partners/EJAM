# Drop invalid rows, warn if all invalid, add unique ID, transform (CRS)

Drop invalid rows, warn if all invalid, add unique ID, transform (CRS)

## Usage

``` r
shapefile_clean(shp, crs = 4269)
```

## Arguments

- shp:

  a shapefile object using sf::st_read()

- crs:

  used in shp \<- sf::st_transform(shp, crs = crs), default is crs =
  4269 or Geodetic CRS NAD83

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame like input shp, but applying crs and dropping if not valid,
plus column ejam_uniq_id 1:NROW()

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
