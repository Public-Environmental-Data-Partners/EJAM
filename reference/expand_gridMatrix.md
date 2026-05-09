# utility similar to expand.grid, but returns a matrix not data.frame

This function is similar to
[`expand.grid`](https://rdrr.io/r/base/expand.grid.html), in the sense
that it returns a matrix that has 2 columns, one for each input, and one
row per combination, cycling through the first field first. It differs
from expand.grid in that this returns a matrix not data.frame, only
accepts two parameters creating two columns, for now, and lacks the
other parameters of expand.grid

## Usage

``` r
expand_gridMatrix(x, y)
```

## Arguments

- x:

  required vector

- y:

  required vector

## Value

This function returns a matrix and tries to assign colnames based on the
two input parameters. If they are variables, it uses those names as
colnames. Otherwise it uses "x" and "y" as colnames.

## See also

[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)

## Examples

``` r
 EJAM:::expand_gridMatrix(99:103, 1:2)
 zz <- 1:10; top <- 1:2
 EJAM:::expand_gridMatrix(zz, top)
 
```
