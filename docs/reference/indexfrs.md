# Utility to create an efficient quadtree spatial index of EPA-regulated facility locations

Index US EPA Facility Registry Service facility locations so
[`getfrsnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getfrsnearby.md)
can find them very quickly

## Usage

``` r
indexfrs(frspts = NULL, indexname = "frs_index", envir = globalenv())
```

## Arguments

- frspts:

  optional, default is the frs table from the EJAM package, but could be
  a subset of that [data.table](https://r-datatable.com) with columns
  name lat and lon, one row per location (point), and any other columns
  are ignored. If frspts not specified and indexname exists already,
  just returns that index without rebuilding it. If frspts is specified,
  such as just frs from one industry or one state, then new index is
  built, even if one named indexname already existed.

- envir:

  optional environment - default is to assign index object to
  globalenv()

## Value

Index is returned and the side effect is it puts in the globalenv() (or
specified envir) that spatial index with name defined by indexname, as
created by
[`indexpoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexpoints.md).

## Details

This creates a quadtree spatial index of some or all facilities, to be
used by
[`getfrsnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getfrsnearby.md),
such as to count the regulated facilities near some other specified
sites, or to create a new proximity score for every block and blockgroup
in the US, via
[`proxistat()`](https://public-environmental-data-partners.github.io/EJAM/reference/proxistat.md)
