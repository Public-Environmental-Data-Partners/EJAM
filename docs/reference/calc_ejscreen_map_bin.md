# Calculate EJSCREEN map color bins

Calculate EJSCREEN map color bins

## Usage

``` r
calc_ejscreen_map_bin(x)
```

## Arguments

- x:

  numeric vector of percentiles on a 0-100 scale.

## Value

integer vector of bin numbers from 0 to 11.

## Details

EJSCREEN shows color-coded maps based on percentile bins. This helper
calculates those bin numbers so the can be stored in EJSCREEN's dataset
of blockgroups. Percentiles are expected to be represented on a 0-100
scale. Bins match the historical EJSCREEN thresholds: 0-9th percentile
is bin 1, 10-19 is bin 2, ..., 80-89 is bin 9, 90-94 is bin 10, and
95-100 is bin 11. Missing or out-of-range percentiles are assigned bin
0.
