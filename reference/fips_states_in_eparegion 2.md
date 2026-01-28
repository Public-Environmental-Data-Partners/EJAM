# FIPS - Get state fips for all States in EPA Region(s)

FIPS - Get state fips for all States in EPA Region(s)

## Usage

``` r
fips_states_in_eparegion(region)
```

## Arguments

- region:

  vector of 1 or more EPA Regions (numbers 1 through 10)

## Value

vector of 2-digit state FIPS codes like c("10", "44", "44"), same length
as input, so including any duplicates

## Examples

``` r
  fips_states_in_eparegion(2)
  fips_states_in_eparegion(6)
  fips2stateabbrev(fips_states_in_eparegion(6))
```
