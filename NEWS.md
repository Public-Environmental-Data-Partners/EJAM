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
- Drafted changes to draft API code to provide more endpoints, start work on POST vs just GET, added `api_run()` to run API in background locally while testing/in dev, etc.
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
    -   [What is EJAM?](https://ejanalysis.github.io/EJAM/articles/whatis.html) is an overview of what EJAM can do.
    -   [Accessing the Web App](https://ejanalysis.github.io/EJAM/articles/webapp.html) is about the web app.

### Web App Documentation

-   Improved the `About page`
-   Collected copies of old user guides to inform a new one that could be developed. [See User Guide examples](https://github.com/ejanalysis/EJAM/tree/EJAM-v2.32.6/data-raw/user-guides) that [will be here](https://github.com/ejanalysis/EJAM/tree/main/data-raw/user-guides)

### Web App Customization

-   Added ability to configure web app (change settings), and added ability to pass inputs to the web app at launch. This allows the following:
    -   Anyone using the EJAM web app online can go to the app using a URL that encodes customized input settings, and therefore launches a somewhat customized app. This is because bookmarking in the app saves the state of inputs, which control more settings now. Not all settings are available this way, but many are. These features may evolve.
    -   Anyone using R/RStudio can now launch the web app locally with many more custom settings and inputs (providing sites as a parameter, using a custom default radius, overriding caps, etc.). See `ejamapp()` for examples.
    -   Anyone hosting a version of the EJAM web app can customize it, e.g., to use a different logo, different default radius, different options for how to select sites, etc.
-   Reorganized the "Advanced" settings tab, which now has more options and settings that can be changed. That tab is hidden by default in most cases because it is complicated, and some parts are experimental/untested.


## **NON-WEB-APP CHANGES (FOR USING EJAM IN R/RSTUDIO)**

### Shortcuts are provided via [ejanalysis.org](https://www.ejanalysis.org) (or [ejanalysis.com](https://www.ejanalysis.com))

-   [ejanalysis.org/repo](https://www.ejanalysis.org/repo) or [ejanalysis.org/ejamrepo](https://www.ejanalysis.org/ejamrepo) directs you to the GitHub page for the EJAM package open source software.
-   [GitHub issues now can be submitted here](https://github.com/ejanalysis/EJAM/issues)
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
-   Drafted a new article with technical details: [Defaults and Custom Settings for the Web App](https://ejanalysis.github.io/EJAM/articles/dev-app-settings.html)
-   Changed where the app title is stored. It is stored in the DESCRIPTION file as a field. (The app title also can be modified by editing `global_defaults_package.R` or by passing parameters to `ejamapp()`).
-   Changed how Advanced tab visibility is controlled ("default_can_show_advanced_settings" and "default_show_advanced_settings" set initial values of shiny inputs of the same names)
-   Fixed a bug where `isPublic` parameter in `ejamapp()` was being ignored.
-   Fixed a bug where threshold-related params in `ejamapp()` got ignored in latlon case.
-   Renamed many global_defaults\_ variables and shiny app input variables, and check in ejamapp() for special variables, so they are easier to use as parameters in `ejamapp()`. 
-   Renamed many global defaults (related to app title, logo, and version number, etc.), to be more clear and consistent, and moved several to `global_defaults_package.R`. So logos e.g. could be changed via `ejamapp(report_logo="www/EPA_logo_white_2.png", app_logo="www/EPA_logo_white_2.png")`, or report_logo="" to show no logo on reports.
  

### Added documentation

-   Simplified the [README](https://github.com/ejanalysis/EJAM/#readme)
-   Improved the [article on how to install the package](https://ejanalysis.github.io/EJAM/articles/installing.html), but it does need some additional testing/fixes.
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
-   [README](https://github.com/ejanalysis/EJAM/#readme) mentions <https://www.ejanalysis.com> now. `?blockgroupstats` documentation was improved.
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

Note the URLs, emails, and notes about repository locations/owners were edited to reflect this forked non-EPA version of the EJAM package being located at ejanalysis/EJAM, so the package called the v2.32.4 release on ejanalysis/EJAM is slightly different than the version called the v2.32.4 release that was released on USEPA/EJAM-open.

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
-   Extensive additions of and improvements in articles/vignettes, including documentation of how to maintain repo, package, and datasets. Articles/vignettes avoid hardcoded repo urls, and use relative links within pkgdown site... unexported helper function `EJAM:::repo_from_desc()` added, avoids hardcoded repo url; download_latest_arrow_data avoids hardcoded repo url; links to testdata files on webapp UI avoid hardcoded repo url; simpler [What is EJAM](../articles/whatis.html) doc.
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
-   `reposissues()` and `repoissues2()` help record snapshot of gh issues
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
