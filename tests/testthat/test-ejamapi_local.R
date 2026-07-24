
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
apiproc <- EJAM:::ejamapi_local(launch_browser = FALSE)
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

test_that("/draft/ejamit endpoint", {
  # test=true returns a precalculated sample result quickly
  urlx <- paste0(baseurl, "/draft/ejamit?test=true")
  resp <- httr::GET(urlx)
  expect_equal(httr::status_code(resp), 200)
  out <- httr::content(resp)
  expect_true(length(out) > 0)
})
