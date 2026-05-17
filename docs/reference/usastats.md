# usastats (DATA) data.frame of 100 percentiles and means

data.frame of 100 percentiles and means (about 100 rows) in the USA
overall, across all locations (e.g., blockgroups in
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md))
for a set of indicators such as percent low income. Each column is one
indicator (or specifies the percentile).

This should be similar to the lookup tables in the gdb on the FTP site
of EJSCREEN, except it also has data for additional population
subgroups.

For details on how the table was made, see source package files in
data-raw folder.

See also
[statestats](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md)

## Usage

``` r
usastats
```

## Format

An object of class `data.frame` with 102 rows and 107 columns.
