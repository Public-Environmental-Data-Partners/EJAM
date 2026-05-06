# Validate an EJSCREEN/EJAM pipeline stage before saving it

Validate an EJSCREEN/EJAM pipeline stage before saving it

## Usage

``` r
ejscreen_pipeline_validate(x, stage, strict = TRUE)
```

## Arguments

- x:

  object to validate.

- stage:

  pipeline stage name, such as `"bg_acsdata"`, `"bg_acs_raw"`,
  `"blockgroupstats_acs"`, `"bg_envirodata"`, `"envirodata"`,
  `"bg_extra_indicators"`, `"blockgroupstats"`, `"bgej"`,
  `"bg_ejindexes"`, `"usastats_acs"`, `"statestats_acs"`,
  `"usastats_envirodata"`, `"statestats_envirodata"`, `"usastats_ej"`,
  `"statestats_ej"`, `"usastats"`, `"statestats"`, or
  `"ejscreen_export"`.

- strict:

  logical. If TRUE, errors stop execution. Warnings are still emitted as
  warnings.

## Value

invisibly returns a list with `errors` and `warnings`.

## Details

These checks are intentionally lightweight. They catch structural
problems that would make the next stage fail or make a saved checkpoint
misleading, without trying to be a full scientific validation report.
