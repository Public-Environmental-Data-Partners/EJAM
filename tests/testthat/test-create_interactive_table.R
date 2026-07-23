test_that("create_interactive_table does not mutate results_bysite by reference", {
  env <- new.env(parent = emptyenv())
  data("testoutput_ejamit_10pts_1miles", package = "EJAM", envir = env)
  out <- get("testoutput_ejamit_10pts_1miles", envir = env, inherits = FALSE)

  local_mocked_bindings(
    saveWidget = function(widget, file, ...) {
      writeLines("<html></html>", file)
      invisible(file)
    },
    .package = "htmlwidgets"
  )

  expect_false(is.null(out$results_bysite))
  expect_true(data.table::is.data.table(out$results_bysite))

  max_columns_for_test <- 25
  selected_columns <- names(out$results_bysite)[1:min(max_columns_for_test, ncol(out$results_bysite))]

  expect_no_error(
    interactive_table <- EJAM:::create_interactive_table(
      out = out,
      columns_used = selected_columns
    )
  )

  expect_s3_class(interactive_table, "datatables")
  expect_true(data.table::is.data.table(out$results_bysite))
})

test_that("download-button column HTML matches rendering a shiny::actionButton() per row", {
  # The button column is built from a single rendered actionButton template with
  # per-row string substitution (much faster for many sites, issue #127).
  # This test keeps that template in sync with whatever HTML shiny currently
  # produces, by comparing against the straightforward one-button-per-row way.
  env <- new.env(parent = emptyenv())
  data("testoutput_ejamit_10pts_1miles", package = "EJAM", envir = env)
  out <- get("testoutput_ejamit_10pts_1miles", envir = env, inherits = FALSE)

  local_mocked_bindings(
    saveWidget = function(widget, file, ...) {
      writeLines("<html></html>", file)
      invisible(file)
    },
    .package = "htmlwidgets"
  )

  interactive_table <- EJAM:::create_interactive_table(
    out = out,
    # keep lat/lon so ejam2tableviewer() can infer sitetype without a warning
    columns_used = c("ejam_uniq_id", "lat", "lon", "pop", "statename")
  )

  shown <- interactive_table$x$data
  expect_true("Download EJAM Report" %in% names(shown))
  buttoncol <- shown[["Download EJAM Report"]]
  n <- NROW(out$results_bysite)
  expect_length(buttoncol, n)

  expected <- vapply(seq_len(n), function(i) {
    as.character(shiny::actionButton(
      paste0("button_", i),
      label = "Download",
      onclick = paste0('Shiny.onInputChange(\"single_site_report_button', i, '\", this.id)')
    ))
  }, character(1))
  expect_identical(as.character(buttoncol), expected)
})
