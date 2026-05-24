# Future Arrow Versioning and Manifest Refactor Plan

This is a durable planning note for post-v2.5.0 cleanup. It records the intended direction for how EJAM should name, version, cache, validate, and document large Arrow-format datasets such as `bgej.arrow`, `blockwts.arrow`, `blockpoints.arrow`, and FRS-related files.

## Current v2.5.0 Bridge

For v2.5.0, EJAM still obtains large Arrow files from release assets in the `ejamdata` repository. The important change is that current EJAM code should not use the latest `ejamdata` release implicitly. Instead, EJAM should read the package-level required release tag from `DESCRIPTION` via `ejamdata_required_tag` and use that tag for Arrow downloads and local cache checks.

This bridge deliberately keeps the existing `data/ejamdata_version.txt` marker for now. The name is imperfect because it actually records the local Arrow release tag, but keeping it avoids a larger migration immediately before v2.5.0.

## Goals

- Make every installed EJAM version use the correct vintage of large Arrow datasets.
- Avoid hidden dependence on the latest GitHub release in `ejamdata`.
- Make Arrow file provenance, checksums, row counts, schemas, and data vintages auditable.
- Move dynamic Arrow files and other runtime cache files out of the installed package `data/` folder after the v2.5.0 bridge is stable.
- Consider using Arrow-backed access through `dataload_dynamic(..., return_data_table = FALSE)` in more places, but only where profiling shows meaningful speed, memory, or startup benefits.
- Support future storage in either `ejamdata` release assets or a public S3 bucket without changing the conceptual model.
- Make developer testing of release branches such as `ACS2024`, possible `ACS2023`, and a future `v2.32.9` maintenance release predictable.
- Reduce confusion from old names such as `download_latest_arrow_data()` and `ejamdata_version.txt`.

## Dataset Categories

The refactor should preserve the distinction among these groups because they have different update schedules and compatibility rules.

| Category | Meaning | Example files |
| --- | --- | --- |
| Facility Data Updates | Facility and program lookup data that can update independently of ACS/EJScreen annual releases. | `frs`, `frs_by_programid`, `frs_by_naics`, `frs_by_sic`, `frs_by_mact`, NAICS/SIC/MACT metadata |
| EJSCREEN Annual Data Update | Annual EJScreen/EJAM blockgroup indicator outputs that must be pinned to a package or EJScreen release. | `bgej`, possibly other release-coupled annual outputs |
| Blockgroup Geography Updates | Blockgroup identifier, point, population, and weight helpers that change when blockgroup IDs, coordinates, or tract/BG relationships change. | `bgid2fips`, `blockwts`, `bgpts`, `bg_cenpop2020` |
| Block Geography Updates | Block-level helper files that change when block IDs, block coordinates, or block-to-BG mappings change. | `blockpoints`, `quaddata`, `blockid2fips` |

## Naming and Representation Rules

The future refactor should keep these concepts separate:

- logical dataset name: `frs`, `blockwts`, `blockpoints`, `quaddata`, `bgej`, `bgid2fips`, `blockid2fips`
- storage file: `frs.arrow`, `blockwts.arrow`, `bgej.arrow`
- optional Arrow-backed in-memory object: `frs_arrow`, `bgid2fips_arrow`, `blockid2fips_arrow`
- normal in-memory object: `frs`, `blockwts`, `bgej`, usually a `data.table` or data-frame-like object

The base name should remain the standard user-facing and function-facing dataset name. The `_arrow` suffix should only mean "this code path intentionally kept the dataset Arrow-backed instead of reading it fully into memory." A blanket rename from `frs` to `frs_arrow`, or from `blockwts` to `blockwts_arrow`, would be high risk and should not be part of the first refactor.

Important convention:

```r
dataload_dynamic("frs")
```

loads the logical dataset as `frs`, while:

```r
dataload_dynamic("frs", return_data_table = FALSE)
```

loads the Arrow-backed representation as `frs_arrow`. Code should not normally call `dataload_dynamic("frs_arrow")`; it should call the base dataset name and choose the representation with `return_data_table`.

