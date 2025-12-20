# utility to check if internet connection is not available

utility to check if internet connection is not available

## Usage

``` r
offline(url = "r-project.org")
```

## Arguments

- url:

  optional URL checked, using
  [`curl::nslookup()`](https://jeroen.r-universe.dev/curl/reference/nslookup.html)

## Value

logical (TRUE or FALSE), TRUE if offline, FALSE if can connect to
r-project.org

## See also

offline_warning() and offline_cat() utilities unexported undocumented,
either returns the same as offline() does, while also providing, if
offline, warning() or cat() info to console
