# Use SIC code or industry title text search to see FRS Facility Registry Service data on those EPA-regulated sites

Use SIC code or industry title text search to see FRS Facility Registry
Service data on those EPA-regulated sites

## Usage

``` r
frs_from_sic(sic_code_or_name, ...)
```

## Arguments

- sic_code_or_name:

  passed to
  [`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)

- ...:

  passed to
  [`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)

## Value

relevant rows of the data.table called frs, which has column names that
are "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME" "NAICS" "SIC"
"PGM_SYS_ACRNMS"

The EPA also provides a [FRS Facility Industrial Classification Search
tool](https://www.epa.gov/frs/frs-query#industrial) where you can find
facilities based on NAICS or SIC.

## See also

[`regid_from_sic()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_sic.md)
[`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)
[`latlon_from_sic()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_sic.md)

## Examples

``` r
  frs_from_sic("glass")
  mapfast(frs_from_sic(sic_from_any("silver")$code))
  sic_from_any("silver")
  sic_from_name("silver")
  sic_from_any('0780')
  frs_from_sic('0780')
  regid_from_sic('0780')
  latlon_from_sic('0780')
```
