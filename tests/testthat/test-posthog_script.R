## posthog_script() adds the PostHog analytics tag only where a project key is
## configured, so local runs, tests, and CI send nothing to PostHog.

test_that("posthog_script() adds nothing when no key is configured", {
  withr::local_envvar(EJAM_POSTHOG_KEY = NA)
  expect_null(EJAM:::posthog_script())
  expect_null(EJAM:::posthog_script(""))
  expect_null(EJAM:::posthog_script(NA_character_))
})

test_that("posthog_script() uses the EJAM_POSTHOG_KEY environment variable", {
  withr::local_envvar(EJAM_POSTHOG_KEY = "phc_testKEY123")
  s <- as.character(EJAM:::posthog_script())
  expect_true(startsWith(s, "<script>"))
  expect_true(grepl("posthog.init('phc_testKEY123'", s, fixed = TRUE))
})

test_that("posthog_script() refuses anything but a phc_ project key", {
  expect_warning(x <- EJAM:::posthog_script("phx_personalSecret"), "phc_")
  expect_null(x)
  expect_warning(x <- EJAM:::posthog_script("phc_a'});alert(1);//"), "phc_")
  expect_null(x)
})
