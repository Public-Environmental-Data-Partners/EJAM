# utility to check which elements of vector are numbers, even if stored as text like "01"

utility to check which elements of vector are numbers, even if stored as
text like "01"

## Usage

``` r
is.numerictext(x, na.is = c(NA, TRUE, FALSE)[1])
```

## Arguments

- x:

  character vector OR numeric vector

- na.is:

  optional, what to return for the NA values (NA, TRUE, or FALSE)

## Value

vector of TRUE / FALSE

## Details

Checks which elements of vector contain only digits or leading/trailing
spaces and have only zero or one period (decimal) and have only zero or
one minus sign, which must be the first nonspace character if it is
there.

Does not matter if stored as text character or numeric, so number can be
stored as text like "01" or " -1.32" ".3" or "3." even "." ? even "-" ?
NOT "- 2" and not "3-1" and not "2.0.6"

## See also

[`is.numericish()`](https://public-environmental-data-partners.github.io/EJAM/reference/is.numericish.md)
