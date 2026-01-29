# utility to get USPS addresses from a table that has correct colnames

utility to get USPS addresses from a table that has correct colnames

## Usage

``` r
address_from_table_goodnames(
  x,
  colnames_allowed = c("address", "street", "city", "state", "zip")
)
```

## Arguments

- x:

  a table with columns that overlap with colnames_allowed

- colnames_allowed:

  optional

## Value

vector of USPS addresses

## See also

[`address_from_table()`](https://ejanalysis.github.io/EJAM/reference/address_from_table.md)
