# utility - How many blocks are near the sites (pop density affects accuracy)

Number of blocks near avg site, how many sites have only 1 or fewer than
30 blocks nearby, etc.

## Usage

``` r
getblocks_summarize_blocks_per_site(x, varname = "ejam_uniq_id")
```

## Arguments

- x:

  The output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  like
  [testoutput_getblocksnearby_1000pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_1000pts_1miles.md)

- varname:

  colname of variable in x, a table in
  [data.table](https://r-datatable.com) format, that is the one to
  summarize by

## Value

invisibly, a list of stats, and plot

## See also

[`getblocks_diagnostics()`](https://ejanalysis.github.io/EJAM/reference/getblocks_diagnostics.md)
