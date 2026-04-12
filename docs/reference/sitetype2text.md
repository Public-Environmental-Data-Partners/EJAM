# helper to convert sitetype code ("latlon") to singular or plural text describing it ("specified point")

helper to convert sitetype code ("latlon") to singular or plural text
describing it ("specified point")

## Usage

``` r
sitetype2text(
  sitetype = NULL,
  site_method = sitetype,
  sitetype_nullna = "place",
  census_unit_type = "Census unit",
  nsites = 1
)
```

## Arguments

- sitetype:

  character string, latlon, shp, fips – like come from
  ejamit()\$sitetype, but could also provide the site_method info like
  latlon, shp, fips, fips_place, frs, echo, naics, sic, mact,
  epa_program – like (once made lowercase) used in server
  submitted_upload_method() or current_upload_method() reactive.

- site_method:

  optional word or phrase about the sites or how they were selected.

  The `site_method` parameter can be used as-is by
  [`create_filename()`](https://public-environmental-data-partners.github.io/EJAM/reference/create_filename.md)
  to be part of the saved file name. It can also be used by the shiny
  app to add informational text in the header of a report, via
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  and related helper functions like
  [`report_residents_within_xyz()`](https://public-environmental-data-partners.github.io/EJAM/reference/report_residents_within_xyz.md)
  or via
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  and related helper functions.

  The `site_method` parameter provides more detailed info about how
  sites were specified in the web app, beyond what `sitetype` provides
  (e.g., from `ejamit()$sitetype` or `ejamitout$sitetype`):

  - sitetype can be "latlon", "fips", or "shp"

  - site_method can be one of these: "latlon", "SHP", "FIPS",
    "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT"

  The shiny app server provides `site_method` from the reactive called
  submitted_upload_method() which is much like the one called
  current_upload_method().

- sitetype_nullna:

  optional, to use if sitetype is NULL – should be a singular word, like
  "location"

- census_unit_type:

  e.g., "county"

- nsites:

  number of sites total, to determine whether to pluralize e.g.,
  "county" into "counties"

## Value

text string, phrase to use in report header (or excel notes tab, etc.)
