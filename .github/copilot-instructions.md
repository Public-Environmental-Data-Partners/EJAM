# Copilot Instructions for EJAM Repository

## Repository Overview

EJAM (Environmental Justice Analysis Multisite tool) is an R package with Shiny web app for environmental justice analysis and proximity assessment. 
Large repository: Can be roughly ~737MB, 621 R files, 618 man pages, 115MB datasets. However, several very large .arrow data files are used by the package but not part of the bundle that gets downloaded to be installed.

**Tech Stack:** See the DESCRIPTION file for a list of dependencies, such as these: R (>= 4.3.0), Golem Shiny framework, data.table, sf (spatial), arrow
**Key Directories:** `R/` (source), `data/` (.rda files), `inst/` (configs), `tests/` (testthat + shinytest2), `man/` (auto-generated), `.github/workflows/` (has CI workflows)

## Critical Build Requirements

### System Dependencies (Ubuntu/Debian)

**On linux/Ubuntu/Debian, ALWAYS install these system libraries before attempting package installation:**

```bash
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
```bash
brew update
brew install freetype udunits cairo harfbuzz fribidi libpng libtiff jpeg gdal pkg-config
```

### R Package Installation

See installation details in `vignettes/installing.Rmd`

**Installation from GitHub:**
```r
install.packages("remotes")
# NOTE: replace "REPO_OWNER" with the actual github repo owner (see DESCRIPTION file)
remotes::install_github("REPO_OWNER/EJAM", dependencies = TRUE, force = TRUE)
```

**Installation from local source:**
```r
remotes::install_local(".", force = TRUE, dependencies = TRUE)
```

**Important:** The package is NOT on CRAN. Always install from GitHub or local source.

## Testing

### Unit Tests

**Running all tests:**
```r
# Standard testthat approach
devtools::test()

# Using package-specific test function
EJAM:::test_ejam()
```

**Test configuration:**
- Test framework: testthat (edition 3)
- Parallel testing: DISABLED (Config/testthat/parallel: false)
- Tests location: `tests/testthat/`
- Special setup: `tests/testthat.R` installs package before running tests
- Web app tests: Use shinytest2 (see below)

**Important:** Unit tests started using devtools::test() may use the INSTALLED version of the package, not local source. If you make changes, you MUST reinstall the package before tests will reflect those changes.

### Shiny App Tests (shinytest2)

**Running web app functionality tests:**
```r
library(shinytest2)
library(EJAM)

# Run all web app tests
source("./tests/testthat.R")

# Run specific web app tests, for example:
test_app(".", filter = "FIPS-functionality") # maybe with , check_setup = FALSE
test_app(".", filter = "NAICS-functionality") 
```

**Dependencies for shinytest2:**
```r
# webshot::install_phantomjs()  # Required for screenshots
```

## Linting

**Lintr is configured but runs in CI with continue-on-error: true**

To run lintr locally:
```r
lintr::lint_dir(".")

# CI uses SARIF output
lintr::sarif_output(lintr::lint_dir("."), "lintr-results.sarif")
```

**Important:** Lintr violations won't block PRs, but you should address them when reasonable.

## Building Documentation

**Update just the .Rd files of documentation (roxygen2):**
```r
devtools::document()
```

**Build pkgdown site (which also updates the .Rd files of documentation):**
```r
EJAM:::pkgdown_update() # see documentation of this function for details

## or:
# pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
```

**Important:** Documentation is automatically built and deployed to GitHub Pages on pushes to main branch.

## Running the Shiny App

**Locally in RStudio:**
```r
library(EJAM)
ejamapp()

# Or with custom settings (as explained in `vignettes/dev-app-settings.Rmd`)
ejamapp(isPublic = TRUE)
```

**On a server once deployed:**
```r
# one option is this:
source("app.R")

