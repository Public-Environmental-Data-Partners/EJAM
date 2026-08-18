# Copilot Instructions for EJAM Repository

## Repository Overview

EJAM (Environmental Justice Analysis Multisite tool) is an R package with Shiny web app for environmental justice analysis and proximity assessment.
Large repository: roughly ~737MB, ~450 R source files, ~665 man pages, 115MB datasets (counts drift; re-count rather than trusting these). However, several very large .arrow data files are used by the package but not part of the bundle that gets downloaded to be installed.

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
  cmake \
  libfontconfig1-dev \
  libudunits2-dev \
  libcairo2-dev \
  libcurl4-openssl-dev \
  libssl-dev \
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
  pkg-config \
  libprotobuf-dev \
  protobuf-compiler
```

**macOS Dependencies:**
NOTE THIS LIST MAY NEED TO BE EDITED FROM TIME TO TIME, AS THE REQUIRED R PACKAGES GET UPDATED AND CREATE CHANGING DEPENDENCIES, FOR EXAMPLE!
```bash
brew update
brew install freetype udunits cairo harfbuzz fribidi libpng libtiff jpeg gdal pkg-config cmake
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
- Special setup: `tests/testthat.R` itself does NOT reinstall the package -- it just runs `test_check("EJAM")` against whichever version is currently INSTALLED. See the "Important" note below.
- Web app tests: Use shinytest2 (see below)

**Important:** `devtools::test()` and `EJAM:::test_ejam()` (default `useloadall = TRUE`) call `pkgload::load_all()`/`devtools::load_all()` first, so they test the CURRENT LOCAL SOURCE directly -- no reinstall needed for those. It's `testthat::test_check()`/`test_package()` -- and therefore `R CMD check`, `devtools::check()`, and `rcmdcheck::rcmdcheck()`, which run `tests/testthat.R` -- that test the INSTALLED package instead; reinstall first (`remotes::install_local(".", force = TRUE)`) if you need one of those to reflect recent changes.

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
# shinytest2 itself drives a local headless Chrome/Chromium via its own
# chromote dependency -- no install_phantomjs() needed.
# (webshot2, also chromote-based, is a separate Imports dependency used
# elsewhere in EJAM for report/Excel map screenshots -- not part of shinytest2.)
# also needs pandoc probably
```

## Linting

**Lintr is configured in `.github/workflows/lintr.yaml`. As of 2026-08-17 that workflow and
`R CMD check` (`.github/workflows/check-standard.yaml`) are both `active`** -- they had been
manually disabled in the Actions settings through mid-2026 and have since been re-enabled.
Enablement is a repo setting, not something visible in the YAML, so re-check the Actions tab
(or `gh api repos/OWNER/REPO/actions/workflows`) rather than trusting this paragraph.

Note what each one actually gates: `check-standard.yaml` runs the 5-platform matrix on PRs into
`main` and pushes to `main` only -- **development PRs deliberately get only the cheap gates**
(lintr, quick install), because the full matrix is expensive. And `lintr.yaml`'s `Run lintr`
step has `continue-on-error: true`, so lint findings alone do not fail the workflow or block a
PR unless that setting changes.

To run lintr locally anyway:
```r
lintr::lint_dir(".")

