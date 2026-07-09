test_that("EJScreen reference values can replace selected envirodata columns", {
  bg_envirodata <- data.frame(
    bgfips = c("010010001001", "010010001002", "010010001003"),
    drinking = c(0, 0.2, 0.3),
    proximity.npl = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
  reference <- data.frame(
    ID = c("10010001001", "010010001002", "010010001999"),
    DWATER = c(NA_real_, 0.25, 0.99),
    PNPL = c(11, 22, 33),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::ejscreen_reference_bg_envirodata_adjusted(
    bg_envirodata,
    reference,
    vars = "drinking"
  )

  expect_equal(out$bgfips, bg_envirodata$bgfips)
  expect_equal(out$drinking, c(NA_real_, 0.25, 0.3))
  expect_equal(out$proximity.npl, bg_envirodata$proximity.npl)

  info <- attr(out, "ejscreen_reference_adjustment")
  expect_equal(info$stage_var, "drinking")
  expect_equal(info$reference_field, "DWATER")
  expect_equal(info$matched_rows, 2L)
  expect_equal(info$changed_rows, 2L)
})

test_that("EJScreen reference adjustment accepts EPA field names in vars", {
  bg_envirodata <- data.frame(
    bgfips = c("010010001001", "010010001002"),
    drinking = c(0, 0),
    proximity.npl = c(1, 2),
    stringsAsFactors = FALSE
  )
  reference <- data.frame(
    ID = c("010010001001", "010010001002"),
    DWATER = c(0.1, NA_real_),
    PNPL = c(10, 20),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::ejscreen_reference_bg_envirodata_adjusted(
    bg_envirodata,
    reference,
    vars = "DWATER"
  )

  expect_equal(out$drinking, c(0.1, NA_real_))
  expect_equal(out$proximity.npl, bg_envirodata$proximity.npl)
})
