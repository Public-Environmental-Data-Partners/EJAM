# Utility to create a table used to create a quadtree spatial index of points etc.

Used by
[`indexpoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexpoints.md)
that in turn is used by
[`proxistat()`](https://public-environmental-data-partners.github.io/EJAM/reference/proxistat.md).
It prepares a set of coordinates ready for indexing.

## Usage

``` r
create_quaddata(pts, idcolname = NULL, xyzcolnames = c("x2", "z2", "y2"))
```

## Arguments

- pts:

  a data.frame or [data.table](https://r-datatable.com) with columns
  name lat and lon, one row per location (point), and any other columns
  are ignored.

- idcolname:

  if NULL (default), a pointid column is created as a unique id
  1:NROW(). If creating the index of blocks, idcolname is "blockid" If
  set to "id" it just uses that even if not unique id.
  [`indexpoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexpoints.md)
  does not directly refer to this column but index probably incorporates
  it.

- xyzcolnames:

  For creating quaddata and then localtree index of blocks, this must be
  set to c("BLOCK_X", "BLOCK_Z", "BLOCK_Y") ??

## Value

returns a [data.table](https://r-datatable.com) one row per point,
columns with names that are c(xyzcolnames, idcolname)

## Details

Very similar to what is used to prepare
[quaddata](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md),
which is used by
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md).

Note that BOTH this table and the index of it are needed in
getblocksnearby() or getpointsnearby() !

For 8 million block points, this takes a couple of seconds to do, so it
may be useful to store the index during a session rather than building
it each time it is used. But it cannot be saved on disk because of what
it is and how it works.
