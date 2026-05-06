# Changelog

## EJAM 2.32.8.001 (May 2026)

Web app features:

- Added PDF-format Community Report download option in the web app!
  Printing out the html report did not really work because of the page
  breaks, but the new pdf report has page breaks that make sense so a
  printed report looks good. Heatmap color-coding in tables is also
  working in the pdf.

Other changes:

- Improved
  [`ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi.md)
  examples and error-checking, and had it use
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
- Significantly revamped webapp functionality testing (done by
  shinytest2) to be faster, robust, and only check for basic web app UI
  functionality (not using snapshots that change when very minor updates
  occur).
- Revised some of unit testing setup, like setup.R etc.
- Disabled most github actions workflows pending debugging/updates.
  Changed to `checkout@v4.3.0` not just `checkout@v4` in all gh action
  workflows
- Revised/updated instructions for github copilot

## EJAM 2.32.8 (April 2026)

Released v2.32.8 initially on 4/13/2026

- Moved EJAM and ejamdata repositories and documentation website (and
  updated all URLs) by changing owner from “ejanalysis” to
  “Public-Environmental-Data-Partners”
- MACT, NAICS, SIC categories initially selected at launch of app now
  can be specified as parameters mact, naics, sic in
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md),
  or as parameters default_mact, default_naics, default_sic in
  global_defaults_shiny.R, or in Advanced tab. Default SIC was added.
- MACT, NAICS, SIC validation improved in server. Fixed some edge cases
  related to invalid mact codes, too many points selected, etc. Removed
  obsolete naics_validation() function. See better
  [`naics_is.valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_is.valid.md).
- Server handling of specifying large numbers of points was improved.
- Server handling of capitalization of column names in uploaded registry
  id/programs made more flexible.
- Server prints more consistent info about selected categories of sites
  to console (and server log, depending on how app is hosted)
- Fixed
  [`ejam2shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2shapefile.md)
  where it had problems if closely related filename had previously been
  used
- Added utility
  [`get_ejscreen_facilities_nearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_ejscreen_facilities_nearby.md)
  and helpers to use API to find/count NPL, TSDF, TRI, etc. near each
  point
- Added utility
  [`distance_epa_api()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_epa_api.md)
  that calculates distance between two lat/lon points using the same
  method as the EPA API, which uses ArcGIS and gives slightly different
  distances than other functions in this package.
- Added utility
  [`calc_formulas_from_varname()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_formulas_from_varname.md)
  that looks at `formulas_ejscreen_acs` and compiles the subset of
  formulas needed to calculate one or more final indicators by
  recursively getting formulas for the intermediate variables also.
- Added parameter to
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md),
  so ejamapp(testing=TRUE) now works as shortcut for
  ejamapp(default_testing=TRUE)
- Added
  [`ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi.md),
  simple wrapper for EJAM API to get HTML report on a site or get
  data.frame of results for multiple sites. Unit tests also added.
- Added utility
  [`url_package()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_package.md)
  based on deleted repo_from_desc(), to get current URL or
  owner/reponame for code repo, data repo, or documentation website.
