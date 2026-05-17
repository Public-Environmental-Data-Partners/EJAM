# utility - Helper for find_in_files()

Internal helper used by
[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
to search text that is already in memory, such as the output of
[`readLines()`](https://rdrr.io/r/base/readLines.html).

## Usage

``` r
grep_lines(
  pattern,
  x,
  ignore.case = TRUE,
  ignorecomments = FALSE,
  value = TRUE
)
```

## Arguments

- pattern:

  regular expression to look for

- x:

  character vector to search, typically one element per line

- ignore.case:

  logical passed to [`grepl()`](https://rdrr.io/r/base/grep.html)

- ignorecomments:

  if `TRUE`, lines beginning with `#` are excluded

- value:

  if `TRUE`, return matching lines; otherwise return a logical vector

## Value

Character vector of matching lines if `value = TRUE`, otherwise a
logical vector the same length as `x`. Returned values are named with
line numbers where applicable.

## Details

Search an in-memory character vector line by line

This is somewhat like grepv() but with these options: option to return
numbers of the elements or line numbers as names of the output vector
option to ignore commented-out lines of code (if searching with in lines
of code) option to return just the matching part of the element or line
instead of the whole line if desired.

use grepl to find all members of character vector z where the character
string "h" appears in the string but the string does not start with zero
or more spaces followed by the character "#"

## See also

[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
[`grepn()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepn.md)
[`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
[`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)

## Examples

``` r

EJAM:::grep_lines("x",  c("x", "y", "has any x x xxxxx"))

xx = c("   ej", "ej", "#ej", "   #ej", "asdf#ej", "   asdf#ej", "#   ej", "#   xej", "x#  ej", "  x#ej")

 cbind(xx, EJAM:::grep_lines("ej", xx, ignorecomments = TRUE,  value = FALSE))
 cbind(xx, EJAM:::grep_lines("ej", xx, ignorecomments = FALSE, value = FALSE))

 cbind(  EJAM:::grep_lines("ej", xx, ignorecomments = TRUE,    value = TRUE))
 cbind(  EJAM:::grep_lines("ej", xx, ignorecomments = FALSE,   value = TRUE))
```
