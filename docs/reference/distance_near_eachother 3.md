# which points are near any of the others in a list?

which points are near any of the others in a list?

## Usage

``` r
distance_near_eachother(lon, lat, distance, or_tied = FALSE)
```

## Arguments

- lon:

  longitude

- lat:

  latitude

- distance:

  distance between points in miles to check

- or_tied:

  if TRUE, checks if less than or equal to distance, otherwise if less
  than

## Value

logical vector the length of lon or lat, telling if the point is within
distance of any other point in list for example, which sites have
residents that might also be near others sites?

## Examples

``` r
mapfast(testpoints_500[distance_near_eachother(
  lon = testpoints_500$lon,
  lat = testpoints_500$lat,
  3.1), ], radius = 3.1)
```
