# count the number of topoints within a specified radius of each frompoint

count the number of topoints within a specified radius of each frompoint

## Usage

``` r
countpoints_nearby(frompoints, topoints, radius = 3)
```

## Arguments

- frompoints:

  table with lat,lon colnames

- topoints:

  table with lat,lon colnames

- radius:

  search radius in miles from each of frompoints

## Value

table or vector?? 1 row per frompoints row, column attribute called
"unique" will store the count of unique topoints overall

## Examples

``` r
# EJAM:::countpoints_nearby(pts_sites, pts_features, radius = 3)
```
