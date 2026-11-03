# Prepared 2024 State and County Geography

These files are the prepared 2024 state/county geography inputs for PR #675.
They are staged source inputs, not active package data.
The package build excludes `data-raw/`; nothing here replaces the objects in
`data/`, changes DESCRIPTION, or activates the ACS/environmental data swap.

- `states_shapefile.rda`: 56 full TIGER state/territory polygons.
- `counties_shapefile.rda`: 3,235 generalized 1:500,000 county polygons.
- `stateinfo.rda` and `stateinfo2.rda`: prepared state lookup information.
- `countyinfo.csv`: county audit information, not an installed public dataset.
- `manifest.json`: original source/provenance record (schema 1, MD5).
- `current-input-diagnostic.json`: historical comparison against the then-active
  ACS 2018-2022 inputs, not acceptance of a new ACS 2020-2024 release build.
- `SHA256SUMS`: SHA-256 checksums for all seven original files. The files are
  restored byte-for-byte; the original manifest has not been rewritten.

From this directory, `shasum -a 256 -c SHA256SUMS` checks the restored payloads.
`EJAM:::release_geography_read()` checks the original manifest and validates
geometry, physical vintage, coverage, and lookup consistency. New builds use
the newer SHA-256 manifest format.

Before activating these inputs, compare them against the accepted same-build
demographic and Arrow inputs, review geography differences, and coordinate
the package data, version metadata, asset pin, and fixture changes. Do not use
the historical diagnostic to claim that those release checks are complete.