The future implementation should document this clearly in `dataload_dynamic()`, the Arrow dataset vignette material, and any developer notes about `.arrow` files. This is especially important because some current code deliberately uses normal data.table-style objects and a few code paths deliberately use Arrow-backed objects.

## Recommended Future State

### 1. Add an explicit release manifest

Each `ejamdata` release, or future S3 release folder, should include a machine-readable manifest, for example:

```text
ejamdata_release_manifest.json
```

The manifest should be a release asset, not an EJAM package dataset. It should contain at least:

- release tag, such as `v2.5.0`
- compatible EJAM versions or version ranges
- files included in the release
- dataset category for each file
- source system and data vintage for each file
- expected byte size
- SHA256 checksum
- row count and column count
- key columns expected to exist
- schema summary, including column names and basic types
- whether the Arrow file has been checked for safe metadata
- a note that provenance and validation metadata should live in the manifest where possible, not as unsafe R object attributes inside Arrow files
- creation date and maintainer notes

The manifest can later support multiple required tags if FRS files remain independently updateable while `bgej` stays pinned to the EJAM/EJScreen annual release.

### 2. Rename the local marker, with a compatibility bridge

The existing local marker:

```text
data/ejamdata_version.txt
```

should eventually be replaced by a clearer name such as:

```text
data/ejamdata_local_arrow_release_tag.txt
```

Recommended migration:

1. In one release, read the new marker first and fall back to `data/ejamdata_version.txt`.
2. Write both marker files after a successful download or validation.
3. Update documentation to describe the new file and mark `ejamdata_version.txt` as a legacy compatibility marker.
4. In a later release, stop writing the old marker.
5. In a still later release, remove code that reads the old marker.

### 3. Move dynamic Arrow files out of the installed package `data/` folder

Dynamic Arrow files and marker files should eventually stop living in the installed package `data/` folder. That folder is a good home for package-shipped `.rda` datasets, but it is a brittle home for downloaded runtime assets because installed packages may be read-only, may be shared across users, may be replaced during reinstall, and can confuse package checks when nonstandard files appear there.

The current `data/` approach was useful because it made first use of large datasets faster for RStudio users and hosted app deployments, and it avoided bundling very large files inside the package tarball. The replacement should preserve those performance benefits while making the storage location explicit and conventional.

Recommended future local cache root:

```r
tools::R_user_dir("EJAM", which = "cache")
```

with a versioned layout such as:

```text
<EJAM user cache>/
  arrow/
    v2.5.0/
      bgej.arrow
      blockwts.arrow
      blockpoints.arrow
      quaddata.arrow
      bgid2fips.arrow
      blockid2fips.arrow
      frs.arrow
      frs_by_programid.arrow
      frs_by_naics.arrow
      frs_by_sic.arrow
      frs_by_mact.arrow
      ejamdata_local_arrow_release_tag.txt
      ejamdata_release_manifest.json
```

The cache root should be overrideable for hosted deployments and reproducible testing, for example with:

```r
Sys.getenv("EJAM_ARROW_CACHE_DIR")
```

or a package option such as:

```r
options(EJAM.arrow_cache_dir = "/path/to/cache")
```

Recommended search order during the migration:

1. Explicit user or deployment cache directory, if provided.
2. Versioned `tools::R_user_dir("EJAM", "cache")` directory.
3. Legacy installed-package `data/` folder, as a read-only fallback for old installs or source-tree development.
4. Download from the required release tag if allowed and needed.

Recommended write behavior:

- Write new downloads only to the explicit/user cache directory.
- Do not write newly downloaded Arrow files into the installed package `data/` folder after the migration begins.
- Continue to read existing Arrow files from the package `data/` folder during a transition period.
- In source-tree development, allow maintainers to point `EJAM_ARROW_CACHE_DIR` at a local test cache instead of mutating the package `data/` directory.

The package should also provide small helper functions for maintainers and app deployments, such as:

