# Run the staged EJSCREEN/EJAM dataset update pipeline

Run the staged EJSCREEN/EJAM dataset update pipeline

## Usage

``` r
calc_ejscreen_dataset(
  yr,
  bg_envirodata = NULL,
  bg_extra_indicators = NULL,
  bg_acs_raw = NULL,
  bg_acsdata = NULL,
  blockgroupstats = NULL,
  pipeline_dir = NULL,
  pipeline_storage = c("auto", "local", "s3"),
  save_stages = FALSE,
  use_saved_stages = TRUE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  raw_acs_storage = c("folder", "object"),
  raw_table_format = stage_format,
  overwrite = TRUE,
  validation_strict = TRUE,
  download_acs_raw = TRUE,
  return_intermediate = TRUE,
  include_ejscreen_export = FALSE,
  ejscreen_export_path = NULL,
  ejscreen_export_vars = NULL,
  ejscreen_export_required_names = NULL,
  ejscreen_export_rename_newtype = "ejscreen_names",
  blockgroup_tables = setdiff(as.vector(EJAM::tables_ejscreen_acs), tract_tables),
  tract_tables = c("B18101", "C16001"),
  include_tract_data = TRUE,
  fiveorone = "5",
  formulas = EJAM::formulas_ejscreen_acs$formula,
  tract_formulas = NULL,
  dropMOE = TRUE,
  extra_indicator_vars = ejscreen_default_extra_indicator_vars(),
  reuse_existing_if_missing = FALSE,
  existing_blockgroupstats = NULL,
  acs_vars = NULL,
  enviro_vars = NULL,
  ej_indicator_vars = names_e,
  ej_indicator_pctile_vars = names_e_pctile,
  ej_indicator_state_pctile_vars = names_e_state_pctile,
  ej_index_vars = names_ej,
  ej_index_supp_vars = names_ej_supp,
  ej_index_state_vars = names_ej_state,
  ej_index_supp_state_vars = names_ej_supp_state,
  demog_index_var = "Demog.Index",
  demog_index_supp_var = "Demog.Index.Supp",
  demog_index_state_var = "Demog.Index.State",
  demog_index_supp_state_var = "Demog.Index.Supp.State"
)
```

## Arguments

- yr:

  end year of the ACS 5-year survey to use.

- bg_envirodata:

  environmental blockgroup table. If NULL, the wrapper tries to read the
  saved `bg_envirodata` stage when `use_saved_stages` is TRUE.

- bg_extra_indicators:

  non-ACS, non-enviro blockgroup indicators such as `lowlifex`, or NULL
  to read/reuse/create that stage.

- bg_acs_raw:

  optional raw ACS pipeline object from
  [`download_bg_acs_raw()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_bg_acs_raw.md).

- bg_acsdata:

  optional ACS-derived blockgroup table from
  [`calc_bg_acsdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bg_acsdata.md).

- blockgroupstats:

  optional already-combined blockgroupstats-like table.

- pipeline_dir:

  folder or `s3://...` URI for reading/writing pipeline stage files.

- pipeline_storage:

  stage storage backend: `"auto"`, `"local"`, or `"s3"`. `"auto"` uses
  S3 when `pipeline_dir` starts with `s3://` and local file storage
  otherwise.

- save_stages:

  logical, whether to save each stage as it is created.

- use_saved_stages:

  logical, whether missing inputs may be read from existing files in
  `pipeline_dir`.

- stage_format:

  file format for saved/read tabular stages: `"csv"`, `"rds"`, `"rda"`,
  or `"arrow"`. The wrapper defaults to CSV so every pipeline checkpoint
  is easy to inspect outside R.

- raw_acs_storage:

  raw ACS checkpoint storage pattern. `"folder"` saves one ACS table per
  file plus a manifest. `"object"` saves the historical single
  `bg_acs_raw` list object.

- raw_table_format:

  file format for per-table raw ACS files when
  `raw_acs_storage = "folder"`.

- overwrite:

  logical, whether to overwrite saved stage files.

- validation_strict:

  logical passed to stage validators.

- download_acs_raw:

  logical, whether to download raw ACS tables when neither `bg_acsdata`
  nor saved ACS stages are available.

- return_intermediate:

  logical. If TRUE, return key interim stage objects in addition to
  final datasets.

