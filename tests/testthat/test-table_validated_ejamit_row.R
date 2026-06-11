# table_validated_ejamit_row

test_that("valid 1-row input is returned as a 1-row data.table", {
  x <- EJAM:::table_validated_ejamit_row(
    testoutput_ejamit_10pts_1miles$results_overall)
  expect_true(data.table::is.data.table(x))
  expect_equal(NROW(x), 1)
  expect_setequal(
    names(x),
    colnames(testoutput_ejamit_10pts_1miles$results_overall))
})

test_that("a single row of results_bysite is returned unchanged in structure", {
  x <- EJAM:::table_validated_ejamit_row(
    testoutput_ejamit_10pts_1miles$results_bysite[1, ])
  expect_true(data.table::is.data.table(x))
  expect_equal(NROW(x), 1)
})

test_that("NULL input warns and returns a 1-row data.table of NAs", {
  expect_warning(
    x <- EJAM:::table_validated_ejamit_row(NULL)
  )
  expect_true(data.table::is.data.table(x))
  expect_equal(NROW(x), 1)
  expect_setequal(
    names(x),
    colnames(testoutput_ejamit_10pts_1miles$results_overall))
  expect_true(all(is.na(unlist(x))))
})

test_that("multi-row input warns and returns a 1-row data.table of NAs", {
  expect_warning(
    x <- EJAM:::table_validated_ejamit_row(
      testoutput_ejamit_10pts_1miles$results_bysite)
  )
  expect_true(data.table::is.data.table(x))
  expect_equal(NROW(x), 1)
  expect_setequal(
    names(x),
    colnames(testoutput_ejamit_10pts_1miles$results_overall))
  expect_true(all(is.na(unlist(x))))
})
