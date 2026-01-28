# Get latitude, longitude (and NAICS) via EPA Facility Registry ID See FRS Facility Registry Service data on EPA-regulated sites

Get latitude, longitude (and NAICS) via EPA Facility Registry ID See FRS
Facility Registry Service data on EPA-regulated sites

## Usage

``` r
latlon_from_regid(regid = NULL)
```

## Arguments

- regid:

  vector of one or more EPA Facility Registry Service IDs like
  110010052520

## Value

table in [data.table](https://r-datatable.com) format drawn from
[frs](https://ejanalysis.github.io/EJAM/reference/frs.md) dataset, with
columns "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME" "NAICS"
"PGM_SYS_ACRNMS"

## See also

[`url_frs_facility()`](https://ejanalysis.github.io/EJAM/reference/url_frs_facility.md)

## Examples

``` r
 latlon_from_regid("110070874073")
 latlon_from_regid(110070874073)
 frs_from_regid(110070874073)
 frs_from_regid(testinput_registry_id)
```
