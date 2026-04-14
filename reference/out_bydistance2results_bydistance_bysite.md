# A way to focus on 1 SITE at a time, for a few radius choices Get a list of tables, one per site. Each table has a row per distance.

A way to focus on 1 SITE at a time, for a few radius choices Get a list
of tables, one per site. Each table has a row per distance.

## Usage

``` r
out_bydistance2results_bydistance_bysite(out_bydistance)
```

## Arguments

- out_bydistance:

  list of tables that is output of
  [`ejamit_compare_distances_fulloutput()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)

## Value

a LIST you can call results_bydistance_bysite (not
results_bysite_bydistance), that is a list where each element is a table
for 1 site (ejam_uniq_id value) with one row per distance (radius or
buffer width). This table is in the same format as the output of
[`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)
or the internal function out_bydistance2results_bydistance()

## Details

This function might not be used at all. Extract/create
results_bydistance for each site, from list of ejamit() runs at multiple
distances

## See also

[`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)
[`ejamit_compare_distances_fulloutput()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)
and internal functions
[`out_bydistance2results_bysite_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bysite_bydistance.md)
[`out_bydistance2results_bydistance()`](https://public-environmental-data-partners.github.io/EJAM/reference/out_bydistance2results_bydistance.md)
