# NAICS - Search for industry names and NAICS codes by query string

query by parts of words, etc. in the industry name.

## Usage

``` r
naics_from_name(mynames, children = FALSE, ignore.case = TRUE, fixed = FALSE)
```

## Arguments

- mynames:

  query string, vector of NAICS industry names or any regular expression
  or partial words. See <https://naics.com>

- children:

  logical, if TRUE, also return all the subcategories - where NAICS
  starts with the same digits

- ignore.case:

  see [`grepl()`](https://rdrr.io/r/base/grep.html)

- fixed:

  should it be an exact match? see
  [`grepl()`](https://rdrr.io/r/base/grep.html)

## Value

a subset of the
[naicstable](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md)
data.table (not just the codes column)

## Details

See
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
which uses this

## See also

[`naics_findwebscrape()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_findwebscrape.md)
[`naics_subcodes_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_subcodes_from_code.md)
[`naics_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_code.md)
`naics_from_name()`
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Examples

``` r
 data.table::fintersect(naics_from_any( "manufac"), naics_from_any("chem"))
  EJAM:::naics_from_name("silver")
```
