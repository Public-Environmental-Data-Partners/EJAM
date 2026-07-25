############################# #
# ejamapi_local() will run the API in the background as a separate R process
#
# https://callr.r-lib.org
# Security considerations
# callr makes a copy of the user's .Renviron file and potentially of the local or user .Rprofile, in the session temporary directory. Avoid storing sensitive information such as passwords, in your environment file or your profile, otherwise this information will get scattered in various files, at least temporarily, until the subprocess finishes. You can use the keyring package to avoid passwords in plain files.
############################# #

#' Run the EJAM API locally, in the background, to test/develop it
#'
#' @description Serves, on localhost, a composite of two plumber routers:
#'
#'  1. At the root, a verbatim mirror of the deployed EJAM-API
#'     (`inst/plumber/ejam-api/rest_controller.r` -- see the SYNC.md there),
#'     so local paths like `/report`, `/data`, `/query`, `/handoff`, and the
#'     Swagger docs at `/__docs__/` behave like <https://api.ejanalysis.com>.
#'     Since the EJAM-API has no staging server, this is the way to preview
#'     how it will behave -- including how it will behave after a proposed
#'     EJAM-API code edit (edit the mirror copy, rerun this, test, then
#'     submit the identical diff to the EJAM-API repo).
#'
#'  2. Mounted at `/draft`, the draft/experimental endpoints that exist only
#'     in this package (`inst/plumber/draft/plumber.R`), e.g. `/draft/echo`,
#'     `/draft/ejamit`, `/draft/report2`, `/draft/getblocksnearby`.
#'
#' Note local PDF report rendering requires pandoc (e.g., the RSTUDIO_PANDOC
#' environment variable set when running outside RStudio).
#' @seealso [ejamapi()] and [url_ejamapi()]
#' @param fname plumber file served at the root. Default is the mirror of the
#'   deployed EJAM-API. (Passing the older combined file, or any other plumber
#'   file, still works.)
#' @param draftfile plumber file mounted at /draft. Default is the package's
#'   draft endpoints file.
#' @param drafts set FALSE to serve only the EJAM-API mirror, without
#'   mounting the /draft endpoints (a pure preview of the deployed API).
#' @param host optional, localhost IP
#' @param port optional, a port number
#' @param quiet optional, set to TRUE to reduce info printed to console
#' @param launch_browser optional, set FALSE to not open `/__docs__/` in a browser
#'
#' @examples
#' \dontrun{
#'  # launch (in a background R process) and try it from this R console
#'  apiproc <- EJAM:::ejamapi_local()
#'
#'  # the deployed-API endpoints, served locally:
#'  browseURL("http://127.0.0.1:3035/report?lat=34.05&lon=-118.24&radius=3")
#'  df <- ejamapi(fips = "10001", endpoint = "data",
#'    baseurl = "http://127.0.0.1:3035/")
#'
#'  # the draft-only endpoints, at /draft:
#'  urlx <- "http://127.0.0.1:3035/draft/getblocksnearby?lat=33&lon=-99&radius=2"
#'  outx <- httr2::req_perform(httr2::request(urlx))
#'  s2b <- data.table::rbindlist(httr2::resp_body_json(outx))
#'
#'  # stop the background API process when done:
#'  apiproc$kill()
#' }
#' @return Invisibly, the [callr::r_bg()] process handle for the background
#'   server; use `x$kill()` to stop it, `x$is_alive()` to check on it, and
#'   `x$read_error()` to see startup errors if the server did not come up.
#'
#' @keywords internal
#'
ejamapi_local <- function(
    fname = system.file("plumber/ejam-api/rest_controller.r", package = "EJAM"),
    draftfile = system.file("plumber/draft/plumber.R", package = "EJAM"),
    drafts = TRUE,
    host = "127.0.0.1",
    port = 3035,
    quiet = FALSE,
    launch_browser = interactive()
) {

  if (!nzchar(fname) || !file.exists(fname)) {
    stop("Cannot find the plumber API file: ", fname)
  }
  if (drafts && (!nzchar(draftfile) || !file.exists(draftfile))) {
    stop("Cannot find the draft plumber file: ", draftfile, " (or pass drafts = FALSE)")
  }

  ############################# #
  # ejamapi_local_here() runs the API in the current process (blocking):

  ejamapi_local_here <- function(fname, draftfile, drafts, host, port, quiet) {

    library(EJAM) # the plumber files also attach EJAM; do it first so startup messages come now

    # Preload data the endpoints need, once, before serving. The mirrored
    # rest_controller.r is kept verbatim (see inst/plumber/ejam-api/SYNC.md)
    # so it cannot do this itself; on the deployed API the Docker image bakes
    # the data in instead.
    if (!exists("blockwts", envir = globalenv())) dataload_dynamic("blockwts")
    if (!EJAM:::localtree_exists()) indexblocks()

    if (requireNamespace("beepr", quietly = TRUE)) {
      beepr::beep() # alerts when finished with package loading and ready
    }
    cat("Try  http://", host, ":", port, "/__docs__/ \n", sep = "")

    # Serve from the root file's OWN directory, for the life of this process
    # (which is dedicated to the server): the mirrored rest_controller.r
    # source()s query_pagination.R at plumb time AND serves ./assets resolved
    # at request time, both relative to its folder -- exactly like the Docker
    # WORKDIR in production. See inst/plumber/ejam-api/SYNC.md.
    draftfile <- if (drafts) normalizePath(draftfile) else NULL
    setwd(dirname(fname))
    pr <- plumber::plumb(basename(fname))
    if (drafts) {
      pr$mount("/draft", plumber::plumb(draftfile))
    }

    pr <- plumber::pr_hook(pr, "exit", function() {
      # can specify any other cleanup here
      print("plumber API process is terminating")
    })

    plumber::pr_run(pr, host = host, port = port, quiet = quiet)
  }
  ############################# #

  # Run the API in the background using the callr package:

  x <- callr::r_bg(
    ejamapi_local_here,
    args = list(
      fname = fname,
      draftfile = draftfile,
      drafts = drafts,
      host = host,
      port = port,
      quiet = quiet
    )
  )

  # Wait for the server to come up (data preload can take a while on first
  # run), then open the interactive docs page.
  docs_url <- paste0("http://", host, ":", port, "/__docs__/")
  deadline <- Sys.time() + 120
  up <- FALSE
  while (Sys.time() < deadline && x$is_alive()) {
    up <- tryCatch({
      con <- suppressWarnings(url(docs_url, open = "rb"))
      close(con)
      TRUE
    }, error = function(e) FALSE)
    if (up) break
    Sys.sleep(1)
  }
  if (!x$is_alive()) {
    warning("The background API process exited during startup. Check x$read_error() on the returned handle.")
  } else if (!up) {
    warning("The background API process has not started listening yet at ", docs_url,
            "; it may still be loading data. Check again shortly.")
  } else {
    if (!quiet) cat("Local EJAM API is up at http://", host, ":", port, "/  (docs at ", docs_url, ")\n", sep = "")
    if (launch_browser) browseURL(docs_url)
  }

  invisible(x)
}
############################# #
