# utility - How many sites are near the blocks (site density near residents)

utility - How many sites are near the blocks (site density near
residents)

## Usage

``` r
getblocks_summarize_sites_per_block(x, varname = "blockid")
```

## Arguments

- x:

  The output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  like
  [testoutput_getblocksnearby_10pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md)

- varname:

  colname of variable in data.table x that is the one to summarize by

## Value

invisibly, a list of stats

## See also

[`getblocks_diagnostics()`](https://ejanalysis.github.io/EJAM/reference/getblocks_diagnostics.md)
