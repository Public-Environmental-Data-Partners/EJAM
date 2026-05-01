
## Tests for PDF report availability helpers in ejam2report.R

test_that("pdf_report_status() returns a list with ok and reason fields", {
  skip_if_not_installed("pagedown")
  result <- EJAM:::pdf_report_status()
  expect_type(result, "list")
  expect_true("ok" %in% names(result))
  expect_true("reason" %in% names(result))
})

test_that("pdf_report_status() returns ok=FALSE with a reason when pagedown is not installed", {
  skip_if(requireNamespace("pagedown", quietly = TRUE),
          message = "pagedown is installed; skipping test for missing-package path")
  result <- EJAM:::pdf_report_status()
  expect_false(isTRUE(result$ok))
  expect_true(nzchar(result$reason))
  expect_match(result$reason, "pagedown", ignore.case = TRUE)
})

test_that("assert_pdf_report_available() stops with a descriptive message when PDF is unavailable", {
  # Force the unavailable path by mocking pdf_report_status() to return not-ok.
  # This exercises the stop() path regardless of whether Chrome is installed.
  local_mocked_bindings(
    pdf_report_status = function() list(ok = FALSE, reason = "Chrome is not available."),
    .package = "EJAM"
  )
  expect_error(
    EJAM:::assert_pdf_report_available(),
    regexp = "Chrome is not available"
  )
})
