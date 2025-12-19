# Check lat lon coordinates to see if each is approx. in general area of USA excluding Island Areas

Check lat lon coordinates to see if each is approx. in general area of
USA excluding Island Areas

## Usage

``` r
latlon_is.usa(lat, lon)
```

## Arguments

- lat:

  vector of latitudes

- lon:

  vector of longitudes

## Value

logical vector, one element per lat lon pair (location) Indicates the
point is approximately in one of the rough bounding boxes that includes
the USA without the Island Areas Guam, American Samoa, USVI, N Marianas
Islands.

## See also

`latlon_is.usa()`
[`latlon_is.islandareas()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.islandareas.md)
[`latlon_is.available()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.available.md)
[`latlon_is.possible()`](https://ejanalysis.github.io/EJAM/reference/latlon_is.possible.md)
