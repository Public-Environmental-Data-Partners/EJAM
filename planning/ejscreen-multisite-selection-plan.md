# Plan: Multi-site selection in EJScreen → EJAM multisite report + handoff to the EJAM app

Branch: `ejscreen-multisite-selection`
Status: **Design only — no implementation yet.**
Author: investigation + plan, 2026-06-26

---

## 1. Goal

Today an EJScreen user can specify **one** place at a time in the **Report** tool — via *Drop a Pin* (point), *Draw an Area* (polygon), or *Select an Area* (blockgroup / tract / county / city) — and run a single **EJScreen Community Report** on it (rendered by the EJAM API).

We want to let the user accumulate **multiple** places and then:

- **Goal 1 (primary):** click a new **"Multisite Report"** button to run an **EJAM-style multisite report** over **all** the selected locations, using the EJAM API.
- **Goal 2 (secondary, separable):** click a new **"Send to EJAM"** button to launch the full EJAM app (what EJScreen labels the *"Multisite Tool"*) **pre-loaded** with those same locations — especially polygons — most likely via a URL the EJScreen app constructs.

Both goals share one prerequisite (let EJScreen hold *more than one* selection at a time), then diverge into mostly independent backend work.

---

## 2. How the three systems work today (verified)

### 2.1 EJScreen app — `Public-Environmental-Data-Partners/EJScreen`
Esri/ArcGIS Maps SDK for JS (v4) + Dojo/dijit, served from ASP.NET. Not React/Vue.

- **Three selection modes** live in `mapdijit/templates/ejChart.html` and `mapdijit/ejChart.js`:
  - *Drop a Pin* (`ejChart.html:41`, `startpoint`) → Esri `SketchViewModel` point.
  - *Draw an Area* (`ejChart.html:66`, `startpoly`) → `SketchViewModel` polygon.
  - *Select an Area* (`ejChart.html:102`) → `mapdijit/ejKnownGeo.js`; queries census FeatureLayers and produces a Graphic carrying a `fips` attribute. It already accumulates **up to 5** FIPS (`ejKnownGeo.js:277`) but **merges their rings into one multi-ring polygon** and stores a single Graphic (`submitFIPs`, `ejKnownGeo.js:138-248`).
- **Single-selection bottleneck.** The selected place is one Esri `Graphic` held as `EJinfoWindow.currentGraphic` (`mapdijit/EJinfoWindow.js:83,92`). Drawing a new shape or switching modes calls `tempGraphicsLayer.removeAll()` / `eraseAll()` (`ejChart.js`, `layout_new.js`), which destroys the previous selection and closes the popup. The digitize layers are already named `Project<N>` with an auto-incrementing counter, so **multiple layers *can* coexist** — only the `eraseAll`/`removeAll` calls prevent it.
- **The single-site API call** is built in `getEJReport` (`EJinfoWindow.js:448-532`) and fired from `_getEJscreen` (`EJinfoWindow.js:340`). It reads `currentGraphic`, builds a GET query string, and does `window.open(url + query)` in a **new tab**. The endpoint is registered at `EJinfoWindow.js:57`:
  ```js
  "ejsrpt": { "reporturl": "https://ejamapi-84652557241.us-central1.run.app/report", "category": "ejscreen" }
  ```
  Payload per mode: `?fips=<comma-sep fips>` | `?lon=<x>&lat=<y>&buffer=<mi>` | `?shape=<GeoJSON FeatureCollection>&buffer=<mi>`. (Mobile variant hardcodes the same endpoint at `mobile/mapdijit/reportPanel_v4.js:164`.)
- **Result rendering.** The API response (a full HTML page or PDF) loads directly in the new tab; nothing is rendered inside EJScreen.
- **Existing EJAM link.** `index.html:662` has a **"Multisite Tool"** button that `openPage('https://ejam.publicenvirodata.org/')` — a plain link, **no data handoff**.

