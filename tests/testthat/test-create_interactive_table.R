test_that("create_interactive_table does not mutate results_bysite by reference", {
  skip_if_not(
    exists("testoutput_ejamit_10pts_1miles", envir = asNamespace("EJAM"), inherits = FALSE),
    message = "testoutput_ejamit_10pts_1miles is required for this test"
  )
  out <- get("testoutput_ejamit_10pts_1miles", envir = asNamespace("EJAM"))
  expect_false(is.null(out$results_bysite))
  expect_true(data.table::is.data.table(out$results_bysite))

  selected_columns <- names(out$results_bysite)[1:min(25, ncol(out$results_bysite))]

  expect_no_error(
    interactive_table <- EJAM:::create_interactive_table(
      out = out,
      columns_used = selected_columns
    )
  )

  expect_s3_class(interactive_table, "datatables")
  expect_true(data.table::is.data.table(out$results_bysite))
})
