# Barplot of ratios of 1 State's indicator averages vs US overall

Barplot of ratios of 1 State's indicator averages vs US overall

## Usage

``` r
plot_st_v_us(ST = "CA", varnames = names_these)
```

## Arguments

- ST:

  state abbreviation like "NY"

- varnames:

  vector of character names of raw indicator variables that are among
  names(statestats), like "pm" or "pctlowinc" or a vector like names_d
  or names_e

## Value

similar to
[`plot_barplot_ratios()`](https://ejanalysis.github.io/EJAM/reference/plot_barplot_ratios.md)

## Examples

``` r
plot_st_v_us("CA", names_these)
```
