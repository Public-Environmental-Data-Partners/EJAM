# FIPS - Read and clean FIPS column from a table, after inferring which col it is

Just read the codes in one column of a table obtained from something
like read.csv, or excel, etc.

## Usage

``` r
fips_from_table(fips_table, addleadzeroes = TRUE, in_shiny = FALSE)
```

## Arguments

- fips_table:

  data.frame or [data.table](https://r-datatable.com) of FIPS codes for
  counties, states, or tracts, for example, in a column whose name can
  be interpreted as FIPS (is one of the aliases like fips, countyfips,
  etc.) Aliases are: c("FIPS", "fips", "fips_code", "fipscode", "Fips",
  "statefips", "countyfips", "ST_FIPS", "st_fips", "ST_FIPS", "st_fips",
  "FIPS.ST", "FIPS.COUNTY", "FIPS.TRACT")

- addleadzeroes:

  whether to add leading zeroes where needed as for a State whose FIPS
  starts with "01"

- in_shiny:

  used by server during shiny app

## Value

vector of fips codes

## See also

[`fips_bgs_in_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bgs_in_fips.md)
[`fips_lead_zero()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_lead_zero.md)
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
`fips_from_table()`

## Examples

``` r
 fips_from_table( data.frame(countyfips=0, FIPS=1, bgfips=2, other=3, fips=4))
```
