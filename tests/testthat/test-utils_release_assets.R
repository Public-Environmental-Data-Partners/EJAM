gh_http_error <- function(status, message = paste0("GitHub HTTP error ", status)) {
  structure(
    class = c(paste0("http_error_", status), "http_error", "gh_error", "error", "condition"),
    list(message = message, call = NULL)
  )
}

test_that("github_error_status reads the status from the condition class", {
  expect_identical(EJAM:::github_error_status(gh_http_error(503)), 503L)
  expect_identical(EJAM:::github_error_status(gh_http_error(404)), 404L)
  expect_true(is.na(EJAM:::github_error_status(simpleError("Timeout was reached"))))
  expect_true(is.na(EJAM:::github_error_status("not a condition")))
})

test_that("github_error_is_transient separates try-again failures from real ones", {
  # worth retrying
  expect_true(EJAM:::github_error_is_transient(gh_http_error(500)))
  expect_true(EJAM:::github_error_is_transient(gh_http_error(502)))
  expect_true(EJAM:::github_error_is_transient(gh_http_error(503)))
  expect_true(EJAM:::github_error_is_transient(gh_http_error(429)))
  expect_true(EJAM:::github_error_is_transient(
    gh_http_error(403, "API rate limit exceeded for user")
  ))
  expect_true(EJAM:::github_error_is_transient(simpleError("Timeout was reached after 10s")))
  expect_true(EJAM:::github_error_is_transient(simpleError("Could not resolve host: api.github.com")))

  # not worth retrying
  expect_false(EJAM:::github_error_is_transient(gh_http_error(404)))
  expect_false(EJAM:::github_error_is_transient(gh_http_error(401)))
  expect_false(EJAM:::github_error_is_transient(gh_http_error(403, "Resource not accessible")))
  expect_false(EJAM:::github_error_is_transient(simpleError("something else went wrong")))
})

test_that("ejamdata_release_assets distinguishes a real listing from a failed one", {
  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      list(id = 7L, draft = FALSE, assets = list(
        list(name = "quaddata.arrow"), list(name = "bgej.arrow")
      ))
    },
    .package = "gh"
  )

  listing <- EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token"
  )
  expect_true(listing$ok)
  expect_identical(listing$status, "ok")
  expect_identical(listing$assets, c("quaddata.arrow", "bgej.arrow"))
  expect_identical(listing$n_assets, 2L)
  expect_null(EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow"))
})

test_that("ejamdata_release_assets calls an empty release empty, and says so distinctly", {
  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) list(id = 7L, draft = FALSE, assets = list()),
    .package = "gh"
  )

  listing <- EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token"
  )
  # the listing itself worked; the release is what is empty
  expect_true(listing$ok)
  expect_identical(listing$status, "release_empty")
  expect_identical(listing$n_assets, 0L)

  problem <- EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow")
  expect_true(grepl("has NO assets at all", problem))
  expect_true(grepl("genuinely empty release", problem))
})

test_that("ejamdata_release_assets retries transient failures with backoff, then gives up", {
  tries <- new.env(parent = emptyenv())
  tries$n <- 0L

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      tries$n <- tries$n + 1L
      stop(gh_http_error(503))
    },
    .package = "gh"
  )

  listing <- suppressMessages(EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token",
    max_tries = 3L,
    wait_seconds = 0
  ))

  expect_identical(tries$n, 3L)
  expect_false(listing$ok)
  expect_identical(listing$status, "api_error")
  expect_identical(listing$attempts, 3L)

  problem <- EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow")
  expect_true(grepl("Could not list assets for release v3.2022.0", problem))
  expect_true(grepl("failed after 3 attempts", problem))
  expect_true(grepl("UNREACHABLE rather than empty", problem))
})