```r
ejam_arrow_cache_dir()
ejam_arrow_cache_status()
ejam_arrow_cache_clear()
```

The clear function should be conservative and should only remove EJAM-managed cache directories for a specific release tag unless the user explicitly asks for broader cleanup.

### 4. Keep Arrow metadata safe and mostly external

The Arrow metadata warning that triggered this planning thread came from unsafe R metadata embedded in some Arrow files, especially `externalptr` metadata from data.table internals such as `.internal.selfref`. Future data creation and upload steps should treat Arrow files as storage for tabular values, not as a place to preserve arbitrary R object attributes.

Recommended rule:

- Use the manifest for provenance, release tags, checksums, source vintage, row counts, and schema expectations.
- If metadata must be stored in an Arrow file, keep it simple, scalar, string-like, and explicitly checked for safe round-tripping.
- Before uploading Arrow assets, run a validation step that reads each file in a clean R session and confirms there are no unsafe metadata warnings.
- Avoid relying on R object attributes of Arrow-loaded objects for release-critical provenance. Use the manifest and package metadata instead.

### 5. Relocate other non-`.rda` runtime files out of `data/`

The same principle applies to non-`.rda` runtime files such as local marker text files and future manifest copies. Package source may still contain scripts, documentation, and package data, but runtime state should not be written into `data/`.

Recommended rule:

- Keep package-shipped datasets in `data/*.rda`.
- Keep package documentation and package-building source files in normal repo locations.
- Keep downloaded Arrow files, local release-tag markers, local manifests, cache status files, and checksum verification outputs in the EJAM cache directory.
- Keep pipeline outputs and validation artifacts in their configured pipeline directory or S3 location, not in package `data/`.

The future manifest workflow should treat `data/ejamdata_version.txt` as a legacy cache marker, not as package data.

### 6. Replace "latest" language in APIs and docs

The existing function name `download_latest_arrow_data()` is misleading once package-pinned tags are used. It can remain as a compatibility wrapper, but future code should prefer a clearer function name such as:

```r
download_required_arrow_data()
```

or:

```r
download_ejamdata_release_assets()
```

The same cleanup should happen in roxygen comments, vignettes, scripts, and user-facing messages. Phrases like "latest-released" should be replaced with "required", "package-pinned", or "manifest-required" where that is what the code actually does.

### 7. Validate assets against the manifest

Add a validator that can be run by maintainers and optionally by package code when a required Arrow dataset is missing or stale. It should check:

- the installed package's required Arrow tag
- local marker tag
- cache directory path
- whether local files are coming from the new cache or the legacy package `data/` folder
- manifest tag
- required asset names
- SHA256 checksums
- row counts
- required columns
- Arrow read success without unsafe metadata warnings
- whether the requested representation is normal in-memory data or Arrow-backed data
- basic universe consistency among related files

For `bgej`, the validator should confirm it matches the expected EJAM/EJScreen release and is compatible with `blockgroupstats`. For block and blockgroup helper files, the validator should report whether their geography universe is identical to, a documented superset of, or incompatible with `blockgroupstats`.

### 8. Profile before converting data.table code paths to Arrow-backed code paths

The old notes identified possible performance opportunities but also a real risk of confusion. Several datasets are stored as `.arrow` files, but most package code expects normal in-memory objects with base names such as `blockwts`, `blockpoints`, `quaddata`, and `frs`. Some code paths use `_arrow` objects, such as `blockid2fips_arrow`, `frs_arrow`, or `frs_by_programid_arrow`.

The future refactor should include a focused audit of which datasets should use the Arrow-backed representation enabled by:

```r
dataload_dynamic("dataset_name", return_data_table = FALSE)
```

This audit should start from the current mixed state:

