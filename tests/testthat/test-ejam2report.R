
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
  expect_true(grepl("@media print[\\s\\S]*\\.report-running-footer-screen[\\s\\S]*display:\\s*none", footer, perl = TRUE))
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

test_that("ejam2report() returns an absolute path when filename has no directory or uses './'", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")

  tmpdir <- tempdir()
  outfile_bare   <- file.path(tmpdir, "bare_filename_test.html")
  outfile_dotslash <- file.path(tmpdir, "dotslash_filename_test.html")
  on.exit({
    unlink(outfile_bare)
    unlink(outfile_dotslash)
  }, add = TRUE)

  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(tmpdir)

  # filename with no directory component (just a bare name)
  result_bare <- ejam2report(
    ejamitout = testoutput_ejamit_10pts_1miles,
    filename = "bare_filename_test.html",
    return_html = FALSE,
    launch_browser = FALSE
  )
  expect_true(file.exists(result_bare))
  expect_false(is.na(result_bare))
  # The returned path must be absolute (not relative)
  expect_true(startsWith(result_bare, "/") || grepl("^[A-Za-z]:", result_bare))

  # filename using "./" prefix
  result_dotslash <- ejam2report(
    ejamitout = testoutput_ejamit_10pts_1miles,
    filename = "./dotslash_filename_test.html",
    return_html = FALSE,
    launch_browser = FALSE
  )
  expect_true(file.exists(result_dotslash))
  expect_false(is.na(result_dotslash))
  expect_true(startsWith(result_dotslash, "/") || grepl("^[A-Za-z]:", result_dotslash))
})

fips_report_test_output <- function(radius) {
  list(
    sitetype = "fips",
    results_bysite = data.table::data.table(
      ejam_uniq_id = c("10001", "10003"),
      valid = c(TRUE, TRUE),
      pop = c(10, 20),
      radius.miles = radius,
      statename = c("Delaware", "Delaware")
    ),
    results_overall = data.table::data.table(
      ejam_uniq_id = "overall",
      valid = TRUE,
      pop = 30,
      radius.miles = radius,
      statename = "Delaware"
    )
  )
}

local_ejam2report_fips_mocks <- function(buffer_state, .env = parent.frame()) {
  local_mocked_bindings(
    shapes_from_fips = function(fips) {
      data.frame(fips = fips)
    },
    shape_buffered_from_shapefile = function(shapefile, radius.miles, ...) {
      buffer_state$radii <- c(buffer_state$radii, radius.miles)
      shapefile
    },
    fips2name = function(fips) paste("FIPS", fips),
    report_residents_within_xyz_from_ejamit = function(...) "residents",
    report_setup_temp_files = function(...) "template.Rmd",
    create_filename = function(...) "report.html",
    build_community_report = function(...) "<section>report</section>",
    plot_barplot_ratios_ez = function(...) ggplot2::ggplot(),
    ejam2map = function(...) "map",
    ensure_pandoc_available_for_ejam = function(...) invisible(TRUE),
    .package = "EJAM",
    .env = .env
  )
  local_mocked_bindings(
    pandoc_available = function(...) TRUE,
    render = function(input, output_format, output_file, params, envir, quiet, ...) {
      writeLines("<html>report</html>", output_file)
      output_file
    },
    .package = "rmarkdown",
    .env = .env
  )
}

