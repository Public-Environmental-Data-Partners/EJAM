# Convert raw indicator values to percentiles, for a table of indicators and places

Convert raw indicator values to percentiles, for a table of indicators
and places

## Usage

``` r
calc_pctile_columns(
  mytable,
  varnames = intersect(names(mytable), names(EJAM::usastats)),
  varnames_pctile = paste0("pctile.", varnames),
  varnames_state_pctile = paste0("state.pctile.", varnames),
  zones = "USA",
  lookup = NULL,
  quiet = TRUE
)
```

## Arguments

- mytable:

  data.frame with one indicator per column, one row per place

- varnames:

  optional vector of indicators with raw scores to convert to
  percentiles, such as names_these or "pm" - must be among colnames of
  mytable and lookup (typically usastats or statestats)

- varnames_pctile:

  optional vector as long as varnames, what to name the output columns
  of US percentiles

- varnames_state_pctile:

  optional vector as long as varnames, what to name the output columns
  of State percentiles

- zones:

  optional vector of 2-character state abbreviations, or else just
  "USA", but not a mixture of both at once

- lookup:

  optional, in case custom indicators are used

- quiet:

  passed to
  [`pctile_from_raw_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)

## Value

data.frame of percentiles for a table of indicators and places one
indicator per column, one place per row

## Details

Note each percentile is not "calculated" per se, but is actually looked
up in a table of percentiles and raw cutoffs

## See also

[`pctile_from_raw_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
[`calc_avg_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_avg_columns.md)

## Examples

``` r
# examples of getting pctiles, averages, and ratios to averages
# via functions that do parts of what is done in doaggregate()

#############################
#  using ejamit() which uses doaggregate()

testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
testfips = blockgroupstats$bgfips[ testrows ]
out = ejamit(fips = testfips)
x = out$results_bysite
# look at the averages, ratios, and percentiles
names_these_pctile       = paste0("pctile.",      names_these)
names_these_state_pctile = paste0("state.pctile.", names_these)
avgs0    = x[ , c(..names_these_avg,          ..names_these_state_avg)]
ratios0  = x[ , c(..names_these_ratio_to_avg, ..names_these_ratio_to_state_avg)]
pctiles0 = x[ , c(..names_these_pctile,       ..names_these_state_pctile)]
# outputs are tables in [data.table](https://r-datatable.com) format, 1 row per site, 1 col per indicator
names(avgs0); dim(avgs0)
names(ratios0); dim(ratios0)
names(pctiles0); dim(pctiles0)

#############################
##  using just parts of what doaggregate() does

testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
## if missing names_d_demogindexstate, cannot do correct ratios  ***
testvars = c("ST", names_these, names_d_demogindexstate)
testbgs = blockgroupstats[testrows, ..testvars]

#   ----------------- AVERAGES -----------------

avgs <- cbind(
  EJAM:::calc_avg_columns(varnames = names_these, zones = "USA"),
  EJAM:::calc_avg_columns(varnames = names_these, zones = testbgs$ST)
)
data.table::setDT(avgs)
t(avgs)
all.equal(avgs, avgs0)
testbgs <- cbind(testbgs, avgs) # need these averages to calculate the ratios

#   ----------------- RATIOS TO AVERAGES -----------------

ratios <- EJAM:::calc_ratio_columns(testbgs)  # needs raw and avg cols be in 1 dt
data.table::setDT(ratios)
t(ratios)
all.equal(ratios, ratios0)

#   ----------------- PERCENTILES -----------------

pctiles <- cbind(
  EJAM:::calc_pctile_columns(testbgs, varnames = names_these, zones = "USA"),
  EJAM:::calc_pctile_columns(testbgs, varnames = names_these, zones = testbgs$ST)
)
data.table::setDT(pctiles)
all.equal(pctiles, pctiles0)
t(pctiles)

############################# ############################## #
```
