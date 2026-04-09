# helper function - assign fill color to shade excel cells by indicator type and category

Use color shading to make spreadsheet easier to use, grouping the
indicators

## Usage

``` r
vartype_cat2color_ejam(vartype = raw, varcategory = "other")
```

## Arguments

- vartype:

  must be one found in dput(unique(map_headernames\$vartype)) like
  "usratio", "stateratio", "usraw", "stateraw", "uspctile",
  "statepctile", "usavg", "stateavg", etc. NA if not found.

- varcategory:

  must be one of "Demographic" "Environmental" "Summary Index" "other"
  as from dput(unique(map_headernames\$varcategory))

## Value

vector of colors like c('lightblue', 'gray') matching length of vartype

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`varname2vartype_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/varname2vartype_ejam.md)
[`varname2varcategory_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/varname2varcategory_ejam.md)
[`varname2color_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/varname2color_ejam.md)
