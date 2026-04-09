# aggregate blockwt values by blockgroup, by site they are in or near

aggregate blockwt values by blockgroup, by site they are in or near

## Usage

``` r
calc_bgwts_bysite(sites2blocks)
```

## Arguments

- sites2blocks:

  like output of
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  or input to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  or
  [`custom_doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/custom_doaggregate.md)

## Value

[data.table](https://r-datatable.com), 1 row per site-bg pair. May have
same bgid or bgfips in 2,3, more rows since it is here once per site
that the bg is near. It is like a sites2blockgroups table.

## See also

[`custom_doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/custom_doaggregate.md)
