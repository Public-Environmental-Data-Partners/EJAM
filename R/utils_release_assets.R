
# Helpers for listing the assets of a GitHub release.
#
# Why this file exists:
#   piggyback::pb_download() gets its list of downloadable files from
#   piggyback::pb_releases(), which asks GitHub for /repos/{owner}/{repo}/releases.
#   When the GitHub API is degraded it can answer that request with HTTP 200 and
#   an EMPTY array. piggyback then believes the repository has no releases and no
#   assets, warns quietly, downloads nothing, and returns without an error. EJAM
#   used to treat that as "nothing to download" and carried on, so the only thing
#   the user ever saw was a later complaint that an Arrow file was missing from
#   disk -- which points at the data release instead of at the failed API call.
#
#   These helpers ask GitHub directly for one specific release, so that
#     - a failed/unreachable listing,
#     - a release that really does have zero assets, and
#     - a release whose assets simply do not include the requested files
#   are three clearly different, loudly reported outcomes.


# Remember the most recent diagnosis of why Arrow datasets could not be
# downloaded, so a later "dataset not found on disk" error can say what actually
# went wrong instead of blaming the data release.
.ejamdata_download_state <- new.env(parent = emptyenv())

ejamdata_download_problem_set <- function(text) {
  assign("problem", as.character(text)[1], envir = .ejamdata_download_state)
  invisible(text)
}

ejamdata_download_problem_clear <- function() {
  if (exists("problem", envir = .ejamdata_download_state, inherits = FALSE)) {
    rm("problem", envir = .ejamdata_download_state)
  }
  invisible(NULL)
}

ejamdata_download_problem <- function() {
  if (!exists("problem", envir = .ejamdata_download_state, inherits = FALSE)) {
    return(NULL)
  }
  get("problem", envir = .ejamdata_download_state, inherits = FALSE)
}

# Text appended to unrelated "cannot find the dataset" errors, so the root cause
# travels with them.
ejamdata_download_problem_note <- function() {
  problem <- ejamdata_download_problem()
  if (is.null(problem) || !nzchar(problem)) {
    return("")
  }
  paste0(
    "\n\nThe most likely reason is that the download of the Arrow datasets ",
    "did not succeed:\n", problem
  )
}
################################################################ #

# HTTP status code of a gh error, or NA if this was not an HTTP error at all
# (e.g., DNS failure, timeout, TLS problem).
github_error_status <- function(e) {
  if (!inherits(e, "condition")) {
    return(NA_integer_)
  }
  hits <- grep("^http_error_[0-9]+$", class(e), value = TRUE)
  if (length(hits) > 0) {
    return(as.integer(sub("^http_error_", "", hits[1])))
  }
  # Older/other gh conditions keep the status only in the message.
  found <- regmatches(
    conditionMessage(e),
    regexpr("HTTP[ /][^ ]* ?([0-9]{3})|\\(HTTP ([0-9]{3})\\)", conditionMessage(e))
  )
  if (length(found) == 1) {
    digits <- regmatches(found, regexpr("[0-9]{3}", found))
    if (length(digits) == 1) return(as.integer(digits))
  }
  NA_integer_
}

# Is this the kind of failure that often clears up on its own within seconds?
github_error_is_transient <- function(e) {
  status <- github_error_status(e)
  if (!is.na(status)) {
    if (status %in% c(408L, 429L, 500L, 502L, 503L, 504L)) return(TRUE)
    # 403 is what GitHub uses for both rate limiting and outright denial.
    if (status == 403L) {
      return(grepl("rate limit|abuse|secondary", conditionMessage(e), ignore.case = TRUE))
    }
    return(FALSE)
  }
  # Not an HTTP status, so this is a network/transport problem.
  grepl(
    "timed? out|timeout|resolve host|could not connect|connection (reset|refused|closed)|network is (down|unreachable)|ssl|tls|handshake|recv failure|empty reply",
    conditionMessage(e),
    ignore.case = TRUE
  )
}
################################################################ #

