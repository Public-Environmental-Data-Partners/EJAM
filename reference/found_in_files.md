# search for vector of query terms, to see which ones are found in any of the files

search for vector of query terms, to see which ones are found in any of
the files

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

data.frame

## Details

Uses EJAM:::find_in_files()

## Examples

``` r
  found_in_files(c("gray", "grey"), quiet=F, ignore.case=F)
```
