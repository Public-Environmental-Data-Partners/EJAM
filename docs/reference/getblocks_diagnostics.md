# utility - How many blocks and many other stats about blocks and sites

utility - How many blocks and many other stats about blocks and sites

## Usage

``` r
getblocks_diagnostics(
  x,
  detailed = FALSE,
  see_pctiles = FALSE,
  see_distanceplot = FALSE
)
```

## Arguments

- x:

  The output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  like
  [testoutput_getblocksnearby_10pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md)

- detailed:

  if TRUE, also shows in console a long table of frequencies via
  [`getblocks_summarize_blocks_per_site()`](https://ejanalysis.github.io/EJAM/reference/getblocks_summarize_blocks_per_site.md)

- see_pctiles:

  set to TRUE to see 20 percentiles of distance in a table

- see_distanceplot:

  if TRUE, also draws scatter plot of adjusted vs unadj distances

## Value

A list of stats

## See also

This relies on
[`getblocks_summarize_blocks_per_site()`](https://ejanalysis.github.io/EJAM/reference/getblocks_summarize_blocks_per_site.md)
and
[`getblocks_summarize_sites_per_block()`](https://ejanalysis.github.io/EJAM/reference/getblocks_summarize_sites_per_block.md)

## Examples

``` r
  getblocks_diagnostics(testoutput_getblocksnearby_10pts_1miles)
  # library(data.table)
  x <- data.table::copy(testpoints_10)
  setDT(x)
  pts <- rbind(data.table(lat = 40.3, lon = -96.23),
    x[ , .(lat, lon)])
 z <- getblocksnearbyviaQuadTree(pts, 1, quadtree = localtree, quiet = T)
 z[ , .(blocks = .N) , keyby = 'ejam_uniq_id']
 plotblocksnearby(pts, radius = 1, sites2blocks = z)
 zz <- getblocks_diagnostics(z, detailed = T, see_pctiles = T)
cbind(stats = zz)

  getblocks_diagnostics(testoutput_getblocksnearby_1000pts_1miles, see_distanceplot = TRUE)
```
