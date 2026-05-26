# Compare an EJSCREEN export table to a reference export CSV

Compare an EJSCREEN export table to a reference export CSV

## Usage

``` r
calc_ejscreen_export_reference_report(
  ejscreen_export = NULL,
  export_path = NULL,
  reference = NULL,
  reference_path = NULL,
  export_format = NULL,
  reference_format = NULL,
  storage = c("auto", "local", "s3"),
  id_col = "ID",
  numeric_tolerance = 1e-06,
  reference_label = NULL,
  note = NULL,
  output_dir = NULL,
  output_prefix = "prior_validation_ejscreen_export_vs_reference",
  write_files = FALSE
)
```

## Arguments

- ejscreen_export:

  optional EJSCREEN export data.frame.

- export_path:

  optional path to a saved EJSCREEN export stage.

- reference:

  optional reference data.frame.

- reference_path:

  optional path to a saved reference CSV/R data file.

- export_format:

  file format for `export_path`.

- reference_format:

  file format for `reference_path`.

- storage:

  storage backend for pipeline-style paths.

- id_col:

  preferred ID column name.

- numeric_tolerance:

  threshold for substantive numeric differences.

- reference_label:

  label shown in the text report.

- note:

  optional note shown near the top of the text report.

- output_dir:

  optional folder/S3 prefix for report files.

- output_prefix:

  base filename for written report files.

- write_files:

  logical. If TRUE, write `*_summary.txt`, `*_summary.csv`, and `*.csv`
  report files.

## Value

list with `summary`, `report`, and `text`.

## Details

This internal validation helper is used by the annual pipeline to
compare the 2022 pipeline `ejscreen_export` stage to the EPA-style
`EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv` reference file, which is named
for EJSCREEN 2024 but uses ACS 2018-2022 inputs. It preserves leading
zeroes in `ID` fields and reports both exact differences and substantive
numeric differences above `numeric_tolerance`.
