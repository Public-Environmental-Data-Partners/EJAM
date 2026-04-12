# utility to see which objects in a loaded/attached package are functions or datasets, exported or not (internal)

utility to see which objects in a loaded/attached package are functions
or datasets, exported or not (internal)

## Usage

``` r
pkg_functions_and_data(
  pkg = "EJAM",
  alphasort_table = FALSE,
  internal_included = TRUE,
  exportedfuncs_included = TRUE,
  data_included = TRUE,
  vectoronly = FALSE
)
```

## Arguments

- pkg:

  name of package as character like "EJAM"

- alphasort_table:

  default is FALSE, to show internal first as a group, then exported
  funcs, then datasets

- internal_included:

  default TRUE includes internal (unexported) objects in the list

- exportedfuncs_included:

  default TRUE includes exported functions (non-datasets, actually) in
  the list

- data_included:

  default TRUE includes datasets in the list, as would be seen via
  data(package=pkg)

- vectoronly:

  set to TRUE to just get a character vector of object names instead of
  the data.frame table output

## Value

table in [data.table](https://r-datatable.com) format with colnames
object, exported, data where exported and data are 1 or 0 for T/F,
unless vectoronly = TRUE in which case it returns a character vector

## Details

See
[`pkg_dupeRfiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_dupeRfiles.md)
for files supporting a shiny app that is not a package, e.g.

See
[`pkg_dupenames()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_dupenames.md)
for objects that are in R packages.

See `pkg_functions_and_data()`, pkg_functions_and_sourcefiles(),

See
[`pkg_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_data.md)

## See also

[`ls()`](https://rdrr.io/r/base/ls.html)
[`getNamespace()`](https://rdrr.io/r/base/ns-reflect.html)
[`getNamespaceExports()`](https://rdrr.io/r/base/ns-reflect.html)
[`loadedNamespaces()`](https://rdrr.io/r/base/ns-load.html)

## Examples

``` r
 # EJAM:::pkg_functions_and_data("datasets")
```
