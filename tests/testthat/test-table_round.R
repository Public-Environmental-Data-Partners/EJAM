## unit tests for table_round()
## (rewritten for speed for issue #127 - these tests pin down the contract:
##  each roundable column is rounded to its per-column digits from
##  table_rounding_info(), everything else is untouched)

test_that("table_round rounds each roundable column of a wide results_bysite table correctly", {
  env <- new.env(parent = emptyenv())
  data("testoutput_ejamit_10pts_1miles", package = "EJAM", envir = env)
  out <- get("testoutput_ejamit_10pts_1miles", envir = env, inherits = FALSE)
  x <- as.data.frame(out$results_bysite)

  result <- EJAM:::table_round(x)

  # reference: the same rounding rules applied independently, column by column
  dig <- EJAM:::table_rounding_info(var = names(x), varnametype = "rname")
  roundable <- EJAM:::is.numericish(x)
  roundable[is.na(dig)] <- FALSE
  expected <- x
  for (i in which(roundable)) {
    expected[[i]] <- round(expected[[i]], dig[i])
  }

  expect_identical(result, expected)
  # something was actually rounded, and non-roundable columns are untouched
  expect_gt(sum(roundable), 0)
  expect_identical(result[!roundable], x[!roundable])
  expect_identical(dim(result), dim(x))
  expect_identical(names(result), names(x))
})

test_that("table_round on a data.table gives the same values as on a data.frame", {
  env <- new.env(parent = emptyenv())
  data("testoutput_ejamit_10pts_1miles", package = "EJAM", envir = env)
  out <- get("testoutput_ejamit_10pts_1miles", envir = env, inherits = FALSE)
  df <- as.data.frame(out$results_bysite)

  from_df <- EJAM:::table_round(df)
  from_dt <- EJAM:::table_round(data.table::as.data.table(df))

  expect_identical(as.data.frame(from_dt), from_df)
})

test_that("table_round works on a vector", {
  v <- c(12.123456, 9, NA)
  dig <- EJAM:::table_rounding_info(var = "pm", varnametype = "rname")
  expect_identical(EJAM:::table_round(v, "pm"), round(v, dig))
})

test_that("table_round works on a matrix", {
  m <- matrix(c(12.123456, 9.87654, 1.234567, 2.345678), nrow = 2,
              dimnames = list(NULL, c("pm", "o3")))
  result <- EJAM:::table_round(m, var = colnames(m))
  dig <- EJAM:::table_rounding_info(var = colnames(m), varnametype = "rname")
  expected <- m
  for (i in seq_along(dig)) {
    expected[, i] <- round(expected[, i], dig[i])
  }
  expect_identical(result, expected)
})
