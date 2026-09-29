## unit tests for EJAM::frs_from_regid
## Author: Sara Sokolinski

# function is in the file frs_from_xyz.R
# not much to test here

# does it work with a proper reg id
test_that('lookup works correctly',{
  expect_no_warning({val <- frs_from_regid(testinput_registry_id[1])})
  expect_true("lat" %in% names(val) & "lon" %in% names(val) &   "data.table" %in% class(val))
  expect_true(any(!is.na(val$lat) & !is.na(val$lon)))
})

test_that('plausibility does not reject IDs newer than an old FRS maximum', {
  expect_true(EJAM:::regids_seem_ok(110073000001))
  expect_false(EJAM:::regids_seem_ok("fakeid"))
  expect_false(EJAM::regids_valid("fakeid"))
})


# does it give an error when id doesnt exist?
# no it doesn't, just returns an empty data frame, or actually 1 row all NA values
test_that('lookup works correctly',{
  expect_no_error({
    val <- frs_from_regid("fakeid")
  })
  expect_true(all(is.na(val)))
  
  # expect_equal(NROW(val), 0)
})
