# helper function - convert vector of lat,lon pairs to data.frame

helper function - convert vector of lat,lon pairs to data.frame

## Usage

``` r
latlon_from_vectorofcsvpairs(x)
```

## Arguments

- x:

  vector of comma-separated pairs of lat,lon values stored as character
  strings such as c("30,-83", " 32.5, -86.377325 ")

## Value

data.frame with colnames lat and lon

## Examples

``` r
lat_x = testpoints_10$lat
lon_x = testpoints_10$lon
latlon_pairs = latlon2csv(lat = lat_x, lon = lon_x)
latlon_from_vectorofcsvpairs(latlon_pairs)
all.equal(testpoints_10[, c("lat", "lon")], latlon_from_vectorofcsvpairs(latlon_pairs))

x = latlon_from_vectorofcsvpairs(c("30,-83",  "  32.5,  -86.377325 "))
x
latlon_is.valid(x)
```
