# helper to convert sitetype code ("latlon") to text describing it (" specified point")

helper to convert sitetype code ("latlon") to text describing it ("
specified point")

## Usage

``` r
sitetype2text(sitetype = NULL, sitetype_nullna = " place")
```

## Arguments

- sitetype:

  character string, like (if lowercase) latlon, shp, fips, fips_place,
  frs, echo, naics, sic, mact, epa_program_sel, epa_program_up as used
  in server or some of which come from ejamit()\$sitetype like latlon,
  fips, or shp

- sitetype_nullna:

  optional, to use if sitetype is NULL – should be a singular word
  preceded by a space, like " location"

## Value

text string, phrase to use in report header (or excel notes tab, etc.)
