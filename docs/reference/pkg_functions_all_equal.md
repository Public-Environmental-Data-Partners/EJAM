# UTILITY - check different versions of function with same name in 2 packages obsolete since old EPA ejscreen api functions were phased out - was used by pkg_dupenames() to check different versions of function with same name in 2 packages

UTILITY - check different versions of function with same name in 2
packages obsolete since old EPA ejscreen api functions were phased out -
was used by pkg_dupenames() to check different versions of function with
same name in 2 packages

## Usage

``` r
pkg_functions_all_equal(fun = "latlon_infer", package1 = "EJAM", package2)
```

## Arguments

- fun:

  quoted name of function, like "latlon_infer"

- package1:

  quoted name of package, like "EJAM"

- package2:

  quoted name of other package

## Value

TRUE or FALSE

## See also

[`pkg_dupenames()`](https://ejanalysis.github.io/EJAM/reference/pkg_dupenames.md)
[`all.equal.function()`](https://rdrr.io/r/base/all.equal.html)
