# FIPS - Get unique blockgroup fips in or containing specified fips of any type

Convert any FIPS codes to the FIPS of all the blockgroups that are among
or within or containing those FIPS

## Usage

``` r
fips_bgs_in_fips(fips)
```

## Arguments

- fips:

  vector of US FIPS codes, as character or numeric, with or without
  their leading zeroes, each with as many characters

## Value

vector of blockgroup FIPS (or NA values) that may be much longer than
the vector of fips passed to this function.

## Details

This is a way to get a list of blockgroups, specified by
state/county/tract or even block.

Takes a vector of one or more FIPS that could be State (2-digit), County
(5-digit), Tract (11-digit), or blockgroup (12 digit), or even block
(15-digit fips).

It also works for city/CDP fips but finds the blockgroups that are at
least partly in the city bounds (see
[`fips_bgs_in_city()`](https://ejanalysis.github.io/EJAM/reference/fips_bgs_in_city.md)).

Returns unique vector of FIPS of all US blockgroups (including DC and
Puerto Rico) that contain any specified blocks, are equal to any
specified blockgroup fips, or are contained within any provided
tract/county/state FIPS.

## See also

[`fips_lead_zero()`](https://ejanalysis.github.io/EJAM/reference/fips_lead_zero.md)

## Examples

``` r
  # all blockgroups in one state (as a single vector)
  fips_counties_from_state_abbrev("DE") # there are 3 counties
  fips_bgs_in_fips( fips_counties_from_state_abbrev("DE") )

  blockgroupstats[,.N,by=substr(bgfips,1,2)]
  length(fips_bgs_in_fips("72")) # finds all that blockgroupstats has

  # all blockgroups in this one county
  fips_bgs_in_fips(30001)

  # all blockgroups for (that contain any of) these 6 blocks (i.e., just one bg)
  x = c("010010201001000", "010010201001001", "010010201001002",
   "010010201001003", "010010201001004", "010010201001005")
  fips_bgs_in_fips(x)

testfipslist <- list(
  blockgroup = testinput_fips_blockgroups,
  tract = testinput_fips_tracts,
  city = testinput_fips_cities, #
  county = testinput_fips_counties,
  state = testinput_fips_states,
  mix = c(testinput_fips_blockgroups[1],
          testinput_fips_tracts[3],
          testinput_fips_cities[1],
          "53023",
          56) # name2fips('WY')
)
testfipslist = lapply(testfipslist, function(z) {attributes(z) <- NULL; z}) # drop distracting metadata

x  = sapply(testfipslist, function(v) sapply(v, fips_bgs_in_fips ))
x1 = sapply(testfipslist, function(v) sapply(v, EJAM:::fips_bgs_in_fips1))
all.equal(x, x1)
x['tract']
x['county']
```
