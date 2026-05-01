# Copilot Instructions for EJAM Repository

## Repository Overview

EJAM (Environmental Justice Analysis Multisite tool) is an R package with Shiny web app for environmental justice analysis and proximity assessment.
Large repository: Can be roughly ~737MB, 621 R files, 618 man pages, 115MB datasets. However, several very large .arrow data files are used by the package but not part of the bundle that gets downloaded to be installed.

**Tech Stack:** See the DESCRIPTION file for a list of dependencies, such as these: R with a specific version specified, Golem Shiny framework, data.table, sf (spatial), arrow

**Key Directories:**
- Root directory of package (which has several key files like DESCRIPTION, NEWS.md, README.Rmd, etc.)
- `R/` (source)
- `data/` (.rda files lazy-loaded by the package when it is loaded, plus .arrow format datasets saved their upon first install or when datasets are updated on the dataset repo, and "ejamdata_version.txt" with metadata on what is the latest version of certain large datasets)
- `data-raw/` (scripts for updating the datasets)
- `inst/` (configs prefixed with "global_", "testdata" folder with examples of data for testing, "report" folder related to templates and creating html report of results, etc.)
- `tests/` (unit testing via testthat + shinytest2)
- `.github/workflows/` (has CI github actions workflows)
- `man/` (auto-generated documentation)


## Critical Build Requirements

### System Dependencies (Ubuntu/Debian)

**On linux/Ubuntu/Debian, ALWAYS install these system libraries before attempting package installation:**
NOTE THIS LIST MAY NEED TO BE EDITED FROM TIME TO TIME, AS THE REQUIRED R PACKAGES GET UPDATED AND CREATE CHANGING DEPENDENCIES, FOR EXAMPLE!
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
NOTE THIS LIST MAY NEED TO BE EDITED FROM TIME TO TIME, AS THE REQUIRED R PACKAGES GET UPDATED AND CREATE CHANGING DEPENDENCIES, FOR EXAMPLE!
```bash
brew update
brew install freetype udunits cairo harfbuzz fribidi libpng libtiff jpeg gdal pkg-config
```

### R Package Installation

- See installation instructions and notes in `vignettes/installing.Rmd`
- Note the key R packages and R version dependencies listed in the `DESCRIPTION` file.
- **Important:** The package is NOT on CRAN. Always install from GitHub or local source.


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
shinytest2::test_app(".", filter = "functionality", check_setup = FALSE)
#or
EJAM:::test_ejam(ask=F,run_these="webapp")

# Run specific web app tests, for example:
shinytest2::test_app(".", filter = "FIPS-functionality", check_setup = FALSE)
shinytest2::test_app(".", filter = "NAICS-functionality", check_setup = FALSE)
```

**Dependencies for shinytest2:**
```r
# webshot::install_phantomjs()  # Required for screenshots
# also needs pandoc probably
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
# See the existing github actions workflow(s) related to build/deploy or just deploying the pkgdown website.
```

## Running the Shiny App

**Running the app locally in RStudio:**
```r
library(EJAM)
ejamapp()

# Or with custom settings (as explained in `vignettes/dev-app-settings.Rmd`),
# especially the setting isPublic=TRUE that should be used for debugging or testing
ejamapp(isPublic = TRUE)
```

**Running the app on a server once deployed:**
```r
# one option is this:
source("app.R")

