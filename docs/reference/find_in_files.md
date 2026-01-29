# utility to do global search/find in full text of the files in a folder, like source code files or unit tests

utility to do global search/find in full text of the files in a folder,
like source code files or unit tests

## Usage

``` r
find_in_files(
  pattern,
  path = ".",
  recursive = TRUE,
  filename_pattern = "\\.R$|\\.r$",
  full.names = TRUE,
  ignorecomments = FALSE,
  ignore.case = TRUE,
  whole_line = TRUE,
  quiet = FALSE
)
```

## Arguments

- pattern:

  regular expression to look for

- path:

  can be e.g., "./R" or "./tests/testthat" or "."

- recursive:

  if TRUE, search includes subfolders (passed to
  [`list.files()`](https://rdrr.io/r/base/list.files.html))

- filename_pattern:

  default is R code files only! A regular expression that would limit
  file names to search

- full.names:

  if TRUE, returns paths not just filenames (passed to
  [`list.files()`](https://rdrr.io/r/base/list.files.html))

- ignorecomments:

  omit hits from commented out lines

- ignore.case:

  as in grep

- whole_line:

  set it to FALSE to see only the matching fragments vs entire line of
  text that has a match in it

- quiet:

  whether to print results or just invisibly return

## Value

a list of named vectors, where names are file paths with hits, elements
are vectors of text with hits.

## Details

Also see undocumented related functions
EJAM:::found_in_N_files_T_times() and EJAM:::found_in_files() and
EJAM:::grab_hits() and EJAM:::grepn()

## Examples

``` r
EJAM:::find_in_files("[^_]logo_....",    path = "./R", whole_line = FALSE)
EJAM:::find_in_files("report_logo.....", path = "./R", whole_line = FALSE)
EJAM:::find_in_files("app_logo......",   path = "./R", whole_line = FALSE)

EJAM:::find_in_files("latlon_from_.{18}",    whole_line = F)
EJAM:::find_in_files("latlon_from_s.{9}",    whole_line = F)
EJAM:::find_in_files("latlon_from_mact.{9}", whole_line = F)
```
