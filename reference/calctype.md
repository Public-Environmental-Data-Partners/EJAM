# utility - what type of formula is used to aggregate this variable?

utility - what type of formula is used to aggregate this variable?

## Usage

``` r
calctype(varnames)
```

## Arguments

- varnames:

  vector like names_d

## Value

vector same length as varnames, like c("sum of counts", "wtdmean")

## Examples

``` r
 calctype("pop")
 calctype(names_d)

 x = names_these
 cbind(indicator = x, calctype = calctype(x), calcweight = calcweight(x))

 x = names(testoutput_ejamit_10pts_1miles$results_overall)
 cbind(indicator = x, calctype = calctype(x), calcweight = calcweight(x))
```
