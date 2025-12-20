# utility - what variable is the weight used to aggregate this variable as a weighted mean?

utility - what variable is the weight used to aggregate this variable as
a weighted mean?

## Usage

``` r
calcweight(varnames)
```

## Arguments

- varnames:

  vector like names_d

## Value

vector same length as varnames, like c("pop", "povknownratio", "hhlds")

## Examples

``` r
 x = names_these
 cbind(indicator = x, calctype = calctype(x), calcweight = calcweight(x))
```
