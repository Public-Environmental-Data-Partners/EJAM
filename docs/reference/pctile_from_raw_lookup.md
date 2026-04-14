# Find approx percentiles in lookup table for just 1 indicator or 1 zone (State or US)

This is used with a lookup table to convert a raw indicator vector to
percentiles in US or States.

## Usage

``` r
pctile_from_raw_lookup(
  myvector,
  varname.in.lookup.table,
  lookup = usastats,
  zone = "USA",
  quiet = TRUE
)

lookup_pctile(
  myvector,
  varname.in.lookup.table,
  lookup = usastats,
  zone = "USA"
)
```

## Arguments

- myvector:

  Numeric vector, required. Values to look for in the lookup table.

- varname.in.lookup.table:

  Character element, required. Name of column in lookup table to look in
  to find interval where a given element of myvector values is.

  \*\*\* If vector is provided, then must be same length as myvector,

  but only 1 value for zone can be provided.

- lookup:

  Either lookup must be provided, not quoted, or a lookup table called
  [usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
  must already be in memory. This is the lookup table data.frame with a
  PCTILE column, REGION column, and column whose name is the value of
  varname.in.lookup.table To use state lookups set lookup=statestats

- zone:

  Character element (or vector as long as myvector), optional. If
  specified, must appear in a column called REGION within the lookup
  table, or NA returned for each item looked up and warning given. For
  example, it could be "NY" for New York State, "USA" for national
  percentiles.

- quiet:

  set to FALSE to see details on where certain scores were all NA values
  like in 1 state

## Value

By default, returns numeric vector length of myvector.

## Details

For handling a whole table of raw indicators, see
[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)

This function can handle 2 kinds of inputs right now:

- a vector of scores and vector of corresponding indicator names, in
  only 1 zone (e.g. 1 State)

- a vector of scores and vector of corresponding zones (States), for
  only 1 indicator (e.g., pctlowinc)

This could be recoded to be more efficient - could use
[data.table](https://r-datatable.com) package.

The data.frame lookup table must have a field called "PCTILE" that has
quantiles/percentiles and other column(s) with values that fall at those
percentiles.
[usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
and
[statestats](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md)
are such lookup tables. This function uses a lookup table and finds the
number in the PCTILE column that corresponds to where a specified value
(in myvector) appears in the column called varname.in.lookup.table. The
function just looks for where the specified value fits between values in
the lookup table and returns the approximate percentile as found in the
PCTILE column. If the value is between the cutpoints listed as
percentiles 89 and 90, it returns 89, for example. If the value is
exactly equal to the cutpoint listed as percentile 90, it returns
percentile 90. If the value is exactly the same as the minimum in the
lookup table and multiple percentiles in that lookup are listed as tied
for having the same threshold value defining the percentile (i.e., a
large percent of places have the same score and it is the minimum
score), then the percentile gets reported as 0, not the percent of
places tied for that minimum score. Note this is true whether they are
tied at a value of 0 or are tied at some other minimum value than 0. If
the value is less than the cutpoint listed as percentile 0, which should
be the minimum value in the dataset, it still returns 0 as the
percentile, but with a warning that the value checked was less than the
minimum in the dataset.

It also handles other odd cases, like where a large percent of all raw
scores are tied at the minimum value, in which case it reports 0 as
percentile, not that large percent.

## See also

[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)
for handling a table not just a vector

## Examples

``` r
# \donttest{

eg <- dput(
        round(as.vector(
          unlist(testoutput_ejamit_10pts_1miles$results_overall[ , ..names_d] )),
          3)
      )

data.frame(value = eg,
           pctile = t(testoutput_ejamit_10pts_1miles$results_overall[ , ..names_d_pctile]))

data.frame(value = eg, pctile = lookup_pctile(eg, names_d))

# }
```
