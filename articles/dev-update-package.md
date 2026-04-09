# Updating the Package as a New Release

This document outlines the general development process for updating EJAM
(for a new release of the package) or relocating it to a different
repository (repo name and/or github user name), or changing the full
name of the tool (the web app). Also see the separate vignettes on
[updating
datasets](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.md)
and [updating
documentation](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-documentation.md).
This document mentions the code repository, the data repository, the
documentation pages website, and the app’s title.

## CODE REPOSITORY: If relevant, carefully change owner (and possibly repo name) of github code repository

If the package is renamed or relocated (if the owner of the repository
changed, or the location of the data repository changed, or a new name
were used for the repository), several files would need to be updated
for everything to work correctly.

- The full URL of the repo where the R package is stored must be
  recorded as the part of the URL parameter in the DESCRIPTION file in
  the root folder of the source package.

- The full URL is currently
  <https://github.com/Public-Environmental-Data-Partners/EJAM> as found
  in the DESCRIPTION file. It also can be checked via
  `url_package(type = "code", get_full_url=TRUE)`

- The \_pkgdown.yml file in the root folder should also get updated with
  the new URL.

- Rebuilding/installing the package should update usage of the URL where
  relevant. Some utility functions used it for example.

- Rebuilding the pkgdown site via
  [`pkgdown_update()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkgdown_update.md)
  should use that new information within documentation, including
  articles and function/data reference pages.

### CODE REPO OWNER: owner of the github code repository

- The owner name portion is currently
  “Public-Environmental-Data-Partners” and can be found as part of the
  URL for the code repository, or via
  `gsub("/.*", "", url_package(type = "code"))`

- Changing the URL as explained above and transferring ownership should
  work, but generated documentation pages and code test results and code
  comments should be carefully checked.

- Note it would not make sense to simply globally replace “ejanalysis”
  with “newowner” – There are web links within the R package (mostly in
  documentation) that use the domain
  [ejanalysis.com](https://ejanalysis.com) or equivalently
  [ejanalysis.org](https://ejanalysis.org), mostly used to provide
  aliases that are convenient shortcuts to the repo, documentation,
  datasets repo, etc. Those aliases include
  [ejanalysis.org/code](https://ejanalysis.org/code),
  [ejanalysis.org/data](https://ejanalysis.org/data), and
  [ejanalysis.org/docs](https://ejanalysis.org/docs). They are also
  available via `url_package("code", desc_or_alias = "alias")` for
  example. The redirect information at that domain would need to be
  updated to point to any new URLs for the data, code, or docs. It
  should not matter if that domain name is different than the owner of
  any of the repositories, so these hard-coded URLs. Those could be
  changed to use a format like url_package(desc_or_alias=“alias”) to
  make them easier to update later, by just changing that one function,
  but that is not essential.

### CODE REPO NAME: Name of the github code repository and/or the R package

- The repo name portion is currently “EJAM” and can be found as part of
  the URL for the code repository, or via
  `gsub(".*/", "", url_package(type = "code"))`

- The R package and the code repository and RStudio project in theory
  could all be different but have been the same.

- The name of the *R package* would NOT be easy to change, since it is
  used in so many places in different ways, sometimes referring to the
  github repository name and sometimes just used to refer to the R
  package name or even the tool in general. It is assumed to be the same
  as the name of the github *repository*, and there are many places
  where the package name is mentioned in vignettes/ articles, etc.
  Changing the repo name (as distinct from the owner of the repo) might
  be feasible, as described here, but you would have to be very careful
  about this distinction between package name, repo name, project name,
  and tool name. You would have to globally find in files all hardcoded
  references to the old names, urls, etc. since there still are places
  in documentation and comments where it does not check in DESCRIPTION
  for the repo name or assumes repo and package names are identical.

## DATASETS REPOSITORY: If relevant, carefully change owner and/or repo name of github repository storing the large datasets

- The owner/name of the repo where datasets are stored must be recorded
  as the ejam_data_repo parameter in the DESCRIPTION file in the root
  folder of the source package (which can be checked via
  `url_package(type = "data")`).

- The full URL is currently
  <https://github.com/Public-Environmental-Data-Partners/ejamdata>. It
  can be checked via `url_package(type = "data", get_full_url=TRUE)`

- The owner name portion is currently
  “Public-Environmental-Data-Partners” and can be found as part of the
  URL for the data repository, or via
  `gsub("/.*", "", url_package(type = "data"))`

- The repo name portion is currently “ejamdata” and can be found as part
  of the URL for the data repository, or via
  `gsub(".*/", "", url_package(type = "data"))`

- Changing the name of this repository, and/or the owner, should be
  easier than in the case of the R package code repository, since the
  data repo is referred to much less often and in fewer ways. A global
  find just to check this would be important, but changing the info in
  the DESCRIPTION file and rebuilding the package should be sufficient
  to update the info about where the data repository is located, and
  that should be used in all relevant places in the package and
  documentation after reinstalling and rebuilding documentation
  including the pkgdown site. There are some places in documentation or
  comments where the term “ejamdata” is used to refer to the repo
  without it being based on the info in the DESCRIPTION file, notably.

## DOCUMENTATION URL: If relevant, carefully change URL for where the R package documentation is published

- The name of the repo (or other domain) where webpages of package
  documentation are published must be recorded as part of the URL
  parameter in the DESCRIPTION file in the root folder of the source
  package. The website providing documentation of the R package is
  created via
  [`pkgdown_update()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkgdown_update.md),
  as explained in [updating
  documentation](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-documentation.md).