#' List the assets of one GitHub release, distinguishing failure from emptiness
#'
#' @param repository "owner/name", such as `"Public-Environmental-Data-Partners/ejamdata"`
#' @param tag release tag such as `"v3.2022.0"`
#' @param .token GitHub token, or `""` to let [gh::gh_token()] decide
#' @param max_tries how many times to ask GitHub before giving up. Retries happen
#'   only for transient failures (5xx, rate limiting, network trouble).
#' @param wait_seconds seconds to wait before the first retry; doubled each retry
#' @return a list with
#'   - `ok`: TRUE only if GitHub actually answered with this release
#'   - `status`: one of "ok", "release_empty", "release_not_found", "api_error",
#'      "bad_repository", "no_gh"
#'   - `assets`: character vector of asset file names (empty if none)
#'   - `n_assets`, `draft`, `attempts`, `detail`, `repository`, `tag`
#' @keywords internal
#' @noRd
#'
ejamdata_release_assets <- function(repository,
                                    tag,
                                    .token = "",
                                    max_tries = 3L,
                                    wait_seconds = 2) {

  out <- list(
    ok = FALSE, status = "api_error", assets = character(0), n_assets = 0L,
    draft = NA, attempts = 0L, detail = "", repository = repository, tag = tag
  )

  repository_parts <- strsplit(as.character(repository)[1], "/", fixed = TRUE)[[1]]
  if (length(repository_parts) != 2 || !all(nzchar(repository_parts))) {
    out$status <- "bad_repository"
    out$detail <- paste0("repository must be in owner/name form, but was: ", repository)
    return(out)
  }
  if (!requireNamespace("gh", quietly = TRUE)) {
    out$status <- "no_gh"
    out$detail <- "The gh package is required to list GitHub release assets."
    return(out)
  }

  # Treat NULL, NA, and "" alike as "no token was supplied, let gh decide".
  token <- as.character(.token)
  token <- if (length(token) == 1 && !is.na(token) && nzchar(token)) {
    token
  } else {
    gh::gh_token()
  }

  attempt <- 0L
  release <- NULL
  repeat {
    attempt <- attempt + 1L
    release <- tryCatch(
      gh::gh(
        "GET /repos/{owner}/{repo}/releases/tags/{tag}",
        owner = repository_parts[1],
        repo  = repository_parts[2],
        tag   = tag,
        .token = token
      ),
      error = function(e) e
    )
    if (!inherits(release, "condition")) break
    if (attempt >= max_tries || !github_error_is_transient(release)) break
    pause_for <- wait_seconds * 2^(attempt - 1L)
    message(
      "GitHub could not be reached while listing assets for release ", tag,
      " in ", repository, " (attempt ", attempt, " of ", max_tries,
      "); retrying in ", pause_for, " seconds..."
    )
    Sys.sleep(pause_for)
  }
  out$attempts <- attempt

  if (inherits(release, "condition")) {
    status <- github_error_status(release)
    out$status <- if (!is.na(status) && status == 404L) "release_not_found" else "api_error"
    out$detail <- conditionMessage(release)
    return(out)
  }

  asset_names <- if (length(release$assets) == 0) {
    character(0)
  } else {
    vapply(release$assets, function(a) as.character(a[["name"]])[1], character(1))
  }

  # The assets GitHub includes inside a release object can be capped for releases
  # with many of them, which is why a separate paginated assets endpoint exists.
  # Only ask for it when the inline list is long enough to have been truncated,
  # and only believe it if it tells us about MORE assets, never fewer -- an empty
  # or short answer here is the same degraded-API symptom this file exists for.
  if (length(asset_names) >= 30 && !is.null(release$id)) {
    paged <- tryCatch(
      gh::gh(
        "GET /repos/{owner}/{repo}/releases/{release_id}/assets",
        owner = repository_parts[1],
        repo  = repository_parts[2],
        release_id = release$id,
        per_page = 100,
        .limit = Inf,
        .token = token
      ),
      error = function(e) NULL
    )
    if (length(paged) > length(asset_names)) {
      asset_names <- vapply(paged, function(a) as.character(a[["name"]])[1], character(1))
    }
  }

  out$ok <- TRUE
  out$assets <- asset_names
  out$n_assets <- length(asset_names)
  out$draft <- isTRUE(release$draft)
  out$status <- if (length(asset_names) == 0) "release_empty" else "ok"
  out
}
################################################################ #

