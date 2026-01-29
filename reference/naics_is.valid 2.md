# validate industry NAICS codes

validate industry NAICS codes

## Usage

``` r
naics_is.valid(code)
```

## Arguments

- code:

  vector of one or more numeric or character codes like c(22, 111, 4239,
  423860)

## Value

logical vector, TRUE means valid

## Examples

``` r
  EJAM:::naics_is.valid(c(22, "022", " 22", 111, "4239", 423860))
  # table(EJAM:::naics_is.valid(frs_by_naics$NAICS)) / NROW(frs_by_naics)
```