### 2.2 EJAM API — `Public-Environmental-Data-Partners/EJAM-API`
R + **plumber** on Google Cloud Run. Three source files: `main.r`, `rest_controller.r`, `Dockerfile`. The Docker image **clones + installs EJAM at a pinned tag** — currently **`v2.32.8.1`** (vs. local working copy `v3.2022.0`). It is a thin wrapper over EJAM's `ejamit()` + `ejam2report()`.

| Method | Path | Inputs | Returns |
|---|---|---|---|
| GET | `/report` | `lat`,`lon`,`shape`(GeoJSON),`fips`,`buffer`=3,`sitenumber`=**1**,`fileextension`=`pdf` | A **single** rendered community report file (PDF/HTML bytes) |
| POST | `/data` | `sites`(array of `{lat,lon}`),`shape`,`fips`,`buffer`=0,`geometries`=FALSE,`scale` | **JSON array** — one object (457 fields) per site = `results_bysite` |
| POST | `/query` | `attribute`,`value` | (currently **500 / broken** live) |

Key facts for this work:
- **`POST /data` already does multisite** (returns one row per site), but it **returns only `results_bysite` and discards `results_overall`** — the aggregate row that *is* the multisite summary (`return(result$results_bysite)` in `rest_controller.r`).
- **`GET /report` is single-site only.** `sitenumber` defaults to **1**, so `ejam2report` always renders one site. Multi-input `/report` (e.g. `fips=10001,10003`) returns **HTTP 500** — it doesn't split comma lists and skips `fipper()`.
- **EJAM's report engine already supports multisite.** `ejam2report(ejamitout, sitenumber = 0 | NULL)` renders the **aggregate `results_overall`** report (`R/ejam2report.R:77-79`, multisite branch ~`:274-300`). The API simply never invokes that path.
- **Polygons are first-class** on both `/report` (`shape=` URL-encoded GeoJSON) and `/data` (`shape` in body): `geojsonsf::geojson_sf(area)` → `ejamit(shapefile=, radius=buffer)`. Multi-feature collections work. There is **no** shapefile/zip upload endpoint — input must be GeoJSON text.

### 2.3 EJAM app (Shiny) — this repo
- **`ejamapp()` parameters** (`R/ejamapp.R:255-410`) can pre-load sites (`sitepoints`/`pts`/`lat`/`lon`, `shapefile`/`shp`, `fips`, `radius`, plus `default_*` tab/method controls). These flow `dots → get_global_defaults_or_user_options() → with_golem_options() → global_or_param()` and become **initial input defaults / reactive fallbacks**. **But they are fixed at app-launch (deploy) time** — for an already-deployed app that EJScreen opens by URL, they cannot be changed.
- **Bookmarking is `enableBookmarking = 'url'`** (`R/ejamapp.R:257`). There are **no custom `onBookmark`/`onRestore` handlers** anywhere — the app relies entirely on Shiny's default behavior, which serializes only `input$` **control values**.
- **No launch-time query-string handler for sites.** The app does **not** read `?fips=`/`?lat=`/`?shape=` to populate selections. (`R/url_ejamapi.R` builds URLs for the *separate plumber API*, not for the Shiny app.) The only URL mechanism is Shiny's `?_inputs_&<input>=<value>` bookmark form (examples in `vignettes/dev-app-settings.Rmd:305-339`).
- **The three site uploads are `fileInput`s** — `ss_upload_latlon` (`app_ui.R:183`), `ss_upload_shp` (`app_ui.R:210`), `ss_upload_fips` (`app_ui.R:231`). **`fileInput`s are NOT bookmarkable in `url` mode.** So today:
  - **FIPS / NAICS / SIC / MACT** → *partially* preloadable via picker `input$` values in a bookmark URL (`ss_choose_method`, `ss_choose_method_drop`, `pickermoduleid-*`), but the user must still click "Done".
  - **Points and polygons** → **cannot** be passed via URL at all (they are file uploads).
