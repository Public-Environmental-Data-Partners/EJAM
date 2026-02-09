# Map popups - make simple popups for map to show info about uploaded points

Map popups - make simple popups for map to show info about uploaded
points

## Usage

``` r
popup_from_uploadedpoints(mypoints, n = "all")
```

## Arguments

- mypoints:

  data.frame (or tibble?) with lat and lon columns preferably

- n:

  Show the first n columns of mypoints, in popup. "all" means all of
  them.

## Value

popups vector to be used in leaflet maps

## See also

[`popup_from_any()`](https://ejanalysis.github.io/EJAM/reference/popup_from_any.md)
