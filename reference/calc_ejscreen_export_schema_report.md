# Report which EJSCREEN export fields are expected, missing, or extra

Report which EJSCREEN export fields are expected, missing, or extra

## Usage

``` r
calc_ejscreen_export_schema_report(
  ejscreen_export = NULL,
  export_path = NULL,
  mapping_for_names = map_headernames,
  rename_newtype = "ejscreen_names",
  expected_output_names = NULL,
  include_map_helper_fields = TRUE
)
```

## Arguments

- ejscreen_export:

  optional data.frame containing an EJSCREEN export.

- export_path:

  optional path to a saved export CSV.

- mapping_for_names:

  map_headernames-like crosswalk.

- rename_newtype:

  naming column in `mapping_for_names` to check.

- expected_output_names:

  optional extra expected output field names.

- include_map_helper_fields:

  logical. If TRUE, include expected `B_...` and `T_...` helper fields
  associated with percentile fields.

## Value

data.frame describing present/missing/extra export fields.

## Details

This helper compares a proposed EJSCREEN export table with the names
implied by
[map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
or another mapping table. It is used by the annual data-update pipeline
to write `ejscreen_export_schema_report.csv`.
