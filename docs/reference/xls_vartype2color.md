# helper function - assign fill color to shade excel cells by indicator type - NOT USED except by unused function xls_varname2color()

Use color shading to make spreadsheet easier to use, grouping the
indicators

## Usage

``` r
xls_vartype2color(vartype)
```

## Arguments

- vartype:

  must be one found in varnameinfo\$jsondoc_vartype, ie "percentile",
  "average", or "raw data for indicator" NA if not found.

## Value

vector of colors like c('lightorange', 'gray')

## See also

[`xls_varname2vartype()`](https://public-environmental-data-partners.github.io/EJAM/reference/xls_varname2vartype.md)
`xls_vartype2color()`
[`xls_varname2color()`](https://public-environmental-data-partners.github.io/EJAM/reference/xls_varname2color.md)
