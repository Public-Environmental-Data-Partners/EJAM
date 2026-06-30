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
