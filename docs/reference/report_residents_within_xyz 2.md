# Build text for report: Residents within( X miles of)( any of) the (N) point(s)/polygon(s)/Census unit(s)

Helps app_server create locationstr parameter passed to
[`build_community_report()`](https://ejanalysis.github.io/EJAM/reference/build_community_report.md)

## Usage

``` r
report_residents_within_xyz(
  text1 = "Residents within ",
  radius = NULL,
  unitsingular = "mile",
  area_in_square_miles = NULL,
  nsites = 1,
  sitenumber = NULL,
  ejam_uniq_id = NULL,
  sitetype = c(NA, "latlon", "fips", "shp")[1],
  site_method = sitetype,
  census_unit_type = "Census unit",
  sitetype_nullna = "place",
  linefeed = "<br>",
  addlatlon = TRUE,
  lat = NULL,
  lon = NULL,
  show_fips_name = TRUE
)
```

## Arguments

- text1:

  text to start the phrase, like "Residents within "

- radius:

  The distance from each place, normally in miles (which can be 0), or
  custom text like "seven kilometers from" in which case it should end
  with words like "a safe distance from" or "the vicinity of" or
  "proximity to" or "near" – but may need to specify custom text1 also.
  If numeric (or a number stored as text like "3.5"), it gets rounded
  for display, where rounding depends on
  table_rounding_info("radius.miles")

- unitsingular:

  'mile' by default, but can use 'kilometer' etc. Ignored if radius is
  not a number.

- area_in_square_miles:

  number if available, area in square miles, added as a second line

- nsites:

  number of places or text in lieu of number

- sitenumber:

  if the 1 site is from a list of sites, can say which one (1:N)

- ejam_uniq_id:

  if the 1 site is from a list of sites, can say which ID

- sitetype:

  can be 'latlon', 'fips', 'shp', or some singular custom text like
  "Georgia location" or "place" but should be something that can be made
  plural by just adding "s" so ending with "site" works better than
  ending with "... facility" since that would print as "facilitys" here.

- site_method:

  optional detailed info about how sites were selected (see server
  submitted_upload_method() reactive)

- census_unit_type:

  optional phrase like "Counties" if relevant (if sitetype is "fips")

- sitetype_nullna:

  optional, to use if sitetype is NULL – should be a singular word
  preceded by a space, like " location"

- linefeed:

  optional, to use `"\n"` or `". "` instead of default `"<br>"`, for
  example

- addlatlon:

  optional, defines whether coordinates are noted in header for latlon
  sitetype

- show_fips_name:

  optional, if it was a FIPS-based analysis, this defines whether to
  also show name of FIPS Census unit (e.g., name of city or county).
  Normally this is already in the analysis title, so not needed in this
  additional part of the report header.

## See also

[`report_xmilesof()`](https://ejanalysis.github.io/EJAM/reference/report_xmilesof.md)
[`buffer_desc_from_sitetype()`](https://ejanalysis.github.io/EJAM/reference/buffer_desc_from_sitetype.md)

## Examples

``` r
 out <- testoutput_ejamit_100pts_1miles
 x <- EJAM:::report_residents_within_xyz(
   sitetype = out$sitetype,
   radius = out$results_overall$radius.miles,
   nsites = NROW(out$results_bysite[out$results_bysite$valid == T, ]),
   area_in_square_miles = out$results_overall$area_sqmi,
   # sitenumber = 6,  # only relevant for 1-site report
   # ejam_uniq_id = out$results_bysite[sitenumber, ejam_uniq_id], # only relevant for 1-site report
   linefeed = ". ",
   lat = out$results_bysite$lat, lon = out$results_bysite$lon
 )
```
