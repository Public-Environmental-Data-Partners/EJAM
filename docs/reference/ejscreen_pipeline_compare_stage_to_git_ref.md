# Compare one saved pipeline stage to a data object at an explicit Git ref

Compare one saved pipeline stage to a data object at an explicit Git ref

## Usage

``` r
ejscreen_pipeline_compare_stage_to_git_ref(
  stage,
  git_ref,
  git_path = "data/blockgroupstats.rda",
  object_name = NULL,
  new_dt = NULL,
  new_pipeline_dir = NULL,
  new_stage = stage,
  format = "csv",
  storage = c("auto", "local", "s3"),
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

- git_ref:

  Git branch, tag, or commit SHA holding the prior/reference package
  data.

- git_path:

  Repository path to the `.rda` prior/reference file.

- object_name:

  Optional object name inside `git_path`.

- new_dt:

  Optional new data object. If NULL, `new_stage` is loaded from
  `new_pipeline_dir`.

- new_pipeline_dir:

  Folder or S3 prefix holding the new pipeline stage file. Required when
  `new_dt` is NULL.

- new_stage:

  Stage name to load from `new_pipeline_dir`. Defaults to `stage`.

- format:

  File format used when loading the saved new pipeline stage.

- storage:

  Storage backend: `"auto"`, `"local"`, or `"s3"`.

- shared_only:

  Logical. If TRUE, compare only prior columns shared with the new data,
  plus `id_cols`.

- id_cols:

  Identifier columns to keep for shared-column comparisons.

- output_dir:

  Optional folder or S3 prefix for written validation artifacts.

- write_files:

  Logical. If TRUE, write one detail text file and one one-row CSV
  summary for this stage.

- use_waldo:

  Logical passed to
  [`ejscreen_pipeline_validate_vs_prior()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_validate_vs_prior.md).

## Value

List with `result`, `summary`, `text`, `warnings`, and `error`.

## Examples

``` r
if (FALSE) { # \dontrun{
# compare s3 copy of 2022 blockgroupstats.csv
# to v2.32.8.001 release version of blockgroupstats.rda

x <- EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
  git_ref = "v2.32.8.001",
  git_path = "data/blockgroupstats.rda",
  stage = "blockgroupstats",
  new_pipeline_dir = paste0(
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/",
    "ejscreen_acs_2022"
  )
)
print(x$text)
x$result$not_replicated

# compare only the 13 environmental indicators in names_e
# from a user-provided file against the v2.32.8.001 package data
user_env <- data.table::fread("path/to/user_bg_envirodata.csv")
user_env <- user_env[, c("bgfips", EJAM::names_e), with = FALSE]
x_env <- EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
  git_ref = "v2.32.8.001",
  git_path = "data/blockgroupstats.rda",
  stage = "bg_envirodata_names_e",
  new_dt = user_env,
  shared_only = TRUE,
  id_cols = "bgfips"
)
print(x_env$text)
} # }
```
