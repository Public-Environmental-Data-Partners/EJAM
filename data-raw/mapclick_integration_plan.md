# Plan: "Click on map" point selection in the EJAM app

Status: **designed, NOT yet implemented** (2026-06-26)
Branch where the module fix lives: `fix-latlon-from-map-click-module`
Module file: `R/MODULE_latlon_from_map_click.R`

## Goal

Add a third way to specify sites in the EJAM Shiny app (`ejamapp()`): let the user
**click on the existing main-tab map to drop one or more points**, as an alternative to
the current "Select a category of locations" (dropdown) and "Upload specific locations"
(upload) options. Clicked points must be handled by the server exactly like uploaded
lat/lon points so that the radius slider, the map circles, "Review selected sites",
running the analysis, and downloads all work with no special-casing downstream.

## Decisions locked in (from review with user, 2026-06-26)

1. **Scope of "Click or draw on map":** Phase 1 is **click-to-add points only**.
   Free-draw / lasso polygons are a **future phase** (would build on `R/MODULE_lasso.R`
   + `leaflet.extras` draw toolbar and feed the existing `SHP` path). Not in this plan's
   implementation scope, but the UI label ("Click or draw on map") and routing are chosen
   so drawing can be added later without renaming things.
2. **Module reuse:** **Refactor** `MODULE_SERVER_latlon_from_map_click` into a
   **map-agnostic "points accumulator"** that binds to the app's *existing* `an_leaf_map`
   click events. The module will **not** render the map in the app (the app already does).
   The self-contained standalone demo + `testServer` test in the module file stay working.
3. **Delete a point:** user **clicks an existing point on the map to remove just that one**,
   plus a **Clear all points** button. (Undo-last and the click-to-delete share the same
   accumulator API, so undo can also remain available.)

## How the EJAM app handles sites today (reference, with anchors)

- **Top-level method radio** `ss_choose_method` — values `dropdown` / `upload`
  — `R/app_ui.R:114`.
- **Upload sub-type** `ss_choose_method_upload` (latlon, FRS, SHP, FIPS, EPA_PROGRAM)
  — `R/app_ui.R:141`; choices defined in
  `inst/global_defaults_shiny_public.R:118` (`default_choices_for_type_of_site_upload`).
- **Method router** `current_upload_method()` — `switch()` over the two radios
  — `R/app_server.R:349`. Returns e.g. `"latlon"`, `"FRS"`, `"SHP"`, ...
- **Central data reactive** `data_uploaded()` — `switch()` on `current_upload_method()`,
  returns the per-method reactive — `R/app_server.R:1295`. For latlon it returns
  `data_up_latlon()`.
- **latlon ingest** `data_up_latlon()` — `R/app_server.R:627`. Produces a `data.table`
  with `ejam_uniq_id`, `lat`, `lon`, `valid`, `invalid_msg` (via `latlon_df_clean()`),
  sets `disable_buttons[['latlon']] <- FALSE` and `invalid_alert[['latlon']]`.
  **This is the output shape every downstream consumer expects.**
- **Base map** `orig_leaf_map()` (`R/app_server.R:1646`) → rendered by
  `output$an_leaf_map` (`R/app_server.R:1791`). For latlon it builds a leaflet map and
  `fitBounds`/`setView` to the uploaded points. Reacts to `data_uploaded()` — so it
  currently **re-creates the map (and re-zooms) whenever the points change.**
- **Circle drawing** — a separate `observe()` using
  `leafletProxy("an_leaf_map") %>% map_facilities_proxy(rad = sanitized_radius_now(), ...)`
  — `R/app_server.R:2357` (latlon branch ~`R/app_server.R:2392`). **Already reacts to the
  radius slider**, so the radius requirement is satisfied for free once clicks feed
  `data_uploaded()`.
- **Radius slider** `input$radius_now` → `sanitized_radius_now()` (`R/app_server.R:46`);
  per-method memory in `current_slider_val` / `current_slider_min`
  (`R/app_server.R:1563`, `1576`); restored on method change at `R/app_server.R:1625`.
- **"Review selected sites"** button `show_data_preview` → modal with DT
  `print_test2_dt` (`R/app_server.R:378`), driven by `data_preview()` (`R/app_server.R:1460`)
  which reads `data_uploaded()`. **Auto-updates** when clicks change `data_uploaded()`;
  re-opening the modal shows the latest list. Downloads (`download_sites_before_analysis_*`)
  also read `data_preview()`.
