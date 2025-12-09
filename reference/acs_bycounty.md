# download ACS 5year data from Census API, at County resolution

download ACS 5year data from Census API, at County resolution

## Usage

``` r
acs_bycounty(myvars = "B03002_001", myst = "DE", yr = acsendyear())
```

## Arguments

- myvars:

  optional .extracted from x, one or more ACS5 variables like
  "B03002_001"

- myst:

  abbreviation of one state, like "DE"

- yr:

  like 2023, end of 5 year ACS 2019-2023

## Value

tibble table from output of acs_bycounty() i.e., output of get_acs()
from tidycensus pkg

## Examples

``` r
## also see examples for acs_bybg()
# \donttest{
  x     <- acs_bycounty(myvars = "B03002_003", myst = "NY", yr = acsendyear(guess_always = T, guess_census_has_published = T)) # nhwa
  denom <- acs_bycounty(myvars = "B03002_001", myst = "NY", yr = acsendyear(guess_always = T, guess_census_has_published = T)) # pop
  z = x
  z$estimate = x$estimate / denom$estimate
  z$moe = 0  # x$moe / denom$estimate # need to calculate using census guidance if at all
  # z$variable = "pctnhwa" # not used if myvarnames is given
  # plot_bycounty(z, myvarnames = "Percent NonHispanic White Alone (i.e., Not People of Color)",
  #               labeltype = scales::label_percent()) # requires scales package
# }
```
