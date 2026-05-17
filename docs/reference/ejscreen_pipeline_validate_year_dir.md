# Check that a pipeline folder name matches the requested ACS year

Check that a pipeline folder name matches the requested ACS year

## Usage

``` r
ejscreen_pipeline_validate_year_dir(yr, pipeline_dir, allow_mismatch = FALSE)
```

## Arguments

- yr:

  ACS end year requested for the run.

- pipeline_dir:

  pipeline folder or S3 prefix.

- allow_mismatch:

  logical. If TRUE, return FALSE for mismatches instead of stopping.

## Value

TRUE if no mismatch is detected. FALSE only when `allow_mismatch` is
TRUE and a mismatch was found.
