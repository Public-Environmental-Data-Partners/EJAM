# utility to check formulas and extract variable names they calculate values for

utility to check formulas and extract variable names they calculate
values for

## Usage

``` r
formula_varname(myforms)
```

## Arguments

- myforms:

  see
  [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)

## Value

a vector as long as myforms input vector

## Details

- [`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)
  may use
  [`calc_ejam()`](https://ejanalysis.github.io/EJAM/reference/calc_ejam.md)

- [`calc_ejam()`](https://ejanalysis.github.io/EJAM/reference/calc_ejam.md)
  uses
  [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)

- [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)
  uses `formula_varname()` and maybe source_this_codetext()

## Examples

``` r
EJAM:::formula_varname(c("z=10", "b<- 1", "c <- 34", " h = 1+1", "   q=2+2"))
head(cbind(EJAM:::formula_varname(formulas_d), formulas_d))
```
