# FIPS - for a set of points (lat,lon) quickly find the blockgroup each is inside

FIPS - for a set of points (lat,lon) quickly find the blockgroup each is
inside

## Usage

``` r
fips_bg_from_latlon(
  df = testpoints_10[1:2, ],
  nblocks = 50,
  nbg = 3,
  radius1 = 3,
  quiet = TRUE
)
```

## Arguments

- df:

  data.frame or data.table with columns lat, lon, and ejam_uniq_id

- nblocks:

  number of candidate blocks to check at each site

- nbg:

  number of candidate blockgroups to download for each site

- radius1:

  initial search radius for relevant block points

- quiet:

  whether to print more while it downloads etc.

## Value

vector of blockgroup FIPS codes, same length as NROW(df)

## See also

[`state_from_latlon()`](https://ejanalysis.github.io/EJAM/reference/state_from_latlon.md)
(different approach, unclear which is faster)

## Examples

``` r
if (FALSE) { # \dontrun{
# Looks like it finds the right blockgroup:
x10 = EJAM:::fips_bg_from_latlon(testpoints_10)
mapfast( data.frame(ejam_uniq_id = x10[3]) )
mapfast(testpoints_10[3, ], radius = 0.1)

# Looks like it finds the right blockgroup:
x100 = EJAM:::fips_bg_from_latlon(testpoints_100)
mapfast( data.frame(ejam_uniq_id = x100[34]) )
mapfast(testpoints_100[34, ], radius = 0.1)
  } # }
```
