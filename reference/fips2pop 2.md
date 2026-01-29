# Get population counts (ACS EJSCREEN) by FIPS Utility to aggregate just population count for each FIPS Census unit

Get population counts (ACS EJSCREEN) by FIPS Utility to aggregate just
population count for each FIPS Census unit

## Usage

``` r
fips2pop(fips)
```

## Arguments

- fips:

  vector of fips (can be state, county, tract, blockgroup, block). If
  block, it estimates using weights like it does when aggregating for a
  report. If city/cdp, it returns NA currently since those pop counts
  are not in blockgroupstats.

## Value

vector of population counts same length as fips vector
