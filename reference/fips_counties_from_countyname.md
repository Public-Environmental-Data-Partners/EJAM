# get FIPS for a county based on part of the countyname and state abbrev

get FIPS for a county based on part of the countyname and state abbrev

## Usage

``` r
fips_counties_from_countyname(countyname_start, ST = NULL, exact = TRUE)
```

## Arguments

- countyname_start:

  first few letters of countyname to look for via grep("^x", ) like
  "Johnson" or "Johnson County". Ignores case.

- ST:

  two letter abbreviation of State, such as "TX" – Can only be omitted
  if the 1st parameter has the full name and ST like "Harris County,
  TX". Ignores case.

- exact:

  TRUE requires exact matches, FALSE to allow partial matches which here
  means first few letters match (it is not using grep), and in which
  case outputs might differ from inputs in length and not be 1-to-1

## Value

the county FIPS (5 digits long with leading zero if needed, as
character) but can return more than one guess per input name!

## Examples

``` r
 fips2name(fips_counties_from_countyname("Har", "TX")) # finds 5 matches
 fips_counties_from_countyname("Har",               "TX")    # finds 5  matches
 fips_counties_from_countyname("Harris",            "TX")    # finds 2 matches
 fips_counties_from_countyname("Harris ",           "TX")    # finds 1 match
 fips_counties_from_countyname("Harris County",     "TX")    # same
 fips_counties_from_countyname("harris county, tx", "TX")    # same
 fips_counties_from_countyname("Harris County, Texas", "TX") # finds 0 if state spelled out
 fips_counties_from_countyname("harris county, tx") # can omit ST param like this
 fips_counties_from_countyname("Harris County TX")  # needs comma
```
