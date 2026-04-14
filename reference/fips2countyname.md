# FIPS - Get names for the Counties CONTAINING the given census units (of any type)

FIPS - Get names for the Counties CONTAINING the given census units (of
any type)

## Usage

``` r
fips2countyname(fips, includestate = c("ST", "Statename", "")[1])
```

## Arguments

- fips:

  vector of US Census FIPS codes for Counties (5 digits each). can be
  string or numeric, with or without leading zeroes.

- includestate:

  can be ST, Statename, "", or TRUE to specify what if anything comes
  after county name and comma

## Value

vector of county names, same length as input fips vector, optionally
with comma and 2-character abbreviation or full state name.

## Details

NOTE THAT ISLAND AREAS WORK DIFFERENTLY SINCE THEIR FIPS ARE NOT QUITE
LIKE COUNTY FIPS

- FIRST 5 LETTERS OF FIPS ARE NOT THE UNIQUE "COUNTY" CODE IN Northern
  Mariana Islands

## Examples

``` r
cbind(
  fips = testinput_fips_mix,
  type = fipstype(testinput_fips_mix),
  cfips = fips2countyfips(testinput_fips_mix),
  countyname = fips2countyname(testinput_fips_mix)
)

cfips = fips_counties_from_state_abbrev("RI")
fips2countyname(cfips, includestate = "Statename")
fips2countyname(cfips)
fips2name(cfips)
fips2name(10001)
fips2name(fips_counties_from_statename(c("Delaware", "Rhode Island")))
```
