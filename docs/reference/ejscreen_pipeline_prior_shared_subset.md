# Keep the prior columns that can be compared to a new table

Keep the prior columns that can be compared to a new table

## Usage

``` r
ejscreen_pipeline_prior_shared_subset(old_dt, new_dt, id_cols = "bgfips")
```

## Arguments

- old_dt:

  prior/reference data.frame or data.table.

- new_dt:

  new data.frame or data.table.

- id_cols:

  identifier columns to preserve when available.

## Value

data.table containing identifier columns and columns shared by both
inputs.