# CI (when enabled) uses SARIF output
lintr::sarif_output(lintr::lint_dir("."), "lintr-results.sarif")
```

**Important:** Lint findings do not block a PR (see `continue-on-error` above), but you should still address violations when reasonable.

## Building Documentation

**Update just the .Rd files of documentation (roxygen2):**
```r
devtools::document()
```

**Build pkgdown site:**
- `.github/workflows/pkgdown.yaml` is an active GitHub Actions workflow that automatically
  builds and deploys the pkgdown site (e.g. on pushes to relevant branches) -- for most changes
  you don't need to build it manually.
- For manual/local builds, `EJAM:::pkgdown_update()` (see `R/utils_pkgdown_update.R`) is still
  a working utility function with more granular options (doc rebuild, tests, install, etc.).

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

**Live EJAM web app**
- Don't hardcode a URL for this in docs/code -- it can change. Prefer `EJAM::url_ejamapp()` (note: the `URL` field in `DESCRIPTION` is the docs/code/org URLs, not the live app URL -- use `url_ejamapp()`, not that field, for the app).
- As of 2026-07, the live Shiny app is hosted on **AWS ECS Fargate** (not Cloud Run), reachable at `https://ejam.publicenvirodata.org` (prod, via a Squarespace CNAME to the prod Application Load Balancer) and also at `url_ejamapp()`'s default base URL `https://ejamapp.ejanalysis.com/` (a Cloudflare-fronted shortcut that 302-redirects there while preserving the query string, so launch-URL parameters survive -- unlike the plain `https://ejanalysis.com/ejamapp` Squarespace 301, which drops them). See `vignettes/dev-deployment.Rmd` (companion: `vignettes/dev-deploy-app.Rmd`) for the full hosting/deploy procedure -- the actual Terraform/Docker/deploy files live on the `dev-deploy`/`prod-deploy` branches, not on `main`/`development`.
- Note the version of the EJAM package used there may differ from the latest release sometimes, for some time after the release.

