# FIPS - Get state fips for each state name

FIPS - Get state fips for each state name

## Usage

``` r
fips_state_from_statename(statename)
```

## Arguments

- statename:

  vector of state names like c("New York","Georgia"), ignoring case.
  Converts any ST to statename in case abbreviations were provided
  instead of name.

## Value

vector of 2-digit state FIPS codes like c("10", "44", "44"), same length
as input, so including any duplicates

## Examples

``` r
  fips_state_from_statename("Delaware")
  fips_state_from_statename(c("dc", 'district of columbia', 'georgia'))
```
