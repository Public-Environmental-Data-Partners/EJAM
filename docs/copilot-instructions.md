# Copilot Instructions for EJAM Repository

## Repository Overview

EJAM (Environmental Justice Analysis Multisite tool) is an R package
with Shiny web app for environmental justice analysis and proximity
assessment. Large repository: ~737MB, 621 R files, 618 man pages, 115MB
datasets.

**Tech Stack:** R (\>= 4.3.0), Golem Shiny framework, data.table, sf
(spatial), arrow **Key Directories:** `R/` (source), `data/` (.rda
files), `inst/` (configs), `tests/` (testthat + shinytest2), `man/`
(auto-generated), `.github/workflows/` (6 CI workflows)

## Critical Build Requirements

### System Dependencies (Ubuntu/Debian)

**ALWAYS install these system libraries before attempting package
installation:**

``` bash
sudo apt-get update
sudo apt-get install -y \
  libfontconfig1-dev \
  libudunits2-dev \
  libcairo2-dev \
  libcurl4-openssl-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  libjq-dev \
  libprotobuf-dev \
  protobuf-compiler
```

**macOS Dependencies:**

``` bash
brew update
brew install freetype udunits cairo harfbuzz fribidi libpng libtiff jpeg gdal pkg-config
```

### R Package Installation

**Installation from GitHub (recommended):**

``` r
install.packages("remotes")
remotes::install_github("ejanalysis/EJAM", dependencies = TRUE, force = TRUE)
```

**Installation from local source:**

``` r
remotes::install_local(".", force = TRUE, dependencies = TRUE)
```

**Important:** The package is NOT on CRAN. Always install from GitHub or
local source.

## Testing

### Unit Tests

**Running all tests:**

``` r
# Standard testthat approach
devtools::test()

# Using package-specific test function
EJAM:::test_ejam()
```

**Test configuration:** - Test framework: testthat (edition 3) -
Parallel testing: DISABLED (Config/testthat/parallel: false) - Tests
location: `tests/testthat/` - Special setup: `tests/testthat.R` installs
package before running tests - Web app tests: Use shinytest2 (see below)

**Important:** Unit tests use the INSTALLED version of the package, not
local source. If you make changes, you MUST reinstall the package before
tests will reflect those changes.

### Shiny App Tests (shinytest2)

**Running web app functionality tests:**

``` r
library(shinytest2)
library(EJAM)
source("tests/app-functionality.R")

# Run all web app tests
shinytest2::test_app(".", filter = "-functionality")

# Run specific tests
test_app(".", filter = "FIPS-shiny-functionality")
test_app(".", filter = "NAICS-shiny-functionality")
```

**Dependencies for shinytest2:**

``` r
webshot::install_phantomjs()  # Required for screenshots
```

## Linting

**Lintr is configured but runs in CI with continue-on-error: true**

To run lintr locally:

``` r
lintr::lint_dir(".")

# CI uses SARIF output
lintr::sarif_output(lintr::lint_dir("."), "lintr-results.sarif")
```

**Important:** Lintr violations won’t block PRs, but you should address
them when reasonable.

## Building Documentation

**Update documentation (roxygen2):**

``` r
devtools::document()
```

**Build pkgdown site:**

``` r
pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
```

**Important:** Documentation is automatically built and deployed to
GitHub Pages on pushes to main branch.

## Running the Shiny App

**Locally in RStudio:**

``` r
library(EJAM)
ejamapp()

# Or with custom settings
ejamapp(isPublic = TRUE)
```

**From app.R (for deployment):**

``` r
source("app.R")  # This will launch the app
```

**Important:** The app.R file is specifically designed for deployment to
Posit Connect/Shiny Server.

## GitHub Actions / CI Workflows

### On Pull Requests to main:

1.  **R CMD check** (`.github/workflows/check-standard.yaml`)
    - Runs on: macOS-latest (release), windows-latest (release),
      ubuntu-latest (devel, release, oldrel-1)
    - Builds package with: `--no-manual --compact-vignettes=gs+qpdf`
    - **Typical duration:** 10-20 minutes per OS
    - **Common failures:** Missing system dependencies, documentation
      errors
2.  **lintr** (`.github/workflows/lintr.yaml`)
    - Runs on: ubuntu-latest
    - continue-on-error: true (won’t fail builds)
    - Uploads SARIF results to GitHub Security tab
3.  **Test Installation - Comprehensive**
    (`.github/workflows/test-ability-to-install-all-situations.yaml`)
    - Tests matrix: ubuntu/windows/macOS × R 4.3/4.4/4.5/release ×
      install methods (github)
    - Verifies package installs and loads successfully
    - **Watch for:** macOS-specific issues with fortran compiler on
      older R versions
