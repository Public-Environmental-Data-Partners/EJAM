# naicstable (DATA) data.table of NAICS code(s) and industry names for each EPA-regulated site

data.table of NAICS code(s) and industry names for each EPA-regulated
site in Facility Registry Service Also has the 2,3,4,5,and 6-digit NAICS
that this code falls under, where relevant for given length

## Usage

``` r
naicstable
```

## Format

An object of class `data.table` (inherits from `data.frame`) with 2200
rows and 8 columns.

## Details

This is similar to the data file EJAM::NAICS but in a more useful format
and newer functions work with it. see [NAICS.com](https://naics.com)

## See also

[`naics_from_any()`](https://ejanalysis.github.io/EJAM/reference/naics_from_any.md)
[NAICS](https://ejanalysis.github.io/EJAM/reference/NAICS.md)
[`naics_categories()`](https://ejanalysis.github.io/EJAM/reference/naics_categories.md)
[`naics_findwebscrape()`](https://ejanalysis.github.io/EJAM/reference/naics_findwebscrape.md)
