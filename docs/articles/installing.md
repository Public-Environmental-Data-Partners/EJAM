# Installing the EJAM R package

EJAM is not only a web app, it is also an R package you can install.
This is useful if you want to use the full set of EJAM R functions, many
of which do things not available in the web app, to do customized
analysis, to explore the datasets, or to reuse data or code in other
applications.

This assumes you have installed and know how to use [R and
RStudio](https://posit.co/download/rstudio-desktop/) (some functions
assume you have RStudio), and
[git](https://github.com/git-guides/install-git). You might also want
[GitHub Desktop](https://github.com/apps/desktop) for convenience.

## Options

The package is on GitHub.com, not CRAN (so `install.packages('EJAM')`
would *not* work).

To use EJAM in RStudio, you have two options:

1.  You can clone (or fork) the repo as a new RStudio Project, and then
    install from that source. Cloning (or forking) is easy and allows
    you to explore or contribute to source code. This is the recommended
    option.
2.  Option 2 is to avoid cloning. That is easier if you only want to run
    the web app locally, but may not work if you want to use certain R
    functions directly.

## Option 1. Install *with* cloning (preferred approach)

### Step 1. Clone EJAM & create a Project in RStudio

Here are three ways, but any of them should work – The first one is
probably the simplest:

method A. start in **RStudio**: Click **File**, **New Project**,
**Version Control**, **Git**, and for the repository URL, enter
`https://github.com/Public-Environmental-Data-Partners/EJAM`. For help:
[How to create a new RStudio project by cloning a remote Git
repo](https://docs.posit.co/ide/user/ide/guide/tools/version-control.html#creating-a-new-project-based-on-a-remote-git-or-subversion-repository).
Then add it to GitHub Desktop if that is a tool you use.

method B. start in **GitHub Desktop**: Click **File**, **Clone**,
**URL**, and for the repository URL, enter
`https://github.com/Public-Environmental-Data-Partners/EJAM`. For help:
[How to clone a repo using GitHub
Desktop](https://docs.github.com/en/desktop/adding-and-cloning-repositories/cloning-and-forking-repositories-from-github-desktop).
Then in **RStudio**: Click **File**, **New Project**, **Existing
Directory**, and specify the folder you just cloned into.

method C. start at **GitHub.com**: Go to [the EJAM repository
page](https://github.com/Public-Environmental-Data-Partners/EJAM "github.com/Public-Environmental-Data-Partners/EJAM"),
click the green **Code** button, **Download Zip**, then unzip the zip
file that contains the package. For help: [How to clone a repo from
GitHub.com](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository).
Then in **RStudio**: Click **File**, **New Project**, **Existing
Directory**, and specify the folder you just cloned into.

#### Configure Build Tools in RStudio (optional)

You can click Build, Configure Build Tools, and change settings. For
example, try these settings:

- Project build tools: Package
- Package directory: (Project Root)
- Always use –preclean : checked (yes)
- Use devtools : checked (yes)
- Generate documentation with Roxygen: checked (yes)
  - Configure Roxygen options: all checked/yes, except for Vignettes and
    Build/Install
- Install package R CMD check: –no-multiarch –with-keep.source
- Build source & Build binary: leave both blank

For help: [How to configure build tools in
RStudio](https://docs.posit.co/ide/user/ide/guide/pkg-devel/writing-packages.html#configuring-build-tools).

------------------------------------------------------------------------

### Step 2. Install (after Cloning)

You can use the “Build, Install Package” menu in RStudio.

Alternatively, you could do the following. This installs the packages
needed to load and use EJAM, without forcing every optional package used
for development, testing, or less-common workflows.

``` r

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# To install, you have to say where the cloned package was saved:
# ejamroot = the root directory into which you cloned!

## If you used the RStudio default, this may be where you cloned to:
parentfolder <- rstudioapi::readRStudioPreference(
  "default_open_project_location", ".")
ejamroot <- file.path(parentfolder, "EJAM")
# or maybe ejamroot <- "." 
if (!(basename(ejamroot) == "EJAM" && 
      file.exists(file.path(ejamroot, "DESCRIPTION")))) {
  stop("must set ejamroot to root folder of EJAM source package")}

pak::pkg_install(pkg = ejamroot, 
                 dependencies = NA, upgrade = FALSE)

library(EJAM)
```

## Option 2. Install *without* cloning (not the preferred approach)

You may be able to install the package to just run the web app locally
in RStudio without cloning, but some of the code may assume a local
source code copy is available (especially functions or scripts related
to analysis the web app cannot do, or for package development).

### Installing from github

You can use
[`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html)
to install from GitHub. A valid GitHub PAT is recommended to avoid low
unauthenticated rate limits. If you have an invalid PAT configured, fix
or remove it first; invalid credentials can fail even when the public
repository would otherwise be accessible. For help on PAT setup, see the
last section of this article.

``` r

options(timeout = 600)
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# Choose one install target.

# latest release:
pkg <- "Public-Environmental-Data-Partners/EJAM@*release"

# main branch, sometimes slightly ahead of latest release:
# pkg <- "Public-Environmental-Data-Partners/EJAM"

# development branch, often well ahead of latest release:
# pkg <- "Public-Environmental-Data-Partners/EJAM@development"

# ACS2024 branch:
# pkg <- "Public-Environmental-Data-Partners/EJAM@ACS2024"

# a specific release (version):
# pkg <- "Public-Environmental-Data-Partners/EJAM@v2.32.8.001"

pak::pkg_install(pkg = pkg, 
                 dependencies = NA, upgrade = FALSE)

library(EJAM)
```

### Installing from local source

Setting up a PAT is easy (see last section of this article), but if you
*don’t have a [personal access
token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#about-personal-access-tokens)
(PAT) and don’t want to set one up*, you could [check the github
repository for the latest
release](https://github.com/Public-Environmental-Data-Partners/EJAM/releases/latest).

You could get the name of or just download the .zip from the release
assets, and try to install it using
[`utils::install.packages()`](https://rdrr.io/r/utils/install.packages.html),
but this will not work if you have a newer version of R than the .zip
was built on. Installing source packages with `pak::pkg_install()` is
usually more reliable.

------------------------------------------------------------------------

## Census API key

It is recommended that you also [obtain and use a Census API
key](https://walker-data.com/tidycensus/articles/basic-usage.html) that
will be used to download boundaries of Census units when analyzing based
on FIPS codes, such as when comparing cities (or counties, tracts,
etc.).

## Start Using EJAM

After installing, see the [Basics - Quick Start
Guide](https://public-environmental-data-partners.github.io/EJAM/articles/basics.md).

------------------------------------------------------------------------

------------------------------------------------------------------------

## Other Technical Details

Just in case you need more details on how installing and attaching the
package works, the following describes the package dependencies and code
used by the package to get the data and build an index.

### Setting up Personal Access Tokens (PATs)

You may need to set up a [personal access
token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#about-personal-access-tokens)
(PAT) for authentication to work reliably when using repositories on
GitHub.com. Public repositories can often be installed without a PAT,
but GitHub applies lower rate limits. A bad or expired PAT can cause
errors such as “Bad GitHub credentials” or HTTP 401, so update or remove
invalid credentials before retrying. See more [about git credentials and the credential
store](https://usethis.r-lib.org/articles/git-credentials.html#git-credential-helpers-and-the-credential-store).
Note Windows takes care of most of this now, in conjunction with GitHub.

``` r

##  To check for existing PATs:
usethis::gh_token_help() 
# or
usethis::git_sitrep()  # git situation report

#  To make a new PAT:
usethis::create_github_token()

#  To register a PAT:
credentials::set_github_pat()
# or 
gitcreds::gitcreds_set()
```

### Tests of installation on various platforms and R versions

The package has GitHub Actions tests of whether it can be installed. A
quick install check runs on pushes to the main and development branches
and on pull requests to main. A broader release/user install workflow
runs for release tags, published releases, and on demand. The workflow
files are at
<https://github.com/Public-Environmental-Data-Partners/EJAM/blob/main/.github/workflows>
and logs of the results are here:
<https://github.com/Public-Environmental-Data-Partners/EJAM/actions>.

### Details on CRAN packages needed (dependencies)

You should not have to do anything other than the instructions above, to
handle package dependencies. EJAM needs dozens of other packages to be
installed that are (almost all) available from
[CRAN](https://cran.r-project.org). Installing the EJAM package as
explained above with `dependencies = NA` will handle obtaining the
required packages. Cloning and building/installing and then trying to
load/attach EJAM will also alert you to any required packages you need
to install if you don’t already have them.

In case it is of interest, a list of packages needed is in the
`DESCRIPTION` file in the R package source code root folder (as can be
found in the code repository). Packages listed in `Suggests` are
optional; they support development, testing, documentation, or
less-common workflows. Installing every suggested package with
`dependencies = TRUE` is not recommended as a first install step,
because optional packages can fail for reasons unrelated to normal EJAM
use.

### Details on the automatic data downloads

To work in the RStudio console, EJAM needs some datasets not stored as
part of the package. However, they already should be downloaded (right
after you first install the package) and loaded into memory
automatically (or be ready for lazy-loading or otherwise loading as
needed) as soon as you do require(EJAM) or library(EJAM).

On first use, the package should automatically download some data files.
Each time the package is attached via library() or require(),
`.onAttach()` will check for updates.
