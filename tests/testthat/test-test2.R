
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

test_that("test_ejam skips live URL and API groups by default", {
  default_skip_these <- eval(formals(EJAM:::test_ejam)$skip_these)

  expect_true(all(c("live_url", "live_api") %in% default_skip_these))
})
