# helper - given filename, figure out type and return list of input params for ejamit() Do not actually read file but get list of sitepoints, fips, shapefile args to pass to ejamit()

helper - given filename, figure out type and return list of input params
for ejamit() Do not actually read file but get list of sitepoints, fips,
shapefile args to pass to ejamit()

## Usage

``` r
sites_from_file(file)
```

## Arguments

- file:

  a file name (with path) to look at

## Value

named list, with sitepoints, fips, shapefile as names

## See also

[`sites_from_input()`](https://ejanalysis.github.io/EJAM/reference/sites_from_input.md)