**API: Live hosted EJAM REST API (separate from, and not the same as, the draft/inactive API code sitting in this package's `inst/plumber/` folder)**
- Don't hardcode a URL for this either. Use `EJAM::url_package("api", get_full_url = TRUE)` or `url_ejamapi()`, which read the `Config/EJAM/url_api` field in `DESCRIPTION`.
- The API is a separate service hosted on **Google Cloud Run**, deployed from its own repo: https://github.com/Public-Environmental-Data-Partners/EJAM-API (that repo's README documents every endpoint/parameter and is the authoritative reference -- see also `vignettes/dev-api.Rmd` here for a short overview from the EJAM-package side).
- Note the version of the EJAM package used there may differ from the latest release sometimes, for some time after the release.

**EJScreen web app integration**
- Since the v3.2022.1 patch release, EJScreen can hand off multiple selected places to EJAM (deep-link/launch-URL parameters, plus a token-based `POST /handoff` on the API) so EJAM opens pre-loaded with those sites, or the API can return one combined "multisite" report directly. See `vignettes/dev-app-settings.Rmd` for the launch-URL parameters, and `NEWS.md` (top entry) for the full feature description.
- The EJScreen app/repo is separate from EJAM; treat it (like EJAM-API) as a stricter-approval repo -- see "Cross-Tool Working Conventions" below.

## GitHub Actions / CI Workflows

- See `.github/workflows/` **on this branch** for most `.yaml` files. A workflow's file can still be present even when it's been manually disabled via the GitHub Actions UI (as with `lintr.yaml`/`check-standard.yaml` below) -- check the repo's Actions tab for the authoritative enabled/disabled state, since it changes over time.
- **`deploy.yaml`/`deploy-dev.yaml` are the exception:** those two live only on the `dev-deploy`/`prod-deploy` branches (not on `main`/`development`), alongside the rest of the deploy-only files -- see "Live EJAM web app" above and `vignettes/dev-deployment.Rmd`. Don't expect to find them by browsing `.github/workflows/` on `main`/`development`.
- Snapshot as of 2026-07-02 (verify before relying on it): **enabled** -- on `main`/`development`: `test-webapp-functionality.yaml` (Shiny app UI tests), `install-quick-check.yaml`, `install-release-user-check.yaml`, `pkgdown.yaml` (docs site build+deploy), plus a couple of narrowly-scoped debug/diagnostic workflows; on the deploy branches: `deploy.yaml` (prod AWS ECS Fargate deploy, triggered from `prod-deploy`), `deploy-dev.yaml` (dev AWS ECS Fargate deploy, triggered from `dev-deploy`). **Disabled (manually, in GitHub UI)** -- `lintr.yaml` and `check-standard.yaml` (`R CMD check`); neither currently runs on PRs.


## Common Issues and Workarounds

### Common Failures and Solutions:

1. **Package attachment fails (.onAttach errors):** Reinstall from source: `remotes::install_local(".", force = TRUE)` when new functions are referenced in global_defaults_package.R.
2. **Tests don't reflect code changes:** This mainly bites `R CMD check`/`devtools::check()`/`rcmdcheck::rcmdcheck()` (which test the INSTALLED package via `tests/testthat.R`) -- reinstall first with `remotes::install_local(".", force = TRUE)` if you need one of those to reflect recent changes. `devtools::test()` and `EJAM:::test_ejam()` already test the current local source (via `load_all()`), so a reinstall isn't required for those. See more about testing in the vignette at vignettes/dev-run-unit-tests.Rmd and vignettes/dev-run-shinytests.Rmd
3. **shinytest2 timeouts:** App init might take 2+ minutes. Use `load_timeout=2e+06` in tests.
4. **"Cannot find file" in .onAttach():** Ensure `inst/global_defaults_package.R` exists when using `devtools::load_all()`.
5. **Slow builds/tests:** In `R/aaa_onAttach.R`, set `asap_download <- asap_index <- asap_bg <- FALSE` when iterating. That might help somewhat.
6. **Ubuntu install fails:** Install ALL system libraries above. Missing one causes cryptic errors.
7. **macOS jpeg errors:** Set environment variables: `PATH, LDFLAGS, CPPFLAGS, PKG_CONFIG_PATH` for `/opt/homebrew/opt/jpeg`.
8. **Cannot find datasets normally loaded via dataload_dynamic() and related functions:** See the vignettes/dev-update-datasets.Rmd about updating datasets where they explain where arrow and rda dataset files are stored.

## Key Files

**Root:** `DESCRIPTION` (metadata), `NAMESPACE` (auto-gen), `app.R` (deployment entry), `Dockerfile`, `.Rbuildignore`
**R/:** `app_ui.R`/`app_server.R` (key code for the web app), `aaa_onAttach.R` (init), `MODULE_*` (Shiny modules), `*_FUNCTIONS` (grouped functions)
**inst/:** `global_defaults_package.R` & `global_defaults_shiny.R` (settings), `golem-config.yml`, `plumber/` (draft/inactive API code -- the *live* API is the separate EJAM-API repo, see below), `report/` (templates)
**tests/:**  `testthat/test-*.R`, `test_ejam.R` (utility for interactively running groups of unit tests), `setup.R`, `setup-shinytest2.R` (shinytest2 testing of webapp functionality)

## Architecture

**Golem Framework:** Uses `app_ui()`/`app_server()`, best launched via `ejamapp()`. Config in `inst/golem-config.yml`.
**Data:**
  - Some is lazy-loaded from data/
  - Some large dynamic datasets are downloaded from the ejamdata repository as `.arrow` files and cached locally, instead of being installed as `.rda` package data. This is explained in `vignettes/dev-update-datasets.Rmd`.
  - Some is loaded via `dataload_dynamic()` and read as `.arrow` format in the app.
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

**Avoid commenting on, unless asked to do a final check for any other issues after all the significant things have been reviewed:**
- Very minor issues that are nitpicking
- Very minor issues that involve very rare or very unlikely cases
- Very minor issues that are matters of preference
- Non-critical issues related to code formatting


## Cross-Tool Working Conventions

These conventions are used consistently across the maintainer's AI tooling (Claude Code, Codex, and Copilot) for this repo. Follow them here too.

- **Protected sibling repos:** `EJAM-API` and `EJScreen` are co-managed and co-maintained with, but primarily managed by, other people (PEDP / EPIC / EDGI / Eric / Gabe / others). Never edit, merge, push, close issues, or post comments/reviews in those two repos without explicit per-action approval from the primary maintainer. This repo (`EJAM`) itself is co-managed but does not have that restriction.
- **Test file bookkeeping:** Any time a `tests/testthat/test-*.R` file is added, removed, or renamed, also update `R/test_ejam.R` (the `testlist` group membership and `timebyfile` timing metadata) in the same change -- it is not auto-discovered.
- **Cross-repo issue/PR references:** In commit messages, PR descriptions, comments, and docs, write cross-repo issue/PR references as `owner/repo#NN` (e.g. `Public-Environmental-Data-Partners/EJAM-API#43`), not bare `#NN`. A bare `#NN` auto-links to whichever repo the text lives in, which is wrong when referring to one of the sibling repos.
- **No local machine paths in commits:** Never commit code, comments, or docs containing a local-machine path (e.g. a personal home-directory path, a personal folder name). Check staged content before committing; this repo has at least one pre-existing offender (a hardcoded local path in a `data-raw/` script) that should eventually be cleaned up.
- **Resolve addressed PR review threads:** When a PR review comment/thread has been fully addressed (fixed or confirmed obsolete), resolve the conversation rather than leaving it open.
- **Don't hardcode live-service URLs in docs or code:** The Shiny app URL, the API base URL, and related repo URLs can change (proxies, domain moves, etc.). They are stored in the `Config/EJAM/url_*` namespace in `DESCRIPTION`; prefer reading them via `url_package()`/`url_ejamapp()`/`url_ejamapi()` rather than hardcoding a URL string, per the "Live EJAM web app" / "API" sections above (which also have the current, verified specifics on AWS ECS Fargate vs. Cloud Run hosting).
- **Obsolete worktree or branch cleanup:** If it is clear that a worktree or local or remote branch is obsolete since it has already been used for a PR that is merged or issue that it closed, then it should be deleted, but if it is somewhat unclear or not easy to confirm then make a note of it asking for confirmation before deleting it.
- **Never schedule a release:** Do not add, re-target, or leave in place any `cron`/`schedule:` trigger, scheduled task, or automation that can tag, publish, or deploy a release. A release requires the maintainer's explicit approval at the time. A version guard is *not* a readiness guard -- it only blocks firing on the wrong version and cannot tell a release that is ready from one that merely matches a date, and release dates slip routinely. `release.yaml` is intentionally `workflow_dispatch`-only. Scheduled *read-only* status checks are fine; the prohibition is on scheduled actions that publish, tag, or deploy.

## Package Version Management

**Version scheme: `MAJOR.ACSENDYEAR.PATCH`.** The middle field is the ACS vintage end year, not a minor number (`3.2022.2`, `4.2022.0`, `4.2024.0`). A breaking code change bumps the major (`5.YYYY.0`).

- Release **tags carry a leading `v`** (`v4.2022.0`); the `DESCRIPTION` `Version:` field does **not** (`4.2022.0`). `CITATION.cff` uses the tag spelling. Do not "normalize" one into the other.
- Because the version encodes the vintage, it can disagree with `DESCRIPTION`'s `VersionACS`. `.github/workflows/release.yaml` fails the release if version field 2 does not equal the `VersionACS` end year, and derives the release title from `VersionACS` rather than parsing the version string.
- The NEWS.md heading for a release must be `# EJAM <Version>` matching `DESCRIPTION` (a leading `v` is tolerated). The release workflow extracts its notes from that section and hard-fails if it finds none.

Version of package and versions of critical data sources like ACS are tracked in multiple files and must be updated consistently:
- `DESCRIPTION` (primary source)
- `NEWS.md` (changelog)
- `_pkgdown.yml` (documentation site -- regenerated from `DESCRIPTION` by `R/utils_pkgdown_update.R`, so prefer regenerating over hand-editing)
- `inst/golem-config.yml` (hand-maintained; nothing regenerates it)
- `CITATION.cff` and `inst/CITATION` (check for any other CITATION files too)

### ACS data vintages

Two ACS vintages are supported at once: a **frozen** one and a **live** one (the highest version number is the live line). The vintage-defining fields in `DESCRIPTION` are `VersionACS`, `ReleaseDateACS`, `ejamdata_required_tag`, and `VersionCensus` -- these move independently of `Version`, and a release that ships only code changes keeps the existing `ejamdata_required_tag` (see `vignettes/dev-update-datasets.Rmd`).

- **A vintage is a data property, not a code property.** Comparing two vintages shows no differences under `R/`. Only a handful of bundled `data/*.rda` files carry real content differences (`blockgroupstats`, `usastats`, `statestats`, `avg.in.us`); the rest differ only by stamped metadata attributes. Changing vintage means swapping those datasets and restamping metadata -- not migrating code.
- Those bundled `.rda` datasets are **not** in `ejamdata` releases. The git tag for a vintage is their source. `ejamdata` releases hold the `.arrow` files, of which only `bgej` is vintage-specific (geography and FRS files are shared).
- **Do not backport code into the `ACS2022`/`ACS2023`/`ACS2024` branches.** They are stale historical branches, not active release lines; `development`/`main` carry the currently-shipping vintage. A new vintage is produced by swapping data onto the main line.
- `data/testoutput_*.rda` fixtures are vintage-sensitive and must be regenerated when the vintage changes -- several tests assert exact equality against them. Do not reuse fixtures from an older vintage branch.
- The annual pipeline runbook is `vignettes/dev-update-ejscreen-datasets-yearly.Rmd`; dataset/release identifier rules are in `vignettes/dev-update-datasets.Rmd`.

## Additional Resources

**General context information about the EJAM package and EJAM web app and EJScreen, especially their uses, their ongoing development, and their key URLs:**
- See https://ejanalysis.com and https://ejanalysis.com/status for an initial, short, broad overview explaining what are EJSCREEN and EJAM, and status of their recent and ongoing development.
- See https://screening-tools.com for the recent history and broad context of this work and related efforts to preserve tools and data, and organizations involved in continued development.
- See https://public-environmental-data-partners.github.io/EJAM/articles/whatis.html for an article providing an overview of what the EJAM package and EJAM web app are.
- See https://ejanalysis.com/ejam-code for key URLs for relevant repositories and documentation.

**Documentation:** See the DESCRIPTION fields `URL` and `Config/EJAM/url_ejamdocs` for the github.io documentation URL. `EJAM::url_package("docs", get_full_url = T)` reads the latter.
Also, https://ejanalysis.com/docs redirects to the package documentation site. However that URL is for a set of pages that document the main branch or latest release, and does not necessarily document the most recent source version or any other branch such as the development branch.
  However, it is important to note that the most recent documentation for a given branch is in roxygen2 tags within the .R files in the given branch. Periodically those are converted to .Rd files in the man folder (via document()), and eventually may be converted to .html files in the docs folder via pkgdown_update()

**Code Repository:** See the DESCRIPTION fields `URL` and `Config/EJAM/url_ejamrepo` for the github.com R package code URL. `EJAM::url_package("code", get_full_url = T)` reads the latter.

**Data Repository:** See the DESCRIPTION fields `ejam_data_repo` and `Config/EJAM/url_ejamdata` for the github.com datasets repository. `EJAM::url_package("data", get_full_url = T)` reads the full URL from the latter.
And note it might be useful to look at the live web app and/or the hosted API, both of which are mentioned above.

## Trust These Instructions

These instructions have been carefully validated (originally as of May 1, 2026; re-verified/corrected against the live repo, GitHub Actions state, and open PRs as of July 2, 2026; the version-scheme, ACS-vintage, and no-scheduled-release sections added and the CI-enablement, lint-enforcement, and repository-size statements re-verified against the live repo and Actions API on August 17, 2026),
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
