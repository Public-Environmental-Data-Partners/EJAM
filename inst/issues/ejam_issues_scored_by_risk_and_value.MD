# EJAM Open Issues — Scored by Cost & Benefit

**Total open issues:** 148  |  **Generated:** 2026-09-06  |  **Source:** Live GitHub REST API open issues (Public-Environmental-Data-Partners/EJAM)

**Score payload:** `inst/issues/ejam_issues_scored_by_risk_and_value.json`

---

## Overview

### Previous-run comparison

| Metric | Value |
|--------|-------|
| Previous run | 2026-09-04 |
| Issues opened since previous run | 0 |
| Issues closed since previous run | 0 |
| Issues whose quadrant changed | 0 |

---

## 2×2 Priority Matrix

| Cost / Benefit | **LOW Benefit**<br>value < median | **HIGH Benefit**<br>value ≥ median |
|---|---|---|
| **LOW Cost**<br>cost < median | **C — Other Low-Cost Work**<br>46 issues | **A — Focus Shortlist (max 20)**<br>20 issues |
| **HIGH Cost**<br>cost ≥ median | **D — WORST CANDIDATES**<br>32 issues | **B — OK Candidates**<br>50 issues |

---

## Quadrant A — FOCUS SHORTLIST — Low Cost, High Benefit
*The top 20 low-cost, high-benefit candidates at most, ordered by benefit then cost. Prioritize these above all others.*

**20 issues**

