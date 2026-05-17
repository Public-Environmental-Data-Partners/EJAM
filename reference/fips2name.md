# FIPS - Get county or state names from county or state FIPS codes

FIPS - Get county or state names from county or state FIPS codes

## Usage

``` r
fips2name(fips, quiet = FALSE, ...)
```

## Arguments

- fips:

  vector of US Census FIPS codes for

  - States (2 digits once any required leading zeroes are included)

  - Counties (5)

  - City/town/CDP (7)

  - Tracts (11)

  - Blockgroups (12) Can be string or numeric, with or without leading
    zeroes.

- quiet:

  whether to silence warnings – also passed to
  [`fips_lead_zero()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_lead_zero.md)
  and
  [`fipstype()`](https://public-environmental-data-partners.github.io/EJAM/reference/fipstype.md)

- ...:

  passed to
  [`fips2countyname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2countyname.md)
  to control whether it appends something like , NY or , New York after
  county name

## Value

vector of state and/or county names, where county names optionally have
comma and 2-character abbreviation or full state name.

## Details

This reports the name of the census unit specified by the FIPS code.

Other functions can instead report the name or code of the enclosing
(parent, surrounding) unit, such as the State or County that each fips
is located within.

## See also

[`fips_counties_from_countyname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_counties_from_countyname.md)

## Examples

``` r
fips2name(fips_counties_from_statename("Delaware"))
cfips = fips_counties_from_state_abbrev(c("RI", "DE"))
fips2name(cfips)
fips2name("10001")

mixfips = c(testinput_fips_blockgroups[1], testinput_fips_tracts[1],
            testinput_fips_cities[1], testinput_fips_counties[1],
            testinput_fips_states[2])
data.frame(mixfips,
           sitename = fips2name(mixfips),
           stfips = EJAM:::fips2statefips(mixfips),
           ST = fips2stateabbrev(mixfips),
           state = fips2statename(mixfips) )

name2fips("Alaska")
name2fips("NY")
name2fips("Kings County, NY")
name2fips("Minneapolis, MN")

name2fips("Anchorage, AK") # not found
name2fips("Anchorage, AK", usegrep = TRUE) # finds the city
name2fips("Anchorage municipality, AK") # finds the county of same name, not city
```
