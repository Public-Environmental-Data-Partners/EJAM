# helper function - given indicator names, look up what type each is

helper function - given indicator names, look up what type each is

## Usage

``` r
varname2vartype_ejam(varname, varnameinfo)
```

## Arguments

- varname:

  vector of 1 or more names

- varnameinfo:

  data.frame with info on type of each variable

## Value

vector same size as varname

## Details

The types are things like raw data count for indicator, average,
percentile, etc.

## See also

[`varinfo()`](https://ejanalysis.github.io/EJAM/reference/varinfo.md)
[`vartype_cat2color_ejam()`](https://ejanalysis.github.io/EJAM/reference/vartype_cat2color_ejam.md)
[`varname2color_ejam()`](https://ejanalysis.github.io/EJAM/reference/varname2color_ejam.md)
