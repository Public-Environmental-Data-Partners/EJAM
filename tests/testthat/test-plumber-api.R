# Tests of the plumber API definition files shipped in inst/plumber/:
#
#  - ejam-api/rest_controller.r  = verbatim mirror of the deployed EJAM-API repo
#    (see inst/plumber/ejam-api/SYNC.md)
#  - draft/plumber.R             = draft endpoints that exist only in this package
#  - plumber.R                   = thin launcher composing the two
#
# These parse/inventory checks do NOT start a server (server smoke tests are in
# test-ejamapi_local.R, gated by EJAM_TEST_LOCAL_API=true).

testthat::skip_if_not_installed("plumber")

route_paths <- function(pr) {
  sort(unique(unlist(lapply(pr$endpoints, function(group) {
    vapply(group, function(e) e$path, character(1))
  }))))
}

# The mirrored rest_controller.r source()s query_pagination.R and serves
# ./assets with paths relative to its own folder (the Docker WORKDIR in
# production), so it must be plumbed from that folder -- as ejamapi_local()
# and inst/plumber/plumber.R do. See inst/plumber/ejam-api/SYNC.md.
plumb_mirror <- function() {
  fname <- system.file("plumber/ejam-api/rest_controller.r", package = "EJAM")
  expect_true(nzchar(fname) && file.exists(fname))
  withr::with_dir(dirname(fname), plumber::plumb(basename(fname)))
}

test_that("EJAM-API mirror file plumbs and defines the deployed endpoints", {
  pr <- plumb_mirror()
  paths <- route_paths(pr)
  expect_true(all(c("/", "/data", "/query", "/report", "/handoff", "/handoff/<token>") %in% paths))
  # /report must be there twice (GET and POST)
  allpaths <- unlist(lapply(pr$endpoints, function(group) vapply(group, function(e) e$path, character(1))))
  expect_gte(sum(allpaths == "/report"), 2)
  # static assets are mounted at /assets, NOT at root (root would shadow /__docs__/)
  expect_true("/assets/" %in% names(pr$mounts))
})

test_that("draft endpoints file plumbs and defines the draft-only endpoints", {
  fname <- system.file("plumber/draft/plumber.R", package = "EJAM")
  expect_true(nzchar(fname) && file.exists(fname))
  pr <- plumber::plumb(fname)
  paths <- route_paths(pr)
  expect_true(all(c(
    "/echo", "/ejamit", "/ejamit_csv", "/getblocksnearby",
    "/report2", "/reportpost", "/ejam2report", "/ejam2excel",
    "/get_blockpoints_in_shape", "/doaggregate"
  ) %in% paths))
  # drafts must NOT define any deployed-API path: they are mounted under /draft,
  # and a same-named route would shadow or confuse the mirror after any re-sync
  expect_length(intersect(paths, c("/", "/data", "/query", "/report", "/handoff")), 0)
})

test_that("mirror + drafts compose: drafts mount at /draft with no route collisions", {
  api <- plumb_mirror()
  draft <- plumber::plumb(system.file("plumber/draft/plumber.R", package = "EJAM"))
  api$mount("/draft", draft)
  expect_true("/draft/" %in% names(api$mounts))
  expect_length(intersect(route_paths(api), route_paths(draft)), 0)
})

test_that("mirror of the EJAM-API code has not drifted from the EJAM-API repo's main branch", {
  testthat::skip_on_cran()
  testthat::skip_if_offline(host = "raw.githubusercontent.com")

  for (relpath in c(
    "rest_controller.r",
    "query_pagination.R",
    "assets/communityreport.css"
  )) {
    upstream_url <- paste0(
      "https://raw.githubusercontent.com/Public-Environmental-Data-Partners/EJAM-API/main/",
      relpath
    )
    # Compare RAW BYTES, not readLines(): readLines() normalizes line endings and
    # trailing newlines, so it cannot verify the byte-for-byte mirror contract
    # described in inst/plumber/ejam-api/SYNC.md (per Copilot review).
    upstream_file <- tempfile()
    on.exit(unlink(upstream_file), add = TRUE)
    fetched <- tryCatch({
      # download.file() can return a NON-ZERO status without throwing, which would
      # leave an empty/partial file and a confusing readBin() failure later --
      # validate the status AND that a non-empty file landed (per Copilot review),
      # so fetch problems route through the skip_if() below instead.
      status <- utils::download.file(upstream_url, upstream_file, quiet = TRUE, mode = "wb")
      identical(status, 0L) && file.exists(upstream_file) && file.size(upstream_file) > 0
    }, error = function(e) FALSE, warning = function(w) FALSE)
    testthat::skip_if(!fetched, paste("could not fetch upstream", relpath))

    local_path <- system.file(paste0("plumber/ejam-api/", relpath), package = "EJAM")
    local_bytes    <- readBin(local_path,    what = "raw", n = file.size(local_path))
    upstream_bytes <- readBin(upstream_file, what = "raw", n = file.size(upstream_file))
    expect_identical(
      local_bytes, upstream_bytes,
      label = paste0("inst/plumber/ejam-api/", relpath, " (raw bytes)"),
      expected.label = paste0("EJAM-API main ", relpath,
                              " (re-sync the mirror; see inst/plumber/ejam-api/SYNC.md)")
    )
  }
})
