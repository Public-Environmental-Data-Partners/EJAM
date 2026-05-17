# Count regex matches within each element of a character vector

Count regex matches within each element of a character vector

## Usage

``` r
grepn(pattern, x, ignore.case = TRUE)
```

## Arguments

- pattern:

  pattern to search for, passed to
  [`gregexec()`](https://rdrr.io/r/base/grep.html)

- x:

  a vector of character strings to search within

- ignore.case:

  passed to [`gregexec()`](https://rdrr.io/r/base/grep.html)

## Value

vector of numbers, same length as x

## Details

- `grepn()` counts matches for one pattern across a character vector.

- [`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
  handles multiple patterns and can return either a matrix of counts per
  string or a vector summarizing hits per pattern.

- [`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)
  handles multiple patterns and returns logical presence/absence results
  rather than counts.

## See also

[`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
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
