# utility - get table with bgid for each blockid, or just unique bgid values vector

utility - get table with bgid for each blockid, or just unique bgid
values vector

## Usage

``` r
bgid_from_blockid(blockids, asdt = FALSE)
```

## Arguments

- blockids:

  vector of blockid values as in
  [blockwts](https://ejanalysis.github.io/EJAM/reference/blockwts.md)
  table or in
  [testoutput_getblocksnearby_10pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md)

- asdt:

  set to TRUE if you want it to return a table in
  [data.table](https://r-datatable.com) format with colnames bgid,
  blockid, one row per input blockid, so it may have duplicates in the
  bgid column. set to FALSE if you want it to return a vector of bgid
  values (integer class)

## Value

depends on asdt parameter value

## Examples

``` r
rad = 0.658
pts = data.frame(lat=39.4347105, lon=-74.7203421)
s2b = getblocksnearby(sitepoints=pts, radius = rad)
EJAM:::bgid_from_blockid(s2b$blockid) # vector of unique ids
EJAM:::bgid_from_blockid(s2b$blockid, asdt = TRUE) # data.table

 # plotblocksnearby(pts, radius = rad, overlay_blockgroups = T)
```
