# test points data.frame with columns note, lat, lon

test points data.frame with columns note, lat, lon

## Usage

``` r
testpoints_overlap3
```

## Format

An object of class `data.frame` with 3 rows and 4 columns.

## Details

examples of test points for testing functions that need lat lon, with 3
overlapping 1-mile radius circles. To view these points:

     pts <- testpoints_overlap3

     mapfast(pts, radius = 1)

     plotblocksnearby(pts, radius = 1)
