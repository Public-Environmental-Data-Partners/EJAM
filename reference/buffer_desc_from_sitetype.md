# Build text for report: Locations analyzed: e.g. (" specified point") based on sitetype ("latlon") and site_method

Helps create text for excel report's notes sheet (via
[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)
helpers like
[`table_xls_format()`](https://ejanalysis.github.io/EJAM/reference/table_xls_format.md))

## Usage

``` r
buffer_desc_from_sitetype(sitetype, site_method)
```

## Arguments

- sitetype:

  character string, one of "shp", "latlon", "fips"

- site_method:

  optional word or phrase about the sites or how they were selected.

  The `site_method` parameter can be used by the shiny app to add
  informational text in the header of a report.

  The `site_method` parameter provides more detailed info about how
  sites were specified in the web app, beyond what `sitetype` provides,
  e.g., from `ejamit()$sitetype` or `ejamitout$sitetype`

  - sitetype can be "latlon", "fips", or "shp"

  - site_method can be one of these: "latlon", "SHP", "FIPS",
    "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT"

  The shiny app server provides `site_method` from the reactive called
  submitted_upload_method() which is much like the one called
  current_upload_method().

## Value

text string, phrase to use in excel notes tab

## See also

[`report_residents_within_xyz_from_ejamit()`](https://ejanalysis.github.io/EJAM/reference/report_residents_within_xyz_from_ejamit.md)
and
[`report_residents_within_xyz()`](https://ejanalysis.github.io/EJAM/reference/report_residents_within_xyz.md)
for a newer approach to this.

## Examples

``` r
EJAM:::buffer_desc_from_sitetype("latlon", "NAICS")
EJAM:::buffer_desc_from_sitetype("shp")
EJAM:::buffer_desc_from_sitetype("fips")
```
