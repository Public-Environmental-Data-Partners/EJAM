# Plan: Reconcile EJAM `inst/plumber/` with the EJAM-API repo

**Goal:** Make the EJAM package's plumber folder an up-to-date, locally runnable mirror of the
live EJAM-API endpoints, **without losing any of the draft endpoints and tooling** that exist
only in the EJAM repo, and **without changing the EJAM-API repo at all**. Deliverable is one
draft PR to EJAM's `development` branch.

**Why:** There is no dev/staging server for the EJAM-API (it is prod-only, Docker-deployed by
Eric/PEDP, and Mark lacks deploy credentials). Running the mirrored code locally via
`ejamapi_local()` becomes the de-facto dev server: preview how the EJAM-API will behave after a
proposed code edit, *before* anyone deploys it.

---

## 1. What exists today (inventory)

### EJAM-API repo (`../EJAM-API`, sync from **origin/main**, currently commit `8ca7869`)

> Note: the local clone's `main` is 1 commit behind origin (missing `8ca7869`, PR
> Public-Environmental-Data-Partners/EJAM-API#49, radius-0 defaults for FIPS/shape). Sync must
> copy from `origin/main`, not the local checkout.

- `rest_controller.r` (597 lines) — the production API. Endpoints & features:
  - `cors` filter (CORS + OPTIONS preflight)
  - `GET /` → 302 redirect to `/__docs__/` (Swagger UI)
  - `POST /data` — analysis data as JSON (sites/shape/fips, geometries, scale, radius alias)
  - `POST /query` — blockgroups filtered by attribute percentile cutoff
  - `GET /report` — multisite-capable (comma-separated lat/lon/fips), pdf **and** html,
    per-method buffer defaults (3 for points, 0 for fips/shape), `radius` alias,
    `normalize_sitenumber()` (0/"overall"/N with strict 400 on junk), `sitenumber_label`
    "Site N" pass-through (EJAM#470 / EJAM-API#51), zero-population fail-safe
    (EJAM-API#48), `escape_html()`/`html_error()` hardened error pages, edge-cache headers
    (`public, max-age=86400` on GET, `no-store` on errors/POST)
  - `POST /report` — same engine, JSON body, no URL-length limit
  - `POST /handoff` + `GET /handoff/<token>` — token-based site handoff for EJScreen→EJAM app
    launch (CSPRNG tokens via openssl, TTL, capacity/payload limits)
  - `@assets ./assets /assets` — static css/logo (mounted at /assets, NOT root, so Swagger works)
- `main.r` — 4 lines: `plumb("rest_controller.r")$run(port=8080, host="0.0.0.0")` (Docker entry)
- `assets/communityreport.css`, `assets/www/EPA_logo_white_2.png`
- `Dockerfile`, `tests/tests.ipynb`, `tests/houston_zips.json` (not needed in EJAM)

### EJAM package `inst/plumber/` (1,094-line `plumber.R` + `try_the_api.R`)

- **Stale partial copies of EJAM-API code** (to be replaced by the mirror):
  - helpers `handle_error()` (no HTML escaping), `fipper()`, `ejamit_interface()`
  - `GET /report` — older port: html-only serializer, no POST twin, no pdf, no caching, weaker
    sitenumber validation, no zero-pop fail-safe, no CORS (it does already have the
    EJAM#470 `sitenumber_label` logic)
  - `POST /data` and `@assets` — present but disabled inside `if (FALSE)` blocks
- **Draft-only work to RETAIN** (exists nowhere in EJAM-API):
  - `GET /dataset` — serve any EJAM .rda/.arrow dataset
  - `POST /report2` — full `ejamit()` parameter surface (~40 params) → html report
  - `POST /reportpost` — ejamit+ejam2report draft
  - `POST /ejam2report` — report from a supplied ejamit output object
  - `POST /ejam2excel` — xlsx output
  - `GET /ejamit_csv` — csv of results_overall (future::future draft)
  - `GET /ejamit` — json of results_overall
  - `GET /getblocksnearby` — block distances (works for 1 point)
  - `POST /get_blockpoints_in_shape`, `GET /doaggregate`, `GET /echo`
  - `logger` filter (writes `log_api_usage.txt`)
  - helper converters `NULL_if_empty()`, `TRUEFALSE_if_truefalse()`, `api2rnulltf()`
  - startup preload: `dataload_dynamic("blockwts")` + `indexblocks()`
- `try_the_api.R` — local-testing notes/snippets (retain, refresh)
- Related R/ functions: `ejamapi_local()` (runs plumber.R via callr background process),
  `ejamapi()` (client for the live API), `url_ejamapi()` (URL builder)

### Route conflicts between the two sets
Only **`GET /report`** is live in both (the EJAM draft version is strictly older/weaker — it is
exactly what "bring up to date" should replace). `/data` and `/assets` conflicts are moot
(disabled in EJAM today). Everything else is disjoint.

---

## 2. Chosen design: two routers — verbatim mirror + mounted drafts

Do **not** hand-merge into one file. Split `inst/plumber/` into:

```
inst/plumber/
  ejam-api/
    rest_controller.r      <- BYTE-FOR-BYTE copy of EJAM-API origin/main rest_controller.r
    assets/                <- copy of EJAM-API assets/ (css + logo)
    SYNC.md                <- synced-from commit SHA + 3-step re-sync instructions
  draft/
    plumber.R              <- draft-only endpoints (list above), duplicated code removed
  plumber.R                <- thin launcher kept for back-compat (see below) OR removed
  try_the_api.R            <- retained, notes refreshed
```

`ejamapi_local()` composes them:

```r
pr_api   <- plumber::plumb(system.file("plumber/ejam-api/rest_controller.r", package = "EJAM"))
pr_draft <- plumber::plumb(system.file("plumber/draft/plumber.R", package = "EJAM"))
pr_api$mount("/draft", pr_draft)
pr_api$run(host = host, port = port)
```

So locally:
- `http://127.0.0.1:3035/report?...`, `/data`, `/query`, `/handoff`, `/__docs__/` behave
  **exactly like the production API paths** (preview fidelity — the whole point), and
- every draft endpoint survives at `/draft/dataset`, `/draft/report2`, `/draft/echo`, ... with
  zero possibility of route collision, now or after any future sync.

### Why this beats the alternatives
- **Single merged plumber.R** (status quo shape): every future EJAM-API change requires a
  careful hand-merge; the stale-drift problem this task is fixing simply recurs. Rejected.
- **Mount the API mirror under `/api`**: local URLs would not match prod paths, so
  `url_ejamapi(baseurl=...)`-built URLs and copy-pasted prod URLs wouldn't preview cleanly.
  Rejected — drafts move aside instead, because drafts have no prod contract to preserve.

### The sync contract (why "verbatim" matters)
`ejam-api/rest_controller.r` is **never hand-edited** in EJAM. Future syncs are:
1. `git -C ../EJAM-API fetch origin`
2. `git -C ../EJAM-API show origin/main:rest_controller.r > inst/plumber/ejam-api/rest_controller.r`
   (and same for `assets/`)
3. Update the SHA in `SYNC.md`, run the plumber tests.

And in the other direction (proposing an EJAM-API change): edit the mirror copy locally, test
via `ejamapi_local()`, then submit the *identical* diff as an EJAM-API PR for Eric to review and
deploy. Because the file is byte-identical, `diff` between the two repos is always meaningful.
(Per standing policy: never push to EJAM-API without explicit approval — this plan only ever
*reads* from it.)

---

## 3. Concrete changes in the EJAM PR

1. **Add** `inst/plumber/ejam-api/rest_controller.r` + `assets/` copied from EJAM-API
   `origin/main` (`8ca7869`), plus `SYNC.md` recording that SHA.
2. **Create** `inst/plumber/draft/plumber.R` containing only the draft-only endpoints, the
   `api2rnulltf()` helper family, and the logger filter. Delete from it the now-redundant
   stale copies: old `GET /report`, disabled `/data` + `/assets` blocks, `handle_error()`,
   `fipper()`, `ejamit_interface()` (the mirror provides the live versions; drafts that call
   `handle_error()` keep one small local copy or source the mirror's — decide during
   implementation, preferring a tiny local helper so the mirror stays untouched).
3. **Move startup preload out of the route file**: `dataload_dynamic("blockwts")` /
   `indexblocks()` move into `ejamapi_local()` (before `plumb()`), since the mirrored
   rest_controller.r must stay verbatim and doesn't do preloads.
4. **Rewrite `ejamapi_local()`** to plumb + mount as in §2, keeping the existing
   callr-background behavior, host/port defaults, and the `/__docs__/` startup message. Add a
   `drafts = TRUE` arg to optionally skip mounting drafts (pure prod preview).
5. **`inst/plumber/plumber.R`**: replace with a small file that plumbs the mirror and mounts
   drafts (so RStudio's "Run API" button on that file still works), or delete it and update all
   references (`ejamapi_local()` default `fname`, `try_the_api.R`, any vignettes). Prefer the
   thin launcher for least breakage; note plumber annotations can't express mounting, so this
   launcher is an entrypoint script (`plumber.R` calling `pr_mount`) rather than an annotated
   route file — verify RStudio button behavior, else document `ejamapi_local()` as the way in.
6. **DESCRIPTION**: add `openssl` to Suggests (handoff token minting); confirm `plumber`,
   `geojsonsf`, `jsonlite`, `sf`, `callr`, `beepr` remain covered (they are today).
7. **`try_the_api.R`**: refresh notes — new paths, `/draft/` prefix, example curl/httr2 calls
   for `/report` (pdf + html), `POST /report`, `POST /handoff` round-trip.
8. **Tests** (new `tests/testthat/test-plumber-api.R`):
   - both files `plumber::plumb()` without error (parse check, no server start);
   - route inventory: mirror router exposes `/data /query /report /handoff` etc.; mounted
     router exposes `/draft/...`; no duplicate routes;
   - drift check: `skip_if_offline()`, fetch raw `rest_controller.r` from GitHub main and
     compare to the shipped copy — fails loudly when EJAM-API has moved on;
   - **update `R/test_ejam.R` group lists + timing** (required whenever a test file is added).
9. **Docs**: short section in the dev-api / API vignette: "Run the API locally" (ejamapi_local,
   what mirrors prod, what's draft, how to propose an EJAM-API change from here).

### Gotchas to verify during implementation
- **`@assets ./assets /assets` relative path**: confirm plumber resolves it against the plumber
  file's directory when plumbed from `inst/plumber/ejam-api/`. If it resolves against `getwd()`
  instead, fix inside `ejamapi_local()` (temporarily `setwd()` to the file's dir around
  `plumb()`, or `pr_static()` the absolute path on the composed router) — never by editing the
  mirrored file.
- **logger file location**: draft logger writes `log_api_usage.txt` to cwd; point it at
  `tempdir()` (draft file is ours to improve).
- **Behavior change to flag in the PR description**: local `GET /report` default output for a
  single site becomes **pdf** (prod behavior) instead of the old draft's html. That's the
  point of the sync, but anyone using the local draft endpoint should know; html is one
  `fileextension=html` away.
- Local PDF rendering needs `RSTUDIO_PANDOC` set when running from a shell (existing
  local-R-from-shell note applies).
- No local-machine paths in any committed file.

---

## 4. Verification (before marking the PR ready)

Manual smoke test via `ejamapi_local()` against these, comparing where possible with the same
request against the live API (`https://api.ejanalysis.com/...`):

| Check | Request |
|---|---|
| Swagger docs | `GET /` redirects to `/__docs__/` |
| Single-site pdf report | `GET /report?lat=34.05&lon=-118.24` |
| Multisite html report | `GET /report?lat=34,35&lon=-118,-117&sitenumber=0` |
| Site-N label (EJAM#470) | `GET /report?lat=34.05&lon=-118.24&sitenumber=3` header says "Site 3" |
| Zero-pop fail-safe | `GET /report?lat=33&lon=-112&buffer=1` (real report or clear 500 page, never 1-byte 200) |
| FIPS radius-0 default (EJAM-API#49) | `GET /report?fips=10001` |
| POST /report | JSON body with polygons |
| Data endpoint | `POST /data` sites + geometries |
| Query endpoint | `POST /query?attribute=pctlowinc&value=0.9` |
| Handoff round trip | `POST /handoff` → token → `GET /handoff/<token>` |
| CORS preflight | `OPTIONS /handoff` returns the CORS headers |
| Drafts intact | `GET /draft/echo?msg=hi`, `GET /draft/getblocksnearby?...`, `GET /draft/dataset` |

Plus `R CMD check` / the plumber test group in `test_ejam()`.

## 5. PR mechanics

- Branch off `development` (suggest `plumber-sync-ejam-api`, worktree `../EJAM-plumber-sync`
  optional), **draft** PR into `development`.
- Cross-repo refs written as `Public-Environmental-Data-Partners/EJAM-API#NN`.
- Milestone: ask Mark (v3.2022.2 vs v4) — this is dev-tooling + inst/ files only, no exported
  behavior change to the package's R functions except `ejamapi_local()` internals.
- EJAM-API repo: **zero changes** in this effort (read-only source of truth).

## 6. Out of scope (explicitly deferred)

- Promoting any draft endpoint into the real EJAM-API.
- The multi-version `?version=` API plan, R2 write-back caching (#446), and in-app rendering
  (#476) — unrelated tracks.
- Automating the sync (a GH Action could diff the mirror against EJAM-API main and open an
  issue; nice-to-have later).