| Dataset | Current representation pattern to review | Future question |
| --- | --- | --- |
| `blockid2fips` | Already used as `blockid2fips_arrow` in some code paths. | Confirm this is still the right Arrow-backed pattern and whether more lookups should use it. |
| `frs` | Used in both normal in-memory form and Arrow-backed form as `frs_arrow`. | Decide which FRS lookup paths benefit from Arrow filtering before `collect()`. |
| `frs_by_programid` | Used in both normal in-memory form and Arrow-backed form as `frs_by_programid_arrow`. | Standardize program lookup code so it does not unnecessarily load both forms. |
| `frs_by_mact` | Used in a mix of normal and Arrow-backed approaches. | Check whether MACT/subpart lookups should consistently use Arrow-backed filtering. |
| `blockwts` | Stored as Arrow but generally loaded as normal `blockwts`. | Treat as high-risk because weighted aggregation code uses data.table-style joins heavily. |
| `blockpoints` | Stored as Arrow but generally loaded as normal `blockpoints`. | Review spatial search and shape-intersection paths for selective-column or filtered reads. |
| `quaddata` | Stored as Arrow but generally loaded as normal `quaddata`. | Treat as high-risk because it is central to spatial indexing and search. |
| `bgej` | Stored as Arrow but generally loaded as normal `bgej`. | Avoid changing unless profiling shows a clear benefit without affecting user-facing output behavior. |
| `bgid2fips` | Stored as Arrow but generally loaded as normal `bgid2fips`. | Review lookup-only paths where Arrow filtering may help. |
| `frs_by_naics` | Stored as Arrow but generally loaded as normal `frs_by_naics`. | Review NAICS lookup paths, especially if they currently load a large table to return a small subset. |
| `frs_by_sic` | Stored as Arrow but generally loaded as normal `frs_by_sic`. | Review SIC lookup paths, especially if they can filter before loading. |

Do not convert all code to `_arrow` names. Instead:

1. Profile the slow paths first, especially FRS lookups, `getblocksnearby*()`, `get_blockpoints_in_shape()`, `doaggregate()`, and functions using `quaddata` or `blockwts`.
2. Identify code paths where Arrow-native filtering can avoid loading a very large table.
3. Convert only narrow, tested paths where Arrow clearly improves speed or memory use.
4. Ensure each converted path uses one representation consistently and does not load both `frs` and `frs_arrow` unless there is a measured reason.
5. Keep data.table-heavy joins and aggregation code on normal in-memory objects unless Arrow-native code is proven faster and simpler.
6. Prefer small helper functions that hide the representation choice from callers, so normal package code can keep asking for logical datasets such as `frs` or `blockwts`.

Good candidates for future review include:

- `frs_from_sitename()` and other FRS lookup helpers
- `latlon_from_program()` and related program-ID lookups that already use some Arrow-backed inputs
- `blockid2fips` lookups, where Arrow-backed use already exists
- `bgid2fips` and other identifier lookup paths where a small subset is needed
- `frs_by_naics` and `frs_by_sic` lookup paths if they can filter before loading
- block search/indexing paths where reading only selected columns or rows might help

High-risk candidates that need extra caution:

- `blockwts`, because it is used in many data.table-style joins and weighted aggregations
- `quaddata`, because it is central to spatial search and indexing
- `bgej`, because it is release-coupled and feeds user-facing outputs

### 9. Decide whether S3 or `ejamdata` is canonical

Short-term v2.5.0 plan: continue using `ejamdata` release assets.

Longer-term decision: decide whether a public S3 location should become canonical for large Arrow assets. If S3 becomes canonical, `ejamdata` releases should either stop carrying those files or clearly mirror the same manifest and checksums. Avoid a future state where some code silently prefers `ejamdata` and other code silently prefers S3.

Access control must be decided explicitly. Public GitHub release assets in `ejamdata` are downloadable by anyone without AWS credentials. S3 objects are not automatically public just because analogous files are available in `ejamdata`. For S3 to be usable by ordinary EJAM users, one of these must be true:

- the bucket or prefix is public-readable for the required objects
- a public HTTP or CDN layer fronts the S3 objects
- the package obtains presigned URLs from a service
- users have AWS credentials with `s3:GetObject` permission for the relevant bucket and prefix

