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

ejscreen_pipeline_stage_names()

ejscreen_pipeline_stage_canonical(stage)

ejscreen_pipeline_dir(
  root = tempdir(),
  yr = NULL,
  pipeline_name = "ejscreen_acs"
)

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

  logical passed to
  [`ejscreen_pipeline_validate()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_validate.md).

- root:

  root folder where the pipeline folder should be created.

- yr:

  optional ACS end year or other year label to append to the pipeline
  folder name.

- pipeline_name:

  short pipeline folder name.

## Value

- `EJAM:::ejscreen_pipeline_stage_names()` returns known stage names.

- `EJAM:::ejscreen_pipeline_dir()` &
  `EJAM:::ejscreen_pipeline_stage_path()` return paths.

- `EJAM:::ejscreen_pipeline_save()` writes data to files and returns the
  path.

- `ejscreen_pipeline_input()` & helper `EJAM:::ejscreen_pipeline_load()`
  read data from files & return the loaded or supplied object.

## Details

These helpers are intended for annual update functions that should be
usable either as in-memory calculations or as resumable file-backed
pipeline steps. They intentionally use base R formats by default and
only use Arrow when explicitly requested. The helpers construct file
paths, save files, load files, and normalize compatibility stage aliases
to canonical names.

## See also

[`calc_ejscreen_dataset()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset.md)
