# NAICS - search for industry names by NAICS code(s), 2-6 digits long each

See
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
which uses this

## Usage

``` r
naics_from_code(mycodes, children = FALSE)
```

## Arguments

- mycodes:

  vector of numeric NAICS codes. see <https://naics.com>

- children:

  logical, if TRUE, also return all the subcategories - where NAICS
  starts with the same digits

## Value

a subset of the
[naicstable](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md)
data.table (not just the codes column)

## See also

[`naics_subcodes_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_subcodes_from_code.md)
`naics_from_code()`
[`naics_from_name()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_name.md)
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
