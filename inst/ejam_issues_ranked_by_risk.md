# EJAM Open Issues — Ranked by Agent Fix Risk & Complexity

**Total open issues:** 151  |  **Generated:** 2026-05-18  |  **Branch context:** copilot/rank-open-issues-by-risk

---

## Risk Level Legend

| Tier | Score Range | Meaning |
|------|------------|---------|
| 🟢 EASY | 0–2 | Trivial: link edits, renaming, suppress messages, one-liners |
| 🟡 LOW | 3–5 | Simple bounded fix, clear scope, minimal ripple risk |
| 🟠 MEDIUM | 6–9 | Needs codebase knowledge; clear intent; moderate investigation |
| 🔴 MOD-HIGH | 10–13 | Judgment calls, WIP, multiple components |
| 🔴🔴 HIGH | 14–18 | Core logic/math/stats, architecture, potentially breaking |
| ⛔ VERY HIGH | 19+ | Research, methodology, data pipeline, major features |

## Distribution

| Tier | Count |
|------|-------|
| EASY | 19 |
| LOW | 46 |
| MEDIUM | 51 |
| MOD-HIGH | 25 |
| HIGH | 7 |
| VERY HIGH | 3 |

---

## Scoring Method

Each issue scored on these factors (additive):

| Factor | Points |
|--------|--------|
| PRIORITY HIGH label | +6 |
| PRIORITY HIGH-ish label | +5 |
| PRIORITY MEDIUM label | +3 |
| PRIORITY LOW label | +1 |
| BUG label (+ HIGH priority) | +3 (+1 alone) |
| datasets-related label | +3 |
| calculate/validate label | +4 |
| speed/performance label | +3 |
| future plan list / tasklist label | +4 |
| refactor label | +1 |
| still relevant? / from archive labels | +2 / +1 |
| Title: replicate/validate/resolve differences | +4 |
| Title: WIP/revisit/draft | +3 |
| Title: CRAN submission | +5 |
| Title: investigate/review | +2 |
| Title: module/create/enable | +2 |
| Title: async/dasymetric | +4 |
| Title: README/links | −4 |
| Title: silence/suppress/remove NA/trim | −3 |
| Title: round to N digits | −2 |
| documentation label (no bug) | −1 |
| Body length >2000 chars | +3 |
| Body length 800–2000 chars | +2 |
| Body length 300–800 chars | +1 |
| Body length <50 chars | −1 |

---

## Full Ranked Table (All Issues, Easiest → Hardest)

