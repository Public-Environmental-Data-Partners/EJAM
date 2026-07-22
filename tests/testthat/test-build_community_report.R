
## Tests for build_community_report() and build_barplot_report()
## focusing on the filename parameter: when provided, the HTML must be
## written to that file AND still be returned (identical to the filename=NULL
## return), since callers and the report .Rmd templates use the return value.
## (Previously the filename branch discarded the content, which is the root
## cause behind the empty saved reports addressed in
## Public-Environmental-Data-Partners/EJAM#471.)

test_that("build_community_report(filename=NULL) returns the report HTML", {
  returned <- EJAM:::build_community_report(
    output_df = testoutput_ejamit_10pts_1miles$results_overall,
    analysis_title = "MARKER TITLE nullcase",
    report_title = "Test Report",
    in_shiny = FALSE
  )
  expect_s3_class(returned, "html")
  expect_match(as.character(returned), "MARKER TITLE nullcase", fixed = TRUE)
})

test_that("build_community_report(filename=) writes the HTML to the file and still returns it", {
  outfile <- file.path(tempdir(), "build_community_report_test_output.html")
  on.exit(unlink(outfile), add = TRUE)

  returned <- EJAM:::build_community_report(
    output_df = testoutput_ejamit_10pts_1miles$results_overall,
    analysis_title = "MARKER TITLE filecase",
    report_title = "Test Report",
    in_shiny = FALSE,
    filename = outfile
  )

  # return value must be the same HTML as in the filename=NULL case, not NULL
  expect_s3_class(returned, "html")
  expect_match(as.character(returned), "MARKER TITLE filecase", fixed = TRUE)

  # and the same content must have been saved to the file
  expect_true(file.exists(outfile))
  saved <- paste(readLines(outfile, warn = FALSE), collapse = "\n")
  expect_match(saved, "MARKER TITLE filecase", fixed = TRUE)
  expect_identical(trimws(saved), trimws(as.character(returned)))
})

test_that("build_community_report() derives totalpop from output_df$pop when not provided", {
  out <- testoutput_ejamit_10pts_1miles$results_overall
  expected_popstr <- prettyNum(round(as.numeric(out$pop), 0), big.mark = ",")
  returned <- EJAM:::build_community_report(
    output_df = out,
    analysis_title = "irrelevant",
    report_title = "Test Report"
  )
  expect_match(as.character(returned), expected_popstr, fixed = TRUE)
})

test_that("build_community_report(filename=) errors clearly when the folder does not exist", {
  badpath <- file.path(tempdir(), "no_such_subfolder_for_test", "report.html")
  expect_error(
    EJAM:::build_community_report(
      output_df = testoutput_ejamit_10pts_1miles$results_overall,
      analysis_title = "irrelevant",
      report_title = "Test Report",
      filename = badpath
    ),
    "does not exist"
  )
})

test_that("build_barplot_report(filename=) writes the HTML to the file and still returns it", {
  outfile <- file.path(tempdir(), "build_barplot_report_test_output.html")
  on.exit(unlink(outfile), add = TRUE)

  returned <- EJAM:::build_barplot_report(
    analysis_title = "MARKER BARPLOT TITLE",
    totalpop = "1,234",
    locationstr = "Test location",
    report_title = "Test Barplot Report",
    in_shiny = FALSE,
    filename = outfile
  )

  expect_s3_class(returned, "html")
  expect_match(as.character(returned), "MARKER BARPLOT TITLE", fixed = TRUE)

  expect_true(file.exists(outfile))
  saved <- paste(readLines(outfile, warn = FALSE), collapse = "\n")
  expect_match(saved, "MARKER BARPLOT TITLE", fixed = TRUE)
  expect_identical(trimws(saved), trimws(as.character(returned)))
})