- Renamed utility api_run() as
  [`ejamapi_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi_local.md)
  to be consistent with
  [`ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi.md)
  and
  [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
- Documented utilities
  [`grepn()`](https://public-environmental-data-partners.github.io/EJAM/reference/grepn.md)
  and
  [`found_in_files()`](https://public-environmental-data-partners.github.io/EJAM/reference/found_in_files.md)
  (and also improved some internal/unexported utilities
  pkg_functions\_\* )

Updated the v2.32.8 release to include some additional fixes and
cleanup, on 4/24/2026

- Resaved testoutput and various other datasets and updated or added
  remaining metadata about version number, and fixed acs_version
  metadata for `tables_ejscreen_acs`.
- Fixed bugs in utilities that help update dataset metadata, etc.
- Fixed issue in unit testing helper functions/setup, and some unit
  tests (e.g., function creating text for report header).
- Fixed
  [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md)
- Amended
  [`latlon_from_address()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_address.md)

## EJAM 2.32.7 (February 2026)

- Bug fixes:

  - Fixed a bug where the community report in version 2.32.6.003
    incorrectly showed results rounded to zero decimal places. The bug
    was in
    [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
    and had been introduced 3 weeks earlier while a separate issue was
    being fixed.
  - Fixed a bug where some latitude or longitude values could get
    somewhat rounded off in the URL from
    [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
    linking to the API to get a single-site report, so a report would
    show a very slightly different point and population count, for
    example, for some sites, versus what was intended.
  - Fixed bug in hosted app where uploads and downloads sometimes
    failed.
  - Fixed various other/ misc small issues.

- Improved the Community Report, Multisite Report, Spreadsheet

  - Report footer was edited, and can be customized now via
    [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  - Report Title was revised: FIPS place name shown in header, lat/lon
    coordinates shown in 1-site report header, 1-site vs multisite named
    differently, says “EJSCREEN”” not “EJAM” in header as new defaults.
  - Analysis Title (on reports) revised also
  - Report Footer was revised (new params in
    [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
    now define footer in community report, via new
    [`generate_report_footer()`](https://public-environmental-data-partners.github.io/EJAM/reference/generate_report_footer.md)
    helper)
  - Multisite report is now rendered as html file automatically as soon
    as results are ready (and if analysis title is changed afterwards),
    so it will be available immediately if/when a user decides to
    download it. And spreadsheet download may be faster, as the server
    now does not have to re-render report for use in spreadsheet.
  - Multisite report and spreadsheet download buttons now disabled until
    each is ready.
  - Spreadsheet file is now created automatically when results are done,
    so it will be available immmediately if/when a user decides to
    download it.
  - Client side user’s timezone is now used by shiny app to use the
    correct date for report footer. Otherwise a report run late in the
    day might incorrectly say it was created the next day if the app is
    running on a server in a timezone east of the user, for example.

- Raised some limits on number of sites one can upload, map, analyze

  - Number of uploaded points
    - cap was 5,0000 (or 10,000 via advanced tab)
    - cap now 10,000 (or 35,000 via advanced tab) Now just omits 8111
      Automotive Repair and Maintenance (58,132 sites) and a few overly
      broad groups like “Manufacturing”
  - Number of selected points based on NAICS, etc.
    - cap was 5,0000 (or 10,000 via advanced tab)
    - cap now 10,000 (or 35,000 via advanced tab)
  - Number of points it will map
    - cap was 5,0000 (or 15,000 via advanced tab)
    - no change
  - Number of polygons it will map
    - cap was 159 (or 254 via advanced tab)
    - no change e.g., TX has 254 counties, but no other state exceeds
      159 counties
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

  - Changed links in header at top right of the webpages, to link to
    “Share data feedback” and “Help improve the tool” forms just like
    CEJST has and EJSCREEN is adding. The “Contact Us” link to an email
    address was removed.
  - Updated text in the “About” tab, to refer to and link to EJSCREEN,
    and to refer to EJAM in terms of EJSCREEN.
  - Updated text in README
  - Updated text in the [Future
    Plans](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-future-plans.html)
    and other vignettes/articles.
  - Renamed
    [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
    parameters (in.analysis_title changed to analysis_title) to be
    consistent with
    [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
    parameter, or to simplify (react.v1_summary_plot changed to
    report_plot).
  - [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
    now lets you specify the city/cities to analyze (to show as
    preselected upon launch), via default_cities_picked parameter
  - [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
    has new parameter aliases: “pts” is short for “sitepoints”, “shp” is
    short for “shapefile”, “analysis_title” or “default_analysis_title”
    will set analysis title in report header, and “report_title” or
    “default_report_title” will set overall title in topmost part of
    report header.
  - [`url_ejscreentechdoc()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreentechdoc.md)
    was added to easily get URL of EJSCREEN documentation pages and docs

## EJAM 2.32.6.003 (November 2025)

- Bug fixes:

  - Fixed bug where States could not be analyzed in the web app.
  - Fixed bug where size of circular buffer at each point on map in a
    report did not reflect actual radius.
  - Fixed limitation affecting API where a request to find all
    blockgroups in a city did not work.
  - Fixed bug where
    [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
    settings/parameters isPublic and default_show_advanced_settings were
    ignored and advanced tab was being shown even if isPublic=TRUE and
    default_show_advanced_settings=FALSE.
  - Fixed examples in documentation of all functions.
  - Fixed bug in
    [`plot_barplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios.md)
    that could affect
    [`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
  - Fixed bug in
    [`popshare_p_lives_at_what_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_p_lives_at_what_pct.md),
    which reports info in notes tab of excel download
  - Fixed bug in utility `EJAM:::find_in_files()`
  - Fixed bug affecting geocoding in
    [`names2fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/name2fips.md)
    based on fips_place_from_placename()
  - Fixed bug in
    [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
    that was only renaming the first instance of any duplicated inputs
  - Fixed various smaller issues like edge cases or typos in comments or
    messages.

- Added (strong) recommendation that you obtain a Census API key, in the
  [guide to installing the
  package](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/installing.html).
  Also added warnings when envt var CENSUS_API_KEY not found before
  trying to use [tidycensus
  package](https://walker-data.com/tidycensus/) / [tidycensus on
  CRAN](https://cran.r-project.org/web/packages/tidycensus/index.html)
  or [tigris
  package](https://cran.r-project.org/web/packages/tigris/index.html)
  downloads of ACS Info or Census unit boundaries, e.g., in
  [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
  and elsewhere.

- Specified R version 4.3 as the minimum required per the DESCRIPTION
  file. Although older versions like 4.1 may work for most of what EJAM
  does, installation can be complicated depending on the platform
  (windows, macos, ubuntu) since building from source and installing
  some of the dependencies that require compilation can create varying
  requirements. A future release might use something like the renv
  package to simplify installation. Deployment to Posit Connect Cloud
  handles dependencies well, but individual users may find installation
  tricky because of dependencies. Putting the package on the [R universe
  platform](https://ropensci.org/r-universe/) and maybe eventually
  [CRAN](https://cran.r-project.org) are other options.

- Removed dependency on a few packages rarely needed.

- Removed all files, functions, datasets related to old ejscreenapi app
  that relied on EPA API for EJSCREEN pre-2025, like ejscreenit\_*,
  ejscreenapi**, ejscreen_vs**, ejscreenREST**, testoutput***, etc.

- Stopped exporting several shapefile_from_XYZ helper functions since
  shapefile_from_any() can be used.

- Hosting:

  - Added Dockerfile used to deploy the shiny app to a server.
  - Added notes on hosting on Posit connect cloud
  - Revised article (vignette) on hosting, to add posit vs docker info,
    and updated files supporting deployment of shiny app to Posit
    Connect Cloud (manifest.json, etc.).
  - Fixed dependency issue where package
    [geojsonsf](https://github.com/SymbolixAU/geojsonsf) used in draft
    API code (plumber.R) had a typo so deployment to posit would fail
    due to not finding a package of that name.
  - Edited apparently problematic file data_names_all.R and may add back
    the \_disable_autoload.R file
  - Added example of using api_run() (later renamed as
    [`ejamapi_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi_local.md))
    to locally run API draft in background
  - Revised github actions; Added a github action workflow to run R CMD
    check, via
    [`rcmdcheck::rcmdcheck()`](http://r-lib.github.io/rcmdcheck/reference/rcmdcheck.md)
    to find various problems in package.

- Added article (vignette) about [speed – how long it takes to analyze
  thousands of
  sites](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-speed.html)

- Improved
  [`acs_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bybg.md)
  for creating new indicators based on Census Bureau ACS data

- Improved
  [`popshare_p_lives_at_what_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_p_lives_at_what_n.md)
  for reporting how most of the residents are at a few key sites
  typically

- Added `sites_only()` helper; added
  [`sites_from_input()`](https://public-environmental-data-partners.github.io/EJAM/reference/sites_from_input.md)
  examples

- In
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md),
  added a radius parameter

- Added
  [`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md),
  [`calc_avg_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_avg_columns.md),
  [`calc_ratio_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ratio_columns.md)
  – Added (or renamed to be consistent) these helper functions to make
  columns of averages, ratios to average, and percentiles (all of which
  can be used later to replace parts of
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)).
  Old, now-removed function avg_from_raw_lookup() was renamed as
  [`calc_avg_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_avg_columns.md).
  New function
  [`calc_pctile_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_pctile_columns.md)
  is vectorized form of retained function
  [`pctile_from_raw_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md).
  [`calc_ratio_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ratio_columns.md)
  is new. Removed/replaced the old, obsolete function
  calc_ratios_to_avg().

- Stopped exporting plot_boxplot_ratios() since ‘ejam2boxplot_ratios()’
  and ‘plot_boxplot_pctiles()’ work better.

## EJAM 2.32.6.002 (October 2025)

This update does not add any web app features.

Changes:

- Started rounding off the radius shown in the report header
- Fixed some small bugs in
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md),
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md),
  [`ejam2tableviewer()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2tableviewer.md),
  [`report_residents_within_xyz()`](https://public-environmental-data-partners.github.io/EJAM/reference/report_residents_within_xyz.md),
  and some helper functions related to report creation, etc. to support
  new API and R users, for handling sitenumber, missing shapefile, etc.
  For example, ejamit(fips=x) had a problem if x was a fips missing a
  needed leading zero.
- Fixed some obstacles to using the package and/or app locally from a
  working directory other than root of source pkg
- Fixed misc minor issues in reference documentation
- Deleted obsolete file and function report_community_download
- Changed github actions that run tests of ability to install the
  package on various R versions, operating systems, etc.

## EJAM 2.32.6.001 (October 2025)

This update does not add any web app features.

It mainly does the following:

- Fixes a couple of key issues related to installing and/or hosting
- Provides a new article about US Counties
- Provides a list of URLs of archived EPA webpages with EJSCREEN
  documentation
- Improves or adds code related to updating and maintaining this package
- Drafts code in progress that will support new features:
  - API
  - reports on user-provided indicators
  - counts of nearby user-provided points of interest

### Fixed

- Fixed some issues that were obstacles to installing the package and/or
  deploying to server
- Fixed code and tests so that when running more than 2,000 unit tests,
  zero tests fail now

### Changed or Added

- Added a list of URLs of archived EPA webpages documenting various
  aspects of EJSCREEN, in
  data-raw/EJSCREEN_archived_pages/EJSCREEN_archived_pages_and_docs.md
  (This may get moved later or could even be converted to a subset of a
  website)
- Added text to improve the articles on installing the package and
  updating datasets and others
- Added an article about US Counties
- [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  no longer will ask to confirm zero radius in shapefile case
- Drafted changes in
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)
  that will enable reports counting nearby user-provided points of
  interest, etc.
- Drafted changes in
  [`calc_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejam.md)
  and related functions that will enable reports aggregating custom,
  user-provided indicators.
- Drafted changes to draft API code to provide more endpoints, start
  work on POST vs just GET, added api_run() (later renamed as
  [`ejamapi_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi_local.md))
  to run API in background locally while testing/in dev, etc.
- Drafted sites_from_input() helper function called sites_only(), added
  as prelude to allowing lat,lon or sitepoints or fips or shapefile as
  inputs to more ejam2\_\_ functions
- Fixed code that can update the NAICS codes table.
- Removed obsolete article about EPA EJSCREEN API that was taken down in
  early 2025.
- Cleaned up, reformatted, or improved/ fixed code via lintr and in
  general, such as && or \|\| instead of & or \| within if().
- Improved documentation of
  [`?blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
  dataset
- Added utilities supporting package development, like map_add_pts() in
  MAP_FUNCTIONS.R, `pause()`, bgid_from_blockid(),
  pkg_functions_preceding_lines(), pkg_sizes(), find_transitive_minR(),
  functions in getblocks_helpers.R, etc.
- Documented the dataset_documenter() utility

## EJAM 2.32.6 (September 2025)

### **WEB APP CHANGES**

#### \* Restored language related to “Environmental Justice”

- Changed name of tool back to “Environmental Justice Analysis
  Multisite” tool (from “Environmental and Residential Population
  Analysis Multisite” tool, the name used in early 2025 through July
  2025)
- Restored some text: “EJ Indexes” now once again refers to what were
  called “Summary Indexes” early 2025 through July. “Supplementary EJ
  Indexes” is also restored.
- Did not restore all old text, at least not yet: Other language related
  to “environmental justice” was edited in early 2025 at EPA in response
  to an Executive Order, but has not been changed back to its original
  language even in this non-EPA version of the package. For anyone
  interested, notes listing those changes were archived in a file saved
  as “EJAM/data-raw/0_generic_terms_notes.R”.
- Made “EJSCREEN” all-caps everywhere (not “EJScreen”)
- Edited descriptions of some language-related indicators (to be shorter
  and more consistent), changed “block group” to “blockgroup”, etc.

#### Summary Report and Tables of Sites: Header, Footer, and Links to 1-Site Reports

- Report footer now shows exact version number (“2.32.6” not just
  “2.32”). Same in web app home page header. Fixed missing footer in
  some reports.

- Tables of sites (web and downloaded excel) and Map popups (web and
  downloaded html) now have web links to various kinds of 1-site
  reports, for each site. These were gone, but now are restored and
  expanded. Links to 2 report types are included by default:

  - link to the EJSCREEN app (zoomed to that 1 site)
  - summary report on 1 site, as a *downloaded* html file
    (API-generated)
  - summary report on 1 site, as a *live* webpage (shiny-generated) (Not
    yet implemented)
  - Others reports can be shown via settings – see table below.

#### Website now at [ejanalysis.org](https://www.ejanalysis.org) (or [ejanalysis.com](https://www.ejanalysis.com))

- [ejanalysis.org](https://www.ejanalysis.org) is an easy URL to
  remember, with info about – and links to – EJAM and EJSCREEN.
- [ejanalysis.org/about](https://www.ejanalysis.org/about) has [a new
  emailing list you can join](https://www.ejanalysis.org/about)
- [ejanalysis.org/ejamapp](https://www.ejanalysis.org/ejamapp) will go
  to a live version of the EJAM web app
- [ejanalysis.org/ejscreenapp](https://www.ejanalysis.org/ejscreenapp)
  will go to a live version of the EJSCREEN web app
- [ejanalysis.org/ejscreen](https://ejanalysis.org/ejscreen) has info on
  EJSCREEN
- [ejanalysis.org/ejam](https://ejanalysis.org/ejam) has info on EJAM
- [ejanalysis.org/status](https://ejanalysis.org/status) has info about
  the 2025 status and history of transition from EPA to non-EPA versions
  of EJSCREEN and EJAM
- [ejanalysis.org/ejamdocs](https://www.ejanalysis.org/ejamdocs) directs
  you to the documentation:
  - [What is
    EJAM?](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/whatis.html)
    is an overview of what EJAM can do.
  - [Accessing the Web
    App](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/webapp.html)
    is about the web app.

#### Web App Documentation

- Improved the `About page`
- Collected copies of old user guides to inform a new one that could be
  developed. [See User Guide
  examples](https://github.com/Public-Environmental-Data-Partners/EJAM/tree/main/data-raw/user-guides)

#### Web App Customization

- Added ability to configure web app (change settings), and added
  ability to pass inputs to the web app at launch. This allows the
  following:
  - Anyone using the EJAM web app online can go to the app using a URL
    that encodes customized input settings, and therefore launches a
    somewhat customized app. This is because bookmarking in the app
    saves the state of inputs, which control more settings now. Not all
    settings are available this way, but many are. These features may
    evolve.
  - Anyone using R/RStudio can now launch the web app locally with many
    more custom settings and inputs (providing sites as a parameter,
    using a custom default radius, overriding caps, etc.). See
    [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
    for examples.
  - Anyone hosting a version of the EJAM web app can customize it, e.g.,
    to use a different logo, different default radius, different options
    for how to select sites, etc.
- Reorganized the “Advanced” settings tab, which now has more options
  and settings that can be changed. That tab is hidden by default in
  most cases because it is complicated, and some parts are
  experimental/untested.

### **NON-WEB-APP CHANGES (FOR USING EJAM IN R/RSTUDIO)**

#### Shortcuts are provided via [ejanalysis.org](https://www.ejanalysis.org) (or [ejanalysis.com](https://www.ejanalysis.com))

- [ejanalysis.org/repo](https://www.ejanalysis.org/repo) or
  [ejanalysis.org/ejamrepo](https://www.ejanalysis.org/ejamrepo) directs
  you to the GitHub page for the EJAM package open source software.
- [GitHub issues now can be submitted
  here](https://github.com/Public-Environmental-Data-Partners/EJAM/issues)
- [ejanalysis.org/docs](https://www.ejanalysis.org/docs) or
  [ejanalysis.org/ejamdocs](https://www.ejanalysis.org/ejamdocs) directs
  you to the documentation for the EJAM package, including technical
  reference docs (how to install and use the R package to work directly
  with the more powerful tools EJAM offers beyond the web app).

#### Weblinks / URLs (API, reports, etc.)

- Restored columns of weblinks in single-site reports - they had been
  missing since 1/2025. Restored to tables of sites (results_bysite
  table from
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  [`ejam2tableviewer()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2tableviewer.md),
  etc.) & map popups (in functions like
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md))
- The choice of which types of reports to link to is controlled by a
  “default_reports” setting in the global_defaults_package.R file.
- Added several new functions that can provide these kinds of reports:

| header (column title) | text (of link) | function name | key parameters |
|----|----|----|----|
| EJAM Report | Report | [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md) | sitepoints (or lat,lon) or shapefile or fips |
| EJSCREEN Map | EJSCREEN | [`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md) | sitepoints (or lat,lon) or shapefile or fips |
| EnviroMapper Report | EnviroMapper | [`url_enviromapper()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_enviromapper.md) | sitepoints (or lat,lon) or shapefile or fips |
| ECHO Report | ECHO | [`url_echo_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_echo_facility.md) | regid |
| FRS Report | FRS | [`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md) | regid |
| County Health Report | County | [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md) | fips |
| State Health Report | State | [`url_state_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_health.md) | fips |
| County Equity Atlas Report | County | [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md) | fips |
| State Equity Atlas Report | State | [`url_state_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_equityatlas.md) | fips |

- [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
  provides URLs to use with EJAM-API to get an html summary report on 1
  site at a time. Inputs to this function are like inputs to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  but so far mostly limited to radius, sitepoints, fips, shapefile. This
  will enable the map popups and excel tables of sites to include links
  to single-site reports, for example. It is limited to blockgroup fips
  only, right now, and only single-site reports right now.
- [`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
  and other functions in table above were revised, cleaned up, and moved
  among .R files.
- [`url_enviromapper()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_enviromapper.md)
  and
  [`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
  can now accept a fips code and get the approx centroid of each block,
  blockgroup, tract, city, county, or state - that lets it craft a link
  to send you to EJSCREEN or EnviroMapper zoomed to one fips unit
- [`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md)
  and
  [`url_echo_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_echo_facility.md)
  are the new names of functions giving links to EPA FRS and ECHO
  reports on regulated facilities.
- [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md)
  and
  [`url_state_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_health.md)
  are new or renamed and provide links to reports that used to be called
  county health rankings
- [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md)
  &
  [`url_state_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_equityatlas.md)
  make links to Equity Atlas reports

#### Web app customization details

- Added
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  as the new name for what was
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md)
  – This launches EJAM as a local shiny app, in RStudio.
- Added ability to set many options and defaults as parameters passed to
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md).
- Added many examples to
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  documentation showing how to change the defaults and options. You can
  now provide a set of points, fips, or polygons to preload at launch
  e.g., `ejamapp(sitepoints=testpoints_10, radius=5)`
- Drafted a new article with technical details: [Defaults and Custom
  Settings for the Web
  App](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/dev-app-settings.html)
- Changed where the app title is stored. It is stored in the DESCRIPTION
  file as a field. (The app title also can be modified by editing
  `global_defaults_package.R` or by passing parameters to
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)).
- Changed how Advanced tab visibility is controlled
  (“default_can_show_advanced_settings” and
  “default_show_advanced_settings” set initial values of shiny inputs of
  the same names)
- Fixed a bug where `isPublic` parameter in
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  was being ignored.
- Fixed a bug where threshold-related params in
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  got ignored in latlon case.
- Renamed many global_defaults\_ variables and shiny app input
  variables, and check in ejamapp() for special variables, so they are
  easier to use as parameters in
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md).
- Renamed many global defaults (related to app title, logo, and version
  number, etc.), to be more clear and consistent, and moved several to
  `global_defaults_package.R`. So logos e.g. could be changed via
  `ejamapp(report_logo="www/EPA_logo_white_2.png", app_logo="www/EPA_logo_white_2.png")`,
  or report_logo=“” to show no logo on reports.

#### Added documentation

- Simplified the
  [README](https://github.com/Public-Environmental-Data-Partners/EJAM/#readme)
- Improved the [article on how to install the
  package](https://Public-Environmental-Data-Partners.github.io/EJAM/articles/installing.html),
  but it does need some additional testing/fixes.
- Renamed fields in the DESCRIPTION file, for VERSION and DATE info!
- Redid sample report, etc. outputs in `testdata/examples_of_outputs`
  folder to reflect changes in version numbers shown in report footer
  and app header, etc.
- Renamed various \*.R files and relocated some source code among those,
  to make some filenames more consistent.
- Made some functions internal that until now had been exported, to
  simplify things for most R users.
- Updated [roxygen2](https://roxygen2.r-lib.org/) help file docs and
  pkgdown documentation webpages
- New function
  [`url_github_preview()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_github_preview.md)
  makes it a bit easier to view rendered HTML reports that each package
  release or branch stores in the testdata/examples_of_outputs folder,
  to compare how they look in different versions.
- Spell checked / fixed some typos
- Fixed some documentation

#### Added or changed functions

- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  now has a sitenumber parameter, to get a report on one site more
  easily
- [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  now has a sitenumber parameter, to map one site more easily
- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  now downloads FIPS bounds if missing.
- [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  now downloads FIPS bounds if missing.
- unit tests added for functions including ejam2map() and ejam2excel()
  and various other functions
- [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
  and some others now drop sites with empty geometry before trying to
  map, avoid an error
- [`popup_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/popup_from_any.md)
  and other map popup functions now have different parameters that can
  handle more columns of URLs/links of any type
- [`popup_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/popup_from_any.md)
  and other map popup functions now drop the geometry column from
  spatial data.frames to avoid including a mess in the popup
- [`ejam2histogram()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2histogram.md)
  is now exported and has more flexible parameters for title, y axis
  label, variable names
- [`shape2geojson()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape2geojson.md)
  is a new helper function that tries to convert a spatial data.frame to
  text string geojson, the format needed by the 8/2025 version of the
  EJAM-API
- [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
  now can also recognize a vector of character strings that are geojson
  polygons, via helper shapefile_from_geojson_text(), the inverse of
  shape2geojson()
- `testinput_fips_mix` is a new dataset with fips of each type: block,
  blockgroup, tract, city, county, state
- [`fips_county_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_county_from_latlon.md)
  and
  [`fips_state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_state_from_latlon.md)
  are new internal functions - for each point, they identify the county
  or state it is in
- [`fips2countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2countyfips.md)
  reports what US County contains each fips-based Census unit, such as
  the Counties in which some blockgroups are located.
- [`fips2name()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2name.md)
  now handles block fips instead of warning
- [`sites_from_input()`](https://public-environmental-data-partners.github.io/EJAM/reference/sites_from_input.md)
  new internal function that helps other functions flexibly accept sites
  in various formats of input parameters:
  - lat= and lon= vectors of point coordinates, or
  - sitepoints= a data.frame with columns called lat and lon, or
  - shapefile= a spatial data.frame of polygons, or
  - fips= a vector of census FIPS code
- [`regids_valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/regids_valid.md)
  is a new internal function
- [`url_linkify()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_linkify.md)
  improved and made internal
- `urls_from_keylists()` utility drafted to help assemble url-encoded
  API query from lists of key=value arguments, etc.
- `url_ejamapi2arglist()` is a new helper that just parses url-encoded
  API requests back to arguments like ejamit() would need

## EJAM v2.32.5 (July 2025)

### Web App

- **Cities, Counties, States:** Census units like States, Counties, and
  Cities/Towns/CDPs can be selected from a menu or searched by typing
  part of the name. Clicking “Done” will check online for the boundaries
  of those places, at which point the “Start Analysis” button will be
  enabled. Then clicking the “Start Analysis” button analyzes the sites
  for which bounds were found.
- **Area in square miles**: The app now gets or calculates the area of
  each site more consistently and efficiently. (The function
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  has new params related to how
  [`area_sqmi()`](https://public-environmental-data-partners.github.io/EJAM/reference/area_sqmi.md)
  now can get square mileage info from
  [`?blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
  table without needing to download boundaries. There are new parameters
  called `download_fips_bounds_ok`, `download_noncity_fips_bounds`, and
  `includewater`. The new params are also driven by two new defaults in
  `global_defaults_shiny.R` The old parameter
  default_download_fips_bounds_to_calc_areas is no longer a param in
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)).
- **County population counts:** Fixed county population counts obtained
  from and shown in some maps (via fixes in a function used by
  [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
  so, e.g., if using
  [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md),
  `mapfast(shapes_from_fips(testinput_fips_counties))` now shows the
  right numbers).
- **Summary Indexes (aka EJ Indexes)** had some incorrect numbers, so
  this release has replaced
  [`?bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md)
  dataset with correct numbers. (Correct numbers were drawn from the
  [internet archive
  version](https://web.archive.org/web/20250203215307/https://gaftp.epa.gov/ejscreen/2024/2.32_August_UseMe/EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv.zip)
  that was a copy of the [datasets EPA had posted August
  2024](https://gaftp.epa.gov/EJScreen/2024/2.32_August_UseMe/EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv.zip)).
- **Sort order of FIPS Census units:** Sort order of output FIPS codes
  and polygons should now always be the same as the order of the inputs
  (sorted like they were in an uploaded shapefile, uploaded FIPS, or
  FIPS selected from the dropdown list).
- **Medians in barplots:** DRAFT feature/ work in progress – interactive
  barplots of indicators will be able to show median not just mean (via
  the
  [`ejam2barplot_indicators()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_indicators.md)
  function).

### RStudio users only

#### Documentation updates

- [Installation instructions in
  vignette/article](https://public-environmental-data-partners.github.io/EJAM/articles/installing.md)
  were redone.
- Articles (aka vignettes) were renamed (titles and file names).
- [README](https://github.com/Public-Environmental-Data-Partners/EJAM/#readme)
  mentions <https://www.ejanalysis.com> now.
  [`?blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
  documentation was improved.
- [`acs_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bybg.md)
  documentation now has notes on the key ACS demographic data tables
  most relevant to EJSCREEN.
- Edited files `DESCRIPTION`, `CITATION.cff` (new), `CITATION`,
  `LICENSE` (new), `LICENSE.md`, etc.

#### Functions added or improved

- Mix of fips types allowed:
  - [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
    now accepts a mix of city and noncity fips (state, county, tract,
    blockgroup), so you can get a shapefile where some polygons are
    cities and others are counties, etc. Previously that was not
    possible and caused an error. See parameter
    `allow_multiple_fips_types` in
    [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md).
  - [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
    now accepts a mix of city and noncity fips (state, county, tract,
    blockgroup), so you can get a shapefile where some polygons are
    cities and others are counties, etc. Previously that was not
    possible and caused an error.
- [`fips2name()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2name.md)
  now also provides text name for a tract
- [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
  for a single point now zooms out enough to see the whole radius (e.g.,
  `mapfast(testpoints_10[1,], radius = 10)`)
- [`mapfastej_counties()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfastej_counties.md)
  has improved color-coded maps of counties.
- [`convert_units()`](https://public-environmental-data-partners.github.io/EJAM/reference/convert_units.md)
  now can recognize more abbreviations like “mi^2” via updated
  [`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md),
  and got some bug fixes.
- [`fips_bg_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bg_from_latlon.md)
  drafted as unexported function that identifies which blockgroup each
  point is inside.

#### Functions fixed or modified

- [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  and
  [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
  (and related helper functions) have more consistent, useful outputs:
  - *Sorting*: The outputs now consistently preserve sort order of the
    input (points, fips, or polygons). This had not been the case for
    [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
    outputs, and the table `results_bysite` from
    [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
    or
    [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
    was preserving sort order only for the latlon case but not
    necessarily the fips or shapes cases.
  - *Invalid sites*: The outputs of
    [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
    (and related helper functions) will have a row for each valid or
    invalid input site (it will no longer omit output rows for invalid
    fips and when boundaries could not be obtained for valid fips) – The
    number of rows in a shapefile output will be the same as then length
    of the input fips vector. The output table `results_bysite` from
    [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
    also has a row for each valid or invalid input site. That table in
    the output of
    [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
    in contrast does *not* have a row for any site lacking blocks, since
    the input is from getblock_xyz functions
    ([`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
    [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md),
    [`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)),
    which don’t provide those sites.
  - *Columns* from
    [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
    and related helpers: The output columns are ordered in a more useful
    way and are more consistent across functions. The output also
    consistently tries to add population, area in square miles, name of
    census unit, state abbreviation, etc., via new helpers like
    `shapefile_addcols()`
- [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  and related functions
  ([`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md),
  [`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md),
  etc.) also have more consistent outputs:
  - *Unique ID in FIPS case*: The `ejam_uniq_id` column in the outputs
    of these functions will be based on 1 through the number of sites in
    the inputs (with multiple rows per site as needed to include all the
    blocks). Previously, FIPS codes had been used as the `ejam_uniq_id`
    sometimes (and still are in the outputs of functions like
    [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
    where the output has a table with one row per site).
  - *Sorting*: The output sites are now sorted like the input sites
    (points, fips, or polygons), while there are still usually many rows
    (blocks) per site. It had been sorted primarily by blockid,
    previously.
  - **Invalid sites:** The outputs of all the getblock… functions will
    be consistent – They all provide a sites2blocks data.table output
    (like
    [`?testoutput_getblocksnearby_10pts_1miles`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md))
    that does not include any sites that have zero blocks. The
    `ejam_uniq_id` will still correspond to the input vector, so if an
    invalid and valid site were input in that order, 2 would be the only
    `ejam_uniq_id` in the sites2blocks table. The FIPS-based functions,
    though, like
    [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md),
    when returning a spatial data.frame, will include all the sites in
    the output, even if they have no blocks, so that the number of rows
    in the output shapefile will match the number of sites in the input
    fips vector.
- [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
  (and related) have new `year` parameter, passed to
  \[tigris::places()\], defaulting to the 2024 boundaries polygons of
  cities/towns.
- testoutput_xyz .xlsx and .html files and dataset R objects like
  [`?testoutput_ejamit_100pts_1miles`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_100pts_1miles.md)
  have been updated to reflect the new
  [`?bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md)
  dataset, typo fixes, and other edits.
- Some testinput objects like testinput_fips_counties are now vectors
  per is.vector(), and no longer have metadata stored as attributes like
  date_saved_in_package, etc. Adding that info via
  [`metadata_add()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add.md)
  was making is.vector() FALSE and interfered with some functions that
  expect the input to be a vector, like
  [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md).
  Also, `testinput_xtrac` was removed.
- [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  and
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  now report 0 for `results_bysite$blockcount_near_site` and
  `results_bysite$bgcount_near_site` if there are none, and total counts
  are correct.
- [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  based on
  [`getblocksnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearbyviaQuadTree.md)
  will no longer include, in its output, the lat lon columns from the
  input table of sitepoints. That was unintentional and potentially
  confusing and wasted space.
- `plotblocksnearby()` rewritten to fix/improve map popups, etc., and a
  parameter was dropped

#### Package development/ technical

- Many unit tests added, especially for
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  and
  [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
  and related.
- [`test_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/test_ejam.md)
  is what used to be called `test_interactively()` – it was improved and
  renamed and moved to the R folder as an unexported internal function
  loaded as part of the package. Also, a new parameter y_skipbasic is
  used instead of y_basic.
- `test_coverage_check()` utility was improved (but somewhat work in
  progress), just as a way to for package maintainers/contributors to
  look at which functions might need unit tests written.
- Utility functions related to package development were renamed, e.g.,
  in utils_PACKAGE_dev.R
- `linesofcode2()` utility was improved, just as a way for package
  maintainers/contributors to look at which files have most of the lines
  of code, are mostly comments, etc.
- `table_xls_format_api()` is what used to be called
  table_xls_formatting_api() (but is not used unless the ejscreenapi
  module or server is working).
- fixed inconsistent use of parameter `in_shiny` versus `inshiny`, to
  always call it `in_shiny`
- removed functions and text related to pins board (obsolete)
- renamed map_headernames spreadsheet file to reflect a new version
  (`EJAM/data-raw/map_headernames_2.32.5.xlsx`), made edits/fixes
  (spelling of CEJST, e.g.), and updated the data object
  [`?map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).
- rebuilt favicons per updates in {pkgdown}
- Edited DESCRIPTION file to specify minimum versions for most packages
  in Imports, and a newer version of R. Almost all of these just refer
  to the latest version on CRAN as of this release, even though several
  were not strictly necessary for the functions to work correctly.

## EJAM v2.32.4 (June 2025)

Note the URLs, emails, and notes about repository locations/owners were
edited to reflect this forked non-EPA version of the EJAM package being
located initially at ejanalysis/EJAM, later moved to
Public-Environmental-Data-Partners/EJAM, so the package called the
v2.32.4 release on ejanalysis/EJAM (later moved to
Public-Environmental-Data-Partners/EJAM) is slightly different than the
version called the v2.32.4 release that was released on USEPA/EJAM-open.

### Web app

- Fixed logo in “About” tab, app header, and report header, in app_ui,
  generate_html_header(), global_defaults_xyz, etc., and updated
  testoutput files related to
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  and
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
- corrected spelling in app and documentation
- added better examples of params one can pass via
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md)

### RStudio users only

- New summary table and plot are available via
  [`ejam2areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2areafeatures.md)
  and
  [`ejam2barplot_areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_areafeatures.md).
  Changes in
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  provide information about what fraction of residents have certain
  features or types of areas where they live, such as schools,
  hospitals, Tribal areas, nonattainment areas, CEJST areas, etc. This
  is done via many changes to
  [`batch.summarize()`](https://public-environmental-data-partners.github.io/EJAM/reference/batch.summarize.md).
- added better examples of params one can pass via
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md)
- documented
  [`get_global_defaults_or_user_options()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_global_defaults_or_user_options.md)
  and
  [`global_or_param()`](https://public-environmental-data-partners.github.io/EJAM/reference/global_or_param.md)
- fixed
  [`ejam2means()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2means.md)
- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  gets new params, and in
  [`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md)
  added report_title = NULL, logo_path = NULL, logo_html = NULL.
- [`plot_barplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios.md)
  gets new ylab and caption params
- added warning in
  [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md)
  if default year seems outdated
- unexported draft
  [`read_and_clean_points()`](https://public-environmental-data-partners.github.io/EJAM/reference/read_and_clean_points.md)
- unexported draft `ejam2quantiles()`
- removed reference to obsolete testids_registry_id, replaced by
  [`?testinput_regid`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_regid.md)

### Technical / internal changes:

- enabled testing of web app functionality from the test_interactively()
  utility (which has more recently been renamed
  [`test_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/test_ejam.md)
  and put in R folder as an unexported internal function loaded as part
  of the package) or via test_local(), etc., not just from a github
  action. (See /tests/setup.R which now has a copy of what is also in
  app-functionality.R)
- drafted revisions to ui and server to try to allow for more
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md)
  params or advanced tab or global_defaults_xyz to alter default method
  of upload vs dropdown, e.g., output ss_choose_method_ui,
  default_ss_choose_method, default_upload_dropdown. This included
  revising server and ui to use just `EJAM:::global_or_param()` not
  [`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html),
  so that non-shiny global defaults can work (e.g., logo path as
  `global_defaults_package$.community_report_logo_path`) even outside
  shiny when global_defaults_package has happened via onattach but
  global_defaults_shiny etc. has not happened.
- changed `.onAttach()` to do source(global_defaults_package) with local
  = FALSE not TRUE, but this might need to be revisited – note both
  local = F and local = T are used in `.onAttach()` versus
  [`get_global_defaults_or_user_options()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_global_defaults_or_user_options.md)
- in server,
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  now figures out value of radius_or_buffer_description,
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  gets new parameters table_xls_from_ejam() uses improved
  buffer_desc_from_sitetype() and now uses
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  to add a report in one tab.
- reorganized server code by moving v1_demog_table() and v1_envt_table
  to long report section of server file
- cleaned up server code (eg, remove obsolete input\$disconnect, remove
  obsolete community_download() and report_community_download(), and
  remove repetitive `ejam2repor()`, remove old EJSCREEN Batch Tool tab,
  used session = session as param in server calls to updateXYZINPUT,
  etc.)
- allow shiny.testmode to be TRUE even if not set in options
- used silent=TRUE in more cases of
  [`try()`](https://rdrr.io/r/base/try.html)
- added validate(“problem with
  [`map_shapes_leaflet()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_leaflet.md)
  function”)
- added validate(need(data_processed(), ‘Please run an analysis to see
  results.’))

## EJAM v2.32.3 (May 2025)

### Summary report and related improvements

- Added a long list of additional indicators in the summary report (in a
  subtable) and in outputs of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  etc. New indicators include counts of features (Superfund sites,
  schools, etc.), asthma and cancer rates, overlaps with certain types
  of areas (Tribal, C JEST disadv., air nonattainment areas, etc.),
  flood risk, % with health insurance, more age groups (% under 18), and
  numerous other indicators. You can see the expanded report via
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  or at
  `system.file("testdata/examples_of_output/testoutput_ejam2report_100pts_1miles.html", package = "EJAM")`
- Area in square miles (area_sqmi column) added to results, with
  calculation of size of each location (polygon or FIPS unit or circle
  around a point)
- More/better info on number of sites or site ID and lat/lon, now in
  header
- Enabled customization of summary table (for R users) to show fewer or
  new additional indicators (as long as they are in the outputs of
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  and
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  or at least are in the inputs to
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  etc.). This is done via the `extratable_list_of_sections` parameter in
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md),
  in
  [`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md),
  in the community_report_template.Rmd, and in global parameter
  `default_extratable_list_of_sections`. It may later be enabled as
  modifiable in the advanced tab.
- Easier to set which logo to show on summary report (EPA or EJAM or
  other logo), in global settings

### Other web app improvements

- More types of shapefiles can be uploaded in the web app – json,
  geojson, kml, zip (of gdb or other), and shp.
- Census units like States, Counties, and Cities/Towns/CDPs can now be
  selected from a menu or searched by typing part of the name, in a
  shiny module called fipspicker, and the feature is enabled/disabled
  via global settings `use_fipspicker` and
  `default_choices_for_type_of_site_category`. It works but current does
  not check or alert users if boundaries are not available, until after
  the Start Analysis button is clicked.
- Simpler UI for “More info” button about file types and formats allowed
  in upload.
- Preview maps can show FIPS now, along with shapefile polygons, or
  points
- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  and
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  and
  [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
  now better able to create maps of polygon data, FIPS, one site vs all
  sites, etc.
- progress bar added for doaggregate() in cases of fips and latlon

### RStudio user-related or internal improvements

- Clarified/explained 2025 status of API and urls in CONTRIBUTING and
  README, etc.
- Extensive additions of and improvements in articles/vignettes,
  including documentation of how to maintain repo, package, and
  datasets. Articles/vignettes avoid hardcoded repo urls, and use
  relative links within pkgdown site… helper function repo_from_desc()
  added – but later renamed to url_package() – avoids hardcoded repo
  url; download_latest_arrow_data avoids hardcoded repo url; links to
  testdata files on webapp UI avoid hardcoded repo url; simpler [What is
  EJAM](https://public-environmental-data-partners.github.io/EJAM/articles/whatis.md)
  doc.
- [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  in interactive mode (RStudio) now lets you select any type of file to
  upload if no sites specified by parameters
- Many options or starting values or settings for the shiny app (and in
  general) can now be set as parameters passed to the
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md)
  function, which overrides the defaults. extensive changes to global
  defaults vs user parameters allowed: replaced global.R; files renamed,
  put in 1 folder, etc. System for using user parameters passed to
  [`run_app()`](https://public-environmental-data-partners.github.io/EJAM/reference/run_app.md),
  global defaults otherwise, many can be changed in advanced tab; some
  may be bookmarkable. The default values are now set for the shiny app
  and in general in files called `global_defaults_package.R`,
  `global_defaults_shiny_public.R`, and `global_defaults_shiny.R`
  (rather than in the old files global.R or manage-public-private.R).
- [`acs_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bybg.md)
  examples added, on how to obtain and analyze new/custom indicators
  from the American Community Survey (ACS) data
- [`testdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/testdata.md)
  function improved, showing you examples of files that be used as
  inputs to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md).
  [`testdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/testdata.md)
  files and data objects cleaned up/renamed consistently and new ones
  added for fips types, naics, sic, mact, etc.
- refactored names of plot functions made more consistent to use “plot”
  singular and “ratios” plural, as in
  [`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md),
  `boxplot_ratios()`, etc.
- documentation fixed in some functions (e.g.,
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md))
- large datasets managed via
  [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md),
  [`download_latest_arrow_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_latest_arrow_data.md)
  and other new arrow-related functions and no longer on pins board or
  aws at all. arrow datasets faster format used most places, other
  changes to handling downloads etc.
- `shape_from_fips()` checks if census API key available and tidycensus
  pkg now imported, uses alt method (arcgis services) to get boundaries
  if necessary.
- Continued towards refactoring/consolidating code in server vs in
  functions, related to creating summary report as HTML vs for download
  from shiny app vs from
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md),
  in helper functions such as
  [`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md),
  [`report_residents_within_xyz()`](https://public-environmental-data-partners.github.io/EJAM/reference/report_residents_within_xyz.md),
  renamed generate_demog_header to generate_env_demog_header, etc.
- server uses
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  for SHP and latlon, and cleanup
- server uses
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  now (which then relies on
  [`table_xls_format()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_xls_format.md))
- server uses
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  now, not obsolete report_community_download() etc.
- server uses
  [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
  now
- server: removed use of data_summarized reactive everywhere, use
  data_processed\$…
- 2 new params
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  has, to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md),
  for calctype_maxbg and minbg
- bug fixes such as in
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  for wtdmeancols param,
  [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md),
  [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md),
  [`plot_ridgeline_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_ridgeline_ratios.md),
  [`map_google()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_google.md),
  in
  [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
  for tracts vs blockgroups, many others
- unit tests added and others updated/fixed
- misc helpers/utility added/updated/documented
- renamed .xlsx file of map_headernames info to reflect a new version
  and made edits/fixes
- `reposissues()` and `repoissues2()` help record snapshot of gh issues
- DESCRIPTION file now has new field ejam_data_repo
- updated workflow action to use latest version of
  github-pages-deploy-action

## EJAM v2.32.2 (February 2025)

- Revised all language based on executive orders, to refer to
  environmental and residential population data analysis, rather than EJ
  / EJSCREEN / etc.
- Revised web links based on EJSCREEN website being offline
- Some edits made considering github repositories and gh pages may
  change location or go offline
- Updated FRS datasets, pulled on 2/12/25
- Remove screenshots from user guide document

## EJAM v2.32.1-EJAM (February 2025)

### Bug Fixes

- Fixed metadata warning shown during loading of arrow datasets
- Fixed typos in languages spoken indicators labels
- Improved labeling and legibility of barplot of ratios used in reports
  and downloads
- Fixed caps to \# of points selected, analyzed

### Enhancements

- Expanded tables of indicators shown in community report
- Languages spoken at home, health, community, age
- Added ratio columns to community report as advanced setting and
  heatmap highlighting optional
- Incorporated `shinytest2` tests for app-based functionality testing
- Implemented mapping for points in
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)

### Experimental enhancements

- Added draft plumber API for
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
- Added widget to advanced settings
- proxistat() helps build proximity indicator
- Zipcodes vignette

### Other

- Refactored community report functions, `app_server.R` script

## EJAM v2.32-EJAM (January 2025)

### New Features + Improvements

- Enabled automatic download of latest arrow data from ejamdata repo
- Incorporated public-internal toggles to hide specific UI elements not
  yet applicable to the public version of EJAM
- Made improvements to maps of polygons
- Added shapefile upload instructions

### Bug Fixes and Enhancements

- Added `leaflet.extras2` dependency to Imports, instead of Suggests,
  which is necessary for new installations

## EJAM v2.32.0

- The EJAM R package is available as an open source resource you can
  - clone from the [EJAM-open github
    repository](https://github.com/USEPA/EJAM-open) or
  - install using the [installation
    instructions](https://public-environmental-data-partners.github.io/EJAM/articles/installing.md)
