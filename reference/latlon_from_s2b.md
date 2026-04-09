# DRAFT - NOT WORKING YET - Estimate lat,lon of site(s) from sites2blocks output of getblocksnearby() trilateration – Use lat,lon of nearby block points and distances to estimate original sitepoints

DRAFT - NOT WORKING YET - Estimate lat,lon of site(s) from sites2blocks
output of getblocksnearby() trilateration – Use lat,lon of nearby block
points and distances to estimate original sitepoints

## Usage

``` r
latlon_from_s2b(s2b)
```

## Arguments

- s2b:

  sites2blocks data.table that is output of
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

## Value

table in [data.table](https://r-datatable.com) format with columns
ejam_uniq_id, lat, lon, one row per site

## Details

This function is needed ONLY if you did not retain site latlons, and
then only for sites not entirely in single states based on their nearby
blocks. This is slow and assumes you do not already know the lat,lon of
the sitepoints. If for some reason all you have is output of
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
then this is how you could estimate where the original sitepoint(s) were
that were input(s) to
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

But ejamit() or the shiny app do not require doing this since the
original latlon of sitepoints are retained and provided to
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
which needs to figure out what state each site is in to use the right
state percentiles.

## Examples

``` r
 pts = testpoints_10
 #x = EJAM:::latlon_from_s2b(getblocksnearby(pts, quiet = T))
 x = EJAM:::latlon_from_s2b(testoutput_getblocksnearby_10pts_1miles)
 cbind(estimate = x, pts,
   latratio = x$lat/pts$lat, lonratio = x$lon/pts$lon)
```
