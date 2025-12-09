# helper function - combine lat/lon values to paste into NEXUS tool

Converts 2 vectors of values for latitude and longitude into a format
you can paste into NEXUS tool lat/lon site selection box

## Usage

``` r
latlon2nexus(lat, lon)
```

## Arguments

- lat:

  vector of latitudes

- lon:

  vector of longitudes

## Value

a single character string that has all the csv pairs, with a semicolon
between each pair and the next like "30.01,-90.61; 30.26,-90.95;
30.51,-91.23"

## Examples

``` r
  lat_example = c(30.01,30.26,30.51)
  lon_example = c(-90.61,-90.95,-91.23)
  latlon2nexus(lat=lat_example, lon=lon_example)
```
