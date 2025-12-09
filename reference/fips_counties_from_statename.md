# FIPS - Get ALL county fips in specified states

FIPS - Get ALL county fips in specified states

## Usage

``` r
fips_counties_from_statename(statename)
```

## Arguments

- statename:

  vector of state names like c("New York","Georgia"), ignoring case

## Value

vector of 5-digit character string county FIPS of all unique counties in
those states

## Examples

``` r
fips_counties_from_statename("Delaware")
```
