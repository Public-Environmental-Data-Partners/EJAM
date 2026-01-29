# FIPS - Get FIPS codes of the States CONTAINING the given census units (of any type)

FIPS - Get FIPS codes of the States CONTAINING the given census units
(of any type)

## Usage

``` r
fips2statefips(fips)
```

## Arguments

- fips:

  vector of FIPS

## Value

vector of State FIPS 2 characters each

## Details

Tells you which State contains each County (or tract or blockgroup or
block)

## Examples

``` r
n = 1:80
stfips= fips_lead_zero(n)[!is.na(fips2stateabbrev(n))]
data.frame(
  stfips = stfips,
  ST = fips2stateabbrev(stfips),
  statename = fips2statename(stfips),
  region = fips_st2eparegion(stfips)
)

cfips = fips_counties_from_state_abbrev("RI")
fips2countyname(cfips, includestate = "Statename")
fips2countyname(cfips)
fips2name(cfips)
fips2name(10001)
fips2name(fips_counties_from_statename(c("Delaware", "Rhode Island")))

mixfips = c(testinput_fips_blockgroups[1], testinput_fips_tracts[1],
  testinput_fips_cities[1], testinput_fips_counties[1],
  testinput_fips_states[2])
data.frame(mixfips,
  sitename = fips2name(mixfips),
  stfips = fips2statefips(mixfips),
  state = fips2statename(mixfips))
```
