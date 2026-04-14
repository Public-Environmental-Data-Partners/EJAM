# How many decimal places to round to for given variable(s)

How many decimal places to round to for given variable(s)

## Usage

``` r
table_rounding_info(var, varnametype = "rname")
```

## Arguments

- var:

  vector of variable names such as c("pctlowinc", "pm") or c(names_d,
  names_d_subgroups)

- varnametype:

  which column of
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  to use when looking for var, like "rname" or "api" or "long"

## Value

named vector same size as var, with var as names.

## See also

[`table_signif_round_x100()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_signif_round_x100.md)
[`table_signif()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_signif.md)
[`table_round()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_round.md)
[`table_x100()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_x100.md)

## Examples

``` r
  EJAM:::table_rounding_info("pm")
  EJAM:::table_round(8.252345, "pm")
  EJAM:::table_round(8, "pm")

  cbind(EJAM:::table_rounding_info(names_all_r), fixcolnames(names_all_r, "r", "long"))
```
