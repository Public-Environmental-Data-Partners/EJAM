# FIPS - Analyze US States as if they were sites, to get summary indicators summary

FIPS - Analyze US States as if they were sites, to get summary
indicators summary

## Usage

``` r
states_as_sites(fips)
```

## Arguments

- fips:

  State FIPS vector, like c("01", "02") or
  fips_state_from_state_abbrev(c("DE", "RI"))

## Value

provides table similar to the output of
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
[data.table](https://r-datatable.com) with one row per blockgroup in
these states, or all pairs of states fips - bgid, and ejam_uniq_id (1
through N) assigned to each state but missing blockid and distance so
not ready for
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md).

## Details

This function provides one row per blockgroup.
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
provides one row per block. See more below under "Value"

## Examples

``` r
  s2b <- states_as_sites(fips_state_from_state_abbrev(c("DE", "RI")))
```
