# Compile formulas needed to calculate one or more final indicators

Compile formulas needed to calculate one or more final indicators

## Usage

``` r
calc_formulas_from_varname(varname = "pctlowinc", formulas = NULL, top = TRUE)
```

## Arguments

- varname:

  one or more character string variable names found in the `"rname"`
  column of the formulas parameter.

- formulas:

  default is to use the built-in
  [formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md),
  but a custom data.frame can be supplied if it has columns `"rname"`
  and `"formula"`.

- top:

  do not change.

## Value

data.frame with columns `"rname"` and `"formula"`, similar to those
columns as found in
[formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md).

## Details

Recursively finds formulas for any intermediate variables that are also
outputs in the supplied formula table, then sorts them so dependencies
are calculated before they are used.

## Examples

``` r
EJAM:::calc_formulas_from_varname("pctlingiso")
EJAM:::calc_formulas_from_varname("pctlths")
EJAM:::calc_formulas_from_varname("pctlowinc")
EJAM:::calc_formulas_from_varname(c("lingiso", "lowinc"))
```
