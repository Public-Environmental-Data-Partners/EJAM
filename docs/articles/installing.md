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

You can use the Build menu in RStudio, or just run the following (which
installs all the Suggests, not just Imports)

``` r
if (!require(devtools)) {install.packages("devtools")}

# To do install() below, you have to say where the cloned package was saved:
# ejamroot = the root directory into which you cloned!

## If you used the RStudio default, this may be where you cloned to:
parentfolder <- rstudioapi::readRStudioPreference(
  "default_open_project_location", ".")
ejamroot <- file.path(parentfolder, "EJAM")
if (!(basename(ejamroot) == "EJAM" && 
      file.exists(file.path(ejamroot, "DESCRIPTION")))) {
  stop("must set ejamroot to root folder of EJAM source package")}

devtools::install(pkg = ejamroot, dependencies=T, upgrade="always", build=F)
```

## Option 2. Install *without* cloning (not the preferred approach)

You may be able to install the package to just run the web app locally
in RStudio without cloning, but some of the code assumes a local source
code copy is available (especially functions or scripts related to
analysis the web app cannot do, or for package development).

### Using install_github()

If you *do have a PAT set up*, you can use
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html).
(For help on PAT setup, see the last section of this article).

Replace OWNER/REPO below with “Public-Environmental-Data-Partners/EJAM”
including the quote marks

``` r
options(timeout=300); if (!require(devtools)) {install.packages("devtools")}
ref = github_release() # specifies you want the latest released version
#ref = "v2.5.0"   # a tag identifying a specific release
#ref = "HEAD"          # main branch
#ref = "development"   # development branch version

remotes::install_github(
  repo = OWNER/REPO, ref = ref, 
  dependencies=T, upgrade="always", build=F)
library(EJAM)
```

### Using install_url() or install_local()

If you *don’t have a [personal access
token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#about-personal-access-tokens)
(PAT) and don’t want to set one up*, you could [check the github
repository for the latest
release](https://github.com/Public-Environmental-Data-Partners/EJAM/releases/latest)
and may be able to use
[`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html)
something like this:

Replace “URL_OF_REPO” below with
“<https://github.com/Public-Environmental-Data-Partners/EJAM>” including
the quote marks

``` r
options(timeout=300); if (!require(devtools)) {install.packages("devtools")}
zipname = "v2.5.0.zip" # or whatever the latest release is - update as needed

remote_zip = paste0(
  "URL_OF_REPO", "/archive/refs/tags/", zipname)
remotes::install_url(url = remote_zip, 
                     dependencies=T, upgrade='always', build=F)
library(EJAM)
```

*or download the .zip file as a separate step, and install from that
saved file:*

Replace “URL_OF_REPO” below with
“<https://github.com/Public-Environmental-Data-Partners/EJAM>” including
the quote marks

``` r
options(timeout=300); if (!require(devtools)) {install.packages("devtools")}
zipname = "v2.5.0.zip" # or whatever the latest release is - update as needed

remote_zip = paste0(
  "URL_OF_REPO", "/archive/refs/tags/", zipname)
local_zip = file.path(tempdir(), zipname)
download.file(remote_zip, destfile = local_zip)
remotes::install_local(path = local_zip, 
                       dependencies=T, upgrade="always", build=F)
library(EJAM)
```

------------------------------------------------------------------------

## Census API key

It is recommended that you [obtain and use a Census API
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
(PAT) for authentication to work when using a repository on GitHub.com.
See more [about git credentials and the credential
store](https://usethis.r-lib.org/articles/git-credentials.html#git-credential-helpers-and-the-credential-store).
Note Windows takes care of most of this now, in conjunction with GitHub.

``` r
##  To check for existing PATs:
usethis::gh_token_help() # or
usethis::git_sitrep() # git situation report

#  To make a new PAT:
usethis::create_github_token()

#  To register a PAT:
credentials::set_github_pat()
```

### Tests of installation on various platforms and R versions

The package has tests of whether it can be installed on Windows, MacOS,
and Ubuntu, with various R versions and with `remotes::url_install()`
and `remotes::github_install()`. When a pull request or push to the main
branch of EJAM occurs, those tests run automatically as github actions
in a workflow at
<https://github.com/Public-Environmental-Data-Partners/EJAM/blob/main/.github/workflows>
and logs of the results of those tests are here:
<https://github.com/Public-Environmental-Data-Partners/EJAM/actions>.
The same sort of tests could be set up to be triggered by pushes to the
development branch, but just note a set of installation tests like these
can take well over an hour to run on github.

### Details on CRAN packages needed (dependencies)

You should not have to do anything other than the instructions above, to
handle package dependencies. EJAM needs dozens of other packages to be
installed that are (almost all) available from
[CRAN](https://cran.r-project.org). Installing the EJAM package as
explained above (with dependencies=TRUE, upgrade=“always”) will handle
obtaining those other packages. Cloning and building/installing and then
trying to load/attach EJAM will also alert you to those other packages
you need to install if you don’t already have them. In case it is of
interest, a list of packages needed is in the `DESCRIPTION` file in the
R package source code root folder (as can be found in the code
repository). Note some are in Suggests and you probably want to install
those as well since some of them were actually used in some
less-often-used features or functions. Using dependencies=T in
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html),
[`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html),
install(), etc. will make sure they are all installed. Each of those
packages in turn requires other packages that also get installed as
needed. Future work may reduce the number of package dependencies to a
more typical number.

### Details on the automatic data downloads

To work in the RStudio console, EJAM needs some datasets not stored as
part of the package. However, they already should be downloaded (right
after you first install the package) and loaded into memory
automatically (or be ready for lazy-loading or otherwise loading as
needed) as soon as you do require(EJAM) or library(EJAM).

On first use, the package should automatically download some data files
from a related repository. Each time the package is attached via
library() or require(), `.onAttach()` will check for updates and also
will build a spatial index of Census block points called
[`?localtree`](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md),
via
[`indexblocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexblocks.md).

Typically you would not need to download any datasets yourself, because
EJAM just downloads these when the app starts (technically, when the R
package is attached) (or only as needed in the case of certain datasets
that are not always needed). Some datasets are installed along with the
package, such as the
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
data. But large files like
[blockpoints](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md)
are stored in a separate data repo, and EJAM downloads them from there.
You might want your own local copies, though, for these reasons:

Attaching the package actually checks (using internal function
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md))
for copies in memory first (e.g.,
`exists("quaddata", envir = globalenv())`), then local disk (using
[`dataload_from_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_from_local.md)
looking in the data folder of the (source or installed) package, as
defined by `app_sys()` which is just a wrapper for
[`system.file()`](https://rdrr.io/r/base/system.file.html)), then
finally tries to download any still needed, using internal functions.