For a public R package and hosted app, the first two options are simplest operationally. Presigned URLs or user-specific AWS credentials add complexity and should be avoided for ordinary package use unless there is a strong security or governance reason.

### 10. Keep package data and dynamic data roles distinct

Datasets stored in EJAM's package `data/` directory are already version-specific because they ship with the package. Large Arrow files are dynamic external assets and need explicit release-tag handling.

The future design should document which files are:

- package datasets shipped in `data/*.rda`
- external Arrow release assets cached locally
- pipeline outputs stored on S3
- temporary pipeline checkpoints

This should be reflected in the release checklist and annual dataset update vignette.

## Migration Tests to Add

Before replacing the bridge with the full manifest workflow, add tests for these scenarios:

- EJAM v2.5.0 requires `ejamdata_required_tag: v2.5.0`.
- A maintenance release such as EJAM v2.32.9 can require `ejamdata_required_tag: v2.32.8.001`.
- Offline mode succeeds when required files exist and the local marker matches.
- Offline mode fails clearly when the marker is stale.
- Missing local files trigger download when network access is available.
- Manifest checksum mismatch fails clearly and does not silently use the asset.
- A custom `EJAM_ARROW_CACHE_DIR` is respected for reads and writes.
- The new user cache is preferred over the legacy package `data/` folder when both contain the same release tag.
- The legacy package `data/` folder remains readable during the migration.
- Package code does not write new Arrow files or marker files into the installed package `data/` folder after the cache migration is enabled.
- `dataload_dynamic("frs")` and `dataload_dynamic("frs", return_data_table = FALSE)` resolve the same storage asset but create different intended in-memory representations.
- Code does not treat `frs_arrow` or another `_arrow` name as the normal logical dataset name.
- Arrow files with unsafe R metadata fail validation before they are uploaded as release assets.
- A user or maintainer override is explicit, logged, and documented.
- FRS files can be tested separately if they are allowed to update on a different schedule from `bgej`.

## Documentation to Update in the Refactor

Update these files after the manifest design is implemented:

- `DESCRIPTION`
- `R/arrow_ds_names.R`
- `R/download_latest_arrow_data.R`
- `R/dataload_dynamic.R`
- `R/data_ejamdata_version.R`
- any new cache helper file, such as `R/arrow_cache_dir.R`
- FRS lookup helpers if any are converted to Arrow-backed code paths after profiling
- block lookup/indexing helpers if any are converted to Arrow-backed code paths after profiling
- `vignettes/dev-update-datasets.Rmd`
- `vignettes/dev-update-ejscreen-datasets-yearly.Rmd`
- `vignettes/dev-update-package.Rmd`
- the release checklist or handoff note used for v2.5.0 and later releases

The documentation should explicitly tell maintainers to check:

- `DESCRIPTION` package version
- `DESCRIPTION` `ejamdata_required_tag`
- the `ejamdata` or S3 release manifest
- the asset list and checksums
- package metadata attributes for shipped `.rda` datasets
- local Arrow marker behavior
- the local Arrow cache directory
- whether the current run is using the new cache or the legacy package `data/` fallback
- the distinction between storage files, logical dataset names, and `_arrow` in-memory objects

## Suggested Timing

Do not make the full manifest/cache/S3 refactor a blocker for v2.5.0 unless the v2.5.0 bridge fails. The safer path is:

1. Finish and release v2.5.0 with package-pinned Arrow tags.
2. Create a separate branch from `ACS2024` or `development`, for example `arrow-manifest-refactor`.
3. Add manifest creation and validation without changing storage location.
4. Add marker rename compatibility.
5. Add cache helper functions and support reading from a versioned user cache before the legacy package `data/` folder.
6. Stop writing new Arrow files and marker files into the installed package `data/` folder.
7. Update documentation and release checklist.
8. Profile selected slow paths before making any `_arrow` representation changes.
9. Decide whether to migrate from `ejamdata` release assets to public S3.
10. Only then consider changing the canonical storage backend.

