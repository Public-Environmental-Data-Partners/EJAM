# Check which search terms are found in any file

Check which search terms are found in any file

## Usage

``` r
found_in_files(pattern_vector, path = "./R", ignorecomments = TRUE, ...)
```

## Arguments

- pattern_vector:

  in a loop, each element is passed to
  [`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)

- path:

  optional path like "./R"

- ignorecomments:

  if TRUE, ignore matches in lines that are just comments not actual
  source code and note TRUE IS NOT DEFAULT IN find_in_files() but is
  here

- ...:

  passed to
  [`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
  can be ignore.case, filename_pattern, etc.

## Value

Logical vector, one element per search term in `pattern_vector`.

## Details

Uses
[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
once for each element of `pattern_vector`.

## See also

[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
[`found_in_N_files_T_times()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_N_files_T_times.md)
[`grepn()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepn.md)
[`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
[`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)
[`grep_lines()`](https://public-environmental-data-partners.github.io/EJAM/reference/grep_lines.md)

## Examples

``` r
  EJAM:::found_in_files(c("gray", "grey"), quiet = FALSE, ignore.case = FALSE)
```
