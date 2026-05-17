
#' Download package-compatible Arrow datasets if user does not have them already
#'
#' Used when EJAM package is attached
#' @details
#'   Checks to see what release of each requested Arrow dataset should be used.
#'   Facility and most geography Arrow files are treated as dynamic data and
#'   normally come from the latest applicable data-repository release, tracked
#'   with the installed package's `data/ejamdata_version.txt` marker.
#'
#'   Annual EJSCREEN/EJAM data files such as `bgej.arrow` are package-coupled.
#'   They are obtained from the `ejamdata` release tag that matches the current
#'   EJAM package version as reported by `packageVersion("EJAM")`. For example,
#'   EJAM 2.5.0 looks for `bgej.arrow` in the `ejamdata` release tagged
#'   `v2.5.0`, not in the latest data-repository release.
#'
#'   Relies on [piggyback::pb_releases()] to track / update / store / download
#'   data files as assets of a specific release on the data repository.
#'   For details, see [technical details of how datasets are updated](`r paste0(EJAM::url_package(type = "docs", get_full_url = TRUE), "/articles/dev-update-datasets.html")`)
#'
#' @param varnames use defaults, or vector of names like "bgej" or use "all" to get all available
#' @param repository repository owner/name such as `r EJAM::url_package(type = "data", get_full_url = FALSE)` or "XYZ/ejamdata"
#'   (wherever the ejamdata repo is hosted, as specified in the DESCRIPTION file of this package)
#' @param envir if needed to specify environment other than default, e.g., globalenv() or parent.frame()
#' @param piggybacktag default is `"latest"` for dynamic Arrow data. Package-
#'   coupled annual datasets such as `bgej` override `"latest"` internally and
#'   use `paste0("v", packageVersion("EJAM"))` as their release tag.
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
  piggybacktag <- unique(unname(release_tags))
  update_group <- unique(unname(dynamic_data_group(varnames)))
  use_ejamdata_version_marker <- !("ejscreen_annual_update" %in% update_group)

  if (missing(repository) || is.null(repository)) {
    repository <- url_package(type="data", get_full_url = FALSE) # must be xyz/abc, not full URL
  }
  installed_data_folder <- app_sys('data')
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

  if (offline_cat()) {
    # message("No internet connection seems to be available!")
    if (length(missing_files) == 0) {
      warning("Arrow-format datasets (blocks, etc.) files were all found, but no internet connection seems to be available, so cannot check if files are the latest version available online!")
      return(invisible(TRUE))
    } else {
      warning("One or more arrow-format datasets (blocks, etc.) are missing, but no internet connection seems to be available, so cannot downloading missing files!")
      return(invisible(FALSE))
    }
  }

  # get arrow data version in repo vs. user's version *** CHECK THIS
  github_token <- Sys.getenv("GITHUB_PAT", unset = Sys.getenv("GITHUB_TOKEN", unset = ""))

  # check that it's valid
  if (nzchar(github_token)) {
    token_is_valid <- tryCatch(
      {
        gh::gh("GET /user", .token = github_token)
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

  # see what is release of datasets repo according to piggyback::pb_releases()
  # and then determine if user has latest versions as recorded in ejamdata_version.txt.
  # EJSCREEN annual-update datasets like bgej are pinned to the EJAM package
  # release tag instead of the latest data-repository release.

  if (use_ejamdata_version_marker && identical(piggybacktag, "latest")) {
    latestArrowVersion <- tryCatch({piggyback::pb_releases(
      repo = repository, # must be xyz/abc, not full URL
      .token = github_token
    )[1, "tag_name"]},
    error = function(e) {
      message(paste0("\u274C Failed trying to get info from github repository ", repository, " about latest release according to piggyback::pb_releases()..."))
      FALSE
    })

    if (isFALSE(latestArrowVersion)) {
      return(invisible(FALSE))
    }
  } else {
    latestArrowVersion <- piggybacktag
  }

  ejamdata_version_fpath <- paste0(installed_data_folder,"/ejamdata_version.txt")

  if (!use_ejamdata_version_marker) {
    usersArrowVersions <- latestArrowVersion
  } else if (!file.exists(ejamdata_version_fpath)) {
    usersArrowVersions <- NULL
  } else {
    usersArrowVersions <- readLines(ejamdata_version_fpath)
  }

  # if user has latest release, check if any requested files are missing
  # if so, need to re-download (default to all files). Otherwise, all set
  if (!isTRUE(force) && isTRUE(usersArrowVersions == latestArrowVersion)) {
    # filenames <- paste0(varnames, ".arrow")
    # full_paths <- file.path(installed_data_folder, filenames)
    # missing_files <- filenames[!file.exists(full_paths)]

    if (length(missing_files) == 0) {
      if (use_ejamdata_version_marker) {
        message("Arrow-format datasets (blocks, etc.) are up-to-date -- locally-installed and latest-released data repository versions match.")
      } else {
        message("Package-pinned Arrow dataset(s) found locally for release tag ", latestArrowVersion, ": ", paste(filenames, collapse = ", "))
      }
      return(invisible(TRUE))
    } else {
      message("One or more arrow-format datasets (blocks, etc.) are missing. Downloading release ", latestArrowVersion, " from this github repository: ", repository)
    }
  } else {
    # If user installs for the first time, they won't have any arrow datasets or
    # the txt with the version, which is added at the end of this program

    missing_files <- filenames
    if (is.null(usersArrowVersions)) {
      message("Downloading arrow-format datasets (blocks, etc.) from release ", latestArrowVersion)
    } else {
      message(paste0("Arrow-format datasets (blocks, etc.) are out-of-date. Downloading release ", latestArrowVersion, " from this github repository: ", repository))
    }
  }

  # otherwise, download the data from EJAM package's release assets
  tried <- tryCatch({
    piggyback::pb_download(
      file = missing_files,
      dest = installed_data_folder,
      repo = repository,
      tag = piggybacktag,
      overwrite = TRUE,
      use_timestamps = FALSE,
      .token = github_token
    )},
    error = function(e) {
      message(paste0("\u274C Failed trying to get datasets from github repository ", repository, " release ", piggybacktag, "..."))
      FALSE
    }
  )
  if (isFALSE(tried)) {
    return(invisible(FALSE))
  }

  downloaded_paths <- file.path(installed_data_folder, missing_files)
  downloaded_valid <- vapply(downloaded_paths, function(path) {
    file.exists(path) &&
      isTRUE(file.info(path)$size >= 1024) &&
      !inherits(try(arrow::read_ipc_file(path, as_data_frame = FALSE), silent = TRUE), "try-error")
  }, logical(1))
  if (!all(downloaded_valid)) {
    bad_files <- basename(downloaded_paths[!downloaded_valid])
    unlink(downloaded_paths[!downloaded_valid])
    warning(
      "Download failed or did not produce valid Arrow IPC file(s): ",
      paste(bad_files, collapse = ", "),
      ". These files were removed and the local data version marker was not updated.",
      call. = FALSE
    )
    return(invisible(FALSE))
  }
  message(paste0("Finished downloading release ", latestArrowVersion, " versions of datasets."))

  if (use_ejamdata_version_marker) {
    # update user's arrowversion
    message("Writing updated info about what versions of arrow datasets are saved locally...")
    tried <- tryCatch({
      writeLines(latestArrowVersion, ejamdata_version_fpath)},
      error = function(e) {
        message(paste0("\u274C Failed to write (updated info about what versions of arrow datasets are saved locally) to file ", ejamdata_version_fpath, " -- check permissions..."))
        FALSE
      }
    )
    if (isFALSE(tried)) {
      return(invisible(FALSE))
    }
  }
  invisible(TRUE)
}
