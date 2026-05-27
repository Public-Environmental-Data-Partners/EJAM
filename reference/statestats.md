# statestats (DATA) data.frame of 100 percentiles and means for each US State and PR and DC.

data.frame of 100 percentiles and means for each US State and PR and DC
for all the blockgroups in that zone (e.g., blockgroups in
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md))
for a set of indicators such as percent low income. Each column is one
indicator (or specifies the percentile).

Because every row in `statestats` is a state-specific lookup row, most
columns use the usual indicator names even when the values are used for
state percentiles. The demographic index columns are a special
compatibility case: `Demog.Index` and `Demog.Index.Supp` contain
state-specific cutoffs calculated from `Demog.Index.State` and
`Demog.Index.Supp.State`, respectively, so code that uses `names_d` or
older EJSCREEN-style lookup names gets the correct state lookup values.
The explicit `Demog.Index.State` and `Demog.Index.Supp.State` columns are
also included and contain those same state-specific cutoff values for code
that uses the clearer state-specific names.

For details on how the table was made, see source package files in
data-raw folder.

See also
[usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
for more details.

## Usage

``` r
statestats
```

## Format

An object of class `data.frame` with 5304 rows and 114 columns.
