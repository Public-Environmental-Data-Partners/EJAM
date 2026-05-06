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
  yr = acs_endyear()
)
```

## Arguments

- x:

  table that is output of acs_bycounty() i.e., output of get_acs() from
  tidycensus pkg that downloads ACS Census Bureau data via API.

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

  large table of metadata as from load_variables function from
  tidycensus pkg

- yr:

  like 2022, end of 5 year ACS 2018-2022

## Value

plot
