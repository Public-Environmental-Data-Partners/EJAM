# utility to do global search/find in full text of the files in a folder, like source code files or unit tests

utility to do global search/find in full text of the files in a folder,
like source code files or unit tests

## Usage

``` r
find_in_files(
  pattern,
  path = "./tests/testthat",
  filename_pattern = "\\.R$|\\.r$",
  ignorecomments = FALSE,
  ignore.case = TRUE,
  value = TRUE,
  whole_line = TRUE,
  quiet = TRUE
)
```

## Arguments

- pattern:

  regular expression to look for

- path:

  can change it to e.g., "./R"

- filename_pattern:

  query regex on file names, default is R code files

- ignorecomments:

  omit hits from commented out lines

- ignore.case:

  as in grep

- value:

  logical as in [`grep()`](https://rdrr.io/r/base/grep.html) if TRUE
  returns matching text; if FALSE, returns logical vectors like
  [`grepl()`](https://rdrr.io/r/base/grep.html)

- whole_line:

  set it to FALSE to see only the matching fragments vs entire line of
  text that has a match in it

- quiet:

  whether to print results or just invisibly return

## Value

list of named vectors, where names are file paths with hits, elements
are vectors of text with hits

## Examples

``` r
EJAM:::find_in_files("[^_]logo_....",    path = "./R", whole_line = FALSE, quiet = F)
EJAM:::find_in_files("report_logo.....", path = "./R", whole_line = FALSE, quiet = F)
EJAM:::find_in_files("app_logo......",   path = "./R", whole_line = FALSE, quiet = F)

EJAM:::find_in_files("latlon_from_.{18}", quiet = FALSE, whole_line = F)
EJAM:::find_in_files("latlon_from_s.{9}", quiet = FALSE, whole_line = F)
EJAM:::find_in_files("latlon_from_mact.{9}", quiet = FALSE, whole_line = F)
```
