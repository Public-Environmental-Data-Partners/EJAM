# Count how often each search term appears across files

For each term in `pattern_vector`, runs
[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
and reports both how many files contain the term and how many matching
lines were found overall.

## Usage

``` r
found_in_N_files_T_times(
  pattern_vector,
  path = "./R",
  ignorecomments = TRUE,
  ...
)
```

## Arguments

- pattern_vector:

  character vector of search terms

- path:

  optional path like "./R"

- ignorecomments:

  if `TRUE`, ignore matches in lines that are just comments rather than
  active source code

- ...:

  passed to
  [`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
  such as `ignore.case` or `filename_pattern`

## Value

Data frame with columns `term`, `nfiles`, and `nhits`.

## See also

[`find_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/find_in_files.md)
[`found_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_files.md)
[`grepn()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepn.md)
[`grepns()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepns.md)
[`grepls()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepls.md)
[`grep_lines()`](https://public-environmental-data-partners.github.io/EJAM/reference/grep_lines.md)

## Examples

``` r
EJAM:::found_in_N_files_T_times(c("gray", "grey"), path = "./R", quiet = TRUE)
```
