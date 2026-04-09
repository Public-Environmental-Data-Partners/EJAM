# Find all blocks within each of the FIPS codes provided

Allows EJAM to analyze and compare Counties, for example

## Usage

``` r
getblocksnearby_from_fips2(fips, in_shiny = FALSE, need_blockwt = TRUE)
```

## Arguments

- fips:

  vector of FIPS codes identifying blockgroups, tracts, counties, or
  states. This is useful if – instead of getting stats on and comparing
  circular buffers or polygons – one will be getting stats on one or
  more tracts, or analyzing and comparing blockgroups in a county, or
  comparing whole counties to each other, within a State.

- in_shiny:

  used by shiny app server code to handle errors via validate() instead
  of stop()

- need_blockwt:

  ignored now

## Value

same as for
[getblocksnearby](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
but one row per FIPS, and the distance column is irrelevant

## See also

[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
[`fips_bgs_in_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bgs_in_fips.md)
[`fips_lead_zero()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_lead_zero.md)
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
[`fips_from_table()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_from_table.md)
