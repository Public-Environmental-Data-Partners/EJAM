
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

test_that("ejam2report() routes a bare filename to tempdir() and a './' filename to the working dir", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc not available")

  # work from a SUBFOLDER of tempdir() so the test can tell apart
  # "saved in tempdir()" (bare name) from "saved in working dir" ("./" name)
  workdir <- file.path(tempdir(), "wd_for_filename_routing_test")
  dir.create(workdir, showWarnings = FALSE)
  outfile_bare     <- file.path(tempdir(), "bare_filename_test.html")
  outfile_dotslash <- file.path(workdir, "dotslash_filename_test.html")
  on.exit({
    unlink(outfile_bare)
    unlink(workdir, recursive = TRUE)
  }, add = TRUE)

  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(workdir)

  # filename with no directory component (just a bare name) is saved in tempdir()
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
  expect_true(file.exists(outfile_bare))                                       # went to tempdir()
  expect_false(file.exists(file.path(workdir, "bare_filename_test.html")))     # not to the working dir

  # filename using "./" prefix is saved in the working dir, with the name unmangled
  result_dotslash <- ejam2report(
    ejamitout = testoutput_ejamit_10pts_1miles,
    filename = "./dotslash_filename_test.html",
    return_html = FALSE,
    launch_browser = FALSE
  )
  expect_true(file.exists(result_dotslash))
  expect_false(is.na(result_dotslash))
  expect_true(startsWith(result_dotslash, "/") || grepl("^[A-Za-z]:", result_dotslash))
  expect_identical(basename(result_dotslash), "dotslash_filename_test.html")   # no "._" mangling
  expect_true(file.exists(outfile_dotslash))                                   # went to the working dir
  expect_false(file.exists(file.path(tempdir(), "dotslash_filename_test.html")))
  expect_false(file.exists(file.path(tempdir(), "._dotslash_filename_test.html")))
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
  # new section sits after the Climate section subheader (which follows Poverty)
  # and before the Counts of Features and Overlap with Area Types section
  expect_true(regexpr(flagged_section_title_text, txt, fixed = TRUE) >
                regexpr(">Climate<", txt, fixed = TRUE))
  expect_true(regexpr(flagged_section_title_text, txt, fixed = TRUE) <
                regexpr("Counts of Features and Overlap with Area Types", txt, fixed = TRUE))
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
  expect_true(grepl("Counts of Features and Overlap with Area Types", html_multi, fixed = TRUE)) # rest of report still there
})
############################################################################## #

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

