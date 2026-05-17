# Compare one pipeline stage to a prior version

Compare one pipeline stage to a prior version

## Usage

``` r
ejscreen_pipeline_compare_stage(
  stage,
  new_dt = NULL,
  old_dt = NULL,
  new_pipeline_dir = NULL,
  old_pipeline_dir = NULL,
  new_stage = stage,
  old_stage = stage,
  format = "csv",
  storage = c("auto", "local", "s3"),
  old_label = NULL,
  new_acs_version = NULL,
  old_acs_version = NULL,
  shared_only = FALSE,
  id_cols = "bgfips",
  output_dir = NULL,
  write_files = FALSE,
  use_waldo = FALSE
)
```

## Arguments

- stage:

  label to use in summaries.

- new_dt:

  optional new data object. If NULL, load `new_stage` from
  `new_pipeline_dir`.

- old_dt:

  optional prior data object. If NULL, load `old_stage` from
  `old_pipeline_dir`.

- new_pipeline_dir, old_pipeline_dir:

  pipeline folders for loading stages.

- new_stage, old_stage:

  stage names to load. Defaults to `stage`.

- format:

  file format used for loading stages.

- storage:

  storage backend: `"auto"`, `"local"`, or `"s3"`.

- old_label:

  label for the prior/reference object.

- shared_only:

  logical. If TRUE, compare only prior columns shared with `new_dt`,
  plus `id_cols`.

- id_cols:

  identifier columns to keep for shared-column comparisons.

- output_dir:

  optional folder/S3 prefix for validation artifacts.

- write_files:

  logical. If TRUE, write one detail text file and one one-row CSV
  summary for this stage.

- use_waldo:

  logical passed to
  [`ejscreen_pipeline_validate_vs_prior()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_validate_vs_prior.md).

## Value

List with `result`, `summary`, `text`, `warnings`, and `error`.
