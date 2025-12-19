# Utility to create efficient quadtree spatial index of any set of lat,lon

Index a list of points (e.g., schools) so
[`getpointsnearby()`](https://ejanalysis.github.io/EJAM/reference/getpointsnearby.md)
can find them very quickly

## Usage

``` r
indexpoints(pts, indexname = "custom_index", envir = globalenv())
```

## Arguments

- pts:

  a data.frame or [data.table](https://r-datatable.com) with columns
  name lat and lon, one row per location (point), and any other columns
  are ignored.

- indexname:

  optional name to give the index

- envir:

  optional environment - default is to assign index object to
  globalenv()

## Value

Just returns TRUE when done. Side effect is to put into the globalenv()
(or specified envir) that spatial index with name defined by indexname,
as created by `indexpoints()`.

## Details

This creates a spatial index to be used by
[`getpointsnearby()`](https://ejanalysis.github.io/EJAM/reference/getpointsnearby.md)
to support
[`proxistat()`](https://ejanalysis.github.io/EJAM/reference/proxistat.md),
to create a new proximity score for every block and blockgroup in the
US. It relies on
[`create_quaddata()`](https://ejanalysis.github.io/EJAM/reference/create_quaddata.md)
for one step, then
[`SearchTrees::createTree()`](https://rdrr.io/pkg/SearchTrees/man/createTree.html)