- **Per-method reactiveValues that must gain a `mapclick` key:** `disable_buttons`
  (`R/app_server.R:1318`), `invalid_alert` (`R/app_server.R:393`), `an_map_text_pts`
  (`R/app_server.R:1406`), `current_slider_min` (`R/app_server.R:1563`),
  `current_slider_val` (`R/app_server.R:1576`), and the radius-default seeding loop
  `these <- c('latlon', ...)` (`R/app_server.R:1602`).

**Key consequence:** because the map circles, the preview table, the run button, and the
downloads all read `data_uploaded()`, the entire integration reduces to: *make
`data_uploaded()` return the clicked points when the method is `mapclick`.* Everything
else follows.

## Target design

### New method value: `mapclick`

- Add a third `ss_choose_method` radio choice: name **"Click or draw on map"**,
  value **`mapclick`** (`R/app_user.R` radio at `R/app_ui.R:114`). No sub-`selectInput`
  needed (unlike `dropdown`/`upload`), so the routing in `current_upload_method()` gets a
  top-level branch returning `"mapclick"` rather than going through a sub-switch.
- A `conditionalPanel(condition = "input.ss_choose_method == 'mapclick'")` in the
  left control column holds the **Clear all points** button, a short help line
  ("Click the map to add a point; click a point again to remove it"), and the live
  count / invalid-site alert (reuse `an_map_text_pts` / `invalid_sites_alert2`).

### Reactive data flow

```
input$an_leaf_map_click ──► (accumulator) ──► mapclick_points  (reactiveVal: lat, lon)
input$an_leaf_map_marker_click ──► (accumulator removes that point)
input$mapclick_clear ──► (accumulator empties mapclick_points)
                                    │
                       data_up_mapclick()  (clean to ejam_uniq_id/lat/lon/valid/invalid_msg,
                                    │        set disable_buttons[['mapclick']], invalid_alert)
                                    ▼
                       data_uploaded()  (switch: method=='mapclick' -> data_up_mapclick())
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
 orig_leaf_map()/proxy       data_preview()/print_test2_dt   bt_get_results (run ejamit)
 (circles + radius)          ("Review selected sites")        + downloads
```

### Module refactor (the reusable accumulator)

Refactor `R/MODULE_latlon_from_map_click.R` so the point-accumulation logic is separated
from the demo map. Concretely:

- **Keep** `MODULE_UI_latlon_from_map_click()` and the standalone demo app + `testServer`
  block (these render their own `mymap` and are used for isolated testing — do not break).
- **Generalize** `MODULE_SERVER_latlon_from_map_click(id, reactdat, ...)` to accept
  optional external wiring so it works in two modes:
  - `add_click`   — a `reactive()` returning the latest map click as `list(lat=, lng=)`
                    or `NULL` (in the app: `reactive(input$an_leaf_map_click)`).
  - `remove_click`— a `reactive()` returning the latest marker/shape click (which carries
                    a layer `id`) to delete one point (in the app:
                    `reactive(input$an_leaf_map_marker_click)`).
  - `clear`       — a `reactive()` / event to empty all points (in the app:
                    `reactive(input$mapclick_clear)`).
  - `render_map`  — `TRUE` for standalone (module draws `mymap` + slider + redraws),
                    `FALSE` for the app (app owns `an_leaf_map`, slider, and circle proxy).
  - When the external `add_click`/`clear` args are supplied, the module observes **those**
    instead of its own `input$mymap_click` / `input$clear_points`, and (with
    `render_map = FALSE`) skips `output$mymap`, the slider, and the redraw observer.
  - The accumulator's core (already present and tested): append `data.frame(lat, lon)` to
    `reactdat` on add; drop the matching row on remove; reset on clear; `latlon_only()`
    normalization. **This logic is what the app reuses.**
- The module continues to **return `reactdat`** (the reactive points table), matching the
  `MODULE_latlontypedin` contract.

App usage (in `app_server.R`):

