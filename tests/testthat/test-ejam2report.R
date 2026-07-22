
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

fips_report_test_output <- function(radius,
                                    valid = c(TRUE, TRUE),
                                    pop = c(10, 20),
                                    invalid_msg = rep("", length(valid))) {
  stopifnot(length(valid) == length(pop), length(valid) == length(invalid_msg))
  fips <- c("10001", "10003")[seq_along(valid)]
  list(
    sitetype = "fips",
    results_bysite = data.table::data.table(
      ejam_uniq_id = fips,
      valid = valid,
      invalid_msg = invalid_msg,
      pop = pop,
      radius.miles = radius,
      statename = rep("Delaware", length(valid))
    ),
    results_overall = data.table::data.table(
      ejam_uniq_id = "overall",
      valid = TRUE,
      invalid_msg = "",
      pop = sum(pop[valid %in% TRUE], na.rm = TRUE),
      radius.miles = radius,
      statename = "Delaware"
    )
  )
}

local_ejam2report_fips_mocks <- function(buffer_state, .env = parent.frame()) {
  local_mocked_bindings(
    shapes_from_fips = function(fips) {
      buffer_state$selected_fips <- c(buffer_state$selected_fips, fips)
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
    build_community_report = function(...) {
      args <- list(...)
      buffer_state$reported_fips <- c(
        buffer_state$reported_fips,
        as.character(args$output_df$ejam_uniq_id)
      )
      buffer_state$reported_pop <- c(buffer_state$reported_pop, args$output_df$pop)
      "<section>report</section>"
    },
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

test_that("ejam2report creates a report for an analysis-invalid zero-population site", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  buffer_state$selected_fips <- character()
  buffer_state$reported_fips <- character()
  buffer_state$reported_pop <- numeric()
  local_ejam2report_fips_mocks(buffer_state)

  out <- fips_report_test_output(
    radius = 1,
    valid = FALSE,
    pop = 0,
    invalid_msg = "blocks found but zero residents"
  )

  expect_no_error(
    result <- ejam2report(
      out,
      sitenumber = 1,
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_match(result, "<html>report</html>", fixed = TRUE)
  expect_equal(buffer_state$reported_pop, 0)
})

test_that("ejam2report selects the actual valid row when only one site is valid", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  buffer_state$selected_fips <- character()
  buffer_state$reported_fips <- character()
  buffer_state$reported_pop <- numeric()
  local_ejam2report_fips_mocks(buffer_state)

  out <- fips_report_test_output(
    radius = 1,
    valid = c(FALSE, TRUE),
    pop = c(0, 20),
    invalid_msg = c("blocks with residents found but unable to aggregate", "")
  )

  expect_no_error(
    ejam2report(
      out,
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_equal(buffer_state$selected_fips, "10003")
  expect_equal(buffer_state$reported_fips, "10003")
  expect_equal(buffer_state$reported_pop, 20)
})

test_that("ejam2report only treats known no-results messages as reportable", {
  recognized_messages <- unname(EJAM:::ejamit_reportable_invalid_messages())
  recognized_results <- lapply(recognized_messages, function(message) {
    data.frame(valid = FALSE, pop = 0, invalid_msg = message)
  })
  invalid_input <- data.frame(
    valid = FALSE,
    pop = 0,
    invalid_msg = "invalid FIPS"
  )

  expect_true(all(vapply(
    recognized_results,
    EJAM:::ejam2report_site_is_reportable,
    logical(1)
  )))
  expect_false(EJAM:::ejam2report_site_is_reportable(invalid_input))
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

test_that("ejam2report passes sitenumber_label through to the report header helper (issue #348)", {
  # (Public-Environmental-Data-Partners/EJAM#348) The API's per-site report links
  # re-analyze one site that was row N of a larger analysis; ejam2report() must hand
  # the display label to report_residents_within_xyz_from_ejamit() so the header
  # says "Site N" instead of "Site 1", and to the map builder so the marker popup
  # says "Site N" too.
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    shapes_from_fips = function(fips) data.frame(fips = fips),
    shape_buffered_from_shapefile = function(shapefile, radius.miles, ...) shapefile,
    fips2name = function(fips) paste("FIPS", fips),
    report_residents_within_xyz_from_ejamit = function(..., sitenumber_label = NULL) {
      seen$label <- sitenumber_label
      "residents"
    },
    report_setup_temp_files = function(...) "template.Rmd",
    create_filename = function(...) "report.html",
    build_community_report = function(...) "<section>report</section>",
    plot_barplot_ratios_ez = function(...) ggplot2::ggplot(),
    ejam2map = function(..., sitenumber_label = NULL) {
      seen$maplabel <- sitenumber_label
      "map"
    },
    ensure_pandoc_available_for_ejam = function(...) invisible(TRUE),
    .package = "EJAM"
  )
  local_mocked_bindings(
    pandoc_available = function(...) TRUE,
    render = function(input, output_format, output_file, params, envir, quiet, ...) {
      writeLines("<html>report</html>", output_file)
      output_file
    },
    .package = "rmarkdown"
  )

  expect_no_error(
    ejam2report(
      fips_report_test_output(radius = 1),
      sitenumber = 1,
      sitenumber_label = 7,
      report_title = "Report",
      analysis_title = "Analysis",
      return_html = TRUE,
      launch_browser = FALSE
    )
  )
  expect_equal(seen$label, 7)
  expect_equal(seen$maplabel, 7)
})


########################### #

# TESTS OF filename and fileextension handling ####

test_that("ejam2report() writes actual report content when filename is provided", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")
  outfile <- file.path(tempdir(), "content_check_471.html")
  on.exit(unlink(outfile), add = TRUE)
  result <- ejam2report(
    ejamitout = testoutput_ejamit_10pts_1miles,
    analysis_title = "CONTENT MARKER PR 471",
    filename = outfile, launch_browser = FALSE
  )
  expect_true(file.exists(result))
  html <- paste(readLines(result, warn = FALSE), collapse = "\n")
  expect_match(html, "CONTENT MARKER PR 471", fixed = TRUE)
})


### more tests/ checks of ejam2report() function, for checking various cases, locally
### not as unit tests, since paths are not generic

if (FALSE) {

  out = testoutput_ejamit_10pts_1miles

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "defaults")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename.html_only", filename = "test.html")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename.pdf_only", filename = "test.pdf")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename.pdf_but_fileextension=.html", filename = "test.pdf", fileextension = ".html")
  file.exists(x)


  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename 1 word only, no path no extension", filename = "testword") # interprets as file name
  file.exists(x)
  pause(2)       # without pause, it cannot show up in browser before it is deleted.
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename empty", filename = "")
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename . only", filename = ".")
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename .. only", filename = "..")
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename .. slash blah only", filename = "../blah")
  file.exists(x)
  pause(2)
  file.remove(x)

  # handle slash in title which becomes part of filename?
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "valid folder ./inst only", filename = "./inst")
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "valid folder dot slash inst only", filename = "./inst")
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "valid folder squiggle slash Downloads only", filename = "~/Downloads")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "valid folder ~/Downloads/ only", filename = "~/Downloads/")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "valid folder ~/Downloads/ only", filename = "~/Downloads/test1")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "full path with filename.html", filename = "~/Downloads/test2.html")
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "path ends with badpathword only", filename = "~/Downloads/badpathword") # interprets as file name
  file.exists(x)
  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "full path with filename no extension", filename = "~/Downloads/testword") # interprets as file name
  file.exists(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename is vector", filename = c("a","b"))
  x
  file.exists(x)
  pause(2)
  file.remove(x)

  x = ejam2report(testoutput_ejamit_10pts_1miles, analysis_title = "filename is NULL", filename = NULL)
  x
  file.exists(x)
  pause(2)
  file.remove(x)

}