test_that("ejam2report tolerates NULL, empty, or vector fileextension by falling back to html", {
  buffer_state <- new.env(parent = emptyenv())
  buffer_state$radii <- numeric()
  local_ejam2report_fips_mocks(buffer_state)

  expect_no_error(
    ejam2report(fips_report_test_output(radius = 1), report_title = "Report",
                analysis_title = "Analysis", return_html = TRUE, launch_browser = FALSE,
                fileextension = NULL)
  )
  expect_no_error(
    ejam2report(fips_report_test_output(radius = 1), report_title = "Report",
                analysis_title = "Analysis", return_html = TRUE, launch_browser = FALSE,
                fileextension = character(0))
  )
  expect_warning(
    ejam2report(fips_report_test_output(radius = 1), report_title = "Report",
                analysis_title = "Analysis", return_html = TRUE, launch_browser = FALSE,
                fileextension = c("html", "pdf")),
    "single value"
  )
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

################ ################# ################# ################# ################# #

# pdf_wait_seconds() - configurable pauses used while making a PDF report ####

testthat::test_that("pdf_wait_seconds() returns the trimmed defaults", {

  withr::with_options(list(EJAM.pdf_map_snapshot_delay = NULL, EJAM.pdf_print_wait = NULL), {
    withr::with_envvar(list(EJAM_PDF_MAP_SNAPSHOT_DELAY = NA, EJAM_PDF_PRINT_WAIT = NA), {
      expect_equal(EJAM:::pdf_wait_seconds("map_snapshot"), 1)
      expect_equal(EJAM:::pdf_wait_seconds("print"), 2)
    })
  })
})

testthat::test_that("PDF waits have named package defaults", {

  expect_equal(global_or_param("pdf_map_snapshot_delay"), 1)
  expect_equal(global_or_param("pdf_print_wait"), 2)
})

testthat::test_that("pdf_wait_seconds() uses package defaults after option and environment", {

  local_mocked_bindings(
    global_or_param = function(vname) {
      switch(vname,
             pdf_map_snapshot_delay = 1.25,
             pdf_print_wait = 2.25)
    },
    .package = "EJAM"
  )
  withr::with_options(list(EJAM.pdf_map_snapshot_delay = NULL,
                           EJAM.pdf_print_wait = NULL), {
    withr::with_envvar(list(EJAM_PDF_MAP_SNAPSHOT_DELAY = NA,
                            EJAM_PDF_PRINT_WAIT = NA), {
      expect_equal(EJAM:::pdf_wait_seconds("map_snapshot"), 1.25)
      expect_equal(EJAM:::pdf_wait_seconds("print"), 2.25)
    })
  })
})

testthat::test_that("pdf_wait_seconds() can be raised via an R option", {

  withr::with_options(list(EJAM.pdf_map_snapshot_delay = 6, EJAM.pdf_print_wait = 7), {
    expect_equal(EJAM:::pdf_wait_seconds("map_snapshot"), 6)
    expect_equal(EJAM:::pdf_wait_seconds("print"), 7)
  })
})

testthat::test_that("pdf_wait_seconds() can be raised via an environment variable", {

  # this is the one that matters on the API server, where a container can set an
  # env var but cannot easily be rebuilt just to change a number
  withr::with_options(list(EJAM.pdf_map_snapshot_delay = NULL, EJAM.pdf_print_wait = NULL), {
    withr::with_envvar(list(EJAM_PDF_MAP_SNAPSHOT_DELAY = "3.5", EJAM_PDF_PRINT_WAIT = "4"), {
      expect_equal(EJAM:::pdf_wait_seconds("map_snapshot"), 3.5)
      expect_equal(EJAM:::pdf_wait_seconds("print"), 4)
    })
  })
})

testthat::test_that("pdf_wait_seconds() option beats environment variable", {

  withr::with_options(list(EJAM.pdf_print_wait = 9), {
    withr::with_envvar(list(EJAM_PDF_PRINT_WAIT = "3"), {
      expect_equal(EJAM:::pdf_wait_seconds("print"), 9)
    })
  })
})

testthat::test_that("pdf_wait_seconds() skips unusable higher-precedence values", {

  local_mocked_bindings(
    global_or_param = function(vname) {
      switch(vname,
             pdf_map_snapshot_delay = 1.25,
             pdf_print_wait = 2.25)
    },
    .package = "EJAM"
  )
  withr::with_options(list(EJAM.pdf_print_wait = "junk"), {
    withr::with_envvar(list(EJAM_PDF_PRINT_WAIT = "3.5"), {
      expect_equal(EJAM:::pdf_wait_seconds("print"), 3.5)
    })
  })
  withr::with_options(list(EJAM.pdf_print_wait = NULL), {
    withr::with_envvar(list(EJAM_PDF_PRINT_WAIT = "junk"), {
      expect_equal(EJAM:::pdf_wait_seconds("print"), 2.25)
    })
  })
})

testthat::test_that("pdf_wait_seconds() falls back to the default for unusable values", {

  # a bad value must not become a 0-second wait (silently degrading output) nor an error
  for (bad in list("not a number", "", NA, NULL, -1, c(1, 2), Inf, list("junk"))) {
    withr::with_options(list(EJAM.pdf_print_wait = bad), {
      val <- EJAM:::pdf_wait_seconds("print")
      expect_true({is.numeric(val) && length(val) == 1 && is.finite(val) && val >= 0})
    })
  }
  withr::with_options(list(EJAM.pdf_print_wait = "junk"), {
    expect_equal(EJAM:::pdf_wait_seconds("print"), 2)
  })
  withr::with_options(list(EJAM.pdf_print_wait = -5), {
    expect_equal(EJAM:::pdf_wait_seconds("print"), 2)
  })
})

testthat::test_that("pdf_wait_seconds() rejects an unknown setting name", {

  expect_error({EJAM:::pdf_wait_seconds("something_else")})
})
################ ################# ################# ################# ################# #

testthat::test_that("ejam2report rebuilds fips polygons for FIPS/fips spellings", {
  ## ejamit() always sets site_method = "FIPS", but site_method2text() and
  ## sitetype2text() both accept either case, so a caller passing "fips" should
  ## still get polygons rather than an unmapped report. Mirrors the zip gate test
  ## in test-shapes_from_zip.R.
  fips_report_output <- function() list(
    sitetype = "fips",
    site_method = "FIPS",
    results_bysite = data.table::data.table(
      ejam_uniq_id = c("10001", "10003"), valid = TRUE, invalid_msg = "", pop = c(10, 20),
      radius.miles = 0, statename = "Delaware"),
    results_overall = data.table::data.table(
      ejam_uniq_id = "overall", valid = TRUE, invalid_msg = "", pop = 30,
      radius.miles = 0, statename = "Delaware")
  )
  for (spelling in c("FIPS", "fips", "Fips", "NAICS")) {
    called <- new.env(parent = emptyenv()); called$n <- 0L
    local_mocked_bindings(
      shapes_from_fips = function(fips, ...) {
        called$n <- called$n + 1L
        sf::st_as_sf(data.frame(fips = fips, geometry = sf::st_sfc(
          lapply(seq_along(fips), function(i) sf::st_polygon(list(rbind(
            c(-75, 39 + i), c(-74.9, 39 + i), c(-74.9, 39.1 + i), c(-75, 39 + i))))), crs = 4269)))
      },
      report_residents_within_xyz_from_ejamit = function(...) "residents",
      report_setup_temp_files = function(...) "template.Rmd",
      create_filename = function(...) "report.html",
      build_community_report = function(...) "<section>report</section>",
      plot_barplot_ratios_ez = function(...) ggplot2::ggplot(),
      ejam2map = function(...) "map",
      ensure_pandoc_available_for_ejam = function(...) invisible(TRUE),
      .package = "EJAM"
    )
    local_mocked_bindings(
      pandoc_available = function(...) TRUE,
      render = function(input, output_format, output_file, params, envir, quiet, ...) {
        writeLines("<html>report</html>", output_file); output_file
      }, .package = "rmarkdown"
    )
    out <- fips_report_output()
    out$site_method <- spelling
    res <- suppressWarnings(try(ejam2report(out, site_method = spelling, return_html = TRUE,
                                            launch_browser = FALSE), silent = TRUE))
    if (spelling == "NAICS") {
      expect_identical(called$n, 0L)                     # non-fips method must not rebuild fips
      ## called$n == 0 on its own would ALSO be satisfied by ejam2report() dying
      ## before it ever reached the gate, so this case has to show execution got
      ## past it. It cannot simply complete: with a non-FIPS method against this
      ## FIPS-shaped fixture, shp stays NULL and the unmapped branch needs
      ## ratio.to.state.avg.* columns the minimal fixture omits. So pin that
      ## specific downstream failure - which is only reachable past the gate.
      expect_true(inherits(res, "try-error"))
      expect_match(conditionMessage(attr(res, "condition")), "ratio\\.to\\.state\\.avg")
    } else {
      expect_gt(called$n, 0L)                            # both FIPS spellings do
      ## and the report itself must still complete - otherwise "shapes_from_fips()
      ## was called" would pass even if everything after it blew up.
      expect_false(inherits(res, "try-error"))
      expect_type(res, "character")
    }
  }
})
################ ################# ################# ################# ################# #
