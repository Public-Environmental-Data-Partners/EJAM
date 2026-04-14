# Find what state is where each point is located

Find what state is where each point is located

## Usage

``` r
fips_state_from_latlon(sitepoints = NULL, lat = NULL, lon = NULL)
```

## Arguments

- sitepoints:

  data.frame with lat,lon columns

- lat:

  latitudes vector if sitepoints not provided

- lon:

  longitudes vector if sitepoints not provided

## Value

just vector of fips, unlike
[`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)

## See also

[`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)
