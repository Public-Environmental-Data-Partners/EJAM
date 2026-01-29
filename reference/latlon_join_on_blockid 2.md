# utility to add each block's lat and lon as new columns in data.table by reference, joining on blockid

get expanded version of data.table, such as sites2blocks, with new
lat,lon columns

## Usage

``` r
latlon_join_on_blockid(s2b)
```

## Arguments

- s2b:

  table in [data.table](https://r-datatable.com) format like
  [testoutput_getblocksnearby_10pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md),
  output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md),
  with column called blockid

## Value

returns the input table in [data.table](https://r-datatable.com) format
but with lat,lon columns added as block coordinates

## Examples

``` r
 s2b = copy(testoutput_getblocksnearby_10pts_1miles)
 EJAM:::latlon_join_on_blockid(s2b)
```
