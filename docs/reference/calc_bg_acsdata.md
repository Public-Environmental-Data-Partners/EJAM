# Calculate the ACS-derived blockgroup pipeline stage

Calculate the ACS-derived blockgroup pipeline stage

## Usage

``` r
calc_bg_acsdata(
  yr,
  formulas = EJAM::formulas_ejscreen_acs$formula,
  tables = as.vector(EJAM::tables_ejscreen_acs),
  include_tract_data = TRUE,
  tract_tables = c("B18101", "C16001"),
  tract_formulas = NULL,
  dropMOE = TRUE,
  acs_raw = NULL,
  acs_raw_stage = NULL,
  pipeline_dir = NULL,
  save_stage = FALSE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  overwrite = TRUE,
  validation_strict = TRUE
)
```

## Arguments

- yr:

  end year of the ACS 5-year survey to use.

- formulas:

  formulas used for blockgroup-resolution ACS tables.

- tables:

  ACS tables to inspect and download when available at blockgroup
  resolution.

- include_tract_data:

  logical, whether to add tract-resolution ACS indicators apportioned to
  blockgroups.

- tract_tables:

  ACS tables to obtain at tract resolution and apportion to blockgroups.

- tract_formulas:

  formulas used for tract-resolution ACS indicators. Defaults to
  [`calc_blockgroupstats_from_tract_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_from_tract_data.md)
  defaults.

- dropMOE:

  logical, whether to drop ACS margin-of-error columns.

- acs_raw:

  optional raw ACS pipeline object from
  [`download_bg_acs_raw()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_bg_acs_raw.md).

- acs_raw_stage:

  optional stage name to read from `pipeline_dir`.

- pipeline_dir:

  folder for saving the pipeline stage.

- save_stage:

  logical, whether to save the `bg_acsdata` stage.

- stage_format:

  file format for saved stages: `"csv"`, `"rds"`, `"rda"`, or `"arrow"`.

- overwrite:

  logical, whether to overwrite an existing saved stage.

- validation_strict:

  logical passed to
  [`ejscreen_pipeline_save()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_input.md).

## Value

data.table, one row per blockgroup.

## Details

This is the first step in the reusable ACS pipeline for annual
EJSCREEN/EJAM data updates. It downloads blockgroup-resolution ACS
tables via
[`calc_blockgroupstats_acs()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_acs.md),
apportions tract-resolution-only ACS tables to blockgroups with
[`calc_blockgroupstats_from_tract_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_from_tract_data.md),
merges those ACS-derived indicators, and can save the validated
`bg_acsdata` stage.

`bg_acsdata` is intentionally limited to data columns that can be
created using only ACS data. "Demographic index" columns are calculated
later by
[`calc_ejscreen_blockgroupstats()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_blockgroupstats.md),
after `bg_envirodata` and extra indicators have been joined, because the
supplemental demographic index needs `lowlifex` which is not from the
ACS.
