# helper function - given indicator names, look up what type each is - NOT USED except by unused function xls_varname2color()

helper function - given indicator names, look up what type each is - NOT
USED except by unused function xls_varname2color()

## Usage

``` r
xls_varname2vartype(varname, varnameinfo)
```

## Arguments

- varname:

  vector of 1 or more names

- varnameinfo:

  data.frame with info on type of each variable, like map_headernames

## Value

vector same size as varname

## Details

The types are things like raw data count for indicator, average,
percentile, etc. Variable names can be from column of map_headernames
called rname, e.g. Types are stored in column of map_headernames called
jsondoc_vartype

## See also

`xls_varname2vartype()`
[`xls_vartype2color()`](https://public-environmental-data-partners.github.io/EJAM/reference/xls_vartype2color.md)
[`xls_varname2color()`](https://public-environmental-data-partners.github.io/EJAM/reference/xls_varname2color.md)
