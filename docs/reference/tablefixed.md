# Table of counts of integer values zero through maxbin

Like tabulate or table, sort of, but includes zero unlike tabulate, and
lets you ensure results include every integer 0 through maxbin, so you
can, for example, easily combine tables of counts where some did not
include all integers.

## Usage

``` r
tablefixed(x, maxbin = NULL)
```

## Arguments

- x:

  vector of integers, like counts, that can include 0

- maxbin:

  highest integer among x, or number of bins

## Value

summary table

## Details

There is likely a more efficient way to do this in some existing
package, but this is useful and fast enough.

When using a dataset like EJSCREEN with 13 indicators of interest, and
counting how many of the 13 are above various cutpoints, there may be
zero rows that have exactly 8 above some cutoff, for example.

This function makes it easier to combine those tables into a summary
where 0-13 are in each table while table() would only return integers
that came up in a given case (for one cutoff).

## See also

colcounter_summary()
