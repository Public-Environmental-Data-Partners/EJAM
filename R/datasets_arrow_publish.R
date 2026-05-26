#' Publish Arrow files as ejamdata release assets
#'
#' Maintainer helper for publishing dynamic EJAM `.arrow` files to the data
#' repository release assets. Defaults are intentionally conservative: dry-run
#' only, do not overwrite existing assets, and do not mark the release as latest.
#'
#' @param files Character vector of local `.arrow` file paths.
#' @param tag GitHub release tag to create/use. Defaults to the required
#'   `ejamdata` tag for this package.
#' @param repo GitHub repository in `owner/name` form.
#' @param release_name Release title. Defaults to `tag`.
#' @param release_date Date used in the default release notes.
#' @param release_notes Release body text. Defaults to
#'   `"Updated datasets for EJScreen/EJAM updated as of "` plus
#'   `release_date`.
#' @param mark_latest Logical. If `TRUE`, ask GitHub to mark the release as
#'   latest. Defaults to `FALSE`.
#' @param dry_run Logical. If `TRUE`, validate and report the planned actions
#'   without creating a release or uploading assets.
#' @param overwrite Logical. If `TRUE`, replace existing release assets with the
#'   same names. Defaults to `FALSE`.
#' @param validate_arrow Logical. If `TRUE`, confirm files can be opened as
#'   Arrow IPC files before publishing.
#' @examples
#'  fpaths <- file.path("data", paste0(EJAM:::.arrow_ds_names, ".arrow"), )
#'  \dontrun{
#'
#'  stopifnot(all(file.exists(fpaths)))
#'  EJAM:::datasets_arrow_publish(
#'    files = fpaths,
#'    tag = "v2.5.0",
#'    mark_latest = FALSE,
#'    dry_run = TRUE,
#'    overwrite = FALSE
#'    )
#'
#' }
#' @return A data.frame describing files and planned/performed actions,
#'   invisibly.
#'
#' @keywords internal
#'
datasets_arrow_publish <- function(files,
                                         tag = ejamdata_required_tag(),
                                         repo = url_package(type = "data", get_full_url = FALSE),
                                         release_name = tag,
                                         release_date = Sys.Date(),
                                         release_notes = paste0(
                                           "Updated datasets for EJScreen/EJAM updated as of ",
                                           release_date
                                         ),
                                         mark_latest = FALSE,
                                         dry_run = TRUE,
                                         overwrite = FALSE,
                                         validate_arrow = TRUE) {
  if (missing(files) || length(files) == 0) {
    stop("Provide one or more local .arrow files to publish.", call. = FALSE)
  }
  files <- path.expand(files)
  files <- normalizePath(files, mustWork = FALSE)
  files <- unique(files)

  missing_files <- files[!file.exists(files)]
  if (length(missing_files) > 0) {
    stop("Missing .arrow file(s): ", paste(missing_files, collapse = ", "), call. = FALSE)
  }

  not_arrow <- files[!grepl("\\.arrow$", files, ignore.case = TRUE)]
  if (length(not_arrow) > 0) {
    stop("All files must end in .arrow: ", paste(not_arrow, collapse = ", "), call. = FALSE)
  }

  file_info <- file.info(files)
  too_small <- files[is.na(file_info$size) | file_info$size < 1024]
  if (length(too_small) > 0) {
    stop("Invalid or too-small .arrow file(s): ", paste(too_small, collapse = ", "), call. = FALSE)
  }

  if (isTRUE(validate_arrow)) {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      stop("The arrow package is required to validate .arrow files.", call. = FALSE)
    }
    valid_arrow <- vapply(files, function(path) {
      !inherits(try(arrow::read_ipc_file(path, as_data_frame = FALSE), silent = TRUE), "try-error")
    }, logical(1))
    if (!all(valid_arrow)) {
      stop("Could not read these files as Arrow IPC files: ",
           paste(files[!valid_arrow], collapse = ", "),
           call. = FALSE)
    }
  }

  asset_names <- basename(files)
  duplicate_assets <- unique(asset_names[duplicated(asset_names)])
  if (length(duplicate_assets) > 0) {
    stop("Duplicate asset filename(s): ", paste(duplicate_assets, collapse = ", "), call. = FALSE)
  }

  plan <- data.frame(
    file = files,
    asset = asset_names,
    size = unname(file_info$size),
    repo = repo,
    tag = tag,
    stringsAsFactors = FALSE
  )

  message("Arrow release asset plan:")
  print(plan, row.names = FALSE)
  message("Release name: ", release_name)
  message("Release notes: ", release_notes)
  message("Mark latest: ", mark_latest)
  message("Overwrite existing assets: ", overwrite)
  message("Dry run: ", dry_run)

  if (isTRUE(dry_run)) {
    message("Dry run only: no release was created and no assets were uploaded.")
    return(invisible(plan))
  }

  if (!requireNamespace("gh", quietly = TRUE)) {
    stop("The gh package is required to create/update GitHub releases.", call. = FALSE)
  }
  if (!requireNamespace("piggyback", quietly = TRUE)) {
    stop("The piggyback package is required to upload release assets.", call. = FALSE)
  }

  repo_parts <- strsplit(repo, "/", fixed = TRUE)[[1]]
  if (length(repo_parts) != 2 || !all(nzchar(repo_parts))) {
    stop("repo must be in owner/name form, such as Public-Environmental-Data-Partners/ejamdata.", call. = FALSE)
  }
  owner <- repo_parts[[1]]
  repo_name <- repo_parts[[2]]

  token <- Sys.getenv("GITHUB_PAT", unset = Sys.getenv("GITHUB_TOKEN", unset = ""))
  if (!nzchar(token)) {
    token <- gh::gh_token()
  }

  release <- tryCatch(
    gh::gh(
      "GET /repos/{owner}/{repo}/releases/tags/{tag}",
      owner = owner,
      repo = repo_name,
      tag = tag,
      .token = token
    ),
    error = function(e) NULL
  )

  if (is.null(release)) {
    message("Creating release ", tag, " in ", repo)
    release <- gh::gh(
      "POST /repos/{owner}/{repo}/releases",
      owner = owner,
      repo = repo_name,
      tag_name = tag,
      name = release_name,
      body = release_notes,
      draft = FALSE,
      prerelease = FALSE,
      make_latest = if (isTRUE(mark_latest)) "true" else "false",
      .token = token
    )
  } else {
    message("Release ", tag, " already exists in ", repo)
    gh::gh(
      "PATCH /repos/{owner}/{repo}/releases/{release_id}",
      owner = owner,
      repo = repo_name,
      release_id = release$id,
      name = release_name,
      body = release_notes,
      make_latest = if (isTRUE(mark_latest)) "true" else "false",
      .token = token
    )
  }

  existing_assets <- release$assets
  existing_asset_names <- if (length(existing_assets) == 0) {
    character(0)
  } else {
    vapply(existing_assets, `[[`, character(1), "name")
  }
  conflicts <- intersect(asset_names, existing_asset_names)
  if (length(conflicts) > 0 && !isTRUE(overwrite)) {
    stop(
      "Release already has asset(s): ", paste(conflicts, collapse = ", "),
      ". Use overwrite = TRUE only after confirming replacement is intended.",
      call. = FALSE
    )
  }

  for (path in files) {
    message("Uploading ", basename(path), " to ", repo, " release ", tag)
    piggyback::pb_upload(
      path,
      repo = repo,
      tag = tag,
      overwrite = isTRUE(overwrite),
      .token = token
    )
  }

  invisible(plan)
}
