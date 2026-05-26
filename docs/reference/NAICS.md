# NAICS (DATA) named vector of all NAICS code numbers and industry name for each

A named vector of more than 2,000 NAICS code numbers and industry name
for each

## Usage

``` r
NAICS
```

## Format

An object of class `numeric` of length 2200.

## Details

This is a named set of numeric codes, where a name has the code and
title, like '22132 - Sewage Treatment Facilities' or '22 - Utilities'
Revised codes have been published every five years, such as in 2017 and
2022.

The version used should match the version used in assigning codes to the
EPA FRS facilities. As of 10/2025, the 2017 NAICS codes were being used
in EJAM because the copy of EPA FRS being used by EJAM is somewhat
outdated but the NAICS codes in it were clearly be 2017-style NAICS not
2022-style codes.

For more info, see
[`naics_download()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_download.md)
and (https://naics.com)

and [2022 codes](https://www.census.gov/naics/?58967?yearbck=2022)

and [2017 codes](https://www.census.gov/naics/?58967?yearbck=2017)

## See also

[`naics_download()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_download.md)
[naicstable](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md)
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
[`naics_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_categories.md)
NAICS
