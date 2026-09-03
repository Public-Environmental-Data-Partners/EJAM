# Session handoff → "API in EJAM package - PR-plan"

> **Addendum (added 2026-07-24 when this handoff was absorbed into the plan branch):**
> re-verified against GitHub the same day and two items in §4/§5 had already moved on:
> **EJAM-API #49 and #32 are now MERGED** — `origin/main` is `08dc3a7` (#32 `/query`
> pagination) on top of `8ca7869` (#49 buffer defaults). So "Live == main" no longer holds:
> the live API matches main *as of `0518bc9`* and now lags it (#48 also verified undeployed).
> The map-popup residual in §4 is **verified resolved on `development`** (`sitenumber_label`
> threads ejam2report → ejam2map/mapfastej → popup_from_ejscreen). EJAM #470 is MERGED to
> development (the §4 "OPEN" row was stale when written). These corrections are reflected in
> `planning/plumber-sync-with-ejam-api-plan.md` §0; the original handoff follows unedited.

**Written:** 2026-07-24 · **From:** a comparison/verification session (now being archived).
**Purpose:** carry forward everything needed to continue the "API in EJAM package" PR-plan work
without the originating conversation. Self-contained — everything below was verified live/local
this session, not recalled.

**Companion plan (the actual work):** `planning/plumber-sync-with-ejam-api-plan.md`
(on branch `API-in-EJAM`; also `planning/in-app-report-rendering-plan.md`).
This file is a status/ground-truth snapshot to sit next to it.

---

## 1. What this session produced

1. A **5-variant comparison of the EJAM API** (embedded in §3 so it survives without the chat).
2. A **correction** to a stale belief: the EJAM-API side of the "Site N" fix (`sitenumber_label`)
   **was filed AND merged** — EJAM-API **#51** (not "not yet filed").
3. **Refreshed local checkouts** of both repos (FF-only). EJAM-API `main` had been stale.

---

## 2. Ground truth verified this session (2026-07-24)

- **Live API (`api.ejanalysis.com`) == EJAM-API `main`, exactly.** Same 7 endpoints; `/query`
  returns a bare unpaginated JSON list (2,420 rows on a test cutoff); a bad `fileextension` on
  `/report` returns `400 text/html`. Root `/` → `302 /__docs__/`.
- **Deployed EJAM pin = `EJAM_VERSION=v3.2022.1`.** This matters: the merged `sitenumber_label`
  code on EJAM-API `main` is **formals-guarded and therefore dormant** until this pin advances to
  a release containing EJAM #470.

### Two distinct API codebases (this is the crux of the whole plan)

| | EJAM-API repo (`rest_controller.r`) | EJAM package draft (`inst/plumber/plumber.R`) |
|---|---|---|
| Role | **Deployed, hardened.** 7 endpoints. | **Experimental kitchen-sink** it was forked from. Remaining endpoints are mostly "NOT TESTED". |
| Has | CORS, `escape_html`, `html_error` (no-store + correct Content-Type), multisite comma-lists, GET+POST `/report`, cache headers, zero-pop fail-safe, `/query`, `/handoff` (+token store) | `/ejamit`, `/ejamit_csv`, `/getblocksnearby`, `/echo`, `/report2`, `/reportpost`, `/ejam2report`, `/ejam2excel`, `/doaggregate`, `/get_blockpoints_in_shape`, logger filter |
| Missing | the draft-only experimental endpoints | CORS, POST `/report`, `/query`, `/handoff`, multisite, caching, escaping; `/data` present but disabled (`if(FALSE)`) |

**The plumber-sync plan's job:** reconcile these — mirror the deployed `rest_controller.r` into
`EJAM/inst/plumber/` so the package ships the real API, with drafts mounted separately.
See `planning/plumber-sync-with-ejam-api-plan.md`.

---

## 3. The 5-variant comparison (condensed, for the record)

Variants: **Live** (api.ejanalysis.com) · **main** (EJAM-API main) · **PRs** (open EJAM-API PRs) ·
**draft** (EJAM inst/plumber) · **#470** (EJAM draft after PR #470).

**`GET /report`** — most complete: EJAM-API PR #49 → then main/live.
- Live/main: multisite comma-lists, `sitenumber` 0/overall, `buffer` flat 3, html+pdf, edge-cached 1 day, zero-pop fail-safe.
- PR #49: `buffer` default → **0 for fips/shape, 3 for latlon** (was OPEN; **now merged** — see addendum).
- draft: **single-site only**, `sitenumber` **hard-coded 1** (the #348 bug), html-only.
- #470: adds `sitenumber` normalize + **"Site N" label** via new `sitenumber_label`; still single-site/html-only.

**`POST /report`** — main/live only. draft/#470: does not exist.

**`POST /query`** — most complete: PR #32.
- Live/main: `attribute`,`value` → bare unpaginated list.
- PR #32: adds `page`/`limit` (max 500/pg), `{results, pagination}` envelope, 400 on bad input
  (was OPEN; **now merged** — see addendum; issue #37).
- draft/#470: does not exist.

**`POST /handoff` + `GET /handoff/{token}`** — most complete: PR #49.
- Live/main: token store, 1 h TTL, CSPRNG; **`{}` empty-radius bug** for fips/shape.
- PR #49: stores explicit `radius=0` → fixes the `{}` crash.
- draft/#470: does not exist.

**`POST /data`** — main/live. draft/#470: present but disabled (`if(FALSE)`).

**Draft-only endpoints** (exist only in EJAM inst/plumber; #470 touches none): `/echo` ✅,
`/getblocksnearby` ⚠️("1 point"), `/report2` ⚠️, `/reportpost` ⚠️, `/ejam2report`
⚠️(has a `future({})` bug — `out` not returned), `/ejam2excel` ⚠️, `/ejamit` ⚠️(shapefile
"not working yet"), `/ejamit_csv` ⚠️, `/get_blockpoints_in_shape` ❌, `/doaggregate` ⚠️.

---

## 4. PR / issue status board (as verified that session; see addendum for what moved)

| Ref | What | State |
|---|---|---|
| **EJAM #470** | draft `/report` gets `sitenumber`; `ejam2report()` gains `sitenumber_label`; fixes #348. Also fixes map-popup residual on-branch (commits 23542821 + 87b824c7). | MERGED to development (row said OPEN when written — stale) |
| **EJAM-API #51** | API-side: `report_response()` passes `sitenumber_label=N`, **guarded** on `"sitenumber_label" %in% names(formals(ejam2report))`; adds `normalize_sitenumber()` (invalid → 400, not silent Site-1). | **MERGED 2026-07-18** |
| EJAM-API #50 | issue: "every per-site report labeled Site 1" (API half of #348) | CLOSED by #51 |
| **EJAM-API #49** | `GET /report` buffer default method-dependent + `/handoff` explicit `radius=0` | **MERGED** (`8ca7869`; was OPEN/CONFLICTING when written) |
| **EJAM-API #32** | `/query` pagination + assets docs | **MERGED** (`08dc3a7`; was OPEN when written) |
| EJAM-API #24/#36 | earlier: `/report` accepts `sitenumber` row-picker; multisite+CORS+handoff | MERGED |

**Activation chain for "Site N":** EJAM #470 merged → an EJAM release cut containing it →
EJAM-API `EJAM_VERSION` pin advanced to that release + redeploy + Cloudflare cache purge → live
reports show "Site N". Nothing else to code on the API side (#51 already handles it, dormant).

**Governance:** EJAM-API and EJScreen are PEDP-owned (Eric) — no changes/merges there without
per-action approval. EJAM repo is user-managed.

---

## 5. Standing constraints for the PR-plan session

- Work on branch `API-in-EJAM` (off `development`) in the **main checkout — no worktrees**.
- **No implementation until Mark OKs the plan** — planning/memory only for now.
- Reconcile the plan against **current** `rest_controller.r` (re-fetch origin/main first; it
  has moved three times in two days) — diff before mirroring.
- Decide draft-endpoint disposition with Mark: which experimental endpoints ship at `/draft`,
  which get dropped (see §3 defect flags).
