# Build the standard folder path for one EJSCREEN pipeline version

Build the standard folder path for one EJSCREEN pipeline version

## Usage

``` r
ejscreen_pipeline_version_dir(yr, root = NULL, prefix = "ejscreen_acs_")
```

## Arguments

- yr:

  ACS end year, such as 2024.

- root:

  pipeline root folder or S3 prefix that contains version folders.

- prefix:

  version folder prefix.

## Value

Character path, such as `s3://.../pipeline/ejscreen_acs_2024`.
