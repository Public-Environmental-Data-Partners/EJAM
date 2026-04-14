# utility for developing package - searches for text in each function exported by pkg (or each .R source file in pkg/R)

utility for developing package - searches for text in each function
exported by pkg (or each .R source file in pkg/R)

## Usage

``` r
pkg_functions_that_use(
  text = "stop\\(",
  pkg = "EJAM",
  ignore_comments = TRUE,
  internal_included = TRUE
)
```

## Arguments

- text:

  something like "EJAM::" or "stop\\" or "library\\" or "\*\*\*"

- pkg:

  name of package or path to source package root folder - this

  checks only the exported functions of an installed package, if pkg =
  some installed package as character string like "EJAM"

  checks each .R source FILE NOT each actual function, if pkg = root
  folder of source package with subfolder called R with .R source files

- ignore_comments:

  logical, ignore_comments is ignored and treated as if it were TRUE
  when pkg = some installed package

  ignore_comments is used only if pkg = a folder that contains .R files

  Note it will fail to ignore comments in .R files that are at the end
  of the line of actual code like print(1) \# that prints 1

- internal_included:

  whether to also check internal functions - tries to identify those
  using
  [`pkg_functions_and_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_functions_and_data.md)

## Value

vector of names of functions or paths to .R files

## Details

Searches the body and parameter defaults of exported functions.
