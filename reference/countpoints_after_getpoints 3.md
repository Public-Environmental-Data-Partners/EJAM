# utility - count topoints near each frompoint, AFTER getpointsnearby() or getfrsnearby() or getblocksnearby() was already run

utility - count topoints near each frompoint, AFTER getpointsnearby() or
getfrsnearby() or getblocksnearby() was already run

## Usage

``` r
countpoints_after_getpoints(
  sites2points,
  frompoints_id_colname = "ejam_uniq_id",
  topoints_id_colname = "blockid",
  radius = NULL
)
```

## Arguments

- sites2points:

  output of function like
  [`getpointsnearby()`](https://ejanalysis.github.io/EJAM/reference/getpointsnearby.md)
  or
  [`getfrsnearby()`](https://ejanalysis.github.io/EJAM/reference/getfrsnearby.md)
  or
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)

- frompoints_id_colname:

  character string name of column in sites2points that is the unique ID
  of frompoints

- topoints_id_colname:

  character string name of column in topoints that is the unique ID of
  counted points

- radius:

  optional, should be less than or equal to radius originally used to
  create sites2points. If radius is provided here, this function counts
  only the topoints that are at a distance of less than or equal to this
  radius (which is likely only a subset of all points within original
  radius used to create sites2points). You can run for example,

  ` s2s <- getpointsnearby(frompoints = testpoints_10[1,], topoints = frs_from_naics("cement"), radius = 30) `
  EJAM:::countpoints_after_getpoints(s2s)
  EJAM:::countpoints_after_getpoints(s2s, radius = 20)
  EJAM:::countpoints_after_getpoints(s2s, radius = 10)
  EJAM:::countpoints_after_getpoints(s2s, radius = 5)
  EJAM:::countpoints_after_getpoints(s2s, radius = 3)

## Value

counts [data.table](https://r-datatable.com) with column N for count,
and a column named via frompoints_id_colname

## Examples

``` r
EJAM:::countpoints_after_getpoints(testoutput_getblocksnearby_10pts_1miles)
```