- This URL at least through mid-2026 was associated with the same
  ownername as the R code repository, but it is relatively easy to
  change where the documentation is published and it does not have to be
  the same as the code repository owner. If the documentation is
  published on github pages, then the URL would be something like
  `https://OWNER.github.io/REPONAME` and the OWNER and REPONAME in that
  URL would need to be updated if the documentation is moved to a
  different location. If the documentation is published on a different
  domain, then that URL would need to be updated in DESCRIPTION.

- This URL can be checked via `url_package(type = "docs")` which should
  return the full URL where documentation is published (currently
  <https://public-environmental-data-partners.github.io/EJAM>).

## APP TITLE: If relevant, carefully change the title of the web app

- The full name/title of the web app / tool is used in several places
  and all of those should be reading the full name from where it is
  defined. The web app title is stored in the DESCRIPTION file, and is
  available for vignettes, functions, etc. directly via
  `as.vector(desc::desc_get("Title"))`. After the package is attached,
  the name as potentially modified via global_defaults_package.R or
  parameters to
  [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  is available as `EJAM:::global_or_param("app_title")`

## PACKAGE RELEASES: Update the package release

- Update EJAM version number in the Version: field of the *DESCRIPTION*
  file in the development branch (e.g., 2.32.8) (& tying it to EJSCREEN
  version numbers if relevant). Search in files globally too, as there
  still are places where the version number is not read from
  DESCRIPTION, like the files \*\_pkgdown.yml\* and *golem-config.yml*
  and *CITATION* and *CITATION.cff* where the version must be updated
  too!

- Update `NEWS.md` in development branch listing changes made. Use the
  numbering x.y.z (same numbering as was put in DESCRIPTION).

- Merge development into main branch

- Update the EJAM release/ create a new release on github.com, using the
  `NEWS.md` as the changelog, creating a new tag like “v2.32.N”.

### Update and run the test installation script

You may want to update the test script that checks if the package can be
installed.

- Remove older versions of R from the testing and add more recent ones
- Add new system libraries required by newly added packages
  (e.g. certain libraries need for installation on Ubuntu)

To ensure that, after changes are made, the package can still be
installed by users with various operating systems and versions of R, a
workflow file, `.github/workflows/test-ability-to-install.yml`, is
triggered by any push to the main branch. This file could attempt
installation with the following matrix of options, for example, but this
has to be updated over time and checked as dependencies and other
factors do change making **some of these tests fail eventually**:

1.  **OS**: Latest Ubuntu, Windows, macOS

2.  **R version**: latest release and some prior versions

3.  **Using install_url() versus install_github()**:
    [`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html)
    and
    [`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)

But also note users may need to set up a personal access token (PAT) if
they want to install from github - [see article on installing for info
on setting up a
PAT](https://public-environmental-data-partners.github.io/EJAM/articles/installing.md).
