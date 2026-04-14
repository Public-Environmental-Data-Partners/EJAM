# utility to calculate annually for EJSCREEN the updated ACS data available at only tract resolution (% disability & language detail)

utility to calculate annually for EJSCREEN the updated ACS data
available at only tract resolution (% disability & language detail)

## Usage

``` r
calc_blockgroupstats_from_tract_data(
  yr,
  tables = c("B18101", "C16001"),
  formulas,
  dropMOE = TRUE
)
```

## Arguments

- yr:

  endyear of ACS 5-year survey to use, inferred if omitted

- tables:

  "B18101" and "C16001", e.g., for disability and detailed language
  spoken

## Value

data.table, one row per blockgroup (not tract)

## Details

Needs Census API key for
[`tidycensus::get_decennial()`](https://walker-data.com/tidycensus/reference/get_decennial.html).

Takes some time to download data for every State.

First get tract counts, then apportion into blockgroup counts, then
calculate percents in blockgroups via formulas.
