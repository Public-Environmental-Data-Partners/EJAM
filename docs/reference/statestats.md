# statestats (DATA) data.frame of 100 percentiles and means for each US State and PR and DC.

data.frame of 100 percentiles and means for each US State and PR and DC
for all the blockgroups in that zone (e.g., blockgroups in
[blockgroupstats](https://ejanalysis.github.io/EJAM/reference/blockgroupstats.md))
for a set of indicators such as percent low income. Each column is one
indicator (or specifies the percentile).

This should be similar to the lookup tables in the gdb on the FTP site
of EJSCREEN, except it also has data for additional population
subgroups. See also
[usastats](https://ejanalysis.github.io/EJAM/reference/usastats.md) for
more details.

## Usage

``` r
statestats
```

## Format

An object of class `data.frame` with 5304 rows and 67 columns.
