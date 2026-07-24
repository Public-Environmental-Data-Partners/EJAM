####################################################### #
#
# Thin launcher for the EJAM local API -- compose and serve two routers:
#
#  1) ROOT: a verbatim mirror of the deployed EJAM-API (see ejam-api/SYNC.md),
#     so local paths like /report, /data, /query, /handoff, /__docs__/ behave
#     exactly like https://api.ejanalysis.com
#  2) /draft: draft/experimental endpoints that exist only in this package
#     (see draft/plumber.R), e.g. /draft/echo, /draft/ejamit, /draft/report2
#
# Run it via  EJAM:::ejamapi_local()  (background process; recommended), or by
# plumbing this file (e.g. RStudio's "Run API" button, or
# plumber::pr_run(plumber::plumb(this_file), port = 3035) ).
#
# DO NOT define endpoints in this file. Production endpoints belong in the
# EJAM-API repo (edit the mirror only to preview a proposed EJAM-API change);
# experimental endpoints belong in draft/plumber.R.
####################################################### #

#* @plumber
function(pr) {

  # Locate the two route files: prefer the source tree when running from a
  # checkout of the EJAM repo (so edits are picked up without reinstalling),
  # else use the installed package's copies.
  find_plumber_file <- function(relpath) {
    candidates <- c(
      file.path("inst", "plumber", relpath),        # running from EJAM source pkg root
      file.path("..", relpath),                     # cwd is inst/plumber itself
      system.file(file.path("plumber", relpath), package = "EJAM") # installed (or load_all)
    )
    for (f in candidates) {
      if (nzchar(f) && file.exists(f)) return(normalizePath(f))
    }
    stop("Cannot find ", relpath, " -- is the EJAM package installed (or getwd() the EJAM source root)?")
  }

  api_file   <- find_plumber_file(file.path("ejam-api", "rest_controller.r"))
  draft_file <- find_plumber_file(file.path("draft", "plumber.R"))

  # Preload the data the endpoints need, once, before serving (the mirrored
  # rest_controller.r stays verbatim, so it cannot do this itself; on the
  # deployed API the Docker image bakes the data in instead).
  if (!exists("blockwts", envir = globalenv())) EJAM::dataload_dynamic("blockwts")
  if (!EJAM:::localtree_exists()) EJAM::indexblocks()

  # Serve from the mirror's OWN directory: rest_controller.r source()s
  # query_pagination.R at plumb time AND serves ./assets resolved at request
  # time, both relative to its folder (the Docker WORKDIR in production) --
  # see ejam-api/SYNC.md. This changes the working directory for the life of
  # the serving process; prefer EJAM:::ejamapi_local(), which runs the server
  # in its own background process, to keep your session's directory pristine.
  setwd(dirname(api_file))
  api <- plumber::plumb(basename(api_file))
  draft <- plumber::plumb(draft_file)
  api$mount("/draft", draft)
  pr$mount("/", api)
  pr
}
