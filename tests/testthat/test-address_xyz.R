
#  FUNCTIONS

# address_from_table_goodnames()
# address_from_table()

################################ #

# TEST DATA

##     test data:
##
##  to see test objects and test files:
##
# cbind(data.in.package  = sort(grep("address", pkg_data()$Item, value = T)))
# cbind(files.in.package = sort(basename(testdata('address', quiet = T))))

# testinput_address_parts
# testinput_address_2  # "1200 Pennsylvania Ave, NW Washington DC" "Research Triangle Park"
# testinput_address_table
# testinput_address_table_withfull
# testinput_address_table_goodnames

## fname <- system.file("testdata/address/testinput_address_table_9.xlsx", package = "EJAM")

offline_warning()

################################ #

testthat::test_that("address_from_table_goodnames works", {

  testthat::skip_if_offline()
  testthat::expect_no_error({
    x <- address_from_table_goodnames(testinput_address_table_goodnames)
  })
  testthat::expect_identical(x,  c("1200 Pennsylvania Ave Washington DC ", "5 pARK AVE NY NY "))
})
###################### #

testthat::test_that("address_from_table works", {

  testthat::skip_if_offline()

  ### address_from_table() works with filename??
  ## fname <- system.file(  ..........................)
  ### pts <- address_from_table(fname)

  testthat::expect_no_error({
    x <- address_from_table(testinput_address_table)
  })
  testthat::expect_identical(x, c("1200 Pennsylvania Ave Washington DC ", "5 pARK AVE NY NY "))

  testthat::expect_no_error({
    x <- address_from_table(testinput_address_table_goodnames)
  })
  testthat::expect_identical(x, c("1200 Pennsylvania Ave Washington DC ", "5 pARK AVE NY NY "))
})

# testthat::test_that("address_from_table works in odd case (Address colname has different FULL address than STREET etc do)", {
#
# testthat::skip_if_offline()
# suppressWarnings({
#     testthat::expect_no_error({
#
#       x <- address_from_table(testinput_address_table_withfull)
#
#     })
#     testthat::expect_identical(
#       x,
#       c("1200 Pennsylvania Ave, NW Washington DC", "Research Triangle Park"))
#   })
# })
