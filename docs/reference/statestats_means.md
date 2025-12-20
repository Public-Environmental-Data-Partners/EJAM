# statestats_means - convenient way to see STATE MEANS of ENVIRONMENTAL and RESIDENTIAL POPULATION indicators

statestats_means - convenient way to see STATE MEANS of ENVIRONMENTAL
and RESIDENTIAL POPULATION indicators

## Usage

``` r
statestats_means(
  ST = unique(EJAM::statestats$REGION),
  varnames = c(EJAM::names_e, EJAM::names_d, EJAM::names_d_subgroups_nh),
  PCTILES = "mean",
  dig = 4
)
```

## Arguments

- ST:

  vector of state abbreviations, or USA

- varnames:

  names of columns in lookup table, like "proximity.rmp"

- PCTILES:

  vector of percentiles 0-100 and/or "mean"

- dig:

  digits to round to