# another option is this:
library(EJAM)
ejamapp(isPublic=TRUE)
```

## GitHub Actions / CI Workflows

The notes below might need to be updated every time the github workflow actions have been updated via edits to the .yaml files in the .github/workflows folder.

### On Pull Requests to main:

1. **R CMD check** (`.github/workflows/check-standard.yaml`)
   - Runs on: macOS-latest (release), windows-latest (release), ubuntu-latest (devel, release, oldrel-1)
   - Builds package with: `--no-manual --compact-vignettes=gs+qpdf`
   - **Typical duration:** 10-20 minutes per OS
   - **Common failures:** Missing system dependencies, documentation errors

2. **lintr** (`.github/workflows/lintr.yaml`)
   - Runs on: ubuntu-latest
   - continue-on-error: true (won't fail builds)
   - Uploads SARIF results to GitHub Security tab

3. **Test Installation - Comprehensive** (`.github/workflows/test-ability-to-install-all-situations.yaml`)
   - Tests matrix: ubuntu/windows/macOS × R 4.3/4.4/4.5/release × install methods (github)
   - Verifies package installs and loads successfully
   - **Watch for:** macOS-specific issues with fortran compiler on older R versions

4. **Test Shiny App Functionality** (`.github/workflows/test-shiny-web-app-functionality.yaml`)
   - Runs on: ubuntu-latest
   - Tests FIPS and NAICS functionality via shinytest2
   - Requires PhantomJS installation
   - **Typical duration:** 5-15 minutes
   - **Watch for:** Snapshot mismatches, timeout issues

### On Pushes to main:

5. **pkgdown Documentation** (`.github/workflows/pkgdown.yaml`)
   - Builds and deploys documentation website to GitHub Pages
   - Deployed to: https://ejanalysis.github.io/EJAM/

### On Pushes to development:

6. **Test Installation - Limited** (`.github/workflows/test-ability-to-install-limited-cases.yaml`)
   - Quick smoke test: ubuntu-latest + R 4.5 + github install method only


## Common Issues and Workarounds

### Common Failures and Solutions:

1. **Package attachment fails (.onAttach errors):** Reinstall from source: `remotes::install_local(".", force = TRUE)` when new functions are referenced in global_defaults_package.R.
2. **Tests don't reflect code changes:** Tests use INSTALLED version. Always `remotes::install_local(".", force = TRUE)` before testing, or do unit testing via the utility function `test_ejam()` and see more about testing in the vignette at vignettes/dev-run-unit-tests.Rmd and vignettes/dev-run-shinytests.Rmd
3. **shinytest2 timeouts:** App init might take 2+ minutes. Use `load_timeout=2e+06` in tests.
4. **"Cannot find file" in .onAttach():** Ensure `inst/global_defaults_package.R` exists when using `devtools::load_all()`.
5. **Slow builds/tests:** In `R/aaa_onAttach.R`, set `asap_download <- asap_index <- asap_bg <- FALSE` when iterating.
6. **Ubuntu install fails:** Install ALL system libraries above. Missing one causes cryptic errors.
7. **macOS jpeg errors:** Set environment variables: `PATH, LDFLAGS, CPPFLAGS, PKG_CONFIG_PATH` for `/opt/homebrew/opt/jpeg`.

## Key Files

**Root:** `DESCRIPTION` (metadata), `NAMESPACE` (auto-gen), `app.R` (deployment entry), `Dockerfile`, `.Rbuildignore`
**R/:** `app_ui.R`/`app_server.R` (main app, 136KB server), `aaa_onAttach.R` (init), `MODULE_*` (Shiny modules), `*_FUNCTIONS` (grouped functions)
**inst/:** `global_defaults_package.R` & `global_defaults_shiny.R` (settings), `golem-config.yml`, `plumber/` (API), `report/` (templates)
**tests/:** `testthat.R` (runner), `app-functionality.R` (shinytest2 helpers), `testthat/test-*.R`, `_snaps/` (snapshots)

## Architecture

**Golem Framework:** Uses `app_ui()`/`app_server()`, launched via `ejamapp()`. Config in `inst/golem-config.yml`.
**Data:** 
  - Some is lazy-loaded from data/ 
  - Some is saved in the data folder upon package installation because some large data files must be downloaded from the ejamdata repository. This is explained in the file vignettes/dev-update-datasets.Rmd
  - Some is loaded via `dataload_dynamic()` and some is in .arrow format instead of .rda format.
**Naming:** 
  - Closely-related R functions are often grouped within a single .R file in the R folder, especially if the filename includes the phrase "_FUNCTIONS" such as in "PROXIMITY_FUNCTIONS.R"
  - Closely-related R functions often share a common prefix such as "fips_" or "frs_" or "ejamit" or "ejam2" or "calc_" or "latlon" or "plot" or "table_" or "url_" or "shape" or "state_" or "popup_" or "get"
  - Some utilities are in .R files that start with "utils_"
  - All or almost all datasets should be documented in .R files that have a filename that starts with "data_"
  - Many datasets were created for the package using scripts in the data-raw folder, usually with a file whose name starts with "datacreate_"
  - Some other naming conventions are these: `aaa_` prefix = load first, `MODULE_` = Shiny modules, `_FUNCTIONS` = grouped functions. Don't edit .Rd files (auto-generated).

## Code Review Notes

**When reviewing PRs, ignore:**
- Changes to NAMESPACE (auto-generated by roxygen2)
- Changes to files in the man/ directory (auto-generated by roxygen2)
- Changes to .Rd files (auto-generated documentation created by by roxygen2)
- Changes to files in the docs/ folders (auto-generated pkgdown site)
- Changes to files under the tests/testthat/_snaps/ folder (snapshots created by the shinytest2 package testing web app functionality)

**Focus review on:**
- R/ source files, including the .R files in the R folder but also the .R files in the inst folder
- Test files in the folders under tests/
- Vignettes that are .Rmd files in the vignettes/ folder
- GitHub workflow changes
- Configuration files (DESCRIPTION, golem-config.yml, global_defaults* , etc.)

**Avoid commenting on:**
- Very minor issues, such as nitpicking
- Minor code formatting issues

## Package Version Management

Version is tracked in multiple files and must be updated consistently:
- `DESCRIPTION` (primary source)
- `NEWS.md` (changelog)
- `_pkgdown.yml` (documentation site)
- `inst/golem-config.yml`
- `CITATION.cff`

## Additional Resources

**Documentation:** See the DESCRIPTION file URL field for the github.io documentation URL. Also can be obtained via EJAM::url_package("docs", get_full_url = T) - Also, https://ejanalysis.com/docs redirects to the package documentation site. However that URL is for a set of pages that document the main branch or latest release, and does not necessarily document the most recent source version or any other branch such as the development branch.
  The more recent documentation is in roxygen2 tags within the .R files for a given branch, which are converted to .Rd files in the man folder (via document()), and eventually may be converted to .html files in the docs folder via pkgdown_update()
**Code Repository:** See the DESCRIPTION file URL field for the github.com R package code URL. Also can be obtained via EJAM::url_package("code", get_full_url = T)
**Data Repository:** See the DESCRIPTION file ejam_data_repo field for the github.com datasets URL. Also can be obtained via EJAM::url_package("data", get_full_url = T)

## Trust These Instructions

These instructions have been carefully validated except where they explicitly mention the latest updates or need for updates. Only search for additional information if:
1. These instructions are incomplete for your specific task - In that case, see additional resources mentioned above, or any of the .Rmd files in the vignettes folder.
2. You encounter an error not covered here - In that case, first try to resolve it using documentation of relevant R packages, and if that still is not sufficient to have a clear answer, 
  then look for mentions of the error or problem and solutions to the issue as posted in key resources starting with sources such as stackexchange, stackoverflow, R-specific discussion groups, support for posit or shiny or other specific software that is clearly relevant to the problem.
3. You need details about a specific function's implementation - In that case, see additional resources noted above for more documentation of specific functions or datasets.

For most development tasks, following these instructions should allow you to work efficiently without extensive exploration.
