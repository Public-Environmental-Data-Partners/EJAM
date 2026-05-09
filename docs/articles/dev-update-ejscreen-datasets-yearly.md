# Updating EJScreen Datasets Annually (via the Pipeline)

This document explains the annual staged pipeline for updating the
blockgroup-level EJScreen/EJAM datasets, especially the objects
historically called `blockgroupstats`, `bgej`, `usastats`, and
`statestats`.

For general dataset maintenance outside this annual EJScreen pipeline,
such as FRS-related tables, NAICS/SIC tables, block-level files, and
Arrow release management, see [Updating and Managing the Datasets used
by
EJAM](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.md).

## What the Pipeline Covers

The annual pipeline is meant to make each major stage explicit, saved,
and reusable. It is centered on the high-level wrapper
[`calc_ejscreen_dataset()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset.md)
and the runner script:

``` r
source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

The pipeline creates or reads these stages:

1.  `bg_acs_raw`: raw ACS tables downloaded from the Census Bureau,
    saved before EJAM renaming or formula calculations.

2.  `bg_acsdata`: ACS-derived blockgroup indicators calculated from
    `bg_acs_raw`, including ACS-based demographics and the lead-paint
    indicator `pctpre1960`.

3.  `bg_envirodata`: blockgroup environmental indicators. This is
    expected to come from a separate environmental-data workflow. For
    draft builds, it can be provisionally reused from the current
    package data.

4.  `bg_extra_indicators`: other blockgroup indicators that are not ACS
    and not the main environmental indicators, such as health, life
    expectancy, and related context variables. For draft builds, these
    can also be provisionally reused from current package data.

5.  `blockgroupstats`: the combined blockgroup table with ACS
    indicators, environmental indicators, extra indicators, and
    geographic columns.

6.  `usastats_acs`, `statestats_acs`, `usastats_envirodata`, and
    `statestats_envirodata`: percentile lookup tables for ACS and
    environmental inputs.

7.  `bgej`: blockgroup EJ index values calculated from demographic
    indexes and environmental percentile values.

8.  `usastats_ej` and `statestats_ej`: percentile lookup tables for EJ
    index columns.

9.  `usastats` and `statestats`: combined lookup tables used by EJAM.

10. `ejscreen_export`: a provisional EJScreen-ready export that combines
    `blockgroupstats` and `bgej`, applies EJScreen-style names from
    `map_headernames`, and adds map helper fields where available.

The pipeline also writes `pipeline_validation_summary.csv`. When the
EJScreen export is created, it also writes
`ejscreen_export_schema_report.csv`.

The pipeline uses the packaged `formulas_ejscreen_acs` object for
ACS-derived indicator formulas. The old
`data-raw/archived_datacreate_formulas_ejscreen_acs_notes.R` script is
legacy reference material and should not be used as the current rebuild
workflow.

## Storage Choices

By default, the runner writes CSV checkpoints to a local folder:

``` r
data-raw/pipeline_outputs/ejscreen_acs_2024
```

This folder is ignored by Git because the checkpoint files can be very
large.

The same pipeline can later use AWS S3 by setting `EJAM_PIPELINE_DIR` to
an `s3://...` URI. S3 support uses the AWS CLI, so the machine running
the pipeline must have `aws` installed and configured.

``` r
Sys.setenv(
  EJAM_PIPELINE_DIR = "s3://your-bucket/your-prefix/ejscreen_acs_2024",
  EJAM_PIPELINE_STORAGE = "s3"
)

source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

The repository also has Git LFS rules for these pipeline CSV/RDS
artifacts, but large checkpoint files should normally stay out of the
code repository unless a temporary branch artifact is intentionally
needed.

## Running an Annual ACS Update

Start from a clean or well-understood branch, with the package source
loaded from the EJAM repository. The runner uses environment variables
so it can be rerun without editing the script.

For a normal 2020-2024 ACS update using local checkpoint files:

``` r
Sys.setenv(
  EJAM_PIPELINE_YR = "2024",
  EJAM_PIPELINE_DIR = file.path(
    getwd(),
    "data-raw",
    "pipeline_outputs",
    "ejscreen_acs_2024"
  ),
  EJAM_PIPELINE_STORAGE = "local",
  EJAM_INCLUDE_EJSCREEN_EXPORT = "TRUE"
)

source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

To force a fresh ACS download and rebuild `bg_acsdata`:

``` r
Sys.setenv(
  EJAM_FORCE_ACS = "TRUE",
  EJAM_FORCE_BG_ACSDATA = "TRUE"
)

source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

To reuse the saved raw ACS files but rebuild `bg_acsdata`:

``` r
Sys.setenv(
  EJAM_FORCE_ACS = "FALSE",
  EJAM_FORCE_BG_ACSDATA = "TRUE"
)

source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

## Adding Updated Environmental Data Later

The environmental data stage is intentionally separate. After updated
environmental indicators are available, save them as:

``` r
data-raw/pipeline_outputs/ejscreen_acs_2024/bg_envirodata.csv
```

The table must include `bgfips` and `pctpre1960`. The environmental
workflow may create `pctpre1960` by reading the saved `bg_acsdata.csv`
stage.

Then rerun the pipeline without forcing ACS:

``` r
Sys.setenv(
  EJAM_FORCE_ACS = "FALSE",
  EJAM_FORCE_BG_ACSDATA = "FALSE"
)

source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

This should reuse `bg_acs_raw` and `bg_acsdata`, read the updated
`bg_envirodata`, and regenerate downstream `blockgroupstats`, `bgej`,
`usastats`, `statestats`, and `ejscreen_export`.

## Draft Builds With Provisional Inputs

For draft builds, the runner can create provisional versions of
`bg_envirodata.csv` and `bg_extra_indicators.csv` by reusing columns
from the current package `blockgroupstats` object.

This is useful for testing the ACS and pipeline mechanics before the new
environmental data are ready. It is not the final scientific update.

To require an externally provided `bg_envirodata.csv` instead:

``` r
Sys.setenv(EJAM_USE_PROVISIONAL_BG_ENVIRODATA = "FALSE")
source("data-raw/run_ejscreen_acs2024_pipeline.R")
```

If the file is missing, the runner will stop rather than silently
reusing old environmental indicators.

## Reviewing Pipeline Outputs

After a run, start with:

``` r
library(data.table)

pipeline_dir <- "data-raw/pipeline_outputs/ejscreen_acs_2024"

validation <- fread(file.path(pipeline_dir, "pipeline_validation_summary.csv"))
validation[, .(stage, rows, columns, errors, warnings)]
```

There should be no validation errors. Row counts should be plausible and
should be compared against the prior release and against known Census
blockgroup coverage.

Then inspect the main outputs:

``` r
blockgroupstats <- fread(file.path(pipeline_dir, "blockgroupstats.csv"))
bgej            <- fread(file.path(pipeline_dir, "bgej.csv"))
usastats        <- fread(file.path(pipeline_dir, "usastats.csv"))
statestats      <- fread(file.path(pipeline_dir, "statestats.csv"))

nrow(blockgroupstats)
nrow(bgej)
names(blockgroupstats)
names(bgej)
```

Useful checks include:

- Are expected FIPS columns present and character typed?
- Are row counts close to expected blockgroup counts?
- Are key ACS indicators non-missing for most populated blockgroups?
- Are percentage/rate variables in the expected range?
- Do national and state percentile lookup tables include `PCTILE`,
  `REGION`, `mean`, and expected endpoints?
- Do `bgej` and `blockgroupstats` join cleanly by `bgfips`?

## Reviewing the EJScreen Export Schema

If `EJAM_INCLUDE_EJSCREEN_EXPORT=TRUE`, the runner writes:

``` r
ejscreen_export.csv
ejscreen_export_schema_report.csv
```

Use the schema report as a checklist:

``` r
x <- fread(file.path(pipeline_dir, "ejscreen_export_schema_report.csv"))

x[, .N, by = status]
x[status == "missing_expected"]
x[status == "missing_expected", .N, by = field_type][order(-N)]
```

Each missing expected field should be classified as one of:

1.  A field that EJScreen truly requires and the export must add.

2.  A field that is in `map_headernames` but should not be expected in
    the EJScreen export.

3.  A field that should be deferred until the EJScreen export schema is
    confirmed, such as some `B_...` map-bin or `T_...` popup-text helper
    fields.

The export schema is still being finalized, so this report is meant to
support review rather than automatically define release readiness.

## Finalizing Package Data

Once the annual outputs have been reviewed and accepted, the remaining
release work is outside the basic pipeline run:

- update dataset metadata with the relevant `metadata_*` helpers,
- save package data objects in the expected `.rda` format,
- create or update `.arrow` files where EJAM expects Arrow-backed
  datasets,
- update documentation and NEWS,
- publish large data files through the chosen release or storage
  mechanism, such as the data repository or S3.

The general release and large-data publication steps are covered in
[Updating and Managing the Datasets used by
EJAM](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.md)
and [Updating the Package as a New
Release](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-package.md).
