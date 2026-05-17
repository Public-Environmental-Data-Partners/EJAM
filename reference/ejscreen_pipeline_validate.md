# Validate one pipeline stage before saving dataset at that stage, for EJSCREEN/EJAM data updates pipeline

Validate one pipeline stage before saving dataset at that stage, for
EJSCREEN/EJAM data updates pipeline

## Usage

``` r
ejscreen_pipeline_validate(x, stage, strict = TRUE)
```

## Arguments

- x:

  object to validate.

- stage:

  pipeline stage name, must be among known stages or aliases as found in
  `EJAM:::ejscreen_pipeline_stage_names()` with canonical names such as
  bg_acs_raw, bg_acsdata, bg_envirodata, bg_geodata,
  bg_extra_indicators, blockgroupstats, usastats_acs, statestats_acs,
  usastats_envirodata, statestats_envirodata, usastats_ej,
  statestats_ej, usastats, statestats, bgej, ejscreen_export,
  ejscreen_dataset_creator_input

- strict:

  logical. If TRUE, errors stop execution. Warnings are still emitted as
  warnings.

## Value

invisibly returns a list with `errors` and `warnings`.

## Details

These checks are intentionally lightweight. They catch structural
problems that would make the next stage fail or make a saved checkpoint
misleading, without trying to be a full scientific validation report.