```r
mapclick_points <- reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))
MODULE_SERVER_latlon_from_map_click(
  id          = "mapclick",
  reactdat    = mapclick_points,
  add_click   = reactive(input$an_leaf_map_click),
  remove_click= reactive(input$an_leaf_map_marker_click),
  clear       = reactive(input$mapclick_clear),
  render_map  = FALSE
)
```

> Alternative considered: re-implement the ~10 lines of accumulator logic inline in
> `app_server.R` and keep the module purely as a standalone demo. Rejected per decision #2
> (user wants the module reused), and the refactor keeps a single source of truth for the
> add/remove/clear behavior.

### `data_up_mapclick()` — make clicks look like an upload

New reactive mirroring `data_up_latlon()` (`R/app_server.R:627`) but sourcing rows from
`mapclick_points()` instead of a file:

```r
data_up_mapclick <- reactive({
  pts <- mapclick_points()
  if (is.null(pts) || NROW(pts) == 0) {
    disable_buttons[['mapclick']] <- TRUE
    an_map_text_pts[['mapclick']] <- NULL
    return(NULL)            # data_uploaded() -> NULL, map shows empty base map
  }
  sitepoints <- data.table::as.data.table(pts)
  sitepoints[, ejam_uniq_id := .I]
  data.table::setcolorder(sitepoints, 'ejam_uniq_id')
  sitepoints <- latlon_df_clean(sitepoints, invalid_msg_table = TRUE)
  sitepoints$invalid_msg <- NA
  sitepoints$invalid_msg[is.na(sitepoints$lon) | is.na(sitepoints$lat)] <- 'bad lat/lon coordinates'
  disable_buttons[['mapclick']] <- FALSE
  invalid_alert[['mapclick']]   <- sum(!sitepoints$valid)
  sitepoints
})
```

Then add the branch to `data_uploaded()` (`R/app_server.R:1299`):

```r
} else if (current_upload_method() == 'mapclick') { data_up_mapclick()
```

and the top-level branch in `current_upload_method()` (`R/app_server.R:349`):

```r
'mapclick' = 'mapclick',
```

(`max_pts_upload` / `max_pts_run` caps are enforced by the same observers as uploads since
they key off `data_uploaded()` and `current_upload_method()` — `R/app_server.R:1366`.)

## Edge cases & UX details to get right

1. **Add vs. delete disambiguation.** Clicking a marker fires *both*
   `an_leaf_map_marker_click` and `an_leaf_map_click`. To avoid "delete then immediately
   re-add", the accumulator must ignore the map click that coincides with a marker click
   (same reactive flush). Implementation: when `remove_click` fires, stamp a guard token;
   the `add_click` handler checks the guard and the click coordinates and skips if it
   matches the just-removed marker. (Assign each circle/marker `layerId = ejam_uniq_id` so
   `marker_click$id` identifies the row to drop.) **This is the trickiest part — call it
   out in the task and cover it in tests.**
2. **Base map must not re-zoom on every click.** `orig_leaf_map()` currently depends on
   `data_uploaded()` and re-fits bounds. For `mapclick`, build the base map **once**
   (depend only on `current_upload_method() == 'mapclick'`, `isolate()` any initial view —
   e.g., a US-wide `setView`, or center on existing points the first time only) so adding
   a point doesn't yank the viewport. The existing circle-drawing `leafletProxy` observer
   (`R/app_server.R:2357`, latlon branch) then updates circles incrementally — it already
   reacts to `data_uploaded()` + `sanitized_radius_now()` and uses `clearShapes()` first,
   so it handles add/remove/clear correctly with no change beyond ensuring `mapclick`
   takes the latlon branch (it will, since it is not SHP/FIPS).
3. **Clear removes prior points (incl. a previous upload).** "Clear all points" empties
   `mapclick_points()`. Because `data_uploaded()` for `mapclick` returns only
   `data_up_mapclick()`, switching to `mapclick` already hides any prior `upload` data;
   Clear then resets the click set to empty. (Switching methods does not delete the other
   method's stored reactive — that matches today's behavior where each method keeps its own
   inputs.)
4. **Radius slider.** No new work: `mapclick` flows through the latlon circle proxy which
   uses `sanitized_radius_now()`. Just add `mapclick` to `current_slider_val`,
   `current_slider_min`, and the `radius_default` seeding loop so the slider initializes
   and is enabled (not disabled like FIPS/SHP).
