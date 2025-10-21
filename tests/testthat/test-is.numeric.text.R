test_that("is.numeric.text works", {

  ## This function was changed to return a vector - previously just checked the vector as a whole, returning only 1 T/F.
  ## Now it does check each element to return a logical vector.

  expect_length(is.numeric.text(c('1', '2')), 2)

  ## For Valid numbers stored as numeric not text, func now will return TRUE
  expect_equal(
    is.numeric.text(1:10),
    rep(TRUE, 10)
  )

  ## normal cases

  # "01" or " -1.32"
  # ".3" or "3."

  expect_true(is.numeric.text('1'))
  expect_true(is.numeric.text('01'))
  expect_true(is.numeric.text('  0001  '))
  expect_true(is.numeric.text(1))
  expect_true(is.numeric.text(0))
  expect_true(is.numeric.text(-0))
  expect_true(is.numeric.text("   -1.32   "))
  expect_true(is.numeric.text(0.3))
  expect_true(is.numeric.text("0.3"))
  expect_true(is.numeric.text(".3"))
  expect_true(is.numeric.text("3."))
  expect_true(is.numeric.text("-.3"))
  expect_true(is.numeric.text(" -3. "))


  #' even "." ?
  #' even "-" ?
  expect_true(is.numeric.text("."))
  expect_true(is.numeric.text("-"))

  expect_false(is.numeric.text("-  1"))

  expect_false(is.numeric.text("x"))
  expect_false(is.numeric.text("3x"))
  expect_false(is.numeric.text("3.3.3"))
  expect_false(is.numeric.text("10-1"))
  expect_false(is.numeric.text("1.-1"))

  suppressWarnings({
    expect_warning(is.numeric.text(list(1,2)))
    expect_false(is.numeric.text(list(1,2)))
    expect_warning(is.numeric.text(data.frame(a=1,b=1)))
    expect_false(is.numeric.text(data.frame(a=1,b=1)))
  })

  ## NA values, vectors
  expect_equal(
    is.numeric.text(c(NA, 1, "1", "x", NA), na.is = NA),
    c(NA, TRUE, TRUE, FALSE, NA)
  )
  expect_equal(
    is.numeric.text(c(NA, 1, "1", "x", NA), na.is = TRUE),
    c(TRUE, TRUE, TRUE, FALSE, TRUE)
  )
  expect_equal(
    is.numeric.text(c(NA, 1, "1", "x", NA), na.is = FALSE),
    c(FALSE, TRUE, TRUE, FALSE, FALSE)
  )
})
