# utility - quick way to do dir() but for query pattern like \*.xlsx useful if you forget [`glob2rx()`](https://rdrr.io/r/utils/glob2rx.html) is available

utility - quick way to do dir() but for query pattern like \*.xlsx
useful if you forget [`glob2rx()`](https://rdrr.io/r/utils/glob2rx.html)
is available

## Usage

``` r
dir2(
  query_glob = "*.*",
  ignore.case = TRUE,
  recursive = FALSE,
  silent = FALSE,
  ...
)
```

## Arguments

- query_glob:

  optional, something like "*.r*" or "*.xlsx" or "myfile.*" or "a\*.\*",
  so it is like `dir(pattern = glob2rx(query_glob))`

- ignore.case:

  passed to [`dir()`](https://rdrr.io/r/base/list.files.html)

- recursive:

  passed to [`dir()`](https://rdrr.io/r/base/list.files.html), often
  useful to set TRUE

- silent:

  whether to avoid printing to console

- ...:

  passed to [`dir()`](https://rdrr.io/r/base/list.files.html)

## Value

vector of paths

## Examples

``` r
 #  EJAM:::dir2()
 if (FALSE) { # \dontrun{
EJAM:::dir2()
EJAM:::dir2("*.zip", recursive = TRUE)
EJAM:::dir2("*.y*",  recursive = TRUE)

# if recursive=TRUE, left-aligned view of paths is shown
EJAM:::dir2("*datacreate*.*", recursive = TRUE)
# for right-aligned view:
data.frame(hit= EJAM:::dir2("*address*.*", recursive = TRUE))

EJAM:::dir2("*.csv*", path = testdatafolder(installed = FALSE), recursive = TRUE)
} # }
```