5. **Run button / preview gating.** `disable_buttons[['mapclick']]` is toggled in
   `data_up_mapclick()` (FALSE once ≥1 point). The existing observe at `R/app_server.R:1335`
   then enables `bt_get_results` and shows `show_data_preview` automatically.
6. **"Review selected sites".** No change needed — `data_preview()` reads `data_uploaded()`;
   re-opening the modal after more clicks shows the updated list.
7. **Validity & invalid alert.** `latlon_df_clean()` yields `valid`/`invalid_msg`; reuse
   `invalid_sites_alert2` / `invalid_alert[['mapclick']]`. (Clicks on the map are always
   valid lat/lon, so this is mostly a no-op but keeps parity.)

## Implementation phases / task breakdown

1. **Refactor module** (`R/MODULE_latlon_from_map_click.R`): add `add_click`,
   `remove_click`, `clear`, `render_map` params; keep standalone demo + `testServer`
   passing; add `testServer` cases for external-wiring mode (simulate `add_click`,
   `remove_click`, `clear` reactives).
2. **Globals/UI**: add `'Click or draw on map' = 'mapclick'` to the `ss_choose_method`
   radio (`R/app_ui.R:114`); add the `mapclick` `conditionalPanel` (Clear button, help
   text, count/alert). Decide whether `mapclick` appears for both public and internal
   builds (default: yes for both).
3. **Server routing**: `mapclick` branches in `current_upload_method()`
   (`R/app_server.R:349`) and `data_uploaded()` (`R/app_server.R:1295`); add `mapclick`
   keys to the per-method reactiveValues lists; add `mapclick` to the radius seeding loop.
4. **Server wiring**: `mapclick_points` reactiveVal + `MODULE_SERVER_latlon_from_map_click(
   ..., render_map = FALSE)` call; `data_up_mapclick()`; `input$mapclick_clear` handled by
   the module's `clear` arg.
5. **Base map**: make `orig_leaf_map()` produce a stable, non-re-zooming base map for the
   `mapclick` method; verify the circle proxy updates on add/remove/clear and on radius.
6. **Delete disambiguation**: implement and unit-test the marker-click-vs-map-click guard.
7. **End-to-end test**: `shinytest2`/manual — click several points (circles + radius
   appear), move radius slider (circles resize), click a point to delete it, Clear all,
   open "Review selected sites" (table matches), run analysis (`ejamit` gets the clicked
   sitepoints), download CSV/XLSX.

## Testing

- **Module unit (`shiny::testServer`)**: external-wiring mode — feed `add_click` twice →
  2 rows; `remove_click` with a layer id → 1 row; `clear` → 0 rows; confirm `reactdat`
  shape is `lat,lon`.
- **App integration (`shinytest2`, see existing app tests)**: drive `input$an_leaf_map_click`
  via `session$setInputs`, assert `data_uploaded()` row count, `data_preview()`, and that
  `bt_get_results` becomes enabled; assert radius change updates circles (smoke).
- **Regression**: existing `upload`/`dropdown` flows unchanged (the new branch is additive).

## Future phase: "draw" (polygons / lasso)

Out of scope here. When added: surface a `leaflet.extras::addDrawToolbar()` (or reuse
`R/MODULE_lasso.R`) on `an_leaf_map` under the same `mapclick` method, capture
`input$an_leaf_map_draw_new_feature`, convert to an `sf` polygon, and route through the
existing **`SHP`** path (`data_up_shp()` / `map_shapes_leaflet_proxy`). The `mapclick`
method would then yield either points (clicks) or polygons (draws); `data_uploaded()`
would dispatch to the latlon vs SHP handling accordingly.

## Open questions / risks

- **Marker-click vs map-click race** (#1 above) is the main technical risk; budget time to
  test across leaflet versions.
- **Public vs internal availability**: should `mapclick` be in the public build's radio, or
  internal-only at first? (Default assumption: available in both.)
- **Initial map view** for `mapclick` when there are zero points (US-wide `setView` is the
  proposed default).
- **Interaction with bookmarking**: clicked points live in a `reactiveVal`, not an
  `input$`, so (like typed-in points) they are **not** restored by URL bookmarking. Note
  this limitation; matches the `latlontypedin` caveat already in the module notes.
