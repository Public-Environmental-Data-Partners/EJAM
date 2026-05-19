# EJAM Open Issues — Scored by Cost & Benefit

**Total open issues:** 151  |  **Generated:** 2026-05-19  |  **Source:** inst/ejam_issues_ranked_by_risk.md rescore

---

## Overview

Each issue is scored independently on two dimensions:

| Dimension | What it measures | Key inputs |
|-----------|-----------------|------------|
| **Cost** (complexity / risk / effort) | How hard is it to fix safely? | WIP/unclear state, data pipeline, spatial methods, refactor scope, body length, architecture labels |
| **Benefit** (value / urgency / importance) | How much does fixing it matter? | PRIORITY label, BUG label, web app vs R-only impact, crash/wrong-calculation signals, CRAN visibility |

### Score ranges

| Dimension | Range | Median (split threshold) |
|-----------|-------|--------------------------|
| Cost  | 0 – 18 | 3 |
| Benefit | 0 – 23 | 7 |

Issues at or above the median are **High**; below are **Low** for that dimension.

---

## 2×2 Priority Matrix

```
                │  LOW Benefit          │  HIGH Benefit
                │  (value < median)     │  (value ≥ median)
────────────────┼───────────────────────┼───────────────────────
 LOW Cost       │  C — Might As Well    │  A — BEST CANDIDATES
 (cost < med.)  │  23 issues                │  39 issues
────────────────┼───────────────────────┼───────────────────────
 HIGH Cost      │  D — WORST CANDIDATES │  B — OK Candidates
 (cost ≥ med.)  │  49 issues                │  40 issues
```

---

## Scoring Factors

### Cost factors (higher = harder/riskier)

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

### Benefit factors (higher = more valuable/urgent)

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

---

## Quadrant A — BEST CANDIDATES — Low Cost, High Benefit
*Easy fixes with clear high value. Prioritize these above all others.*

**39 issues**

