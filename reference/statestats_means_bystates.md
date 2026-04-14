# statestats_means - convenient way to see STATE MEANS of indicators for a list of states (that can have repeats)

Given a vector of 2-char ST abbrevs, and vector of colnames in
statestats table (indicator names), return data.frame of state averages

## Usage

``` r
statestats_means_bystates(
  ST = unique(EJAM::statestats$REGION),
  varnames = names_these,
  PCTILES = "mean"
)
```

## Arguments

- ST:

  vector of 2-char ST abbrevs, or all values can be "USA" to get
  duplicate rows like found in `ejamit()$results_bysite[, names_d_avg]`

- varnames:

  vector of colnames in statestats table (indicator names)

- PCTILES:

  "mean"

## Value

data.frame of state averages for those, one row per ST provided (can
have repeats) and colnames are varnames.
