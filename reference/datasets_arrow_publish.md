# Publish Arrow files as ejamdata release assets

Maintainer helper for publishing dynamic EJAM `.arrow` files to the data
repository release assets. Defaults are intentionally conservative:
dry-run only, do not overwrite existing assets, and do not mark the
release as latest.

## Usage

``` r
datasets_arrow_publish(
  files,
  tag = ejamdata_required_tag(),
  repo = url_package(type = "data", get_full_url = FALSE),
  release_name = tag,
  release_date = Sys.Date(),
  release_notes = paste0("Updated datasets for EJScreen/EJAM updated as of ",
    release_date),
  mark_latest = FALSE,
  dry_run = TRUE,
  overwrite = FALSE,
  validate_arrow = TRUE
)
```

## Arguments

- files:

  Character vector of local `.arrow` file paths.

- tag:

  GitHub release tag to create/use. Defaults to the required `ejamdata`
  tag for this package.

- repo:

  GitHub repository in `owner/name` form.

- release_name:

  Release title. Defaults to `tag`.

- release_date:

  Date used in the default release notes.

- release_notes:

  Release body text. Defaults to
  `"Updated datasets for EJScreen/EJAM updated as of "` plus
  `release_date`.

- mark_latest:

  Logical. If `TRUE`, ask GitHub to mark the release as latest. Defaults
  to `FALSE`.

- dry_run:

  Logical. If `TRUE`, validate and report the planned actions without
  creating a release or uploading assets.

- overwrite:

  Logical. If `TRUE`, replace existing release assets with the same
  names. Defaults to `FALSE`.

- validate_arrow:

  Logical. If `TRUE`, confirm files can be opened as Arrow IPC files
  before publishing.

## Value

A data.frame describing files and planned/performed actions, invisibly.

## Examples

``` r
 fpaths <- file.path("data", paste0(EJAM:::.arrow_ds_names, ".arrow"), )
 if (FALSE) { # \dontrun{

 stopifnot(all(file.exists(fpaths)))
 EJAM:::datasets_arrow_publish(
   files = fpaths,
   tag = "v2.5.0",
   mark_latest = FALSE,
   dry_run = TRUE,
   overwrite = FALSE
   )

} # }
```