- [#126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | Cost 2 / Benefit 23 | PRIORITY HIGH 🐛 — enable API query for 1-site or multisite report on Polygons / Shapefile, via buttons in shiny AND if possible via URL-based/link in Excel table, etc.
- [#123](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/123) | Cost 1 / Benefit 21 | PRIORITY HIGH 🐛 — enable API-query URLs to encode a large polygon in excel download of results
- [#154](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/154) | Cost 0 / Benefit 19 | PRIORITY HIGH-ish but not a bug 🐛 — Enable pdf output option for ejam2report() and/or in API
- [#149](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/149) | Cost 1 / Benefit 19 | PRIORITY HIGH-ish but not a bug 🐛 — remove sitenumber=-1 in output of url_ejamapi() for fips case at least
- [#155](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/155) | Cost 2 / Benefit 19 | PRIORITY HIGH-ish but not a bug 🐛 — revisit draft work in progress on API (see branch)
- [#156](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/156) | Cost 0 / Benefit 17 | PRIORITY HIGH-ish but not a bug 🐛 — in app - add view of   ejam2areafeatures(out)  (info on % of pop with certain things nearby)
- [#142](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/142) | Cost 0 / Benefit 17 | PRIORITY MEDIUM 🐛 — ejam2map() fails on shapefile case using sitenumber parameter
- [#152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | Cost 0 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — build_community_report() needs unit tests, table_signif_round_x100() or table_round() too
- [#148](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/148) | Cost 0 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — in excel, have freeze columns apply to the correct columns
- [#150](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/150) | Cost 1 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — shp case map popups should not include "Area within 0 miles of site" nor long,lat: NA, NA
- [#292](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/292) | Cost 2 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — use a column heading that is more informative/clear than "invalid_msg" in the site-by-site details table
- [#274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | Cost 2 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — Add the features not yet restored from the pre-2025 EPA version of the Community Report
- [#205](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/205) | Cost 2 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — adjust summary report fonts and row heights/line spacing to make text more legible
- [#144](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/144) | Cost 0 / Benefit 13 | PRIORITY MEDIUM 🐛 — use or remove or explain the sitenumber parameter in ejam2map() for fips case
- [#127](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/127) | Cost 0 / Benefit 13 | PRIORITY MEDIUM 🐛 — web app details tab with table of all sites is too sluggish as it appears after clicking to view that tab
- [#140](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/140) | Cost 1 / Benefit 13 | PRIORITY MEDIUM 🐛 — in app and R functions, handle blockgroup fips better
- [#136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | Cost 1 / Benefit 13 | PRIORITY MEDIUM 🐛 — in web app, fix console  error msg when uploading a shapefile
- [#109](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/109) | Cost 1 / Benefit 13 | PRIORITY MEDIUM 🐛 — Update &amp; correct the article "Defaults and Custom Settings for the Web App"
- [#249](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/249) | Cost 2 / Benefit 12 | PRIORITY LOW 🐛 — ejam2report() fails if filename is specified without path, or with "./xyz.html"
- [#145](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/145) | Cost 0 / Benefit 11 | PRIORITY MEDIUM 🐛 — fix .onAttach() stumbling on load_all() if add new url_xyz function in global_defaults_package.R
- [#143](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/143) | Cost 0 / Benefit 11 | PRIORITY MEDIUM 🐛 — xlsx download:  snapshot image of report in excel tab lacks logo (and update testdata when fixed)
- [#141](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/141) | Cost 0 / Benefit 11 | PRIORITY MEDIUM 🐛 — allow user to do library(EJAM) from any other folder  (working dir) not just from EJAM source pkg root
- [#130](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/130) | Cost 0 / Benefit 11 | PRIORITY MEDIUM 🐛 — 'basics.html' article needs to be checked / fixed
- [#139](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/139) | Cost 1 / Benefit 11 | PRIORITY MEDIUM 🐛 — The radius parameter gets ignored, but should not, in fips case, where NO BUFFER IS ADDED but should be.
- [#137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | Cost 1 / Benefit 11 | PRIORITY MEDIUM 🐛 — fix bug in popshare_at_top_x_pct() - results sometimes not quite right. seems to interpolate badly.
- [#240](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/240) | Cost 2 / Benefit 11 | PRIORITY MEDIUM 🐛 — Reports need to round off the ratios for climate and health indicators (via new rows in map_headernames)
- [#147](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/147) | Cost 0 / Benefit 10 | PRIORITY LOW 🐛 — rlang pkg is imported by shiny and others, but has its own definition of := that conflicts with data.table pkg :=
- [#164](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/164) | Cost 1 / Benefit 9 | PRIORITY MEDIUM — add unit tests for ejam2report() if possible, and others
- [#166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | Cost 2 / Benefit 9 | PRIORITY MEDIUM — could simplify polygons before mapping, saving - check if useful and then implement
- [#223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | Cost 2 / Benefit 8 | PRIORITY LOW 🐛 — app_title parameter is not working in ejamapp()
- [#208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | Cost 2 / Benefit 8 | PRIORITY LOW 🐛 — check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ejam2map() etc.?)
- [#119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | Cost 2 / Benefit 8 | PRIORITY LOW 🐛 — some code assumes RStudio user is in root folder of source package - check &amp; warn/document, or fix
- [#91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | Cost 2 / Benefit 8 | PRIORITY MEDIUM — Excel needs new tab with uploaded places or facilities found
- [#161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | Cost 0 / Benefit 7 | PRIORITY MEDIUM — ejamapp() should be able to handle mix of fips types
- [#163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | Cost 1 / Benefit 7 | PRIORITY MEDIUM — put certain columns last in table of results (bg count, block count, radius)
- [#162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | Cost 1 / Benefit 7 | PRIORITY MEDIUM — rename "in_how_many_states" and "invalid_msg" columns in table of results
- [#288](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/288) | Cost 2 / Benefit 7 | PRIORITY MEDIUM — ratio of 1.0 should not be yellow on community report
- [#70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | Cost 2 / Benefit 7 | PRIORITY MEDIUM — set up alerts that monitor and alert staff when the app goes down - ensure available
- [#24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | Cost 2 / Benefit 7 | PRIORITY MEDIUM — map popups in make.popups.api() and other functions are too cluttered, move most info to separate popup (see example in comment)

| # | Issue | Cost | Benefit | Priority | Labels (key) |
|---|-------|------|---------|----------|--------------|
| [126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | enable API query for 1-site or multisite report on Polygons / Shapefil… | 2 (🟡 Low) | 23 (🟥 Very High) | PRIORITY HIGH | BUG, Affects Web App, API |
| [123](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/123) | enable API-query URLs to encode a large polygon in excel download of r… | 1 (🟢 Very Low) | 21 (🟥 Very High) | PRIORITY HIGH | BUG, Affects Web App, API |
| [154](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/154) | Enable pdf output option for ejam2report() and/or in API | 0 (🟢 Very Low) | 19 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | test, Affects Web App, API |
| [149](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/149) | remove sitenumber=-1 in output of url_ejamapi() for fips case at least | 1 (🟢 Very Low) | 19 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App, API |
| [155](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/155) | revisit draft work in progress on API (see branch) | 2 (🟡 Low) | 19 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | test, Affects Web App, API |
| [156](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/156) | in app - add view of   ejam2areafeatures(out)  (info on % of pop with … | 0 (🟢 Very Low) | 17 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | test, Affects Web App |
| [142](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/142) | ejam2map() fails on shapefile case using sitenumber parameter | 0 (🟢 Very Low) | 17 (🟥 Very High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users, API |
| [152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | build_community_report() needs unit tests, table_signif_round_x100() o… | 0 (🟢 Very Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | test, Affects Web App, Community Report |
| [148](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/148) | in excel, have freeze columns apply to the correct columns | 0 (🟢 Very Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App |
| [150](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/150) | shp case map popups should not include "Area within 0 miles of site" n… | 1 (🟢 Very Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App |
| [292](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/292) | use a column heading that is more informative/clear than "invalid_msg"… | 2 (🟡 Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App |
| [274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | Add the features not yet restored from the pre-2025 EPA version of the… | 2 (🟡 Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App, Community Report |
| [205](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/205) | adjust summary report fonts and row heights/line spacing to make text … | 2 (🟡 Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | help wanted, Affects Web App, Community Report |
| [144](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/144) | use or remove or explain the sitenumber parameter in ejam2map() for fi… | 0 (🟢 Very Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, Affects Web App, API |
| [127](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/127) | web app details tab with table of all sites is too sluggish as it appe… | 0 (🟢 Very Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, Affects Web App |
| [140](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/140) | in app and R functions, handle blockgroup fips better | 1 (🟢 Very Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, Affects Web App |
| [136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | in web app, fix console  error msg when uploading a shapefile | 1 (🟢 Very Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, Affects Web App |
| [109](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/109) | Update &amp; correct the article "Defaults and Custom Settings for the… | 1 (🟢 Very Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, documentation, Affects R users only - NOT web app users |
| [249](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/249) | ejam2report() fails if filename is specified without path, or with "./… | 2 (🟡 Low) | 12 (🟧 High) | PRIORITY LOW | BUG, Affects R users only - NOT web app users |
| [145](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/145) | fix .onAttach() stumbling on load_all() if add new url_xyz function in… | 0 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users |
| [143](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/143) | xlsx download:  snapshot image of report in excel tab lacks logo (and … | 0 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users |
| [141](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/141) | allow user to do library(EJAM) from any other folder  (working dir) no… | 0 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users |
| [130](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/130) | 'basics.html' article needs to be checked / fixed | 0 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users |
| [139](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/139) | The radius parameter gets ignored, but should not, in fips case, where… | 1 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects Web App |
| [137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | fix bug in popshare_at_top_x_pct() - results sometimes not quite right… | 1 (🟢 Very Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects Web App |
| [240](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/240) | Reports need to round off the ratios for climate and health indicators… | 2 (🟡 Low) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects Web App, Community Report |
| [147](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/147) | rlang pkg is imported by shiny and others, but has its own definition … | 0 (🟢 Very Low) | 10 (🟧 High) | PRIORITY LOW | BUG, Affects R users only - NOT web app users |
| [164](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/164) | add unit tests for ejam2report() if possible, and others | 1 (🟢 Very Low) | 9 (🟧 High) | PRIORITY MEDIUM | Affects Web App, API |
| [166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | could simplify polygons before mapping, saving - check if useful and t… | 2 (🟡 Low) | 9 (🟧 High) | PRIORITY MEDIUM | Affects Web App, API |
| [223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | app_title parameter is not working in ejamapp() | 2 (🟡 Low) | 8 (🟨 Medium) | PRIORITY LOW | BUG, Affects Web App |
| [208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ej… | 2 (🟡 Low) | 8 (🟨 Medium) | PRIORITY LOW | BUG, Affects Web App |
| [119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | some code assumes RStudio user is in root folder of source package - c… | 2 (🟡 Low) | 8 (🟨 Medium) | PRIORITY LOW | BUG, Affects R users only - NOT web app users |
| [91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | Excel needs new tab with uploaded places or facilities found | 2 (🟡 Low) | 8 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App |
| [161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | ejamapp() should be able to handle mix of fips types | 0 (🟢 Very Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App |
| [163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | put certain columns last in table of results (bg count, block count, r… | 1 (🟢 Very Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App |
| [162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | rename "in_how_many_states" and "invalid_msg" columns in table of resu… | 1 (🟢 Very Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App |
| [288](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/288) | ratio of 1.0 should not be yellow on community report | 2 (🟡 Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App, Community Report |
| [70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | set up alerts that monitor and alert staff when the app goes down - en… | 2 (🟡 Low) | 7 (🟨 Medium) | PRIORITY MEDIUM |  |
| [24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | map popups in make.popups.api() and other functions are too cluttered,… | 2 (🟡 Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | map-popups-related |

---

## Quadrant B — OK Candidates — High Cost, High Benefit
*Worth doing but require more effort or expertise. Plan carefully before starting.*

**40 issues**

- [#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | Cost 5 / Benefit 19 | PRIORITY HIGH-ish but not a bug 🐛 — API takes too long to create a community report from when user clicks
- [#284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | Cost 3 / Benefit 17 | PRIORITY LOW 🐛 — resolve warning about datum, in logs/console, when web app tries to upload/read some shapefiles
- [#52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | Cost 8 / Benefit 17 | PRIORITY HIGH-ish but not a bug 🐛 — Create density score /proximity score/ count-nearby functions, then provide via web app, and API
- [#321](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/321) | Cost 14 / Benefit 17 | PRIORITY HIGH 🐛 — resolve differences between EPA ejscreen indicators from the ACS (demographics) and data pipeline effort to replicate it
- [#320](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/320) | Cost 14 / Benefit 17 | PRIORITY HIGH 🐛 — resolve differences between EPA percentiles table and data pipeline effort to replicate it
- [#44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | Cost 18 / Benefit 17 | PRIORITY HIGH-ish but not a bug 🐛 — Investigate options for asynchronous processing in R Shiny (espec for speed / performance at launch)
- [#22](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/22) | Cost 3 / Benefit 16 | PRIORITY HIGH-ish but not a bug 🐛 — Provide/enhance EJAM API
- [#226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | Cost 7 / Benefit 16 | PRIORITY HIGH-ish but not a bug 🐛 — NOTES on SPEEDING UP app &amp; functions (incl load testing)
- [#241](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/241) | Cost 3 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — provide ratios to avg in community report for more indicators (such as %speaking each language)
- [#153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | Cost 4 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — revisit work in progress on this list of .R files
- [#193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | Cost 6 / Benefit 15 | PRIORITY HIGH-ish but not a bug 🐛 — Create Executive Summary helper functions - summarizer / Methods for Identifying and Focusing on Key Findings
- [#319](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/319) | Cost 3 / Benefit 13 | PRIORITY MEDIUM 🐛 — fix err msg for FIPS with no available boundaries info in app, or polygon that is too small or bad geom
- [#68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | Cost 4 / Benefit 13 | PRIORITY HIGH-ish but not a bug 🐛 — allow user to type in radius not only use slider
- [#65](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/65) | Cost 4 / Benefit 13 | PRIORITY HIGH-ish but not a bug 🐛 — include AREA (square miles area) as an output for SHAPEFILE and FIPS analyses too
- [#46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | Cost 8 / Benefit 13 | PRIORITY HIGH-ish but not a bug 🐛 — Long Report text needed
- [#20](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/20) | Cost 5 / Benefit 12 | PRIORITY HIGH-ish but not a bug 🐛 — Need to update to using latest demographic data (from Census ACS5)
- [#135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | Cost 4 / Benefit 11 | PRIORITY MEDIUM 🐛 — finish work in progress on default_ss_choose_method  vs input$ ?
- [#48](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/48) | Cost 8 / Benefit 11 | PRIORITY MEDIUM 🐛 — URLs / links to EJScreen reports for shapefile analysis
- [#73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | Cost 3 / Benefit 10 | PRIORITY MEDIUM — in web app, add ways to analyze multiple radii at once or even continuous radius
- [#279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | Cost 5 / Benefit 10 | PRIORITY MEDIUM — Prepare the package to submit to CRAN (and get it accepted for hosting on CRAN)
- [#87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | Cost 6 / Benefit 10 | PRIORITY MEDIUM — Enable shiny.telemetry log file that is not just a text file on server
- [#171](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/171) | Cost 4 / Benefit 9 | PRIORITY MEDIUM — enhance ejamit() to allow params lat,lon
- [#31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | Cost 4 / Benefit 9 | PRIORITY MEDIUM 🐛 — fix distance_avg in doaggregate()$results_bybg_people
- [#56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | Cost 6 / Benefit 9 | PRIORITY MEDIUM 🐛 — check/ fix Distance and Site Count summary stats, in doaggregate()
- [#103](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/103) | Cost 4 / Benefit 8 | PRIORITY MEDIUM 🐛 — results_summarized$rows percentiles info needs debugging, or stop using it
- [#101](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/101) | Cost 5 / Benefit 8 | PRIORITY MEDIUM — Enable printing reports of analysis speed to console
- [#86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | Cost 6 / Benefit 8 | PRIORITY LOW 🐛 — Fix (or remove?) references to ejampackages data object
- [#255](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/255) | Cost 7 / Benefit 8 | PRIORITY LOW 🐛 — fix warning seen when reinstalling from source, about some arrow data files not found in ejamdata repo
- [#159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | Cost 3 / Benefit 7 | PRIORITY MEDIUM — integrate file-naming function and header-creating functions
- [#172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | Cost 4 / Benefit 7 | PRIORITY MEDIUM — create "sites_from_anything" func to allow any types of inputs specifying any types of places
- [#82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | Cost 4 / Benefit 7 | PRIORITY MEDIUM — confusing UI: a user names the analysis #1, then forgets to change title when runs 2d analysis
- [#81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | Cost 4 / Benefit 7 | PRIORITY MEDIUM — confusion in UI: if user tries a second analysis by uploading new stuff, they sometimes click on See Results instead of reclicking "Start Analysis" 
- [#192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | Cost 5 / Benefit 7 | PRIORITY MEDIUM — User-specified indicators (enable upload of and reporting on user-provided block group indicators)
- [#167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | Cost 5 / Benefit 7 | PRIORITY MEDIUM — review and reduce or fix pkg dependencies
- [#34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | Cost 6 / Benefit 7 | PRIORITY MEDIUM — Remove extraneous comments from Shiny app scripts
- [#170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | Cost 7 / Benefit 7 | PRIORITY MEDIUM — refactor/rename inconsistent function names that contain state_fips or state_abbrev
- [#37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | Cost 7 / Benefit 7 | PRIORITY MEDIUM — MODULE: make a Shiny module for typing in lat/lon values
- [#168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | Cost 8 / Benefit 7 | PRIORITY MEDIUM — refactor/reconcile "report_logo" vs "logo_path" (parameters and/or global defaults
- [#256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | Cost 9 / Benefit 7 | PRIORITY MEDIUM — speed up some functions by using .arrow not .rda version of each large dataset more consistently
- [#169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | Cost 9 / Benefit 7 | PRIORITY MEDIUM — harmonize/refactor functions that create or sanitize filenames, paths

| # | Issue | Cost | Benefit | Priority | Labels (key) |
|---|-------|------|---------|----------|--------------|
| [293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | API takes too long to create a community report from when user clicks | 5 (🟠 Medium) | 19 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | speed / performance (see #226), Affects Web App, API |
| [284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | resolve warning about datum, in logs/console, when web app tries to up… | 3 (🟡 Low) | 17 (🟥 Very High) | PRIORITY LOW | Affects Web App |
| [52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | Create density score /proximity score/ count-nearby functions, then pr… | 8 (🔴 High) | 17 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | distance-related, future plan list |
| [321](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/321) | resolve differences between EPA ejscreen indicators from the ACS (demo… | 14 (⛔ Very High) | 17 (🟥 Very High) | PRIORITY HIGH | BUG, calculate/validate to EJScreen, datasets-related, Affects Web App |
| [320](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/320) | resolve differences between EPA percentiles table and data pipeline ef… | 14 (⛔ Very High) | 17 (🟥 Very High) | PRIORITY HIGH | BUG, calculate/validate to EJScreen, datasets-related, Affects Web App |
| [44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | Investigate options for asynchronous processing in R Shiny (espec for … | 18 (⛔ Very High) | 17 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | datasets-related, speed / performance (see #226), API |
| [22](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/22) | Provide/enhance EJAM API | 3 (🟡 Low) | 16 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | help wanted, API, future plan list |
| [226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | NOTES on SPEEDING UP app &amp; functions (incl load testing) | 7 (🔴 High) | 16 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | speed / performance (see #226), Affects Web App |
| [241](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/241) | provide ratios to avg in community report for more indicators (such as… | 3 (🟡 Low) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | Affects Web App, Community Report |
| [153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | revisit work in progress on this list of .R files | 4 (🟠 Medium) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | test, Affects Web App |
| [193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | Create Executive Summary helper functions - summarizer / Methods for I… | 6 (🟠 Medium) | 15 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | LongReport_output, Affects Web App, future plan list |
| [319](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/319) | fix err msg for FIPS with no available boundaries info in app, or poly… | 3 (🟡 Low) | 13 (🟥 Very High) | PRIORITY MEDIUM | BUG, help wanted, good first issue, Affects Web App |
| [68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | allow user to type in radius not only use slider | 4 (🟠 Medium) | 13 (🟥 Very High) | PRIORITY HIGH-ish but not a bug |  |
| [65](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/65) | include AREA (square miles area) as an output for SHAPEFILE and FIPS a… | 4 (🟠 Medium) | 13 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | shapefile-related |
| [46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | Long Report text needed | 8 (🔴 High) | 13 (🟥 Very High) | PRIORITY HIGH-ish but not a bug | LongReport_output, future plan list |
| [20](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/20) | Need to update to using latest demographic data (from Census ACS5) | 5 (🟠 Medium) | 12 (🟧 High) | PRIORITY HIGH-ish but not a bug | datasets-related |
| [135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | finish work in progress on default_ss_choose_method  vs input$ ? | 4 (🟠 Medium) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, Affects R users only - NOT web app users |
| [48](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/48) | URLs / links to EJScreen reports for shapefile analysis | 8 (🔴 High) | 11 (🟧 High) | PRIORITY MEDIUM | BUG, shapefile-related, refactor, URL-related |
| [73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | in web app, add ways to analyze multiple radii at once or even continu… | 3 (🟡 Low) | 10 (🟧 High) | PRIORITY MEDIUM | Affects Web App |
| [279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | Prepare the package to submit to CRAN (and get it accepted for hosting… | 5 (🟠 Medium) | 10 (🟧 High) | PRIORITY MEDIUM | help wanted, Affects R users only - NOT web app users |
| [87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | Enable shiny.telemetry log file that is not just a text file on server | 6 (🟠 Medium) | 10 (🟧 High) | PRIORITY MEDIUM | datasets-related, Affects Web App |
| [171](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/171) | enhance ejamit() to allow params lat,lon | 4 (🟠 Medium) | 9 (🟧 High) | PRIORITY MEDIUM | refactor, Affects R users only - NOT web app users, API |
| [31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | fix distance_avg in doaggregate()$results_bybg_people | 4 (🟠 Medium) | 9 (🟧 High) | PRIORITY MEDIUM | BUG, distance-related |
| [56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | check/ fix Distance and Site Count summary stats, in doaggregate() | 6 (🟠 Medium) | 9 (🟧 High) | PRIORITY MEDIUM | BUG, documentation, calculate/validate to EJScreen, distance-related |
| [103](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/103) | results_summarized$rows percentiles info needs debugging, or stop usin… | 4 (🟠 Medium) | 8 (🟨 Medium) | PRIORITY MEDIUM | BUG, still relevant? |
| [101](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/101) | Enable printing reports of analysis speed to console | 5 (🟠 Medium) | 8 (🟨 Medium) | PRIORITY MEDIUM | speed / performance (see #226), Affects R users only - NOT web app users |
| [86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | Fix (or remove?) references to ejampackages data object | 6 (🟠 Medium) | 8 (🟨 Medium) | PRIORITY LOW | BUG, still relevant?, refactor, Affects R users only - NOT web app users |
| [255](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/255) | fix warning seen when reinstalling from source, about some arrow data … | 7 (🔴 High) | 8 (🟨 Medium) | PRIORITY LOW | BUG, datasets-related, Affects R users only - NOT web app users |
| [159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | integrate file-naming function and header-creating functions | 3 (🟡 Low) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, Affects Web App, Community Report |
| [172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | create "sites_from_anything" func to allow any types of inputs specify… | 4 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, Affects R users only - NOT web app users |
| [82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | confusing UI: a user names the analysis #1, then forgets to change tit… | 4 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | still relevant?, Affects Web App |
| [81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | confusion in UI: if user tries a second analysis by uploading new stuf… | 4 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | still relevant?, Affects Web App |
| [192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | User-specified indicators (enable upload of and reporting on user-prov… | 5 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | Affects Web App, future plan list |
| [167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | review and reduce or fix pkg dependencies | 5 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, dependencies-related, Affects R users only - NOT web app users |
| [34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | Remove extraneous comments from Shiny app scripts | 6 (🟠 Medium) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, server |
| [170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | refactor/rename inconsistent function names that contain state_fips or… | 7 (🔴 High) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, Affects R users only - NOT web app users |
| [37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | MODULE: make a Shiny module for typing in lat/lon values | 7 (🔴 High) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, server |
| [168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | refactor/reconcile "report_logo" vs "logo_path" (parameters and/or glo… | 8 (🔴 High) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, Affects R users only - NOT web app users, Community Report |
| [256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | speed up some functions by using .arrow not .rda version of each large… | 9 (🔴 High) | 7 (🟨 Medium) | PRIORITY MEDIUM | datasets-related, speed / performance (see #226), Affects Web App |
| [169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | harmonize/refactor functions that create or sanitize filenames, paths | 9 (🔴 High) | 7 (🟨 Medium) | PRIORITY MEDIUM | refactor, Affects R users only - NOT web app users |

---

## Quadrant C — Might As Well — Low Cost, Low Benefit
*Cheap to do; low urgency. Pick these up when bandwidth allows or combine with nearby work.*

**23 issues**

- [#283](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/283) | Cost 1 / Benefit 6 | PRIORITY LOW — resolve warning about logo file, in logs/console, when web app tries to create community report
- [#102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | Cost 0 / Benefit 5 | PRIORITY LOW — Remove NA console messages from `doaggregate`
- [#96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | Cost 2 / Benefit 5 | PRIORITY LOW — Detailed Table UI Filtering improvements
- [#94](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/94) | Cost 2 / Benefit 5 | PRIORITY LOW — popup in summary report map has too many indicators?
- [#92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | Cost 2 / Benefit 5 | PRIORITY LOW — Excel's new tab with upload needs cap on size
- [#78](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/78) | Cost 2 / Benefit 5 | PRIORITY LOW — Add info message to radius slider label on hover/click
- [#71](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/71) | Cost 2 / Benefit 5 | PRIORITY MEDIUM — allow user to see the newer more flexible barplot ratios functions and to interactively change parameters so they can plot whatever variables etc.
- [#69](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/69) | Cost 2 / Benefit 5 | PRIORITY MEDIUM — enable other units like kilometers for entry of radius
- [#58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | Cost 2 / Benefit 5 | PRIORITY MEDIUM — joining FIPS upload data to preview table
- [#177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | Cost 0 / Benefit 4 | PRIORITY LOW — pick which approach is faster among functions like sf_nearest_points() and related
- [#176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | Cost 0 / Benefit 4 | PRIORITY LOW — popups reports in county case are not normal/ignore reports settings?
- [#175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | Cost 0 / Benefit 4 | PRIORITY LOW — drop the excel column called "Area of block group in geodatabase" and others
- [#173](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/173) | Cost 0 / Benefit 4 | PRIORITY LOW — adjust logo in excel version of summary report so it looks correct
- [#328](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/328) | Cost 2 / Benefit 4 | PRIORITY LOW — Finalize and test plot_vs_us() production behavior
- [#16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | Cost 2 / Benefit 4 | — 🐛 — need new/updated "User Guide" ("Help" in header at right) since UI has changed a lot, etc.
- [#179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | Cost 0 / Benefit 3 | PRIORITY LOW — in ejam2excel() rename parameter fname to filename for consistency w other functions
- [#174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | Cost 0 / Benefit 3 | PRIORITY LOW — round to only 1 digit the area in square miles in header of summary report
- [#181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | Cost 1 / Benefit 2 | PRIORITY LOW — add other ejam2xyz functions to basics.Rmd as examples
- [#93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | Cost 2 / Benefit 2 | PRIORITY LOW — make Demog. section of summary report table more visually prominent
- [#59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | Cost 2 / Benefit 2 | PRIORITY LOW — Improve MACT-related  lat lon data
- [#285](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/285) | Cost 0 / Benefit 1 | — 🐛 — update README links
- [#183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | Cost 0 / Benefit 0 | PRIORITY LOW — use more standardized format in NEWS / changelog?
- [#42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | Cost 1 / Benefit 0 | PRIORITY LOW — Remove unused report template files

| # | Issue | Cost | Benefit | Priority | Labels (key) |
|---|-------|------|---------|----------|--------------|
| [283](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/283) | resolve warning about logo file, in logs/console, when web app tries t… | 1 (🟢 Very Low) | 6 (🟨 Medium) | PRIORITY LOW | Affects Web App |
| [102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | Remove NA console messages from `doaggregate` | 0 (🟢 Very Low) | 5 (🟨 Medium) | PRIORITY LOW | Affects R users only - NOT web app users |
| [96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | Detailed Table UI Filtering improvements | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY LOW | Affects Web App |
| [94](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/94) | popup in summary report map has too many indicators? | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY LOW | map-popups-related, Affects Web App |
| [92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | Excel's new tab with upload needs cap on size | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY LOW | Affects Web App |
| [78](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/78) | Add info message to radius slider label on hover/click | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY LOW | distance-related, Affects Web App |
| [71](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/71) | allow user to see the newer more flexible barplot ratios functions and… | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY MEDIUM | plots-graphs-related |
| [69](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/69) | enable other units like kilometers for entry of radius | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY MEDIUM |  |
| [58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | joining FIPS upload data to preview table | 2 (🟡 Low) | 5 (🟨 Medium) | PRIORITY MEDIUM |  |
| [177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | pick which approach is faster among functions like sf_nearest_points()… | 0 (🟢 Very Low) | 4 (🟦 Low) | PRIORITY LOW | Affects Web App |
| [176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | popups reports in county case are not normal/ignore reports settings? | 0 (🟢 Very Low) | 4 (🟦 Low) | PRIORITY LOW | Affects Web App, Community Report |
| [175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | drop the excel column called "Area of block group in geodatabase" and … | 0 (🟢 Very Low) | 4 (🟦 Low) | PRIORITY LOW | Affects Web App |
| [173](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/173) | adjust logo in excel version of summary report so it looks correct | 0 (🟢 Very Low) | 4 (🟦 Low) | PRIORITY LOW | Affects Web App, Community Report |
| [328](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/328) | Finalize and test plot_vs_us() production behavior | 2 (🟡 Low) | 4 (🟦 Low) | PRIORITY LOW | plots-graphs-related, Affects R users only - NOT web app users |
| [16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | need new/updated "User Guide" ("Help" in header at right) since UI has… | 2 (🟡 Low) | 4 (🟦 Low) | — | BUG, documentation, help wanted, good first issue |
| [179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | in ejam2excel() rename parameter fname to filename for consistency w o… | 0 (🟢 Very Low) | 3 (🟦 Low) | PRIORITY LOW | refactor, Affects R users only - NOT web app users |
| [174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | round to only 1 digit the area in square miles in header of summary re… | 0 (🟢 Very Low) | 3 (🟦 Low) | PRIORITY LOW | Affects Web App, Community Report |
| [181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | add other ejam2xyz functions to basics.Rmd as examples | 1 (🟢 Very Low) | 2 (🟦 Low) | PRIORITY LOW | documentation, refactor, Affects R users only - NOT web app users |
| [93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | make Demog. section of summary report table more visually prominent | 2 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW | Community Report |
| [59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | Improve MACT-related  lat lon data | 2 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW |  |
| [285](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/285) | update README links | 0 (🟢 Very Low) | 1 (⬜ Very Low) | — | BUG, documentation, URL-related |
| [183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | use more standardized format in NEWS / changelog? | 0 (🟢 Very Low) | 0 (⬜ Very Low) | PRIORITY LOW | documentation, refactor, Affects R users only - NOT web app users |
| [42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | Remove unused report template files | 1 (🟢 Very Low) | 0 (⬜ Very Low) | PRIORITY LOW | Community Report |

---

## Quadrant D — WORST CANDIDATES — High Cost, Low Benefit
*Expensive to fix, limited payoff. Defer or deprioritize unless circumstances change.*

**49 issues**

- [#224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | Cost 3 / Benefit 5 | PRIORITY LOW 🐛 — report correct population for a single block (if block is analyzed via block fips code)
- [#40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | Cost 3 / Benefit 5 | PRIORITY MEDIUM — Allow abort site selection processing when selections are changed
- [#242](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/242) | Cost 3 / Benefit 4 | PRIORITY MEDIUM — Report should show ratios to avg for special indicators like
- [#184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | Cost 3 / Benefit 2 | PRIORITY LOW — trim the extremely long unit test names
- [#43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | Cost 3 / Benefit 2 | PRIORITY LOW — Enable fast site selection map during category scrolling
- [#41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | Cost 3 / Benefit 2 | PRIORITY LOW — Include indicator formulas in Community Report
- [#39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | Cost 3 / Benefit 2 | PRIORITY LOW — Review/revise/expand unit testing for SIC functions
- [#60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | Cost 3 / Benefit 0 | PRIORITY LOW — Rename community report functions with common convention
- [#83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | Cost 4 / Benefit 5 | PRIORITY LOW — enable selecting a folder as way to upload shapefile(s)
- [#74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | Cost 4 / Benefit 5 | PRIORITY MEDIUM — Develop options for defining the Reference Zone or Ref. Group - avg person vs bg vs "other 3-mile circles" - in rural, county, user-defined etc.
- [#72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | Cost 4 / Benefit 5 | PRIORITY MEDIUM — find a way to map more polygons (than just 159 cap)
- [#26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | Cost 4 / Benefit 5 | PRIORITY MEDIUM — Create LongReport (quarto/word doc/TSD) Settings Panel
- [#182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | Cost 4 / Benefit 4 | PRIORITY LOW — consider refactoring url_xyz functions
- [#89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | Cost 4 / Benefit 4 | PRIORITY LOW — clarify what "N places" really means &amp; report on the selection type (in summary report etc.)
- [#49](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/49) | Cost 4 / Benefit 2 | PRIORITY LOW — URLs / links to EJScreen reports for FIPS analysis other than counties - need these to work
- [#35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | Cost 4 / Benefit 2 | PRIORITY LOW — Review/revise/expand unit testing for URL functions
- [#64](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/64) | Cost 4 / Benefit 1 | PRIORITY LOW — lat lon Latitude Longitude duplicative indicators in ejscreenit()$table
- [#62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | Cost 4 / Benefit 1 | PRIORITY LOW — Enable download of 'Plot of Average Scores' and 'Plot Full Range of Scores' plots
- [#61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | Cost 4 / Benefit 1 | PRIORITY LOW — downloading excel output with plots for 1000-2000 points takes 10-15 seconds
- [#55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | Cost 4 / Benefit 1 | PRIORITY LOW — add links to COUNTY-LEVEL reports - on a place - from other tools/ sources
- [#194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | Cost 5 / Benefit 6 | PRIORITY MEDIUM — Create visualizations of overall results in app  - engaging &amp; insightful
- [#33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | Cost 5 / Benefit 5 | PRIORITY MEDIUM — Move HTML, CSS, and Javascript code into appropriate external files
- [#331](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/331) | Cost 5 / Benefit 0 | — — Replicate 2022 EJScreen-ready dataset via pipeline
- [#80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | Cost 6 / Benefit 5 | PRIORITY LOW — make latlon_from_naics() and other naics-related functions consistent with others like frs_from_naics()
- [#77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | Cost 6 / Benefit 5 | PRIORITY MEDIUM — MODULE: Point layer MODULE (specify URL of service with point data)
- [#75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | Cost 6 / Benefit 5 | PRIORITY MEDIUM — "Schools Counter" functionality needed (to count schools or other features in each place)
- [#19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | Cost 6 / Benefit 4 | — 🐛 — FIPS missing/problems (mostly in Connecticut)
- [#76](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/76) | Cost 6 / Benefit 2 | PRIORITY LOW — MODULE: Points table upload MODULE
- [#53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | Cost 6 / Benefit 2 | PRIORITY LOW — for proximity score creation tool, resolve how to apply short distances formula (continuous or abrupt)
- [#27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | Cost 6 / Benefit 2 | PRIORITY LOW — add ability to save/load/bookmark static report settings (the parameters)
- [#231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | Cost 6 / Benefit 1 | PRIORITY LOW — fix frs_by_mact.arrow and /data/mact_table to remove leading and extra spaces
- [#63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | Cost 6 / Benefit 1 | PRIORITY LOW — Fix use of mapping_for_names parameter
- [#180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | Cost 7 / Benefit 4 | PRIORITY LOW — refactor functions handling sitepoints (espec in url_ functions?)
- [#18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | Cost 7 / Benefit 0 | — — some FIPS-related functions/data could be improved
- [#84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | Cost 8 / Benefit 5 | PRIORITY LOW — enable an Add Data tool or otherwise harmonize with geoplatform, ejscreen, enviroatlas, echo, etc. to view or link to other layers
- [#67](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/67) | Cost 8 / Benefit 5 | PRIORITY MEDIUM — improve use of global environment, data files, global.R, and maybe even param/config settings 
- [#57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | Cost 8 / Benefit 5 | PRIORITY MEDIUM — Enable analysis of VERY large numbers of points - test limits and code solutions like batching, etc
- [#50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | Cost 8 / Benefit 5 | PRIORITY MEDIUM — plotting functions all need review/ consolidation/ improvement/ renaming/ testing
- [#95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | Cost 8 / Benefit 4 | PRIORITY LOW — in map_headernames, consider adding info re: in which tables/ popups/ xls/ etc. should given indicator be included
- [#29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | Cost 8 / Benefit 3 | PRIORITY LOW — add info about zero results/ zero pop &amp; near other sites, to EJAM::doaggregate() outputs (as already provided by EJAMejscreenapi::ejscreenapi() output)
- [#54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | Cost 9 / Benefit 6 | PRIORITY LOW 🐛 — correctly handle cases where the adjusted distance (via block_radius_miles) is &gt; radius the user specified
- [#38](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/38) | Cost 9 / Benefit 2 | PRIORITY LOW — MODULE? Review/revise/expand unit testing for shapefile functions
- [#28](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/28) | Cost 9 / Benefit 1 | — — for each siteid, add ST, statename, and REGION columns to EJAM::doaggregate() outputs (as already provided by EJAMejscreenapi::ejscreenapi() output)
- [#66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | Cost 10 / Benefit 6 | PRIORITY LOW 🐛 — EJAM &amp; EJScreen report on avg PERSON generally but State Average or US Avg shown is avg BLOCK GROUP ! Decide how to reconcile this.
- [#32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | Cost 11 / Benefit 5 | PRIORITY MEDIUM — *** MOVE CODE OUT OF SERVER and app_ui
- [#85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | Cost 12 / Benefit 5 | PRIORITY LOW — Enable higher resolution analysis than getblocksnearby() does, via Dasymetric mapping
- [#51](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/51) | Cost 12 / Benefit 5 | PRIORITY LOW 🐛 — Confirm/fix what formula to use for state percentiles in overall summary
- [#45](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/45) | Cost 12 / Benefit 5 | PRIORITY MEDIUM — Replicating EJScreen: MAKE EJAM REPLICATE EJSCREEN RESULTS (overview of issues/tasks)
- [#25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | Cost 12 / Benefit 1 | PRIORITY LOW — Enable areal apportionment as option, via existing OW and/or OP code

| # | Issue | Cost | Benefit | Priority | Labels (key) |
|---|-------|------|---------|----------|--------------|
| [224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | report correct population for a single block (if block is analyzed via… | 3 (🟡 Low) | 5 (🟨 Medium) | PRIORITY LOW | BUG |
| [40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | Allow abort site selection processing when selections are changed | 3 (🟡 Low) | 5 (🟨 Medium) | PRIORITY MEDIUM |  |
| [242](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/242) | Report should show ratios to avg for special indicators like | 3 (🟡 Low) | 4 (🟦 Low) | PRIORITY MEDIUM | Community Report |
| [184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | trim the extremely long unit test names | 3 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW | documentation, refactor, Affects R users only - NOT web app users |
| [43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | Enable fast site selection map during category scrolling | 3 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW | maps-related |
| [41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | Include indicator formulas in Community Report | 3 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW | Community Report |
| [39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | Review/revise/expand unit testing for SIC functions | 3 (🟡 Low) | 2 (🟦 Low) | PRIORITY LOW | test |
| [60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | Rename community report functions with common convention | 3 (🟡 Low) | 0 (⬜ Very Low) | PRIORITY LOW | documentation, refactor, server, Community Report |
| [83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | enable selecting a folder as way to upload shapefile(s) | 4 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY LOW | shapefile-related, Affects Web App |
| [74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | Develop options for defining the Reference Zone or Ref. Group - avg pe… | 4 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM |  |
| [72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | find a way to map more polygons (than just 159 cap) | 4 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM | shapefile-related, maps-related |
| [26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | Create LongReport (quarto/word doc/TSD) Settings Panel | 4 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM | LongReport_output |
| [182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | consider refactoring url_xyz functions | 4 (🟠 Medium) | 4 (🟦 Low) | PRIORITY LOW | refactor, Affects R users only - NOT web app users |
| [89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | clarify what "N places" really means &amp; report on the selection typ… | 4 (🟠 Medium) | 4 (🟦 Low) | PRIORITY LOW | still relevant?, Affects Web App |
| [49](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/49) | URLs / links to EJScreen reports for FIPS analysis other than counties… | 4 (🟠 Medium) | 2 (🟦 Low) | PRIORITY LOW | refactor, URL-related |
| [35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | Review/revise/expand unit testing for URL functions | 4 (🟠 Medium) | 2 (🟦 Low) | PRIORITY LOW | test, URL-related |
| [64](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/64) | lat lon Latitude Longitude duplicative indicators in ejscreenit()$tabl… | 4 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | still relevant? |
| [62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | Enable download of 'Plot of Average Scores' and 'Plot Full Range of Sc… | 4 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | still relevant?, plots-graphs-related |
| [61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | downloading excel output with plots for 1000-2000 points takes 10-15 s… | 4 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | still relevant? |
| [55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | add links to COUNTY-LEVEL reports - on a place - from other tools/ sou… | 4 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | still relevant? |
| [194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | Create visualizations of overall results in app  - engaging &amp; insi… | 5 (🟠 Medium) | 6 (🟨 Medium) | PRIORITY MEDIUM | plots-graphs-related, future plan list |
| [33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | Move HTML, CSS, and Javascript code into appropriate external files | 5 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM | refactor, server |
| [331](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/331) | Replicate 2022 EJScreen-ready dataset via pipeline | 5 (🟠 Medium) | 0 (⬜ Very Low) | — |  |
| [80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | make latlon_from_naics() and other naics-related functions consistent … | 6 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY LOW | refactor, Affects R users only - NOT web app users |
| [77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | MODULE: Point layer MODULE (specify URL of service with point data) | 6 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM | refactor, server |
| [75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | "Schools Counter" functionality needed (to count schools or other feat… | 6 (🟠 Medium) | 5 (🟨 Medium) | PRIORITY MEDIUM | shapefile-related, refactor, distance-related |
| [19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | FIPS missing/problems (mostly in Connecticut) | 6 (🟠 Medium) | 4 (🟦 Low) | — | BUG, help wanted, datasets-related |
| [76](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/76) | MODULE: Points table upload MODULE | 6 (🟠 Medium) | 2 (🟦 Low) | PRIORITY LOW | refactor, server |
| [53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | for proximity score creation tool, resolve how to apply short distance… | 6 (🟠 Medium) | 2 (🟦 Low) | PRIORITY LOW | calculate/validate to EJScreen, distance-related |
| [27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | add ability to save/load/bookmark static report settings (the paramete… | 6 (🟠 Medium) | 2 (🟦 Low) | PRIORITY LOW | refactor, Community Report |
| [231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | fix frs_by_mact.arrow and /data/mact_table to remove leading and extra… | 6 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | datasets-related |
| [63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | Fix use of mapping_for_names parameter | 6 (🟠 Medium) | 1 (⬜ Very Low) | PRIORITY LOW | still relevant?, refactor |
| [180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | refactor functions handling sitepoints (espec in url_ functions?) | 7 (🔴 High) | 4 (🟦 Low) | PRIORITY LOW | refactor, Affects R users only - NOT web app users |
| [18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | some FIPS-related functions/data could be improved | 7 (🔴 High) | 0 (⬜ Very Low) | — | datasets-related |
| [84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | enable an Add Data tool or otherwise harmonize with geoplatform, ejscr… | 8 (🔴 High) | 5 (🟨 Medium) | PRIORITY LOW | shapefile-related, Affects Web App |
| [67](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/67) | improve use of global environment, data files, global.R, and maybe eve… | 8 (🔴 High) | 5 (🟨 Medium) | PRIORITY MEDIUM | refactor, datasets-related |
| [57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | Enable analysis of VERY large numbers of points - test limits and code… | 8 (🔴 High) | 5 (🟨 Medium) | PRIORITY MEDIUM | tasklist, speed / performance (see #226) |
| [50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | plotting functions all need review/ consolidation/ improvement/ renami… | 8 (🔴 High) | 5 (🟨 Medium) | PRIORITY MEDIUM | refactor, server, speed / performance (see #226), plots-graphs-related |
| [95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | in map_headernames, consider adding info re: in which tables/ popups/ … | 8 (🔴 High) | 4 (🟦 Low) | PRIORITY LOW | map-popups-related, still relevant?, datasets-related, Affects R users only - NOT web app users |
| [29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | add info about zero results/ zero pop &amp; near other sites, to EJAM:… | 8 (🔴 High) | 3 (🟦 Low) | PRIORITY LOW | still relevant?, refactor |
| [54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | correctly handle cases where the adjusted distance (via block_radius_m… | 9 (🔴 High) | 6 (🟨 Medium) | PRIORITY LOW | BUG, calculate/validate to EJScreen, distance-related |
| [38](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/38) | MODULE? Review/revise/expand unit testing for shapefile functions | 9 (🔴 High) | 2 (🟦 Low) | PRIORITY LOW | shapefile-related, refactor, server, test |
| [28](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/28) | for each siteid, add ST, statename, and REGION columns to EJAM::doaggr… | 9 (🔴 High) | 1 (⬜ Very Low) | — | still relevant?, refactor |
| [66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | EJAM &amp; EJScreen report on avg PERSON generally but State Average o… | 10 (🔴 High) | 6 (🟨 Medium) | PRIORITY LOW | BUG, calculate/validate to EJScreen, Community Report |
| [32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | *** MOVE CODE OUT OF SERVER and app_ui | 11 (⛔ Very High) | 5 (🟨 Medium) | PRIORITY MEDIUM | refactor, tasklist, server |
| [85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | Enable higher resolution analysis than getblocksnearby() does, via Das… | 12 (⛔ Very High) | 5 (🟨 Medium) | PRIORITY LOW | shapefile-related, maps-related, Affects Web App, future plan list |
| [51](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/51) | Confirm/fix what formula to use for state percentiles in overall summa… | 12 (⛔ Very High) | 5 (🟨 Medium) | PRIORITY LOW | BUG, still relevant?, refactor, calculate/validate to EJScreen |
| [45](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/45) | Replicating EJScreen: MAKE EJAM REPLICATE EJSCREEN RESULTS (overview o… | 12 (⛔ Very High) | 5 (🟨 Medium) | PRIORITY MEDIUM | calculate/validate to EJScreen, distance-related, test |
| [25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | Enable areal apportionment as option, via existing OW and/or OP code | 12 (⛔ Very High) | 1 (⬜ Very Low) | PRIORITY LOW | shapefile-related, still relevant? |

---

## Full Table — All 151 Issues

Sorted: A first (best), then B, C, D; within each group by benefit DESC.

| Quad | Issue # | Cost | Benefit | Priority | Title |
|------|---------|------|---------|----------|-------|
| A | [#126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | 2 | 23 | PRIORITY HIGH | enable API query for 1-site or multisite report on Polygons / Shapefile,… |
| A | [#123](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/123) | 1 | 21 | PRIORITY HIGH | enable API-query URLs to encode a large polygon in excel download of res… |
| A | [#154](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/154) | 0 | 19 | PRIORITY HIGH-ish but not a bug | Enable pdf output option for ejam2report() and/or in API |
| A | [#149](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/149) | 1 | 19 | PRIORITY HIGH-ish but not a bug | remove sitenumber=-1 in output of url_ejamapi() for fips case at least |
| A | [#155](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/155) | 2 | 19 | PRIORITY HIGH-ish but not a bug | revisit draft work in progress on API (see branch) |
| A | [#156](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/156) | 0 | 17 | PRIORITY HIGH-ish but not a bug | in app - add view of   ejam2areafeatures(out)  (info on % of pop with ce… |
| A | [#142](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/142) | 0 | 17 | PRIORITY MEDIUM | ejam2map() fails on shapefile case using sitenumber parameter |
| A | [#152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | 0 | 15 | PRIORITY HIGH-ish but not a bug | build_community_report() needs unit tests, table_signif_round_x100() or … |
| A | [#148](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/148) | 0 | 15 | PRIORITY HIGH-ish but not a bug | in excel, have freeze columns apply to the correct columns |
| A | [#150](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/150) | 1 | 15 | PRIORITY HIGH-ish but not a bug | shp case map popups should not include "Area within 0 miles of site" nor… |
| A | [#292](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/292) | 2 | 15 | PRIORITY HIGH-ish but not a bug | use a column heading that is more informative/clear than "invalid_msg" i… |
| A | [#274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | 2 | 15 | PRIORITY HIGH-ish but not a bug | Add the features not yet restored from the pre-2025 EPA version of the C… |
| A | [#205](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/205) | 2 | 15 | PRIORITY HIGH-ish but not a bug | adjust summary report fonts and row heights/line spacing to make text mo… |
| A | [#144](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/144) | 0 | 13 | PRIORITY MEDIUM | use or remove or explain the sitenumber parameter in ejam2map() for fips… |
| A | [#127](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/127) | 0 | 13 | PRIORITY MEDIUM | web app details tab with table of all sites is too sluggish as it appear… |
| A | [#140](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/140) | 1 | 13 | PRIORITY MEDIUM | in app and R functions, handle blockgroup fips better |
| A | [#136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | 1 | 13 | PRIORITY MEDIUM | in web app, fix console  error msg when uploading a shapefile |
| A | [#109](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/109) | 1 | 13 | PRIORITY MEDIUM | Update &amp; correct the article "Defaults and Custom Settings for the W… |
| A | [#249](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/249) | 2 | 12 | PRIORITY LOW | ejam2report() fails if filename is specified without path, or with "./xy… |
| A | [#145](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/145) | 0 | 11 | PRIORITY MEDIUM | fix .onAttach() stumbling on load_all() if add new url_xyz function in g… |
| A | [#143](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/143) | 0 | 11 | PRIORITY MEDIUM | xlsx download:  snapshot image of report in excel tab lacks logo (and up… |
| A | [#141](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/141) | 0 | 11 | PRIORITY MEDIUM | allow user to do library(EJAM) from any other folder  (working dir) not … |
| A | [#130](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/130) | 0 | 11 | PRIORITY MEDIUM | 'basics.html' article needs to be checked / fixed |
| A | [#139](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/139) | 1 | 11 | PRIORITY MEDIUM | The radius parameter gets ignored, but should not, in fips case, where N… |
| A | [#137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | 1 | 11 | PRIORITY MEDIUM | fix bug in popshare_at_top_x_pct() - results sometimes not quite right. … |
| A | [#240](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/240) | 2 | 11 | PRIORITY MEDIUM | Reports need to round off the ratios for climate and health indicators (… |
| A | [#147](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/147) | 0 | 10 | PRIORITY LOW | rlang pkg is imported by shiny and others, but has its own definition of… |
| A | [#164](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/164) | 1 | 9 | PRIORITY MEDIUM | add unit tests for ejam2report() if possible, and others |
| A | [#166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | 2 | 9 | PRIORITY MEDIUM | could simplify polygons before mapping, saving - check if useful and the… |
| A | [#223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | 2 | 8 | PRIORITY LOW | app_title parameter is not working in ejamapp() |
| A | [#208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | 2 | 8 | PRIORITY LOW | check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ejam… |
| A | [#119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | 2 | 8 | PRIORITY LOW | some code assumes RStudio user is in root folder of source package - che… |
| A | [#91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | 2 | 8 | PRIORITY MEDIUM | Excel needs new tab with uploaded places or facilities found |
| A | [#161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | 0 | 7 | PRIORITY MEDIUM | ejamapp() should be able to handle mix of fips types |
| A | [#163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | 1 | 7 | PRIORITY MEDIUM | put certain columns last in table of results (bg count, block count, rad… |
| A | [#162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | 1 | 7 | PRIORITY MEDIUM | rename "in_how_many_states" and "invalid_msg" columns in table of result… |
| A | [#288](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/288) | 2 | 7 | PRIORITY MEDIUM | ratio of 1.0 should not be yellow on community report |
| A | [#70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | 2 | 7 | PRIORITY MEDIUM | set up alerts that monitor and alert staff when the app goes down - ensu… |
| A | [#24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | 2 | 7 | PRIORITY MEDIUM | map popups in make.popups.api() and other functions are too cluttered, m… |
| B | [#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | 5 | 19 | PRIORITY HIGH-ish but not a bug | API takes too long to create a community report from when user clicks |
| B | [#284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | 3 | 17 | PRIORITY LOW | resolve warning about datum, in logs/console, when web app tries to uplo… |
| B | [#52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | 8 | 17 | PRIORITY HIGH-ish but not a bug | Create density score /proximity score/ count-nearby functions, then prov… |
| B | [#321](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/321) | 14 | 17 | PRIORITY HIGH | resolve differences between EPA ejscreen indicators from the ACS (demogr… |
| B | [#320](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/320) | 14 | 17 | PRIORITY HIGH | resolve differences between EPA percentiles table and data pipeline effo… |
| B | [#44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | 18 | 17 | PRIORITY HIGH-ish but not a bug | Investigate options for asynchronous processing in R Shiny (espec for sp… |
| B | [#22](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/22) | 3 | 16 | PRIORITY HIGH-ish but not a bug | Provide/enhance EJAM API |
| B | [#226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | 7 | 16 | PRIORITY HIGH-ish but not a bug | NOTES on SPEEDING UP app &amp; functions (incl load testing) |
| B | [#241](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/241) | 3 | 15 | PRIORITY HIGH-ish but not a bug | provide ratios to avg in community report for more indicators (such as %… |
| B | [#153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | 4 | 15 | PRIORITY HIGH-ish but not a bug | revisit work in progress on this list of .R files |
| B | [#193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | 6 | 15 | PRIORITY HIGH-ish but not a bug | Create Executive Summary helper functions - summarizer / Methods for Ide… |
| B | [#319](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/319) | 3 | 13 | PRIORITY MEDIUM | fix err msg for FIPS with no available boundaries info in app, or polygo… |
| B | [#68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | 4 | 13 | PRIORITY HIGH-ish but not a bug | allow user to type in radius not only use slider |
| B | [#65](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/65) | 4 | 13 | PRIORITY HIGH-ish but not a bug | include AREA (square miles area) as an output for SHAPEFILE and FIPS ana… |
| B | [#46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | 8 | 13 | PRIORITY HIGH-ish but not a bug | Long Report text needed |
| B | [#20](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/20) | 5 | 12 | PRIORITY HIGH-ish but not a bug | Need to update to using latest demographic data (from Census ACS5) |
| B | [#135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | 4 | 11 | PRIORITY MEDIUM | finish work in progress on default_ss_choose_method  vs input$ ? |
| B | [#48](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/48) | 8 | 11 | PRIORITY MEDIUM | URLs / links to EJScreen reports for shapefile analysis |
| B | [#73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | 3 | 10 | PRIORITY MEDIUM | in web app, add ways to analyze multiple radii at once or even continuou… |
| B | [#279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | 5 | 10 | PRIORITY MEDIUM | Prepare the package to submit to CRAN (and get it accepted for hosting o… |
| B | [#87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | 6 | 10 | PRIORITY MEDIUM | Enable shiny.telemetry log file that is not just a text file on server |
| B | [#171](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/171) | 4 | 9 | PRIORITY MEDIUM | enhance ejamit() to allow params lat,lon |
| B | [#31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | 4 | 9 | PRIORITY MEDIUM | fix distance_avg in doaggregate()$results_bybg_people |
| B | [#56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | 6 | 9 | PRIORITY MEDIUM | check/ fix Distance and Site Count summary stats, in doaggregate() |
| B | [#103](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/103) | 4 | 8 | PRIORITY MEDIUM | results_summarized$rows percentiles info needs debugging, or stop using … |
| B | [#101](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/101) | 5 | 8 | PRIORITY MEDIUM | Enable printing reports of analysis speed to console |
| B | [#86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | 6 | 8 | PRIORITY LOW | Fix (or remove?) references to ejampackages data object |
| B | [#255](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/255) | 7 | 8 | PRIORITY LOW | fix warning seen when reinstalling from source, about some arrow data fi… |
| B | [#159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | 3 | 7 | PRIORITY MEDIUM | integrate file-naming function and header-creating functions |
| B | [#172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | 4 | 7 | PRIORITY MEDIUM | create "sites_from_anything" func to allow any types of inputs specifyin… |
| B | [#82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | 4 | 7 | PRIORITY MEDIUM | confusing UI: a user names the analysis #1, then forgets to change title… |
| B | [#81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | 4 | 7 | PRIORITY MEDIUM | confusion in UI: if user tries a second analysis by uploading new stuff,… |
| B | [#192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | 5 | 7 | PRIORITY MEDIUM | User-specified indicators (enable upload of and reporting on user-provid… |
| B | [#167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | 5 | 7 | PRIORITY MEDIUM | review and reduce or fix pkg dependencies |
| B | [#34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | 6 | 7 | PRIORITY MEDIUM | Remove extraneous comments from Shiny app scripts |
| B | [#170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | 7 | 7 | PRIORITY MEDIUM | refactor/rename inconsistent function names that contain state_fips or s… |
| B | [#37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | 7 | 7 | PRIORITY MEDIUM | MODULE: make a Shiny module for typing in lat/lon values |
| B | [#168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | 8 | 7 | PRIORITY MEDIUM | refactor/reconcile "report_logo" vs "logo_path" (parameters and/or globa… |
| B | [#256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | 9 | 7 | PRIORITY MEDIUM | speed up some functions by using .arrow not .rda version of each large d… |
| B | [#169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | 9 | 7 | PRIORITY MEDIUM | harmonize/refactor functions that create or sanitize filenames, paths |
| C | [#283](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/283) | 1 | 6 | PRIORITY LOW | resolve warning about logo file, in logs/console, when web app tries to … |
| C | [#102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | 0 | 5 | PRIORITY LOW | Remove NA console messages from `doaggregate` |
| C | [#96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | 2 | 5 | PRIORITY LOW | Detailed Table UI Filtering improvements |
| C | [#94](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/94) | 2 | 5 | PRIORITY LOW | popup in summary report map has too many indicators? |
| C | [#92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | 2 | 5 | PRIORITY LOW | Excel's new tab with upload needs cap on size |
| C | [#78](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/78) | 2 | 5 | PRIORITY LOW | Add info message to radius slider label on hover/click |
| C | [#71](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/71) | 2 | 5 | PRIORITY MEDIUM | allow user to see the newer more flexible barplot ratios functions and t… |
| C | [#69](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/69) | 2 | 5 | PRIORITY MEDIUM | enable other units like kilometers for entry of radius |
| C | [#58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | 2 | 5 | PRIORITY MEDIUM | joining FIPS upload data to preview table |
| C | [#177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | 0 | 4 | PRIORITY LOW | pick which approach is faster among functions like sf_nearest_points() a… |
| C | [#176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | 0 | 4 | PRIORITY LOW | popups reports in county case are not normal/ignore reports settings? |
| C | [#175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | 0 | 4 | PRIORITY LOW | drop the excel column called "Area of block group in geodatabase" and ot… |
| C | [#173](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/173) | 0 | 4 | PRIORITY LOW | adjust logo in excel version of summary report so it looks correct |
| C | [#328](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/328) | 2 | 4 | PRIORITY LOW | Finalize and test plot_vs_us() production behavior |
| C | [#16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | 2 | 4 | — | need new/updated "User Guide" ("Help" in header at right) since UI has c… |
| C | [#179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | 0 | 3 | PRIORITY LOW | in ejam2excel() rename parameter fname to filename for consistency w oth… |
| C | [#174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | 0 | 3 | PRIORITY LOW | round to only 1 digit the area in square miles in header of summary repo… |
| C | [#181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | 1 | 2 | PRIORITY LOW | add other ejam2xyz functions to basics.Rmd as examples |
| C | [#93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | 2 | 2 | PRIORITY LOW | make Demog. section of summary report table more visually prominent |
| C | [#59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | 2 | 2 | PRIORITY LOW | Improve MACT-related  lat lon data |
| C | [#285](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/285) | 0 | 1 | — | update README links |
| C | [#183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | 0 | 0 | PRIORITY LOW | use more standardized format in NEWS / changelog? |
| C | [#42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | 1 | 0 | PRIORITY LOW | Remove unused report template files |
| D | [#224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | 3 | 5 | PRIORITY LOW | report correct population for a single block (if block is analyzed via b… |
| D | [#40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | 3 | 5 | PRIORITY MEDIUM | Allow abort site selection processing when selections are changed |
| D | [#242](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/242) | 3 | 4 | PRIORITY MEDIUM | Report should show ratios to avg for special indicators like |
| D | [#184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | 3 | 2 | PRIORITY LOW | trim the extremely long unit test names |
| D | [#43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | 3 | 2 | PRIORITY LOW | Enable fast site selection map during category scrolling |
| D | [#41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | 3 | 2 | PRIORITY LOW | Include indicator formulas in Community Report |
| D | [#39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | 3 | 2 | PRIORITY LOW | Review/revise/expand unit testing for SIC functions |
| D | [#60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | 3 | 0 | PRIORITY LOW | Rename community report functions with common convention |
| D | [#83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | 4 | 5 | PRIORITY LOW | enable selecting a folder as way to upload shapefile(s) |
| D | [#74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | 4 | 5 | PRIORITY MEDIUM | Develop options for defining the Reference Zone or Ref. Group - avg pers… |
| D | [#72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | 4 | 5 | PRIORITY MEDIUM | find a way to map more polygons (than just 159 cap) |
| D | [#26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | 4 | 5 | PRIORITY MEDIUM | Create LongReport (quarto/word doc/TSD) Settings Panel |
| D | [#182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | 4 | 4 | PRIORITY LOW | consider refactoring url_xyz functions |
| D | [#89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | 4 | 4 | PRIORITY LOW | clarify what "N places" really means &amp; report on the selection type … |
| D | [#49](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/49) | 4 | 2 | PRIORITY LOW | URLs / links to EJScreen reports for FIPS analysis other than counties -… |
| D | [#35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | 4 | 2 | PRIORITY LOW | Review/revise/expand unit testing for URL functions |
| D | [#64](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/64) | 4 | 1 | PRIORITY LOW | lat lon Latitude Longitude duplicative indicators in ejscreenit()$table |
| D | [#62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | 4 | 1 | PRIORITY LOW | Enable download of 'Plot of Average Scores' and 'Plot Full Range of Scor… |
| D | [#61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | 4 | 1 | PRIORITY LOW | downloading excel output with plots for 1000-2000 points takes 10-15 sec… |
| D | [#55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | 4 | 1 | PRIORITY LOW | add links to COUNTY-LEVEL reports - on a place - from other tools/ sourc… |
| D | [#194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | 5 | 6 | PRIORITY MEDIUM | Create visualizations of overall results in app  - engaging &amp; insigh… |
| D | [#33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | 5 | 5 | PRIORITY MEDIUM | Move HTML, CSS, and Javascript code into appropriate external files |
| D | [#331](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/331) | 5 | 0 | — | Replicate 2022 EJScreen-ready dataset via pipeline |
| D | [#80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | 6 | 5 | PRIORITY LOW | make latlon_from_naics() and other naics-related functions consistent wi… |
| D | [#77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | 6 | 5 | PRIORITY MEDIUM | MODULE: Point layer MODULE (specify URL of service with point data) |
| D | [#75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | 6 | 5 | PRIORITY MEDIUM | "Schools Counter" functionality needed (to count schools or other featur… |
| D | [#19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | 6 | 4 | — | FIPS missing/problems (mostly in Connecticut) |
| D | [#76](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/76) | 6 | 2 | PRIORITY LOW | MODULE: Points table upload MODULE |
| D | [#53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | 6 | 2 | PRIORITY LOW | for proximity score creation tool, resolve how to apply short distances … |
| D | [#27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | 6 | 2 | PRIORITY LOW | add ability to save/load/bookmark static report settings (the parameters… |
| D | [#231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | 6 | 1 | PRIORITY LOW | fix frs_by_mact.arrow and /data/mact_table to remove leading and extra s… |
| D | [#63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | 6 | 1 | PRIORITY LOW | Fix use of mapping_for_names parameter |
| D | [#180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | 7 | 4 | PRIORITY LOW | refactor functions handling sitepoints (espec in url_ functions?) |
| D | [#18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | 7 | 0 | — | some FIPS-related functions/data could be improved |
| D | [#84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | 8 | 5 | PRIORITY LOW | enable an Add Data tool or otherwise harmonize with geoplatform, ejscree… |
| D | [#67](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/67) | 8 | 5 | PRIORITY MEDIUM | improve use of global environment, data files, global.R, and maybe even … |
| D | [#57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | 8 | 5 | PRIORITY MEDIUM | Enable analysis of VERY large numbers of points - test limits and code s… |
| D | [#50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | 8 | 5 | PRIORITY MEDIUM | plotting functions all need review/ consolidation/ improvement/ renaming… |
| D | [#95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | 8 | 4 | PRIORITY LOW | in map_headernames, consider adding info re: in which tables/ popups/ xl… |
| D | [#29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | 8 | 3 | PRIORITY LOW | add info about zero results/ zero pop &amp; near other sites, to EJAM::d… |
| D | [#54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | 9 | 6 | PRIORITY LOW | correctly handle cases where the adjusted distance (via block_radius_mil… |
| D | [#38](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/38) | 9 | 2 | PRIORITY LOW | MODULE? Review/revise/expand unit testing for shapefile functions |
| D | [#28](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/28) | 9 | 1 | — | for each siteid, add ST, statename, and REGION columns to EJAM::doaggreg… |
| D | [#66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | 10 | 6 | PRIORITY LOW | EJAM &amp; EJScreen report on avg PERSON generally but State Average or … |
| D | [#32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | 11 | 5 | PRIORITY MEDIUM | *** MOVE CODE OUT OF SERVER and app_ui |
| D | [#85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | 12 | 5 | PRIORITY LOW | Enable higher resolution analysis than getblocksnearby() does, via Dasym… |
| D | [#51](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/51) | 12 | 5 | PRIORITY LOW | Confirm/fix what formula to use for state percentiles in overall summary |
| D | [#45](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/45) | 12 | 5 | PRIORITY MEDIUM | Replicating EJScreen: MAKE EJAM REPLICATE EJSCREEN RESULTS (overview of … |
| D | [#25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | 12 | 1 | PRIORITY LOW | Enable areal apportionment as option, via existing OW and/or OP code |