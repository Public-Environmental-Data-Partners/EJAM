# Count matches for multiple patterns across a character vector

Count matches for multiple patterns across a character vector

## Usage

``` r
grepns(patterns, x, ignore.case = TRUE, rowperx = FALSE, count1perx = TRUE)
```

## Arguments

- patterns:

  vector of 1+ patterns to search for, passed one at a time to
  [`gregexec()`](https://rdrr.io/r/base/grep.html)

- x:

  a vector of character strings to search within

- ignore.case:

  passed to [`gregexec()`](https://rdrr.io/r/base/grep.html)

- rowperx:

  whether to return a matrix with one row per element of `x` and one
  column per pattern, or instead return a vector with one element per
  pattern summarizing across all of `x`

- count1perx:

  whether to count only 1 match per pattern per element of x, or to
  count all matches (i.e., if there are 3 matches for a pattern in one
  element of x, count as 1 or 3)

## Value

If `rowperx = TRUE`, a matrix with one row per element of `x` and one
column per pattern. If `rowperx = FALSE`, a vector with one element per
pattern summarizing across all of `x`.

## See also

`grepns()`
[`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)
[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
[`found_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_files.md)
[`found_in_N_files_T_times()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_N_files_T_times.md)
[`grep_lines()`](https://public-environmental-data-partners.github.io/EJAM/reference/grep_lines.md)

## Examples

``` r
 grepn("x", c("0 abc", "1 uppercase X", "1 xyz", "2 xx", "3 x x x"))
 grepn("x", c("0 abc", "1 uppercase X", "1 xyz", "2 xx", "3 x x x"), ignore.case = FALSE)

 grepns(c("x", "y"), c("yes", "yx", "this 1 has some x x xxxxx"))
 grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
         rowperx = TRUE, count1perx = TRUE)
 grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
         rowperx = FALSE, count1perx = TRUE)
 grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
         rowperx = TRUE, count1perx = FALSE)
 grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
         rowperx = FALSE, count1perx = FALSE)

 grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
   rowperx = TRUE)
 grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
   rowperx = FALSE)
```
