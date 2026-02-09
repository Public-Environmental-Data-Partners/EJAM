# Search for industry names by SIC code(s), 4 digits each

Search for industry names by SIC code(s), 4 digits each

## Usage

``` r
sic_from_code(mycodes, children = FALSE)
```

## Arguments

- mycodes:

  vector of character SIC codes. see <https://siccode.com>

- children:

  logical, if TRUE, also return all the subcategories - where SIC starts
  with the same digits

## Value

a subset of the
[sictable](https://ejanalysis.github.io/EJAM/reference/sictable.md)
table in [data.table](https://r-datatable.com) format (not just the
codes column)

## See also

[`sic_subcodes_from_code()`](https://ejanalysis.github.io/EJAM/reference/sic_subcodes_from_code.md)
`sic_from_code()`
[`sic_from_name()`](https://ejanalysis.github.io/EJAM/reference/sic_from_name.md)
