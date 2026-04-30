# Check whether raw scores meet a percentile cutoff (e.g., to see which blockgroups are at high percentiles)

Compares one or more raw indicator values to the raw-score threshold
that corresponds to a specified percentile cutoff in
[usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
or
[statestats](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md).

## Usage

``` r
pctile_x_is_hit_by_score(
  raw_score_name,
  cutoff = 0.9,
  score = NULL,
  ST = FALSE
)
```

## Arguments

- raw_score_name:

  Character scalar. Name of the raw indicator column to evaluate, such
  as `"pctlowinc"` or `"o3"`. It must exist in
  [usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
  and
  [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md).

- cutoff:

  Numeric scalar from 0 to 1. Percentile cutoff expressed as a fraction,
  for example `0.90` for the 90th percentile.

- score:

  Optional numeric vector of raw values to compare to the cutoff. If
  omitted or `NULL`, the function uses the column named by
  `raw_score_name` from
  [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md).

- ST:

  Either `FALSE`/`NULL` for nationwide percentiles, `TRUE` to use
  `blockgroupstats$ST`, or a character vector of state abbreviations the
  same length as `score` for state-specific comparisons.

## Value

Logical vector the same length as `score`, indicating if each raw score
is at or above the requested percentile cutoff.

## Details

To save space, blockgroupstats does not store the US and State
percentiles of all US blockgroups for all indicators – it just has the
raw scores. Therefore one cannot easily check which blockgroups have raw
scores that are at or above a given percentile cutoff, without first
converting the raw scores to percentiles with
[`lookup_pctile()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
and then checking which percentiles are at or above the cutoff. This
function does that in a more efficient way by just looking up the raw
score that corresponds to the cutoff percentile in usastats or
statestats, and then comparing all the raw scores to that cutoff raw
score. It is a fast alternative to converting every raw score to a
percentile with
[`lookup_pctile()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
and then checking whether that percentile is at or above the requested
cutoff.

If `score` is omitted, values are taken from
`blockgroupstats[[raw_score_name]]`. If `ST = TRUE`, the function also
takes states from `blockgroupstats$ST` and ignores any user-supplied
`score`.

## See also

[`lookup_pctile()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
[`pctile_from_raw_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)

## Examples

``` r
# \donttest{

  # Which blockgroups have a raw score at/above a specified raw score cutoff?

   # Which ones have % unemployed of at least 99%?
   blockgroupstats[  pctunemployed >= 0.99, 1:12]

 # What % of blockgroups have a raw score at/above a specified raw score cutoff?

   # What % of places have % unemployed of at least 50%?
   round(table(
     pct.with.at.least.50pct.unemployed =
     blockgroupstats$pctunemployed >= 0.50) /
     nrow(blockgroupstats)*100, 2)


  # Which blockgroups have a raw score at/above a specified percentile?

    these <- pctile_x_is_hit_by_score("pctunemployed", cutoff = 0.95)
    blockgroupstats[these, 1:12]

  # What % of blockgroups have a raw score at/above a specified percentile?

    these <- pctile_x_is_hit_by_score("pctunemployed", cutoff = 0.95)
    round(table(percent.that.are.high = these)/NROW(these) * 100, 2)
    # About 5% of US blockgroups are at/above 95th percentile as expected


pctile_x_is_hit_by_score("pctlowinc", cutoff = 0.80, score = c(0.1, 0.33, 0.50))

testrows <- c(14840L, 96520L, 105100L)
pctile_x_is_hit_by_score(
  "pctlowinc",
  cutoff = 0.80,
  score = EJAM::blockgroupstats$pctlowinc[testrows],
  ST = EJAM::blockgroupstats$ST[testrows]
)
blockgroupstats[testrows, .(bgfips, ST, pop, pctlowinc)]

# }
```
