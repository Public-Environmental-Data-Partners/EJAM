# download ACS 5year data from Census API, at County resolution

download ACS 5year data from Census API, at County resolution

## Usage

``` r
acs_bycounty(myvars = "B03002_001", myst = "DE", yr = NULL)
```

## Arguments

- myvars:

  optional .extracted from x, one or more ACS5 variables like
  "B03002_001"

- myst:

  abbreviation of one state, like "DE"

- yr:

  Default is what the package is currently using as default per
  [`acs_endyear()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_endyear.md).
  A year like 2024, end of 5 year ACS 2020-2024

## Value

tibble table from output of acs_bycounty() i.e., output of
[`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)

## Examples

``` r
## also see examples for acs_bybg()
# \donttest{
  x     <- acs_bycounty(myvars = "B03002_003", myst = "NY", yr = acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)) # nhwa
  denom <- acs_bycounty(myvars = "B03002_001", myst = "NY", yr = acs_endyear(guess_always = TRUE, guess_census_has_published = TRUE)) # pop
  z = x
  z$estimate = x$estimate / denom$estimate
  z$moe = 0  # x$moe / denom$estimate # need to calculate using census guidance if at all
  # z$variable = "pctnhwa" # not used if myvarnames is given
  # plot_bycounty(z, myvarnames = "Percent NonHispanic White Alone (i.e., Not People of Color)",
  #               labeltype = scales::label_percent()) # requires scales package
# }
```
