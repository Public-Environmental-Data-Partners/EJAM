# formulas_all (DATA) table of formulas to aggregate or calculate indicators

These formulas can describe how each indicator is calculated from other
variables like counts or how it is aggregated as a weighted mean, etc.

## Usage

``` r
formulas_all
```

## Format

An object of class `character` of length 202.

## Details

Created for EJAM by datacreate_formulas.R script

See also formulas_all and
[formulas_ejscreen_acs](https://ejanalysis.github.io/EJAM/reference/formulas_ejscreen_acs.md)

Can be used by
[`calc_ejam()`](https://ejanalysis.github.io/EJAM/reference/calc_ejam.md)
or
[`acs_bybg()`](https://ejanalysis.github.io/EJAM/reference/acs_bybg.md)
for

1.  aggregation over blockgroups at a site or

2.  to create a derived custom indicator for all US blockgroups based on
    counts obtained from the ACS.)
