# FIPS - Get ALL county fips in specified states

FIPS - Get ALL county fips in specified states

## Usage

``` r
fips_counties_from_statefips(statefips)
```

## Arguments

- statefips:

  vector of 2-digit state FIPS codes like c("10", "44", "44") or
  c(10,44)

## Value

vector of 5-digit character string county FIPS of all unique counties in
those states

## Details

Very similar to list_counties(state) from the tigris package.

## Examples

``` r
  fips_counties_from_statefips(c(10,44,44))
  fips_counties_from_statefips("10")
```
