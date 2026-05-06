# Extra blockgroup indicators used by the EJSCREEN/EJAM pipeline

Extra blockgroup indicators used by the EJSCREEN/EJAM pipeline

## Usage

``` r
calc_bg_extra_indicators(
  bg_extra_indicators = NULL,
  extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
  reuse_existing_if_missing = FALSE,
  existing_blockgroupstats = NULL,
  pipeline_dir = NULL,
  save_stage = FALSE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  overwrite = TRUE,
  validation_strict = TRUE
)

ejscreen_default_extra_indicator_vars()

ejscreen_default_extra_indicator_varlists()
```

## Arguments

- bg_extra_indicators:

  optional data.frame or data.table with `bgfips` and extra indicator
  columns.

- extra_indicator_vars:

  expected extra indicator columns.

- reuse_existing_if_missing:

  logical, whether missing extra indicators should be copied from
  `existing_blockgroupstats`.

- existing_blockgroupstats:

  optional blockgroupstats-like table to use when
  `reuse_existing_if_missing` is TRUE. Defaults to current package data.

- pipeline_dir:

  folder for saving the pipeline stage.

- save_stage:

  logical, whether to save the `bg_extra_indicators` stage.

- stage_format:

  file format for saved stages: `"csv"`, `"rds"`, `"rda"`, or `"arrow"`.

- overwrite:

  logical, whether to overwrite an existing saved stage.

- validation_strict:

  logical passed to
  [`ejscreen_pipeline_save()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_input.md).

- extra_indicator_varlists:

  `map_headernames$varlist` groups used to identify extra indicator
  defaults.

## Value

data.table with `bgfips` and extra indicator columns.

## Details

`bg_extra_indicators` is for blockgroup-level fields that are not
ACS-derived `bg_acsdata` columns and are not environmental raw-score
`bg_envirodata` columns. Examples include low life expectancy, health
outcome rates, site/feature counts, climate indicators, and flag fields.

By default, missing extra indicators are errors. Set
`reuse_existing_if_missing = TRUE` only when you intentionally want to
carry forward columns from the currently packaged
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
data.
