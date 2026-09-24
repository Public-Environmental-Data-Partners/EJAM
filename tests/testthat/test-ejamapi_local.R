
# see ?ejamapi() and test-ejamapi.R for testing the wrapper that is an interface to
#   the "report" and "data" endpoints, using GET and POST, for the live EJAM API that is hosted on a server.

# see ?url_ejamapi() and test-url_ejamapi.R for testing the utility that provides a URL
#   (that handles the "report" endpoint, and is designed to work in the live EJAM API that is hosted on a server).

# see ?ejamapi_local() and this file for testing the API served locally by the EJAM package:
#   the root paths (/report, /data, /query, /handoff, ...) are a verbatim mirror of the
#   deployed EJAM-API repo (see inst/plumber/ejam-api/SYNC.md), and the DRAFT-ONLY
#   endpoints are mounted at /draft/... (see inst/plumber/draft/plumber.R).
# Parse/inventory tests of those files that do NOT start a server are in test-plumber-api.R.

testthat::skip_if_not(
  identical(tolower(Sys.getenv("EJAM_TEST_LOCAL_API")), "true"),
  "local Plumber API tests require EJAM_TEST_LOCAL_API=true and port 3035"
)

# Start the API in the background only when these local-server tests are
# explicitly requested. The public API tests live in test-ejamapi.R.
# Prefer the source checkout's files, so this exercises the draft router being
# edited rather than a stale installed copy. testthat runs from tests/testthat,
# so the checkout's inst/ is two levels up; fall back to the installed copy
# (e.g., under R CMD check, where there is no source tree).
src_or_installed <- function(...) {
  src <- testthat::test_path("..", "..", "inst", ...)
  if (file.exists(src)) src else system.file(..., package = "EJAM")
}
apiproc <- EJAM:::ejamapi_local(
  fname = src_or_installed("plumber", "ejam-api", "rest_controller.r"),
  draftfile = src_or_installed("plumber", "draft", "plumber.R"),
  launch_browser = FALSE
)
withr::defer(try(apiproc$kill(), silent = TRUE), teardown_env())

host <- "127.0.0.1"
port <- 3035  #   browseURL("http://127.0.0.1:3035/__docs__/")
baseurl <- paste0("http://", host, ":", port)

test_that("API root redirects to the interactive docs, like the deployed API", {
  resp <- httr::GET(baseurl)
  expect_equal(httr::status_code(resp), 200)
  # httr follows the 302; the final URL is the Swagger docs page
  expect_true(grepl("__docs__", resp$url))
})

test_that("/handoff round trip works locally (mirror of deployed endpoint)", {
  resp <- httr::POST(paste0(baseurl, "/handoff"),
                     body = list(fips = list("10001")), encode = "json")
  expect_equal(httr::status_code(resp), 200)
  tok <- httr::content(resp)
  # extract + normalize first: if the response ever lacks `token`, indexing
  # NULL[[1]] would ERROR the test rather than fail the expectation cleanly
  token <- tok$token
  if (is.list(token)) token <- unlist(token, use.names = FALSE)
  expect_true(is.character(token) && length(token) >= 1 && nzchar(token[[1]]))
  resp2 <- httr::GET(paste0(baseurl, "/handoff/", token[[1]]))
  expect_equal(httr::status_code(resp2), 200)
  payload <- httr::content(resp2)
  expect_equal(payload$fips[[1]], "10001")
  # fips-only handoff stores an explicit radius 0 (EJAM-API#49)
  expect_equal(payload$radius[[1]], 0)
})

test_that("/draft/echo endpoint", {
  urlx <- paste0(baseurl, "/draft/echo?msg=heyo")
  echo_resp <- httr::GET(urlx)
  expect_equal(httr::status_code(echo_resp), 200)
  expect_equal(httr::headers(echo_resp)[["content-type"]], "application/json")
  expect_equal(httr::content(echo_resp)[["msg"]][[1]], "The message is: 'heyo'")
})

test_that("/draft/getblocksnearby endpoint", {
  urlx <- paste0(baseurl, "/draft/getblocksnearby?lat=33&lon=-95&radius=3.14")
  resp <- httr::GET(urlx)
  expect_equal(httr::status_code(resp), 200)
  expect_equal(httr::headers(resp)[["content-type"]], "application/json")

  s2b <- data.table::rbindlist(httr::content(resp))
  expect_true(NROW(s2b) > 100)
  expect_true(all(c("ejam_uniq_id", "blockid", "distance") %in% colnames(s2b)))
  expect_true(
    all(s2b$distance <= 3.14 & !is.na(s2b$distance & s2b$distance > 0))
  )
  expect_true(
    all(unique(s2b$ejam_uniq_id) == 1)
  )
})

