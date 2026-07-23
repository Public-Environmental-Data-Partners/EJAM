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

test_that("faster table defaults from #491: pageLength 50, and the default column subset is usable", {
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

  # the app's server falls back to this subset when the user has not picked columns.
  # (in the running app global_or_param() reads it from golem options, which are
  # populated at launch from the same defaults assembled here)
  opts_before <- options()
  gopts <- EJAM:::get_global_defaults_or_user_options(
    user_specified_options = list(), bookmarking_allowed = "disable"
  )
  # undo the options that assembling the defaults sets as a side effect
  # (shiny.*, spinner.*), so this test leaves global state unchanged
  opts_added <- setdiff(names(options()), names(opts_before))
  if (length(opts_added) > 0) {
    do.call(options, stats::setNames(vector("list", length(opts_added)), opts_added))
  }
  options(opts_before)
  default_cols <- gopts$default_bysite_webtable_colnames
  expect_true(is.character(default_cols) && length(default_cols) > 10)
  expect_true(all(default_cols %in% names(out$results_bysite)))

  tbl <- EJAM:::create_interactive_table(
    out = out,
    columns_used = default_cols,
    sitereport_download_buttons_show = FALSE
  )
  expect_equal(tbl$x$options$pageLength, 50)
  shown_cols <- ncol(tbl$x$data)
  # the subset (plus the few summary columns bound on) - nowhere near the ~700 total
  expect_gt(shown_cols, 40)
  expect_lt(shown_cols, length(default_cols) + 10)
})
