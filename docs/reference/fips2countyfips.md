# FIPS - Get FIPS codes of the Counties CONTAINING the given census units (of any type)

FIPS - Get FIPS codes of the Counties CONTAINING the given census units
(of any type)

## Usage

``` r
fips2countyfips(fips)
```

## Arguments

- fips:

  vector of FIPS codes where fipstype(fips) is among block, blockgroup,
  tract, city, county, state but where it is a state this will return NA

## Value

vector of fips as long as input

## Examples

``` r
fips2countyfips(testinput_fips_blockgroups[1])
```
