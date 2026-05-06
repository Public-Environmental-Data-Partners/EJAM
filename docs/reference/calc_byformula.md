# DRAFT utility to use formulas provided as text, to calculate indicators

DRAFT utility to use formulas provided as text, to calculate indicators

## Usage

``` r
calc_byformula(
  mydf,
  formulas = NULL,
  keep = calc_varname_from_formula(formulas),
  quiet = FALSE
)
```

## Arguments

- mydf:

  data.frame of indicators or variables to use

- formulas:

  text strings of formulas - WARNING: this should not really be used on
  user-provided, untrusted formula strings, since the contents could
  potentially be a security risk

- keep:

  useful if some of the formulas are just interim steps creating
  evanescent variables created only for use in later formulas and not
  needed after that

- quiet:

  if FALSE, prints to console the success/failure of each formula

## Value

data.frame of results, but if mydf was a data.table, returns a table in
[data.table](https://r-datatable.com) format

## Details

- [`custom_doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/custom_doaggregate.md)
  may use
  [`calc_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejam.md)

- [`calc_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejam.md)
  uses `calc_byformula()`

- `calc_byformula()` uses
  [`calc_varname_from_formula()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_varname_from_formula.md)
  and maybe source_this_codetext()
