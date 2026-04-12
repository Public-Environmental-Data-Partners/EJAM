# Calculate ratios to US and State average for each indicator in each place

Calculate ratios to US and State average for each indicator in each
place

## Usage

``` r
calc_ratio_columns(
  mytable,
  varnames = names_these,
  varnames_avg = paste0("avg.", varnames),
  varnames_state_avg = paste0("state.avg.", varnames),
  varnames_ratio_to_avg = paste0("ratio.to.", varnames_avg),
  varnames_ratio_to_state_avg = paste0("ratio.to.", varnames_state_avg),
  varnames_state_special = c("Demog.Index.State", "Demog.Index.Supp.State")
)
```

## Arguments

- mytable:

  table in [data.table](https://r-datatable.com) format with 1 row per
  place, 1 column per raw data indicator values

- varnames:

  column names of mytable that contain the raw indicator values
  (numerators of ratios)

- varnames_avg:

  column names of mytable that contain the US averages (denominators of
  ratios to US avg)

- varnames_state_avg:

  column names of mytable that contain the State averages (denominators
  of ratios to State avg)

- varnames_ratio_to_avg:

  optional names to use for the calculated ratios to US avg

- varnames_ratio_to_state_avg:

  optional names to use for the calculated ratios to State avg

- varnames_state_special:

  handles special case of ratio to state avg for Demog.Index and
  Demog.Index.Supp needing special numerator that is state-specific
  version of the index

## Value

data.frame with 1 row per row of mytable and set of columns for US
ratios and set of columns for State ratios

## Details

For examples, see
[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)

Note how averages (or percentiles) are defined in EJSCREEN data –
technically it has been defined as average blockgroup (or percentile
across blockgroups) in US or State, not average resident in US or State,
but those are in most cases almost the same. Average resident and
average blockgroup can be very different for a single analyzed site,
however, or for the overall aggregate of several analyzed sites, and in
those situations EJSCREEN calculates the average local resident's
blockgroup score, not the average blockgroup score. In reporting ratios,
those local average resident's values are still compared to the US or
State "average" that is the average blockgroup in the US or State, so
technically they are not exactly comparable, but in practice the ratio
would be almost the same if compared to a population weighted average of
all US blockgroups (i.e., the average US resident).

## See also

[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
[`calc_avg_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_avg_columns.md)
[`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)
