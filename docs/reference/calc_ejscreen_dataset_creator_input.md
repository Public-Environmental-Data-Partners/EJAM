# Create the input CSV expected by EPA's EJScreen dataset-creator tool

Create the input CSV expected by EPA's EJScreen dataset-creator tool

## Usage

``` r
calc_ejscreen_dataset_creator_input(
  blockgroupstats = NULL,
  pipeline_dir = NULL,
  pipeline_storage = c("auto", "local", "s3"),
  blockgroupstats_stage = "blockgroupstats",
  blockgroupstats_path = NULL,
  stage_format = c("csv", "rds", "rda", "arrow"),
  mapping_for_names = map_headernames,
  rename_newtype = "ejscreen_indicator",
  expected_output_names = ejscreen_dataset_creator_input_fields(),
  placeholder_fields = ejscreen_dataset_creator_placeholder_fields(),
  force_placeholder_fields = ejscreen_dataset_creator_placeholder_fields(),
  fill_missing = TRUE,
  return_report = FALSE,
  save_stage = FALSE,
  save_path = NULL,
  save_format = NULL,
  overwrite = TRUE,
  validation_strict = TRUE
)
```

## Arguments

- blockgroupstats:

  blockgroupstats-like data.frame, or NULL if reading from a saved
  pipeline stage.

- pipeline_dir:

  folder for reading/saving pipeline stages.

- pipeline_storage:

  stage storage backend: `"auto"`, `"local"`, or `"s3"`.

- blockgroupstats_stage:

  stage name to read when `blockgroupstats` is not supplied.

- blockgroupstats_path:

  explicit path to a saved blockgroupstats input.

- stage_format:

  input/output stage file format.

- mapping_for_names:

  map_headernames-like crosswalk.

- rename_newtype:

  target naming column in `mapping_for_names`.

- expected_output_names:

  final EJScreen field names to create and order.

- placeholder_fields:

  fields that may be created as explicit `NA` placeholders if
  unavailable.

- force_placeholder_fields:

  fields to write as explicit `NA` placeholders even if a mapped source
  column is present. This defaults to post-percentile exceedance-count
  fields, because those are not really pre-index inputs for the EJScreen
  Python process.

- fill_missing:

  logical. If TRUE, add unavailable expected fields as `NA` columns and
  report them. If FALSE, stop when any expected field is unavailable.

- return_report:

  logical. If TRUE, return a list with `data` and `report`.

- save_stage:

  logical. If TRUE, save as the `ejscreen_dataset_creator_input`
  pipeline stage.

- save_path:

  optional direct path to save the input table.

- save_format:

  optional direct-save format, guessed from `save_path` when NULL.

- overwrite:

  logical. If FALSE, refuse to overwrite saved output.

- validation_strict:

  logical passed to
  [`ejscreen_pipeline_save()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_input.md).

## Value

data.frame, or a list with `data` and `report` when
`return_report = TRUE`.

## Details

This helper prepares the smaller pre-index input table expected by
`ejscreen-dataset-creator-2.3`. It is intended for the alternative
workflow where EJAM creates the ACS/environmental/extra-indicator base
table, but the EJScreen Python scripts calculate EJ indexes,
percentiles, map bins, and map popup text.

The helper reads a `blockgroupstats`-like object or saved pipeline
stage, renames fields through
[map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
via the same `ejscreen_indicator` metadata used by
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md),
adds explicit placeholder columns where requested fields are not
available, and returns columns in the order expected by the Python
tool's `col_names.py`.

A report is attached as the attribute
`ejscreen_dataset_creator_input_report`. Set `return_report = TRUE` to
return both the data and report.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create the pre-index input CSV that EPA's ejscreen-dataset-creator-2.3
# Python tool expects, using pipeline files that already exist on S3.
pipeline_dir <- paste0(
  "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/",
  "ejscreen_acs_2024"
)

out <- EJAM:::calc_ejscreen_dataset_creator_input(
  pipeline_dir = pipeline_dir,
  pipeline_storage = "s3",
  stage_format = "csv",
  save_stage = TRUE,
  return_report = TRUE
)

# This writes the file here:
EJAM:::ejscreen_pipeline_stage_path(
  "ejscreen_dataset_creator_input",
  pipeline_dir = pipeline_dir,
  format = "csv"
)

# Review any fields that were filled rather than mapped from blockgroupstats.
subset(out$report, status %in% c("placeholder", "missing_filled"))
} # }
```
