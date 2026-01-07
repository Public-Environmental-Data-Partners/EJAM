# Updating the Package as a New Release

This document outlines the general development process for updating EJAM
(for a new release of the package) or relocating it to a different
repository (repo name and/or github user name), or changing the full
name of the tool. Also see the separate vignettes on [updating
datasets](https://ejanalysis.github.io/EJAM/articles/dev-update-datasets.md)
and [updating
documentation](https://ejanalysis.github.io/EJAM/articles/dev-update-documentation.md).

## If relevant, carefully change owners and names of github repositories

- The full name/title of the web tool is used in several places and all
  of those should be reading the full name from where it is defined. The
  app title is stored in the DESCRIPTION file, and is available for
  vignettes, functions, etc. directly via
  `as.vector(desc::desc_get("Title"))`. After the package is attached,
  the name as potentially modified via global_defaults_package.R or
  parameters to
  [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)
  is available as `EJAM:::global_or_param("app_title")`

- The name of the *package* (e.g., “EJAM”) is assumed to be the same as
  the name of the github *repository*, and there are many places where
  the package name is mentioned in vignettes/ articles, etc. Changing
  just the repo name is feasible, as described here, but you would have
  to be careful about this distinction. You would have to globally find
  in files all hardcoded references to the old names, urls, etc. since
  there still are places where it does not check in DESCRIPTION for the
  repo name or assumes repo and package names are identical.

If the package were renamed or relocated (if a new name were used for
the repository or the owner of the repository changed, or the location
of the data repository changed), several files would need to be updated
for everything to work correctly:

- The name of the github repository storing the package code must be
  recorded as part of the URL parameter in the DESCRIPTION file in the
  root folder of the source package.

- The name of the repo (or other domain) where webpages of package
  documentation are published also must be recorded as part of the URL
  parameter in the DESCRIPTION file in the root folder of the source
  package. The website providing documentation of the R package is
  created via
  [`pkgdown_update()`](https://ejanalysis.github.io/EJAM/reference/pkgdown_update.md),
  as explained in [updating
  documentation](https://ejanalysis.github.io/EJAM/articles/dev-update-documentation.md).

- The name of the repo where datasets are stored must be recorded as the
  ejam_data_repo parameter in the DESCRIPTION file in the root folder of
  the source package.

## Update the package release

- Update EJAM version number in *DESCRIPTION* in development branch
  (e.g. to 2.32.7) (& tying it to EJSCREEN version numbers if relevant).
  Search in files globally too, as there still are places where the
  version number is not read from DESCRIPTION, like the files
  \*\_pkgdown.yml\* and *golem-config.yml* and *CITATION* and
  *CITATION.cff* where the version must be updated too!

- Update `NEWS.md` in development branch listing changes made. Use the
  numbering x.y.z (same numbering as was put in DESCRIPTION).

- Merge development into main branch

- Update the EJAM release/ create a new release on github.com, using the
  `NEWS.md` as the changelog, creating a new tag like “v2.32.N”.

## Update the test installation script

You may want to update the test script.

- Remove older versions of R from the testing and add more recent ones
- Add new system libraries required by newly added packages
  (e.g. certain libraries need for installation on Ubuntu)

## Test the installation process

To ensure that, after changes are made, the package can still be
installed by users with various operating systems and versions of R, a
workflow file, `.github/workflows/test-ability-to-install.yml`, is
triggered by any push to the main branch. This file tests installation
with the following matrix of options:

1.  **OS**: Latest Ubuntu, Windows, macOS

2.  **R version**: latest release and some prior versions

3.  **Using install_url() versus install_github()**:
    [`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html)
    and
    [`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)

But also note users may need to set up a personal access token (PAT) if
they want to install from github - [see article on installing for info
on setting up a
PAT](https://ejanalysis.github.io/EJAM/articles/installing.md).

## obsolete step: Make updates public before a new release (from when a nonpublic repo was used for development at EPA)

If the development repo being used is internal or private, not public,
then to make the package installable, the updates need to be pushed to a
public repo. These would be the steps:

1.  If not already done, add ejanalysis/EJAM (or the appropriate public
    repo) as a remote for the internal repo main branch:

`git remote add EJAM git@github.com:ejanalysis/EJAM.git`

2.  Push to the main branch of that public repo:

`git push EJAM main:main`

3.  If you want to squash commits

    1.  If you want to add a new squash commit, do this from main in the
        internal repo:

`git checkout -b squash-temp`
`git reset --soft #SHA OF PREVIOUS MAIN COMMIT`
`git commit -m "Creating squashed commit"`
`git push --force EJAM squash-temp:main`

    b.  If you just want EJAM to end with a single squash commit, do this from main in the internal repo:

`git checkout –orphan squash-temp` `git add .`
`git commit -m "Publishing to public repo"`
`git push --force EJAM squash-temp:main` `git -M main`

4.  Update EJAM release using a similar process as updating an internal
    repo release.
