# Find EPA-regulated facilities in FRS by SIC code (industrial category)

Get lat lon, Registry ID, given SIC industry code(s) Find all EPA
Facility Registry Service (FRS) sites with this exact SIC code (not
subcategories)

## Usage

``` r
latlon_from_sic(sic, id_only = FALSE)
```

## Arguments

- sic:

  a vector of SIC codes, or a table in
  [data.table](https://r-datatable.com) format with column named code,
  as with output of
  [`sic_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_any.md)

- id_only:

  logical optional, set TRUE to get only the vector of REGISTRY_ID
  values back instead of a data.frame with lat,lon,SIC columns too.

## Value

A table in [data.table](https://r-datatable.com) format (not just
data.frame) with columns called lat, lon, REGISTRY_ID, SIC (unless the
id_only parameter is set to TRUE)

## Details

The EPA also provides a [FRS Facility Industrial Classification Search
tool](https://www.epa.gov/frs/frs-query#industrial) where you can find
facilities based on NAICS or SIC.

NOTE: many FRS sites lack SIC code!

Also, this function does not find the sites identified by FRS data as
being in a child SIC (subcategory of your exact query)!

Relies on
[frs_by_sic](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md)

See info about SIC industry codes at <https://www.naics.com/search>

## Examples

``` r
  regid_from_sic('7300')
  latlon_from_sic('7300')
  latlon_from_sic(sic_from_any("cheese")[,code] )
  head(latlon_from_sic(c('6150', '6300', '5995'), id_only=TRUE))
  # mapfast(frs_from_sic('6150')) # simple map
```
