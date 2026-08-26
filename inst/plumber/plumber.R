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

  # Report the installed EJAM package version in the Swagger/OpenAPI metadata, and
  # preserve the build-time git ref separately as provenance. Kept deliberately
  # identical in behavior to EJAM-API's main.r, so the local API and the deployed API
  # describe themselves the same way.
  #
  # packageVersion() is the source of truth: it reports the EJAM that is installed and
  # answering requests. EJAM_VERSION is a *git ref* picked at build time - a tag such as
  # "v3.2022.2" (with a leading "v", which DESCRIPTION's Version field does not carry), or
  # a branch name such as "development", which is not a version at all. It can also
  # disagree with what was installed, since an image may be built with a --build-arg
  # override while the Dockerfile's pinned default goes stale.
  #
  # Note Sys.getenv(unset=) fires only when the variable is ABSENT; a variable exported as
  # an empty string - which `ENV EJAM_VERSION=${EJAM_VERSION}` produces from an empty
  # build-arg - returns "", so nzchar() is what actually guards this.
  plumber::pr_set_api_spec(pr, function(spec) {
    spec$info$version <- as.character(utils::packageVersion("EJAM"))

    ejam_ref <- Sys.getenv("EJAM_VERSION")
    if (nzchar(ejam_ref)) {
      description <- spec$info$description
      if (is.null(description) || !length(description) || is.na(description)) {
        description <- ""
      }
      separator <- if (nzchar(description)) "\n\n" else ""
      spec$info$description <- paste0(
        description,
        separator,
        "Built from EJAM ref: ",
        ejam_ref
      )
    }

    spec
  })

  # Locate the two route files: prefer the source tree when running from a
  # checkout of the EJAM repo (so edits are picked up without reinstalling),
  # else use the installed package's copies.
  find_plumber_file <- function(relpath) {
    candidates <- c(
      file.path("inst", "plumber", relpath),        # running from EJAM source pkg root
      relpath,                                      # cwd is inst/plumber itself
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

  # Plumb the mirror from its OWN directory (rest_controller.r source()s
  # query_pagination.R with a path relative to its folder, the Docker WORKDIR
  # in production -- see ejam-api/SYNC.md), restoring the caller's working
  # directory afterwards so running this in your main R session (e.g. RStudio
  # "Run API") does not leave you in a different directory.
  owd <- setwd(dirname(api_file))
  api <- tryCatch(plumber::plumb(basename(api_file)), finally = setwd(owd))

  # The mirror's `@assets ./assets` static route resolves at REQUEST time
  # against the process working directory, so remount it here by absolute
  # path (composition-layer fix; the mirrored file itself stays verbatim).
  api$mount("/assets", plumber::PlumberStatic$new(file.path(dirname(api_file), "assets")))

  draft <- plumber::plumb(draft_file)
  api$mount("/draft", draft)
  pr$mount("/", api)
  pr
}
