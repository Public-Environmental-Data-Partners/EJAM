# Use NAICS code or industry title text search to see FRS Facility Registry Service data on those EPA-regulated sites

Use NAICS code or industry title text search to see FRS Facility
Registry Service data on those EPA-regulated sites

## Usage

``` r
frs_from_naics(naics_code_or_name, childrenForNAICS = TRUE, ...)
```

## Arguments

- naics_code_or_name:

  passed to
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
  as the query

- childrenForNAICS:

  passed to
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
  as the children param of that function

- ...:

  passed to
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Value

relevant rows of the table in [data.table](https://r-datatable.com)
format called
[frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md),
which has column names that are "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME"
"NAICS" "PGM_SYS_ACRNMS"

## Details

The EPA also provides a [FRS Facility Industrial Classification Search
tool](https://www.epa.gov/frs/frs-query#industrial) where you can find
facilities based on NAICS or SIC.

EPA's [ECHO query
tools](https://echo.epa.gov/help/facility-search/search-criteria-help#facchar)
also provide search by NAICS or SIC, and by MACT subpart.

## See also

[`latlon_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_naics.md)
[`latlon_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_sic.md)
[`frs_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_sic.md)
[`regid_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/regid_from_naics.md)
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Examples

``` r
  frs_from_naics("uranium")
  mapfast(frs_from_naics(naics_from_any("nuclear")$code))
  naics_from_any("silver")
  EJAM:::naics_from_name("silver")
  naics_from_any(212222 )
  frs_from_naics(21222)
  regid_from_naics(21222)
  latlon_from_naics(21222)
```