- [#504](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/504) — Web app: 10,000-point analysis (3.1 mi) OOM-crashes on dev Fargate task during blockgroup join
- [#16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) — need new/updated "EJAM User Guide" ("Help" in header at right) since UI has changed a lot, etc.
- [#458](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/458) — Share one report-header rule across in-app, download, and API paths (1-site vs multisite, FIPS place name)
- [#152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) — build_community_report() needs unit tests, table_signif_round_x100() or table_round() too
- [#274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) — Add the features not yet restored from the pre-2025 EPA version of the Community Report
- [#565](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/565) — Vignette links like ../reference/index.html are broken in the installed package (last R CMD check NOTE)
- [#342](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/342) — use renv package to create lock state for what versions of what packages are used
- [#341](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/341) — Align map_headernames and/or generated avg/pctile/ratio metadata with columns doaggregate() can produce for the report
- [#400](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/400) — improve how webapp users can find info on data vintage (in EJAM web app UI, from community report, and from EJScreen UI)
- [#599](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/599) — fix links in  vignettes/webapp.Rmd
- [#580](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/580) — API version number displayed should reflect EJAM version it uses
- [#137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) — fix bug in popshare_at_top_x_pct() - results sometimes not quite right. seems to interpolate badly.
- [#73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) — in web app, add ways to analyze multiple radii at once or even continuous radius
- [#354](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/354) — consider if downloaded report map and/or excel can use polygons in map to do POST API request for 1-site report
- [#166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) — could simplify polygons before mapping, saving - check if useful and then implement
- [#223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) — app_title parameter is not working in ejamapp()
- [#208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) — check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ejam2map() etc.?)
- [#119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) — some code assumes RStudio user is in root folder of source package - check & warn/document, or fix
- [#91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) — Excel needs new tab with uploaded places or facilities found
- [#161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) — ejamapp() should be able to handle mix of fips types

| # | Issue | Cost | Benefit | Milestone | Priority | Labels (key) |
|---|-------|------|---------|-----------|----------|--------------|
| [504](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/504) | Web app: 10,000-point analysis (3.1 mi) OOM-crashes on dev Fargate tas… | 3 (🔵 Low) | 23 (🟩🟩 Very High) | v4 | PRIORITY HIGH | rank:A-high-value-low-cost, BUG, Affects Web App |
| [16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | need new/updated "EJAM User Guide" ("Help" in header at right) since U… | 2 (🔵 Low) | 17 (🟩🟩 Very High) | v4 | PRIORITY HIGH | rank:A-high-value-low-cost, BUG, documentation, help wanted |
| [458](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/458) | Share one report-header rule across in-app, download, and API paths (1… | 3 (🔵 Low) | 17 (🟩🟩 Very High) | v4 | PRIORITY HIGH-ish but not a bug | rank:A-high-value-low-cost, Affects Web App, Community Report |
| [152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | build_community_report() needs unit tests, table_signif_round_x100() o… | 0 (🟢 Very Low) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:A-high-value-low-cost, test, Affects Web App, Community Report |
| [274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | Add the features not yet restored from the pre-2025 EPA version of the… | 2 (🔵 Low) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:A-high-value-low-cost, Affects Web App, Community Report |
| [565](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/565) | Vignette links like ../reference/index.html are broken in the installe… | 3 (🔵 Low) | 15 (🟩🟩 Very High) | v4 | PRIORITY MEDIUM | rank:A-high-value-low-cost, BUG, documentation, URL-related |
| [342](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/342) | use renv package to create lock state for what versions of what packag… | 3 (🔵 Low) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:A-high-value-low-cost, help wanted, Affects Web App |
| [341](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/341) | Align map_headernames and/or generated avg/pctile/ratio metadata with … | 3 (🔵 Low) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:A-high-value-low-cost, Affects Web App, Community Report |
| [400](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/400) | improve how webapp users can find info on data vintage (in EJAM web ap… | 3 (🔵 Low) | 13 (🟩🟩 Very High) | NA | PRIORITY HIGH | rank:A-high-value-low-cost, Affects Web App |
| [599](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/599) | fix links in  vignettes/webapp.Rmd | 0 (🟢 Very Low) | 11 (🟩🟦 High) | NA | PRIORITY HIGH | rank:A-high-value-low-cost, documentation, Affects Web App |
| [580](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/580) | API version number displayed should reflect EJAM version it uses | 0 (🟢 Very Low) | 11 (🟩🟦 High) | v4 | — | rank:A-high-value-low-cost, BUG, documentation, Affects R users only - NOT web app users |
| [137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | fix bug in popshare_at_top_x_pct() - results sometimes not quite right… | 1 (🟢 Very Low) | 11 (🟩🟦 High) | v4 | PRIORITY MEDIUM | rank:A-high-value-low-cost, BUG, Affects Web App |
| [73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | in web app, add ways to analyze multiple radii at once or even continu… | 3 (🔵 Low) | 10 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:A-high-value-low-cost, Affects Web App |
| [354](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/354) | consider if downloaded report map and/or excel can use polygons in map… | 2 (🔵 Low) | 9 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:A-high-value-low-cost, Affects Web App, Community Report |
| [166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | could simplify polygons before mapping, saving - check if useful and t… | 2 (🔵 Low) | 9 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:A-high-value-low-cost, Affects Web App, API |
| [223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | app_title parameter is not working in ejamapp() | 2 (🔵 Low) | 8 (🟦 Medium) | NA | PRIORITY LOW | rank:A-high-value-low-cost, BUG, Affects Web App |
| [208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ej… | 2 (🔵 Low) | 8 (🟦 Medium) | NA | PRIORITY LOW | rank:A-high-value-low-cost, BUG, Affects Web App |
| [119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | some code assumes RStudio user is in root folder of source package - c… | 2 (🔵 Low) | 8 (🟦 Medium) | NA | PRIORITY LOW | rank:A-high-value-low-cost, BUG, Affects R users only - NOT web app users |
| [91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | Excel needs new tab with uploaded places or facilities found | 2 (🔵 Low) | 8 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:A-high-value-low-cost, Affects Web App |
| [161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | ejamapp() should be able to handle mix of fips types | 0 (🟢 Very Low) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:A-high-value-low-cost, Affects Web App |

---

## Quadrant B — OK Candidates — High Cost, High Benefit
*Worth doing but require more effort or expertise. Plan carefully before starting.*

**50 issues**

- [#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) — API takes too long to create a community report from when user clicks
- [#513](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/513) — need better ETA estimates (predicted seconds to completion are too high)
- [#52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) — Create density score /proximity score/ count-nearby functions, then provide via web app, and API
- [#44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) — Investigate options for asynchronous processing in R Shiny (espec for speed / performance at launch)
- [#226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) — NOTES on SPEEDING UP app & functions (incl load testing)
- [#349](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/349) — Polygon report links recompute API reports from simplified GeoJSON
- [#153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) — revisit work in progress on this list of .R files
- [#193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) — Create Executive Summary helper functions - summarizer / Methods for Identifying and Focusing on Key Findings
- [#68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) — allow user to type in radius not only use slider
- [#46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) — Long Report text needed
- [#555](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/555) — Saved-results fixtures are macOS-specific: the 4 comparisons fail on Linux and Windows
- [#560](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/560) — Four NAICS web-scrape tests fail when naics.com blocks a CI runner (seen on Linux)
- [#527](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/527) — shapes_from_fips() errors offline even when the county boundary is built into the package
- [#126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) — enable 1-site report on Polygons / Shapefile, via links/buttons in shiny map popups and table of sites (but NOT outside shiny like in URL-based/link in Excel table)
- [#279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) — Prepare the package to submit to CRAN (and get it accepted for hosting on CRAN)
- [#87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) — Enable shiny.telemetry log file that is not just a text file on server
- [#31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) — fix distance_avg in doaggregate()\$results_bybg_people
- [#553](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/553) — plot_lorenz_*() draft plots are broken: undefined bysite, filter on a literal, constant aes mapping
- [#56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) — check/ fix Distance and Site Count summary stats, in doaggregate()
- [#135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) — finish work in progress on default_ss_choose_method  vs input\$ ?
- [#19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) — FIPS missing/problems (mostly in Connecticut)
- [#511](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/511) — CI runs only on PRs into main: development and deploy PRs get no checks at all
- [#510](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/510) — Smoke-test PDF generation in the built image and after deploy (prod PDF broke undetected)
- [#172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) — create "sites_from_anything" func to allow any types of inputs specifying any types of places
- [#82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) — confusing UI: a user names the analysis #1, then forgets to change title when runs 2d analysis
- [#81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) — confusion in UI: if user tries a second analysis by uploading new stuff, they sometimes click on See Results instead of reclicking "Start Analysis"
- [#192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) — User-specified indicators (enable upload of and reporting on user-provided block group indicators)
- [#167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) — review and reduce or fix pkg dependencies
- [#34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) — Remove extraneous comments from Shiny app scripts
- [#170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) — refactor/rename inconsistent function names that contain state_fips or state_abbrev
- [#37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) — MODULE: incorporate the Shiny module for typing in lat/lon values
- [#168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) — refactor/reconcile "report_logo" vs "logo_path" (parameters and/or global defaults
- [#256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) — speed up some functions by using .arrow not .rda version of each large dataset more consistently
- [#169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) — harmonize/refactor functions that create or sanitize filenames, paths
- [#194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) — Create visualizations of overall results in app  - engaging & insightful
- [#54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) — correctly handle cases where the adjusted distance (via block_radius_miles) is > radius the user specified
- [#66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) — EJAM & EJScreen report on avg PERSON generally but State Average or US Avg shown is avg BLOCK GROUP ! Decide how to reconcile this.
- [#83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) — enable selecting a folder as way to upload shapefile(s)
- [#74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) — Develop options for defining the Reference Zone or Ref. Group - avg person vs bg vs "other 3-mile circles" - in rural, county, user-defined etc.
- [#72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) — find a way to map more polygons (than just 159 cap)
- [#26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) — Create LongReport (quarto/word doc/TSD) Settings Panel
- [#33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) — Move HTML, CSS, and Javascript code into appropriate external files
- [#80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) — make latlon_from_naics() and other naics-related functions consistent with others like frs_from_naics()
- [#77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) — MODULE: Point layer MODULE (specify URL of service with point data)
- [#75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) — "Schools Counter" functionality needed (to count schools or other features in each place)
- [#84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) — enable an Add Data tool or otherwise harmonize with geoplatform, ejscreen, enviroatlas, echo, etc. to view or link to other layers
- [#57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) — Enable analysis of VERY large numbers of points - test limits and code solutions like batching, etc
- [#50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) — plotting functions all need review/ consolidation/ improvement/ renaming/ testing
- [#32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) — *** MOVE CODE OUT OF SERVER and app_ui
- [#85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) — Enable higher resolution analysis than getblocksnearby() does, via Dasymetric mapping

| # | Issue | Cost | Benefit | Milestone | Priority | Labels (key) |
|---|-------|------|---------|-----------|----------|--------------|
| [293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | API takes too long to create a community report from when user clicks | 5 (🟡 Medium) | 19 (🟩🟩 Very High) | v4 | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, speed / performance (see #226), Affects Web App, API |
| [513](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/513) | need better ETA estimates (predicted seconds to completion are too hig… | 6 (🟡 Medium) | 17 (🟩🟩 Very High) | v4 | PRIORITY HIGH | rank:B-high-value-high-cost, BUG, speed / performance (see #226), Affects Web App |
| [52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | Create density score /proximity score/ count-nearby functions, then pr… | 8 (🟠 High) | 17 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, distance-related, future plan list |
| [44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | Investigate options for asynchronous processing in R Shiny (espec for … | 18 (⛔ Very High) | 17 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, datasets-related, speed / performance (see #226), API |
| [226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | NOTES on SPEEDING UP app & functions (incl load testing) | 7 (🟠 High) | 16 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, speed / performance (see #226), Affects Web App |
| [349](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/349) | Polygon report links recompute API reports from simplified GeoJSON | 4 (🟡 Medium) | 15 (🟩🟩 Very High) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, shapefile-related, URL-related |
| [153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | revisit work in progress on this list of .R files | 4 (🟡 Medium) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, test, Affects Web App |
| [193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | Create Executive Summary helper functions - summarizer / Methods for I… | 5 (🟡 Medium) | 15 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, LongReport_output, Affects Web App, future plan list |
| [68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | allow user to type in radius not only use slider | 4 (🟡 Medium) | 13 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost |
| [46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | Long Report text needed | 8 (🟠 High) | 13 (🟩🟩 Very High) | NA | PRIORITY HIGH-ish but not a bug | rank:B-high-value-high-cost, LongReport_output, future plan list |
| [555](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/555) | Saved-results fixtures are macOS-specific: the 4 comparisons fail on L… | 4 (🟡 Medium) | 12 (🟩🟦 High) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, test |
| [560](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/560) | Four NAICS web-scrape tests fail when naics.com blocks a CI runner (se… | 4 (🟡 Medium) | 11 (🟩🟦 High) | v4 | — | rank:B-high-value-high-cost, BUG, Affects R users only - NOT web app users |
| [527](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/527) | shapes_from_fips() errors offline even when the county boundary is bui… | 4 (🟡 Medium) | 11 (🟩🟦 High) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, test, Affects R users only - NOT web app users |
| [126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | enable 1-site report on Polygons / Shapefile, via links/buttons in shi… | 4 (🟡 Medium) | 11 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, Affects Web App, API |
| [279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | Prepare the package to submit to CRAN (and get it accepted for hosting… | 5 (🟡 Medium) | 10 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, help wanted, Affects R users only - NOT web app users |
| [87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | Enable shiny.telemetry log file that is not just a text file on server | 6 (🟡 Medium) | 10 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, datasets-related, Affects Web App |
| [31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | fix distance_avg in doaggregate()\$results_bybg_people | 4 (🟡 Medium) | 9 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, distance-related |
| [553](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/553) | plot_lorenz_*() draft plots are broken: undefined bysite, filter on a … | 6 (🟡 Medium) | 9 (🟩🟦 High) | NA | PRIORITY LOW | rank:B-high-value-high-cost, BUG |
| [56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | check/ fix Distance and Site Count summary stats, in doaggregate() | 6 (🟡 Medium) | 9 (🟩🟦 High) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, documentation, calculate/validate to EJScreen |
| [135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | finish work in progress on default_ss_choose_method  vs input\$ ? | 4 (🟡 Medium) | 8 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, BUG, Affects R users only - NOT web app users |
| [19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | FIPS missing/problems (mostly in Connecticut) | 6 (🟡 Medium) | 8 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, BUG, help wanted, maps-related |
| [511](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/511) | CI runs only on PRs into main: development and deploy PRs get no check… | 4 (🟡 Medium) | 7 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, test, Affects Web App |
| [510](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/510) | Smoke-test PDF generation in the built image and after deploy (prod PD… | 4 (🟡 Medium) | 7 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:B-high-value-high-cost, test, Affects Web App |
| [172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | create "sites_from_anything" func to allow any types of inputs specify… | 4 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, Affects R users only - NOT web app users |
| [82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | confusing UI: a user names the analysis #1, then forgets to change tit… | 4 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, still relevant?, Affects Web App |
| [81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | confusion in UI: if user tries a second analysis by uploading new stuf… | 4 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, still relevant?, Affects Web App |
| [192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | User-specified indicators (enable upload of and reporting on user-prov… | 5 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, Affects Web App, future plan list |
| [167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | review and reduce or fix pkg dependencies | 5 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, dependencies-related, Affects R users only - NOT web app users |
| [34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | Remove extraneous comments from Shiny app scripts | 6 (🟡 Medium) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, server |
| [170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | refactor/rename inconsistent function names that contain state_fips or… | 7 (🟠 High) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, Affects R users only - NOT web app users |
| [37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | MODULE: incorporate the Shiny module for typing in lat/lon values | 7 (🟠 High) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, server |
| [168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | refactor/reconcile "report_logo" vs "logo_path" (parameters and/or glo… | 8 (🟠 High) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, Affects R users only - NOT web app users, Community Report |
| [256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | speed up some functions by using .arrow not .rda version of each large… | 9 (🟠 High) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, datasets-related, speed / performance (see #226), Affects Web App |
| [169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | harmonize/refactor functions that create or sanitize filenames, paths | 9 (🟠 High) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, Affects R users only - NOT web app users |
| [194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | Create visualizations of overall results in app  - engaging & insightf… | 5 (🟡 Medium) | 6 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, plots-graphs-related, future plan list |
| [54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | correctly handle cases where the adjusted distance (via block_radius_m… | 9 (🟠 High) | 6 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, BUG, calculate/validate to EJScreen, distance-related |
| [66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | EJAM & EJScreen report on avg PERSON generally but State Average or US… | 10 (🟠 High) | 6 (🟦 Medium) | v4 | PRIORITY LOW | rank:B-high-value-high-cost, BUG, calculate/validate to EJScreen, Community Report |
| [83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | enable selecting a folder as way to upload shapefile(s) | 4 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, shapefile-related, Affects Web App |
| [74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | Develop options for defining the Reference Zone or Ref. Group - avg pe… | 4 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost |
| [72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | find a way to map more polygons (than just 159 cap) | 4 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, shapefile-related, maps-related |
| [26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | Create LongReport (quarto/word doc/TSD) Settings Panel | 4 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, LongReport_output |
| [33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | Move HTML, CSS, and Javascript code into appropriate external files | 5 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, server |
| [80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | make latlon_from_naics() and other naics-related functions consistent … | 6 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, refactor, Affects R users only - NOT web app users |
| [77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | MODULE: Point layer MODULE (specify URL of service with point data) | 6 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, server |
| [75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | "Schools Counter" functionality needed (to count schools or other feat… | 6 (🟡 Medium) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, shapefile-related, refactor, distance-related |
| [84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | enable an Add Data tool or otherwise harmonize with geoplatform, ejscr… | 8 (🟠 High) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, shapefile-related, Affects Web App |
| [57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | Enable analysis of VERY large numbers of points - test limits and code… | 8 (🟠 High) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, tasklist, speed / performance (see #226) |
| [50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | plotting functions all need review/ consolidation/ improvement/ renami… | 8 (🟠 High) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, server, speed / performance (see #226) |
| [32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | *** MOVE CODE OUT OF SERVER and app_ui | 11 (⛔ Very High) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:B-high-value-high-cost, refactor, tasklist, server |
| [85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | Enable higher resolution analysis than getblocksnearby() does, via Das… | 12 (⛔ Very High) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:B-high-value-high-cost, shapefile-related, maps-related, Affects Web App |

---

## Quadrant C — OTHER LOW-COST WORK
*Cheap to do but not in the current focus shortlist. Pick these up when bandwidth allows or combine them with nearby work.*

**46 issues**

- [#595](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/595) — improve API documentation vignette
- [#490](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/490) — swap us and state ratio columns
- [#361](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/361) — Add date and time of last updated to help with deploys
- [#163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) — put certain columns last in table of results (bg count, block count, radius)
- [#162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) — rename "in_how_many_states"   column  in table of results
- [#136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) — in web app, fix console  error msg when uploading a shapefile
- [#588](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/588) — Web app: production serves several static assets as 404
- [#70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) — set up alerts that monitor and alert staff when the app goes down - ensure available
- [#596](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/596) — EJAM v4.2024.0 pipeline incorrectly reports some ACS variables
- [#484](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/484) — in overall table, change EJAM Report link for 1-site analysis
- [#486](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/486) — allow zip code analysis in EJAM shiny web app
- [#284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) — resolve warning about datum, in logs/console, when web app tries to upload/read some shapefiles
- [#102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) — Remove NA console messages from `doaggregate`
- [#455](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/455) — fix radius slider behavior after deep link passes a radius and then user changes it
- [#403](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/403) — Add explanation of what "average in state" or "percentile in state" means for a multisite report
- [#350](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/350) — Add report regression tests for FIPS, shapefile, sitenumber, NAICS, and PDF-unavailable paths
- [#96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) — Detailed Table UI Filtering improvements
- [#92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) — Excel's new tab with upload needs cap on size
- [#58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) — joining FIPS upload data to preview table
- [#454](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/454) — fix when should radius slider reset to 0 vs 1 mile (a method-specific default) if radio button used to switch between points and polygon/fips type sites
- [#224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) — report correct population for a single block (if block is analyzed via block fips code)
- [#40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) — Allow abort site selection processing when selections are changed
- [#177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) — pick which approach is faster among functions like sf_nearest_points() and related
- [#176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) — popups reports in county case are not normal/ignore reports settings?
- [#175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) — drop the excel column called "Area of block group in geodatabase" and others
- [#159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) — integrate file-naming function and header-creating functions
- [#24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) — map popups in make.popups.api() and other functions are too cluttered, move most info to separate popup (see example in comment)
- [#179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) — in ejam2excel() rename parameter fname to filename for consistency w other functions
- [#174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) — round to only 1 digit the area in square miles in header of summary report
- [#464](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/464) — Investigate and solve high cost on AWS Fargate
- [#535](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/535) — Consolidate app-settings vignette: EJScreen deep links + cross-vignette overlap
- [#181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) — add other ejam2xyz functions to basics.Rmd as examples
- [#93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) — make Demog. section of summary report table more visually prominent
- [#59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) — Improve MACT-related  lat lon data
- [#184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) — trim the extremely long unit test names
- [#43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) — Enable fast site selection map during category scrolling
- [#41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) — Include indicator formulas in Community Report
- [#39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) — Review/revise/expand unit testing for SIC functions
- [#482](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/482) — Feature: zipcode analysis — accept zipcode parameter in ejamit() and key functions
- [#183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) — use more standardized format in NEWS / changelog?
- [#600](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/600) — Expose a Community Report example in public pkgdown docs
- [#343](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/343) — check/loosen/drop minimum required version of each package specified in DESCRIPTION file
- [#42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) — Remove unused report template files
- [#602](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/602) — fix vignette on analyzing
- [#597](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/597) — Add Donate button
- [#60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) — Rename community report functions with common convention

| # | Issue | Cost | Benefit | Milestone | Priority | Labels (key) |
|---|-------|------|---------|-----------|----------|--------------|
| [595](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/595) | improve API documentation vignette | 0 (🟢 Very Low) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost, documentation, Affects R users only - NOT web app users |
| [490](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/490) | swap us and state ratio columns | 1 (🟢 Very Low) | 7 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:C-low-value-low-cost, Affects Web App, Community Report |
| [361](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/361) | Add date and time of last updated to help with deploys | 1 (🟢 Very Low) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost, Affects Web App |
| [163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | put certain columns last in table of results (bg count, block count, r… | 1 (🟢 Very Low) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost, Affects Web App |
| [162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | rename "in_how_many_states"   column  in table of results | 1 (🟢 Very Low) | 7 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:C-low-value-low-cost, Affects Web App |
| [136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | in web app, fix console  error msg when uploading a shapefile | 1 (🟢 Very Low) | 7 (🟦 Medium) | v4 | PRIORITY LOW | rank:C-low-value-low-cost, BUG |
| [588](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/588) | Web app: production serves several static assets as 404 | 2 (🔵 Low) | 7 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, BUG |
| [70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | set up alerts that monitor and alert staff when the app goes down - en… | 2 (🔵 Low) | 7 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost |
| [596](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/596) | EJAM v4.2024.0 pipeline incorrectly reports some ACS variables | 3 (🔵 Low) | 7 (🟦 Medium) | v4 | — | rank:C-low-value-low-cost, BUG |
| [484](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/484) | in overall table, change EJAM Report link for 1-site analysis | 3 (🔵 Low) | 7 (🟦 Medium) | v4 | PRIORITY MEDIUM | rank:C-low-value-low-cost, Affects Web App |
| [486](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/486) | allow zip code analysis in EJAM shiny web app | 1 (🟢 Very Low) | 6 (🟦 Medium) | v4 | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | resolve warning about datum, in logs/console, when web app tries to up… | 3 (🔵 Low) | 6 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | Remove NA console messages from `doaggregate` | 0 (🟢 Very Low) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects R users only - NOT web app users |
| [455](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/455) | fix radius slider behavior after deep link passes a radius and then us… | 1 (🟢 Very Low) | 5 (🟦 Medium) | v4 | PRIORITY LOW | rank:C-low-value-low-cost, BUG |
| [403](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/403) | Add explanation of what "average in state" or "percentile in state" me… | 1 (🟢 Very Low) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost, documentation, Affects Web App |
| [350](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/350) | Add report regression tests for FIPS, shapefile, sitenumber, NAICS, an… | 2 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, BUG, test, Community Report |
| [96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | Detailed Table UI Filtering improvements | 2 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | Excel's new tab with upload needs cap on size | 2 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | joining FIPS upload data to preview table | 2 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost |
| [454](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/454) | fix when should radius slider reset to 0 vs 1 mile (a method-specific … | 3 (🔵 Low) | 5 (🟦 Medium) | v4 | PRIORITY LOW | rank:C-low-value-low-cost, BUG |
| [224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | report correct population for a single block (if block is analyzed via… | 3 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY LOW | rank:C-low-value-low-cost, BUG |
| [40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | Allow abort site selection processing when selections are changed | 3 (🔵 Low) | 5 (🟦 Medium) | NA | PRIORITY MEDIUM | rank:C-low-value-low-cost |
| [177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | pick which approach is faster among functions like sf_nearest_points()… | 0 (🟢 Very Low) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | popups reports in county case are not normal/ignore reports settings? | 0 (🟢 Very Low) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App, Community Report |
| [175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | drop the excel column called "Area of block group in geodatabase" and … | 0 (🟢 Very Low) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App |
| [159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | integrate file-naming function and header-creating functions | 3 (🔵 Low) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, refactor, Affects Web App, Community Report |
| [24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | map popups in make.popups.api() and other functions are too cluttered,… | 3 (🔵 Low) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, map-popups-related |
| [179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | in ejam2excel() rename parameter fname to filename for consistency w o… | 0 (🟢 Very Low) | 3 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, refactor, Affects R users only - NOT web app users |
| [174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | round to only 1 digit the area in square miles in header of summary re… | 0 (🟢 Very Low) | 3 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Affects Web App, Community Report |
| [464](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/464) | Investigate and solve high cost on AWS Fargate | 2 (🔵 Low) | 3 (⬜ Low) | NA | — | rank:C-low-value-low-cost, Affects Web App |
| [535](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/535) | Consolidate app-settings vignette: EJScreen deep links + cross-vignett… | 1 (🟢 Very Low) | 2 (⬜ Low) | v4 | PRIORITY LOW | rank:C-low-value-low-cost, documentation, Affects R users only - NOT web app users |
| [181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | add other ejam2xyz functions to basics.Rmd as examples | 1 (🟢 Very Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, documentation, refactor, Affects R users only - NOT web app users |
| [93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | make Demog. section of summary report table more visually prominent | 2 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Community Report |
| [59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | Improve MACT-related  lat lon data | 2 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost |
| [184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | trim the extremely long unit test names | 3 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, documentation, refactor, Affects R users only - NOT web app users |
| [43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | Enable fast site selection map during category scrolling | 3 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, maps-related |
| [41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | Include indicator formulas in Community Report | 3 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Community Report |
| [39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | Review/revise/expand unit testing for SIC functions | 3 (🔵 Low) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, test |
| [482](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/482) | Feature: zipcode analysis — accept zipcode parameter in ejamit() and k… | 2 (🔵 Low) | 1 (⬜ Very Low) | v4 | PRIORITY LOW | rank:C-low-value-low-cost |
| [183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | use more standardized format in NEWS / changelog? | 0 (🟢 Very Low) | 0 (⬜ Very Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, documentation, refactor, Affects R users only - NOT web app users |
| [600](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/600) | Expose a Community Report example in public pkgdown docs | 1 (🟢 Very Low) | 0 (⬜ Very Low) | NA | — | rank:C-low-value-low-cost, documentation |
| [343](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/343) | check/loosen/drop minimum required version of each package specified i… | 1 (🟢 Very Low) | 0 (⬜ Very Low) | NA | — | rank:C-low-value-low-cost |
| [42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | Remove unused report template files | 1 (🟢 Very Low) | 0 (⬜ Very Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, Community Report |
| [602](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/602) | fix vignette on analyzing | 2 (🔵 Low) | 0 (⬜ Very Low) | NA | — | rank:C-low-value-low-cost |
| [597](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/597) | Add Donate button | 2 (🔵 Low) | 0 (⬜ Very Low) | NA | — | rank:C-low-value-low-cost |
| [60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | Rename community report functions with common convention | 3 (🔵 Low) | 0 (⬜ Very Low) | NA | PRIORITY LOW | rank:C-low-value-low-cost, documentation, refactor, server |

---

## Quadrant D — WORST CANDIDATES — High Cost, Low Benefit
*Expensive to fix, limited payoff. Defer or deprioritize unless circumstances change.*

**32 issues**

- [#508](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/508) — ECR lifecycle policy: prune accumulating dev images (without touching prod)
- [#507](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/507) — deploy-dev: encode the deployed EJAM version in the dev ECR image tag
- [#182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) — consider refactoring url_xyz functions
- [#89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) — clarify what "N places" really means & report on the selection type (in summary report etc.)
- [#581](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/581) — Analysis of 2 or more tract FIPS codes never completes in the web app (1 tract works)
- [#536](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/536) — redo list of URLs in url_package() documentation
- [#35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) — Review/revise/expand unit testing for URL functions
- [#546](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/546) — count_sites_with_n_high_scores() ratio default still 1.01, inconsistent with the 1.05 yellow cutoff from #369
- [#62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) — Enable download of 'Plot of Average Scores' and 'Plot Full Range of Scores' plots
- [#61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) — downloading excel output with plots for 1000-2000 points takes 10-15 seconds
- [#55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) — add links to COUNTY-LEVEL reports - on a place - from other tools/ sources
- [#592](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/592) — test_ejam(): 19 test files are missing timing estimates in timebyfile
- [#585](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/585) — CI: 'Quick install check' intermittently hangs to its 60-minute timeout in Set up R / Install hard dependencies
- [#584](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/584) — Speed/ETA calibration: work deliberately scoped out of #515
- [#548](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/548) — R CMD check has 2 ERRORs on macOS and Windows, exposed by #530
- [#547](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/547) — Define color-coding cutoffs once, as adjustable parameters (design half of #288)
- [#497](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/497) — refactor / clean up rounding of numbers
- [#86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) — Fix (or remove?) references to ejampackages data object
- [#53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) — for proximity score creation tool, resolve how to apply short distances formula (continuous or abrupt)
- [#231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) — fix frs_by_mact.arrow and /data/mact_table to remove leading and extra spaces
- [#63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) — Fix use of mapping_for_names parameter
- [#180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) — refactor functions handling sitepoints (espec in url_ functions?)
- [#27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) — ability to save/load/bookmark static report settings (and other parameters) -- need to clarify, clean, harmonize, edit documentation
- [#446](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/446) — Cache/precompute FIPS-based reports and boundaries (layered design: bounds, ejamit results, rendered reports)
- [#18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) — some FIPS-related functions/data could be improved
- [#550](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/550) — Point-shapefile upload: make the error message actionable, and dedupe the rule between app_server.R and shapefix.R
- [#95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) — in map_headernames, consider adding info re: in which tables/ popups/ xls/ etc. should given indicator be included
- [#29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) — add info about zero results/ zero pop & near other sites, to EJAM::doaggregate() outputs (as already provided by EJAMejscreenapi::ejscreenapi() output)
- [#387](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/387) — Refactor so 1 release can use any vintage of datasets specified (at load time or per analysis etc)
- [#386](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/386) — ACS table/variable numbering in tables_ejscreen_acs / formulas_ejscreen_acs is not validated against the build year (vintage-correctness risk)
- [#399](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/399) — Pipeline: emit EJSCREEN-formatted 'extensive ACS' table (~951 demographic breakdowns) from S3-supplied indicators
- [#25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) — Enable areal apportionment as option, via existing OW and/or OP code

| # | Issue | Cost | Benefit | Milestone | Priority | Labels (key) |
|---|-------|------|---------|-----------|----------|--------------|
| [508](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/508) | ECR lifecycle policy: prune accumulating dev images (without touching … | 4 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY MEDIUM | rank:D-defer |
| [507](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/507) | deploy-dev: encode the deployed EJAM version in the dev ECR image tag | 4 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY MEDIUM | rank:D-defer |
| [182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | consider refactoring url_xyz functions | 4 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, refactor, Affects R users only - NOT web app users |
| [89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | clarify what "N places" really means & report on the selection type (i… | 4 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, still relevant?, Affects Web App |
| [581](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/581) | Analysis of 2 or more tract FIPS codes never completes in the web app … | 4 (🟡 Medium) | 2 (⬜ Low) | NA | — | rank:D-defer |
| [536](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/536) | redo list of URLs in url_package() documentation | 4 (🟡 Medium) | 2 (⬜ Low) | v4 | PRIORITY LOW | rank:D-defer, documentation, refactor, Affects R users only - NOT web app users |
| [35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | Review/revise/expand unit testing for URL functions | 4 (🟡 Medium) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, test, URL-related |
| [546](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/546) | count_sites_with_n_high_scores() ratio default still 1.01, inconsisten… | 4 (🟡 Medium) | 1 (⬜ Very Low) | v4 | PRIORITY LOW | rank:D-defer, LongReport_output |
| [62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | Enable download of 'Plot of Average Scores' and 'Plot Full Range of Sc… | 4 (🟡 Medium) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, still relevant?, plots-graphs-related |
| [61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | downloading excel output with plots for 1000-2000 points takes 10-15 s… | 4 (🟡 Medium) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, still relevant? |
| [55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | add links to COUNTY-LEVEL reports - on a place - from other tools/ sou… | 4 (🟡 Medium) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, still relevant? |
| [592](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/592) | test_ejam(): 19 test files are missing timing estimates in timebyfile | 4 (🟡 Medium) | 0 (⬜ Very Low) | NA | — | rank:D-defer |
| [585](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/585) | CI: 'Quick install check' intermittently hangs to its 60-minute timeou… | 4 (🟡 Medium) | 0 (⬜ Very Low) | NA | — | rank:D-defer |
| [584](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/584) | Speed/ETA calibration: work deliberately scoped out of #515 | 4 (🟡 Medium) | 0 (⬜ Very Low) | v4 | — | rank:D-defer |
| [548](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/548) | R CMD check has 2 ERRORs on macOS and Windows, exposed by #530 | 4 (🟡 Medium) | 0 (⬜ Very Low) | v4 | — | rank:D-defer |
| [547](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/547) | Define color-coding cutoffs once, as adjustable parameters (design hal… | 6 (🟡 Medium) | 4 (⬜ Low) | v4 | PRIORITY MEDIUM | rank:D-defer, refactor, Community Report |
| [497](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/497) | refactor / clean up rounding of numbers | 6 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, refactor, Affects R users only - NOT web app users |
| [86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | Fix (or remove?) references to ejampackages data object | 6 (🟡 Medium) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, still relevant?, refactor, Affects R users only - NOT web app users |
| [53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | for proximity score creation tool, resolve how to apply short distance… | 6 (🟡 Medium) | 2 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, calculate/validate to EJScreen, distance-related |
| [231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | fix frs_by_mact.arrow and /data/mact_table to remove leading and extra… | 6 (🟡 Medium) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, datasets-related |
| [63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | Fix use of mapping_for_names parameter | 6 (🟡 Medium) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, still relevant?, refactor |
| [180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | refactor functions handling sitepoints (espec in url_ functions?) | 7 (🟠 High) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, refactor, Affects R users only - NOT web app users |
| [27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | ability to save/load/bookmark static report settings (and other parame… | 7 (🟠 High) | 3 (⬜ Low) | NA | PRIORITY MEDIUM | rank:D-defer, documentation, refactor, server |
| [446](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/446) | Cache/precompute FIPS-based reports and boundaries (layered design: bo… | 7 (🟠 High) | 2 (⬜ Low) | NA | — | rank:D-defer, speed / performance (see #226), API |
| [18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | some FIPS-related functions/data could be improved | 7 (🟠 High) | 0 (⬜ Very Low) | NA | — | rank:D-defer, datasets-related |
| [550](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/550) | Point-shapefile upload: make the error message actionable, and dedupe … | 8 (🟠 High) | 4 (⬜ Low) | v4 | PRIORITY LOW | rank:D-defer, shapefile-related, refactor, Affects Web App |
| [95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | in map_headernames, consider adding info re: in which tables/ popups/ … | 8 (🟠 High) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, map-popups-related, still relevant?, datasets-related |
| [29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | add info about zero results/ zero pop & near other sites, to EJAM::doa… | 8 (🟠 High) | 3 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, still relevant?, refactor |
| [387](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/387) | Refactor so 1 release can use any vintage of datasets specified (at lo… | 8 (🟠 High) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, refactor |
| [386](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/386) | ACS table/variable numbering in tables_ejscreen_acs / formulas_ejscree… | 8 (🟠 High) | 0 (⬜ Very Low) | NA | — | rank:D-defer |
| [399](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/399) | Pipeline: emit EJSCREEN-formatted 'extensive ACS' table (~951 demograp… | 11 (⛔ Very High) | 4 (⬜ Low) | NA | PRIORITY LOW | rank:D-defer, calculate/validate to EJScreen, datasets-related, Affects Web App |
| [25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | Enable areal apportionment as option, via existing OW and/or OP code | 12 (⛔ Very High) | 1 (⬜ Very Low) | NA | PRIORITY LOW | rank:D-defer, shapefile-related, still relevant? |

---

## Full Table — All 148 Issues

Sorted: A first (best), then B, C, D; within each group by benefit DESC.

| Quad | Issue # | Cost | Benefit | Milestone | Priority | Title |
|------|---------|------|---------|-----------|----------|-------|
| A | [504](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/504) | 3 | 23 | v4 | PRIORITY HIGH | Web app: 10,000-point analysis (3.1 mi) OOM-crashes on dev Fargate task … |
| A | [16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | 2 | 17 | v4 | PRIORITY HIGH | need new/updated "EJAM User Guide" ("Help" in header at right) since UI … |
| A | [458](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/458) | 3 | 17 | v4 | PRIORITY HIGH-ish but not a bug | Share one report-header rule across in-app, download, and API paths (1-s… |
| A | [152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | 0 | 15 | NA | PRIORITY HIGH-ish but not a bug | build_community_report() needs unit tests, table_signif_round_x100() or … |
| A | [274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | 2 | 15 | NA | PRIORITY HIGH-ish but not a bug | Add the features not yet restored from the pre-2025 EPA version of the C… |
| A | [565](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/565) | 3 | 15 | v4 | PRIORITY MEDIUM | Vignette links like ../reference/index.html are broken in the installed … |
| A | [342](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/342) | 3 | 15 | NA | PRIORITY HIGH-ish but not a bug | use renv package to create lock state for what versions of what packages… |
| A | [341](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/341) | 3 | 15 | NA | PRIORITY HIGH-ish but not a bug | Align map_headernames and/or generated avg/pctile/ratio metadata with co… |
| A | [400](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/400) | 3 | 13 | NA | PRIORITY HIGH | improve how webapp users can find info on data vintage (in EJAM web app … |
| A | [599](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/599) | 0 | 11 | NA | PRIORITY HIGH | fix links in  vignettes/webapp.Rmd |
| A | [580](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/580) | 0 | 11 | v4 | — | API version number displayed should reflect EJAM version it uses |
| A | [137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | 1 | 11 | v4 | PRIORITY MEDIUM | fix bug in popshare_at_top_x_pct() - results sometimes not quite right. … |
| A | [73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | 3 | 10 | NA | PRIORITY MEDIUM | in web app, add ways to analyze multiple radii at once or even continuou… |
| A | [354](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/354) | 2 | 9 | NA | PRIORITY MEDIUM | consider if downloaded report map and/or excel can use polygons in map t… |
| A | [166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | 2 | 9 | NA | PRIORITY MEDIUM | could simplify polygons before mapping, saving - check if useful and the… |
| A | [223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | 2 | 8 | NA | PRIORITY LOW | app_title parameter is not working in ejamapp() |
| A | [208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | 2 | 8 | NA | PRIORITY LOW | check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ejam… |
| A | [119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | 2 | 8 | NA | PRIORITY LOW | some code assumes RStudio user is in root folder of source package - che… |
| A | [91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | 2 | 8 | NA | PRIORITY MEDIUM | Excel needs new tab with uploaded places or facilities found |
| A | [161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | 0 | 7 | NA | PRIORITY MEDIUM | ejamapp() should be able to handle mix of fips types |
| B | [293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | 5 | 19 | v4 | PRIORITY HIGH-ish but not a bug | API takes too long to create a community report from when user clicks |
| B | [513](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/513) | 6 | 17 | v4 | PRIORITY HIGH | need better ETA estimates (predicted seconds to completion are too high) |
| B | [52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | 8 | 17 | NA | PRIORITY HIGH-ish but not a bug | Create density score /proximity score/ count-nearby functions, then prov… |
| B | [44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | 18 | 17 | NA | PRIORITY HIGH-ish but not a bug | Investigate options for asynchronous processing in R Shiny (espec for sp… |
| B | [226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | 7 | 16 | NA | PRIORITY HIGH-ish but not a bug | NOTES on SPEEDING UP app & functions (incl load testing) |
| B | [349](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/349) | 4 | 15 | v4 | PRIORITY MEDIUM | Polygon report links recompute API reports from simplified GeoJSON |
| B | [153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | 4 | 15 | NA | PRIORITY HIGH-ish but not a bug | revisit work in progress on this list of .R files |
| B | [193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | 5 | 15 | NA | PRIORITY HIGH-ish but not a bug | Create Executive Summary helper functions - summarizer / Methods for Ide… |
| B | [68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | 4 | 13 | NA | PRIORITY HIGH-ish but not a bug | allow user to type in radius not only use slider |
| B | [46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | 8 | 13 | NA | PRIORITY HIGH-ish but not a bug | Long Report text needed |
| B | [555](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/555) | 4 | 12 | v4 | PRIORITY MEDIUM | Saved-results fixtures are macOS-specific: the 4 comparisons fail on Lin… |
| B | [560](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/560) | 4 | 11 | v4 | — | Four NAICS web-scrape tests fail when naics.com blocks a CI runner (seen… |
| B | [527](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/527) | 4 | 11 | v4 | PRIORITY MEDIUM | shapes_from_fips() errors offline even when the county boundary is built… |
| B | [126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | 4 | 11 | NA | PRIORITY MEDIUM | enable 1-site report on Polygons / Shapefile, via links/buttons in shiny… |
| B | [279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | 5 | 10 | NA | PRIORITY MEDIUM | Prepare the package to submit to CRAN (and get it accepted for hosting o… |
| B | [87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | 6 | 10 | NA | PRIORITY MEDIUM | Enable shiny.telemetry log file that is not just a text file on server |
| B | [31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | 4 | 9 | NA | PRIORITY MEDIUM | fix distance_avg in doaggregate()\$results_bybg_people |
| B | [553](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/553) | 6 | 9 | NA | PRIORITY LOW | plot_lorenz_*() draft plots are broken: undefined bysite, filter on a li… |
| B | [56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | 6 | 9 | NA | PRIORITY MEDIUM | check/ fix Distance and Site Count summary stats, in doaggregate() |
| B | [135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | 4 | 8 | NA | PRIORITY LOW | finish work in progress on default_ss_choose_method  vs input\$ ? |
| B | [19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | 6 | 8 | v4 | PRIORITY MEDIUM | FIPS missing/problems (mostly in Connecticut) |
| B | [511](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/511) | 4 | 7 | v4 | PRIORITY MEDIUM | CI runs only on PRs into main: development and deploy PRs get no checks … |
| B | [510](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/510) | 4 | 7 | v4 | PRIORITY MEDIUM | Smoke-test PDF generation in the built image and after deploy (prod PDF … |
| B | [172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | 4 | 7 | NA | PRIORITY MEDIUM | create "sites_from_anything" func to allow any types of inputs specifyin… |
| B | [82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | 4 | 7 | NA | PRIORITY MEDIUM | confusing UI: a user names the analysis #1, then forgets to change title… |
| B | [81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | 4 | 7 | NA | PRIORITY MEDIUM | confusion in UI: if user tries a second analysis by uploading new stuff,… |
| B | [192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | 5 | 7 | NA | PRIORITY MEDIUM | User-specified indicators (enable upload of and reporting on user-provid… |
| B | [167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | 5 | 7 | NA | PRIORITY MEDIUM | review and reduce or fix pkg dependencies |
| B | [34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | 6 | 7 | NA | PRIORITY MEDIUM | Remove extraneous comments from Shiny app scripts |
| B | [170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | 7 | 7 | NA | PRIORITY MEDIUM | refactor/rename inconsistent function names that contain state_fips or s… |
| B | [37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | 7 | 7 | NA | PRIORITY MEDIUM | MODULE: incorporate the Shiny module for typing in lat/lon values |
| B | [168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | 8 | 7 | NA | PRIORITY MEDIUM | refactor/reconcile "report_logo" vs "logo_path" (parameters and/or globa… |
| B | [256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | 9 | 7 | NA | PRIORITY MEDIUM | speed up some functions by using .arrow not .rda version of each large d… |
| B | [169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | 9 | 7 | NA | PRIORITY MEDIUM | harmonize/refactor functions that create or sanitize filenames, paths |
| B | [194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | 5 | 6 | NA | PRIORITY MEDIUM | Create visualizations of overall results in app  - engaging & insightful |
| B | [54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | 9 | 6 | NA | PRIORITY LOW | correctly handle cases where the adjusted distance (via block_radius_mil… |
| B | [66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | 10 | 6 | v4 | PRIORITY LOW | EJAM & EJScreen report on avg PERSON generally but State Average or US A… |
| B | [83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | 4 | 5 | NA | PRIORITY LOW | enable selecting a folder as way to upload shapefile(s) |
| B | [74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | 4 | 5 | NA | PRIORITY MEDIUM | Develop options for defining the Reference Zone or Ref. Group - avg pers… |
| B | [72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | 4 | 5 | NA | PRIORITY MEDIUM | find a way to map more polygons (than just 159 cap) |
| B | [26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | 4 | 5 | NA | PRIORITY MEDIUM | Create LongReport (quarto/word doc/TSD) Settings Panel |
| B | [33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | 5 | 5 | NA | PRIORITY MEDIUM | Move HTML, CSS, and Javascript code into appropriate external files |
| B | [80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | 6 | 5 | NA | PRIORITY LOW | make latlon_from_naics() and other naics-related functions consistent wi… |
| B | [77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | 6 | 5 | NA | PRIORITY MEDIUM | MODULE: Point layer MODULE (specify URL of service with point data) |
| B | [75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | 6 | 5 | NA | PRIORITY MEDIUM | "Schools Counter" functionality needed (to count schools or other featur… |
| B | [84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | 8 | 5 | NA | PRIORITY LOW | enable an Add Data tool or otherwise harmonize with geoplatform, ejscree… |
| B | [57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | 8 | 5 | NA | PRIORITY MEDIUM | Enable analysis of VERY large numbers of points - test limits and code s… |
| B | [50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | 8 | 5 | NA | PRIORITY MEDIUM | plotting functions all need review/ consolidation/ improvement/ renaming… |
| B | [32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | 11 | 5 | NA | PRIORITY MEDIUM | *** MOVE CODE OUT OF SERVER and app_ui |
| B | [85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | 12 | 5 | NA | PRIORITY LOW | Enable higher resolution analysis than getblocksnearby() does, via Dasym… |
| C | [595](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/595) | 0 | 7 | NA | PRIORITY MEDIUM | improve API documentation vignette |
| C | [490](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/490) | 1 | 7 | v4 | PRIORITY MEDIUM | swap us and state ratio columns |
| C | [361](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/361) | 1 | 7 | NA | PRIORITY MEDIUM | Add date and time of last updated to help with deploys |
| C | [163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | 1 | 7 | NA | PRIORITY MEDIUM | put certain columns last in table of results (bg count, block count, rad… |
| C | [162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | 1 | 7 | v4 | PRIORITY MEDIUM | rename "in_how_many_states"   column  in table of results |
| C | [136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | 1 | 7 | v4 | PRIORITY LOW | in web app, fix console  error msg when uploading a shapefile |
| C | [588](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/588) | 2 | 7 | NA | PRIORITY LOW | Web app: production serves several static assets as 404 |
| C | [70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | 2 | 7 | NA | PRIORITY MEDIUM | set up alerts that monitor and alert staff when the app goes down - ensu… |
| C | [596](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/596) | 3 | 7 | v4 | — | EJAM v4.2024.0 pipeline incorrectly reports some ACS variables |
| C | [484](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/484) | 3 | 7 | v4 | PRIORITY MEDIUM | in overall table, change EJAM Report link for 1-site analysis |
| C | [486](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/486) | 1 | 6 | v4 | PRIORITY LOW | allow zip code analysis in EJAM shiny web app |
| C | [284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | 3 | 6 | NA | PRIORITY LOW | resolve warning about datum, in logs/console, when web app tries to uplo… |
| C | [102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | 0 | 5 | NA | PRIORITY LOW | Remove NA console messages from `doaggregate` |
| C | [455](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/455) | 1 | 5 | v4 | PRIORITY LOW | fix radius slider behavior after deep link passes a radius and then user… |
| C | [403](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/403) | 1 | 5 | NA | PRIORITY MEDIUM | Add explanation of what "average in state" or "percentile in state" mean… |
| C | [350](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/350) | 2 | 5 | NA | PRIORITY LOW | Add report regression tests for FIPS, shapefile, sitenumber, NAICS, and … |
| C | [96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | 2 | 5 | NA | PRIORITY LOW | Detailed Table UI Filtering improvements |
| C | [92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | 2 | 5 | NA | PRIORITY LOW | Excel's new tab with upload needs cap on size |
| C | [58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | 2 | 5 | NA | PRIORITY MEDIUM | joining FIPS upload data to preview table |
| C | [454](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/454) | 3 | 5 | v4 | PRIORITY LOW | fix when should radius slider reset to 0 vs 1 mile (a method-specific de… |
| C | [224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | 3 | 5 | NA | PRIORITY LOW | report correct population for a single block (if block is analyzed via b… |
| C | [40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | 3 | 5 | NA | PRIORITY MEDIUM | Allow abort site selection processing when selections are changed |
| C | [177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | 0 | 4 | NA | PRIORITY LOW | pick which approach is faster among functions like sf_nearest_points() a… |
| C | [176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | 0 | 4 | NA | PRIORITY LOW | popups reports in county case are not normal/ignore reports settings? |
| C | [175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | 0 | 4 | NA | PRIORITY LOW | drop the excel column called "Area of block group in geodatabase" and ot… |
| C | [159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | 3 | 4 | NA | PRIORITY LOW | integrate file-naming function and header-creating functions |
| C | [24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | 3 | 4 | NA | PRIORITY LOW | map popups in make.popups.api() and other functions are too cluttered, m… |
| C | [179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | 0 | 3 | NA | PRIORITY LOW | in ejam2excel() rename parameter fname to filename for consistency w oth… |
| C | [174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | 0 | 3 | NA | PRIORITY LOW | round to only 1 digit the area in square miles in header of summary repo… |
| C | [464](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/464) | 2 | 3 | NA | — | Investigate and solve high cost on AWS Fargate |
| C | [535](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/535) | 1 | 2 | v4 | PRIORITY LOW | Consolidate app-settings vignette: EJScreen deep links + cross-vignette … |
| C | [181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | 1 | 2 | NA | PRIORITY LOW | add other ejam2xyz functions to basics.Rmd as examples |
| C | [93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | 2 | 2 | NA | PRIORITY LOW | make Demog. section of summary report table more visually prominent |
| C | [59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | 2 | 2 | NA | PRIORITY LOW | Improve MACT-related  lat lon data |
| C | [184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | 3 | 2 | NA | PRIORITY LOW | trim the extremely long unit test names |
| C | [43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | 3 | 2 | NA | PRIORITY LOW | Enable fast site selection map during category scrolling |
| C | [41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | 3 | 2 | NA | PRIORITY LOW | Include indicator formulas in Community Report |
| C | [39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | 3 | 2 | NA | PRIORITY LOW | Review/revise/expand unit testing for SIC functions |
| C | [482](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/482) | 2 | 1 | v4 | PRIORITY LOW | Feature: zipcode analysis — accept zipcode parameter in ejamit() and key… |
| C | [183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | 0 | 0 | NA | PRIORITY LOW | use more standardized format in NEWS / changelog? |
| C | [600](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/600) | 1 | 0 | NA | — | Expose a Community Report example in public pkgdown docs |
| C | [343](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/343) | 1 | 0 | NA | — | check/loosen/drop minimum required version of each package specified in … |
| C | [42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | 1 | 0 | NA | PRIORITY LOW | Remove unused report template files |
| C | [602](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/602) | 2 | 0 | NA | — | fix vignette on analyzing |
| C | [597](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/597) | 2 | 0 | NA | — | Add Donate button |
| C | [60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | 3 | 0 | NA | PRIORITY LOW | Rename community report functions with common convention |
| D | [508](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/508) | 4 | 4 | NA | PRIORITY MEDIUM | ECR lifecycle policy: prune accumulating dev images (without touching pr… |
| D | [507](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/507) | 4 | 4 | NA | PRIORITY MEDIUM | deploy-dev: encode the deployed EJAM version in the dev ECR image tag |
| D | [182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | 4 | 4 | NA | PRIORITY LOW | consider refactoring url_xyz functions |
| D | [89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | 4 | 4 | NA | PRIORITY LOW | clarify what "N places" really means & report on the selection type (in … |
| D | [581](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/581) | 4 | 2 | NA | — | Analysis of 2 or more tract FIPS codes never completes in the web app (1… |
| D | [536](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/536) | 4 | 2 | v4 | PRIORITY LOW | redo list of URLs in url_package() documentation |
| D | [35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | 4 | 2 | NA | PRIORITY LOW | Review/revise/expand unit testing for URL functions |
| D | [546](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/546) | 4 | 1 | v4 | PRIORITY LOW | count_sites_with_n_high_scores() ratio default still 1.01, inconsistent … |
| D | [62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | 4 | 1 | NA | PRIORITY LOW | Enable download of 'Plot of Average Scores' and 'Plot Full Range of Scor… |
| D | [61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | 4 | 1 | NA | PRIORITY LOW | downloading excel output with plots for 1000-2000 points takes 10-15 sec… |
| D | [55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | 4 | 1 | NA | PRIORITY LOW | add links to COUNTY-LEVEL reports - on a place - from other tools/ sourc… |
| D | [592](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/592) | 4 | 0 | NA | — | test_ejam(): 19 test files are missing timing estimates in timebyfile |
| D | [585](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/585) | 4 | 0 | NA | — | CI: 'Quick install check' intermittently hangs to its 60-minute timeout … |
| D | [584](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/584) | 4 | 0 | v4 | — | Speed/ETA calibration: work deliberately scoped out of #515 |
| D | [548](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/548) | 4 | 0 | v4 | — | R CMD check has 2 ERRORs on macOS and Windows, exposed by #530 |
| D | [547](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/547) | 6 | 4 | v4 | PRIORITY MEDIUM | Define color-coding cutoffs once, as adjustable parameters (design half … |
| D | [497](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/497) | 6 | 4 | NA | PRIORITY LOW | refactor / clean up rounding of numbers |
| D | [86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | 6 | 4 | NA | PRIORITY LOW | Fix (or remove?) references to ejampackages data object |
| D | [53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | 6 | 2 | NA | PRIORITY LOW | for proximity score creation tool, resolve how to apply short distances … |
| D | [231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | 6 | 1 | NA | PRIORITY LOW | fix frs_by_mact.arrow and /data/mact_table to remove leading and extra s… |
| D | [63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | 6 | 1 | NA | PRIORITY LOW | Fix use of mapping_for_names parameter |
| D | [180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | 7 | 4 | NA | PRIORITY LOW | refactor functions handling sitepoints (espec in url_ functions?) |
| D | [27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | 7 | 3 | NA | PRIORITY MEDIUM | ability to save/load/bookmark static report settings (and other paramete… |
| D | [446](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/446) | 7 | 2 | NA | — | Cache/precompute FIPS-based reports and boundaries (layered design: boun… |
| D | [18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | 7 | 0 | NA | — | some FIPS-related functions/data could be improved |
| D | [550](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/550) | 8 | 4 | v4 | PRIORITY LOW | Point-shapefile upload: make the error message actionable, and dedupe th… |
| D | [95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | 8 | 4 | NA | PRIORITY LOW | in map_headernames, consider adding info re: in which tables/ popups/ xl… |
| D | [29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | 8 | 3 | NA | PRIORITY LOW | add info about zero results/ zero pop & near other sites, to EJAM::doagg… |
| D | [387](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/387) | 8 | 1 | NA | PRIORITY LOW | Refactor so 1 release can use any vintage of datasets specified (at load… |
| D | [386](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/386) | 8 | 0 | NA | — | ACS table/variable numbering in tables_ejscreen_acs / formulas_ejscreen_… |
| D | [399](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/399) | 11 | 4 | NA | PRIORITY LOW | Pipeline: emit EJSCREEN-formatted 'extensive ACS' table (~951 demographi… |
| D | [25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | 12 | 1 | NA | PRIORITY LOW | Enable areal apportionment as option, via existing OW and/or OP code |

---

## Issues by Milestone

| Milestone | Issue count |
|-----------|------------:|
| v4 | 32 |
| NA | 116 |

---

## How Ranking was Done

Each issue is scored independently on two dimensions:

| Dimension | What it measures | Key inputs |
|-----------|-----------------|------------|
| **Cost** (complexity / risk / effort) | How hard is it to fix safely? | WIP/unclear state, data pipeline, spatial methods, refactor scope, body length, architecture labels |
| **Benefit** (value / urgency / importance) | How much does fixing it matter? | PRIORITY label, BUG label, web app vs R-only impact, crash/wrong-calculation signals, CRAN visibility |

### Score ranges

| Dimension | Range | Median (split threshold) |
|-----------|-------|--------------------------|
| Cost    | 0 – 18    | 4 |
| Benefit | 0 – 23 | 5 |

Issues at or above the median are **High**; below are **Low** for that dimension.

### Focus shortlist rule

Quadrant A is capped at **20 issues**. After the median split, eligible low-cost, high-benefit issues are ordered by benefit descending, cost ascending, then issue number. Any remaining eligible issues are placed in C as other low-cost work.

### GitHub rank labels for a later update task

This scoring script writes the labels below into the JSON payload, but it does not apply them to GitHub.

| Quadrant | Label |
|----------|-------|
| A | `rank:A-high-value-low-cost` |
| B | `rank:B-high-value-high-cost` |
| C | `rank:C-low-value-low-cost` |
| D | `rank:D-defer` |

### Scoring Factors

#### Cost factors (higher = harder/riskier)

| Factor | Points |
|--------|--------|
| datasets-related or calculate/validate label | +4 |
| speed/performance label | +3 |
| future plan list / tasklist label | +3 each |
| shapefile / spatial label | +2 |
| refactor / still relevant? labels | +2 each |
| Title: replicate/validate/resolve/reconcile | +4 |
| Title: dasymetric / areal apportionment / async | +5 |
| Title: WIP / revisit / draft | +3 |
| Title: investigate / decide | +2 |
| Title: refactor / restructure | +2 |
| Title: new module / create / enable | +2 |
| Title: CRAN submission | +4 |
| Body length >3000 chars | +4 |
| Body length 1500–3000 chars | +3 |
| Body length 700–1500 chars | +2 |
| Body length 250–700 chars | +1 |
| Title: README / suppress / remove unused / rename param / round / changelog / fix link | −2 to −4 |
| documentation label (no calculate/datasets) | −1 |

#### Benefit factors (higher = more valuable/urgent)

| Factor | Points |
|--------|--------|
| PRIORITY HIGH label | +8 |
| PRIORITY HIGH-ish label | +6 |
| PRIORITY MEDIUM label | +4 |
| PRIORITY LOW label | +1 |
| BUG label | +4 (+2 extra if also PRIORITY HIGH) |
| web app / shiny label | +3 |
| API label | +2 |
| Title: web app / shiny / in app | +2 |
| Title: API | +2 |
| Title: calculation wrong / incorrect / error in | +3 |
| Title: crash / fail / broken / does not work | +4 |
| Title: CRAN submission | +3 |
| Title: major / critical / urgent | +3 |
| retain-0325 label | +1 |
| documentation label (no bug) | −2 |
| Title: README / silence / suppress | −2 to −3 |
| Title: changelog / NEWS.md | −3 |
| Unrated enhancement (no PRIORITY label) | −1 |