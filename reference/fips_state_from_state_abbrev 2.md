# FIPS - Get state fips for each state abbrev

FIPS - Get state fips for each state abbrev

## Usage

``` r
fips_state_from_state_abbrev(ST)
```

## Arguments

- ST:

  vector of state abbreviations like c("NY","GA"), ignores case.
  Converts any statename to ST in case names were provided instead of
  ST.

## Value

vector of 2-digit state FIPS codes like c("10", "44", "44"), same length
as input, so including any duplicates

## Examples

``` r
fips_state_from_state_abbrev(c("DE", "DE", "RI", 'new jersey'))
```
