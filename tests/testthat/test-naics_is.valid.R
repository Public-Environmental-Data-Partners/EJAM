## unit tests for naics_is.valid()

################################################## #

test_that('naics_is.valid() correctly reports TEXT as not valid', {
  expect_no_warning({
    val <- naics_is.valid("LOL")
  })
  expect_false(val)
})

test_that('naics_is.valid() correctly reports some NAICS as not valid', {
  expect_equal(
    naics_is.valid(code = ""),
    FALSE
  )
  expect_equal(
  naics_is.valid(code = c("211", "452", "999" , "")),
  c(TRUE, TRUE, FALSE, FALSE)
)
})

test_that('naics_is.valid() correctly reports NULL as not valid', {
  expect_equal(
    naics_is.valid(NULL),
    TRUE
  )
})
################################################## #