| Rank | Issue # | 🚦 Tier | Score | Existing PRIORITY Label | Issue Title | Risk / Simplicity Note |
|------|---------|--------|-------|------------------------|-------------|------------------------|
| 1 | [#285](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/285) | 🟢 EASY | 0 | — | update README links | Pure text/link edits in README |
| 2 | [#282](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/282) | 🟢 EASY | 0 | PRIORITY LOW | silence console message about localtree when app launches | Suppress one console message |
| 3 | [#179](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/179) | 🟢 EASY | 0 | PRIORITY LOW | in ejam2excel() rename parameter fname to filename for consistency w oth… | Rename one function parameter |
| 4 | [#174](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/174) | 🟢 EASY | 0 | PRIORITY LOW | round to only 1 digit the area in square miles in header of summary repo… | One-liner rounding change |
| 5 | [#102](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/102) | 🟢 EASY | 0 | PRIORITY LOW | Remove NA console messages from `doaggregate` | Filter/suppress NA messages |
| 6 | [#184](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/184) | 🟢 EASY | 1 | PRIORITY LOW | trim the extremely long unit test names | Rename test name strings only |
| 7 | [#181](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/181) | 🟢 EASY | 1 | PRIORITY LOW | add other ejam2xyz functions to basics.Rmd as examples | Add examples to vignette |
| 8 | [#177](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/177) | 🟢 EASY | 1 | PRIORITY LOW | pick which approach is faster among functions like sf_nearest_points() a… | Benchmarking note — read-only |
| 9 | [#176](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/176) | 🟢 EASY | 1 | PRIORITY LOW | popups reports in county case are not normal/ignore reports settings? | Popup settings — UI tweak |
| 10 | [#175](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/175) | 🟢 EASY | 1 | PRIORITY LOW | drop the excel column called "Area of block group in geodatabase" and ot… | Remove column from output — low impact |
| 11 | [#173](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/173) | 🟢 EASY | 1 | PRIORITY LOW | adjust logo in excel version of summary report so it looks correct | Excel logo formatting — visual only |
| 12 | [#147](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/147) | 🟢 EASY | 1 | PRIORITY LOW | rlang pkg is imported by shiny and others, but has its own definition of… | Namespace awareness — may be no-op fix |
| 13 | [#42](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/42) | 🟢 EASY | 1 | PRIORITY LOW | Remove unused report template files | Delete files — no logic |
| 14 | [#183](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/183) | 🟢 EASY | 2 | PRIORITY LOW | use more standardized format in NEWS / changelog? | Reformat NEWS.md — style only |
| 15 | [#96](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/96) | 🟢 EASY | 2 | PRIORITY LOW | Detailed Table UI Filtering improvements | Add filter UI to table — UI enhancement |
| 16 | [#94](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/94) | 🟢 EASY | 2 | PRIORITY LOW | popup in summary report map has too many indicators? | Reduce indicator count in popup |
| 17 | [#93](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/93) | 🟢 EASY | 2 | PRIORITY LOW | make Demog. section of summary report table more visually prominent | CSS/visual tweak in report |
| 18 | [#92](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/92) | 🟢 EASY | 2 | PRIORITY LOW | Excel's new tab with upload needs cap on size | Add size limit to Excel tab |
| 19 | [#78](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/78) | 🟢 EASY | 2 | PRIORITY LOW | Add info message to radius slider label on hover/click | Add tooltip text — UI cosmetic |
| 20 | [#249](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/249) | 🟡 LOW | 3 | PRIORITY LOW | ejam2report() fails if filename is specified without path, or with "./xy… | Path normalization — clear fix |
| 21 | [#223](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/223) | 🟡 LOW | 3 | PRIORITY LOW | app_title parameter is not working in ejamapp() | Wire missing param — straightforward |
| 22 | [#164](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/164) | 🟡 LOW | 3 | PRIORITY MEDIUM | add unit tests for ejam2report() if possible, and others | Writing tests — time-consuming but clear |
| 23 | [#163](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/163) | 🟡 LOW | 3 | PRIORITY MEDIUM | put certain columns last in table of results (bg count, block count, rad… | Reorder output columns |
| 24 | [#161](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/161) | 🟡 LOW | 3 | PRIORITY MEDIUM | ejamapp() should be able to handle mix of fips types | FIPS type routing — some logic |
| 25 | [#141](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/141) | 🟡 LOW | 3 | PRIORITY MEDIUM | allow user to do library(EJAM) from any other folder  (working dir) not … | Working-dir fix — path handling |
| 26 | [#127](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/127) | 🟡 LOW | 3 | PRIORITY MEDIUM | web app details tab with table of all sites is too sluggish as it appear… | Performance — may need profiling |
| 27 | [#60](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/60) | 🟡 LOW | 3 | PRIORITY LOW | Rename community report functions with common convention | Column/param rename — check for uses |
| 28 | [#59](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/59) | 🟡 LOW | 3 | PRIORITY LOW | Improve MACT-related  lat lon data | Data quality — trimws/cleanup |
| 29 | [#49](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/49) | 🟡 LOW | 3 | PRIORITY LOW | URLs / links to EJScreen reports for FIPS analysis other than counties -… | URL generation — bounded scope |
| 30 | [#16](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/16) | 🟡 LOW | 3 | — | need new/updated "User Guide" ("Help" in header at right) since UI has c… | Large documentation effort |
| 31 | [#283](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/283) | 🟡 LOW | 4 | PRIORITY LOW | resolve warning about logo file, in logs/console, when web app tries to … | Suppress warning — simple |
| 32 | [#208](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/208) | 🟡 LOW | 4 | PRIORITY LOW | check/fix shapefile_from_any() handling of ejam_uniq_id (may affect ejam… | Moderate but bounded fix |
| 33 | [#182](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/182) | 🟡 LOW | 4 | PRIORITY LOW | consider refactoring url_xyz functions | Refactor — check all uses |
| 34 | [#162](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/162) | 🟡 LOW | 4 | PRIORITY MEDIUM | rename "in_how_many_states" and "invalid_msg" columns in table of result… | Column/param rename — check for uses |
| 35 | [#145](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/145) | 🟡 LOW | 4 | PRIORITY MEDIUM | fix .onAttach() stumbling on load_all() if add new url_xyz function in g… | Moderate but bounded fix |
| 36 | [#144](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/144) | 🟡 LOW | 4 | PRIORITY MEDIUM | use or remove or explain the sitenumber parameter in ejam2map() for fips… | Moderate but bounded fix |
| 37 | [#143](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/143) | 🟡 LOW | 4 | PRIORITY MEDIUM | xlsx download:  snapshot image of report in excel tab lacks logo (and up… | Moderate but bounded fix |
| 38 | [#142](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/142) | 🟡 LOW | 4 | PRIORITY MEDIUM | ejam2map() fails on shapefile case using sitenumber parameter | Moderate but bounded fix |
| 39 | [#130](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/130) | 🟡 LOW | 4 | PRIORITY MEDIUM | 'basics.html' article needs to be checked / fixed | Moderate but bounded fix |
| 40 | [#119](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/119) | 🟡 LOW | 4 | PRIORITY LOW | some code assumes RStudio user is in root folder of source package - che… | Moderate but bounded fix |
| 41 | [#91](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/91) | 🟡 LOW | 4 | PRIORITY MEDIUM | Excel needs new tab with uploaded places or facilities found | Moderate but bounded fix |
| 42 | [#89](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/89) | 🟡 LOW | 4 | PRIORITY LOW | clarify what "N places" really means &amp; report on the selection type … | Moderate but bounded fix |
| 43 | [#88](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/88) | 🟡 LOW | 4 | PRIORITY LOW | Add missing @return info to each function where it is missing info on ou… | Moderate but bounded fix |
| 44 | [#83](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/83) | 🟡 LOW | 4 | PRIORITY LOW | enable selecting a folder as way to upload shapefile(s) | Moderate but bounded fix |
| 45 | [#72](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/72) | 🟡 LOW | 4 | PRIORITY MEDIUM | find a way to map more polygons (than just 159 cap) | Moderate but bounded fix |
| 46 | [#71](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/71) | 🟡 LOW | 4 | PRIORITY MEDIUM | allow user to see the newer more flexible barplot ratios functions and t… | Moderate but bounded fix |
| 47 | [#64](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/64) | 🟡 LOW | 4 | PRIORITY LOW | lat lon Latitude Longitude duplicative indicators in ejscreenit()$table | Moderate but bounded fix |
| 48 | [#61](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/61) | 🟡 LOW | 4 | PRIORITY LOW | downloading excel output with plots for 1000-2000 points takes 10-15 sec… | Moderate but bounded fix |
| 49 | [#41](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/41) | 🟡 LOW | 4 | PRIORITY LOW | Include indicator formulas in Community Report | Moderate but bounded fix |
| 50 | [#288](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/288) | 🟡 LOW | 5 | PRIORITY MEDIUM | ratio of 1.0 should not be yellow on community report | Threshold tweak — find cutoff code |
| 51 | [#242](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/242) | 🟡 LOW | 5 | PRIORITY MEDIUM | Report should show ratios to avg for special indicators like | Moderate but bounded fix |
| 52 | [#224](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/224) | 🟡 LOW | 5 | PRIORITY LOW | report correct population for a single block (if block is analyzed via b… | Moderate but bounded fix |
| 53 | [#166](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/166) | 🟡 LOW | 5 | PRIORITY MEDIUM | could simplify polygons before mapping, saving - check if useful and the… | Moderate but bounded fix |
| 54 | [#159](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/159) | 🟡 LOW | 5 | PRIORITY MEDIUM | integrate file-naming function and header-creating functions | Moderate but bounded fix |
| 55 | [#140](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/140) | 🟡 LOW | 5 | PRIORITY MEDIUM | in app and R functions, handle blockgroup fips better | Moderate but bounded fix |
| 56 | [#139](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/139) | 🟡 LOW | 5 | PRIORITY MEDIUM | The radius parameter gets ignored, but should not, in fips case, where N… | Moderate but bounded fix |
| 57 | [#137](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/137) | 🟡 LOW | 5 | PRIORITY MEDIUM | fix bug in popshare_at_top_x_pct() - results sometimes not quite right. … | Moderate but bounded fix |
| 58 | [#136](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/136) | 🟡 LOW | 5 | PRIORITY MEDIUM | in web app, fix console  error msg when uploading a shapefile | Moderate but bounded fix |
| 59 | [#80](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/80) | 🟡 LOW | 5 | PRIORITY LOW | make latlon_from_naics() and other naics-related functions consistent wi… | Moderate but bounded fix |
| 60 | [#76](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/76) | 🟡 LOW | 5 | PRIORITY LOW | MODULE: Points table upload MODULE | Moderate but bounded fix |
| 61 | [#70](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/70) | 🟡 LOW | 5 | PRIORITY MEDIUM | set up alerts that monitor and alert staff when the app goes down - ensu… | Moderate but bounded fix |
| 62 | [#63](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/63) | 🟡 LOW | 5 | PRIORITY LOW | Fix use of mapping_for_names parameter | Moderate but bounded fix |
| 63 | [#55](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/55) | 🟡 LOW | 5 | PRIORITY LOW | add links to COUNTY-LEVEL reports - on a place - from other tools/ sourc… | URL generation — bounded scope |
| 64 | [#34](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/34) | 🟡 LOW | 5 | PRIORITY MEDIUM | Remove extraneous comments from Shiny app scripts | Moderate but bounded fix |
| 65 | [#24](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/24) | 🟡 LOW | 5 | PRIORITY MEDIUM | map popups in make.popups.api() and other functions are too cluttered, m… | Moderate but bounded fix |
| 66 | [#240](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/240) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | Reports need to round off the ratios for climate and health indicators (… | Clear scope but needs codebase familiarity |
| 67 | [#231](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/231) | 🟠 MEDIUM | 6 | PRIORITY LOW | fix frs_by_mact.arrow and /data/mact_table to remove leading and extra s… | Clear scope but needs codebase familiarity |
| 68 | [#171](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/171) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | enhance ejamit() to allow params lat,lon | Clear scope but needs codebase familiarity |
| 69 | [#168](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/168) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | refactor/reconcile "report_logo" vs "logo_path" (parameters and/or globa… | Clear scope but needs codebase familiarity |
| 70 | [#109](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/109) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | Update &amp; correct the article "Defaults and Custom Settings for the W… | Clear scope but needs codebase familiarity |
| 71 | [#86](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/86) | 🟠 MEDIUM | 6 | PRIORITY LOW | Fix (or remove?) references to ejampackages data object | Clear scope but needs codebase familiarity |
| 72 | [#81](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/81) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | confusion in UI: if user tries a second analysis by uploading new stuff,… | Clear scope but needs codebase familiarity |
| 73 | [#75](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/75) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | "Schools Counter" functionality needed (to count schools or other featur… | Clear scope but needs codebase familiarity |
| 74 | [#74](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/74) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | Develop options for defining the Reference Zone or Ref. Group - avg pers… | Clear scope but needs codebase familiarity |
| 75 | [#73](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/73) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | in web app, add ways to analyze multiple radii at once or even continuou… | Clear scope but needs codebase familiarity |
| 76 | [#69](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/69) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | enable other units like kilometers for entry of radius | Clear scope but needs codebase familiarity |
| 77 | [#62](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/62) | 🟠 MEDIUM | 6 | PRIORITY LOW | Enable download of 'Plot of Average Scores' and 'Plot Full Range of Scor… | Clear scope but needs codebase familiarity |
| 78 | [#58](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/58) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | joining FIPS upload data to preview table | Clear scope but needs codebase familiarity |
| 79 | [#53](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/53) | 🟠 MEDIUM | 6 | PRIORITY LOW | for proximity score creation tool, resolve how to apply short distances … | Clear scope but needs codebase familiarity |
| 80 | [#43](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/43) | 🟠 MEDIUM | 6 | PRIORITY LOW | Enable fast site selection map during category scrolling | Clear scope but needs codebase familiarity |
| 81 | [#40](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/40) | 🟠 MEDIUM | 6 | PRIORITY MEDIUM | Allow abort site selection processing when selections are changed | Clear scope but needs codebase familiarity |
| 82 | [#39](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/39) | 🟠 MEDIUM | 6 | PRIORITY LOW | Review/revise/expand unit testing for SIC functions | Clear scope but needs codebase familiarity |
| 83 | [#35](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/35) | 🟠 MEDIUM | 6 | PRIORITY LOW | Review/revise/expand unit testing for URL functions | Clear scope but needs codebase familiarity |
| 84 | [#27](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/27) | 🟠 MEDIUM | 6 | PRIORITY LOW | add ability to save/load/bookmark static report settings (the parameters… | Clear scope but needs codebase familiarity |
| 85 | [#19](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/19) | 🟠 MEDIUM | 6 | — | FIPS missing/problems (mostly in Connecticut) | Clear scope but needs codebase familiarity |
| 86 | [#18](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/18) | 🟠 MEDIUM | 6 | — | some FIPS-related functions/data could be improved | Clear scope but needs codebase familiarity |
| 87 | [#319](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/319) | 🟠 MEDIUM | 7 | PRIORITY MEDIUM | fix err msg for FIPS with no available boundaries info in app, or polygo… | Clear scope but needs codebase familiarity |
| 88 | [#180](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/180) | 🟠 MEDIUM | 7 | PRIORITY LOW | refactor functions handling sitepoints (espec in url_ functions?) | Clear scope but needs codebase familiarity |
| 89 | [#95](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/95) | 🟠 MEDIUM | 7 | PRIORITY LOW | in map_headernames, consider adding info re: in which tables/ popups/ xl… | Clear scope but needs codebase familiarity |
| 90 | [#84](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/84) | 🟠 MEDIUM | 7 | PRIORITY LOW | enable an Add Data tool or otherwise harmonize with geoplatform, ejscree… | Clear scope but needs codebase familiarity |
| 91 | [#82](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/82) | 🟠 MEDIUM | 7 | PRIORITY MEDIUM | confusing UI: a user names the analysis #1, then forgets to change title… | Clear scope but needs codebase familiarity |
| 92 | [#77](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/77) | 🟠 MEDIUM | 7 | PRIORITY MEDIUM | MODULE: Point layer MODULE (specify URL of service with point data) | New Shiny module — scoped but non-trivial |
| 93 | [#33](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/33) | 🟠 MEDIUM | 7 | PRIORITY MEDIUM | Move HTML, CSS, and Javascript code into appropriate external files | Clear scope but needs codebase familiarity |
| 94 | [#31](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/31) | 🟠 MEDIUM | 7 | PRIORITY MEDIUM | fix distance_avg in doaggregate()$results_bybg_people | Clear scope but needs codebase familiarity |
| 95 | [#28](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/28) | 🟠 MEDIUM | 7 | — | for each siteid, add ST, statename, and REGION columns to EJAM::doaggreg… | API feature — some scope |
| 96 | [#255](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/255) | 🟠 MEDIUM | 8 | PRIORITY LOW | fix warning seen when reinstalling from source, about some arrow data fi… | Clear scope but needs codebase familiarity |
| 97 | [#172](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/172) | 🟠 MEDIUM | 8 | PRIORITY MEDIUM | create "sites_from_anything" func to allow any types of inputs specifyin… | Clear scope but needs codebase familiarity |
| 98 | [#169](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/169) | 🟠 MEDIUM | 8 | PRIORITY MEDIUM | harmonize/refactor functions that create or sanitize filenames, paths | Clear scope but needs codebase familiarity |
| 99 | [#156](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/156) | 🟠 MEDIUM | 8 | PRIORITY HIGH-ish but not a bug | in app - add view of   ejam2areafeatures(out)  (info on % of pop with ce… | Clear scope but needs codebase familiarity |
| 100 | [#152](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/152) | 🟠 MEDIUM | 8 | PRIORITY HIGH-ish but not a bug | build_community_report() needs unit tests, table_signif_round_x100() or … | Clear scope but needs codebase familiarity |
| 101 | [#150](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/150) | 🟠 MEDIUM | 8 | PRIORITY HIGH-ish but not a bug | shp case map popups should not include "Area within 0 miles of site" nor… | Clear scope but needs codebase familiarity |
| 102 | [#149](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/149) | 🟠 MEDIUM | 8 | PRIORITY HIGH-ish but not a bug | remove sitenumber=-1 in output of url_ejamapi() for fips case at least | API feature — some scope |
| 103 | [#148](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/148) | 🟠 MEDIUM | 8 | PRIORITY HIGH-ish but not a bug | in excel, have freeze columns apply to the correct columns | Clear scope but needs codebase familiarity |
| 104 | [#135](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/135) | 🟠 MEDIUM | 8 | PRIORITY MEDIUM | finish work in progress on default_ss_choose_method  vs input$ ? | Partial WIP — unclear state |
| 105 | [#103](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/103) | 🟠 MEDIUM | 8 | PRIORITY MEDIUM | results_summarized$rows percentiles info needs debugging, or stop using … | Clear scope but needs codebase familiarity |
| 106 | [#67](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/67) | 🟠 MEDIUM | 8 | PRIORITY MEDIUM | improve use of global environment, data files, global.R, and maybe even … | Clear scope but needs codebase familiarity |
| 107 | [#29](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/29) | 🟠 MEDIUM | 8 | PRIORITY LOW | add info about zero results/ zero pop &amp; near other sites, to EJAM::d… | API feature — some scope |
| 108 | [#279](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/279) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | Prepare the package to submit to CRAN (and get it accepted for hosting o… | Multi-step compliance checklist |
| 109 | [#170](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/170) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | refactor/rename inconsistent function names that contain state_fips or s… | Clear scope but needs codebase familiarity |
| 110 | [#167](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/167) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | review and reduce or fix pkg dependencies | Clear scope but needs codebase familiarity |
| 111 | [#154](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/154) | 🟠 MEDIUM | 9 | PRIORITY HIGH-ish but not a bug | Enable pdf output option for ejam2report() and/or in API | API feature — some scope |
| 112 | [#65](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/65) | 🟠 MEDIUM | 9 | PRIORITY HIGH-ish but not a bug | include AREA (square miles area) as an output for SHAPEFILE and FIPS ana… | Clear scope but needs codebase familiarity |
| 113 | [#48](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/48) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | URLs / links to EJScreen reports for shapefile analysis | Clear scope but needs codebase familiarity |
| 114 | [#38](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/38) | 🟠 MEDIUM | 9 | PRIORITY LOW | MODULE? Review/revise/expand unit testing for shapefile functions | New Shiny module — scoped but non-trivial |
| 115 | [#37](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/37) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | MODULE: make a Shiny module for typing in lat/lon values | New Shiny module — scoped but non-trivial |
| 116 | [#26](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/26) | 🟠 MEDIUM | 9 | PRIORITY MEDIUM | Create LongReport (quarto/word doc/TSD) Settings Panel | Clear scope but needs codebase familiarity |
| 117 | [#292](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/292) | 🔴 MOD-HIGH | 10 | PRIORITY HIGH-ish but not a bug | use a column heading that is more informative/clear than "invalid_msg" i… | Multiple components or judgment needed |
| 118 | [#284](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/284) | 🔴 MOD-HIGH | 10 | PRIORITY LOW | resolve warning about datum, in logs/console, when web app tries to uplo… | Multiple components or judgment needed |
| 119 | [#274](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/274) | 🔴 MOD-HIGH | 10 | PRIORITY HIGH-ish but not a bug | Add the features not yet restored from the pre-2025 EPA version of the C… | Multiple components or judgment needed |
| 120 | [#241](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/241) | 🔴 MOD-HIGH | 10 | PRIORITY HIGH-ish but not a bug | provide ratios to avg in community report for more indicators (such as %… | Multiple components or judgment needed |
| 121 | [#205](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/205) | 🔴 MOD-HIGH | 10 | PRIORITY HIGH-ish but not a bug | adjust summary report fonts and row heights/line spacing to make text mo… | Multiple components or judgment needed |
| 122 | [#155](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/155) | 🔴 MOD-HIGH | 10 | PRIORITY HIGH-ish but not a bug | revisit draft work in progress on API (see branch) | Multiple components or judgment needed |
| 123 | [#101](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/101) | 🔴 MOD-HIGH | 10 | PRIORITY MEDIUM | Enable printing reports of analysis speed to console | Multiple components or judgment needed |
| 124 | [#87](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/87) | 🔴 MOD-HIGH | 10 | PRIORITY MEDIUM | Enable shiny.telemetry log file that is not just a text file on server | Multiple components or judgment needed |
| 125 | [#56](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/56) | 🔴 MOD-HIGH | 10 | PRIORITY MEDIUM | check/ fix Distance and Site Count summary stats, in doaggregate() | Multiple components or judgment needed |
| 126 | [#54](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/54) | 🔴 MOD-HIGH | 10 | PRIORITY LOW | correctly handle cases where the adjusted distance (via block_radius_mil… | Multiple components or judgment needed |
| 127 | [#256](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/256) | 🔴 MOD-HIGH | 11 | PRIORITY MEDIUM | speed up some functions by using .arrow not .rda version of each large d… | Multiple components or judgment needed |
| 128 | [#194](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/194) | 🔴 MOD-HIGH | 11 | PRIORITY MEDIUM | Create visualizations of overall results in app  - engaging &amp; insigh… | Multiple components or judgment needed |
| 129 | [#192](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/192) | 🔴 MOD-HIGH | 11 | PRIORITY MEDIUM | User-specified indicators (enable upload of and reporting on user-provid… | Multiple components or judgment needed |
| 130 | [#68](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/68) | 🔴 MOD-HIGH | 11 | PRIORITY HIGH-ish but not a bug | allow user to type in radius not only use slider | Multiple components or judgment needed |
| 131 | [#153](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/153) | 🔴 MOD-HIGH | 12 | PRIORITY HIGH-ish but not a bug | revisit work in progress on this list of .R files | Multiple components or judgment needed |
| 132 | [#123](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/123) | 🔴 MOD-HIGH | 12 | PRIORITY HIGH | enable API-query URLs to encode a large polygon in excel download of res… | Multiple components or judgment needed |
| 133 | [#85](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/85) | 🔴 MOD-HIGH | 12 | PRIORITY LOW | Enable higher resolution analysis than getblocksnearby() does, via Dasym… | Multiple components or judgment needed |
| 134 | [#66](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/66) | 🔴 MOD-HIGH | 12 | PRIORITY LOW | EJAM &amp; EJScreen report on avg PERSON generally but State Average or … | Multiple components or judgment needed |
| 135 | [#51](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/51) | 🔴 MOD-HIGH | 12 | PRIORITY LOW | Confirm/fix what formula to use for state percentiles in overall summary | Multiple components or judgment needed |
| 136 | [#50](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/50) | 🔴 MOD-HIGH | 12 | PRIORITY MEDIUM | plotting functions all need review/ consolidation/ improvement/ renaming… | Multiple components or judgment needed |
| 137 | [#25](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/25) | 🔴 MOD-HIGH | 12 | PRIORITY LOW | Enable areal apportionment as option, via existing OW and/or OP code | Multiple components or judgment needed |
| 138 | [#22](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/22) | 🔴 MOD-HIGH | 12 | PRIORITY HIGH-ish but not a bug | Provide/enhance EJAM API | Multiple components or judgment needed |
| 139 | [#20](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/20) | 🔴 MOD-HIGH | 12 | PRIORITY HIGH-ish but not a bug | Need to update to using latest demographic data (from Census ACS5) | Multiple components or judgment needed |
| 140 | [#126](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/126) | 🔴 MOD-HIGH | 13 | PRIORITY HIGH | enable API query for 1-site or multisite report on Polygons / Shapefile,… | Multiple components or judgment needed |
| 141 | [#32](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/32) | 🔴 MOD-HIGH | 13 | PRIORITY MEDIUM | *** MOVE CODE OUT OF SERVER and app_ui | Multiple components or judgment needed |
| 142 | [#226](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/226) | 🔴🔴 HIGH | 14 | PRIORITY HIGH-ish but not a bug | NOTES on SPEEDING UP app &amp; functions (incl load testing) | Core logic/math/stats — high regression risk |
| 143 | [#57](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/57) | 🔴🔴 HIGH | 14 | PRIORITY MEDIUM | Enable analysis of VERY large numbers of points - test limits and code s… | Core logic/math/stats — high regression risk |
| 144 | [#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) | 🔴🔴 HIGH | 15 | PRIORITY HIGH-ish but not a bug | API takes too long to create a community report from when user clicks | Core logic/math/stats — high regression risk |
| 145 | [#45](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/45) | 🔴🔴 HIGH | 15 | PRIORITY MEDIUM | Replicating EJScreen: MAKE EJAM REPLICATE EJSCREEN RESULTS (overview of … | Core logic/math/stats — high regression risk |
| 146 | [#193](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/193) | 🔴🔴 HIGH | 16 | PRIORITY HIGH-ish but not a bug | Create Executive Summary helper functions - summarizer / Methods for Ide… | Core logic/math/stats — high regression risk |
| 147 | [#46](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/46) | 🔴🔴 HIGH | 16 | PRIORITY HIGH-ish but not a bug | Long Report text needed | Core logic/math/stats — high regression risk |
| 148 | [#52](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/52) | 🔴🔴 HIGH | 18 | PRIORITY HIGH-ish but not a bug | Create density score /proximity score/ count-nearby functions, then prov… | Core logic/math/stats — high regression risk |
| 149 | [#321](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/321) | ⛔ VERY HIGH | 21 | PRIORITY HIGH | resolve differences between EPA ejscreen indicators from the ACS (demogr… | Research/methodology/pipeline — expert domain |
| 150 | [#320](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/320) | ⛔ VERY HIGH | 22 | PRIORITY HIGH | resolve differences between EPA percentiles table and data pipeline effo… | Research/methodology/pipeline — expert domain |
| 151 | [#44](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/44) | ⛔ VERY HIGH | 24 | PRIORITY HIGH-ish but not a bug | Investigate options for asynchronous processing in R Shiny (espec for sp… | Research/methodology/pipeline — expert domain |