test_that("ejamdata_release_assets retries until it succeeds", {
  tries <- new.env(parent = emptyenv())
  tries$n <- 0L

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      tries$n <- tries$n + 1L
      if (tries$n < 2L) stop(gh_http_error(502))
      list(id = 7L, draft = FALSE, assets = list(list(name = "quaddata.arrow")))
    },
    .package = "gh"
  )

  listing <- suppressMessages(EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token",
    max_tries = 3L,
    wait_seconds = 0
  ))

  expect_identical(tries$n, 2L)
  expect_true(listing$ok)
  expect_identical(listing$status, "ok")
})

test_that("ejamdata_release_assets does not retry a 404, and names it as a missing release", {
  tries <- new.env(parent = emptyenv())
  tries$n <- 0L

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      tries$n <- tries$n + 1L
      stop(gh_http_error(404, "Not Found"))
    },
    .package = "gh"
  )

  listing <- EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v9.9999.9",
    .token = "test-token",
    max_tries = 3L,
    wait_seconds = 0
  )

  expect_identical(tries$n, 1L)
  expect_identical(listing$status, "release_not_found")
  problem <- EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow")
  expect_true(grepl("does not exist \\(HTTP 404\\)", problem))
})

test_that("ejamdata_release_assets falls back to the paginated assets endpoint for big releases", {
  many <- paste0("asset", sprintf("%03d", 1:30), ".arrow")
  all_of_them <- c(many, "quaddata.arrow")

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      if (identical(endpoint, "GET /repos/{owner}/{repo}/releases/{release_id}/assets")) {
        return(lapply(all_of_them, function(nm) list(name = nm)))
      }
      # the release object itself shows only the first 30
      list(id = 7L, draft = FALSE, assets = lapply(many, function(nm) list(name = nm)))
    },
    .package = "gh"
  )

  listing <- EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token"
  )
  expect_identical(listing$n_assets, 31L)
  expect_true("quaddata.arrow" %in% listing$assets)
  expect_null(EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow"))
})

test_that("a short or failed paged assets answer never shrinks what the release object gave us", {
  many <- paste0("asset", sprintf("%03d", 1:30), ".arrow")

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      if (identical(endpoint, "GET /repos/{owner}/{repo}/releases/{release_id}/assets")) {
        return(list()) # the degraded-API symptom: HTTP 200 and an empty array
      }
      list(id = 7L, draft = FALSE, assets = lapply(many, function(nm) list(name = nm)))
    },
    .package = "gh"
  )

  listing <- EJAM:::ejamdata_release_assets(
    repository = "Public-Environmental-Data-Partners/ejamdata",
    tag = "v3.2022.0",
    .token = "test-token"
  )
  expect_identical(listing$n_assets, 30L)
  expect_identical(listing$status, "ok")
})

test_that("ejamdata_release_assets rejects a repository that is not owner/name", {
  listing <- EJAM:::ejamdata_release_assets(repository = "ejamdata", tag = "v3.2022.0")
  expect_false(listing$ok)
  expect_identical(listing$status, "bad_repository")
  expect_true(grepl(
    "Could not list assets",
    EJAM:::ejamdata_release_listing_problem(listing, needed = "quaddata.arrow")
  ))
})

test_that("the recorded download problem is appended to later dataset errors", {
  EJAM:::ejamdata_download_problem_clear()
  on.exit(EJAM:::ejamdata_download_problem_clear(), add = TRUE)

  expect_identical(EJAM:::ejamdata_download_problem_note(), "")

  EJAM:::ejamdata_download_problem_set("the GitHub API returned no assets")
  note <- EJAM:::ejamdata_download_problem_note()
  expect_true(grepl("did not succeed", note))
  expect_true(grepl("the GitHub API returned no assets", note))

  EJAM:::ejamdata_download_problem_clear()
  expect_identical(EJAM:::ejamdata_download_problem_note(), "")
})

test_that("piggyback_listing_cache_clear is a safe no-op when it cannot clear anything", {
  expect_silent(result <- EJAM:::piggyback_listing_cache_clear())
  expect_true(is.logical(result))
})
