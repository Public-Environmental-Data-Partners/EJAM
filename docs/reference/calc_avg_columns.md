# helper that looks up US or State averages for a vector of variable names (and optional vector of States)

helper that looks up US or State averages for a vector of variable names
(and optional vector of States)

## Usage

``` r
calc_avg_columns(
  varnames = intersect(EJAM::names_all_r, names(EJAM::usastats)),
  zones = "USA",
  lookup = NULL
)
```

## Arguments

- varnames:

  vector of character string names of indicators (like "pctlowinc" or
  names_e) that must be among colnames of usastats, statestats (or
  lookup if custom table used)

- zones:

  optional vector of 2-character upper case state abbreviations. can
  include repeats.

- lookup:

  optional, but for custom indicators a data.frame can be provided that
  is analogous to statestats and usastats – see examples

## Value

data.frame, one column per indicator or element of varnames vector, one
row per site or element of zones vector

## Details

Note the averages are not "calculated" per se, but are actually looked
up in a table of averages

For examples, see
[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)

This could be used, e.g., in doaggregate() or similar to get means for
indicators being analyzed

It assume you want to name output columns like varnames but with
hardcoded prefixes "avg." or "state.avg."