test_that("/draft/ejamit rejects obsolete test mode and returns a versioned bundle", {
  # Endpoint behavior must exercise the source draft router.  A real analysis
  # is intentionally not run here: it depends on local data and is covered in
  # a data-enabled integration environment.
  resp <- httr::GET(paste0(baseurl, "/draft/ejamit?test=true"))
  expect_equal(httr::status_code(resp), 400)
  # 400 for the right reason: the retired test mode, not a missing location
  expect_match(httr::content(resp, as = "parsed")$error$message, "test mode is no longer supported")
})

# Every request below has a timeout, so a stuck server fails the test instead
# of hanging the run.
test_that("/draft/reportnew rejects a non-report fileextension", {
  resp <- httr::GET(paste0(baseurl, "/draft/reportnew?fips=10001&fileextension=xlsx"), httr::timeout(60))
  expect_equal(httr::status_code(resp), 400)
  expect_match(httr::headers(resp)[["content-type"]], "text/html")
  expect_match(httr::content(resp, as = "text", encoding = "UTF-8"), "fileextension must be html or pdf")
})

test_that("/draft/excel errors come back as JSON, not through the xlsx serializer", {
  resp <- httr::GET(paste0(baseurl, "/draft/excel?lat=999&lon=-75.52"), httr::timeout(60))
  expect_equal(httr::status_code(resp), 400)
  expect_match(httr::headers(resp)[["content-type"]], "application/json")
  expect_match(httr::content(resp, as = "parsed")$error$message, "valid coordinates")
})

# These run a real analysis (a populated 1-mile circle in Dover, DE), so they
# need the arrow data. They use the json and html outputs only: xlsx and pdf
# rendering launch headless Chrome (webshot2 / chrome_print), which can hang
# inside a background server process on some machines.
test_that("/draft/all returns a ZIP of the requested outputs plus a manifest", {
  resp <- httr::GET(paste0(baseurl, "/draft/all?lat=39.16&lon=-75.52&radius=1&outputs=json,html"), httr::timeout(300))
  expect_equal(httr::status_code(resp), 200)
  expect_match(httr::headers(resp)[["content-type"]], "application/zip")
  expect_match(httr::headers(resp)[["content-disposition"]], "^attachment")
  zf <- tempfile(fileext = ".zip")
  exdir <- tempfile("zip-")
  withr::defer(unlink(c(zf, exdir), recursive = TRUE))
  writeBin(httr::content(resp, as = "raw"), zf)
  expect_setequal(utils::unzip(zf, list = TRUE)$Name, c("EJAM_analysis.json", "EJAM_results.html", "manifest.json"))
  manifest <- jsonlite::fromJSON(utils::unzip(zf, "manifest.json", exdir = exdir))
  expect_equal(manifest$schema_version, "ejam-analysis-v1")
  expect_setequal(manifest$files$filename, c("EJAM_analysis.json", "EJAM_results.html"))
  expect_equal(manifest$parameters$radius, 1)
})

test_that("/draft/all with one output returns that file, not a ZIP", {
  resp <- httr::GET(paste0(baseurl, "/draft/all?lat=39.16&lon=-75.52&buffer=1&outputs=json"), httr::timeout(300))
  expect_equal(httr::status_code(resp), 200)
  expect_match(httr::headers(resp)[["content-type"]], "application/json")
  expect_match(httr::headers(resp)[["content-disposition"]], "^attachment")
  bundle <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))
  expect_equal(bundle$schema_version, "ejam-analysis-v1")
  expect_equal(bundle$parameters$radius, 1) # from the buffer alias
})

test_that("/draft/reportnew serves an HTML report inline", {
  resp <- httr::GET(paste0(baseurl, "/draft/reportnew?lat=39.16&lon=-75.52&radius=1&fileextension=html"), httr::timeout(300))
  expect_equal(httr::status_code(resp), 200)
  expect_match(httr::headers(resp)[["content-type"]], "text/html")
  expect_match(httr::headers(resp)[["content-disposition"]], "^inline")
})
