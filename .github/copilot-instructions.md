# Copilot Instructions for EJAM Repository

## Repository Overview

EJAM (Environmental Justice Analysis Multisite tool) is an R package with an integrated Shiny web application. It allows users to quickly summarize demographic and environmental indicators for residents in or near hundreds or thousands of areas or sites simultaneously. The package provides tools for proximity analysis, environmental justice assessment, and data visualization.

**Key Technologies:**
- **Language:** R (requires R >= 4.3.0)
- **Type:** R Package with Golem-based Shiny Web Application
- **Primary Frameworks:** Shiny, Golem, data.table, sf (spatial data), arrow (data storage)
- **Size:** Large repository (~737MB, 3100+ files, 621 R files, 618 man pages)
- **Data:** Large datasets (~115MB in data/ directory) stored as .rda files

**Repository Structure:**
- `R/` - 621 R source files containing functions and Shiny modules
- `data/` - 115MB of pre-compiled datasets (.rda format) including blockgroupstats (76MB)
- `inst/` - Installation files including global defaults, Plumber API, and report templates
- `man/` - 618 roxygen2-generated documentation files (.Rd format)
- `tests/` - Unit tests (testthat) and Shiny app functionality tests (shinytest2)
- `vignettes/` - Comprehensive documentation articles
- `.github/workflows/` - 6 GitHub Actions workflows for CI/CD

## Critical Build Requirements

### System Dependencies (Ubuntu/Debian)

**ALWAYS install these system libraries before attempting package installation:**

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

**Installation from GitHub (recommended):**
```r
install.packages("remotes")
remotes::install_github("ejanalysis/EJAM", dependencies = TRUE, force = TRUE)
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

**Important:** Unit tests use the INSTALLED version of the package, not local source. If you make changes, you MUST reinstall the package before tests will reflect those changes.

### Shiny App Tests (shinytest2)

**Running web app functionality tests:**
```r
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
```r
webshot::install_phantomjs()  # Required for screenshots
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

**Update documentation (roxygen2):**
```r
devtools::document()
```

**Build pkgdown site:**
```r
pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
```

**Important:** Documentation is automatically built and deployed to GitHub Pages on pushes to main branch.

## Running the Shiny App

**Locally in RStudio:**
```r
library(EJAM)
ejamapp()

