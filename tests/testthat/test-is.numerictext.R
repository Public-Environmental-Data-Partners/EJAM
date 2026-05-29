test_that("is.numerictext works", {

  ## This function was changed to return a vector - previously just checked the vector as a whole, returning only 1 T/F.
  ## Now it does check each element to return a logical vector.

  expect_length(is.numerictext(c('1', '2')), 2)

  ## For Valid numbers stored as numeric not text, func now will return TRUE
  expect_equal(
    is.numerictext(1:10),
    rep(TRUE, 10)
  )

  ## normal cases

  # "01" or " -1.32"
  # ".3" or "3."

  expect_true(is.numerictext('1'))
  expect_true(is.numerictext('01'))
  expect_true(is.numerictext('  0001  '))
  expect_true(is.numerictext(1))
  expect_true(is.numerictext(0))
  expect_true(is.numerictext(-0))
  expect_true(is.numerictext("   -1.32   "))
  expect_true(is.numerictext(0.3))
  expect_true(is.numerictext("0.3"))
  expect_true(is.numerictext(".3"))
  expect_true(is.numerictext("3."))
  expect_true(is.numerictext("-.3"))
  expect_true(is.numerictext(" -3. "))


  #' even "." ?
  #' even "-" ?
  expect_true(is.numerictext("."))
  expect_true(is.numerictext("-"))

  expect_false(is.numerictext("-  1"))

  expect_false(is.numerictext("x"))
  expect_false(is.numerictext("3x"))
  expect_false(is.numerictext("3.3.3"))
  expect_false(is.numerictext("10-1"))
  expect_false(is.numerictext("1.-1"))

  suppressWarnings({
    expect_warning(is.numerictext(list(1,2)))
    expect_false(is.numerictext(list(1,2)))
    expect_warning(is.numerictext(data.frame(a=1,b=1)))
    expect_false(is.numerictext(data.frame(a=1,b=1)))
  })

  ## NA values, vectors
  expect_equal(
    is.numerictext(c(NA, 1, "1", "x", NA), na.is = NA),
    c(NA, TRUE, TRUE, FALSE, NA)
  )
  expect_equal(
    is.numerictext(c(NA, 1, "1", "x", NA), na.is = TRUE),
    c(TRUE, TRUE, TRUE, FALSE, TRUE)
  )
  expect_equal(
    is.numerictext(c(NA, 1, "1", "x", NA), na.is = FALSE),
    c(FALSE, TRUE, TRUE, FALSE, FALSE)
  )
})
