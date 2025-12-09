# Extract summary from list of ejamit() runs at multiple distances Get a table, one row per distance. Overall summary, not each site.

Extract summary from list of ejamit() runs at multiple distances Get a
table, one row per distance. Overall summary, not each site.

## Usage

``` r
out_bydistance2results_bydistance(out_bydistance)
```

## Arguments

- out_bydistance:

  list of tables that is output of
  [`ejamit_compare_distances_fulloutput()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)

## Value

a table you can call results_bydistance, that is like
ejamit()\$results_overall, but that has 1 row per distance (radius or
buffer width)

## Details

This will compile a results_bydistance table from output of
ejamit_compare_distances_fulloutput(), using the
ejamit()\$results_overall for each distance.

## See also

[`ejamit_compare_distances()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances.md)
[`ejamit_compare_distances_fulloutput()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)
