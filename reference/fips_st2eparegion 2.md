# FIPS - Get EPA Region number (1-10) from state FIPS code

FIPS - Get EPA Region number (1-10) from state FIPS code

## Usage

``` r
fips_st2eparegion(stfips)
```

## Arguments

- stfips:

  vector of one or more state fips codes (numbers or as strings)

## Value

vector of numbers representing US EPA Regions

## Examples

``` r
fips = c(testinput_fips_blockgroups[1], testinput_fips_tracts[1],
  testinput_fips_cities[1], testinput_fips_counties[1],
  testinput_fips_states[2])
data.frame(fips, sitename = fips2name(fips),
  stfips = fips2statefips(fips),
  state = fips2statename(fips))
```