# Or with custom settings
ejamapp(isPublic = TRUE)
```

**From app.R (for deployment):**
```r
source("app.R")  # This will launch the app
```

**Important:** The app.R file is specifically designed for deployment to Posit Connect/Shiny Server.

## GitHub Actions / CI Workflows

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

### Issue: Package attachment during .onAttach() fails
**Symptoms:** Errors about global_defaults_package.R not found during `library(EJAM)`
**Solution:** Reinstall package from source. This happens when new functions are referenced in global_defaults_package.R before package is fully built.

### Issue: Tests fail because of old installed version
**Symptoms:** Tests don't reflect recent code changes
**Solution:** Always run `remotes::install_local(".", force = TRUE)` before running tests. Tests use the INSTALLED version, not source code.

### Issue: shinytest2 tests timeout
**Symptoms:** Tests hang or timeout during app interaction
**Solution:** Increase timeout values in test files. App initialization can take 2+ minutes due to data loading. Current default: `load_timeout=2e+06`.

### Issue: "Cannot find file" errors in .onAttach()
**Symptoms:** Package loads but complains about missing files during startup
**Solution:** Check that `inst/global_defaults_package.R` exists. If using `devtools::load_all()`, this file must be in `inst/` directory.

### Issue: Large data files cause slow tests/builds
**Symptoms:** Package build or test runs take very long
**Solution:** In `R/aaa_onAttach.R`, set flags: `asap_download <- FALSE`, `asap_index <- FALSE`, `asap_bg <- FALSE` when iterating on code.

### Issue: Missing system dependencies on Ubuntu
**Symptoms:** Installation fails with compiler errors about missing libraries
**Solution:** Install ALL system libraries listed in "System Dependencies" section above. Missing even one can cause cryptic errors.

### Issue: macOS jpeg library not found
**Symptoms:** Installation fails with jpeg-related errors on macOS
**Solution:** Set environment variables after installing jpeg:
```bash
export PATH="/opt/homebrew/opt/jpeg/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig"
```

## Key Files and Their Purposes

### Root Directory Files:
- `DESCRIPTION` - Package metadata, dependencies, version
- `NAMESPACE` - Auto-generated by roxygen2 (600+ exports)
- `app.R` - Entry point for deployed Shiny app
- `Dockerfile` - Container definition for deployment
- `.Rbuildignore` - Excludes docs/, pkgdown/, .github/, data-raw/ from package build

### R/ Directory Key Files:
- `EJAM-package.R` - Package-level documentation
- `app_ui.R` / `app_server.R` - Main Shiny app UI and server logic (136KB server!)
- `app_run_EJAMejscreenapi.R` - Alternative app entry point for EJSCREEN API version
- `aaa_onAttach.R` - Package initialization (downloads data, builds indexes)
- Files prefixed with `MODULE_` - Shiny modules for modular UI components
- Files with `_FUNCTIONS` suffix - Grouped related functions (FIPS, NAICS, proximity, etc.)

### inst/ Directory:
- `inst/global_defaults_package.R` - Package-level default settings
- `inst/global_defaults_shiny.R` - Shiny app default settings (90KB!)
- `inst/golem-config.yml` - Golem framework configuration
- `inst/plumber/` - API endpoint definitions (Plumber)
- `inst/report/` - HTML report templates

### tests/ Directory:
- `tests/testthat.R` - Main test runner (installs package before running tests)
- `tests/app-functionality.R` - Helper functions for shinytest2
- `tests/testthat/test-*.R` - Individual unit test files
- `tests/testthat/_snaps/` - Snapshot files for shinytest2

## Architecture Notes

**Golem Framework:** This package uses the Golem framework for Shiny app development. Golem conventions:
- `app_ui()` and `app_server()` are the main app components
- `run_app()` or `ejamapp()` launches the app
- Configuration in `inst/golem-config.yml`
- Options passed via `golem::get_golem_options()`

**Data Loading Strategy:**
- Large datasets are lazy-loaded from data/ directory
- Block-level data can be downloaded on-demand from external repository (ejanalysis/ejamdata)
- `dataload_dynamic()` handles dynamic data loading
- `indexblocks()` creates spatial indexes for fast proximity queries

**Naming Conventions:**
- Files with `aaa_` prefix load first (e.g., `aaa_onAttach.R`)
- MODULE_ prefix indicates Shiny modules
- _FUNCTIONS suffix indicates grouped functions by domain
- .Rd files in man/ are auto-generated by roxygen2 - DO NOT EDIT MANUALLY

## Code Review Notes

**When reviewing PRs, ignore:**
- Changes to .Rd files (auto-generated documentation)
- Changes to NAMESPACE (auto-generated by roxygen2)
- Changes to man/ directory (auto-generated)
- Changes to docs/ folder (auto-generated pkgdown site)

**Focus review on:**
- R/ source files
- Test files
- Vignettes if documentation changes
- GitHub workflow changes
- Configuration files (DESCRIPTION, golem-config.yml, etc.)

## Package Version Management

Version is tracked in multiple files and must be updated consistently:
- `DESCRIPTION` (primary source)
- `NEWS.md` (changelog)
- `_pkgdown.yml` (documentation site)
- `inst/golem-config.yml`
- `CITATION.cff`

## Additional Resources

**Documentation:** https://ejanalysis.github.io/EJAM/
**Code Repository:** https://github.com/ejanalysis/EJAM
**Data Repository:** ejanalysis/ejamdata (referenced in DESCRIPTION)

## Trust These Instructions

These instructions have been carefully validated. Only search for additional information if:
1. These instructions are incomplete for your specific task
2. You encounter an error not covered here
3. You need details about a specific function's implementation

For most development tasks, following these instructions should allow you to work efficiently without extensive exploration.
