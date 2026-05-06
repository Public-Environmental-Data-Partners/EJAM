# Combine EJAM blockgroup datasets and rename fields for EJSCREEN

Combine EJAM blockgroup datasets and rename fields for EJSCREEN

## Usage

``` r
calc_ejscreen_export(
  blockgroupstats = NULL,
  bgej = NULL,
  usastats_ej = NULL,
  statestats_ej = NULL,
  pipeline_dir = NULL,
  blockgroupstats_stage = "blockgroupstats",
  bgej_stage = "bgej",
  usastats_ej_stage = "usastats_ej",
  statestats_ej_stage = "statestats_ej",
  blockgroupstats_path = NULL,
  bgej_path = NULL,
  usastats_ej_path = NULL,
  statestats_ej_path = NULL,
  stage_format = c("csv", "rds", "rda", "arrow"),
  by = "bgfips",
  output_vars = NULL,
  rename_newtype = "ejscreen_names",
  mapping_for_names = map_headernames,
  required_output_names = NULL,
  include_ej_percentiles = TRUE,
  include_state_ej_percentiles = TRUE,
  ej_percentile_vars = c(names_ej, names_ej_supp),
  ej_percentile_output_vars = c(names_ej_pctile, names_ej_supp_pctile),
  ej_state_percentile_vars = c(names_ej_state, names_ej_supp_state),
  ej_state_percentile_output_vars = c(names_ej_state_pctile, names_ej_supp_state_pctile),
  include_ejscreen_map_fields = TRUE,
  map_field_pctile_names = NULL,
  overwrite_ejscreen_map_fields = TRUE,
  save_path = NULL,
  save_format = NULL,
  overwrite = TRUE
)
```

## Arguments

- blockgroupstats:

  blockgroupstats-like data.frame, or NULL if reading from a saved
  pipeline stage.

- bgej:

  bgej-like data.frame, or NULL if reading from a saved pipeline stage.

- usastats_ej, statestats_ej:

  EJ-index percentile lookup tables. These are used to add
  `P_D2_...`/`P_D5_...` fields before creating EJSCREEN map helper
  fields.

- pipeline_dir:

  folder for reading saved pipeline stages.

- blockgroupstats_stage, bgej_stage:

  stage names to read when objects are not supplied.

- usastats_ej_stage, statestats_ej_stage:

  stage names to read for EJ-index percentile lookup tables when objects
  are not supplied.

- blockgroupstats_path, bgej_path, usastats_ej_path, statestats_ej_path:

  explicit paths to saved inputs.

- stage_format:

  input file format when reading pipeline stages.

- by:

  key column used to merge `blockgroupstats` and `bgej`.

- output_vars:

  optional EJAM `rname` columns to keep before renaming. Defaults to all
  available columns after the merge.

- rename_newtype:

  target naming column in
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).
  Defaults to `"ejscreen_names"`.

- mapping_for_names:

  map_headernames-like crosswalk.

- required_output_names:

  optional final EJSCREEN field names that must be present after
  renaming.

- include_ej_percentiles:

  logical. If TRUE, add missing national EJ-index percentile columns
  from `usastats_ej`.

- include_state_ej_percentiles:

  logical. If TRUE, add missing state EJ-index percentile columns from
  `statestats_ej`.

- ej_percentile_vars, ej_percentile_output_vars:

  raw national EJ-index variables and corresponding percentile variables
  to add.

- ej_state_percentile_vars, ej_state_percentile_output_vars:

  raw state EJ-index variables and corresponding percentile variables to
  add.

- include_ejscreen_map_fields:

  logical. If TRUE, create EJSCREEN app `B_...` map color-bin columns
  and `T_...` popup-text columns from exported `P_...` percentile
  columns.

- map_field_pctile_names:

  optional final EJSCREEN percentile field names to use when creating
  map helper fields. Defaults to all exported `P_...` fields known to
  `mapping_for_names`, plus any other exported fields whose names start
  with `P_`.

- overwrite_ejscreen_map_fields:

  logical. If TRUE, recalculate existing `B_...` and `T_...` fields from
  the matching percentile fields.

- save_path:

  optional file path to save the export.

- save_format:

  optional save format. Guessed from `save_path` when NULL. Supported
  values are `"csv"`, `"rds"`, `"rda"`, and `"arrow"`.

- overwrite:

  logical. If FALSE, refuse to overwrite `save_path`.

## Value

data.frame with EJSCREEN-ready column names.

## Details

This helper prepares a tabular export by merging a
`blockgroupstats`-like table with a `bgej`-like table and renaming
available columns through
[map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).
By default it uses `ejscreen_names`, which is the column intended to
represent the current EJSCREEN app/export numeric field name. It also
creates EJSCREEN app map helper fields from exported percentile fields:
`B_...` map color-bin columns and `T_...` popup-text columns. The
`B_...` bins use the historical EJSCREEN/ejanalysis cutpoints: 0-9th
percentile is bin 1, 10-19 is bin 2, ..., 80-89 is bin 9, 90-94 is bin
10, and 95-100 is bin 11. Missing or out-of-range percentiles are
assigned bin 0. The `T_...` fields use the current EJSCREEN service text
style, such as `"95 %ile"`.
