
################################ # fixnames may be obsolete (was for old epa api functions) ####

test_that(desc = 'fixnames() output is char vector of right length, for a simple test set of 2 names', {
  oldvars <- c('totalPop', 'y')
  vars <- fixnames(oldvars, oldtype = 'api', newtype = 'r')
  expect_vector(vars)
  expect_type(vars, "character")
  expect_identical(length(vars), length(oldvars))
})
test_that(desc = 'fixnames renames totalPop to pop for correct element', {
  oldvars <- c('totalPop', 'y')
  vars <- fixnames(oldvars, oldtype = 'api', newtype = 'r')
  expect_equal(grepl("totalPop", oldvars), grepl("pop", vars))
})
test_that('fixnames() returns 1 for 1, NA for NA even if all are NA', {
  # renaming works: 1 or more API indicator names including totalPop get renamed as character vector, same length, NA as NA
  expect_identical(fixnames('just_one_item') , 'just_one_item')
  expect_identical(fixnames(c("validword", NA_character_)) , c("validword", NA))
  expect_identical(is.na(fixnames(NA)), TRUE)
})
