# Infer the ACS end year encoded in a pipeline version folder

Infer the ACS end year encoded in a pipeline version folder

## Usage

``` r
ejscreen_pipeline_dir_year(pipeline_dir)
```

## Arguments

- pipeline_dir:

  pipeline folder or S3 prefix.

## Value

Character ACS end year if the folder contains an `ejscreen_acs_YYYY`
component; otherwise `NA_character_`.
