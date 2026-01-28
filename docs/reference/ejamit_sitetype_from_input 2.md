# helper to infer what type of sites were analyzed by looking at params given as INPUT to ejamit() used by ejamit() and ejamit_compare_types_of_places()

helper to infer what type of sites were analyzed by looking at params
given as INPUT to ejamit() used by ejamit() and
ejamit_compare_types_of_places()

## Usage

``` r
ejamit_sitetype_from_input(sitepoints = NULL, fips = NULL, shapefile = NULL)
```

## Arguments

- sitepoints:

  parameter as was passed to
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- fips:

  parameter as was passed to
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- shapefile:

  parameter as was passed to
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

## Value

either "latlon", "fips", or "shp", or errors if 2 or 3 types were
specified at once

## Details

Note `sitetype` is not quite the same as the `site_method` parameter
used in building reports. `site_method` can be one of these: SHP,
latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, MACT `sitetype` can be
latlon, fips, or shp as returned by
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md), but
can include lowercase versions of site_method values too within server
code and some function parameters!

## See also

[`sites_from_input()`](https://ejanalysis.github.io/EJAM/reference/sites_from_input.md)
