# FIPS - Get ALL county fips in specified states

FIPS - Get ALL county fips in specified states

## Usage

``` r
fips_counties_from_state_abbrev(ST)
```

## Arguments

- ST:

  vector of state abbreviations like c("NY","GA"), ignoring case

## Value

vector of 5-digit character string county FIPS of all unique counties in
those states

## Examples

``` r
  fips_counties_from_state_abbrev("DE")
  fips_counties_from_state_abbrev(c("RI", "RI"))
```
