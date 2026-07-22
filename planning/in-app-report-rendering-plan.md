# Non-blocking in-app single-site report rendering

**Status:** Approved design, pending implementation plan

**Implementation branch:** not yet created

**Base:** `origin/development`

## Objective

For users already viewing analysis results in the EJAM Shiny app, generate selected single-site reports locally from the in-memory `ejamit()` result instead of sending the same site back through the EJAM API. Rendering must run outside the Shiny session's main R process so the app remains responsive.

The change targets the largest avoidable delay for uncached single-point reports: an API round trip that repeats analysis the app has already completed. Expected local HTML rendering is approximately 3–6 seconds instead of an approximately 25-second API round trip. PDF rendering also uses the selected local path and benefits from the separate PDF-wait optimization.

## Exact surface boundary

Only the two live, in-app surfaces change. Exported artifacts continue to contain durable API links.

| Report-link surface | New behavior | Format source |
|---|---|---|
| Live detailed-results DataTable, Reports column, one row per site | Render locally in a background process | Current app format selector |
| Live Leaflet map popups in the in-app HTML report view | Render locally in a background process | Current app format selector |
| By-site table in the Excel download | Unchanged API URL | Existing exported URL |
| Map popups in the downloaded HTML report | Unchanged API URL | Existing exported URL |

The existing format selector remains authoritative: HTML is used when HTML is selected and PDF is used when PDF is selected. The link behavior is evaluated when the user clicks, so it respects the selector's current value.

## Data-flow boundary

`data_processed()` remains the source of truth and is never mutated. Its report columns continue to hold the current API URLs used by downloads and other callers.

Create an app-display-only representation for the live DataTable and live Leaflet map. In that representation only, the single-site EJAM report link is replaced with an app action carrying a stable site-row identifier. The display copy is passed to:

- `create_interactive_table()` for the live detailed-results table.
- `mapfast()` or `popup_from_ejscreen()` for the live map, according to the existing point/FIPS path.

The original `data_processed()` object continues to be passed to Excel generation and `ejam2report()` for downloaded HTML. Consequently, exported by-site tables and downloaded map popups keep their existing API URLs without special-case repair after rendering.

This separation also avoids changing `default_reports`, `url_ejamapi()`, or `popup_from_ejscreen()` globally, which would accidentally alter direct API and exported-link behavior.

## Click and browser behavior

Each live report link will:

1. Open a placeholder tab synchronously from the click event, avoiding browser popup blocking.
2. Send Shiny the site-row identifier and a unique request identifier.
3. Snapshot the current format selector and all render inputs.
4. Show progress in the original app while rendering continues in the background.
5. Navigate the placeholder tab to the session-served HTML or PDF once ready.
6. Display a useful error and close or replace the placeholder if rendering fails.

Existing visible link labels and placement should remain familiar. The old draft single-site `downloadHandler` and observer code in `app_server.R` should be refactored or removed if superseded; there must not be two competing click handlers.

## Background execution

Create one `shiny::ExtendedTask` per Shiny session. Its invocation receives ordinary snapshotted values, never reactive expressions:

- The in-memory `ejamit()` output.
- Selected site-row number and display label.
- The current `input$fileextension` value.
- Existing report and analysis titles and other arguments needed to preserve current output.
- Any shape or already-computed context required by the existing report path.
- A request identifier and destination path.

The task starts a clean `callr` background R process and returns a promise that polls the process without blocking the Shiny event loop. The worker calls `EJAM::ejam2report()` using the supplied `ejamitout` and `sitenumber`; it must not call `ejamit()` or the API.

The worker loads the EJAM namespace without attaching the package, disables user and system profile loading, and receives an explicit library path. This avoids `.onAttach()` work, global data loading, and project-profile side effects in every report process.

`ExtendedTask` serializes overlapping invocations for the session. The UI should state when a request is queued or running rather than silently ignoring repeated clicks.

## Session file serving and cleanup

Each Shiny session receives:

- A unique temporary directory.
- A unique, unguessable resource-path prefix registered with `shiny::addResourcePath()`.
- Unique filenames per request with the chosen `.html` or `.pdf` extension.

On session end, terminate any active background process, remove the resource mapping, and delete the session directory. Do not expose filesystem paths in browser URLs or logs. Successful files live only for the session unless a future retention policy explicitly changes that.

## Dependencies

- Keep `callr` as the process-isolation mechanism; promote it from `Suggests` to `Imports` because the app path depends on it at runtime.
- Add direct `Imports` for `promises` and `later` if their namespaces are called directly.
- Do not add `mirai`; it is not currently an EJAM dependency and is unnecessary for the chosen adapter.

## Error handling

Failures are contained to the report request and must not crash the Shiny session. The app reports:

- An invalid or stale site-row identifier.
- A worker startup or serialization failure.
- An `ejam2report()` error.
- Missing PDF dependencies when PDF is selected.
- A worker exit without the expected output file.
- A timed-out or cancelled task.

The original API URL remains available in the unmodified result data, but automatic fallback is not part of this first implementation because it could unexpectedly repeat a slow analysis and obscure local-render defects. A visible retry or API-fallback affordance can be considered after observing production failures.

## Verification

Unit and server tests will establish that:

- The display-only transformation changes exactly the two live surfaces.
- `data_processed()` retains API URLs after live links are prepared and clicked.
- Excel by-site output retains the existing API report link.
- A downloaded HTML report's map popup retains the existing API report link.
- Both the DataTable action and live map-popup action pass the correct one-based site row.
- A click snapshots the current format selector, producing `.html` for HTML and `.pdf` for PDF.
- The worker calls `ejam2report()` with the supplied result and never calls `ejamit()` or the API.
- Success sends the correct session URL to the originating browser tab.
- Worker errors are surfaced without ending the Shiny session.
- Session cleanup removes files, resource mappings, and active processes.

A focused baseline on `origin/development` currently passes 205 tests with two expected interactive/Shiny skips. Browser-level tests will cover both live click locations and both selector values. A manual timing check will compare the existing API link with the local HTML path using the same one-site, 3-mile result.

## Compatibility and non-goals

- EJScreen and direct EJAM API callers are unchanged.
- API caching and API deployment are unchanged.
- Excel and downloaded HTML remain portable and do not depend on the originating Shiny session.
- Multisite report generation is unchanged.
- The analysis itself is not recomputed.
- This PR does not redesign report contents, the results table, map styling, or the format selector.
- This local path complements rather than replaces API-side performance work.

## Rollback

Because original API URLs remain present in `data_processed()`, rollback consists of routing the two live surfaces back to those columns and removing the session task/resource adapter. No data or exported artifact migration is required.
