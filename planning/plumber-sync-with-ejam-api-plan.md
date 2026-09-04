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

## 0a. Decisions & implementation status (2026-07-24)

**Mark's decisions:** milestone **v4**; **keep ALL draft endpoints and repair them in this PR**
(none dropped); no worktrees; out-of-scope items in §6 stay deferred but tracked.

**IMPLEMENTED on branch `API-in-EJAM`** (all items in §3, plus repairs to every draft
endpoint). Verified locally end-to-end: parse/route-inventory/drift tests
(`test-plumber-api.R`, 12 passing), gated server smoke tests (`test-ejamapi_local.R`,
18 passing, `EJAM_TEST_LOCAL_API=true`), and a manual smoke of the heavy endpoints —
single-site html report (~4s), **"Site 3" header label live locally** (EJAM#470 ×
EJAM-API#51 working together pre-deploy, as §0 predicted), multisite report, `/query`
pagination envelope + 400 on bad input, `/data` (with `scale`), `/handoff` round trip
(returns explicit `radius=0` per EJAM-API#49), CORS preflight, `/assets` files, all
`/draft/...` endpoints incl. a 1.4MB working xlsx from `/draft/ejam2excel`, and the
**zero-population report case renders a real report locally** (EJAM#468 + EJAM-API#48
verified end-to-end before any deploy).

Implementation findings (things learned that the plan didn't know):
- EJAM-API#32 split helpers into a **new upstream file `query_pagination.R`**, `source()`d by
  rest_controller.r with a cwd-relative path — the mirror now includes it, and SYNC.md's
  re-sync recipe copies it and warns to check for new upstream files.
- plumber's `@assets ./assets` resolves **at request time against the process cwd** (not the
  plumber file's folder), so the serving process must run with cwd = the mirror folder —
  `ejamapi_local()` runs the server in a dedicated background process with its cwd set there
  for its lifetime (the exact analog of the Docker WORKDIR in production).
- A `#* @plumber` hook must return the SAME router it was passed; composition therefore
  nests the draft mount inside the mirror router, then mounts that at `/` (verified: mounted
  routes appear in the Swagger docs).
- The old draft file's `attachment == "true"` checks were silently always-FALSE after
  `api2rnulltf()` converted values to logical (R: `TRUE == "true"` is FALSE) — fixed with an
  `api_true()` helper; `@serializer excel` was not a real plumber serializer (the old
  combined file could not even plumb) — `/draft/ejam2excel` now streams a real xlsx via
  `@serializer contentType`.
- **Upstream hardening candidate (out of scope here, mirror stays verbatim):** a location
  where NO census blocks fall inside the buffer (e.g. `lat=33.9&lon=-112.35&buffer=1`)
  makes `ejamit()` (dev EJAM) return empty → `ejam2report()` errors uncaught → plumber's
  generic JSON 500 instead of EJAM-API#48's friendly HTML fail-safe. Distinct from the
  zero-population-with-blocks case, which works. Worth proposing upstream later.

## 0b. Status snapshot (updated 2026-07-24 — see also `planning/api-in-ejam-handoff-2026-07-24.md`)

- **The mirror target is a moving file.** When this plan was drafted (2026-07-23) EJAM-API
  `origin/main` was `8ca7869`; as of 2026-07-24 it is **`08dc3a7`**, which additionally merges
  PR Public-Environmental-Data-Partners/EJAM-API#32: **`POST /query` pagination** —
  `page`/`limit` params (max 500/page), a `{results, pagination}` envelope instead of a bare
  list, and 400 on bad input (closes EJAM-API#37). Recent history of main:
  `08dc3a7` (#32 query pagination) → `8ca7869` (#49 buffer defaults 0 for fips/shape) →
  `0518bc9` (#51 Site-N label + normalize_sitenumber) → `6659786` (#48 zero-pop fail-safe).
  **Re-export from `origin/main` at implementation time; never trust a stale local checkout.**
- **Live API lags main.** A 2026-07-24 verification session found `api.ejanalysis.com`
  byte-identical to main *as of `0518bc9`*; #49 and #32 merged after that and #48 was verified
  NOT yet deployed. So the local mirror will be **ahead of prod and equal to main** — that is
  the intent (mirror tracks the repo, not the deployment).
- **Deployed EJAM pin is `EJAM_VERSION=v3.2022.1`**, so the merged `sitenumber_label` code in
  rest_controller.r is formals-guarded and **dormant in prod** until the pin advances to a
  release containing EJAM#470. Locally, running the mirror against the current EJAM
  `development` (which has #470 merged) exercises the "Site N" path *today* — a concrete
  benefit of this plan's local preview.
- The map-popup residual flagged in earlier notes ("header says Site 5 but popup says Site 1")
  is **verified resolved on `development`**: `sitenumber_label` threads through
  `ejam2report()` → `ejam2map()`/`mapfastej()` → `popup_from_ejscreen()`.
- **No worktrees** (standing preference): all work happens on branch `API-in-EJAM` in the main
  checkout. Branch exists on origin.
- Known draft-endpoint defects to address (or drop) when splitting out `draft/plumber.R`:
  `/ejam2report` has a `future({})` bug (`out` assigned inside the future, never returned);
  `/ejamit` shapefile path "not working yet"; `/get_blockpoints_in_shape` broken;
  `/getblocksnearby` works for 1 point only. Which drafts ship at `/draft` vs get dropped is a
  decision for Mark before implementation (§3 item 2).

## 1. What exists today (inventory)

### EJAM-API repo (`../EJAM-API`, sync from **origin/main** — `08dc3a7` as of 2026-07-24)

> Note: sync must copy from `origin/main` after a fresh `git fetch`, never from the local
> checkout, which has repeatedly been found stale. The endpoint description below reflects
> `8ca7869`; `08dc3a7` additionally changes `POST /query` as described in §0.

- `rest_controller.r` (597 lines) — the production API. Endpoints & features:
  - `cors` filter (CORS + OPTIONS preflight)
  - `GET /` → 302 redirect to `/__docs__/` (Swagger UI)
  - `POST /data` — analysis data as JSON (sites/shape/fips, geometries, scale, radius alias)
  - `POST /query` — blockgroups filtered by attribute percentile cutoff (as of `08dc3a7`:
    paginated — `page`/`limit` ≤ 500, `{results, pagination}` envelope, 400 on bad input)
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
- every draft endpoint survives at `/draft/report2`, `/draft/echo`, ... with
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
   `origin/main` **at whatever SHA it is when implementation starts** (`08dc3a7` as of
   2026-07-24 — re-fetch first), plus `SYNC.md` recording that SHA.
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
| Query endpoint | `POST /query?attribute=pctlowinc&value=0.9` — expect `{results, pagination}` envelope; also try `page=2&limit=100` and a bad `value` (expect 400) |
| Handoff round trip | `POST /handoff` → token → `GET /handoff/<token>` |
| CORS preflight | `OPTIONS /handoff` returns the CORS headers |
| Drafts intact | `GET /draft/echo?msg=hi`, `GET /draft/getblocksnearby?...` |

Plus `R CMD check` / the plumber test group in `test_ejam()`.

## 5. PR mechanics

- Branch: **`API-in-EJAM`** (already created off `development`, in the main checkout — no
  worktrees). **Draft** PR into `development`.
- Cross-repo refs written as `Public-Environmental-Data-Partners/EJAM-API#NN`.
- Milestone: **v4** (Mark, 2026-07-24) — this is dev-tooling + inst/ files only, no exported
  behavior change to the package's R functions except `ejamapi_local()` internals.
- EJAM-API repo: **zero changes** in this effort (read-only source of truth).

## 6. Out of scope (explicitly deferred — tracked, per Mark, so they are not forgotten)

- Promoting any draft endpoint into the real EJAM-API.
- The multi-version `?version=` API plan, R2 write-back caching (#446), and in-app rendering
  (#476) — unrelated tracks.
- Automating the sync (a GH Action could diff the mirror against EJAM-API main and open an
  issue; nice-to-have later — the drift-check test in `test-plumber-api.R` covers this
  manually for now).
- Upstream EJAM-API hardening for the "no census blocks in buffer" 500 (see §0a findings).
- §7 below: configuring the EJAM Shiny app to use a local/draft API — steps 1–2 (the
  `EJAM_API_BASEURL` / `options(ejam.api.baseurl)` override + docs) implemented 2026-07-24;
  the dev-server variant (step 3) still pending, gated on a reachable draft API deployment.
- §8 below: exposing more `ejamit()`/`ejam2report()` parameters through the endpoints
  (draft-first, then upstream) — tracked as Public-Environmental-Data-Partners/EJAM-API#52.

## 7. Adjunct (planning only, per Mark 2026-07-24): test the EJAM app against a draft API

**Goal:** be able to test EJAM Shiny-app release candidates — run locally and/or on the app
dev server (<https://ejamdev.ejanalysis.com>) — configured to use (a) the locally hosted
latest draft of the main API endpoints, and/or (b) the `/draft` endpoints, instead of the
production API at api.ejanalysis.com.

**Where the app touches the API today (small surface, good news):** the app itself computes
results in-process via `ejamit()` — it does NOT call the API for analysis. The API base URL
matters only where the app *builds URLs pointing at the API*: per-site report links in
results tables and map popups (via `url_ejamapi()`), and anything else routed through
`url_package("api")`, which reads the canonical URL from the `DESCRIPTION` `Config/` URLs
(EJAM#485 single-sourcing). The EJScreen→EJAM token handoff calls `GET /handoff/<token>` on
the API from the app at launch.

**Mechanism (steps 1–2 IMPLEMENTED 2026-07-24, same branch/PR):**
1. ✅ **DONE** — `url_package("api")` now honors `options(ejam.api.baseurl)` (highest
   precedence), then env var `EJAM_API_BASEURL`, then DESCRIPTION as before. Applies only
   to the canonical `desc` lookup (alias/redirect lookups unaffected); trailing slash
   stripped like the DESCRIPTION path. Tests added in `test-url_package.R` (env override +
   only-api scoping, option-beats-env precedence, and flow-through to `url_ejamapi()`
   report links). Documented in the roxygen for `url_package()`, a new
   **"Testing against a local or draft API"** section of `vignettes/dev-deployment.Rmd`
   (the hosting/deploy article), and a pointer in `vignettes/dev-api.Rmd`.
2. ✅ **DONE (documented)** — local app + local API: `ejamapi_local()` +
   `EJAM_API_BASEURL=http://127.0.0.1:3035` + `run_app()`; report links in tables/popups
   then exercise the draft API end to end. (Verified at the URL-construction layer by the
   new tests; a full manual app-click-through is listed in §4-style verification for the
   PR review.)
3. **Dev-server app + draft API (still pending):** the AWS-hosted dev app cannot reach a
   laptop's localhost. Options: (a) point dev app's `EJAM_API_BASEURL` env (ECS task
   definition) at any reachable draft API deployment — note
   Public-Environmental-Data-Partners/EJAM-API#47 tracks standing up a real
   apidev.ejanalysis.com staging service, the natural target; (b) expose a local API
   temporarily via a Cloudflare tunnel (`cloudflared`); (c) plumber sidecar in the dev app
   task (heavier). The override honors whatever URL is used, so only the hosting question
   remains.
4. Using the `/draft` endpoints from the app would additionally need the app to build
   `/draft/...` paths — only relevant once a draft endpoint has an app use case; defer.

## 8. Adjunct plan (Mark 2026-07-24): expose more function parameters through the API endpoints

**Goal:** each key endpoint should accept most or all of the *appropriate* parameters of
the function it wraps — e.g. pass any relevant `ejamit()` parameter to the ejamit-style
endpoints, and `ejam2report()` display parameters to the report endpoints — so API users
get (nearly) the flexibility R users have.

**Where this idea is already recorded:** no dedicated GitHub issue found (searched both
repos 2026-07-24); the canonical statement is in `vignettes/dev-future-plans.Rmd` ("A
future, expanded API is likely to provide … allowing the API to use most or all of the
same parameters as the functions `ejamit()` and `ejam2report()`"). Related:
Public-Environmental-Data-Partners/EJAM-API#4 (create different endpoints) and
Public-Environmental-Data-Partners/EJAM-API#12 (GET /report accepting a zipped-shapefile
URL — one specific new parameter). **Tracking issue FILED 2026-07-24 (with Mark's OK):
Public-Environmental-Data-Partners/EJAM-API#52.**

**Approach (draft-first, then upstream):**
1. Inventory `formals(ejamit)` and `formals(ejam2report)` and classify each parameter:
   HTTP-safe scalars/vectors (radius/donut, subgroups_type, include_ejindexes,
   calculate_ratios, extra_demog, thresholds, show* toggles, analysis_title, …) vs
   NOT-exposable (functions/callbacks like updateProgress, shiny-session things,
   in_shiny, quadtree objects, connections). The whitelist becomes the endpoint contract.
2. Prototype on the `/draft` router first (that is what it is for): `/draft/report2`
   already exposes ~15 `ejamit()` params and is the working prototype; extend it and
   `/draft/ejamit` to the full whitelist, converting inputs with the `api2rnulltf()` /
   `api_true()` helper family, and document each param in the plumber annotations so the
   Swagger page at /__docs__/ shows them.
3. Tests: parameterized tests that each whitelisted param round-trips (at least: accepted
   without error, and a spot-check that a few visibly change output, e.g.
   `include_ejindexes`, `subgroups_type`, thresholds).
4. Once proven at `/draft`, propose the same expansion upstream for the production
   `GET/POST /report` and `POST /data` endpoints via the mirror-edit → EJAM-API PR
   workflow (§2 sync contract). Keep GET URLs within length limits (complex params may be
   POST-body only).
