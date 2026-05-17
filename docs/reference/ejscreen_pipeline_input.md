# Helpers for file-backed EJSCREEN/EJAM data update pipeline stages

Helpers for file-backed EJSCREEN/EJAM data update pipeline stages

## Usage

``` r
ejscreen_pipeline_input(
  x = NULL,
  stage = NULL,
  pipeline_dir = NULL,
  path = NULL,
  format = NULL,
  object_name = NULL,
  storage = c("auto", "local", "s3"),
  input_name = "input"
)

ejscreen_pipeline_load(
  stage = NULL,
  pipeline_dir = NULL,
  path = NULL,
  format = NULL,
  object_name = NULL,
  storage = c("auto", "local", "s3"),
  return_data_table = TRUE
)

ejscreen_read_csv_table(path)

ejscreen_pipeline_save(
  x,
  stage,
  pipeline_dir,
  format = c("csv", "rds", "rda", "arrow"),
  object_name = stage,
  overwrite = TRUE,
  validate = TRUE,
  validation_strict = TRUE,
  storage = c("auto", "local", "s3")
)

ejscreen_pipeline_stage_names(canonical_only = FALSE)

ejscreen_pipeline_stage_canonical(stage)

ejscreen_pipeline_stage_path(
  stage,
  pipeline_dir,
  format = c("csv", "rds", "rda", "arrow")
)

ejscreen_pipeline_stage_exists(
  stage,
  pipeline_dir,
  format = "csv",
  storage = c("auto", "local", "s3")
)

ejscreen_pipeline_storage_backend(
  pipeline_dir = NULL,
  path = NULL,
  storage = c("auto", "local", "s3")
)
```

## Arguments

- x:

  object to save or object supplied directly as pipeline input.

- stage:

  pipeline stage name.

- pipeline_dir:

  folder for pipeline stage files.

- path:

  optional explicit file path to load.

- format:

  file format: `"rds"`, `"rda"`, `"csv"`, or `"arrow"`.

- object_name:

  object name to use inside `.rda` files.

- storage:

  stage storage backend: `"auto"`, `"local"`, or `"s3"`. `"auto"` treats
  `s3://...` pipeline directories or paths as S3 and everything else as
  local file storage. S3 support uses the AWS CLI and does not add an R
  package dependency.

- input_name:

  label used in error messages when an input is missing.

- return_data_table:

  logical passed to Arrow reads.

- overwrite:

  logical. If FALSE, refuse to overwrite an existing stage file.

- validate:

  logical. If TRUE, validate known stages before saving.

- validation_strict:

  logical passed to `EJAM:::ejscreen_pipeline_validate()`.

- canonical_only:

  optional logical set to TRUE in ejscreen_pipeline_stage_names() to
  return only the canonical versions without any aliases

## Value

`EJAM:::ejscreen_pipeline_stage_names()` returns vector of allowed stage
names and aliases, such as "bg_envirodata" etc., so that
`EJAM:::ejscreen_pipeline_validate()` can check if a specified stage
name is valid and apply the specific validation rules for that stage

`EJAM:::ejscreen_pipeline_stage_canonical()` returns the character
string input unchanged (if unrecognized) or returns the canonical
version of a stage name, mapping any recognized alias like "envirodata"
to the canonical name like "bg_envirodata"

`EJAM:::ejscreen_pipeline_stage_path()` returns a path, with
pipeline_dir as the folder(s) and filename based on stage and format
(file extension), such as
"some/temp/dir/ejscreen_acs_2024/bg_envirodata.csv"

`EJAM:::ejscreen_pipeline_save()` writes data to files and returns the
path, with many options for file format, local vs s3, validation, etc.

`EJAM:::ejscreen_pipeline_input()` & helper
`EJAM:::ejscreen_pipeline_load()` reads data from files or input,
returns the data object

`EJAM:::ejscreen_pipeline_storage_backend()` checks if using AWS s3 or
local folder storage, returns one of "auto", "local", "s3"

## Details

These helpers are intended for annual update functions that should be
usable either as in-memory calculations or as resumable file-backed
pipeline steps. They intentionally use base R formats by default and
only use Arrow when explicitly requested. The helpers construct file
paths, save files, load files, and normalize compatibility stage aliases
to canonical names.

## See also

[`calc_ejscreen_dataset()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset.md)
