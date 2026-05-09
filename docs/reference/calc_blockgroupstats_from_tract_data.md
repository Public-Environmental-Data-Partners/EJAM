# utility to calculate annually for EJSCREEN the updated ACS data available at only tract resolution (% disability & language detail)

utility to calculate annually for EJSCREEN the updated ACS data
available at only tract resolution (% disability & language detail)

## Usage

``` r
calc_blockgroupstats_from_tract_data(
  yr,
  tables = c("B18101", "C16001"),
  formulas = NULL,
  dropMOE = TRUE,
  acs_raw = NULL
)
```

## Arguments

- yr:

  endyear of ACS 5-year survey to use, inferred if omitted

- tables:

  "B18101" and "C16001", e.g., for disability and detailed language
  spoken

- formulas:

  default includes formulas for disability-related and language-related
  indicators calculated from ACS variables found in tables "B18101" and
  "C16001" - This is a vector of string formulas.

- dropMOE:

  logical, whether to drop not retain the margin of error information
  for each ACS variable

- acs_raw:

  optional raw ACS table list or `bg_acs_raw` pipeline object previously
  created by
  [`download_bg_acs_raw()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_bg_acs_raw.md).
  If supplied, no ACS download is performed for tract-resolution tables.

## Value

data.table, one row per blockgroup (not tract)

## Details

This is now typically orchestrated by
[`calc_ejscreen_dataset()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset.md)
and by the staged pipeline runner script
`data-raw/run_ejscreen_acs2024_pipeline.R`.

Relies on the function get_acs_new() which is available from the package
ACSdownload (on github) as ACSdownload::get_acs_new()

Needs Census API key for
[`tidycensus::get_decennial()`](https://walker-data.com/tidycensus/reference/get_decennial.html).

Takes some time to download data for every State!

First get tract counts, then apportion into blockgroup counts, then
calculate percents in blockgroups via formulas.
