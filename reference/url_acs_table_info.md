# get URL(s) of Census Bureau pages showing ACS 5-year tables examples

get URL(s) of Census Bureau pages showing ACS 5-year tables examples

## Usage

``` r
url_acs_table_info(
  tables = tables_ejscreen_acs,
  fips = NULL,
  yr,
  fiveorone = 5
)
```

## Arguments

- tables:

  vector of one or more ACS table names like "B01001"

- fips:

  optional vector of one or more FIPS codes (e.g., FIPS of tracts or
  blockgroups)

- yr:

  year of ACS data (end year of 5-year period)

- fiveorone:

  must be 5 or 1

## Value

vector of URLs

## See also

[tables_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/tables_ejscreen_acs.md)
[`acs_table_info()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_table_info.md)

## Examples

``` r
url_acs_table_info()
```
