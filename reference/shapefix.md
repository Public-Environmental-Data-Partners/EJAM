# shapefix cleans a spatial data.frame, flags invalid rows, add id if missing, etc.

a way for app_server, and ejamit() via shapefile_from_any(), to both use
this one function to do the same thing whether or not in a reactive
context

## Usage

``` r
shapefix(shp, crs = 4269)
```

## Arguments

- shp:

  simple feature data.frame

- crs:

  coordinate reference system, default is 4269

## Value

returns all rows of shp, but adds columns "valid" and "invalid_msg" and
adds attributes shiny can use to update some reactives, and standardizes
"geometry" as the sfc column name.
