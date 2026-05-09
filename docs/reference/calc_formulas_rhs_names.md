# Parse right-hand-side variable names from an R formula string (or vector of formulas)

Parse right-hand-side variable names from an R formula string (or vector
of formulas)

## Usage

``` r
calc_formulas_rhs_names(formula)
```

## Arguments

- formula:

  character string with an R assignment formula, or a vector of such
  formulas, like c("c = a + b", "b = a \* 3", "a = 2") or
  formulas_ejscreen_acs\$formula

## Value

- Character vector of unique variable names used on the right side, if
  formula is singular.

- A list of such vectors if a vector of formulas is provided as input!
