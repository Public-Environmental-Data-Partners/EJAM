# A way to focus on 1 DISTANCE (RADIUS) at a time (after a multi-distance run), for the list of sites Get a list of tables, one per distance. Each table has a row per site.

A way to focus on 1 DISTANCE (RADIUS) at a time (after a multi-distance
run), for the list of sites Get a list of tables, one per distance. Each
table has a row per site.

## Usage

``` r
out_bydistance2results_bysite_bydistance(out_bydistance)
```

## Arguments

- out_bydistance:

  list of tables that is output of
  [`ejamit_compare_distances_fulloutput()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)

## Value

a LIST you can call results_bysite_bydistance (not
results_bydistance_bysite), that is a list where each element is
ejamit()\$results_bysite for a unique distance (radius or buffer width)

## Details

This function might not be used at all. Extract results_bysite for each
distance from list of ejamit() runs at multiple distances

## See also

[`ejamit_compare_distances()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances.md)
[`ejamit_compare_distances_fulloutput()`](https://ejanalysis.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)
and internal functions
[`out_bydistance2results_bydistance()`](https://ejanalysis.github.io/EJAM/reference/out_bydistance2results_bydistance.md)
[`out_bydistance2results_bydistance_bysite()`](https://ejanalysis.github.io/EJAM/reference/out_bydistance2results_bydistance_bysite.md)
