# helper to pick text phrase to use in excel report notes tab, for Locations analyzed: \_\_\_\_\_

helper to pick text phrase to use in excel report notes tab, for
Locations analyzed: \_\_\_\_\_

## Usage

``` r
buffer_desc_from_sitetype(sitetype, site_method)
```

## Arguments

- sitetype:

  character string, one of "shp", "latlon", "fips"

- site_method:

  string used in filename for saved report and to describe locations
  site_method can be SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, or
  MACT

## Value

text string, phrase to use in excel notes tab

## See also

[`report_residents_within_xyz()`](https://ejanalysis.github.io/EJAM/reference/report_residents_within_xyz.md)
