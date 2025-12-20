# Quick view of summary stats by type of stat, but lacks rounding specific to each type, etc.

Quick view of summary stats by type of stat, but lacks rounding specific
to each type, etc.

## Usage

``` r
ejam2ratios(ejamitout, sitenumber = NULL, decimals = 1)
```

## Arguments

- ejamitout:

  list as from ejamit() that includes results_overall

- sitenumber:

  if NULL, uses overall results. If an integer, uses that site, based on
  just one row from ejamitout\$results_bysite

- decimals:

  optional number of decimal places to round to

## Value

prints to console and returns a simple data.frame

## Examples

``` r
 ejam2barplot(testoutput_doaggregate_100pts_1miles)
 ejam2ratios(testoutput_ejamit_100pts_1miles)
```
