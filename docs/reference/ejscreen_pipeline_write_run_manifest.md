# Write an EJSCREEN pipeline run manifest

Write an EJSCREEN pipeline run manifest

## Usage

``` r
ejscreen_pipeline_write_run_manifest(
  pipeline_dir,
  storage = c("auto", "local", "s3"),
  pipeline_yr,
  pipeline_storage,
  stage_format,
  settings = character(),
  provisional_inputs = logical(),
  run_started_at = Sys.time(),
  run_finished_at = Sys.time(),
  status = "completed",
  filename = "pipeline_run_manifest.csv"
)
```

## Arguments

- pipeline_dir:

  pipeline folder or S3 prefix.

- storage:

  storage backend: `"auto"`, `"local"`, or `"s3"`.

- pipeline_yr:

  ACS end year for the run.

- pipeline_storage:

  resolved pipeline storage backend.

- stage_format:

  pipeline stage file format.

- settings:

  named character vector of environment/settings used by the run.

- provisional_inputs:

  named logical vector indicating whether provisional inputs were reused
  or created for this run.

- run_started_at, run_finished_at:

  run timestamps.

- status:

  run status label.

- filename:

  manifest filename.

## Value

Path or S3 URI to the written manifest.

## Details

The annual pipeline runner writes this manifest after stage validation.
It records run provenance, including package version, Git branch and
SHA, ACS vintage, pipeline location, primary stage format, selected
environment/settings values, and whether provisional inputs were reused.
Keep this file with the stage outputs so later reviewers can tell which
code and settings produced a given S3 or local pipeline folder.
