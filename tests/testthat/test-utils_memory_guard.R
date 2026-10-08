## tests for memory_container_limit_bytes(), memory_cap_for_app(), analysis_error_message(), analysis_step_in_app()

test_that("memory_container_limit_bytes() reads cgroup v2 and v1 limits", {
  v2 <- withr::local_tempfile(lines = "6442450944")
  expect_equal(memory_container_limit_bytes(files = v2), 6442450944)

  v2_nolimit <- withr::local_tempfile(lines = "max")
  expect_true(is.na(memory_container_limit_bytes(files = v2_nolimit)))

  v1_nolimit <- withr::local_tempfile(lines = "9223372036854771712")
  expect_true(is.na(memory_container_limit_bytes(files = v1_nolimit)))

  # first file missing, second has a limit
  v1 <- withr::local_tempfile(lines = "7516192768")
  expect_equal(memory_container_limit_bytes(files = c(tempfile(), v1)), 7516192768)

  expect_true(is.na(memory_container_limit_bytes(files = tempfile())))
})

test_that("memory_cap_for_app() does nothing without a limit, or when R_MAX_VSIZE is set, or when the cap is too low", {
  withr::local_envvar(c(R_MAX_VSIZE = NA))
  before <- mem.maxVSize()
  expect_true(is.na(memory_cap_for_app(limit_bytes = NA, quiet = TRUE)))
  expect_true(is.na(memory_cap_for_app(limit_bytes = 1 * 1024^3, reserve_gb = 3, quiet = TRUE))) # cap would be negative
  expect_equal(mem.maxVSize(), before)

  withr::local_envvar(c(R_MAX_VSIZE = "100Gb"))
  expect_true(is.na(memory_cap_for_app(cap_gb = 50, quiet = TRUE)))
  expect_equal(mem.maxVSize(), before)
})

test_that("memory_cap_for_app() sets the cap to the container limit minus the reserve", {
  withr::local_envvar(c(R_MAX_VSIZE = NA))
  before <- mem.maxVSize()
  withr::defer(mem.maxVSize(before))
  inuse_gb <- sum(gc()[, 2]) / 1024
  # a cap far above what this R session uses, so the rest of the tests are not affected
  limit_gb <- ceiling(inuse_gb) + 103
  expect_message(capped <- memory_cap_for_app(limit_bytes = limit_gb * 1024^3, reserve_gb = 3), "memory cap")
  expect_equal(capped, limit_gb - 3)
  expect_equal(mem.maxVSize(), (limit_gb - 3) * 1024)
})

test_that("analysis_error_message() explains a memory error in plain language", {
  memerr <- simpleError("vector memory limit of 3.0 Gb reached, see mem.maxVSize()")
  expect_match(analysis_error_message(memerr), "needs more memory than this server allows")
  other <- simpleError("boom")
  expect_match(analysis_error_message(other), "stopped because of an error: boom")
})

test_that("analysis_step_in_app() returns the value, or a plain-language failure, and lets validate()/req() through", {
  expect_equal(analysis_step_in_app(1 + 1), 2)
  expect_message(
    failed <- analysis_step_in_app(stop("vector memory limit of 3.0 Gb reached, see mem.maxVSize()"), step = "buffering"),
    "buffering stopped with an error in the web app"
  )
  expect_s3_class(failed, "analysis_failed")
  expect_match(failed$message, "needs more memory than this server allows")
  expect_error(analysis_step_in_app(shiny::req(FALSE)), class = "shiny.silent.error")
})
