# helper function - combine lat/lon values to paste into NEXUS tool

Converts vector of comma-separated values for latitude and longitude
into a format you can paste into NEXUS tool lat/lon site selection box

## Usage

``` r
latloncsv2nexus(latloncsv)
```

## Arguments

- latloncsv:

  a vector of comma-separated values with lat,lon

## Value

a single character string that has all the csv pairs, with a semicolon
between each pair and the next, like
"30.01,-90.61;30.26,-90.95;30.51,-91.23"

## Examples

``` r
 latloncsv_example = c("30.01,-90.61", "30.26,-90.95", "30.51,-91.23")
 latloncsv2nexus(latloncsv_example)
```
