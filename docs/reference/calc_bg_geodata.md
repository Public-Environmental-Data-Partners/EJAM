# Blockgroup geography fields used by the EJSCREEN/EJAM pipeline

Blockgroup geography fields used by the EJSCREEN/EJAM pipeline

## Usage

``` r
calc_bg_geodata(
  yr,
  bgfips = NULL,
  states = NULL,
  bg_geodata = NULL,
  existing_blockgroupstats = NULL,
  reuse_existing_if_missing = FALSE,
  allow_partial_reuse = FALSE,
  download = is.null(bg_geodata),
  geodata_source = c("tiger", "tigerweb"),
  tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
  tiger_base_url = "https://www2.census.gov/geo/tiger",
  download_dir = ejscreen_tiger_bg_cache_dir(),
  download_timeout = 3600,
  download_retries = 2,
  pipeline_dir = NULL,
  save_stage = FALSE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  overwrite = TRUE,
  pipeline_storage = c("auto", "local", "s3"),
  validation_strict = TRUE
)
```

## Arguments

- yr:

  ACS/TIGER vintage year.

- bgfips:

  optional vector of blockgroup FIPS codes that define the desired
  output universe.

- states:

  optional vector of 2-digit state FIPS codes. If NULL and `bgfips` is
  supplied, states are inferred from `bgfips`.

- bg_geodata:

  optional already-loaded geography table.

- existing_blockgroupstats:

  optional existing blockgroupstats-like table used only as an explicit
  fallback source.

- reuse_existing_if_missing:

  logical. If TRUE, reuse `arealand` and `areawater` from
  `existing_blockgroupstats` when TIGER data are missing, and fill
  missing compatibility-only `area` values from
  `existing_blockgroupstats` when available. This requires the old and
  new `bgfips` sets to match unless `allow_partial_reuse` is TRUE.

- allow_partial_reuse:

  logical. If TRUE, allow fallback reuse when the old and new `bgfips`
  sets differ, with a warning and possible missing values.

- download:

  logical. If TRUE, download Census blockgroup geography attributes when
  `bg_geodata` is not supplied.

- geodata_source:

  preferred Census source. `"tiger"` downloads TIGER/Line blockgroup zip
  files and is the default because it best matches legacy EJScreen/EJAM
  `arealand` and `areawater` values. `"tigerweb"` queries only needed
  attributes from Census TIGERweb and is used as a fallback.

- tigerweb_base_url:

  Census TIGERweb REST base URL.

- tiger_base_url:

  Census TIGER base URL used by the TIGER/Line zip fallback.

- download_dir:

  local folder for downloaded TIGER/Line zip files. By default this uses
  `EJAM_TIGER_BG_CACHE_DIR` when set, otherwise the user cache folder
  from [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html) so
  state zip files can be reused across pipeline runs and R sessions.

- download_timeout:

  timeout in seconds for Census downloads.

- download_retries:

  number of retries after a failed Census download.

- pipeline_dir:

  folder for saving the pipeline stage.

- save_stage:

  logical, whether to save the `bg_geodata` stage.

- stage_format:

  file format for saved stages: `"csv"`, `"rds"`, `"rda"`, or `"arrow"`.

- overwrite:

  logical, whether to overwrite an existing saved stage.

- pipeline_storage:

  stage storage backend: `"auto"`, `"local"`, or `"s3"`.

- validation_strict:

  logical passed to
  [`ejscreen_pipeline_save()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejscreen_pipeline_input.md).

## Value

data.table with `bgfips`, `arealand`, `areawater`, optional `intptlat`,
`intptlon`, and compatibility-only `area`.

## Details

`bg_geodata` stores Census/TIGER blockgroup geography attributes needed
by later pipeline stages. By default the function downloads Census
TIGER/Line blockgroup shapefiles for the requested ACS/TIGER vintage and
extracts only the attributes EJAM needs. TIGERweb remains available as a
fallback or explicit lighter-weight source, and its Census Block Groups
layer is discovered at runtime instead of assuming that TIGERweb layer
numbers are stable across years. `arealand` and `areawater` are Census
square-meter fields and should be used for area weighting and
area-derived checks. The legacy `area` column is retained only for
compatibility with older EJScreen/EJAM tables and should not be used for
calculations. When `reuse_existing_if_missing = TRUE`, missing legacy
`area` values can be filled from `existing_blockgroupstats` without
replacing Census `arealand` or `areawater`. If the fallback `bgfips`
universe does not match, legacy `area` remains `NA` while Census
`arealand` and `areawater` remain available for calculations.
