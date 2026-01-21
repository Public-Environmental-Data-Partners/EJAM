# Create a gt-format table of results from EJAM

Uses the list of results of ejamit()

## Usage

``` r
table_gt_from_ejamit(ejamitoutput = NULL, type = c("demog", "envt")[1])
```

## Arguments

- ejamitoutput:

  list of EJAM results formatted as in testoutput_ejamit_100pts_1miles,
  as would be the output of ejamit()

- type:

  Must be "demog" or "envt" – Creates one of these at a time

## Value

Provides table in gt format from the R package called gt

## Details

See the R package called gt. Also see code that creates html tables from
html template and code that creates formatted spreadsheets like
[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)
or related functions

## Examples

``` r
 table_gt_from_ejamit(testoutput_ejamit_100pts_1miles)
```
