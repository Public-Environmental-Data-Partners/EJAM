# aggregate blockwt values by blockgroup

aggregate blockwt values by blockgroup

## Usage

``` r
calc_bgwts_overall(sites2blocks)
```

## Arguments

- sites2blocks:

  like output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  or input to
  [`doaggregate()`](https://ejanalysis.github.io/EJAM/reference/doaggregate.md)
  or
  [`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)

## Value

[data.table](https://r-datatable.com), 1 row per blockgroup (even if bg
is near 2+ sites), so it is a table of all the unique blockgroups in the
overall analysis (merged across all sites), with a weight that indicates
what fraction of that bg population is included in the overall analysis.
This can be used to get overall results if it is joined to blockgroup
residential population data, etc., to aggregate each indicator over all
blockgroups using the weights.

## See also

[`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)
