# helps other functions have flexible input parameters - can provide points in a table, points as lat,lon vectors, polygons in a spatial data.frame, or Census units as a fips code vector figures out which type of inputs were provided, and returns them

helps other functions have flexible input parameters - can provide
points in a table, points as lat,lon vectors, polygons in a spatial
data.frame, or Census units as a fips code vector figures out which type
of inputs were provided, and returns them

## Usage

``` r
sites_from_input(
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  fips = NULL
)
```

## Arguments

- sitepoints:

  optional data.frame with colnames lat,lon

- lat, lon:

  optional vectors of latitudes and longitudes

- shapefile:

  optional polygons in a spatial data.frame

- fips:

  optional Census units as a fips code vector

## Value

a list with names sitetype, sitepoints, fips, and shapefile. sitetype is
"latlon" or "fips" or "shp" or NULL others are NULL except the one
corresponding to the sitetype sitepoints would be a data.frame of points
in columns lat,lon or NULL shapefile would be a spatial data.frame "sf"
class or NULL fips would be a vector of Census FIPS codes or NULL

## See also

[`sites_from_file()`](https://ejanalysis.github.io/EJAM/reference/sites_from_file.md)

## Examples

``` r
# After sites <- EJAM:::sites_from_input(),
# get data type from sites$sitetype
# get data itself from sites_only(sites)

EJAM:::sites_only({sites <- EJAM:::sites_from_input(
  lat = 44:43, lon = -99:-98
  ) })
sites$sitetype
EJAM:::sites_only({sites <- EJAM:::sites_from_input(
  sitepoints = data.frame(lat = 44:43, lon = -99:-98)
  ) })
sites$sitetype
EJAM:::sites_only({sites <- EJAM:::sites_from_input(
  fips = testinput_fips_mix
  ) })
sites$sitetype
EJAM:::sites_only({sites <- EJAM:::sites_from_input(
  shapefile = testinput_shapes_2
  ) })
sites$sitetype
```
