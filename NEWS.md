# EJAM 3.2022.3 (unreleased)

Features from the v4 milestone, shipping on the ACS 2018-2022 vintage.

This is the final ACS 2018-2022 release; it is frozen from here on. The 2020-2024
vintage ships separately as `4.2024.0`, which is where development continues.

## New Features

- Zip code analysis: `ejamit(zipcode = 10605)` now works. Zip codes are converted
  to Census ZCTA polygons by the new `shapes_from_zip()` helper and analyzed like
  any other shapefile, and `ejam2report()` describes the places as zip codes and
  maps their boundaries without needing the `shp` parameter. This automates the
  workflow that the Zipcodes article documented as manual steps (#482).

## Bug Fixes

- The notes tab of the Excel workbook now says how the sites were selected. It
  had never done so: `buffer_desc_from_sitetype()` only appended that detail when
  the description so far was empty, which none of its branches can produce, and
  the test inside was inverted as well. A SIC analysis of latitude/longitude
  sites now reads "Locations defined by latitude, longitude and radius, based on
  EPA-regulated facilities by SIC code (industry type)" instead of stopping at
  the radius. The detail is left off when it would only restate the site type,
  so plain shapefile analyses do not read "Polygons defined by shapefile, based
  on shapefile".

- SIC and MACT analyses get their descriptions back. `site_method2text()`
  lowercases its input, but its SIC and MACT branches compared against the
  uppercase spellings, so neither could ever match and both fell through to an
  empty string.

- `ejam2report()` now fetches FIPS boundaries when `site_method` is given as
  "fips" rather than "FIPS". The two gates that rebuild those polygons were
  case-sensitive, so a lowercase spelling silently produced an unmapped report.
  Matches how the zip code gates added for #482 already behave.

- Percentiles no longer depend on which operating system the analysis runs on.
  A raw score is normally a population-weighted average, so it carries a few
  units in the last place of rounding error, and how much differs between macOS,
  Linux, and Windows. Because percentile lookup is a step function, a score that
  lands exactly on a cutoff could fall either side of it, and where the lookup
  table has several percentiles tied at one cutoff the reported percentile could
  move by the whole width of that tie block. One test site's state asthma
  percentile differed by 7 points between operating systems for this reason.
  Scores that sit within floating-point noise of a cutoff are now snapped onto
  it, so every platform reports the same percentile, and a tied cutoff correctly
  reports the lowest of the tied percentiles as documented (#555).

  This corrects saved percentiles in the eight `testoutput_ejamit_*` and
  `testoutput_doaggregate_*` datasets, which had recorded the higher end of a tie
  block. Only percentile columns changed. It also means `lookup_pctile()` handles
  the ACS22 `pctdisability` boundary case without needing the `signif_digits`
  argument.

- A GitHub outage no longer looks like missing data. When the API cannot list a
  release's assets, `download_latest_arrow_data()` now says so and retries,
  instead of treating the empty answer as an empty release and reporting a
  missing `quaddata.arrow` much later.


# EJAM 3.2022.2 (August 2026)

A code-and-docs patch over v3.2022.1, led by a faster web app and 
new information in the community report about where people live.

## Highlights

- **A quicker web app:** the Details tab's Site-by-Site Table appears in well
  under a second for a 1,000-site analysis instead of roughly six, PDF reports
  finish about seven seconds sooner, and County reports no longer pause to
  download map boundaries.

- **More about where people live:** the community report has new rows showing the
  share of residents whose blockgroup contains a school, hospital, or place of
  worship, or overlaps a Tribal area, impaired waters, a
  disadvantaged community, etc. -- each compared to the US and State average.
  The "Additional Information" part of the report is also reorganized.

- **Ratio columns are now shown by default:** "Ratio to US average" and
  "Ratio to State average", with their color coding, now show in the public
  app's report (not just when isPublic=FALSE).

- **Numbers display correctly:** percentages that had appeared as "0" or "1"
  instead of, say, "79%" now render properly in the report, tables, and map
  popups, and percentages and counts round consistently.

- **New URLs are shorter and provide caching:**
  - EJScreen app: [ejscreen.ejanalysis.com](https://ejscreen.ejanalysis.com)
    - docs: [ejscreendocs.ejanalysis.com](https://ejscreendocs.ejanalysis.com)
  - EJAM app: [ejam.ejanalysis.com](https://ejamapp.ejanalysis.com)
    - docs: [ejamdocs.ejanalysis.com](https://ejamdocs.ejanalysis.com)
  - API: [api.ejanalysis.com](https://api.ejanalysis.com)
    - docs: [apidocs.ejanalysis.com](https://apidocs.ejanalysis.com)
  
- **Bugs fixed**, including a crash when arriving from EJScreen's "Send to EJAM"
  button and downloaded reports that came out empty (details below).

- **Intermittent upload failures on the hosted app are being fixed alongside
  this release** (#268), but by a change to the hosting setup rather than by
  anything in this package. The production app runs on two servers, and an
  upload could be sent to the one that was not holding your session, which
  answered "Not Found" -- roughly half the time. The load balancer is being set
  to keep each session on a single server, the same fix applied in early 2026
  that was later lost when the servers were rebuilt from their configuration
  files. Because it is a hosting change, installing v3.2022.2 does not by itself
  resolve it; the two are simply being done at the same time.

## Improvements

- **The Site-by-Site Table builds about 4x faster** (#491, fixes #127): it now
  starts from a default subset of about 50 columns rather than all ~700 and
  shows 50 rows per page, and the slow steps in building it were rewritten. Any
  columns can still be added from the Advanced Settings column picker (which had
  never appeared -- also fixed), and downloads always include every column.

- **PDF reports are about 7 seconds (~50%) faster** (#473, helps #293), from
  trimming two fixed waits during rendering. Both stay adjustable on a server
  without a rebuild, in case a shorter pause ever degrades output.

- **County reports & maps are faster and more reliable** (#472, part of #446):
  county boundaries are built into the package instead of downloaded while the
  report renders, so no Census API key or boundary-service call is needed, and
  Puerto Rico counties now map correctly.

- **Report's "Additional Information" table was reorganized** so related
  rows sit together: feature counts, facility counts, and analyzed-site rows are
  now separate sections, "Climate" moved up next to "Poverty", and "Flag for..."
  rows read Yes/No instead of 1/0. A footnote explains what the feature and
  facility counts mean, and what a State average means for a multisite report
  (part of #403 and #410).
  
- **The State flagged-areas stats are available outside the report too**
  (closes #242; addresses #156 and #410):
  `ejamit()$results_summarized$flagged_areas` gains statewide percent and
  ratio-to-state columns, `ejam2barplot_areafeatures(vs = "state")` plots
  against State averages, and `ejam2excel()` gains an "Area Features" tab.

- **A new launch-URL parameter:** `?advanced=TRUE` opens the app with the
  Advanced Settings tab visible, even on a public deploy.


## Bug Fixes

- **Report's percentages no longer shown as "0" or "1", or with stray decimals**
  in the report, tables, and map popups (#488). The metadata marking which
  indicators are stored as fractions had been lost, disabling the conversion to
  percent for 76 indicators (language, poverty, housing, broadband, health
  insurance, age, sex, pre-1960 housing, fire and flood risk, and their US and
  State rows).

- **Reports on a site via link to API no longer all say "Site 1"** (#348, fixed
  by #470 and #479); a link for row N now produces a report labeled "Site N".

- **The EJScreen "Send to EJAM" handoff no longer crashes the session** (#465,
  fixed by #466), which it did for every County/Tract and drawn-polygon
  selection, and for any point selection made without a buffer.

- **Zero-population sites no longer error or return wrong statistics** (#467,
  fixed by #468) -- open-water blockgroups and industrial parcels with no
  residents.

- **Saved reports are no longer empty when a `filename` is given** (#385, fixed
  by #471 and #475), and `ejam2report()` accepts a much wider range of file
  names and extensions.

- **`acs_bybg(year = 2024)` no longer wrongly errors** (#391, fixed by #469).
  The year check now follows what the Census Bureau has actually published,
  rather than the tidycensus default year, which can lag by more than a year.

- **Rounding helpers no longer alter their inputs** (#491): `table_round()`,
  `table_signif()`, `table_x100()`, and `is.numericish()` converted a data.table
  in the caller's environment into a data.frame; all four now leave the caller's
  object untouched and return the class they were given.

## For Developers

- **New URLs set up, and all key URLs are single-sourced** as
  `Config/EJAM/url_*` fields in `DESCRIPTION`, read through `url_package()`,
  which now also gives a clear error listing the valid types
  (#485, #501, #502, #503). New short aliases via Cloudflare,
  like [api.ejanalysis.com](https://api.ejanalysis.com), 
  [ejam.ejanalysis.com](https://ejam.ejanalysis.com), and 
  [ejamdev.ejanalysis.com](https://ejamdev.ejanalysis.com), etc. are easy to remember and
  provide edge caching and 302 redirects to the actual deployed endpoints. URLs  
  [ejamdocs.ejanalysis.com](https://ejamdocs.ejanalysis.com) and
  [ejscreendocs.ejanalysis.com](https://ejscreendocs.ejanalysis.com) 
  now redirect to documentation sites for EJAM and EJScreen and support links like 
  - [ejamdocs.ejanalysis.com/dev](https://ejamdocs.ejanalysis.com/dev), 
  - [ejamdocs.ejanalysis.com/dev/articles/dev-api.html](https://ejamdocs.ejanalysis.com/dev/articles/dev-api.html) or 
  - [ejamdocs.ejanalysis.com/reference/url_package.html](https://ejamdocs.ejanalysis.com/dev/reference/url_package.html).

- **A way to test changes to the API and test draft EJAM use of the API:**
  `EJAM:::ejamapi_local()` serves a local stand-in for deployed API as a
  byte-for-byte mirror of the EJAM-API repo at the production paths, with
  draft-only endpoints under `/draft/...` (grouped as "Draft API Endpoints" in
  the Swagger page), and `url_package("api")` honors an
  `options(ejam.api.baseurl=)` / `EJAM_API_BASEURL` override so the package and
  app can be pointed at a local or draft API (#499, #509).

- The web app article now covers deep links, the EJScreen "Send to EJAM" button,
  and launching the app pre-loaded with a set of places. The analysis article
  cross-references the API article. Broken code chunks were fixed in two
  other articles. Many other cleanup edits were done.

- `ejamapi()` and `url_ejamapi()` no longer send a `version` parameter by
  default, since the API serves whichever data vintage it has installed.

- The `AOI` geocoding dependency used by `latlon_from_address()` now installs
  from the `ericnost/AOI` fork (#478, fixes #477).

- **A new release workflow** tags a release from the `Version` in `DESCRIPTION`
  and publishes a GitHub Release whose notes are the matching `NEWS.md` section.
  It defaults to a dry run and refuses to act on an unexpected version (#512).

- The shipped example input and output data and example spreadsheet, HTML, & PDF
  outputs were regenerated so they carry the new report content (#512).

## Datasets are unchanged

This reuses the existing `ejamdata` **v3.2022.0** data -- the packaged ACS and
environmental files are byte-identical to v3.2022.0 -- so it is a drop-in update
over v3.2022.1 with the same demographics, plus code and documentation
improvements. The same applies across the annual-vintage lines
(v3.2022.x, v3.2023.x, v3.2024.x).


# EJAM 3.2022.1 (July 2026)

Patch release for the v3.YYYY.x annual-vintage line (v3.2022.x, v3.2023.x,
v3.2024.x). Functionality is identical across all three ACS vintages
(2018-2022, 2019-2023, 2020-2024); only the ACS data vintage differs between
branches. This is a code-and-docs patch: it reuses the existing per-vintage
ejamdata release, with no change to the packaged ACS or environmental data.

Changes since v3.YYYY.0:

## New Features

### EJScreen integration via API and deep-linking to EJAM

New features across the EJAM API, the EJScreen web app, and the EJAM web app now
work together so that EJScreen users can select several places directly on the
EJScreen map -- clicking points, picking a "Select an Area" FIPS area, or drawing
a polygon -- and then either get a single multisite report covering all of those
places at once, or hand the same selected places off to the EJAM ("multisite")
web app with the sites already loaded and ready to analyze. The supporting pieces:

- Launch-URL site handoff (pre-load the web app from an external site). The app
  server now reads custom launch query parameters so another app -- notably the
  EJScreen Report tool's new "Send to EJAM" button -- can open EJAM already
  pre-loaded with a set of places:
    - `?lat=33,34&lon=-112,-114` -- one or more points, each a site
    - `?fips=10001,10003` -- one or more FIPS codes, each a separate site
    - `?shape=<url-encoded GeoJSON>` -- a polygon or FeatureCollection
    - `?radius=` / `?buffer=` -- analysis radius in miles
    - `?handoff=<token>` -- a token minted by the EJAM API `POST /handoff` and
      fetched back via `GET /handoff/<token>`, for large polygon sets that exceed
      URL-length limits

  Points and polygons are file-upload inputs that cannot travel in a Shiny
  url-bookmark, so this is the supported way to pass them in at launch. One
  place-type loads per launch (points, then FIPS, then polygons); the parsed
  places are held in per-session reactives (`url_sitepoints`, `url_fips`,
  `url_shapefile`) that the upload reactives prefer over `ejamapp()`/global
  defaults. The vocabulary matches `url_ejamapi()`. See
  `vignettes/dev-app-settings.Rmd`.

- `url_ejamapp()` now builds a deep link that launches the live app pre-loaded
  with a set of places: `url_ejamapp(lat=, lon=, fips=, shapefile=, radius=)` or
  `url_ejamapp(handoff=<token>)`, using the same query vocabulary as
  `url_ejamapi()`. The default app base is now **`https://ejamapp.ejanalysis.com/`**,
  a Cloudflare-fronted shortcut on ejanalysis.com that forwards the query string
  (302 redirect) to the live app so launch parameters arrive intact.

- `url_ejscreenmap()` was rewritten to generate **deep links into EJScreen** that
  actually draw and select the place(s) on the EJScreen map -- `?fips=` (county,
  tract, or blockgroup, mixes allowed), `?lat=&lon=` points (with optional
  `radius=`), or `?polygon=` vertex lists -- matching the new inbound deep-link
  vocabulary EJScreen itself gained (so links from EJAM reports and tables select
  the analyzed place for an EJScreen report instead of only dropping a centroid
  pin). Stored test outputs were deliberately not regenerated for the resulting
  URL-column changes.

- The EJAM API base URL is now **single-sourced**: functions read it from
  `DESCRIPTION` via `url_package("api")`, so the endpoint can be
  changed in one place instead of being hardcoded in several. The default is now
  the branded alias **`https://api.ejanalysis.com`** (equivalently
  `https://ejamapi.ejanalysis.com`), a Cloudflare edge proxy in front of the Cloud
  Run API -- so report links generated by the app and package route through an
  edge-cacheable host, and repeat requests for the same report can be served
  from cache instead of re-running the analysis. See the new `dev-api` article.

- Report links generated by the app and package now request the better-suited
  format by default: **`html` for multisite** summary reports (much faster to
  generate, and the interactive map has a popup per site) and **`pdf` for
  single-site** reports (proper page breaks for printing). The `fileextension`
  parameter is normalized and strictly validated (`html`/`pdf`) and remains
  overridable per call.

- The EJAM API now supports multisite reports (`sitenumber=0`) and also now has a
  POST `/report` endpoint for large or numerous polygons. Docs for `ejamapp()`,
  `ejamapi()`, and `url_ejamapi()` were updated to reflect that.

### Parameter aliases and flexible site inputs

- Parameter aliases for consistency across the place-input functions -- `ejamit()`,
  `ejamapp()`, `custom_ejamit()`, `ejamapi()`, `url_ejamapp()`, `url_ejamapi()`,
  `ejam2report()`, `ejam2map()`, `shapefile_from_any()`, `sites_from_input()`,
  `ejamit_compare_distances()`/`_fulloutput()`, `ejamit_compare_types_of_places()`,
  `ejamit_sitetype_from_input()`, `latlon_from_shapefile_centroids()`,
  `shape_buffered_from_shapefile()`, the `url_*` map/report-link builders
  (`url_ejscreenmap`, `url_enviromapper`, `url_county_health`/`_equityatlas`,
  `url_state_health`/`_equityatlas`), and the EJAM API:
    - **`buffer`** is a synonym for **`radius`** (and **`buffers`** for the `radii`
      vector) -- it reads more naturally for FIPS or polygon analysis;
    - **`shape`** and **`shp`** are synonyms for the polygon input (**`shapefile`**).
  Canonical names are unchanged; the aliases are accepted wherever relevant.

- `ejamit()` now accepts `lat` and `lon` vectors directly (it builds `sitepoints`
  from them), in addition to a `sitepoints` data.frame. Closes #171.

## Bug Fixes

- The multisite-report download button now shows the correct cursor after being
  manually re-enabled (it previously kept the not-allowed cursor even once the
  report was ready to download).
- Deep-link `?radius=` / `?buffer=` now reliably sets the analysis radius at app
  launch. Previously the launch handler patched the `radius_now` slider via
  `updateSliderInput()`, but that slider is built by `renderUI`, so the update raced
  the (re)render and was clobbered when the site-selection method changed. The launch
  radius is now stored in a reactive value the slider reads at render time. (The other
  deep-link params -- `lat`/`lon`, `fips`, `shape`, `handoff` -- were unaffected.)
- Census API key (tidycensus >= 1.8 breaking change): tidycensus now *errors*
  (no longer warns) without a key -- including for the `load_variables()`
  metadata lookup. `calc_blockgroupstats_acs()` and `acs_table_info()` now fail
  fast with an actionable message when `CENSUS_API_KEY` is unset. A follow-up
  scopes this check to the live-download path only: when raw ACS data are
  supplied (for example, the pipeline rebuilding block-group data from a saved
  stage), no Census API call is made, so a keyless environment is no longer
  blocked.
- `url_online()`: corrected default behavior, and now gives the intended
  "must specify a URL" error on empty, `NA`, or `NULL` input instead of a cryptic
  "missing value where TRUE/FALSE needed".
- `calc_blockgroupstats_acs()`: when ACS table-geography metadata cannot be
  retrieved for any candidate year (e.g. the Census API is unreachable), it now
  stops with a clear, actionable message instead of failing obscurely later.
- Fixed the release-install workflow and updated the EJAM web-app URLs.
- `table_validated_ejamit_row()`: fixed for use by `table_gt_from_ejamit()`.
- `statestats_means()` and `statestats_means_bystates()`: fixed, improved, and
  documented.
- Excel output (issue #148): no longer freezes the "valid" column; freeze panes
  now begin where that column starts.

## New EJScreen Web-App Pipeline Outputs (issue #395)

The data pipeline now produces the remaining EJScreen web-app data files
directly from the `ejscreen_export` stage, so a single pipeline run yields the
full set of EJScreen-ready outputs:

- ACS "additional demographics" summarized by block group, tract, county, and
  state. Count columns are summed and percentage columns are recomputed as
  denominator-weighted means (via the same `calctype()` / `calcweight()` rules
  `doaggregate()` uses), so block-group values match the ACS data already in the
  package.
- The four EJScreen threshold layers (US and State, EJ-index and supplemental)
  with `P1`..`P100` hit-count columns, tallied in a single NA-aware pass with
  out-of-range ranks clamped into `P1`/`P100`.
- A replication helper that compares these outputs to EPA's published EJScreen
  values -- fetched live from EPA's ArcGIS FeatureServers -- repairing FIPS
  leading zeros and mapping EPA column names. Used to confirm the pipeline
  reproduces EPA's by-geography and threshold layers.

(These are produced by internal helpers `calc_acs_by_geography()`,
`calc_ejscreen_threshold_layers()`,
`calc_ejscreen_threshold_layers_from_exports()`, and
`ejscreen_compare_geography_to_epa()`.)

## Documentation

- Folded the v3.2024.0 dataset-update recipe into the dataset-update vignettes.
- Added internal developer notes for the `ejam2areafeatures()` helpers.

## Internal / Packaging

- Unexported internal helper/report functions (`build_community_report()`,
  `build_barplot_report()`, `calc_acs_by_geography()`,
  `calc_ejscreen_threshold_layers()`,
  `calc_ejscreen_threshold_layers_from_exports()`,
  `ejscreen_compare_geography_to_epa()`, `table_gt_format_step1()`,
  `table_gt_format_step2()`, `latlon2nexus()`, `latloncsv2nexus()`, and
  `calc_bgej()`). Their help topics remain available under the pkgdown internal
  reference section.
- pkgdown CI: build the reference without running examples, and install only
  hard dependencies, so the docs site builds reliably.
- Ensured the final byte of `data/ejamdata_version.txt` is always a newline.
- Git-ignore local Claude Code / agent files.


# EJAM 3.2022.0 (June 2026)

EJAM 3.2022.0 is the ACS 2018-2022 vintage in the new annual-vintage release
line (v3.YYYY.0). It provides EJAM and EJScreen-compatible outputs using
demographics from the 2018-2022 American Community Survey -- the same vintage
EPA's EJScreen used through its final update -- now delivered through the new
EJAM annual data pipeline with the v3 functionality.

It shares all functionality with the rest of the v3.YYYY.0 line; the only
difference from v3.2024.0 and v3.2023.0 is the ACS data vintage. The 2018-2022
ACS data were published by the Census Bureau on 2023-12-07.

This release also provides an entirely new process, or "data pipeline" for
data updates, from downloading data to calculating indicators to packaging
the results for both EJAM and EJScreen. The pipeline is fully documented and
reusable, and it saves files at each stage.
Validation included comparing against and replicating key parts of the old
dataset.

Highlights:

- Web App Improvements: Added PDF-format report downloads. Improved Community
  Report barplot legibility, and added more barplot options in the Details tab.

- Data Updates: Updated EJScreen-style ACS demographic data to ACS 2020-2024.
  Refreshed the related package datasets and metadata, so that EJScreen community
  reports and EJAM summary reports will be based on the newer data.

- Data Pipeline: Added a staged annual data pipeline for demographics,
  environmental indicators, extra indicators, geography info, EJ indexes,
  percentile lookup tables, and EJScreen-ready outputs. Using the pipeline,
  updated environmental data or extra indicators can easily be incorporated
  when available.
  Improved ACS formula handling, tract-to-blockgroup processing, Census/TIGER
  geography handling, dynamic Arrow dataset handling, and release checks.

## Web App Improvements

- Enabled PDF download of EJScreen community report, with better page breaks, footers, and rendering reliability.
- Community Report barplot text is now easier to read.
- "Plot Average Scores" barplots in the Details tab are greatly improved, with more options.
- Invalid-site messages column now explains more clearly why a site has no results.
- Fixed issue where map popups could be for the wrong site if some FIPS bounds could not be downloaded.
- Improved runtime prediction messages for point-buffer, FIPS, and shapefile
  analyses, including separate timing information by analysis type and subtype.
- Fixed interactive table of sites issue: avoided by-reference mutation in Details tab.
- Fixed EPA program dropdown choices after refreshing FRS-related lookup data.
- Added a `doaggregate()` guardrail for rare cases where block geography files
  contain blockgroups not present in `blockgroupstats`. Unsupported blockgroups
  are now dropped before aggregation and before nearby blockgroup/block counts
  are reported.


## R Package Functions

- `ejamapi()` was significantly enhanced with PDF support, query endpoint,
  a new parameter to help save .html file reports, bug fixes, 
  more error-checking, and better examples.
- `url_ejamapp()` created as shortcut to the live web app where it is currently hosted.
- `plot_distance_by_pctd()` fix when weights are not population.
- `acs_bycounty()` / `acs_endyear()` fixes: character year handling and renamed/standardized `acs_endyear()`.
- App robustness fixes for NULL settings such as `bookmarking_allowed` or
  `default_hide_about_tab`.

## Data Updates

- Updated the key nationwide datasets of demographic blockgroup-resolution data and related
  metadata for the ACS 2020-2024 EJScreen-style data release.
- Updated the FRS-related datasets (covering all EPA-regulated facilities) and
  related tables used for specifying facilities to analyze by industry.
- Added year-aware metadata handling for R-native pipeline outputs, so pipeline
  runs for different ACS end years record the appropriate ACS version.
- Moved to a system where each release obtains externally stored datasets tagged to
  that release, so an older dataset will be usable if one installs the older release of EJAM.
- Added Island Areas AS/GU/MP/VI at the blockgroup dataset, EJSCREEN export,
  and map-data visibility level for v3.2022.0, with demographic fields kept as
  `NA` by default and partial EPA environmental fields retained where available.
  The annual/release pipeline uses the archived EPA EJScreen ACS2022 reference
  for Island Area row IDs, area fields, and available environmental fields, and
  validates the expected 686 AS/GU/MP/VI blockgroups. The separate raw and
  transformed Island Areas Census checkpoints are still available for optional
  review. Island Area blocks are not added to the block helper files for this
  release path, so radius/buffer analyses there return no-data results rather
  than block-weighted estimates.
- Preserved environmental-indicator missing values as missing values in the
  annual/release pipeline. In particular, later EJAM releases should not repeat
  the historical v2.32.8.001-and-earlier behavior that converted missing EPA
  drinking-water non-compliance (`DWATER`) values to `drinking = 0`; `NA` now
  means no valid source score, while zero means a valid reported score of zero.
- Note: the Census Bureau discourages using overlapping ACS 5-year datasets for
  trend comparisons. Comparisons between ACS 2018-2022 and 2020-2024, e.g.,
  should not be interpreted as valid trend estimates.

## Annual Data Pipeline

- Added `calc_ejscreen_dataset()` as a high-level wrapper for the staged annual
  data update pipeline. Stages include the following:

  1. Download raw ACS demographic tables at blockgroup and tract resolution
     (`bg_acs_raw`).
  2. Calculate ACS-based demographic indicators and the lead paint indicator
     (`bg_acsdata`).
  3. Append Island Areas AS/GU/MP/VI placeholder rows from the archived EPA
     reference by default, with optional Island Areas Census demographics
     available only as separate review checkpoints.
  4. Validate and save key environmental indicators, or reuse existing ones
     (`bg_envirodata`).
  5. Validate and save extra indicators such as low life expectancy, or reuse
     existing ones (`bg_extra_indicators`).
  6. Validate and save Census/TIGER blockgroup geography fields such as
     `arealand` and `areawater` (`bg_geodata`).
  7. Calculate demographic indexes, including supplemental demographic indexes
     that use extra indicators such as low life expectancy.
  8. Combine blockgroup demographic, environmental, extra-indicator, and
     geography fields for EJAM (`blockgroupstats`).
  9. Create percentile lookup tables for demographic and environmental
     indicators (`usastats_acs`, `statestats_acs`, `usastats_envirodata`,
     and `statestats_envirodata`).
  10. Calculate EJ indexes from environmental percentiles and demographic
      indexes (`bgej`).
  11. Create percentile lookup tables for EJ indexes (`usastats_ej` and
      `statestats_ej`).
  12. Combine the percentile lookup tables (`usastats` and `statestats`).
  13. Create EJScreen-ready export files: the national-percentile export
      (`ejscreen_export`) and the EPA-style state-percentile export
      (`ejscreen_export_statepct`).
  14. Optionally create EJScreen-ready percentile lookup exports
      (`ejscreen_us_pctile_lookup` and `ejscreen_state_pctile_lookup`) from
      `usastats` and `statestats`, including EPA-style `std` rows, only when
      explicitly requested.
- Pipeline stages can be read from or written to local folders or AWS S3, and
  can be saved as CSV and/or `.rda` files. Raw ACS data can be saved in a
  single object or in a folder-plus-manifest layout with one file per ACS table.
  Revised vignettes explain updates and the data pipeline and how to customize
  it.
- Added explicit `bg_envirodata` and `bg_extra_indicators` inputs, with
  intentional reuse paths for provisional or unchanged inputs.
- Added manifest and validation outputs for pipeline runs, including comparison
  helpers for prior package releases, S3 pipeline folders, and EJScreen export
  reference files.
- Added `bg_geodata` as an explicit Census/TIGER geography stage for
  `arealand`, `areawater`, internal points, and area-derived checks. TIGER/Line
  state zip files are cached for faster repeated rebuilds.
- Added a dynamic geography Arrow report to check whether block and blockgroup
  helper datasets are compatible with the current blockgroup universe.

## ACS Formulas and Calculations

- Improved formula dependency ordering and validation for ACS-derived
  indicators, including formulas that depend on intermediate calculated fields.
- Corrected or clarified formulas for lead paint (`pctpre1960`), broadband
  access (`pctnobroadband`), unemployment (`pctunemployed`), health insurance
  (`pctnohealthinsurance`), disability, and detailed language indicators.
- Updated tract-to-blockgroup allocation for tract-only ACS indicators. The
  default tract weighting now uses 2020 Decennial blockgroup-to-tract
  population weights, with special handling for Connecticut ACS 2022+ planning
  region FIPS changes.
- Corrected supplemental demographic index formulas so
  `Demog.Index.Supp` and `Demog.Index.Supp.State` average the four available
  supplemental components where low life expectancy is missing.
- Converted ACS negative sentinel values (that EJScreen had been using)
  for `percapincome` to `NA` rather than treating them as real income values.
- Updated `pctunemployed` so blockgroups with a zero civilian labor-force
  denominator return `NA` in EJAM (unlike what EJScreen had been doing).
- Kept `pctnohealthinsurance` on the Census B27010 civilian
  noninstitutionalized population universe, accepting this as an intentional
  difference from the old EPA ACS 2022 table rather than mimicking legacy
  values.
- Retained `healthinsurance_universe` and other denominator fields in the
  staged blockgroup data where they are needed for weighted aggregation.

## EJScreen Export and Metadata

- Added `calc_ejscreen_export()` for creating an EJScreen-ready blockgroup
  export from EJAM pipeline outputs, since EJScreen uses different column names
  than EJAM and has other differences as well. The export uses EJScreen field names,
  percentile fields, map-bin fields (for color-coded maps), map popup text fields,
  and schema extras needed by the EJScreen FeatureServer-style dataset.
- Added EJScreen export schema validation and reference validation against the
  preserved EPA ACS 2022-based EJScreen export.
- Added an EPA `StatePct`-style EJScreen export that writes state raw scores
  and state percentiles into the same generic EPA field names used by EPA's
  archived state-percentile blockgroup export.
- Significantly updated `map_headernames` naming metadata so EJAM rnames,
  current EJScreen indicator/export names, old EJScreen API names, and
  schema-only fields are tracked more clearly.
- Represented EJScreen map-bin and popup-text fields as their own
  `map_headernames` rows, and removed several redundant legacy name and helper
  columns.
- Made `data-raw/map_headernames.csv` the authoritative source used to
  regenerate `map_headernames.rda`, rather than relying on the old .xlsx file.
- Expanded `map_headernames` and the generated `names_*` metadata so report
  average, percentile, and ratio columns cover the health, climate, critical
  services, language, age, poverty, and community-report groups needed for
  report rounding and ratio-to-average outputs.

## Documentation, Testing, and Maintenance

- Added and updated maintainer documentation for annual EJScreen dataset
  updates, staged pipeline runs, S3/local storage, validation summaries, and
  release preparation.
- Saved future options and plans for Arrow file versioning, cache location,
  manifests, S3/`ejamdata` storage, and related cleanup in
  `data-raw/pipeline_validation_notes/future_arrow_versioning_and_manifest_plan.md`.
- Added conservative maintainer helpers and a manual dry-run script for
  publishing refreshed Arrow datasets to the `ejamdata` release assets.
- Refreshed test fixtures and example output datasets (testoutput* files, etc.).
- Expanded unit testing coverage.
- Sped up Shiny/webapp tests by allowing the web app functionality suite to run
  in one app process and by using the installed package by default.
- Reduced the exported API surface by making many pipeline-stage helpers,
  developer utilities, and thin wrapper functions internal. Public workflows
  now center more clearly on higher-level entry points such as `ejamapp()`,
  `calc_ejscreen_dataset()`, and `calc_ejscreen_export()`.
- Cleaned up package-check issues, optional dependency handling, startup
  message suppression, generated documentation, and test artifacts.
- Made numerous improvements where `check()` had been reporting errors, warnings, or notes.


# EJAM 2.4.0 (May 2026)

## Updated Demographic Data from ACS

- A release tagged as v2.4.0 was a placeholder for a way to provide 2019-2023 ACS for the EJSCREEN demographics indicators (and lead paint indicator), in case those are useful.


## Additional Fixes Merged from the development Branch

- Enabled adding buffer distance around FIPS unit like a city (closes #139)
- Improved warning/handling if upload exceeds max points (closes #347)
- Disable "Start Analysis" when NAICS/SIC selections are cleared (closes #365)
- Fixed shapefile area assignment for no-block polygons (closes #340)
- Fixed radius warnings in FIPS/shapefile report headers (closes #368)
- Fixed downloadable report footer duplication on PDF barplot page (closes #324)
- Fixed shapefile-based report links (in excel) to point to the EJAM app (closes #336)
- Fixed polygon one-site report links to avoid broken EJAM API URLs (closes #360)
- Fixed interactive-table regression in report details table
- Improved popup handling for edge cases with empty FIPS geometries (with regression tests) (closes #267)
- Increased barplot height in the live app view report (400px -> 600px) (closes #160)
- Improved GitHub release-asset download handling so deployed web app sessions can pass a GitHub token through EJAM's `.arrow` dataset download checks.
- Treated `leaflet.extras` as a required dependency because the web app uses it directly.
- Fixed invalid registry-ID upload handling so the web app stops cleanly after showing the validation message.
- Stopped exporting incomplete draft Lorenz plotting helpers until those functions are ready for public use.


# EJAM 2.32.8.001 (May 2026)

Web app features:

- Added PDF-format Community Report download option in the web app! Printing out the html report did not really work because of the page breaks, but the new pdf report has page breaks that make sense so a printed report looks good. Heatmap color-coding in tables is also working in the pdf.

Other changes:

- Improved `ejamapi()` examples and error-checking, and had it use `url_ejamapi()`
- Significantly revamped webapp functionality testing (done by shinytest2) to be faster, robust, and only check for basic web app UI functionality (not using snapshots that change when very minor updates occur).
- Revised some of unit testing setup, like setup.R etc.
- Disabled most github actions workflows pending debugging/updates. Changed to `checkout@v4.3.0` not just `checkout@v4` in all gh action workflows
- Revised/updated instructions for github copilot
- Clarified “Plot Average Scores” barplot summary labels/ratio wording to match report semantics (`Average site analyzed`, `Average person at sites analyzed`) and reduce ambiguity. Closes #128.


# EJAM 2.32.8 (April 2026)

Released v2.32.8 initially on 4/13/2026

- Moved EJAM and ejamdata repositories and documentation website (and updated all URLs) by changing owner from "ejanalysis" to "Public-Environmental-Data-Partners"
- MACT, NAICS, SIC categories initially selected at launch of app now can be specified as parameters mact, naics, sic in `ejamapp()`, or as parameters default_mact, default_naics, default_sic in global_defaults_shiny.R, or in Advanced tab. Default SIC was added.
- MACT, NAICS, SIC validation improved in server. Fixed some edge cases related to invalid mact codes, too many points selected, etc. Removed obsolete naics_validation() function. See better `naics_is.valid()`.
- Server handling of specifying large numbers of points was improved.
- Server handling of capitalization of column names in uploaded registry id/programs made more flexible.
- Server prints more consistent info about selected categories of sites to console (and server log, depending on how app is hosted)
- Fixed `ejam2shapefile()` where it had problems if closely related filename had previously been used
- Added utility `get_ejscreen_facilities_nearby()` and helpers to use API to find/count NPL, TSDF, TRI, etc. near each point
- Added utility `distance_epa_api()` that calculates distance between two lat/lon points using the same method as the EPA API, which uses ArcGIS and gives slightly different distances than other functions in this package.
- Added utility `calc_formulas_from_varname()` that looks at `formulas_ejscreen_acs` and compiles the subset of formulas needed to calculate one or more final indicators by recursively getting formulas for the intermediate variables also.
- Added parameter to `ejamapp()`, so ejamapp(testing=TRUE) now works as shortcut for ejamapp(default_testing=TRUE)
- Added `ejamapi()`, simple wrapper for EJAM API to get HTML report on a site or get data.frame of results for multiple sites. Unit tests also added.
- Added utility `url_package()` based on deleted repo_from_desc(), to get current URL or owner/reponame for code repo, data repo, or documentation website.
- Renamed utility api_run() as `ejamapi_local()` to be consistent with `ejamapi()` and `url_ejamapi()`
- Documented utilities `grepn()` and `found_in_files()` (and also improved some internal/unexported utilities pkg_functions_* )

Updated the v2.32.8 release to include some additional fixes and cleanup, on 4/24/2026

- Resaved testoutput and various other datasets and updated or added remaining metadata about version number, and fixed acs_version metadata for `tables_ejscreen_acs`.
- Fixed bugs in utilities that help update dataset metadata, etc.
- Fixed issue in unit testing helper functions/setup, and some unit tests (e.g., function creating text for report header).
- Fixed `url_county_equityatlas()`
- Amended `latlon_from_address()`


# EJAM 2.32.7 (February 2026)

- Bug fixes: 

  - Fixed a bug where the community report in version 2.32.6.003 incorrectly showed results rounded to zero decimal places. The bug was in `fixcolnames()` and had been introduced 3 weeks earlier while a separate issue was being fixed.
  - Fixed a bug where some latitude or longitude values could get somewhat rounded off in the URL from `url_ejamapi()` linking to the API to get a single-site report, so a report would show a very slightly different point and population count, for example, for some sites, versus what was intended.
  - Fixed bug in hosted app where uploads and downloads sometimes failed.
  - Fixed various other/ misc small issues.
  
- Improved the Community Report, Multisite Report, Spreadsheet

  - Report footer was edited, and can be customized now via `ejam2report()`
  - Report Title was revised: FIPS place name shown in header, lat/lon coordinates shown in 1-site report header, 1-site vs multisite named differently, says "EJSCREEN"" not "EJAM" in header as new defaults.
  - Analysis Title (on reports) revised also
  - Report Footer was revised (new params in `ejam2report()` now define footer in community report, via new `generate_report_footer()` helper)
  - Multisite report is now rendered as html file automatically as soon as results are ready (and if analysis title is changed afterwards),
  so it will be available immediately if/when a user decides to download it. And spreadsheet download may be faster, as 
  the server now does not have to re-render report for use in spreadsheet.
  - Multisite report and spreadsheet download buttons now disabled until each is ready.
  - Spreadsheet file is now created automatically when results are done, so it will be available immediately if/when a user decides to download it. 
  - Client side user's timezone is now used by shiny app to use the correct date for report footer. Otherwise a report run late in the day 
  might incorrectly say it was created the next day if the app is running on a server in a timezone east of the user, for example. 
  
- Raised some limits on number of sites one can upload, map, analyze

  - Number of uploaded points
    - cap was 5,0000 (or 10,000 via advanced tab)
    - cap now 10,000 (or 35,000 via advanced tab) Now just omits 8111 Automotive Repair and Maintenance (58,132 sites) and a few overly broad groups like "Manufacturing"
  - Number of selected points based on NAICS, etc.
    - cap was 5,0000 (or 10,000 via advanced tab)
    - cap now 10,000 (or 35,000 via advanced tab)
  - Number of points it will map
    - cap was 5,0000 (or 15,000 via advanced tab)
    - no change
  - Number of polygons it will map
    - cap was 159 (or 254 via advanced tab)
    - no change e.g., TX has 254 counties, but no other state exceeds 159 counties
  - Number of sites you can analyze
    - cap was 10,000 (or 15,000 via advanced tab)
    - cap now 10,000 (or 35,000 via advanced tab)
  - Number of sites shown in table of all the sites one per row
    - cap was 1,000 (or 5,000 via advanced tab)
    - no change
  - Size of uploaded file
    - cap was 50 MB (or 350 MB via advanced tab)
    - no change

- Other changes:

  - Changed links in header at top right of the webpages, to link to "Share data feedback" and "Help improve the tool" forms just like CEJST has and EJSCREEN is adding. The "Contact Us" link to an email address was removed.
  - Updated text in the "About" tab, to refer to and link to EJSCREEN, and to refer to EJAM in terms of EJSCREEN.
  - Updated text in README
  - Updated text in the [Future Plans](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-future-plans.html) and other vignettes/articles.
  - Renamed `ejam2excel()` parameters (in.analysis_title changed to analysis_title) to be consistent with `ejam2report()` parameter, or to simplify (react.v1_summary_plot changed to report_plot).
  - `ejamapp()` now lets you specify the city/cities to analyze (to show as preselected upon launch), via default_cities_picked parameter
  - `ejamapp()` has new parameter aliases: "pts" is short for "sitepoints", "shp" is short for "shapefile", "analysis_title" or "default_analysis_title" will set analysis title in report header, and "report_title" or "default_report_title" will set overall title in topmost part of report header.
  - `url_ejscreentechdoc()` was added to easily get URL of EJSCREEN documentation pages and docs

# EJAM 2.32.6.003 (November 2025)

- Bug fixes:
  - Fixed bug where States could not be analyzed in the web app.
  - Fixed bug where size of circular buffer at each point on map in a report did not reflect actual radius.
  - Fixed limitation affecting API where a request to find all blockgroups in a city did not work.
  - Fixed bug where `ejamapp()` settings/parameters isPublic and default_show_advanced_settings were ignored and advanced tab was being shown even if isPublic=TRUE and default_show_advanced_settings=FALSE.
  - Fixed examples in documentation of all functions.
  - Fixed bug in `plot_barplot_ratios()` that could affect `ejam2barplot()`
  - Fixed bug in `popshare_p_lives_at_what_pct()`, which reports info in notes tab of excel download
  - Fixed bug in utility `EJAM:::find_in_files()`
  - Fixed bug affecting geocoding in `names2fips()` based on fips_place_from_placename() 
  - Fixed bug in `fixcolnames()` that was only renaming the first instance of any duplicated inputs
  - Fixed various smaller issues like edge cases or typos in comments or messages.
- Added (strong) recommendation that you obtain a Census API key, in the [guide to installing the package](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/installing.html). Also added warnings when envt var CENSUS_API_KEY not found before trying to use [tidycensus package](https://walker-data.com/tidycensus/) / [tidycensus on CRAN](https://cran.r-project.org/web/packages/tidycensus/index.html) or [tigris package](https://cran.r-project.org/web/packages/tigris/index.html) downloads of ACS Info or Census unit boundaries, e.g., in `shapes_from_fips()` and elsewhere.
- Specified R version 4.3 as the minimum required per the DESCRIPTION file. Although older versions like 4.1 may work for most of what EJAM does, installation can be complicated depending on the platform (windows, macos, ubuntu) since building from source and installing some of the dependencies that require compilation can create varying requirements. A future release might use something like the renv package to simplify installation. Deployment to Posit Connect Cloud handles dependencies well, but individual users may find installation tricky because of dependencies. Putting the package on the [R universe platform](https://ropensci.org/r-universe/) and maybe eventually [CRAN](https://cran.r-project.org) are other options.
- Removed dependency on a few packages rarely needed.
- Removed all files, functions, datasets related to old ejscreenapi app that relied on EPA API for EJSCREEN pre-2025, like ejscreenit__, ejscreenapi__, ejscreen_vs__, ejscreenREST__, testoutput___, etc.
- Stopped exporting several shapefile_from_XYZ helper functions since shapefile_from_any() can be used.

- Hosting:
  - Added Dockerfile used to deploy the shiny app to a server.
  - Added notes on hosting on Posit connect cloud
  - Revised article (vignette) on hosting, to add posit vs docker info, and updated files supporting deployment of shiny app to Posit Connect Cloud (manifest.json, etc.).
  - Fixed dependency issue where package [geojsonsf](https://github.com/SymbolixAU/geojsonsf) used in draft API code (plumber.R) had a typo so deployment to posit would fail due to not finding a package of that name.
  - Edited apparently problematic file data_names_all.R and may add back the _disable_autoload.R file
  - Added example of using api_run() (later renamed as `ejamapi_local()`) to locally run API draft in background 
  - Revised github actions; Added a github action workflow to run R CMD check, via `rcmdcheck::rcmdcheck()` to find various problems in package.
- Added article (vignette) about [speed -- how long it takes to analyze thousands of sites](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-speed.html)
- Improved `acs_bybg()` for creating new indicators based on Census Bureau ACS data
- Improved `popshare_p_lives_at_what_n()` for reporting how most of the residents are at a few key sites typically
- Added `sites_only()` helper; added `sites_from_input()` examples
- In `ejam2map()`, added a radius parameter
- Added `calc_pctile_columns()`, `calc_avg_columns()`, `calc_ratio_columns()` -- Added (or renamed to be consistent) these helper functions to make columns of averages, ratios to average, and percentiles (all of which can be used later to replace parts of `doaggregate()`). Old, now-removed function avg_from_raw_lookup() was renamed as `calc_avg_columns()`. New function `calc_pctile_columns()` is vectorized form of retained function `pctile_from_raw_lookup()`. `calc_ratio_columns()` is new. Removed/replaced the old, obsolete function calc_ratios_to_avg().
- Stopped exporting plot_boxplot_ratios() since 'ejam2boxplot_ratios()' and 'plot_boxplot_pctiles()' work better.


# EJAM 2.32.6.002 (October 2025)

This update does not add any web app features. 

Changes:

- Started rounding off the radius shown in the report header
- Fixed some small bugs in `ejam2report()`, `ejamit()`, `ejam2map()`, `ejam2tableviewer()`, `report_residents_within_xyz()`, and some helper functions related to report creation, etc. to support new API and R users, for handling sitenumber, missing shapefile, etc. For example, ejamit(fips=x) had a problem if x was a fips missing a needed leading zero.
- Fixed some obstacles to using the package and/or app locally from a working directory other than root of source pkg
- Fixed misc minor issues in reference documentation
- Deleted obsolete file and function report_community_download
- Changed github actions that run tests of ability to install the package on various R versions, operating systems, etc.


# EJAM 2.32.6.001 (October 2025)

This update does not add any web app features.

It mainly does the following:

- Fixes a couple of key issues related to installing and/or hosting
- Provides a new article about US Counties
- Provides a list of URLs of archived EPA webpages with EJSCREEN documentation
- Improves or adds code related to updating and maintaining this package
- Drafts code in progress that will support new features:
  - API
  - reports on user-provided indicators
  - counts of nearby user-provided points of interest

## Fixed

- Fixed some issues that were obstacles to installing the package and/or deploying to server
- Fixed code and tests so that when running more than 2,000 unit tests, zero tests fail now

## Changed or Added

- Added a list of URLs of archived EPA webpages documenting various aspects of EJSCREEN, in data-raw/EJSCREEN_archived_pages/EJSCREEN_archived_pages_and_docs.md (This may get moved later 
or could even be converted to a subset of a website)
- Added text to improve the articles on installing the package and updating datasets and others
- Added an article about US Counties
- `ejamit()` no longer will ask to confirm zero radius in shapefile case
- Drafted changes in `getpointsnearbyviaQuadTree()` that will enable reports counting nearby user-provided points of interest, etc.
- Drafted changes in `calc_ejam()` and related functions that will enable reports aggregating custom, user-provided indicators.
- Drafted changes to draft API code to provide more endpoints, start work on POST vs just GET, added api_run() (later renamed as `ejamapi_local()`) to run API in background locally while testing/in dev, etc.
- Drafted sites_from_input() helper function called sites_only(), added as prelude to allowing lat,lon or sitepoints or fips or shapefile as inputs to more ejam2__ functions
- Fixed code that can update the NAICS codes table.
- Removed obsolete article about EPA EJSCREEN API that was taken down in early 2025.
- Cleaned up, reformatted, or improved/ fixed code via lintr and in general, such as && or || instead of & or | within if().
- Improved documentation of `?blockgroupstats` dataset
- Added utilities supporting package development, like map_add_pts() in MAP_FUNCTIONS.R, `pause()`, bgid_from_blockid(), pkg_functions_preceding_lines(), pkg_sizes(), find_transitive_minR(), functions in getblocks_helpers.R, etc.
- Documented the dataset_documenter() utility


# EJAM 2.32.6 (September 2025)

## **WEB APP CHANGES**

### * Restored language related to "Environmental Justice"

-   Changed name of tool back to "Environmental Justice Analysis Multisite" tool (from "Environmental and Residential Population Analysis Multisite" tool, the name used in early 2025 through July 2025)
-   Restored some text: "EJ Indexes" now once again refers to what were called "Summary Indexes" early 2025 through July. "Supplementary EJ Indexes" is also restored.
-   Did not restore all old text, at least not yet: Other language related to "environmental justice" was edited in early 2025 at EPA in response to an Executive Order, but has not been changed back to its original language even in this non-EPA version of the package. For anyone interested, notes listing those changes were archived in a file saved as "EJAM/data-raw/0_generic_terms_notes.R".
-   Made "EJSCREEN" all-caps everywhere (not "EJScreen")
-   Edited descriptions of some language-related indicators (to be shorter and more consistent), changed "block group" to "blockgroup", etc.

### Summary Report and Tables of Sites: Header, Footer, and Links to 1-Site Reports

-   Report footer now shows exact version number ("2.32.6" not just "2.32"). Same in web app home page header. Fixed missing footer in some reports.
-   Tables of sites (web and downloaded excel) and Map popups (web and downloaded html) now have web links to various kinds of 1-site reports, for each site. These were gone, but now are restored and expanded. Links to 2 report types are included by default:

    - link to the EJSCREEN app (zoomed to that 1 site)
    - summary report on 1 site, as a *downloaded* html file (API-generated)
    - summary report on 1 site, as a *live* webpage (shiny-generated) (Not yet implemented)
    - Others reports can be shown via settings -- see table below.

### Website now at [ejanalysis.org](https://www.ejanalysis.org) (or [ejanalysis.com](https://www.ejanalysis.com))

-   [ejanalysis.org](https://www.ejanalysis.org) is an easy URL to remember, with info about -- and links to -- EJAM and EJSCREEN.
-   [ejanalysis.org/about](https://www.ejanalysis.org/about) has [a new emailing list you can join](https://www.ejanalysis.org/about)
-   [ejanalysis.org/ejamapp](https://www.ejanalysis.org/ejamapp) will go to a live version of the EJAM web app
-   [ejanalysis.org/ejscreenapp](https://www.ejanalysis.org/ejscreenapp) will go to a live version of the EJSCREEN web app
-   [ejanalysis.org/ejscreen](https://ejanalysis.org/ejscreen) has info on EJSCREEN
-   [ejanalysis.org/ejam](https://ejanalysis.org/ejam) has info on EJAM
-   [ejanalysis.org/status](https://ejanalysis.org/status) has info about the 2025 status and history of transition from EPA to non-EPA versions of EJSCREEN and EJAM
-   [ejanalysis.org/ejamdocs](https://www.ejanalysis.org/ejamdocs) directs you to the documentation:
    -   [What is EJAM?](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/whatis.html) is an overview of what EJAM can do.
    -   [Accessing the Web App](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/webapp.html) is about the web app.

### Web App Documentation

-   Improved the `About page`
-   Collected copies of old user guides to inform a new one that could be developed. [See User Guide examples](https://github.com/Public-Environmental-Data-Partners/EJAM/tree/main/data-raw/user-guides)

### Web App Customization

-   Added ability to configure web app (change settings), and added ability to pass inputs to the web app at launch. This allows the following:
    -   Anyone using the EJAM web app online can go to the app using a URL that encodes customized input settings, and therefore launches a somewhat customized app. This is because bookmarking in the app saves the state of inputs, which control more settings now. Not all settings are available this way, but many are. These features may evolve.
    -   Anyone using R/RStudio can now launch the web app locally with many more custom settings and inputs (providing sites as a parameter, using a custom default radius, overriding caps, etc.). See `ejamapp()` for examples.
    -   Anyone hosting a version of the EJAM web app can customize it, e.g., to use a different logo, different default radius, different options for how to select sites, etc.
-   Reorganized the "Advanced" settings tab, which now has more options and settings that can be changed. That tab is hidden by default in most cases because it is complicated, and some parts are experimental/untested.


## **NON-WEB-APP CHANGES (FOR USING EJAM IN R/RSTUDIO)**

### Shortcuts are provided via [ejanalysis.org](https://www.ejanalysis.org) (or [ejanalysis.com](https://www.ejanalysis.com))

-   [ejanalysis.org/repo](https://www.ejanalysis.org/repo) or [ejanalysis.org/ejamrepo](https://www.ejanalysis.org/ejamrepo) directs you to the GitHub page for the EJAM package open source software.
-   [GitHub issues now can be submitted here](https://github.com/Public-Environmental-Data-Partners/EJAM/issues)
-   [ejanalysis.org/docs](https://www.ejanalysis.org/docs) or [ejanalysis.org/ejamdocs](https://www.ejanalysis.org/ejamdocs) directs you to the documentation for the EJAM package, including technical reference docs (how to install and use the R package to work directly with the more powerful tools EJAM offers beyond the web app).

### Weblinks / URLs (API, reports, etc.)

-   Restored columns of weblinks in single-site reports - they had been missing since 1/2025. Restored to tables of sites (results_bysite table from `ejamit()`, `ejam2tableviewer()`, etc.) & map popups (in functions like `ejam2map()`)
-   The choice of which types of reports to link to is controlled by a "default_reports" setting in the global_defaults_package.R file.
-   Added several new functions that can provide these kinds of reports:

| header (column title) | text (of link) | function name | key parameters |
|---------------|--------------|-----------------|----------------------|
| EJAM Report | Report | `url_ejamapi()` | sitepoints (or lat,lon) or shapefile or fips |
| EJSCREEN Map | EJSCREEN | `url_ejscreenmap()` | sitepoints (or lat,lon) or shapefile or fips |
| EnviroMapper Report | EnviroMapper | `url_enviromapper()` | sitepoints (or lat,lon) or shapefile or fips |
| ECHO Report | ECHO | `url_echo_facility()` | regid |
| FRS Report | FRS | `url_frs_facility()` | regid |
| County Health Report | County | `url_county_health()` | fips |
| State Health Report | State | `url_state_health()` | fips |
| County Equity Atlas Report | County | `url_county_equityatlas()` | fips |
| State Equity Atlas Report | State | `url_state_equityatlas()` | fips |

-   `url_ejamapi()` provides URLs to use with EJAM-API to get an html summary report on 1 site at a time. Inputs to this function are like inputs to `ejamit()` but so far mostly limited to radius, sitepoints, fips, shapefile. This will enable the map popups and excel tables of sites to include links to single-site reports, for example. It is limited to blockgroup fips only, right now, and only single-site reports right now.
-   `url_ejscreenmap()` and other functions in table above were revised, cleaned up, and moved among .R files.
-   `url_enviromapper()` and `url_ejscreenmap()` can now accept a fips code and get the approx centroid of each block, blockgroup, tract, city, county, or state - that lets it craft a link to send you to EJSCREEN or EnviroMapper zoomed to one fips unit
-    `url_frs_facility()` and `url_echo_facility()` are the new names of functions giving links to EPA FRS and ECHO reports on regulated facilities.
-   `url_county_health()` and `url_state_health()` are new or renamed and provide links to reports that used to be called county health rankings
-   `url_county_equityatlas()` & `url_state_equityatlas()` make links to Equity Atlas reports


### Web app customization details

-   Added `ejamapp()` as the new name for what was `run_app()` -- This launches EJAM as a local shiny app, in RStudio.
-   Added ability to set many options and defaults as parameters passed to `ejamapp()`.
-   Added many examples to `ejamapp()` documentation showing how to change the defaults and options. You can now provide a set of points, fips, or polygons to preload at launch e.g., `ejamapp(sitepoints=testpoints_10, radius=5)`
-   Drafted a new article with technical details: [Defaults and Custom Settings for the Web App](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-app-settings.html)
-   Changed where the app title is stored. It is stored in the DESCRIPTION file as a field. (The app title also can be modified by editing `global_defaults_package.R` or by passing parameters to `ejamapp()`).
-   Changed how Advanced tab visibility is controlled ("default_can_show_advanced_settings" and "default_show_advanced_settings" set initial values of shiny inputs of the same names)
-   Fixed a bug where `isPublic` parameter in `ejamapp()` was being ignored.
-   Fixed a bug where threshold-related params in `ejamapp()` got ignored in latlon case.
-   Renamed many global_defaults\_ variables and shiny app input variables, and check in ejamapp() for special variables, so they are easier to use as parameters in `ejamapp()`. 
-   Renamed many global defaults (related to app title, logo, and version number, etc.), to be more clear and consistent, and moved several to `global_defaults_package.R`. So logos e.g. could be changed via `ejamapp(report_logo="www/EPA_logo_white_2.png", app_logo="www/EPA_logo_white_2.png")`, or report_logo="" to show no logo on reports.
  

### Added documentation

-   Simplified the [README](https://github.com/Public-Environmental-Data-Partners/EJAM/#readme)
-   Improved the [article on how to install the package](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/installing.html), but it does need some additional testing/fixes.
-   Renamed fields in the DESCRIPTION file, for VERSION and DATE info!
-   Redid sample report, etc. outputs in `testdata/examples_of_outputs` folder to reflect changes in version numbers shown in report footer and app header, etc.
-   Renamed various \*.R files and relocated some source code among those, to make some filenames more consistent.
-   Made some functions internal that until now had been exported, to simplify things for most R users.
-   Updated `{roxygen2}` help file docs and pkgdown documentation webpages
-   New function `url_github_preview()` makes it a bit easier to view rendered HTML reports that each package release or branch stores in the testdata/examples_of_outputs folder, to compare how they look in different versions. 
-   Spell checked / fixed some typos
-   Fixed some documentation

### Added or changed functions

-   `ejam2report()` now has a sitenumber parameter, to get a report on one site more easily
-   `ejam2map()` now has a sitenumber parameter, to map one site more easily
-   `ejam2report()` now downloads FIPS bounds if missing.
-   `ejam2map()` now downloads FIPS bounds if missing.
-    unit tests added for functions including ejam2map() and ejam2excel() and various other functions
-   `mapfast()` and some others now drop sites with empty geometry before trying to map, avoid an error
-   `popup_from_any()` and other map popup functions now have different parameters that can handle more columns of URLs/links of any type
-   `popup_from_any()` and other map popup functions now drop the geometry column from spatial data.frames to avoid including a mess in the popup
-   `ejam2histogram()` is now exported and has more flexible parameters for title, y axis label, variable names
-   `shape2geojson()` is a new helper function that tries to convert a spatial data.frame to text string geojson, the format needed by the 8/2025 version of the EJAM-API
-   `shapefile_from_any()` now can also recognize a vector of character strings that are geojson polygons, via helper shapefile_from_geojson_text(), the inverse of shape2geojson()
-   `testinput_fips_mix` is a new dataset with fips of each type: block, blockgroup, tract, city, county, state
-   `fips_county_from_latlon()` and `fips_state_from_latlon()` are new internal functions - for each point, they identify the county or state it is in
-   `fips2countyfips()` reports what US County contains each fips-based Census unit, such as the Counties in which some blockgroups are located.
-   `fips2name()` now handles block fips instead of warning
-   `sites_from_input()` new internal function that helps other functions flexibly accept sites in various formats of input parameters: 
      - lat= and lon= vectors of point coordinates, or
      - sitepoints= a data.frame with columns called lat and lon, or
      - shapefile= a spatial data.frame of polygons, or 
      - fips= a vector of census FIPS code
-   `regids_valid()` is a new internal function
-   `url_linkify()` improved and made internal
-   `urls_from_keylists()` utility drafted to help assemble url-encoded API query from lists of key=value arguments, etc.
-   `url_ejamapi2arglist()` is a new helper that just parses url-encoded API requests back to arguments like ejamit() would need




# EJAM v2.32.5 (July 2025)

## Web App

-   **Cities, Counties, States:** Census units like States, Counties, and Cities/Towns/CDPs can be selected from a menu or searched by typing part of the name. Clicking "Done" will check online for the boundaries of those places, at which point the "Start Analysis" button will be enabled. Then clicking the "Start Analysis" button analyzes the sites for which bounds were found.
-   **Area in square miles**: The app now gets or calculates the area of each site more consistently and efficiently. (The function `ejamit()` has new params related to how `area_sqmi()` now can get square mileage info from `?blockgroupstats` table without needing to download boundaries. There are new parameters called `download_fips_bounds_ok`, `download_noncity_fips_bounds`, and `includewater`. The new params are also driven by two new defaults in `global_defaults_shiny.R` The old parameter default_download_fips_bounds_to_calc_areas is no longer a param in `ejamit()`).
-   **County population counts:** Fixed county population counts obtained from and shown in some maps (via fixes in a function used by `shapes_from_fips()` so, e.g., if using `mapfast()`, `mapfast(shapes_from_fips(testinput_fips_counties))` now shows the right numbers).
-   **Summary Indexes (aka EJ Indexes)** had some incorrect numbers, so this release has replaced `?bgej` dataset with correct numbers. (Correct numbers were drawn from the [internet archive version](https://web.archive.org/web/20250203215307/https://gaftp.epa.gov/ejscreen/2024/2.32_August_UseMe/EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv.zip) that was a copy of the [datasets EPA had posted August 2024](https://gaftp.epa.gov/EJScreen/2024/2.32_August_UseMe/EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv.zip)).
-   **Sort order of FIPS Census units:** Sort order of output FIPS codes and polygons should now always be the same as the order of the inputs (sorted like they were in an uploaded shapefile, uploaded FIPS, or FIPS selected from the dropdown list).
-   **Medians in barplots:** DRAFT feature/ work in progress -- interactive barplots of indicators will be able to show median not just mean (via the `ejam2barplot_indicators()` function).

## RStudio users only

### Documentation updates

-   [Installation instructions in vignette/article](../articles/installing.html) were redone.
-   Articles (aka vignettes) were renamed (titles and file names).
-   [README](https://github.com/Public-Environmental-Data-Partners/EJAM/#readme) mentions <https://www.ejanalysis.com> now. `?blockgroupstats` documentation was improved.
-   `acs_bybg()` documentation now has notes on the key ACS demographic data tables most relevant to EJSCREEN.
-   Edited files `DESCRIPTION`, `CITATION.cff` (new), `CITATION`, `LICENSE` (new), `LICENSE.md`, etc.

### Functions added or improved

-   Mix of fips types allowed:
    -   `shapes_from_fips()` now accepts a mix of city and noncity fips (state, county, tract, blockgroup), so you can get a shapefile where some polygons are cities and others are counties, etc. Previously that was not possible and caused an error. See parameter `allow_multiple_fips_types` in `shapes_from_fips()`.
    -   `getblocksnearby_from_fips()` now accepts a mix of city and noncity fips (state, county, tract, blockgroup), so you can get a shapefile where some polygons are cities and others are counties, etc. Previously that was not possible and caused an error.
-   `fips2name()` now also provides text name for a tract
-   `mapfast()` for a single point now zooms out enough to see the whole radius (e.g., `mapfast(testpoints_10[1,], radius = 10)`)
-   `mapfastej_counties()` has improved color-coded maps of counties.
-   `convert_units()` now can recognize more abbreviations like "mi\^2" via updated `fixnames_aliases()`, and got some bug fixes.
-   `fips_bg_from_latlon()` drafted as unexported function that identifies which blockgroup each point is inside.

### Functions fixed or modified

-   `ejamit()` and `shapes_from_fips()` (and related helper functions) have more consistent, useful outputs:
    -   *Sorting*: The outputs now consistently preserve sort order of the input (points, fips, or polygons). This had not been the case for `shapes_from_fips()` outputs, and the table `results_bysite` from `ejamit()` or `doaggregate()` was preserving sort order only for the latlon case but not necessarily the fips or shapes cases.
    -   *Invalid sites*: The outputs of `shapes_from_fips()` (and related helper functions) will have a row for each valid or invalid input site (it will no longer omit output rows for invalid fips and when boundaries could not be obtained for valid fips) -- The number of rows in a shapefile output will be the same as then length of the input fips vector. The output table `results_bysite` from `ejamit()` also has a row for each valid or invalid input site. That table in the output of `doaggregate()` in contrast does *not* have a row for any site lacking blocks, since the input is from getblock_xyz functions (`getblocksnearby()`, `getblocksnearby_from_fips()`, `get_blockpoints_in_shape()`), which don't provide those sites.
    -   *Columns* from `shapes_from_fips()` and related helpers: The output columns are ordered in a more useful way and are more consistent across functions. The output also consistently tries to add population, area in square miles, name of census unit, state abbreviation, etc., via new helpers like `shapefile_addcols()`
-   `getblocksnearby()` and related functions (`getblocksnearby_from_fips()`, `get_blockpoints_in_shape()`, etc.) also have more consistent outputs:
    -   *Unique ID in FIPS case*: The `ejam_uniq_id` column in the outputs of these functions will be based on 1 through the number of sites in the inputs (with multiple rows per site as needed to include all the blocks). Previously, FIPS codes had been used as the `ejam_uniq_id` sometimes (and still are in the outputs of functions like `ejamit()` where the output has a table with one row per site).
    -   *Sorting*: The output sites are now sorted like the input sites (points, fips, or polygons), while there are still usually many rows (blocks) per site. It had been sorted primarily by blockid, previously.
    -   **Invalid sites:** The outputs of all the getblock... functions will be consistent -- They all provide a sites2blocks data.table output (like `?testoutput_getblocksnearby_10pts_1miles`) that does not include any sites that have zero blocks. The `ejam_uniq_id` will still correspond to the input vector, so if an invalid and valid site were input in that order, 2 would be the only `ejam_uniq_id` in the sites2blocks table. The FIPS-based functions, though, like `getblocksnearby_from_fips()`, when returning a spatial data.frame, will include all the sites in the output, even if they have no blocks, so that the number of rows in the output shapefile will match the number of sites in the input fips vector.
-   `shapes_from_fips()` (and related) have new `year` parameter, passed to [tigris::places()], defaulting to the 2024 boundaries polygons of cities/towns.
-   testoutput_xyz .xlsx and .html files and dataset R objects like `?testoutput_ejamit_100pts_1miles` have been updated to reflect the new `?bgej` dataset, typo fixes, and other edits.
-   Some testinput objects like testinput_fips_counties are now vectors per is.vector(), and no longer have metadata stored as attributes like date_saved_in_package, etc. Adding that info via `metadata_add()` was making is.vector() FALSE and interfered with some functions that expect the input to be a vector, like `shapes_from_fips()`. Also, `testinput_xtrac` was removed.
-   `doaggregate()` and `ejamit()` now report 0 for `results_bysite$blockcount_near_site` and `results_bysite$bgcount_near_site` if there are none, and total counts are correct.
-   `getblocksnearby()` based on `getblocksnearbyviaQuadTree()` will no longer include, in its output, the lat lon columns from the input table of sitepoints. That was unintentional and potentially confusing and wasted space.
-   `plotblocksnearby()` rewritten to fix/improve map popups, etc., and a parameter was dropped

### Package development/ technical

-   Many unit tests added, especially for `doaggregate()` and `getblocksnearby_from_fips()` and related.
-   `test_ejam()` is what used to be called `test_interactively()` -- it was improved and renamed and moved to the R folder as an unexported internal function loaded as part of the package. Also, a new parameter y_skipbasic is used instead of y_basic.
-   `test_coverage_check()` utility was improved (but somewhat work in progress), just as a way to for package maintainers/contributors to look at which functions might need unit tests written.
-   Utility functions related to package development were renamed, e.g., in utils_PACKAGE_dev.R
-   `linesofcode2()` utility was improved, just as a way for package maintainers/contributors to look at which files have most of the lines of code, are mostly comments, etc.
-   `table_xls_format_api()` is what used to be called table_xls_formatting_api() (but is not used unless the ejscreenapi module or server is working).
-   fixed inconsistent use of parameter `in_shiny` versus `inshiny`, to always call it `in_shiny`
-   removed functions and text related to pins board (obsolete)
-   renamed map_headernames spreadsheet file to reflect a new version (`EJAM/data-raw/map_headernames_2.32.5.xlsx`), made edits/fixes (spelling of CEJST, e.g.), and updated the data object `?map_headernames`.
-   rebuilt favicons per updates in {pkgdown}
-   Edited DESCRIPTION file to specify minimum versions for most packages in Imports, and a newer version of R. Almost all of these just refer to the latest version on CRAN as of this release, even though several were not strictly necessary for the functions to work correctly.

# EJAM v2.32.4 (June 2025)

Note the URLs, emails, and notes about repository locations/owners were edited to reflect this forked non-EPA version of the EJAM package being 
located initially at ejanalysis/EJAM, later moved to Public-Environmental-Data-Partners/EJAM, 
so the package called the v2.32.4 
release on ejanalysis/EJAM (later moved to Public-Environmental-Data-Partners/EJAM) is slightly different than the version called the v2.32.4 release that was 
released on USEPA/EJAM-open.

## Web app

-   Fixed logo in "About" tab, app header, and report header, in app_ui, generate_html_header(), global_defaults_xyz, etc., and updated testoutput files related to `ejam2report()` and `ejam2excel()`
-   corrected spelling in app and documentation
-   added better examples of params one can pass via `run_app()`

## RStudio users only

-   New summary table and plot are available via `ejam2areafeatures()` and `ejam2barplot_areafeatures()`. Changes in `ejamit()` provide information about what fraction of residents have certain features or types of areas where they live, such as schools, hospitals, Tribal areas, nonattainment areas, CEJST areas, etc. This is done via many changes to `batch.summarize()`.
-   added better examples of params one can pass via `run_app()`
-   documented `get_global_defaults_or_user_options()` and `global_or_param()`
-   fixed `ejam2means()`
-   `ejam2report()` gets new params, and in `build_community_report()` added report_title = NULL, logo_path = NULL, logo_html = NULL.
-   `plot_barplot_ratios()` gets new ylab and caption params
-   added warning in `url_county_health()` if default year seems outdated
-   unexported draft `read_and_clean_points()`
-   unexported draft `ejam2quantiles()`
-   removed reference to obsolete testids_registry_id, replaced by `?testinput_regid`

## Technical / internal changes:

-   enabled testing of web app functionality from the test_interactively() utility (which has more recently been renamed `test_ejam()` and put in R folder as an unexported internal function loaded as part of the package) or via test_local(), etc., not just from a github action. (See /tests/setup.R which now has a copy of what is also in app-functionality.R)
-   drafted revisions to ui and server to try to allow for more `run_app()` params or advanced tab or global_defaults_xyz to alter default method of upload vs dropdown, e.g., output ss_choose_method_ui, default_ss_choose_method, default_upload_dropdown. This included revising server and ui to use just `EJAM:::global_or_param()` not `golem::get_golem_options()`, so that non-shiny global defaults can work (e.g., logo path as `global_defaults_package$.community_report_logo_path`) even outside shiny when global_defaults_package has happened via onattach but global_defaults_shiny etc. has not happened.
-   changed `.onAttach()` to do source(global_defaults_package) with local = FALSE not TRUE, but this might need to be revisited -- note both local = F and local = T are used in `.onAttach()` versus `get_global_defaults_or_user_options()`
-   in server, `ejam2excel()` now figures out value of radius_or_buffer_description, `ejam2excel()` gets new parameters table_xls_from_ejam() uses improved buffer_desc_from_sitetype() and now uses `ejam2report()` to add a report in one tab.
-   reorganized server code by moving v1_demog_table() and v1_envt_table to long report section of server file
-   cleaned up server code (eg, remove obsolete input\$disconnect, remove obsolete community_download() and report_community_download(), and remove repetitive `ejam2repor()`, remove old EJSCREEN Batch Tool tab, used session = session as param in server calls to updateXYZINPUT, etc.)
-   allow shiny.testmode to be TRUE even if not set in options
-   used silent=TRUE in more cases of `try()`
-   added validate("problem with `map_shapes_leaflet()` function")
-   added validate(need(data_processed(), 'Please run an analysis to see results.'))

# EJAM v2.32.3 (May 2025)

## Summary report and related improvements

-   Added a long list of additional indicators in the summary report (in a subtable) and in outputs of `ejamit()`, etc. New indicators include counts of features (Superfund sites, schools, etc.), asthma and cancer rates, overlaps with certain types of areas (Tribal, C JEST disadv., air nonattainment areas, etc.), flood risk, % with health insurance, more age groups (% under 18), and numerous other indicators. You can see the expanded report via `ejam2report()` or at `system.file("testdata/examples_of_output/testoutput_ejam2report_100pts_1miles.html", package = "EJAM")`
-   Area in square miles (area_sqmi column) added to results, with calculation of size of each location (polygon or FIPS unit or circle around a point)
-   More/better info on number of sites or site ID and lat/lon, now in header
-   Enabled customization of summary table (for R users) to show fewer or new additional indicators (as long as they are in the outputs of `doaggregate()` and `ejamit()` or at least are in the inputs to `ejam2report()` etc.). This is done via the `extratable_list_of_sections` parameter in `ejam2report()`, in `build_community_report()`, in the community_report_template.Rmd, and in global parameter `default_extratable_list_of_sections`. It may later be enabled as modifiable in the advanced tab.
-   Easier to set which logo to show on summary report (EPA or EJAM or other logo), in global settings

## Other web app improvements

-   More types of shapefiles can be uploaded in the web app -- json, geojson, kml, zip (of gdb or other), and shp.
-   Census units like States, Counties, and Cities/Towns/CDPs can now be selected from a menu or searched by typing part of the name, in a shiny module called fipspicker, and the feature is enabled/disabled via global settings `use_fipspicker` and `default_choices_for_type_of_site_category`. It works but current does not check or alert users if boundaries are not available, until after the Start Analysis button is clicked.
-   Simpler UI for "More info" button about file types and formats allowed in upload.
-   Preview maps can show FIPS now, along with shapefile polygons, or points
-   `ejam2report()` and `ejam2map()` and `mapfast()` now better able to create maps of polygon data, FIPS, one site vs all sites, etc.
-   progress bar added for doaggregate() in cases of fips and latlon

## RStudio user-related or internal improvements

-   Clarified/explained 2025 status of API and urls in CONTRIBUTING and README, etc.
-   Extensive additions of and improvements in articles/vignettes, including documentation of how to maintain repo, package, and datasets. Articles/vignettes avoid hardcoded repo urls, and use relative links within pkgdown site... helper function repo_from_desc() added -- but later renamed to url_package() -- avoids hardcoded repo url; download_latest_arrow_data avoids hardcoded repo url; links to testdata files on webapp UI avoid hardcoded repo url; simpler [What is EJAM](../articles/whatis.html) doc.
-   `ejamit()` in interactive mode (RStudio) now lets you select any type of file to upload if no sites specified by parameters
-   Many options or starting values or settings for the shiny app (and in general) can now be set as parameters passed to the `run_app()` function, which overrides the defaults. extensive changes to global defaults vs user parameters allowed: replaced global.R; files renamed, put in 1 folder, etc. System for using user parameters passed to `run_app()`, global defaults otherwise, many can be changed in advanced tab; some may be bookmarkable. The default values are now set for the shiny app and in general in files called `global_defaults_package.R`, `global_defaults_shiny_public.R`, and `global_defaults_shiny.R` (rather than in the old files global.R or manage-public-private.R).
-   `acs_bybg()` examples added, on how to obtain and analyze new/custom indicators from the American Community Survey (ACS) data
-   `testdata()` function improved, showing you examples of files that be used as inputs to `ejamit()`. `testdata()` files and data objects cleaned up/renamed consistently and new ones added for fips types, naics, sic, mact, etc.
-   refactored names of plot functions made more consistent to use "plot" singular and "ratios" plural, as in `ejam2boxplot_ratios()`, `boxplot_ratios()`, etc.
-   documentation fixed in some functions (e.g., `ejam2map()`)
-   large datasets managed via `dataload_dynamic()`, `download_latest_arrow_data()` and other new arrow-related functions and no longer on pins board or aws at all. arrow datasets faster format used most places, other changes to handling downloads etc.
-   `shape_from_fips()` checks if census API key available and tidycensus pkg now imported, uses alt method (arcgis services) to get boundaries if necessary.
-   Continued towards refactoring/consolidating code in server vs in functions, related to creating summary report as HTML vs for download from shiny app vs from `ejam2report()`, in helper functions such as `build_community_report()`, `report_residents_within_xyz()`, renamed generate_demog_header to generate_env_demog_header, etc.
-   server uses `ejamit()` for SHP and latlon, and cleanup
-   server uses `ejam2excel()` now (which then relies on `table_xls_format()`)
-   server uses `ejam2report()` now, not obsolete report_community_download() etc.
-   server uses `shapefile_from_any()` now
-   server: removed use of data_summarized reactive everywhere, use data_processed\$...
-   2 new params `doaggregate()` has, to `ejamit()`, for calctype_maxbg and minbg
-   bug fixes such as in `ejamit()` for wtdmeancols param, `ejamit_compare_distances()`, `shapes_from_fips()`, `plot_ridgeline_ratios()`, `map_google()`, in `mapfast()` for tracts vs blockgroups, many others
-   unit tests added and others updated/fixed
-   misc helpers/utility added/updated/documented
-   renamed .xlsx file of map_headernames info to reflect a new version and made edits/fixes
-   DESCRIPTION file now has new field ejam_data_repo
-   updated workflow action to use latest version of github-pages-deploy-action

# EJAM v2.32.2 (February 2025)

-   Revised all language based on executive orders, to refer to environmental and residential population data analysis, rather than EJ / EJSCREEN / etc.
-   Revised web links based on EJSCREEN website being offline
-   Some edits made considering github repositories and gh pages may change location or go offline
-   Updated FRS datasets, pulled on 2/12/25
-   Remove screenshots from user guide document

# EJAM v2.32.1-EJAM (February 2025)

## Bug Fixes

-   Fixed metadata warning shown during loading of arrow datasets
-   Fixed typos in languages spoken indicators labels
-   Improved labeling and legibility of barplot of ratios used in reports and downloads
-   Fixed caps to \# of points selected, analyzed

## Enhancements

-   Expanded tables of indicators shown in community report
-   Languages spoken at home, health, community, age
-   Added ratio columns to community report as advanced setting and heatmap highlighting optional
-   Incorporated `shinytest2` tests for app-based functionality testing
-   Implemented mapping for points in `ejam2excel()`

## Experimental enhancements

-   Added draft plumber API for `ejam2excel()`
-   Added widget to advanced settings
-   proxistat() helps build proximity indicator
-   Zipcodes vignette

## Other

-   Refactored community report functions, `app_server.R` script

# EJAM v2.32-EJAM (January 2025)

## New Features + Improvements

-   Enabled automatic download of latest arrow data from ejamdata repo
-   Incorporated public-internal toggles to hide specific UI elements not yet applicable to the public version of EJAM
-   Made improvements to maps of polygons
-   Added shapefile upload instructions

## Bug Fixes and Enhancements

-   Added `leaflet.extras2` dependency to Imports, instead of Suggests, which is necessary for new installations

# EJAM v2.32.0

-   The EJAM R package is available as an open source resource you can
    -   clone from the [EJAM-open github repository](https://github.com/USEPA/EJAM-open) or
    -   install using the [installation instructions](../articles/installing.html)
