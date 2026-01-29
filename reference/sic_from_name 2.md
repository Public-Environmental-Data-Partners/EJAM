# Search for industry names and SIC codes by query string

query by parts of words, etc. in the industry name.

## Usage

``` r
sic_from_name(mynames, children = FALSE, ignore.case = TRUE, fixed = FALSE)
```

## Arguments

- mynames:

  query string, vector of SIC industry names or any regular expression
  or partial words. See <https://siccode.com>

- children:

  logical, if TRUE, also return all the subcategories - where SIC starts
  with the same digits

- ignore.case:

  see [`grepl()`](https://rdrr.io/r/base/grep.html)

- fixed:

  should it be an exact match? see
  [`grepl()`](https://rdrr.io/r/base/grep.html)

## Value

a subset of the
[sictable](https://ejanalysis.github.io/EJAM/reference/sictable.md)
table in [data.table](https://r-datatable.com) format (not just the
codes column)

## See also

[`sic_subcodes_from_code()`](https://ejanalysis.github.io/EJAM/reference/sic_subcodes_from_code.md)
[`sic_from_code()`](https://ejanalysis.github.io/EJAM/reference/sic_from_code.md)
`sic_from_name()`
[`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)

## Examples

``` r
 data.table::fintersect(sic_from_any( "glass"), sic_from_any("paint"))
```
