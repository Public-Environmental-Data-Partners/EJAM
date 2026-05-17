# Compare saved EJSCREEN pipeline stages across two versions

Compare saved EJSCREEN pipeline stages across two versions

## Usage

``` r
ejscreen_pipeline_compare_versions(
  new_yr = NULL,
  old_yr = NULL,
  stages = c("blockgroupstats", "bgej", "usastats", "statestats"),
  pipeline_root = NULL,
  new_pipeline_dir = NULL,
  old_pipeline_dir = NULL,
  old_stages = NULL,
  format = "csv",
  storage = c("auto", "local", "s3"),
  shared_only_stages = character(),
  id_cols = "bgfips",
  output_dir = NULL,
  write_files = TRUE,
  use_waldo = FALSE
)
```

## Arguments

- new_yr, old_yr:

  version years used to build default pipeline folders.

- stages:

  character vector of stage names to compare.

- pipeline_root:

  root folder/S3 prefix containing version folders.

- new_pipeline_dir, old_pipeline_dir:

  optional explicit version folders.

- old_stages:

  optional stage names in the old folder. Defaults to `stages`. Can be a
  named vector where names are new stage names.

- format:

  file format for loading stage files.

- storage:

  storage backend: `"auto"`, `"local"`, or `"s3"`.

- shared_only_stages:

  stages that should compare only shared prior columns, plus `id_cols`.

- id_cols:

  identifier columns to keep for shared-column comparisons.

- output_dir:

  optional folder/S3 prefix where validation files are saved.

- write_files:

  logical. If TRUE, write per-stage detail files plus
  `prior_validation_summary.csv`.

- use_waldo:

  logical passed to
  [`ejscreen_pipeline_validate_vs_prior()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_validate_vs_prior.md).

## Value

List with `summary`, `comparisons`, `new_pipeline_dir`, and
`old_pipeline_dir`.