# another option is this:
library(EJAM)
ejamapp(isPublic=TRUE)
```

**Live web app**
- The app has been hosted at the site pointed to by https://ejanalysis.com/ejamapp
- Note the version of the EJAM package used there may differ from the latest release sometimes, for some time after the release.

**API: Example of live hosted EJAM API that is not the same as the API drafted in the plumber folder of this package**
- There is an EJAM API hosted at the site pointed to by https://ejanalysis.com/ejamapi  and/or (if different) at https://ejamapi-84652557241.us-central1.run.app/
- Note the version of the EJAM package used there may differ from the latest release sometimes, for some time after the release.
- Also, the code for that API is at https://github.com/Public-Environmental-Data-Partners/EJAM-API

## GitHub Actions / CI Workflows

- Some of the github action workflows for this package might be disabled at any given time, because they are being debugged still or because they are time-consuming and non-essential, for example.
- See the main branch's folder .github/workflows which has the .yaml files.
- See the repository to check which are currently enabled.


## Common Issues and Workarounds

### Common Failures and Solutions:

1. **Package attachment fails (.onAttach errors):** Reinstall from source: `remotes::install_local(".", force = TRUE)` when new functions are referenced in global_defaults_package.R.
2. **Tests don't reflect code changes:** Be sure to know whether tests use latest local source in the checked out branch versus the INSTALLED version which may be different. It is safest to always do `remotes::install_local(".", force = TRUE)` before testing, or do unit testing via the utility function `test_ejam()` and see more about testing in the vignette at vignettes/dev-run-unit-tests.Rmd and vignettes/dev-run-shinytests.Rmd
3. **shinytest2 timeouts:** App init might take 2+ minutes. Use `load_timeout=2e+06` in tests.
4. **"Cannot find file" in .onAttach():** Ensure `inst/global_defaults_package.R` exists when using `devtools::load_all()`.
5. **Slow builds/tests:** In `R/aaa_onAttach.R`, set `asap_download <- asap_index <- asap_bg <- FALSE` when iterating. That might help somewhat.
6. **Ubuntu install fails:** Install ALL system libraries above. Missing one causes cryptic errors.
7. **macOS jpeg errors:** Set environment variables: `PATH, LDFLAGS, CPPFLAGS, PKG_CONFIG_PATH` for `/opt/homebrew/opt/jpeg`.
8. **Cannot find datasets normally loaded via dataload_dynamic() and related functions:** See the vignettes/dev-update-datasets.Rmd about updating datasets where they explain where arrow and rda dataset files are stored.

## Key Files

**Root:** `DESCRIPTION` (metadata), `NAMESPACE` (auto-gen), `app.R` (deployment entry), `Dockerfile`, `.Rbuildignore`
**R/:** `app_ui.R`/`app_server.R` (key code for the web app), `aaa_onAttach.R` (init), `MODULE_*` (Shiny modules), `*_FUNCTIONS` (grouped functions)
**inst/:** `global_defaults_package.R` & `global_defaults_shiny.R` (settings), `golem-config.yml`, `plumber/` (API), `report/` (templates)
**tests/:**  `testthat/test-*.R`, `test_ejam.R` (utility for interactively running groups of unit tests), `setup.R`, `setup-shinytest2.R` (shinytest2 testing of webapp functionality)

## Architecture

**Golem Framework:** Uses `app_ui()`/`app_server()`, best launched via `ejamapp()`. Config in `inst/golem-config.yml`.
**Data:**
  - Some is lazy-loaded from data/
  - Some is saved in the data folder upon package installation because some large data files must be downloaded from the ejamdata repository. This is explained in the file vignettes/dev-update-datasets.Rmd
  - Some is loaded via `dataload_dynamic()` and some is obtained and used in .arrow format instead of .rda format in some parts of the app.
**Naming:**
  - Closely-related R functions are often grouped within a single .R file in the R folder, especially if the filename includes the phrase "_FUNCTIONS" such as in "PROXIMITY_FUNCTIONS.R"
  - Closely-related R functions often share a common prefix such as "fips_" or "frs_" or "ejamit" or "ejam2" or "calc_" or "latlon" or "plot" or "table_" or "url_" or "shape" or "state_" or "popup_" or "get"
  - Some utilities are in .R files that start with "utils_"
  - All or almost all datasets should be documented in .R files that have a filename that starts with "data_"
  - Many datasets were created for the package using scripts in the data-raw folder, usually with a file whose name starts with "datacreate_"
  - Some other naming conventions are these: `aaa_` prefix = load first, `MODULE_` = Shiny modules, `_FUNCTIONS` = grouped functions. Don't edit .Rd files (auto-generated).

## Code Review Notes

**When reviewing PRs, completely ignore:**
- Changes to files in the docs/ folders (auto-generated pkgdown site)

**Focus review on:**
- R/ source files, especially the .R files in the R folder
- Configuration files (DESCRIPTION, golem-config.yml, global_defaults* , etc.)
- Test files in the folders under tests/
- data-raw/ and subfolders, especially datacreate_*.R
- Vignettes that are .Rmd files in the vignettes/ folder
- inst/ and subfolders
- GitHub workflow changes in .github/workflows

**When reviewing PRs, mostly ignore or put a very low priority on reviewing these:**
- Changes to .Rd files in the man/ directory, and other files in the man/ directory (since they should be auto-generated by roxygen2)
- Also low priority for review are *.js,*.json,*.html outside the docs folder.
- Also low priority for review are files in the pkgdown folder
- Also low priority for review are files in the pkgdown folder
- Also low priority for review are files in the pkgdown folder

**Avoid commenting on, unless asked to do a final check for any other issues after all the significant things have been reviewed:**
- Very minor issues that are nitpicking
- Very minor issues that involve very rare or very unlikely cases
- Very minor issues that are matters of preference
- Non-critical issues related to code formatting


## Package Version Management

Version of package and versions of critical data sources like ACS are tracked in multiple files and must be updated consistently:
- `DESCRIPTION` (primary source)
- `NEWS.md` (changelog)
- `_pkgdown.yml` (documentation site)
- `inst/golem-config.yml`
- `CITATION.cff`

## Additional Resources

**General context information about the EJAM package and EJAM web app and EJScreen, especially their uses, their ongoing development, and their key URLs:**
- See https://ejanalysis.com and https://ejanalysis.com/status for an initial, short, broad overview explaining what are EJSCREEN and EJAM, and status of their recent and ongoing development.
- See https://screening-tools.com for the recent history and broad context of this work and related efforts to preserve tools and data, and organizations involved in continued development.
- See https://public-environmental-data-partners.github.io/EJAM/articles/whatis.html for an article providing an overview of what the EJAM package and EJAM web app are.
- See https://ejanalysis.com/ejam-code for key URLs for relevant repositories and documentation.

**Documentation:** See the DESCRIPTION file URL field for the github.io documentation URL. That URL also can be obtained via EJAM::url_package("docs", get_full_url = T) - Also, https://ejanalysis.com/docs redirects to the package documentation site. However that URL is for a set of pages that document the main branch or latest release, and does not necessarily document the most recent source version or any other branch such as the development branch.
  However, it is important to note that the most recent documentation for a given branch is in roxygen2 tags within the .R files in the given branch. Periodically those are converted to .Rd files in the man folder (via document()), and eventually may be converted to .html files in the docs folder via pkgdown_update()

**Code Repository:** See the DESCRIPTION file URL field for the github.com R package code URL. That URL also can be obtained via EJAM::url_package("code", get_full_url = T)

**Data Repository:** See the DESCRIPTION file ejam_data_repo field for the github.com datasets URL. That URL also can be obtained via EJAM::url_package("data", get_full_url = T)
And note it might be useful to look at the live web app and/or the hosted API, both of which are mentioned above.

## Trust These Instructions

These instructions have been carefully validated (at least as of May 1, 2026),
except where they explicitly mention the latest updates or need for updates.

For most development tasks, following these instructions should allow you to work efficiently without extensive exploration outside this package or repository.

Only search for additional information if:

1. These instructions are incomplete for your specific task, or they are unlikely to be sufficient to provide a high-confidence, accurate, clear, complete answer -
  In that case, see additional resources mentioned above, including any of the .Rmd files in the vignettes folder.
2. You encounter an error or question or issue or topic not covered by the resources and information here - In that case,
  first try to resolve it using your knowledge plus the documentation of relevant R packages,
  and if that is unlikely to be sufficient to provide a high-confidence, accurate, clear, complete answer,
  then look for mentions of the error or problem or topic and solutions to the issue as posted in key resources starting with sources
  such as Posit-specific and R-specific discussion groups, stackexchange, stackoverflow,
  other support pages for Posit or the R shiny package, and
  finally, if useful, look at information relevant to any other specific software that is clearly relevant to the problem or question or issue or topic.
3. You need more details about a specific function's implementation - In that case, see any additional resources noted above for more documentation of specific functions or datasets.
  If that is not sufficient, look where you think the information can be found from a highly reliable source.