- include_ejscreen_export:

  logical. If TRUE, also create an EJSCREEN-ready export using
  [`calc_ejscreen_export()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_export.md).

- ejscreen_export_path:

  optional file path for the EJSCREEN export.

- ejscreen_export_vars:

  optional EJAM `rname` columns to keep in the EJSCREEN export before
  renaming.

- ejscreen_export_required_names:

  optional final EJSCREEN field names that must be present.

- ejscreen_export_rename_newtype:

  naming column in
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  to use when renaming the EJSCREEN export.

- blockgroup_tables:

  ACS tables to download at blockgroup resolution.

- tract_tables:

  ACS tables to download at tract resolution for later blockgroup
  apportionment.

- include_tract_data:

  logical, whether to download `tract_tables`.

- fiveorone:

  ACS sample length, `"5"` by default.

- formulas:

  formulas used for blockgroup-resolution ACS tables.

- tract_formulas:

  formulas used for tract-resolution ACS indicators. Defaults to
  [`calc_blockgroupstats_from_tract_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_blockgroupstats_from_tract_data.md)
  defaults.

- dropMOE:

  logical, whether to drop ACS margin-of-error columns.

- extra_indicator_vars:

  expected extra indicator columns.

- reuse_existing_if_missing:

  logical, whether missing extra indicators should be copied from
  `existing_blockgroupstats`.

- existing_blockgroupstats:

  optional blockgroupstats-like table to use when
  `reuse_existing_if_missing` is TRUE. Defaults to current package data.

- acs_vars:

  variables to include in the ACS-only lookup stages. Defaults to
  current EJSCREEN/EJAM ACS indicators found in `bgstats`.

- enviro_vars:

  variables to include in the environmental lookup stages. Defaults to
  current environmental, health, site, climate, and feature variables
  found in `bgstats`.

- ej_indicator_vars:

  environmental indicators to use when calculating EJ indexes. Defaults
  to
  [names_e](https://public-environmental-data-partners.github.io/EJAM/reference/names_e.md),
  but can be replaced for custom indicators.

- ej_indicator_pctile_vars, ej_indicator_state_pctile_vars:

  names for national/state environmental percentile columns used
  internally by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

- ej_index_vars, ej_index_supp_vars, ej_index_state_vars,
  ej_index_supp_state_vars:

  names for the four EJ-index families created by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

- demog_index_var, demog_index_supp_var, demog_index_state_var,
  demog_index_supp_state_var:

  demographic index column names used by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

## Value

named list containing final datasets (`blockgroupstats`, `bgej`,
`usastats`, and `statestats`) plus interim stages when
`return_intermediate` is TRUE. Attributes record `pipeline_dir`,
`stage_format`, and saved stage paths.

## Details

`calc_ejscreen_dataset()` can be called from, for example, a script like
the one in `data-raw/run_ejscreen_acs2024_pipeline.R`

`calc_ejscreen_dataset()` is a high-level wrapper around the staged
annual update helpers. It is intentionally an orchestrator rather than a
replacement for the individual stage functions. Each major input or
output can be supplied as an R object, read from a saved stage in
`pipeline_dir`, or created and saved by this function.

The default stage order is:

1.  download raw ACS tables of demographic data into `bg_acs_raw`

2.  calculate ACS-based demographic indicators (and lead paint
    indicator) as `bg_acsdata`

3.  validate/save `bg_envirodata` (key environmental indicators)

4.  validate/save `bg_extra_indicators` (e.g., % low life expectancy)

5.  calculate demographic indexes (using % low life expectancy, etc.)

6.  combine those blockgroup demog., envt., and extra indicators as
    [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)

7.  create intermediate percentile lookup tables `usastats_acs`,
    `statestats_acs`, `usastats_envirodata`, `statestats_envirodata`

8.  calculate EJ indexes (from envt. percentiles and demog. indexes) and
    save as
    [bgej](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md)
    table

9.  create intermediate percentile lookup tables `usastats_ej`,
    `statestats_ej`

10. combine those as
    [usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
    and
    [statestats](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md)

11. create an EJScreen-ready export file (optionally)

`bg_envirodata` must include `pctpre1960`. That column may be produced
by an upstream environmental-data step that reads the saved `bg_acsdata`
stage.
