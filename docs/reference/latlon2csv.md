# helper function - combine lat/lon values into csv format

Combines a vector of latitudes and a vector of longitudes into one
vector of comma-separated pairs like latitude,longitude

## Usage

``` r
latlon2csv(lat, lon)
```

## Arguments

- lat:

  vector of latitudes

- lon:

  vector of longitudes

## Value

vector of comma-separated pairs (see example)

## Examples

``` r
   lat_example = c(30.01,30.26,30.51)
   lon_example = c(-90.61,-90.95,-91.23)
   latloncsv_example = c("30.01,-90.61", "30.26,-90.95", "30.51,-91.23")
   all.equal(latloncsv_example,
             latlon2csv(lat = lat_example, lon = lon_example)
   )
```
