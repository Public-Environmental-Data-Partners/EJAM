# Plan — `refactoring_app_settings`

Branch `refactoring_app_settings`, based on `development` (developed in a dedicated git worktree).
Companion analysis: [`refactoring_app_settings_analysis.md`](refactoring_app_settings_analysis.md) (full two-axis audit of how app settings get set).

Goal: targeted harmonization of how the EJAM web-app gets its input defaults/values — **not a rewrite**. The architecture (two orthogonal axes: how the widget is built A/B/C × where the value comes from) is sound. We clean up ~5 specific spots.

---

## STATUS: IMPLEMENTED (2026-06-30)

All items below are implemented in this branch, rebased on `development` after PRs #418
(mapclick) and #413 (launch-URL) both merged. The plan originally held all code until those
two PRs landed (to avoid colliding with the owner's open PRs); that gate has cleared, so the
Wave 1 / Wave 2 split below is now **historical context only** — everything was done in one
pass on the clean baseline.

---

## Sequencing constraint (READ FIRST)

This branch is downstream of two OPEN PRs into `development`:

- **PR #418** `mapclick-app-integration` — already removes the dead Design-B `ss_choose_method_ui` renderUI, adds the `observeEvent(input$default_ss_choose_method, updateRadioButtons('ss_choose_method', …))` sync, and adds the `mapclick` choice. **It edits the exact lines our Item 2 touches.**
- **PR #413** `ejscreen-multisite-selection` — introduces the launch-URL `url_*` reactives and `url_x() %||% global_or_param("x")` pattern. **Our Item 1 helper has nothing to wire to until this lands.**

Because we base on `development` (where neither PR is merged yet), the items split into two waves:

**Wave 1 — conflict-free, do now:**
- Item 3 — fix the two anti-patterns (`max_mb_upload_react`, `naics_digits_shown`).
- Item 1a — *define* the `global_or_shinyparam_or_urlparam` helper additively in `R/utils_global_or_param.R` (safe: degrades to `global_or_param` when no URL params exist). Do NOT rewire call sites yet.
- Item 5 — documentation pass (`vignettes/dev-app-settings.Rmd`): two-axis model, alias table, precedence stack.

**Wave 2 — hold until #418 and #413 merge into `development`, then rebase:**
- Item 1b — replace ad-hoc `%||%` chains at the `url_*` call sites with the helper.
- Item 2 — consolidate the `ss_choose_method` writers into one precedence-ordered observer (builds on #418's already-cleaned baseline).
- Item 4 — rename `default_upload_dropdown` → `default_site_method` with back-compat alias (touches #418's mapclick handling; safer once #418 is in).

This ordering avoids guaranteed merge conflicts with the repo owner's own open PRs.

---

## Items (from the analysis report's deferred plan)

### Item 1 — centralize launch-URL precedence
Add `global_or_shinyparam_or_urlparam(name)` in `R/utils_global_or_param.R`, returning `url_param(name) %||% global_or_param(name)` (launch-URL value wins over ejamapp/global default). Replace hand-written `%||%` chains at the `url_*` call sites (from #413). Defines layer-2 precedence in one place.
- 1a (Wave 1): define helper, degrade gracefully when `url_param` / URL params absent.
- 1b (Wave 2): rewire call sites after #413 merges.

### Item 2 — consolidate `ss_choose_method` writers (Wave 2)
Today the radio has multiple writers: the advanced-tab sync plus three `="upload"` updates from shapefile/sitepoints/fips ejamapp params (last-writer-wins, no documented precedence). Consolidate into one observer with explicit, commented precedence: **URL > ejamapp data param > advanced-tab > static**.
*User flagged: good but tricky — do carefully, double-check.* Build on #418's cleaned baseline (no dead renderUI; `mapclick` present).

### Item 3 — fix the two anti-patterns (Wave 1)
- `max_mb_upload_react` (`app_server.R:~202`): a `reactive()` that calls `updateNumericInput()` inside itself (side-effect in a reactive). Split into `observe`-writes (clamp + update the widget) and a pure `reactive`-read for `shiny.maxRequestSize`.
- `naics_digits_shown` (`app_server.R:~261`): an `observe` resets it whenever `default_naics` changes, silently overriding a user's manual pick. Make it respect a user override (only force `detailed` when a detailed `default_naics` requires it; otherwise don't clobber).

### Item 4 — rename `default_upload_dropdown` → `default_site_method` (Wave 2)
The value now selects dropdown / upload / mapclick, so the name is a misnomer. Rename with a back-compat alias so existing `ejamapp()` calls, bookmarks, and URLs keep working. Touch points: `R/ejamapp.R`, `R/app_server.R`, `R/app_ui.R`, `inst/global_defaults_shiny*.R`, `vignettes/dev-app-settings.Rmd`, regenerate `man/`.
*User flagged: good but tricky — do extremely carefully; keep the alias.*

### Item 5 — documentation pass (Wave 1)
`vignettes/dev-app-settings.Rmd` ("Defaults and Custom Settings for the Web App"): document the two-axis model, the `ejamapp()` alias table, and the precedence stack (incl. launch-URL once #413 merges, and the renamed param once Item 4 lands).

---

## Test / verification notes
- Adding/renaming any `tests/testthat/` file requires updating `R/test_ejam.R` group lists + timing (no auto-discovery).
- Item 3 and Item 2 are behavioral — add/adjust tests where feasible and smoke-test the app launch.
- Item 4 alias: add a test that an old `ejamapp(default_upload_dropdown=...)` call still resolves.
