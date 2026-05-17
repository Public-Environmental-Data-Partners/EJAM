# Combine ACS and environmental inputs into blockgroupstats

Combine ACS and environmental inputs into blockgroupstats

## Usage

``` r
calc_ejscreen_blockgroupstats(
  bg_acsdata = NULL,
  bg_envirodata = NULL,
  bg_extra_indicators = NULL,
  bg_geodata = NULL,
  pipeline_dir = NULL,
  bg_acsdata_stage = "bg_acsdata",
  bg_envirodata_stage = "bg_envirodata",
  bg_extra_indicators_stage = "bg_extra_indicators",
  bg_geodata_stage = "bg_geodata",
  blockgroup_universe_source = c("acs", "union"),
  extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
  reuse_existing_extra_if_missing = FALSE,
  existing_blockgroupstats = NULL,
  save_stage = FALSE,
  pipeline_storage = c("auto", "local", "s3"),
  stage_format = c("csv", "rds", "rda", "arrow"),
  blockgroupstats_acs = NULL,
  blockgroupstats_acs_stage = NULL
)
```

## Arguments

- bg_acsdata:

  ACS-derived blockgroup table, or NULL if reading from a saved pipeline
  stage.

- bg_envirodata:

  environmental/non-ACS blockgroup table, or NULL if reading from a
  saved pipeline stage such as `"bg_envirodata"`.

- bg_extra_indicators:

  non-ACS, non-enviro blockgroup indicators such as `lowlifex`, health
  outcome rates, site/feature counts, climate indicators, and flag
  fields.

- bg_geodata:

  Census/TIGER blockgroup geography fields, especially `arealand` and
  `areawater` in square meters.

- pipeline_dir:

  folder for reading/writing pipeline stage files.

- bg_acsdata_stage:

  stage name for ACS input.

- bg_envirodata_stage:

  stage name for environmental input.

- bg_extra_indicators_stage:

  stage name for extra-indicator input.

- bg_geodata_stage:

  stage name for Census/TIGER geography input.

- blockgroup_universe_source:

  which input defines the output blockgroup universe. The default
  `"acs"` uses the ACS table rows as the authoritative tabulated
  universe for the requested ACS vintage. `"union"` keeps the older
  draft behavior of including any blockgroup present in ACS,
  environmental, or extra-indicator inputs.

- extra_indicator_vars:

  expected extra indicator columns.

- reuse_existing_extra_if_missing:

  logical. If TRUE, missing `bg_extra_indicators` columns are copied
  from `existing_blockgroupstats` with a warning. The default FALSE
  errors on missing extra inputs.

- existing_blockgroupstats:

  optional source for reuse when `reuse_existing_extra_if_missing` is
  TRUE. Defaults to current package data.

- save_stage:

  logical, whether to save the final `blockgroupstats` stage.

- pipeline_storage:

  stage storage backend: `"auto"`, `"local"`, or `"s3"`.

- stage_format:

  file format for saved/read stages: `"csv"`, `"rds"`, `"rda"`, or
  `"arrow"`.

- blockgroupstats_acs, blockgroupstats_acs_stage:

  old names retained as aliases for draft scripts.

## Value

data.table like
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md).

## Details

This is a reusable pipeline step. It combines an ACS-derived blockgroup
table with environmental and other non-ACS indicator columns, calculates
demographic indexes, and optionally saves the final
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
stage.

The environmental input is expected to include `pctpre1960`. That
indicator can be created by an upstream envirodata step from the saved
ACS stage, even though EJAM treats it as an environmental indicator for
EJ-index calculations.
