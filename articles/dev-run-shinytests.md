# Testing EJAM App with shinytest2

This document covers the UI-related automated tests.

## NOTE on work in progress

This package had been using
[`shinytest2::test_app()`](https://rstudio.github.io/shinytest2/reference/test_app.html)
in the file `tests/testthat.R`, but that approach was deprecated, per
this note in the source code of
[`shinytest2::test_app()`](https://rstudio.github.io/shinytest2/reference/test_app.html)
– “Calling
[`shinytest2::test_app()`](https://rstudio.github.io/shinytest2/reference/test_app.html)
within a {testthat} test has been deprecated in {shinytest2} v0.5.0.”

Instead, `EJAM:::test_ejam()` uses an approach that first sources
`testthat/setup.R` which sources `testthat/setup-shinytest2.R` which
defines `shinytest2_webapp_functionality()`, a function that contains
the steps tested in the web app, and then directly uses that function
from within test files like
`/tests/testthat/test-webapp-latlon-functionality.R` etc.

## Dev Environment

If you are successfully running the app, you should have all the
necessary packages, or at least those in Imports or Suggests of the
`DESCRIPTION` file – the diffviewer package is not there, e.g. Some
dev-related packages to note:

- **[shinytest2](https://rstudio.github.io/shinytest2/)** -
  [shinytest2](https://rstudio.github.io/shinytest2/) is the key R
  package helping to test shiny web app functionality

- **[diffviewer](https://diffviewer.r-lib.org)** -
  [diffviewer](https://diffviewer.r-lib.org) helps visually compare 2
  files

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

It runs the installed version of the app in a headless Chromium browser,
simulating user interactions and taking snapshots. These snapshots are
stored as JSON files with accompanying PNG images. If differences arise
from code updates, the test fails, indicating which files changed.

### Key Features:

- Compares `.json`, `.html`, `.xlsx` files to a baseline
- Snapshots include inputs, outputs, and exported values
- `.png` files provide visual confirmation (but do not cause test
  failures)
- Developers can update snapshots to set a new baseline

## EJAM’s shinytest2 Folder Structure

``` plaintext
tests/
  ├── testthat.R (was modified to launch the shinytest2 web app functionality tests, but see note above about phasing out shinytest2::test_app() )
  └── testthat/
      ├── setup-shinytest2.R
      ├── test-webapp-[DATA TYPE]-functionality.R (e.g. test-webapp-FIPS-functionality.R)
      └── _snaps/
          ├── [OS, e.g. linux]-[R Version, e.g. 4.5]/
          │   ├── FIPS-functionality/
          │   │   ├── .json, .png, .xlsx, .html files
          │   ├── latlon-functionality/
          │   │   ├── .json, .png, .xlsx, .html files
          │   ├── NAICS-functionality/
          │   │   ├── .json, .png, .xlsx, .html files
```

### File Descriptions

- **`testthat.R`** – It had been calling
  [`shinytest2::test_app()`](https://rstudio.github.io/shinytest2/reference/test_app.html)
  to run all tests, but see note above about phasing out
  shinytest2::test_app(). This file is work in progress – it may need
  more work for the shiny app testing to work correctly.
- **`testthat/setup-shinytest2.R`** – Loads `global.R` and app scripts
  into the testing environment. Does basic setup including defining
  shinytest2_webapp_functionality() which has a script of web app UI
  interactions to test, using the app to upload or select, and analyze,
  multiple data types (FIPS, shapefile, latlon, NAICS, etc.), and save
  results like reports or spreadsheets.
- **`testthat/test-webapp-[DATA TYPE]-functionality.R`** – Simple call
  to the main app functionality function, specifying the data type to
  test with.
- **`testthat/_snaps/`** – Stores snapshots categorized by OS, R
  version, and data type.
  - **`.json` files** – Capture app snapshots.
  - **`.png` files** – Screenshots (do not trigger failures).
  - **`.xlsx` & `.html` files** – Download files. Compared via content
    hashing to prevent false failures.

## Updating Tests

You may wish to modify the shinytest scripts, either to add new
interactions with the application or to modify existing ones, such as in
the case of an app component that can no longer be interacted with. Here
are some methods and tips for updating the shinytest script accordingly.

### Direct Updates

Modify `shinytest2_webapp_functionality()` in setup-shinytest2.R to add
new interactions with the app for the shinytest to test. You would
update that file by coding new UI interactions directly.

### Using `shinytest2::record_test()` to generate testing code

If you’re not sure how to code new UI interactions directly, run
[`shinytest2::record_test()`](https://rstudio.github.io/shinytest2/reference/record_test.html)
to test the app interactively and record your actions, which can then be
copied into test scripts.

### Using `shiny::exportTestValues(name = value)`

Throughout the app code,
[`shiny::exportTestValues()`](https://rdrr.io/pkg/shiny/man/exportTestValues.html)
can be used to store values from reactive expressions or other *items
that are not inputs or outputs* and therefore may not be included in the
standard snapshots. Then, in the shinytests, you can specify
`export=[name]` to include in the snapshot the export named “name” that
you specified in the code, or `export=TRUE` to include all exports. But,
see details in the source code of shinytest2_webapp_functionality() as
defined in the /tests/testthat/ folder.

## Running Tests Locally

One way to run the shinytests is via the GitHub Actions.

Another way is this:

``` r
x = EJAM:::test_ejam(ask=F, run_these="webapp")
```

You could also run a test like this, but you cannot save or compare
snapshots to reference when testing interactively.

``` r
remotes::install_local() # once
library(EJAM) # once
source(testthat::test_path("setup.R")) # once

# run a single test:
shinytest2_webapp_functionality("latlon")
```

It is recommended during development to use
[`remotes::install_local()`](https://remotes.r-lib.org/reference/install_local.html)  
to ensure your development code is the one tested. This is because
shinytest2 automatically references the installed version of a package.

Another useful way was this (but this might be deprecated by shinytest2)

``` r
# first, source `setup.R`, from the tests/testthat/ folder. 
source(testthat::test_path("setup.R"))

# then for one subset of tests, like just the latlon analysis features:
shinytest2::test_app(".", filter="latlon-functionality", check_setup = FALSE)

# for all the webapp functionality tests
shinytest2::test_app(".", filter="-functionality", check_setup = FALSE)
```

## GitHub Actions Integration

Using GitHub Actions (GHA) we can have GitHub run our shiny web app UI
tests prior to merging a Pull Request, to give us peace of mind that the
app will still work with the merged code.

### Workflow

- The GHA sets up R, installs dependencies, runs tests, and compares
  snapshots.
- The workflow is stored in
  `.github/workflows/test-webapp-functionality.yml`.
- PRs to a specified branch such as `development`, `main` can trigger
  GHA workflows (as specified in the workflow yml file).

### Speed Optimization

- If GHA takes too long, cache dependencies by temporarily disabling
  steps after setup.
- If snapshots fail, merge the base branch into the feature branch
  before updating snapshots.

## Reviewing & Updating Snapshots (Saved Results of Testing)

### Reviewing Snapshots

``` r
testthat::snapshot_review()
```

Optionally, can filter to review specific files or folders of snapshots.

### Accepting New Snapshots

``` r
testthat::snapshot_accept()
```

Optionally, can accept them interactively when reviewing.

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

Generally, if you test locally and update snapshots accordingly, GHA
should pass. However, the tests do sometimes fail due to OS differences,
R version differences, or even package differences. Here are some tips
for debugging these issues:

- Inspect the log in the GitHub repo, under the Actions tab or the
  Checks tab of the PR.
- Inspect artifacts (zipped test outputs) after a failed run and compare
  snapshots in a diff viewer to identify discrepancies.

## Current State of Tests

- If the shinytests are failing, it is likely because snapshots have not
  been updated locally and pushed after recent changes.
- The versions of R and shiny and shinytest2 used for testing also
  should be noted as potentially affecting tests.

## Resources

[RStudio shinytest2
Documentation](https://rstudio.github.io/shinytest2/reference/AppDriver.html#method-AppDriver-expect_download)
