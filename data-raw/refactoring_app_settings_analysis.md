# NOTES on how EJAM app settings / defaults / parameters get set

`global_or_param()` vs shiny `input$` vs launch-URL params vs bookmarking — and how to keep it organized.

- **Date:** 2026-06-29
- **Author of analysis:** review for Mark (ejanalysis), based on a 3-part audit of `R/app_ui.R`, `R/app_server.R`, `R/ejamapp.R`, `R/utils_get_global_defaults_or_user_options.R`, `R/utils_global_or_param.R` on branch `mapclick-app-integration` (PR #418).
- **Status:** Reference/analysis. The CLEANUP items at the end are **deferred to a separate branch/PR `refactoring_app_settings`** (its own session, based on `development`).

---

## TL;DR — it looks messier than it is, because two different concerns got tangled

What felt like "competing designs" is really **two orthogonal axes**:

- **Axis 1 — how the input widget is built** (a UI-mechanics concern): static-in-UI vs server-`renderUI` vs static-empty-plus-server-`update*Input`. The choice is almost always *forced* by the widget, not stylistic.
- **Axis 2 — where the widget's value/default comes from** (a config-precedence concern): global-default files, `ejamapp()` params, advanced-tab inputs, Shiny bookmarks, and launch-URL params.

Once you separate them, ~90% of the variation is correct and necessary. The genuine cleanup surface is ~5 specific spots (listed near the end).

---

## Axis 1 — how each input widget is built (and when each is correct)

| Pattern | ~count (PR #418) | Use when | Why it is forced, not stylistic |
|---|---|---|---|
| **A — static UI default**: control written in `app_ui.R` with `selected =`/`value =`/`choices =` set to `global_or_param("…")` or a literal | ~48 controls | default is a plain value known at page-load, with a fixed choice set | simplest, correct for most controls. **UI is built before any reactive `input` exists, so the value MUST be non-reactive here** (never `input$…` in app_ui.R) |
| **B — server `renderUI`** (`uiOutput('x')` in UI + `output$x <- renderUI({...})` in server) | ~7 input controls (radius slider `radius_now`, `summ_bar_*`, `summ_hist_ind`, `analysis_title`, `rg_enter_miles`) | the widget's **structure** (which choices exist, min/max, conditional sub-controls) depends on reactive state | you cannot bake a reactive structure into static UI. e.g. radius slider `min/max` depend on the chosen method; bar-plot choices depend on `include_ejindexes` |
| **C — static-empty UI + server `update*Input()`** | ~20 update calls | choices load **server-side** (selectize `server=TRUE`), OR the value must change on a later **event** | a ~2,000-item NAICS list (also SIC, MACT) *cannot* be static — selectize must be populated server-side. This is why `updateSelectizeInput(ss_select_naics, selected = global_or_param("default_naics"))` exists: **required**, not an inconsistency. Also used for event-driven changes (advanced-tab sync, upload→method switch) |

**Decision rule for contributors:**
- known value + fixed choices → **A**
- choices load lazily, or value must react to an event → **C**
- the widget's shape itself is reactive → **B**
- **never** reference `input$…` inside `app_ui.R` (errors at UI build). To make an advanced-tab setting change a main control, sync server-side via `update*Input()`.

(There was a 4th, abandoned pattern — "Design B for the method radio": `output$ss_choose_method_ui <- renderUI(...)` reading `input$default_ss_choose_method`. It was dead, stale, and buggy; removed in PR #418 and replaced with the C-pattern `observeEvent(input$default_ss_choose_method, updateRadioButtons('ss_choose_method', …))`.)

---

## Axis 2 — where a value comes from (the precedence stack)

There are really **two sub-systems**: a **startup-config pipeline** (consolidated, consistent) and a set of **runtime overrides** (each wired separately).

### Startup-config pipeline (consolidated — this part is good)

```
ejamapp(...)  -- user's call, with convenience ALIASES
   │  (1) ejamapp() normalizes aliases + cross-sets related defaults   [R/ejamapp.R ~275-388]
   ▼
get_global_defaults_or_user_options(user_specified_options = dots)      [R/utils_get_global_defaults_or_user_options.R:72]
   │  (2) merge, FIRST-WRITER-WINS, in precedence order:
   │        a. ejamapp() params (highest)
   │        b. global_defaults_package.R
   │        c. global_defaults_shiny.R
   │        d. global_defaults_shiny_public.R (depends on isPublic)
   ▼
golem_opts  ──►  global_or_param("name")   [R/utils_global_or_param.R]
   │
   ├─► app_ui.R   : Design A  (selected = global_or_param("name"))
   └─► app_server : Design C  (update*Input(..., selected = global_or_param("name")))
```

**Role of `get_global_defaults_or_user_options()`** (the user asked about this): it is the single place that collects the **startup** settings from the 4 sources above and consolidates them into one list (`golem_opts`) that both UI and server read via `global_or_param()`. The merge helper `update_global_defaults_or_user_options()` only adds a key if it is **not already set**, so earlier (higher-priority) sources win — user `ejamapp()` params override the files.

**Is it a good way to collect the various ways params get set?** For the **startup/config layer, yes** — it is centralized, ordered, first-writer-wins, and easy to reason about. Caveats / things to know:
- It only covers the **startup** layer. It does **not** incorporate the *runtime* overrides below (advanced-tab inputs, bookmarks, launch-URL params). So it is "the collector" for config-at-launch, not a single unifying point for *all* ways a value can be set.
- It `source()`s `global_defaults_package.R` with `local = FALSE` (into the global env) — a deliberate hack (needed so the summary-report logo etc. resolve), noted in the code.
- It depends on each file defining a specific named list (`global_defaults_package`, `global_defaults_shiny`, `global_defaults_shiny_public`) in the sourced env — implicit coupling, but stable.
- Recommendation: keep it. Just document clearly that it owns the **startup** layer, and give the **launch-URL** layer a parallel single helper (see the deferred plan) so runtime precedence is as centralized as startup precedence.

**Role of `ejamapp()` alias handling** (the user asked about this): before the merge, `ejamapp()` normalizes a set of **convenience aliases** on its `...` dots and, for some, **cross-sets related defaults** so a one-liner "just works." (The site-selection method param is now `default_site_method`; the former name `default_upload_dropdown` still works as a back-compat alias.) Examples (`R/ejamapp.R ~275-388`):
- `pts` → `sitepoints`; `lat`+`lon` → `sitepoints`; and `sitepoints` ⇒ also sets `default_site_method="upload"`, `default_selected_type_of_site_upload="latlon"`.
- `shp` → `shapefile`; and `shapefile` ⇒ `default_site_method="upload"`, `…upload="SHP"`.
- `fips` ⇒ `default_site_method="upload"`, `…upload="FIPS"`.
- `naics` → `default_naics`; and `default_naics` ⇒ `default_site_method="dropdown"`, `…category="NAICS"`. Similarly `sic`/`mact`.
- `radius`/`default_radius`; `report_title`/`default_report_title`/`default_report_title_multisite`; `analysis_title`/`default_analysis_title`; `testing`; etc.
This is a **third param-setting concern** (alias normalization + dependent-default inference) that runs *upstream* of the merge. It is convenient and mostly good, but it is also where some of the "many ways to set the same thing" feeling comes from — e.g. the method (`default_site_method`) can be set directly, or implicitly via `fips`/`shp`/`pts`/`naics`/`sitepoints`/`shapefile`. Worth documenting the alias table in one place.

### Runtime overrides (each wired separately — this is where harmonization helps)

| Layer | Mechanism | Where | Consistency |
|---|---|---|---|
| **Advanced-tab → main control** | `observeEvent(input$default_ss_choose_method, updateRadioButtons('ss_choose_method', …))` and similar | app_server.R | ad hoc per control |
| **Shiny native bookmarking** | `enableBookmarking='url'` (default in `ejamapp()`); `bookmarkButton()`; `?_inputs_&id=val…` restores all `input$` on load | ejamapp.R, app_ui.R | framework-level; only `input$` vars; no `onBookmark`/`onRestore` customization yet |
| **Launch-URL custom params** (PR #413, now merged to `development`) | parse `session$clientData$url_search`; `url_*()` reactiveVals; precedence resolved by `global_or_shinyparam_or_urlparam()` in each `data_up_*` reactive; also `update*Input` to reflect in UI | app_server.R | **now centralized** via the `global_or_shinyparam_or_urlparam()` helper (Item 1) |

---

## Precedence summary (highest wins)

1. **Shiny bookmark** `?_inputs_&…` — restores `input$` values on load (overrides UI defaults). *Framework-level; orthogonal.*
2. **Launch-URL custom params** `?lat=&lon=`, `?fips=`, `?shape=`, `?handoff=` (PR #413) — `url_x() %||% global_or_param("x")`.
3. **`ejamapp()` params** (after alias normalization) — override the global-default files.
4. **`global_defaults_*.R`** files (package < shiny < shiny_public).

Layers 3–4 are consolidated and consistent (via `get_global_defaults_or_user_options()`). Layers 1–2 and the advanced-tab sync are each reasonable but wired **ad hoc**, and that is the real harmonization target.

---

## Where it is genuinely inconsistent / risky (verified in code)

| Spot | Issue | Severity |
|---|---|---|
| `ss_choose_method` | 4 writers: advanced-tab sync (`app_server.R:~352`) + three `="upload"` updates from shapefile/sitepoints/fips ejamapp params (`~444`, `~657`, `~1212`). Last-writer-wins; no documented precedence | medium |
| `max_mb_upload_react` (`app_server.R:~202`) | a `reactive()` that calls `updateNumericInput()` **inside itself** (side-effect in a reactive — anti-pattern). Self-settles so no infinite loop, but should be `observe`-writes + pure `reactive`-reads | low–med |
| `naics_digits_shown` (`app_server.R:~261`) | an `observe` resets it whenever `default_naics` changes — silently overrides a user's manual pick | low |
| `default_naics` / `default_sic` | belt-and-suspenders: Category-C server populate that re-fetches the same `global_or_param` the static UI "knows" — confusing but harmless | low |
| Launch-URL `%||%` precedence (#413) | repeated per-reactive instead of one helper → easy to apply inconsistently as more URL params are added | medium (growing) |
| `default_upload_dropdown` name | selected 3 methods (dropdown / upload / mapclick) — the name was a misnomer; **renamed to `default_site_method`** (old name kept as a back-compat alias) | resolved |

---

## Assessment: is it messy? Do we need harmonization?

**The architecture is sound; do not rewrite it.** The A/B/C variation is forced and correct; the startup-config pipeline is well-consolidated. The "messiness" is concentrated in (a) the *runtime* override layers being wired ad hoc, and (b) a handful of double-set / side-effect-in-reactive spots. **Targeted harmonization, not a rewrite.**

---

## DEFERRED — `refactoring_app_settings` branch/PR (separate session, based on `development`)

This is captured here so the dedicated session has the full scope. That branch/PR should **include this report + the memory note**, **start with a plan**, then:

1. **Centralize the launch-URL precedence**: add a helper named **`global_or_shinyparam_or_urlparam`**, defined in **`R/utils_global_or_param.R`**, that returns `url_param(name) %||% global_or_param(name)` (i.e. launch-URL value wins over the ejamapp/global default), and use it everywhere instead of hand-written `%||%` chains. Defines layer-2 precedence in one place. *(Coordinate with PR #413, which introduced the `url_*` reactives on `ejscreen-multisite-selection`.)*
2. **Consolidate the `ss_choose_method` writers** into one observer with explicit precedence (URL > ejamapp data param > advanced-tab > static), commented. *User flagged this as good but tricky — do carefully and double-check.*
3. **Fix the two anti-patterns**: split `max_mb_upload` into `observe`-writes / `reactive`-reads; make `naics_digits_shown` respect a user override.
4. **Rename `default_upload_dropdown` → `default_site_method`** with a back-compat alias (the value now selects dropdown/upload/mapclick). *User flagged as good but tricky — do extremely carefully; keep the alias so existing `ejamapp()` calls and bookmarks/URLs keep working.*
5. **Documentation pass**, especially the customizing vignette `dev-app-settings.Rmd` ("Defaults and Custom Settings for the Web App"): document the two-axis model, the alias table, the precedence stack (incl. launch-URL once merged), and the renamed param.

---

## Key file references

- `R/utils_global_or_param.R` — `global_or_param()` (reads golem_opts; future `global_or_shinyparam_or_urlparam` home).
- `R/utils_get_global_defaults_or_user_options.R:72` — startup merge of ejamapp params + 3 global-default files.
- `R/ejamapp.R ~275-388` — alias normalization + dependent-default inference; `enableBookmarking='url'`.
- `R/app_ui.R` — Design A defaults; advanced-tab radios; `bookmarkButton()`; ~48 `global_or_param()` defaults.
- `R/app_server.R` — Design C `update*Input()` calls; Design B `renderUI` controls; advanced-tab→main syncs.
- `inst/global_defaults_*.R` — the default values (package / shiny / shiny_public).
- `vignettes/dev-app-settings.Rmd` — the customizing vignette (covers bookmarking + defaults; missing launch-URL + alias docs).
- Launch-URL params: `R/app_server.R` on branch `ejscreen-multisite-selection` (PR #413), pattern `url_x() %||% global_or_param("x")`.
