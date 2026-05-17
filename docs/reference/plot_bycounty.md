# plot comparison of counties in 1 state, for 1 indicator (variable)

plot comparison of counties in 1 state, for 1 indicator (variable)

## Usage

``` r
plot_bycounty(
  x,
  myvars = x$variable[1],
  myvarnames = NULL,
  mystate = NULL,
  labeltype = NULL,
  acsinfo = NULL,
  yr = NULL
)
```

## Arguments

- x:

  table that is output of
  [`acs_bycounty()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bycounty.md)
  i.e., output of
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)
  that downloads ACS Census Bureau data via API.

- myvars:

  optional .extracted from x, one (or more?) ACS5 variables like
  "B03002_001"

- myvarnames:

  optional friendlier names of myvars

- mystate:

  name of state

- labeltype:

  as from scales package. for continuous scales: label_bytes(),
  label_number_auto(), label_number_si(), label_ordinal(),
  label_parse(), label_percent(), label_pvalue(), label_scientific()

- acsinfo:

  large table of metadata as from load_variables() function from the
  [tidycensus package](https://walker-data.com/tidycensus/)

- yr:

  The year that is the end of a 5 year ACS survey, such as 2022 for the
  ACS covering 2018-2022. Default is whatever then package is currently
  using, per
  [`acs_endyear()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_endyear.md).

## Value

plot
