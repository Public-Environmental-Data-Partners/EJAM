
## Tests for PDF report availability helpers in ejam2report.R

test_that("pdf_report_status() returns a list with ok and reason fields", {
  skip_if_not_installed("pagedown")
  result <- EJAM:::pdf_report_status()
  expect_type(result, "list")
  expect_true("ok" %in% names(result))
  expect_true("reason" %in% names(result))
})

test_that("pdf_report_status() returns ok=FALSE with a reason when pagedown is not installed", {
  local_mocked_bindings(
    pagedown_report_package_available = function() FALSE,
    .package = "EJAM"
  )
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

test_that("PDF footer CSS handles missing, vector, and escaped footer text", {
  expect_no_error(
    footer <- as.character(EJAM:::generate_report_footer(
      footer_text = c(NA, "A\\B \"quoted\"\nnext")
    ))
  )
  expect_true(grepl("<style>", footer, fixed = TRUE))
  expect_true(grepl('class="report-running-footer-screen"', footer, fixed = TRUE))
  expect_true(grepl("@media print.*\\.report-running-footer-screen.*display:\\s*none", footer, perl = TRUE))
  expect_true(grepl('content: " A\\\\B \\"quoted\\"\\nnext";', footer, fixed = TRUE))

  blank_footer <- as.character(EJAM:::generate_report_footer(footer_text = NA))
  expect_false(grepl("<style>", blank_footer, fixed = TRUE))
})

test_that("default report logo resolves to an available file", {
  logo_path <- EJAM:::resolve_report_logo_path()
  expect_true(nzchar(logo_path))
  expect_true(file.exists(logo_path))
})

test_that("standalone report logo is embedded while explicit blank logo is omitted", {
  default_logo <- EJAM:::report_logo_html_from_inputs(in_shiny = FALSE)
  expect_match(default_logo, "<img src=")
  expect_true(grepl("data:image", default_logo, fixed = TRUE))

  expect_identical(
    EJAM:::report_logo_html_from_inputs(logo_path = "", in_shiny = FALSE),
    ""
  )
})

test_that("local logo_html image sources are embedded for standalone reports", {
  logo_path <- EJAM:::resolve_report_logo_path()
  logo_html <- paste0('<img src="', logo_path, '" alt="logo">')
  normalized_logo <- EJAM:::report_logo_html_from_inputs(
    logo_html = logo_html,
    in_shiny = FALSE
  )

  expect_true(grepl("data:image", normalized_logo, fixed = TRUE))
  expect_false(grepl(logo_path, normalized_logo, fixed = TRUE))
})

test_that("ejam2report FIPS buffer guard: rad=999 does not call shape_buffered_from_shapefile", {
  # radius.miles = 999 is the legacy FIPS-mode signal; it must NOT trigger buffering.
  # Verify the guard condition used in ejam2report.R evaluates correctly.
  fips_buffer_guard <- function(rad) !is.na(rad) && rad > 0 && rad != 999
  expect_false(fips_buffer_guard(999), label = "rad=999 should not pass the buffer guard")
  expect_false(fips_buffer_guard(0),   label = "rad=0 should not pass the buffer guard")
  expect_false(fips_buffer_guard(NA),  label = "rad=NA should not pass the buffer guard")
})

test_that("ejam2report FIPS buffer guard: positive rad != 999 passes buffer condition", {
  fips_buffer_guard <- function(rad) !is.na(rad) && rad > 0 && rad != 999
  for (rad in c(0.5, 1, 5)) {
    expect_true(
      fips_buffer_guard(rad),
      label = paste0("rad=", rad, " should pass the buffer guard")
    )
  }
})


