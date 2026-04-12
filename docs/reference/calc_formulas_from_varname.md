# compile the formulas needed to calculate one or more final indicators by recursively getting formulas for the intermediate variables also

compile the formulas needed to calculate one or more final indicators by
recursively getting formulas for the intermediate variables also

## Usage

``` r
calc_formulas_from_varname(varname = "pctlowinc", formulas = NULL, top = TRUE)
```

## Arguments

- varname:

  one or more character string variable names found in the "rname"
  column of the formulas parameter

- formulas:

  default is to use the built-in
  [formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md),
  but a custom data.frame would similarly need to have colnames "rname"
  and "formula"

- top:

  do not change

## Value

data.frame with colnames "rname" and "formula", similar to those columns
as found in
[formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md)

## Examples

``` r
calc_formulas_from_varname("pctlingiso")
calc_formulas_from_varname('pctlths')
calc_formulas_from_varname("pctlowinc")
calc_formulas_from_varname(c("lingiso", "lowinc"))
```
