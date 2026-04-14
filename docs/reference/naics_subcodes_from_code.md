# NAICS - find subcategories of the given overall NAICS industry code(s)

Given 3-digit NAICS code, for example, get all NAICS that start with
those digits.

## Usage

``` r
naics_subcodes_from_code(mycodes)
```

## Arguments

- mycodes:

  NAICS codes vector, of 2 to 6 digits each. See <https://naics.com>

## Value

a subset of the
[naicstable](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md)
data.table (not just the codes column)

## Details

similar idea was naics2children() but this is more robust See
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
which uses this

## See also

`naics_subcodes_from_code()`
[`naics_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_code.md)
[`naics_from_name()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_name.md)
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Examples

``` r
  naics_categories()
```
