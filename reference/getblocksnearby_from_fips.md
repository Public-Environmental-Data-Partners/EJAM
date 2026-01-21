# Find all blocks within each of the FIPS codes provided

Allows EJAM to analyze and compare Counties, for example

## Usage

``` r
getblocksnearby_from_fips(
  fips,
  in_shiny = FALSE,
  need_blockwt = TRUE,
  return_shp = FALSE,
  allow_multiple_fips_types = TRUE,
  radius = 0
)
```

## Arguments

- fips:

  vector of FIPS codes identifying blockgroups, tracts, counties, or
  states. This is useful if – instead of getting stats on and comparing
  circular buffers or polygons – one will be getting stats on one or
  more tracts, or analyzing and comparing blockgroups in a county, or
  comparing whole counties to each other, within a State.

- in_shiny:

  used by shiny app server code to handle errors via
  [`shiny::validate()`](https://rdrr.io/pkg/shiny/man/validate.html)
  instead of [`stop()`](https://rdrr.io/r/base/stop.html)

- need_blockwt:

  set to FALSE to speed it up if you do not need blockwt

- return_shp:

  set to TRUE to get a named list, pts and polys, that are a
  sites2blocks table in [data.table](https://r-datatable.com) format and
  a spatial data.frame, respectively, or FALSE to get the pts table in
  [data.table](https://r-datatable.com) format much like output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  or
  [`get_blockpoints_in_shape()`](https://ejanalysis.github.io/EJAM/reference/get_blockpoints_in_shape.md)

- allow_multiple_fips_types:

  if enabled, set TRUE to allow mix of blockgroup, tract, city, county,
  state fips

- radius:

  CURRENTLY NOT IMPLEMENTED - NO BUFFER IS ADDED

## Value

- if return_shp=F, returns just a sites2blocks table in
  [data.table](https://r-datatable.com) format with colnames
  ejam_uniq_id, blockid, distance, blockwt, bgid, fips. This is like the
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  and
  [`get_blockpoints_in_shape()`](https://ejanalysis.github.io/EJAM/reference/get_blockpoints_in_shape.md)
  outputs.

- if return_shp=T, returns a named list where pts is the table in
  [data.table](https://r-datatable.com) format of sites2blocks, and
  polys is the spatial data.frame with one row per input fips (including
  invalid ones).

  The ejam_uniq_id represents which of the input sites is being referred
  to, and the table will only have the ids of the sites where blocks
  were found. If 10 sites were input but only sites 5 and 8 were valid
  and had blocks identified, then the data.table here will only include
  ejam_uniq_id values of 5 and 8.

## See also

[`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
[`fips_bgs_in_fips()`](https://ejanalysis.github.io/EJAM/reference/fips_bgs_in_fips.md)
[`fips_lead_zero()`](https://ejanalysis.github.io/EJAM/reference/fips_lead_zero.md)
`getblocksnearby_from_fips()`
[`fips_from_table()`](https://ejanalysis.github.io/EJAM/reference/fips_from_table.md)

## Examples

``` r
  x <- getblocksnearby_from_fips(fips_counties_from_state_abbrev("DE"))
  y <- doaggregate(x)
  z <- ejamit(fips = fips_counties_from_statename("Delaware"))

  # x2 <- getblocksnearby_from_fips("482011000011") # one blockgroup only
  # y2 <- doaggregate(x2)
```
