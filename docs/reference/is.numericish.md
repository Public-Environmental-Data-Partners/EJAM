# see which columns seem numeric and could be rounded

see which columns seem numeric and could be rounded

## Usage

``` r
is.numericish(
  x,
  only.if.already.numeric = FALSE,
  strip.characters.before.coerce = FALSE
)
```

## Arguments

- x:

  data.table, data.frame, or vector

- only.if.already.numeric:

  logical, if TRUE, only reports TRUE for a column (or element) if
  is.numeric() is TRUE for that one

- strip.characters.before.coerce:

  logical, if TRUE, tries to remove spaces and percentage signs before
  trying to coerce to numeric

## Value

logical vector as long as NCOL(x) i.e., is length(x), if x is table, or
length(x) if vector, and returns NULL if x = NULL

## Details

Reports "08" as numeric-ish

## See also

[`is.numeric.text()`](https://public-environmental-data-partners.github.io/EJAM/reference/is.numeric.text.md)

[`table_round()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_round.md)
