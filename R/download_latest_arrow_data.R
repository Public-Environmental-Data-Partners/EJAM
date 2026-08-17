
ejamdata_local_arrow_tag_read <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }

  tag <- tryCatch(
    trimws(readLines(path, warn = FALSE)),
    error = function(e) character(0)
  )
  tag <- tag[!is.na(tag) & nzchar(tag)]
  if (length(tag) == 0) {
    return(NULL)
  }

  ejamdata_tag_canonical(tag[1])
}

ejamdata_local_arrow_tag_write <- function(tag, path) {
  tag <- ejamdata_tag_canonical(tag)
  writeLines(tag, con = path, sep = "\n", useBytes = TRUE)
  invisible(path)
}

#' Download package-compatible Arrow datasets if user does not have them already
#'
#' Used when EJAM package is attached
#' @details
#'   Checks to see what `ejamdata` release tag should be used for requested
#'   Arrow datasets. By default, EJAM uses the required `ejamdata` release tag
#'   recorded in DESCRIPTION as `ejamdata_required_tag`. For example, EJAM
#'   2.32.8.001 currently looks for Arrow files in the `ejamdata` release tagged
#'   `v2.32.8.001`, not in whichever data-repository release GitHub currently
#'   marks as latest.
#'
#'   The installed package's `data/ejamdata_version.txt` marker records the
#'   release tag for locally installed Arrow files.
#'
#'   Relies on [piggyback::pb_download()] to download data files that have been
#'   stored as assets of a specific release on the data repository.
#'
#'   Before downloading, it asks GitHub what assets that one release actually
#'   has, and says so distinctly when the answer is a failed listing (the release
#'   may be unreachable rather than empty), a release that does not exist, a
#'   release with no assets at all, or a release missing the requested files.
#'   Transient failures are retried with backoff. Without that check, a degraded
#'   GitHub API that answers with an empty list looks exactly like a release with
#'   nothing in it, and nothing gets downloaded without any error being raised.
#'   For details, see [technical details of how datasets are updated](`r paste0(EJAM::url_package(type = "docs", get_full_url = TRUE), "/articles/dev-update-datasets.html")`)
#'
#' @param varnames use defaults, or vector of names like "bgej" or use "all" to get all available
#' @param repository repository owner/name such as `r EJAM::url_package(type = "data", get_full_url = FALSE)` or "XYZ/ejamdata"
#'   (wherever the ejamdata repo is hosted, as specified in the DESCRIPTION file of this package)
#' @param envir if needed to specify environment other than default, e.g., globalenv() or parent.frame()
#' @param piggybacktag default is `"latest"`, which resolves internally to the
#'   DESCRIPTION `ejamdata_required_tag` field. Pass a specific tag such as
#'   `"v2.32.8.001"` only for explicit maintenance or diagnostic work.
#' @param force set TRUE to download requested files even if local copies exist.
#' @keywords internal
#' @export
#'
download_latest_arrow_data <- function(
    varnames = .arrow_ds_names,
    repository = NULL,
    envir = globalenv(),
    piggybacktag = "latest",
    force = FALSE
) {

  if ('all' %in% tolower(varnames)) {
    varnames <- .arrow_ds_names
  }
  varnames <- unique(varnames)

  release_tags <- dynamic_data_release_tag(varnames, piggybacktag = piggybacktag)
  if (length(unique(release_tags)) > 1) {
    ok <- vapply(
      split(varnames, release_tags),
      function(these_varnames) {
        isTRUE(download_latest_arrow_data(
          varnames = these_varnames,
          repository = repository,
          envir = envir,
          piggybacktag = unique(unname(release_tags[these_varnames])),
          force = force
        ))
      },
      logical(1)
    )
    return(invisible(all(ok)))
  }
  target_arrow_tag <- unique(unname(release_tags))

  if (missing(repository) || is.null(repository)) {
    repository <- url_package(type="data", get_full_url = FALSE) # must be xyz/abc, not full URL
  }
  installed_data_folder <- app_sys('data')
  ejamdata_version_fpath <- file.path(installed_data_folder, "ejamdata_version.txt")
  filenames <- paste0(varnames, ".arrow")
  full_paths <- file.path(installed_data_folder, filenames)
  missing_files <- if (isTRUE(force)) filenames else filenames[!file.exists(full_paths)]
  file_sizes <- suppressWarnings(file.info(full_paths)$size)
  invalid_existing <- filenames[file.exists(full_paths) & (is.na(file_sizes) | file_sizes < 1024)]
  if (length(invalid_existing) > 0) {
    warning(
      "Removing invalid local Arrow file(s) before download: ",
      paste(invalid_existing, collapse = ", "),
      call. = FALSE
    )
    unlink(file.path(installed_data_folder, invalid_existing))
    missing_files <- unique(c(missing_files, invalid_existing))
  }

  users_arrow_tag <- ejamdata_local_arrow_tag_read(ejamdata_version_fpath)

  if (offline_cat()) {
    if (length(missing_files) == 0 &&
        isTRUE(identical(users_arrow_tag, target_arrow_tag))) {
      warning("Arrow-format datasets (blocks, etc.) were all found and match the required local ejamdata release marker, but no internet connection seems to be available, so cannot check GitHub release assets.")
      return(invisible(TRUE))
    } else if (length(missing_files) == 0) {
      warning("Arrow-format datasets (blocks, etc.) were all found, but the local ejamdata release marker does not match required release ", target_arrow_tag, " and no internet connection seems to be available.")
      return(invisible(FALSE))
    } else {
      offline_problem <- paste0(
        "One or more arrow-format datasets (blocks, etc.) are missing, ",
        "but no internet connection seems to be available, so cannot download missing files!"
      )
      ejamdata_download_problem_set(offline_problem)
      warning(offline_problem)
      return(invisible(FALSE))
    }
  }

  # Use a GitHub token if available, so private or rate-limited release asset
  # downloads can still work.
  github_token <- Sys.getenv("GITHUB_PAT", unset = Sys.getenv("GITHUB_TOKEN", unset = ""))

  # check that it's valid
  if (nzchar(github_token)) {
    token_is_valid <- tryCatch(
      {
        repository_parts <- strsplit(repository, "/", fixed = TRUE)[[1]]
        if (length(repository_parts) == 2) {
          gh::gh(
            "GET /repos/{owner}/{repo}",
            owner = repository_parts[1],
            repo = repository_parts[2],
            .token = github_token
          )
        } else {
          gh::gh("GET /rate_limit", .token = github_token)
        }
        message("\u2705 Token is valid!")
        TRUE
      },
      error = function(e) {
        message("\u274C Token is invalid or expired. Resetting...")
        FALSE
      }
    )
    if (!token_is_valid) github_token = ""
  }

  # Determine whether the local Arrow files match the package-compatible
  # ejamdata release recorded in ejamdata_version.txt.

  # If local Arrow files already match the required release tag, only download
  # requested files that are missing. Otherwise, redownload the requested set.
  if (!isTRUE(force) && isTRUE(identical(users_arrow_tag, target_arrow_tag))) {
    # filenames <- paste0(varnames, ".arrow")
    # full_paths <- file.path(installed_data_folder, filenames)
    # missing_files <- filenames[!file.exists(full_paths)]

    if (length(missing_files) == 0) {
      message("Arrow-format datasets (blocks, etc.) are up-to-date -- locally-installed and package-compatible data repository versions match.")
      ejamdata_download_problem_clear()
      return(invisible(TRUE))
    } else {
      message("One or more arrow-format datasets (blocks, etc.) are missing. Downloading release ", target_arrow_tag, " from this github repository: ", repository)
    }
  } else {
    # If user installs for the first time, they won't have any arrow datasets or
    # the txt marker, which is added at the end of this function.

    missing_files <- filenames
    if (is.null(users_arrow_tag)) {
      message("Downloading arrow-format datasets (blocks, etc.) from release ", target_arrow_tag)
    } else {
      message(paste0("Arrow-format datasets (blocks, etc.) are out-of-date. Downloading release ", target_arrow_tag, " from this github repository: ", repository))
    }
  }

  # Before downloading anything, ask GitHub directly what assets this release
  # actually has. piggyback cannot tell an unreachable listing apart from an
  # empty one -- it treats both as "nothing to download", downloads nothing, and
  # returns without an error -- so the only symptom used to be a missing local
  # file reported much later, which points at the data release instead of at the
  # failed API call. See R/utils_release_assets.R
  listing <- ejamdata_release_assets(
    repository = repository,
    tag = target_arrow_tag,
    .token = github_token
  )
  listing_problem <- ejamdata_release_listing_problem(listing, needed = missing_files)
  if (!is.null(listing_problem)) {
    ejamdata_download_problem_set(listing_problem)
    # Reported as a message as well as a warning: .onAttach() suppresses warnings
    # while relaying messages, so a warning alone is invisible during install.
    message(listing_problem)
    warning(listing_problem, call. = FALSE)
    return(invisible(FALSE))
  }

  # otherwise, download the data from EJAM package's release assets
  arrow_file_is_valid <- function(path) {
    file.exists(path) &&
      isTRUE(file.info(path)$size >= 1024) &&
      !inherits(try(arrow::read_ipc_file(path, as_data_frame = FALSE), silent = TRUE), "try-error")
  }

  still_needed <- missing_files
  download_tries <- 3L
  for (attempt in seq_len(download_tries)) {
    if (attempt > 1) {
      pause_for <- 2 * 2^(attempt - 2L)
      message(
        "Retrying download of ", paste(still_needed, collapse = ", "),
        " in ", pause_for, " seconds (attempt ", attempt, " of ", download_tries, ")..."
      )
      Sys.sleep(pause_for)
      # piggyback memoises release listings for the whole R session, so one empty
      # answer from a degraded API would make every retry fail identically.
      piggyback_listing_cache_clear()
    }
    tryCatch({
      piggyback::pb_download(
        file = still_needed,
        dest = installed_data_folder,
        repo = repository,
        tag = target_arrow_tag,
        overwrite = TRUE,
        use_timestamps = FALSE,
        .token = github_token
      )},
      error = function(e) {
        message(paste0("\u274C Failed trying to get datasets from github repository ", repository, " release ", target_arrow_tag, ": ", conditionMessage(e)))
        FALSE
      }
    )
    still_needed <- still_needed[!vapply(
      file.path(installed_data_folder, still_needed), arrow_file_is_valid, logical(1)
    )]
    if (length(still_needed) == 0) break
  }

  if (length(still_needed) > 0) {
    unlink(file.path(installed_data_folder, still_needed))
    download_problem <- paste0(
      "\u274C Download did not produce valid Arrow file(s) after ", download_tries,
      " attempt(s): ", paste(still_needed, collapse = ", "), "\n",
      "   Release ", target_arrow_tag, " in ", repository, " does list these as assets, ",
      "so the files exist -- the transfer itself failed or was incomplete.\n",
      "   The partial files were removed and the local data version marker was not updated. ",
      "Check your network and disk space, then try again in a new R session."
    )
    ejamdata_download_problem_set(download_problem)
    message(download_problem)
    warning(download_problem, call. = FALSE)
    return(invisible(FALSE))
  }
  message(paste0("Finished downloading release ", target_arrow_tag, " versions of datasets."))

  # update user's arrowversion
  message("Writing updated info about what versions of arrow datasets are saved locally...")
  tried <- tryCatch({
    ejamdata_local_arrow_tag_write(target_arrow_tag, ejamdata_version_fpath)},
    error = function(e) {
      message(paste0("\u274C Failed to write (updated info about what versions of arrow datasets are saved locally) to file ", ejamdata_version_fpath, " -- check permissions..."))
      FALSE
    }
  )
  if (isFALSE(tried)) {
    return(invisible(FALSE))
  }
  ejamdata_download_problem_clear()
  invisible(TRUE)
}