## Key Decisions to Confirm Before Implementation

These are the highest-risk or most consequential choices to confirm before turning this plan into code.

### 1. Local cache location for Arrow files

The plan recommends moving dynamic Arrow files out of the installed package `data/` folder and into a versioned cache, probably based on:

```r
tools::R_user_dir("EJAM", "cache")
```

Confirm:

- Should normal R users use an OS/user cache directory by default?
- Should the hosted app use that same default, or should it use a deployment-specific fixed cache path?
- Should source-tree development ever write downloaded Arrow files to `EJAM/data/`, or should that stop entirely after v2.5.0?

### 2. One required Arrow tag or category-specific tags

The simplest design is one `DESCRIPTION` field, `ejamdata_required_tag`, used for all Arrow files. A more flexible design would allow category-specific required tags, especially if FRS files remain independently updateable while `bgej` and block geography files stay pinned to annual EJAM/EJScreen releases.

Confirm:

- Is one required tag for all Arrow files good enough for the next refactor?
- Is independent FRS updating important enough to justify category-specific tags?
- If category-specific tags are needed, should they live in `DESCRIPTION`, the manifest, or both?

### 3. Canonical storage backend

The v2.5.0 bridge keeps using public `ejamdata` GitHub release assets. The longer-term plan leaves open whether S3 should become canonical.

Confirm:

- Are public GitHub release assets acceptable long term?
- If S3 becomes canonical, will the bucket or prefix be public-readable or CDN-backed?
- Should `ejamdata` remain a mirror during any S3 transition?
- Should ordinary package users ever need AWS credentials? The preferred answer is no unless there is a strong governance reason.

### 4. Automatic validation depth

Deep manifest validation is useful but can slow startup or first use if it checks hashes, schemas, row counts, and file metadata every time.

Confirm:

- On package attach, should EJAM only check tag and file presence?
- Should checksum/schema/row-count validation be an explicit maintainer command?
- Should user-facing functions trigger deeper validation only when a file is missing, stale, or newly downloaded?

### 5. API naming and compatibility

The name `download_latest_arrow_data()` is now misleading because normal behavior should use the package-pinned required release tag, not GitHub latest.

Confirm:

- Should `download_latest_arrow_data()` remain as a compatibility wrapper?
- Should a clearer function such as `download_required_arrow_data()` or `download_ejamdata_release_assets()` become the preferred internal name?
- Are breaking changes acceptable after v2.5.0, or should this remain backward-compatible for at least one release cycle?

### 6. Normal data.table objects versus `_arrow` objects

The plan recommends preserving base dataset names such as `frs`, `blockwts`, and `bgej` as the normal logical names, and using `_arrow` only for intentionally Arrow-backed in-memory objects.

Confirm:

- Should `_arrow` conversions be treated only as performance work after profiling?
- Should base names remain the normal user-facing and function-facing dataset names?
- Should any high-traffic lookup paths be prioritized for profiling, such as FRS lookups, `blockid2fips`, or block search helpers?

## Open Questions

- Should FRS-related Arrow files remain independently updateable, or should they also be pinned to each EJAM release for simplicity?
- If FRS remains independently updateable, should `DESCRIPTION` support one required tag per dataset category?
- Should `tools::R_user_dir("EJAM", "cache")` be the default cache root, or does the hosted app need a different default?
- Should the package expose both an environment variable and an option for cache root overrides?
- How long should the package continue reading legacy Arrow files from the installed package `data/` folder?
- Should the package ever write downloaded Arrow assets into a source-tree `data/` folder during development, or should maintainers always use an explicit cache directory?
- Which current slow paths, if any, are worth converting from normal in-memory data.table objects to Arrow-backed objects?
- If S3 becomes canonical, should access be fully public, CDN-backed, presigned, or credential-based?
- Should package startup validate only marker tags, or should deeper manifest validation be an explicit maintainer command?
- If S3 becomes canonical, should `ejamdata` release assets remain as mirrors during a transition period?
