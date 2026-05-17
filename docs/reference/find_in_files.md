# Search across files for lines matching a regular expression

Search across files for lines matching a regular expression

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

## See also

[`grep_lines()`](https://public-environmental-data-partners.github.io/EJAM/reference/grep_lines.md)
[`grepn()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepn.md)
[`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
[`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)
[`found_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_files.md)
[`found_in_N_files_T_times()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_N_files_T_times.md)

## Examples

``` r
EJAM:::find_in_files("[^_]logo_....",    path = "./R", whole_line = FALSE)
EJAM:::find_in_files("report_logo.....", path = "./R", whole_line = FALSE)
EJAM:::find_in_files("app_logo......",   path = "./R", whole_line = FALSE)

EJAM:::find_in_files("latlon_from_.{18}",    whole_line = FALSE)
EJAM:::find_in_files("latlon_from_s.{9}",    whole_line = FALSE)
EJAM:::find_in_files("latlon_from_mact.{9}", whole_line = FALSE)

## useful reminders of how to filter lines of code vs comments when using find_in_files()

grepl_line_not_commented_out = "^[ ]*[^# ]+.*"  ## line starts with zero or more spaces followed by a non-space non-# character, so not commented out and not blank line, but may have a comment later in the line after code
grepl_line_commented_out     = "^[ |#]*#.*"     ## line starts with (zero or more spaces and then) a hash mark
grepl_line_may_have_comment  = "#.*"            ## line contains a hash mark somewhere, but that may be number sign within quoted text
 grepl(grepl_line_may_have_comment,  " print('The # of people is 4.')")  ## TRUE even though there is no comment here
 grepl(grepl_line_may_have_comment,  " # print('The number of people is 4.')") # a commented-out line
 grepl(grepl_line_may_have_comment,  "   print('The number of people is 4.')   # a comment only after the code")

EJAM:::find_in_files(paste0(grepl_line_not_commented_out, "xxx"))
EJAM:::find_in_files(paste0(grepl_line_commented_out,     "xxx"))
EJAM:::find_in_files(paste0(grepl_line_may_have_comment,  "xxx"))
```
