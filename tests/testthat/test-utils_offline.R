# test-utils_offline.R
# offline() must not report "offline" because one DNS lookup failed once.
# These tests replace the lookup with a fake, so they need no network.

test_that("offline() is FALSE when the first lookup succeeds", {
  calls <- character(0)
  local_mocked_bindings(offline_host_resolves = function(host) {
    calls <<- c(calls, host)
    TRUE
  })
  expect_false(offline(cache_seconds = 0, wait = 0))
  expect_equal(calls, "r-project.org")
})

test_that("offline() tries the fallback hosts before giving up", {
  local_mocked_bindings(offline_host_resolves = function(host) host == "census.gov")
  expect_false(offline(cache_seconds = 0, wait = 0))
})

test_that("offline() retries, so one failed lookup round is not enough", {
  n <- 0
  local_mocked_bindings(offline_host_resolves = function(host) {
    n <<- n + 1
    n > 3 # every host fails in the first round, then the first retry works
  })
  expect_false(offline(cache_seconds = 0, wait = 0))
  expect_equal(n, 4)
})

test_that("offline() is TRUE only after every host fails in every round", {
  n <- 0
  local_mocked_bindings(offline_host_resolves = function(host) {
    n <<- n + 1
    FALSE
  })
  expect_true(offline(cache_seconds = 0, wait = 0, tries = 3))
  expect_equal(n, 9) # 3 hosts x 3 rounds
})

test_that("offline() reuses a recent answer, so repeated checks agree", {
  n <- 0
  local_mocked_bindings(offline_host_resolves = function(host) {
    n <<- n + 1
    TRUE
  })
  hosts <- paste0("test-cache-", as.numeric(Sys.time()), ".invalid")
  expect_false(offline(url = hosts, cache_seconds = 60, wait = 0))
  expect_false(offline(url = hosts, cache_seconds = 60, wait = 0))
  expect_equal(n, 1)
  expect_false(offline(url = hosts, cache_seconds = 0, wait = 0))
  expect_equal(n, 2)
})

test_that("offline_host_resolves() treats a lookup error as not resolved", {
  local_mocked_bindings(nslookup = function(...) stop("resolver exploded"), .package = "curl")
  expect_false(offline_host_resolves("example.invalid"))
})
