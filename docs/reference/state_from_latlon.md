# Find what state is where each point is located

Find what state is where each point is located

## Usage

``` r
state_from_latlon(lat, lon)
```

## Arguments

- lat:

  latitudes vector

- lon:

  longitudes vector

## Value

unlike
[`fips_state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_state_from_latlon.md),
returns data.frame: ST, statename, FIPS.ST, REGION, n as many rows as
elements in lat or lon

## Details

Takes 3 seconds to find state for 1k points, so a faster alternative
would be useful It can take approx. one minute for 2.5 million points as
in state_from_latlon(frs\$lat, frs\$lon)

Draft function fips_bg_from_latlon() does NOT seem faster? at least as
drafted.

## See also

[`fips_bg_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bg_from_latlon.md)
might be faster??
[states_shapefile](https://public-environmental-data-partners.github.io/EJAM/reference/states_shapefile.md)
[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
[`state_from_sitetable()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_sitetable.md)

## Examples

``` r
 myprogram <- "CAMDBS" # 739 sites
 pts <- frs_from_program(myprogram)[ , .(lat, lon, REGISTRY_ID,  PRIMARY_NAME)]
 # add a column with State abbreviation
 pts[, ST := state_from_latlon(lat=lat, lon = lon)$ST]
 #map these points
 mapfast(pts[ST == 'TX',], radius = 1) # 1 miles radius circles
```
