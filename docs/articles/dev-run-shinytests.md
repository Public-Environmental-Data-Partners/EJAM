# Testing EJAM App with shinytest2

This document covers the UI-related automated tests.

## NOTE on work in progress / how to run the webapp tests

This package can use
[`shinytest2::test_app()`](https://rstudio.github.io/shinytest2/reference/test_app.html).

`EJAM:::test_ejam()` instead uses an approach that first sources
`testthat/setup.R` which does setup needed and also sources
`testthat/setup-shinytest2.R` which defines
`shinytest2_webapp_functionality()`, a function that contains the steps
tested in the web app, and then directly uses that function from within
test files like `/tests/testthat/test-webapp-all-functionality.R`.

## Dev Environment

If you are successfully running the app, you should have all the
necessary packages, or at least those in Imports or Suggests of the
`DESCRIPTION` file. Some dev-related packages and tools to note:

- **[shinytest2](https://rstudio.github.io/shinytest2/)** -
  [shinytest2](https://rstudio.github.io/shinytest2/) is the key R
  package helping to test shiny web app functionality

- **Pandoc** and **knitr** – The Pandoc software comes bundled with
  RStudio, and is a “swiss-army knife” for document conversion. There
  also is a function called \[knitr::pandoc()\] that is a wrapper that
  calls Pandoc to convert docs to HTML, PDF, etc.

- **PhantomJS** maybe – This used to be needed for downloads (and was
  installed with
  [`webshot::install_phantomjs()`](http://wch.github.io/webshot/reference/install_phantomjs.md)).
  But note this newer info:

NOTE FROM
<https://rstudio.github.io/shinytest2/articles/z-migration.html>: -
[shinytest2](https://rstudio.github.io/shinytest2/) is the successor to
[shinytest](https://github.com/rstudio/shinytest).
[shinytest](https://github.com/rstudio/shinytest) was implemented using
[webdriver](https://github.com/rstudio/webdriver) which uses
[PhantomJS](https://phantomjs.org/api/). PhantomJS has been unsupported
since 2017 and does not support displaying
[bslib](https://rstudio.github.io/bslib/)’s Bootstrap v5.
[shinytest2](https://rstudio.github.io/shinytest2/) uses
[chromote](https://rstudio.github.io/chromote/) to connect to your
locally installed Chrome or Chromium application, allowing
[shinytest2](https://rstudio.github.io/shinytest2/) to display
[bslib](https://rstudio.github.io/bslib/)’s Bootstrap v5.

## How shinytest2 Works

[shinytest2](https://rstudio.github.io/shinytest2/) (here referred to
henceforth as “shinytest” not to be confused with the older R package
that was named shinytest!) automates shiny web app functionality
testing, so we can determine if code updates break or unexpectedly
modify parts of an application.

It runs the app in a headless Chrome or Chromium browser and simulates
user interactions. The EJAM shinytest2 tests no longer compare full
saved snapshots of app state, generated HTML, maps, tables, or
downloaded files. Instead, they assert stable, intentional facts about
app behavior. This avoids brittle failures from minor changes in
generated HTML, dates, package versions, table rendering details, or map
markup.

### Key Features:

- Runs scripted app interactions for each supported web app test
  category
- Checks that the expected site-selection path is used for each category
- Checks uploaded filenames or FIPS picker selections where relevant
- Checks that analysis completion is exported by the app
- Checks selected inputs such as radius, title, plot controls, and
  picker values
- Checks downloaded reports and spreadsheets by file type, approximate
  size, and basic structure
- Checks that key tables, plots, and report outputs render in the
  `latlon` full-path test
- Avoids checking exact full HTML reports, map markup, complete table
  contents, exact dates, or package version text

## EJAM’s shinytest2 Folder Structure

``` plaintext

R/test_ejam.R

tests/
  └── testthat/
      ├── setup.R
      ├── setup-shinytest2.R
      ├── test-webapp-all-functionality.R
      └── test-webapp-[DATA TYPE]-functionality.R (e.g. test-webapp-FIPS-functionality.R)
```

### File Descriptions

- **`testthat/setup.R`** – Does setup for the test environment (loads
  `global_*.R` and app scripts into the testing environment, etc.). This
  file is auto-sourced by `testthat`.

- **`setup-shinytest2.R`** – Is also auto-sourced by `testthat` because
  its filename starts with `setup-`, and it contains the source code for
  `shinytest2_webapp_functionality()`, which does a series of tests of
  web app UI interactions using the app to upload or select, and
  analyze, multiple data types (FIPS, shapefile, latlon, NAICS, etc.).

- **`testthat/test-webapp-all-functionality.R`** – Runs the normal web
  app functionality suite. It launches one Shiny app process and runs
  the FIPS, FIPS picker, FRS, lat/lon, NAICS, and shapefile categories
  sequentially inside that one app session.

- **`testthat/test-webapp-[DATA TYPE]-functionality.R`** – Individual
  category files are available for focused debugging. They are skipped
  by default in ordinary `testthat` runs; set
  `EJAM_SHINYTEST2_INDIVIDUAL=true` before running one if you want that
  file to launch and test only that category.

## Updating Tests

You may wish to modify the shinytest scripts, either to add new
interactions with the application or to modify existing ones, such as in
the case of an app component that can no longer be interacted with. Here
are some methods and tips for updating the shinytest script accordingly.

### Direct Updates

Modify source code of `shinytest2_webapp_functionality()` to add new
interactions with the app for the shinytest to test. You would update
that file by coding new UI interactions directly.

### Using `shinytest2::record_test()` to generate testing code

If you’re not sure how to code new UI interactions directly, run
[`shinytest2::record_test()`](https://rstudio.github.io/shinytest2/reference/record_test.html)
to test the app interactively and record your actions, which can then be
copied into test scripts.

### Using `shiny::exportTestValues(name = value)`

Throughout the app code,
[`shiny::exportTestValues()`](https://rdrr.io/pkg/shiny/man/exportTestValues.html)
can be used to expose values from reactive expressions or other *items
that are not inputs or outputs*. The shinytest2 code can then read those
exported values with `app$get_values(export = TRUE)` or wait for them
with `app$wait_for_value(export = "name")`. EJAM uses this pattern for
stable checks such as `analysis_complete` and
`multisite_report_download_ready`. See details in
`shinytest2_webapp_functionality()` as defined in the `/tests/testthat/`
folder.

## Running Tests Locally

One way to run the shinytests is via the GitHub Actions.

Another way is this:

``` r

x = EJAM:::test_ejam(ask=F, run_these="webapp")
```

That path uses the combined web app test file, so the Shiny app is
launched once for the full functionality suite instead of once per
category.

You can also run a test directly in an interactive R session. This is
useful for debugging one category at a time.

``` r

remotes::install_local() # once
library(EJAM) # once
source(testthat::test_path("setup.R")) # once. gets done automatically though, by things like testthat::test_file()

# run a single test:
Sys.setenv(EJAM_SHINYTEST2_INDIVIDUAL = "true")
shinytest2_webapp_functionality("latlon")
```

It is recommended during development to use
[`remotes::install_local()`](https://remotes.r-lib.org/reference/install_local.html)
to ensure your development code is the one tested. The web app tests
launch the app in a separate R process, so by default they use the
installed EJAM package. This is much faster than reloading the source
tree for every web app test file.

If you specifically need the spawned Shiny app process to use the
current source tree without reinstalling, set this environment variable
before running the tests:

``` r

Sys.setenv(EJAM_SHINYTEST2_USE_SOURCE = "true")
```

For normal test runs, leave `EJAM_SHINYTEST2_USE_SOURCE` unset and
reinstall the package from local source first. If you need verbose Shiny
tracing or reactlog output while debugging a failure, set:

``` r

Sys.setenv(EJAM_SHINYTEST2_TRACE = "true")
```

Another useful way was this (but this might be deprecated by shinytest2)

``` r

# first, source `setup.R`, from the tests/testthat/ folder.
source(testthat::test_path("setup.R"))

# then for one subset of tests, like just the latlon analysis features:
Sys.setenv(EJAM_SHINYTEST2_INDIVIDUAL = "true")
shinytest2::test_app(".", filter="latlon-functionality", check_setup = FALSE)

# for all the webapp functionality tests
shinytest2::test_app(".", filter="all-functionality", check_setup = FALSE)
```

## GitHub Actions Integration

Using GitHub Actions (GHA) we can have GitHub run our shiny web app UI
tests prior to merging a Pull Request, to give us peace of mind that the
app will still work with the merged code.

### Workflow

- The GHA sets up R, installs dependencies, and runs scripted shinytest2
  tests.
- The workflow is stored in
  `.github/workflows/test-webapp-functionality.yaml`.
- PRs to a specified branch such as `development`, `main` can trigger
  GHA workflows (as specified in the workflow yml file).

### Speed Optimization

- If GHA takes too long, cache dependencies by temporarily disabling
  steps after setup.
- Keep slow checks centralized. For example, the `latlon` shinytest2
  test runs the broad report download, spreadsheet download, details
  table, and plot checks; other categories should focus on
  category-specific selection and analysis checks.
- Run the combined web app suite through
  `test-webapp-all-functionality.R` or
  `EJAM:::test_ejam(ask = FALSE, run_these = "webapp")`. The individual
  category files are mainly debugging entry points.
- Use the installed package by default for spawned Shiny app processes.
  Only set `EJAM_SHINYTEST2_USE_SOURCE=true` when you need to debug
  uninstalled source edits.
- Leave `EJAM_SHINYTEST2_TRACE` unset for routine test runs, because
  Shiny trace/reactlog output is mainly useful for debugging and can
  slow the app tests.

## Updating Expected Behavior Checks

Do not use
[`testthat::snapshot_accept()`](https://testthat.r-lib.org/reference/snapshot_accept.html)
for these shinytest2 tests. If a test fails, inspect whether the app
behavior changed in a meaningful way. If the behavior is still correct,
update the explicit assertion in `setup-shinytest2.R` so it checks a
stable fact instead of exact generated output.

Examples of stable checks include:

- an uploaded file input contains the expected filename
- a FIPS picker contains the expected selected FIPS code
- `analysis_complete` is `TRUE`
- a downloaded report exists, has an `.html` extension, is above a
  minimum size, and contains a few stable markers
- a downloaded spreadsheet exists, has an `.xlsx` extension, has the
  expected ZIP signature, and contains required sheet names
- a plot output has rendered an image with nonzero dimensions

## Debugging Tests & GitHub Actions

### Debugging shinytest2

- Use `save_log()` to inspect logs.
- Add [`print()`](https://rdrr.io/r/base/print.html),
  [`message()`](https://rdrr.io/r/base/message.html), or
  [`warning()`](https://rdrr.io/r/base/warning.html) statements in
  shinytest2_webapp_functionality().
- Run, line-by line or in chunks, the main shinytest code in
  shinytest2_webapp_functionality()

Then, after running lines or chunks, run `app$get_log()` to view the
log.

### Debugging GHA

Generally, if the shinytest2 tests pass locally using the same branch
and dependencies, GHA should pass. However, the tests can still fail due
to OS differences, browser availability, R version differences, package
differences, or timeouts. Here are some tips for debugging these issues:

- Inspect the log in the GitHub repo, under the Actions tab or the
  Checks tab of the PR.
- Inspect artifacts or logs after a failed run to identify whether the
  failure was an app behavior regression, browser startup problem,
  timeout, missing dependency, or assertion that is too brittle.

## Current State of Tests

- If the shinytests are failing, do not accept new snapshots. Inspect
  the failing assertion and decide whether app behavior regressed or the
  test should check a more stable fact.
- The versions of R and shiny and shinytest2 used for testing also
  should be noted as potentially affecting tests.

## Resources

[RStudio shinytest2
Documentation](https://rstudio.github.io/shinytest2/reference/AppDriver.html#method-AppDriver-expect_download)
