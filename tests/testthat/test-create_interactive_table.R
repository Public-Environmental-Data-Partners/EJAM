test_that("create_interactive_table does not mutate results_bysite by reference", {
  out <- get("testoutput_ejamit_10pts_1miles", envir = asNamespace("EJAM"))
  expect_true(data.table::is.data.table(out$results_bysite))

  cols <- names(out$results_bysite)[1:min(25, ncol(out$results_bysite))]

  expect_no_error(
    tbl <- EJAM:::create_interactive_table(
      out = out,
      columns_used = cols
    )
  )

  expect_s3_class(tbl, "datatables")
  expect_true(data.table::is.data.table(out$results_bysite))
})
