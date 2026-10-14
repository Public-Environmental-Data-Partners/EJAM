# Verbatim mirror of the EJAM-API repo — DO NOT HAND-EDIT

The files in this folder are byte-for-byte copies from
<https://github.com/Public-Environmental-Data-Partners/EJAM-API> (normally the `main` branch; see the pending upstream PR below):

- `rest_controller.r`    — the API route definitions (the production API)
- `query_pagination.R`   — /query pagination helpers, `source()`d by rest_controller.r
- `assets/`              — static files served at `/assets`

**Synced from commit:** `de27a1c777920642ff61e414c520d88c2131b29a` (2026-10-14)

**Pending upstream:** [EJAM-API#61](https://github.com/Public-Environmental-Data-Partners/EJAM-API/pull/61), branch `codex/zip-analysis-662`. Merge that PR first, then refresh this provenance to the merged `main` commit and verify bytes before merging this companion change. Until then, the main-branch drift check is expected to differ.

NOTE: `rest_controller.r` does `source("query_pagination.R")` and `@assets ./assets`
with paths relative to its own directory (the Docker WORKDIR in production), so callers
must `plumber::plumb()` it with the working directory set to THIS folder —
`ejamapi_local()` and `inst/plumber/plumber.R` do this for you.

## Why a verbatim copy

`EJAM::ejamapi_local()` runs this file as the root router so the package can serve the
*same* API locally that is deployed at <https://api.ejanalysis.com> — a stand-in dev server,
since EJAM-API itself has no staging deployment. Because the copy is byte-identical, a plain
`diff` against the EJAM-API repo is always meaningful, and proposed EJAM-API changes can be
developed and tested here, then submitted as an identical diff to the EJAM-API repo.

Draft/experimental endpoints that exist only in the EJAM package live separately in
`../draft/plumber.R` and are mounted at `/draft/...` — never edit this folder to add them.

## How to re-sync (3 steps, from a local EJAM-API clone kept next to this repo)

```sh
git -C ../EJAM-API fetch origin
git -C ../EJAM-API show origin/main:rest_controller.r > inst/plumber/ejam-api/rest_controller.r
git -C ../EJAM-API show origin/main:query_pagination.R > inst/plumber/ejam-api/query_pagination.R
git -C ../EJAM-API show origin/main:assets/communityreport.css > inst/plumber/ejam-api/assets/communityreport.css
git -C ../EJAM-API show origin/main:assets/www/EPA_logo_white_2.png > inst/plumber/ejam-api/assets/www/EPA_logo_white_2.png
git -C ../EJAM-API rev-parse origin/main   # record this SHA above
```

If upstream adds/renames files (check `git -C ../EJAM-API ls-tree --name-only -r origin/main`
for new `.r`/`.R` files or assets referenced by rest_controller.r), mirror those too and
extend this list. (Upstream's `Dockerfile`, `main.r`, `tests/`, and docs are NOT needed here.)

Then update the commit SHA in this file and run the plumber tests
(`tests/testthat/test-plumber-api.R`). A drift-check test in that file compares this copy
against the EJAM-API repo's `main` on GitHub and fails when the mirror is stale.
