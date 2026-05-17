# utility to calculate annually for EJSCREEN the updated ACS data available at only tract resolution (% disability & language detail)

utility to calculate annually for EJSCREEN the updated ACS data
available at only tract resolution (% disability & language detail)

## Usage

``` r
calc_blockgroupstats_from_tract_data(
  yr,
  tables = c("B18101", "C16001", "B27010"),
  formulas = NULL,
  dropMOE = TRUE,
  acs_raw = NULL,
  tract_weight_source = c("decennial2020", "acs")
)
```

## Arguments

- yr:

  endyear of ACS 5-year survey to use, inferred if omitted

- tables:

  ACS tract tables used for tract-derived indicators, typically
  `"B18101"`, `"C16001"`, and `"B27010"` for disability, detailed
  language, and health insurance.

- formulas:

  default includes formulas for disability-related and language-related
  indicators calculated from tract-level ACS variables. This is a vector
  of string formulas.

- dropMOE:

  logical, whether to drop not retain the margin of error information
  for each ACS variable

- acs_raw:

  optional raw ACS table list or `bg_acs_raw` pipeline object previously
  created by
  [`download_bg_acs_raw()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_bg_acs_raw.md).
  If supplied, no ACS download is performed for tract-resolution tables.

- tract_weight_source:

  source for blockgroup-to-tract apportionment weights.
  `"decennial2020"` uses 2020 Decennial Census population weights,
  matching the legacy EJSCREEN approach. `"acs"` uses same-vintage ACS
  blockgroup population from `acs_raw` or downloads it when needed.

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

First get tract counts, then apportion tract counts into blockgroup
counts where that is how legacy EJSCREEN handled the indicator. Detailed
language counts from C16001 are tract-level values repeated on each
blockgroup in the tract, so language percentages are also tract-level
percentages repeated on each blockgroup.

For ACS 2022 and later, Connecticut ACS tract FIPS use planning-region
county equivalents while 2020 Decennial blockgroup FIPS use the older
county equivalents. When `tract_weight_source = "decennial2020"` and
`acs_raw` is available, the function detects this mismatch and remaps
the 2020 Decennial weights to the same ACS blockgroup suffixes, using
same-vintage ACS blockgroup population weights only for ambiguous or
unmatched cases.
