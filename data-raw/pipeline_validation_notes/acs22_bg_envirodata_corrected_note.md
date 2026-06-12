# ACS22 bg_envirodata Drinking-Water Correction Note

This note documents the corrected ACS2022 environmental input stage used by the
EJAM v2.32.9 ACS22 replication pipeline.

## File

- Canonical pipeline stage:
  `s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2022/bg_envirodata.csv`
- The pipeline should read this file as-is. Do not apply a comparison-time or
  runner-only drinking-water patch during normal ACS22 replication refreshes.

## What This File Represents

`bg_envirodata.csv` is the environmental-data input stage used to build
ACS2022 `blockgroupstats`, `bgej`, percentile lookup tables, and EJScreen-style
exports. For the drinking-water non-compliance indicator, the corrected file
preserves the EPA-style distinction between:

- `drinking = NA`: no valid drinking-water score in the source/reference data.
- `drinking = 0`: a valid reported score of zero.

This differs from EJAM v2.32.8.001 and earlier package data, where missing EPA
`DWATER` values were converted to `drinking = 0` when `blockgroupstats` was
created.

## Replication Interpretation

- `acs22_replication_2025_tool_vs_2024_tool` uses EJAM v2.32.8.001 package data
  as-is. It should expose the historical drinking-water NA-to-zero issue where
  relevant.
- `acs22_replication_2026_tool_vs_2024_tool` uses ACS22 pipeline outputs built
  from this corrected `bg_envirodata.csv`. It should preserve EPA-style
  drinking-water missingness and should not show the old v2.32.8.001 raw-score
  problem for `DWATER`/`drinking`.
- `acs22_replication_2026_tool_vs_2025_tool` is expected to show this deliberate
  source-data difference for drinking-water.

## Verification Counts

Verified from the S3 file copied locally on 2026-05-30:

- Rows: 243,022.
- `drinking = NA`: 19,894 rows total.
- Non-Island-Area `drinking = NA`: 19,208 rows.
- Island Area `drinking = NA`: 686 rows.
- `drinking = 0`: 163,948 rows.
- Nonzero `drinking`: 59,180 rows.

The 19,208 non-Island-Area missing values correspond to the EPA ACS22 `DWATER`
missingness that EJAM v2.32.8.001 did not preserve in `blockgroupstats`.

