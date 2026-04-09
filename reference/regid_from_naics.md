# Find registry ids of EPA-regulated facilities in FRS by NAICS code (industrial category) Like latlon_from_naics() but returns only regid

Find registry ids of EPA-regulated facilities in FRS by NAICS code
(industrial category) Like latlon_from_naics() but returns only regid

## Usage

``` r
regid_from_naics(naics, children = TRUE, id_only = TRUE, ...)
```

## Arguments

- naics:

  a vector of naics codes, or a data.table with column named code, as
  with output of
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

- children:

  optional logical. Must set to TRUE to get facilities whose NAICS
  starts with provided naics (or naics based on provided title) rather
  than only exact matches. Many facilities have only a longer more
  specific NAICS code listed in the FRS, such as a 6-digit code, so if
  the category (e.g., 4-digit) is queried then children = TRUE has to be
  specified to find all the sites within that overall category.

- id_only:

  optional, only for backward compatibility

- ...:

  passed to
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Value

vector of registry ID values of facilities in EPA FRS that are listed
there as being in this/these NAICS, like
[`latlon_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_naics.md)
but with id_only = TRUE

## Details

Finding the right NAICS/SIC and finding all the right sites is
complicated. See discussion of
[`latlon_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_naics.md).

## See also

[`latlon_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_naics.md)
