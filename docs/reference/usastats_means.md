# usastats_means - convenient way to see US MEANS of ENVIRONMENTAL and residential population indicators

usastats_means - convenient way to see US MEANS of ENVIRONMENTAL and
residential population indicators

## Usage

``` r
usastats_means(
  varnames = c(EJAM::names_e, EJAM::names_d, EJAM::names_d_subgroups_nh),
  PCTILES = NULL,
  dig = 4
)
```

## Arguments

- varnames:

  names of columns in lookup table, like "proximity.rmp"

- PCTILES:

  vector of percentiles 0-100 and/or "mean"

- dig:

  how many digits to round to
