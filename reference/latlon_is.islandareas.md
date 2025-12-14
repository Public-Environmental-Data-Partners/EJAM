# Check lat lon coordinates to see if each is approx. in general area of US Island Areas Guam, USVI, Amer Samoa or N Marianas

See
[islandareas](https://ejanalysis.github.io/EJAM/reference/islandareas.md)

## Usage

``` r
latlon_is.islandareas(lat, lon, exact_but_slow_islandareas = FALSE)
```

## Arguments

- lat:

  vector of latitudes

- lon:

  vector of longitudes

- exact_but_slow_islandareas:

  optional logical, set it to TRUE to check each point vs boundaries in
  [states_shapefile](https://ejanalysis.github.io/EJAM/reference/states_shapefile.md)
  to identify which ones are in Island Areas according to that
  shapefile. The default method here is much faster, but just checks if
  a point is within a bounding box that should approximate each of the
  Island Areas, found in the object
  [islandareas](https://ejanalysis.github.io/EJAM/reference/islandareas.md).

## Value

vector of TRUE / FALSE values indicating a given lat lon pair is
approximately in one of the rough bounding boxes that includes the 4
Island Areas.

## See also

[`is.island()`](https://ejanalysis.github.io/EJAM/reference/is.island.md)
[`latlon_is.usa()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.usa.md)
`latlon_is.islandareas()`
[`latlon_is.available()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.available.md)
[`latlon_is.possible()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.possible.md)

## Examples

``` r
  isles <- stateinfo2[ EJAM:::latlon_is.islandareas(lat = stateinfo2$lat, lon = stateinfo2$lon) & !is.na(stateinfo2$lat), ]
  mapfast(isles)
```
