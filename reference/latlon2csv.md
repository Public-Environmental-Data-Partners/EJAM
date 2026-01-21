# helper function - combine lat/lon values into csv format

Combines a vector of latitudes and a vector of longitudes into one
vector of comma-separated pairs like latitude,longitude

## Usage

``` r
latlon2csv(lat, lon, sep = ",")
```

## Arguments

- lat:

  vector of latitudes

- lon:

  vector of longitudes

- sep:

  optional separator, like "," (default), or ", " (with a space) or "\|"

## Value

vector of comma-separated pairs (see example)

## Examples

``` r
lat_example = c(41,42,43)
lon_example = c(-100,-90,-80)
latloncsv_example = c("41,-100", "42,-90", "43,-80")
all.equal(latloncsv_example,
          latlon2csv(lat = lat_example, lon = lon_example)
)
latlon2csv(lat = lat_example, lon = lon_example)

# Note slight changes can occur in lat,lon values if just using
# paste(lat,lon,sep=',) instead of format() as noted in ?as.character()
testpoints_10[1, c("lat","lon")]
latlon2csv(lat = testpoints_10$lat[1], lon = testpoints_10$lon[1])
```
