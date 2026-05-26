# naicstable (DATA) data.table of all possible NAICS code(s) and industry names

naicstable (DATA) data.table of all possible NAICS code(s) and industry
names

## Usage

``` r
naicstable
```

## Format

An object of class `data.table` (inherits from `data.frame`) with 2200
rows and 8 columns.

## Details

data.table of all possible NAICS code(s) and industry names (which get
used to classify EPA-regulated sites in Facility Registry Service (FRS))
Also has the 2,3,4,5,and 6-digit NAICS (categories and subcategories)
that this code falls under, where relevant for given length. Code
universe was updated in 2022, but EPA FRS as of 2025 was still using
NAICS codes from the 2017 update of industry codes and names.

This is similar to the data file EJAM::NAICS but in a more useful format
and newer functions work with it. see [NAICS.com](https://naics.com)

## See also

[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
[NAICS](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md)
[`naics_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_categories.md)
[`naics_findwebscrape()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_findwebscrape.md)
