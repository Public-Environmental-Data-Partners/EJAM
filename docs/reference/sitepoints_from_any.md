# Get lat/lon flexibly - from file, data.frame, data.table, or lat/lon vectors Like latlon_from_anything() but this also adds a ejam_uniq_id column

Get lat/lon flexibly - from file, data.frame, data.table, or lat/lon
vectors Like latlon_from_anything() but this also adds a ejam_uniq_id
column

## Usage

``` r
sitepoints_from_any(
  anything,
  lon_if_used,
  invalid_msg_table = FALSE,
  set_invalid_to_na = TRUE,
  interactiveprompt = TRUE
)

sitepoints_from_anything(
  anything,
  lon_if_used,
  invalid_msg_table = FALSE,
  set_invalid_to_na = TRUE,
  interactiveprompt = TRUE
)
```

## Arguments

- anything:

  see
  [`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md),
  which this is passed to

- lon_if_used:

  see
  [`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md),
  which this is passed to

- invalid_msg_table:

  set to TRUE if you want columns "valid" and "invalid_msg" also

- set_invalid_to_na:

  used by latlon_df_clean()

- interactiveprompt:

  passed to
  [`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md)

## Value

data.frame with lat,lon, and ejam_uniq_id as colnames, one row per point

## Examples

``` r
 sitepoints_from_any(testpoints_10)
 sitepoints_from_any(lon_if_used = testpoints_10$lon, anything = testpoints_10$lat)
 sitepoints_from_any(testpoints_10$lat, testpoints_10$lon)
 pts = c("33,-100", "32,-101")
 sitepoints_from_any(pts)
 pts = data.frame(Longitude = testpoints_10$lon, Latitude = testpoints_10$lat)
 sitepoints_from_any(pts)
 pts = data.table::data.table(Lat = testpoints_10$lat, Long = testpoints_10$lon)
 sitepoints_from_any(pts)

 sitepoints_from_anything(testpoints_bad, set_invalid_to_na = F, invalid_msg_table = T)

   ## Try this in an interactive R session:
   ##
   #   pts <- sitepoints_from_any()

 # \donttest{
 pts = system.file("testdata/latlon/testpoints_10.xlsx", package = "EJAM")
 sitepoints_from_any(pts)
 # }
```
