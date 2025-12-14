# UTILITY - check conflicting getNamespaceExports (names of exported functions or datasets)

See what same-named objects (functions or data) are exported by some
(installed) packages

## Usage

``` r
pkg_dupenames(
  pkg = EJAM::ejampackages,
  sortbypkg = FALSE,
  compare.functions = TRUE
)
```

## Arguments

- pkg:

  one or more package names as vector of strings. If "all" it checks all
  installed pkgs, but takes very very long potentially.

- sortbypkg:

  If TRUE, just returns same thing but sorted by package name

- compare.functions:

  If TRUE, sends to console inf about whether body and formals of the
  functions are identical between functions of same name from different
  packages. Only checks the first 2 copies, not any additional ones
  (where 3+ pkgs use same name)

## Value

data.frame with columns Package, Object name (or NA if no dupes)

## Details

utility to find same-named exported objects (functions or datasets)
within source code of 2+ packages, and see what is on search path, for
dev renaming / moving functions/ packages

See
[`pkg_dupeRfiles()`](https://ejanalysis.github.io/EJAM/reference/pkg_dupeRfiles.md)
for files supporting a shiny app that is not a package, e.g.

See `pkg_dupenames()` for objects that are in R packages.

See
[`pkg_functions_and_data()`](https://ejanalysis.github.io/EJAM/reference/pkg_functions_and_data.md),
pkg_functions_and_sourcefiles(), etc.

See
[`pkg_data()`](https://ejanalysis.github.io/EJAM/reference/pkg_data.md)