# Human-readable explanation of a listing that did not give us what we needed.
# needed = the asset file names we were about to download.
ejamdata_release_listing_problem <- function(listing, needed = character(0)) {

  repository <- listing$repository
  tag <- listing$tag
  missing_from_release <- setdiff(needed, listing$assets)

  if (identical(listing$status, "ok") && length(missing_from_release) == 0) {
    return(NULL)
  }

  if (identical(listing$status, "no_gh")) {
    return(paste0(
      "\u274C Could not list assets for release ", tag, " in ", repository,
      " -- ", listing$detail
    ))
  }
  if (identical(listing$status, "bad_repository")) {
    return(paste0(
      "\u274C Could not list assets for release ", tag,
      " -- ", listing$detail
    ))
  }

  if (identical(listing$status, "api_error")) {
    return(paste0(
      "\u274C Could not list assets for release ", tag, " in ", repository,
      " -- the GitHub API request failed after ", listing$attempts,
      " attempt", if (listing$attempts == 1L) "" else "s", ".\n",
      "   The release may be UNREACHABLE rather than empty, so this is very likely ",
      "a GitHub API or network problem, NOT missing data.\n",
      "   Nothing was downloaded. Check https://www.githubstatus.com and try again.\n",
      "   Last error from GitHub: ", listing$detail
    ))
  }

  if (identical(listing$status, "release_not_found")) {
    return(paste0(
      "\u274C Could not list assets for release ", tag, " in ", repository,
      " -- GitHub says that release does not exist (HTTP 404).\n",
      "   Either the release tag is wrong (see ejamdata_required_tag in DESCRIPTION), ",
      "the release was deleted or renamed, or it is private and the token in use cannot see it.\n",
      "   Nothing was downloaded."
    ))
  }

  if (identical(listing$status, "release_empty")) {
    return(paste0(
      "\u274C Release ", tag, " in ", repository,
      " was found, but GitHub reported that it has NO assets at all.\n",
      "   GitHub answered successfully, so this looks like a genuinely empty release ",
      "rather than a failed listing",
      if (isTRUE(listing$draft)) " (note: this release is still a DRAFT)" else "",
      ".\n",
      "   But if that release is known to have data files, GitHub may be serving an ",
      "incomplete response -- check https://www.githubstatus.com and try again.\n",
      "   Nothing was downloaded."
    ))
  }

  # Listing worked, release has assets, but not the ones we asked for.
  paste0(
    "\u274C Release ", tag, " in ", repository, " lists ", listing$n_assets,
    " asset(s), but does not include: ", paste(missing_from_release, collapse = ", "), "\n",
    "   The listing itself succeeded, so these data files really are absent from that release.\n",
    "   Assets that release does have: ", paste(listing$assets, collapse = ", ")
  )
}
################################################################ #

# piggyback memoises its release listings for the whole R session, so one empty
# answer from a degraded GitHub API would otherwise poison every later attempt in
# the same session. Clearing the cache is what makes a retry worth doing.
# Silently does nothing if memoise is unavailable.
piggyback_listing_cache_clear <- function() {
  if (!requireNamespace("memoise", quietly = TRUE) ||
      !requireNamespace("piggyback", quietly = TRUE)) {
    return(invisible(FALSE))
  }
  cleared <- FALSE
  for (fname in c("pb_info", "pb_releases")) {
    f <- tryCatch(getFromNamespace(fname, "piggyback"), error = function(e) NULL)
    if (is.null(f)) next
    is_memoised <- isTRUE(tryCatch(memoise::is.memoised(f), error = function(e) FALSE))
    if (!is_memoised) next
    ok <- tryCatch({memoise::forget(f); TRUE}, error = function(e) FALSE)
    cleared <- cleared || ok
  }
  invisible(cleared)
}
################################################################ #
