# Get lat/lon flexibly - from file, data.frame, data.table, or lat/lon vectors

Try to figure out if user provided latitude / longitude as vectors,
data.frame, file, or interactively pick file.

## Usage

``` r
latlon_from_anything(
  anything,
  lon_if_used,
  interactiveprompt = TRUE,
  invalid_msg_table = FALSE,
  set_invalid_to_na = TRUE
)
```

## Arguments

- anything:

  If missing and interactive mode in RStudio, prompts user for file.
  Otherwise, this can be a filename (csv or xlsx, with path), or
  data.frame/ data.table/ matrix, or vector of longitudes (in which case
  y must be the latitudes). File or data.frame/data.table/matrix must
  have columns called lat and lon, or names that can be inferred to be
  that by
  [`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)

- lon_if_used:

  If anything parameter is a vector of longitudes, lon_if_used must be
  the latitudes. Ignored otherwise.

- interactiveprompt:

  If TRUE (default) and in interactive mode not running shiny, will
  prompt user for file if "anything" is missing.

- invalid_msg_table:

  Set to TRUE to add columns "valid" and "invalid_msg" to output

- set_invalid_to_na:

  used by
  [`latlon_df_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_df_clean.md)

## Value

A data.frame that has at least columns lon and lat (and others if they
were in anything), and a logical column called "valid"

## Details

Also see closely related function
[`sitepoints_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md).

This function relies on

[`read_csv_or_xl()`](https://public-environmental-data-partners.github.io/EJAM/reference/read_csv_or_xl.md)
and

[`latlon_df_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_df_clean.md)
which in turn uses
[`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)
[`latlon_as.numeric()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_as.numeric.md)
[`latlon_is.valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.valid.md)

## See also

[`sitepoints_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md)
which is like this but also adds ejam_uniq_id column,
[`latlon_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_fips.md)
and
[`latlon_from_shapefile_centroids()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_shapefile_centroids.md)
that find centroids, and see
[`read_csv_or_xl()`](https://public-environmental-data-partners.github.io/EJAM/reference/read_csv_or_xl.md)
and
[`latlon_df_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_df_clean.md)

## Examples

``` r
 latlon_from_anything(testpoints_10)
 latlon_from_anything(testpoints_10$lat, testpoints_10$lon)
 pts = c("33,-100", "32,-101")
 latlon_from_anything(pts)
 pts = data.frame(Longitude = testpoints_10$lon, Latitude = testpoints_10$lat)
 latlon_from_anything(pts)
 pts = data.table(Lat = testpoints_10$lat, Long = testpoints_10$lon)
 latlon_from_anything(pts)
 if (FALSE) { # \dontrun{
 if (interactive()) {
   pts <- latlon_from_anything()
 }} # }
 if (FALSE) { # \dontrun{
 pts = system.file("testdata/latlon/testpoints_10.xlsx", package = "EJAM")
 latlon_from_anything(pts)
 } # }
```
