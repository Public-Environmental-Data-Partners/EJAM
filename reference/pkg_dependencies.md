# utility for developing package, see what pkgs it depends on, recursively (i.e., downstream ones too) Reminder of ways to check this is printed to console.

utility for developing package, see what pkgs it depends on, recursively
(i.e., downstream ones too) Reminder of ways to check this is printed to
console.

## Usage

``` r
pkg_dependencies(
  localpkg = "EJAM",
  depth = 6,
  ignores_grep = "0912873410239478"
)
```

## Arguments

- localpkg:

  "EJAM" or another installed package

- depth:

  would be used if using the deepdep package and function

- ignores_grep:

  would be used if using the deepdep package and function