- The relevant reactives an external preload would need to feed: `data_up_shp()` (`app_server.R:409-479`), `data_up_latlon()` (`app_server.R:627-701`), `data_up_fips()` (`app_server.R:1144-1232`).

**Conclusion that drives Goal 2:** The user's intuition is right — EJScreen cannot use `ejamapp()` parameters, and the *default* bookmark mechanism cannot carry points or polygons. The fix is a small, **new launch-time query-param handler in the EJAM app** (not the default bookmark) that reads site params from the URL and feeds them into the site-selection reactives.

---

## 3. Architecture overview

```
                 ┌─────────────────────────── EJScreen (browser) ───────────────────────────┐
                 │  Report tool: Drop a Pin | Draw an Area | Select an Area                  │
                 │  NEW: accumulate selections → selectedGraphics[]  (Part A)                │
                 │        ├── [Multisite Report]  ── Goal 1 ──► EJAM API                     │
                 │        └── [Send to EJAM]      ── Goal 2 ──► EJAM app (URL handoff)        │
                 └───────────────────────────────────────────────────────────────────────────┘
                          │ (HTTPS)                                   │ (open URL)
                          ▼                                            ▼
   ┌──────────── EJAM API (plumber, Cloud Run) ────────────┐   ┌──────── EJAM app (Shiny) ────────┐
   │ Goal 1: multisite report endpoint                      │   │ Goal 2: NEW URL query handler     │
   │   ejamit(all sites) → ejam2report(sitenumber = 0)      │   │   parse ?fips/?lat/?lon/?shape    │
   │   → multisite HTML/PDF                                  │   │   → feed data_up_* reactives      │
   └────────────────────────────────────────────────────────┘   └────────────────────────────────┘
                          │ uses                                          │ same param vocabulary as
                          ▼                                                ▼ R/url_ejamapi.R
                  EJAM R package (ejamit, ejam2report)            (lat, lon, buffer, fips, shape)
```

**Design principle — one URL vocabulary.** `R/url_ejamapi.R` already defines the param names `lat`, `lon`, `buffer`/`radius`, `fips`, `shape` (GeoJSON), and `version`. **Reuse exactly these names** for the EJAM-app query handler (Goal 2) so a single convention serves both the API and the app, and so `url_ejamapi()` / `url_ejamapi2arglist()` can build/parse both.

---

## 4. Part A — Shared prerequisite: let EJScreen hold multiple selections

This is required by **both** goals and is the bulk of the EJScreen-side work.

**A1. Accumulate selections instead of clearing them.**
- Introduce a module-level array, e.g. `selectedGraphics = []`, alongside (or replacing) the single `EJinfoWindow.currentGraphic` (`EJinfoWindow.js:83`).
- Stop the destructive clears on each new selection: gate the `tempGraphicsLayer.removeAll()` in `ejChart.js` and the `eraseAll()` calls in `layout_new.js`/`ejChart.js` behind a "multi-select mode" flag, or move them to an explicit **"Clear all"** action. Keep each new draw on its own auto-incrementing `Project<N>` digitize layer (the naming loop already supports this).
- For *Select an Area*, decide whether to keep treating ≤5 FIPS as **one merged place** (current `submitFIPs` behavior) or to add each chosen FIPS as a **separate site** in `selectedGraphics[]`. For a multisite report, separate sites is the more natural mapping; make this a config/decision (see §7).

**A2. A "selections" UI.**
- Add a small list/panel showing accumulated places (type, label, radius) with per-row remove + a "Clear all" button. Esri `SketchViewModel` and the `Project<N>` layers give you the geometries to list.
- Add the two new action buttons: **"Multisite Report"** (Goal 1) and **"Send to EJAM"** (Goal 2). Place them near the existing report link / Report tool, and in the popup workflow.

