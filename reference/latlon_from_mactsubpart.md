# Get point locations for US EPA-regulated facilities that have sources subject to Maximum Achievable Control Technology (MACT) standards under the Clean Air Act.

Get point locations for US EPA-regulated facilities that have sources
subject to Maximum Achievable Control Technology (MACT) standards under
the Clean Air Act.

## Usage

``` r
latlon_from_mactsubpart(subpart = "JJJ", include_if_no_latlon = FALSE)
```

## Arguments

- subpart:

  vector of one or more strings indicating the Subpart of CFR Title 40
  Part 63 that covers the source category of interest, such as "FFFF" -
  see for example,
  <https://www.ecfr.gov/current/title-40/part-63/subpart-FFFF>

- include_if_no_latlon:

  logical - many in the database lack lat lon values but have a MACT
  code

## Value

a table in [data.table](https://r-datatable.com) format with columns
named

programid, subpart, title, lat, lon, REGISTRY_ID, program

for US EPA FRS sites with that MACT code. Or NA if none found.

## Details

For background information on MACT NESHAP subparts:

- [MACT
  NESHAP](https://en.wikipedia.org/wiki/National_Emissions_Standards_for_Hazardous_Air_Pollutants)

- [subpart(s) that categorize relevant EPA-regulated
  sites](https://www.epa.gov/stationary-sources-air-pollution/national-emission-standards-hazardous-air-pollutants-neshap-8)

EPA's [ECHO query
tools](https://echo.epa.gov/help/facility-search/search-criteria-help#facchar)
also provide search by NAICS or SIC, and by MACT subpart.

## Examples

``` r
  mact_table
  latlon_from_mactsubpart("OOOO", include_if_no_latlon = FALSE) # default
  latlon_from_mactsubpart("OOOO", include_if_no_latlon = TRUE)
```
