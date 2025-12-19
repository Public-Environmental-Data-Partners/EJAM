# Find subcategories of the given overall SIC industry code(s)

Given 3-digit SIC code, for example, get all SIC that start with those
digits.

## Usage

``` r
sic_subcodes_from_code(mycodes)
```

## Arguments

- mycodes:

  SIC codes vector, of 2 to 4 digits each. See <https://siccode.com>

## Value

a subset of the
[sictable](https://ejanalysis.github.io/EJAM/reference/sictable.md)
table in [data.table](https://r-datatable.com) format (not just the
codes column)

## Details

similar idea was naics2children() but this is more robust See
[`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)
which uses this

## See also

`sic_subcodes_from_code()`
[`sic_from_code()`](https://ejanalysis.github.io/EJAM/reference/sic_from_code.md)
[`sic_from_name()`](https://ejanalysis.github.io/EJAM/reference/sic_from_name.md)
[`sic_from_any()`](https://ejanalysis.github.io/EJAM/reference/sic_from_any.md)

## Examples

``` r
  # codes starting with '07'
  sic_subcodes_from_code('07')
  # codes starting with '078'
  sic_subcodes_from_code('078')
```