4.  **Test Shiny App Functionality**
    (`.github/workflows/test-shiny-web-app-functionality.yaml`)
    - Runs on: ubuntu-latest
    - Tests FIPS and NAICS functionality via shinytest2
    - Requires PhantomJS installation
    - **Typical duration:** 5-15 minutes
    - **Watch for:** Snapshot mismatches, timeout issues

### On Pushes to main:

5.  **pkgdown Documentation** (`.github/workflows/pkgdown.yaml`)
    - Builds and deploys documentation website to GitHub Pages
    - Deployed to: <https://ejanalysis.github.io/EJAM/>

### On Pushes to development:

6.  **Test Installation - Limited**
    (`.github/workflows/test-ability-to-install-limited-cases.yaml`)
    - Quick smoke test: ubuntu-latest + R 4.5 + github install method
      only

## Common Issues and Workarounds

### Common Failures and Solutions:

1.  **Package attachment fails (.onAttach errors):** Reinstall from
    source: `remotes::install_local(".", force = TRUE)` when new
    functions are referenced in global_defaults_package.R.
2.  **Tests don’t reflect code changes:** Tests use INSTALLED version.
    Always `remotes::install_local(".", force = TRUE)` before testing.
3.  **shinytest2 timeouts:** App init takes 2+ minutes. Use
    `load_timeout=2e+06` in tests.
4.  **“Cannot find file” in .onAttach():** Ensure
    `inst/global_defaults_package.R` exists when using
    [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html).
5.  **Slow builds/tests:** In `R/aaa_onAttach.R`, set
    `asap_download/asap_index/asap_bg <- FALSE` when iterating.
6.  **Ubuntu install fails:** Install ALL system libraries above.
    Missing one causes cryptic errors.
7.  **macOS jpeg errors:** Set environment variables:
    `PATH, LDFLAGS, CPPFLAGS, PKG_CONFIG_PATH` for
    `/opt/homebrew/opt/jpeg`.

## Key Files

**Root:** `DESCRIPTION` (metadata), `NAMESPACE` (auto-gen), `app.R`
(deployment entry), `Dockerfile`, `.Rbuildignore` **R/:**
`app_ui.R`/`app_server.R` (main app, 136KB server), `aaa_onAttach.R`
(init), `MODULE_*` (Shiny modules), `*_FUNCTIONS` (grouped functions)
**inst/:** `global_defaults_package.R` & `global_defaults_shiny.R`
(settings), `golem-config.yml`, `plumber/` (API), `report/` (templates)
**tests/:** `testthat.R` (runner), `app-functionality.R` (shinytest2
helpers), `testthat/test-*.R`, `_snaps/` (snapshots)

## Architecture

**Golem Framework:** Uses
[`app_ui()`](https://ejanalysis.github.io/EJAM/reference/app_ui.md)/[`app_server()`](https://ejanalysis.github.io/EJAM/reference/app_server.md),
launched via
[`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md).
Config in `inst/golem-config.yml`. **Data:** Lazy-loaded from data/.
Census block data downloaded on-demand from ejanalysis/ejamdata.
[`dataload_dynamic()`](https://ejanalysis.github.io/EJAM/reference/dataload_dynamic.md) +
[`indexblocks()`](https://ejanalysis.github.io/EJAM/reference/indexblocks.md)
for spatial indexes. **Naming:** `aaa_` prefix = load first, `MODULE_` =
Shiny modules, `_FUNCTIONS` = grouped functions. Don’t edit .Rd files
(auto-generated).

## Code Review Notes

**When reviewing PRs, ignore:** - Changes to .Rd files (auto-generated
documentation) - Changes to NAMESPACE (auto-generated by roxygen2) -
Changes to man/ directory (auto-generated) - Changes to docs/ folder
(auto-generated pkgdown site)

**Focus review on:** - R/ source files, including the .R files in the R
folder but also the .R files in the inst folder - Test files - Vignettes
if documentation changes - GitHub workflow changes - Configuration files
(DESCRIPTION, golem-config.yml, etc.)

**Avoid commenting on:** - Very minor issues, such as nitpicking - code
formatting issues

## Package Version Management

Version is tracked in multiple files and must be updated consistently: -
`DESCRIPTION` (primary source) - `NEWS.md` (changelog) - `_pkgdown.yml`
(documentation site) - `inst/golem-config.yml` - `CITATION.cff`

## Additional Resources

**Documentation:** <https://ejanalysis.github.io/EJAM/> **Code
Repository:** <https://github.com/ejanalysis/EJAM> **Data Repository:**
ejanalysis/ejamdata (referenced in DESCRIPTION)

## Trust These Instructions

These instructions have been carefully validated. Only search for
additional information if: 1. These instructions are incomplete for your
specific task 2. You encounter an error not covered here 3. You need
details about a specific function’s implementation

For most development tasks, following these instructions should allow
you to work efficiently without extensive exploration.
