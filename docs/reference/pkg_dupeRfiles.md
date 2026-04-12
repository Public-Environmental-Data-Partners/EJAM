# UTILITY - check conflicting sourcefile names in 2 packages/folders

See what same-named .R files are in 2 sourcecode folders

## Usage

``` r
pkg_dupeRfiles(folder1 = "../EJAM/R", folder2 = "./R")
```

## Arguments

- folder1:

  path to other folder with R source files

- folder2:

  path to a folder with R source files, defaults to "./R"

## Details

See `pkg_dupeRfiles()` for files supporting a shiny app that is not a
package

See
[`pkg_dupenames()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_dupenames.md)
for objects that are in R packages.

See
[`pkg_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_data.md)
for objects that are in R packages.

See
[`pkg_functions_and_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_functions_and_data.md)
for functions in R package.

See
[`pkg_functions_that_use()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_functions_that_use.md) -
searches for text in each function exported by pkg (or each .R source
file in pkg/R)
