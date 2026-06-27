
# used to check EJAM:::test_ejam() etc.
test_that("test2a works", {
  expect_true(
    TRUE
  )
})

test_that("test2b works", {
  expect_false(
    FALSE
  )
})

test_that("test_ejam skips live URL, live API, and local API groups by default", {
  default_skip_these <- eval(formals(EJAM:::test_ejam)$skip_these)

  expect_true(all(c("live_url", "live_api", "local_api") %in% default_skip_these))
})

test_that("test_ejam detects when selected groups require live network access", {
  expect_false(EJAM:::test_ejam_requests_live_groups(skip_these = c("live_url", "live_api")))
  expect_true(EJAM:::test_ejam_requests_live_groups(skip_these = "live_url"))
  expect_true(EJAM:::test_ejam_requests_live_groups(skip_these = NULL))
  expect_true(EJAM:::test_ejam_requests_live_groups(y_runsome = TRUE, run_these = "live_api"))
  expect_true(EJAM:::test_ejam_requests_live_groups(run_these = "live_url"))
  expect_false(EJAM:::test_ejam_requests_live_groups(y_runsome = TRUE, run_these = c("url", "local_api")))
  expect_false(EJAM:::test_ejam_requests_live_groups(y_runall = FALSE, y_runsome = FALSE))
})
