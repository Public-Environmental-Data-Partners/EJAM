# Download raw ACS tables for the blockgroup ACS pipeline

Download raw ACS tables for the blockgroup ACS pipeline

## Usage

``` r
download_bg_acs_raw(
  yr,
  blockgroup_tables = setdiff(as.vector(EJAM::tables_ejscreen_acs), tract_tables),
  tract_tables = c("B18101", "C16001"),
  include_tract_data = TRUE,
  fiveorone = "5",
  pipeline_dir = NULL,
  save_stage = FALSE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  raw_acs_storage = c("folder", "object"),
  raw_table_format = stage_format,
  overwrite = TRUE,
  validation_strict = TRUE,
  storage = c("auto", "local", "s3")
)
```

## Arguments

- yr:

  end year of the ACS 5-year survey to use.

- blockgroup_tables:

  ACS tables to download at blockgroup resolution.

- tract_tables:

  ACS tables to download at tract resolution for later blockgroup
  apportionment.

- include_tract_data:

  logical, whether to download `tract_tables`.

- fiveorone:

  ACS sample length, `"5"` by default.

- pipeline_dir:

  folder for saving the pipeline stage.

- save_stage:

  logical, whether to save the `bg_acs_raw` stage.

- stage_format:

  file format for saved object stages: `"rds"`, `"rda"`, `"csv"`, or
  `"arrow"`. Raw ACS folder checkpoints use `raw_table_format` for the
  per-table files.

- raw_acs_storage:

  raw ACS checkpoint storage pattern. `"folder"` saves one ACS table per
  file plus a manifest. `"object"` saves the historical single
  `bg_acs_raw` list object.

- raw_table_format:

  file format for per-table raw ACS files when
  `raw_acs_storage = "folder"`.

- overwrite:

  logical, whether to overwrite an existing saved stage.

- validation_strict:

  logical passed to
  [`ejscreen_pipeline_save()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_input.md).

- storage:

  raw ACS checkpoint storage backend: `"auto"`, `"local"`, or `"s3"`.

## Value

list with raw `blockgroup` and `tract` ACS table lists plus metadata.

## Details

This creates the raw ACS checkpoint for the annual EJSCREEN/EJAM data
update pipeline. It downloads the Census Bureau ACS table-based summary
file tables with
[`ACSdownload::get_acs_new()`](https://github.com/ejanalysis/ACSdownload,%20https://ejanalysis.github.io/ACSdownload/,%20https://ejanalysis.org/reference/get_acs_new.html).
By default, the saved checkpoint uses a folder-plus-manifest layout: one
file per ACS table in `bg_acs_raw/blockgroup/` and `bg_acs_raw/tract/`,
plus manifest files that describe the checkpoint. That is easier to
inspect and extend than one large list object, while still being
loadable as the same `ejam_bg_acs_raw` list object used by downstream
functions.

This stage is deliberately before EJAM formula calculations. The
downloaded tables are the parsed ACSdownload output, including Census
table columns, `GEO_ID`, `fips`, and `SUMLEVEL`.