**A3. A geometry-collection helper.**
- Write one function that walks `selectedGraphics[]` and emits a normalized payload, reusing the per-mode logic already in `getEJReport` (`EJinfoWindow.js:448-532`):
  - points → `{lat, lon}` (+ per-site radius),
  - FIPS → `fips` strings,
  - polygons → GeoJSON `Feature`s.
- Produce both forms: (a) a **GET query string** (for short payloads / Goal 2 small cases) and (b) a **GeoJSON `FeatureCollection`** for a POST body (Goal 1, polygons, large sets). This helper is the single integration point both buttons call.

> Note: Esri polygon rings are in the map's spatial reference (often Web Mercator 3857). The current `getEJReport` already emits lon/lat GeoJSON for the single-polygon case — confirm/reuse that projection step so multi-feature collections are in WGS84 (EPSG:4326/4269), which the API's `geojson_sf()` expects.

---

## 5. Part B — Goal 1: "Multisite Report" via the EJAM API

The EJAM **report engine already supports multisite** (`ejam2report(sitenumber = 0)`); the missing pieces are (i) an API surface that runs all sites and renders the aggregate, and (ii) EJScreen collecting + sending all sites.

### B1. EJAM-API changes (`EJAM-API/rest_controller.r`)

Two viable shapes; **recommend doing both in sequence**:

**B1a. Quick win — multisite over points/FIPS on `GET /report`.**
- Split comma-separated `lat`/`lon`/`fips` into vectors; route `fips` through `fipper()` (as `/data` already does) instead of passing the raw string.
- Treat `sitenumber = 0` (or absent) as the **multisite trigger** and pass it to `ejam2report`, invoking the existing aggregate branch. Keep `sitenumber = N` for a single site.
- This fixes the current multi-input `500` and makes pins + selected-areas work with the existing EJScreen `window.open(GET)` pattern — minimal frontend change. **Not** suitable for many/large polygons (URL length).

**B1b. Robust path — `POST /report` (multisite, handles polygons & mixed/large sets).**
- New route accepting the same body as `/data` (`sites`, `fips`, `shape` FeatureCollection, `buffer`, `scale`), running one `ejamit()` and returning **`ejam2report(result, sitenumber = 0, return_html = TRUE, report_title = "EJSCREEN Multisite Report")`** as HTML (and/or PDF).
- POST body removes URL-length limits → this is the polygon-safe and large-set path.
- **Mixed selection types:** a single `ejamit()` run is one method (latlon **or** SHP **or** FIPS). To support a mixed bag (some pins + some polygons + some FIPS) in one report, normalize everything to a single GeoJSON `FeatureCollection` and run `ejamit(shapefile = fc)`: buffer points to polygons by their radius client- or server-side, and resolve FIPS to census polygons (`shapes_from_fips()`). Decide whether v1 requires a **uniform selection type** (simpler) or supports mixed (convert-to-polygons). Recommend: v1 = uniform type; v2 = mixed via FeatureCollection.
- Optionally also extend `POST /data` to return `{results_overall, results_bysite}` so non-HTML clients can get the aggregate (cheap, additive).

**B1c. Cross-cutting API concerns:**
- **CORS.** The current single-site flow uses `window.open` (a top-level navigation — no CORS). A `fetch()`-based **POST from EJScreen's origin** (`*.azurewebsites.net`) to the Cloud Run API **will require CORS** response headers (`Access-Control-Allow-Origin`, methods, `Content-Type`, and a preflight `OPTIONS` handler). Add a plumber CORS filter. (If we keep everything on `GET`+`window.open`, CORS is avoided but polygons/large sets are not supported — hence the POST path needs CORS.)
- **EJAM version pin.** Bump the `Dockerfile` EJAM tag from `v2.32.8.1` toward the `v3.x` line where the multisite-via-API path and `ejam2report`'s "called from the EJAM API" branch (`R/ejam2report.R:254`) are more mature. Treat this as part of the API work and smoke-test the multisite render against the chosen tag.
- **Limits & abuse.** Cap site count and total polygon vertices per request; return a clear error past the cap. Cloud Run request timeout — large multisite runs may be slow; consider a generous timeout and a loading state in EJScreen.

