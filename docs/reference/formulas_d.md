# formulas_d (DATA) table of formulas to aggregate or calculate indicators

These formulas can describe how each indicator is calculated from raw
data or intermediate variables, like population counts from Census ACS
(or potentially formulas for how it is aggregated as a weighted mean,
etc.)

## Usage

``` r
formulas_d
```

## Format

An object of class `character` of length 130.

## Details

Created for EJAM by datacreate_formulas.R script

See also
[formulas_all](https://ejanalysis.github.io/EJAM/reference/formulas_all.md)
and
[formulas_ejscreen_acs](https://ejanalysis.github.io/EJAM/reference/formulas_ejscreen_acs.md)

Can be used by
[`calc_ejam()`](https://ejanalysis.github.io/EJAM/reference/calc_ejam.md)
or
[`acs_bybg()`](https://ejanalysis.github.io/EJAM/reference/acs_bybg.md)
for

1.  aggregation over blockgroups at a site or

2.  to create a derived custom indicator for all US blockgroups based on
    counts obtained from the ACS.)
