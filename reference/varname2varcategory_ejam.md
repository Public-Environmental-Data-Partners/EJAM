# helper function - given indicator names, look up what category each is

helper function - given indicator names, look up what category each is

## Usage

``` r
varname2varcategory_ejam(varname, varnameinfo)
```

## Arguments

- varname:

  vector of 1 or more names like "pctlowinc" as in
  unique(map_headernames\$rname)

- varnameinfo:

  data.frame with info on type of each variable

## Value

vector same size as varname

## Details

tells if variable is "Demographic" "Environmental" "Summary Index" aka
"EJ Index" or "other" as from dput(unique(map_headernames\$varcategory))

## See also

[`varinfo()`](https://ejanalysis.github.io/EJAM/reference/varinfo.md)
[`vartype_cat2color_ejam()`](https://ejanalysis.github.io/EJAM/reference/vartype_cat2color_ejam.md)
[`varname2color_ejam()`](https://ejanalysis.github.io/EJAM/reference/varname2color_ejam.md)
