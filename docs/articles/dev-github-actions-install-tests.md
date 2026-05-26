# GitHub Actions install tests

This note explains the GitHub Actions workflows that check whether EJAM
can be installed. These workflows are intentionally separate from
`R CMD check` because they answer different questions.

## Quick install check

Workflow file: `.github/workflows/install-quick-check.yaml`

This is the low-cost install check. It runs on Ubuntu with the current
release of R. It installs only hard package dependencies first, then
installs EJAM.

Automatic triggers:

- push to `development`
- pull request to `main`

Manual trigger:

- `workflow_dispatch`, with `install_source` set to either `local` or
  `github-sha`

Use the manual trigger when a branch changes package dependencies,
installation code, or workflow files and you want a quick install check
without running the full release matrix.

What it proves:

- `local`: the checked-out source tree installs.
- `github-sha`: the same commit can be installed from GitHub by commit
  SHA.

## Release and user install checks

Workflow file: `.github/workflows/install-release-user-check.yaml`

This workflow is deliberately more expensive. It is for release
validation and for testing installation paths that users are likely to
use.

Automatic triggers:

- push of a tag matching `v*`
- GitHub Release published

Manual trigger:

- `workflow_dispatch`, with a `ref` such as `development`, `ACS2024`,
  `v2.5.0`, or a commit SHA
- optional `expected_version`, such as `2.5.0`
- `test_scope` set to `user-style`, `full-matrix`, or `both`

The `full-matrix` job tests Linux, Windows, and macOS, with `oldrel-1`
and `release` R, and these install methods:

- `local`: install the checked-out source tree with
  [`utils::install.packages()`](https://rdrr.io/r/utils/install.packages.html)
  and `INSTALL_opts`
- `github-ref`: install from GitHub by branch, tag, or SHA using
  [`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)
- `url-tarball`: install the GitHub source tarball using
  [`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html)

The workflow uses `remotes` for `github-ref` and `url-tarball` because
those checks need
`INSTALL_opts = c("--with-keep.source", "--install-tests")`.
[`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html)
is preferred for ordinary user installs, but it does not accept those
`R CMD INSTALL` options.

The `user-style` job tests Windows and macOS with the current release of
R. It does not use `setup-r-dependencies`. It starts closer to a plain R
installation:

``` r

install.packages("pak")
pak::pkg_install("Public-Environmental-Data-Partners/EJAM@*release",
                 dependencies = TRUE, upgrade = FALSE)
library(EJAM)
```

For a manual run, it installs
`Public-Environmental-Data-Partners/EJAM@REF`, where `REF` is the
workflow input. For a GitHub Release published event, it installs
`@*release`.

What it proves:

- tag pushes prove that a specific tag can be installed by local source,
  GitHub ref, and GitHub source tarball.
- release published events prove that the latest GitHub Release can be
  installed with the public `pak`-based instructions on Windows and
  macOS.
- manual runs can test a branch, tag, or SHA before deciding whether to
  create or publish a release.

## Branches and workflow file versions

GitHub Actions uses the workflow file from the branch or ref that
triggers the event, with some event-specific details. In practice, keep
workflow files as similar as possible in `development`, `main`, and
active release branches unless there is a deliberate reason for a
branch-specific workflow.

Manual `workflow_dispatch` runs are easiest to use once the workflow
file exists on the repository’s default branch. The Actions page can
then run the workflow against a selected branch, tag, or SHA, depending
on the workflow inputs.

Recommended workflow promotion:

- Edit and test workflow changes on the active working branch first.
- Push them to `development` once they are ready for routine development
  use.
- Merge them to `main` before relying on them for release validation.
- For a release branch such as `ACS2024`, bring the same workflow
  changes into that branch before testing or tagging a release from that
  branch.

If a branch says `Version: 2.5.0` in `DESCRIPTION`, the branch workflow
can prove that the branch or commit installs as version 2.5.0. It does
not prove that the tag `v2.5.0` installs until the tag exists and the
tag-triggered workflow passes.
