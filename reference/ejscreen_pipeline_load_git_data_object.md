# Load a data object from an explicit Git ref

Load a data object from an explicit Git ref

## Usage

``` r
ejscreen_pipeline_load_git_data_object(
  ref,
  path = "data/blockgroupstats.rda",
  object_name = NULL
)
```

## Arguments

- ref:

  Git branch, tag, or commit SHA.

- path:

  Repository path to an `.rda` file.

- object_name:

  Optional object name inside the `.rda` file. If NULL, use the first
  object in the file.

## Value

List containing `data`, `label`, `ref`, `path`, `object_name`, and
`acs_version`.