test_that("ejam2report buffers FIPS shapes for positive radius in production paths", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  local_ejam2report_fips_mocks(buffer_state)

  expect_no_error(
    ejam2report(
      fips_report_test_output(radius = 1),
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_no_error(
    ejam2report(
      fips_report_test_output(radius = 1),
      sitenumber = 1,
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_equal(buffer_state$radii, c(1, 1))
})

test_that("ejam2report does not buffer FIPS shapes for legacy radius 999", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  local_ejam2report_fips_mocks(buffer_state)

  expect_no_error(
    ejam2report(
      fips_report_test_output(radius = 999),
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_no_error(
    ejam2report(
      fips_report_test_output(radius = 999),
      sitenumber = 1,
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_length(buffer_state$radii, 0)
})

test_that("ejam2report normalizes default_format1pager fallback without a leading dot", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  local_ejam2report_fips_mocks(buffer_state)
  local_mocked_bindings(
    global_or_param = function(...) "pdf",
    create_filename = function(..., ext) paste0("report", ext),
    assert_pdf_report_available = function(...) invisible(TRUE),
    .package = "EJAM"
  )

  expect_warning(
    result <- ejam2report(
      fips_report_test_output(radius = 1),
      fileextension = "docx",
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = FALSE,
      launch_browser = FALSE
    ),
    regexp = "fileextension must be one of",
    fixed = TRUE
  )
  expect_match(basename(result), "\\.pdf$")
})
############################################################################## #

# flagged-areas section of the report (% of residents with feature/area type in their blockgroup) ####

flagged_section_title_text <- "Who Have This Feature or Area Type in (or Overlapping) Their Blockgroup"

test_that("build_community_report() includes flagged-areas section when df provided, omits when NULL", {

  out <- testoutput_ejamit_10pts_1miles
  junk <- capture.output({
    fa <- EJAM:::calc_flagged_areas(out$results_bysite, out$results_bybg_people)
  })

  html_with <- build_community_report(
    output_df = out$results_overall,
    totalpop = 1234,
    analysis_title = "test", report_title = "test",
    flagged_areas_df = fa
  )
  txt <- as.character(html_with)
  expect_true(grepl(flagged_section_title_text, txt, fixed = TRUE))
  expect_true(grepl("Overlapping with Tribes", txt, fixed = TRUE))
  # new section sits after the Features and Location Information section subheader
  expect_true(regexpr(flagged_section_title_text, txt, fixed = TRUE) >
                regexpr("Features and Location Information", txt, fixed = TRUE))
  # the two percentage indicators are excluded from the new section (they stay under Critical Services):
  # inspect just the new section = from its title to the next section subheader after it
  section_start <- regexpr(flagged_section_title_text, txt, fixed = TRUE)
  after_section <- substr(txt, section_start, nchar(txt))
  next_subheader <- regexpr('class="color-alt-table-subheader"', after_section, fixed = TRUE)
  section_txt <- substr(after_section, 1, next_subheader)
  expect_true(grepl("Any schools", section_txt, fixed = TRUE))
  expect_false(grepl("Broadband", section_txt, fixed = TRUE))
  expect_false(grepl("Health Insurance", section_txt, fixed = TRUE))

  html_without <- build_community_report(
    output_df = out$results_overall,
    totalpop = 1234,
    analysis_title = "test", report_title = "test",
    flagged_areas_df = NULL
  )
  expect_false(grepl(flagged_section_title_text, as.character(html_without), fixed = TRUE))
})
############################################################################## #

test_that("ejam2report() shows flagged-areas section in multisite AND single-site reports", {

  skip_if_not(
    EJAM:::ensure_pandoc_available_for_ejam(),
    message = "Pandoc is required to render the report"
  )
  out <- testoutput_ejamit_10pts_1miles

  suppressWarnings({
    html_multi <- ejam2report(out, return_html = TRUE, launch_browser = FALSE)
  })
  expect_true(grepl(flagged_section_title_text, html_multi, fixed = TRUE))

  suppressWarnings({
    html_1site <- ejam2report(out, sitenumber = 1, return_html = TRUE, launch_browser = FALSE)
  })
  expect_true(grepl(flagged_section_title_text, html_1site, fixed = TRUE))
})
############################################################################## #

test_that("ejam2report() still works when flagged-areas info is unavailable (older saved outputs)", {

  skip_if_not(
    EJAM:::ensure_pandoc_available_for_ejam(),
    message = "Pandoc is required to render the report"
  )
  out <- testoutput_ejamit_10pts_1miles
  out$results_summarized <- NULL
  out$results_bybg_people <- NULL

  suppressWarnings({
    html_multi <- ejam2report(out, return_html = TRUE, launch_browser = FALSE)
  })
  expect_false(grepl(flagged_section_title_text, html_multi, fixed = TRUE))
  expect_true(grepl("Features and Location Information", html_multi, fixed = TRUE)) # rest of report still there
})