### B2. EJScreen changes
- Wire the **"Multisite Report"** button to the Part A geometry-collection helper:
  - **Interim (B1a):** if all selections are points/FIPS and the URL is short, build a multisite `GET /report?...&sitenumber=0` URL and `window.open` it (mirrors today's flow).
  - **Robust (B1b):** `fetch('.../report', {method:'POST', body: FeatureCollection/sites JSON})`, then display the returned HTML — e.g. create a `Blob` URL from the response and `window.open` it, or open a blank tab and write the HTML. Show a spinner while the request runs (multisite is slower than single-site).
- Report title/labeling: pass an analysis title so the rendered report reads as a multisite EJScreen report.

### B3. Optional EJAM package changes
- Likely **none required** — `ejamit()` + `ejam2report(sitenumber = 0)` already produce the multisite report. Only touch EJAM if the chosen API tag reveals a gap in the API-driven multisite path (e.g. report titling, `site_method` handling for mixed inputs). Keep EJAM changes out of scope unless the API smoke test surfaces a concrete need.

---

## 6. Part C — Goal 2: "Send to EJAM" (pre-load the EJAM app)

The user is correct that EJScreen can't use `ejamapp()` params and the default bookmark can't carry points/polygons. The clean solution is a **new launch-time query-string handler in the EJAM Shiny app**, using the **same param vocabulary as `R/url_ejamapi.R`**.

### C1. EJAM app changes (this repo)
Add a single `observe()` that runs once at session start and reads custom URL params, then feeds the existing site-selection reactives. Sketch (illustrative — not final code):

```r
# in app_server(), near the existing observeEvent(session$clientData, ...) at app_server.R:254
url_provided_shp    <- reactiveVal(NULL)
url_provided_pts    <- reactiveVal(NULL)
url_provided_fips   <- reactiveVal(NULL)

observe({
  q <- shiny::parseQueryString(session$clientData$url_search)
  # POINTS: ?lat=..,..&lon=..,..&radius=..   (reuse url_ejamapi.R names)
  if (!is.null(q$lat) && !is.null(q$lon)) {
    pts <- data.frame(lat = as.numeric(strsplit(q$lat, ",")[[1]]),
                      lon = as.numeric(strsplit(q$lon, ",")[[1]]))
    url_provided_pts(pts)
    updateRadioButtons(session, "ss_choose_method", selected = "upload")
    updateSelectInput(session, "ss_choose_method_upload", selected = "latlon")
  }
  # FIPS: ?fips=...,...
  if (!is.null(q$fips)) { url_provided_fips(strsplit(q$fips, ",")[[1]]); ... }
  # POLYGONS: ?shape=<url-encoded GeoJSON>
  if (!is.null(q$shape)) {
    shp <- shapefile_from_any(URLdecode(q$shape))   # geojson text → sf
    url_provided_shp(shp)
    updateRadioButtons(session, "ss_choose_method", selected = "upload")
    updateSelectInput(session, "ss_choose_method_upload", selected = "SHP")
  }
  if (!is.null(q$radius)) updateSliderInput(session, "radius_now", value = as.numeric(q$radius))
  # optional: if (!is.null(q$run)) <trigger the analysis/run button>
}, priority = 1000)
```

Then make the three site reactives prefer the URL-provided value:
```r
data_up_shp    <- reactive({ if (!is.null(url_provided_shp()))  return(url_provided_shp());  ...existing... })
data_up_latlon <- reactive({ if (!is.null(url_provided_pts()))  return(url_provided_pts());  ...existing... })
data_up_fips   <- reactive({ if (!is.null(url_provided_fips())) return(url_provided_fips()); ...existing... })
```
- This makes **all three place types** (incl. polygons) loadable via URL — the gap that blocks Goal 2 today.
- Optionally add `?run=1` to auto-trigger the analysis so EJAM opens already showing results.
- Guard with the same validation the upload path uses (`latlon_df_clean`, `fips_valid`/`fipstype`, `shapefile_from_any`/`shapefile_clean`).

### C2. The polygon-via-URL length problem (the real constraint)
- GeoJSON in a query string hits browser/server URL-length limits. EJAM already mitigates this: `shape2geojson()` + `url_ejamapi()` simplify polygons with `dTolerance` (default 100 m) to fit URLs. **Reuse that simplification** when EJScreen builds the `?shape=` value — fine for a handful of modest polygons.
- For **many or large/detailed polygons**, the URL won't fit. Options, in increasing effort:
  1. **v1:** URL `?shape=` with `dTolerance` simplification (points/FIPS always fit; modest polygons fit). Document the limit; fall back to "too large — use the Report button or upload manually."
  2. **v2 (scalable handoff):** a tiny **handoff endpoint** — EJScreen POSTs the full GeoJSON to a service (the EJAM API or a small EJAM-app route) and gets back a short **token/id**; EJScreen opens `https://ejam.../?handoff=<token>`; the EJAM app fetches the GeoJSON by token at startup. Removes URL limits entirely. Needs a small server-side store (or `enableBookmarking = 'server'` with a custom `onBookmark`/`onRestore` that persists the sf object).
  3. Switching the whole app to `enableBookmarking = 'server'` would let *uploaded* files persist in bookmarks, but it does **not** give EJScreen a clean way to *create* such a bookmark remotely — so the token-handoff in (2) is the better scalable design.
- **Recommendation:** ship v1 (URL params, simplified polygons) since Goal 2 is explicitly secondary/separable; design the param names so the v2 token approach is a drop-in addition.

### C3. EJScreen changes
- Wire **"Send to EJAM"** to the Part A helper → build `https://ejam.publicenvirodata.org/?lat=..&lon=..&fips=..&shape=..&radius=..` and `openPage()` it (the existing `index.html:662` "Multisite Tool" button is the natural home — either repurpose it to carry data or add a sibling button).
- Apply polygon simplification before encoding `?shape=`; if the resulting URL exceeds a safe length, prompt the user (or, in v2, switch to the token handoff).

### C4. Docs
- Update `vignettes/dev-app-settings.Rmd` (the bookmark/URL section, `:158-177`, `:305-339`) and `vignettes/webapp.Rmd` to document the new query-param launch vocabulary, and cross-reference `R/url_ejamapi.R`. Note explicitly that this is a **custom query handler**, distinct from Shiny's default `?_inputs_&` bookmark.

---

## 7. Decisions needed (before/while implementing)

1. **Multisite report transport (Goal 1):** ship the quick `GET /report` multisite for points/FIPS first (B1a), then add `POST /report` for polygons/large/mixed (B1b)? (Recommended.) Or jump straight to POST?
2. **Mixed selection types in one report:** v1 = require a uniform type per report; or support mixed by normalizing to a GeoJSON `FeatureCollection`? (Recommend uniform first.)
3. **"Select an Area" semantics:** in multisite mode, treat each chosen FIPS as a **separate site**, or keep the current ≤5-FIPS-merged-into-one-place behavior?
4. **Polygon handoff for Goal 2:** v1 URL-param with `dTolerance` simplification (accept the size limit), or invest in the token-handoff service now?
5. **EJAM API version bump:** confirm the target `v3.x` tag to pin in the API `Dockerfile`, and who owns redeploying the Cloud Run service.
6. **Auto-run on handoff:** should `?run=1` immediately execute the EJAM analysis, or just pre-load and let the user click Run?

---

## 8. Suggested sequencing

- **Phase 0 — API multisite (no UI):** B1a + B1b in `EJAM-API` (+ CORS, + version bump). Verifiable with `curl` independently of EJScreen. Lowest risk, unblocks Goal 1.
- **Phase 1 — EJScreen multi-select (Part A):** accumulate `selectedGraphics[]`, selections panel, two buttons (wired later), geometry-collection helper. Pure frontend; no backend dependency.
- **Phase 2 — Goal 1 end-to-end:** wire "Multisite Report" to the Phase-0 API; spinner + result rendering.
- **Phase 3 — Goal 2 EJAM handler (C1):** query-param launch handler in this repo + docs; testable by hand-crafting a URL.
- **Phase 4 — Goal 2 end-to-end:** wire "Send to EJAM" to build the URL (with polygon simplification); decide v1 vs token handoff.

Phases 0–2 deliver the primary goal; 3–4 deliver the separable secondary goal.

---

## 9. Appendix — file-by-file change map

**EJScreen (`Public-Environmental-Data-Partners/EJScreen`)**
- `mapdijit/EJinfoWindow.js` — `:83,92` single `currentGraphic` → add `selectedGraphics[]`; `:448-532 getEJReport` → factor out per-mode payload builder; add multisite POST/GET + handoff-URL builders; `:57` endpoint config (add multisite/report routes).
- `mapdijit/ejChart.js` — gate `tempGraphicsLayer.removeAll()` / draw-complete clears behind multi-select mode; keep `Project<N>` layers.
- `javascript/layout_new.js` — gate `eraseAll()` on mode switch; instantiate selections panel + 2 buttons (`new ejChart` ~2970, `new ejKnownGeo` ~3035, `SetDesc`).
- `mapdijit/ejKnownGeo.js` — `submitFIPs` (`:138-248`) / `:277` 5-cap → decide merged-vs-separate FIPS sites.
- `mapdijit/templates/ejChart.html`, `templates/EJinfoWindow.html`, `index.html:662` — UI for selections panel + "Multisite Report" / "Send to EJAM" buttons.
- (`mobile/mapdijit/reportPanel_v4.js:164` — mirror if mobile parity wanted.)

**EJAM-API (`Public-Environmental-Data-Partners/EJAM-API`)**
- `rest_controller.r` — fix multi-input `GET /report` + `sitenumber=0` multisite (B1a); add `POST /report` multisite returning `ejam2report(sitenumber=0)` HTML/PDF (B1b); optionally return `results_overall` from `/data`; add CORS filter + `OPTIONS`.
- `Dockerfile` — bump pinned EJAM tag `v2.32.8.1` → target `v3.x`.
- `README.md` — document multisite report + CORS.

**EJAM app (this repo)**
- `R/app_server.R` — add the launch-time query-param handler (near `:254`); make `data_up_shp()` (`:409`), `data_up_latlon()` (`:627`), `data_up_fips()` (`:1144`) prefer URL-provided values; optional `?run=1` trigger.
- `R/url_ejamapi.R` / `R/url_ejamapi2arglist.R` — reuse/extend as the shared URL vocabulary for the app handler (and, if added, the EJScreen handoff URL builder).
- `vignettes/dev-app-settings.Rmd`, `vignettes/webapp.Rmd` — document the new query-param launch path.

---

## 10. Key risks
- **URL length for polygons** (Goal 2) — mitigated by `dTolerance` simplification; token handoff if needed.
- **CORS** for POST from EJScreen → API (Goal 1 robust path) — must add to the plumber API.
- **EJAM version skew** — API pinned to `v2.32.8.1`; multisite-via-API is more mature in `v3.x`; bump + smoke-test.
- **Mixed input types** in one `ejamit()` run — resolve via normalize-to-FeatureCollection, or restrict v1 to uniform types.
- **Esri projection** — ensure multi-feature GeoJSON is emitted in WGS84, not Web Mercator.
