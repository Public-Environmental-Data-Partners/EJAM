test_that("pctiles_lookup_create includes 0 through 100 and mean rows", {
  lookup <- pctiles_lookup_create(data.frame(indicator = c(2, 4, 8)))

  expect_equal(lookup$PCTILE[1], "0")
  expect_equal(lookup$PCTILE[101], "100")
  expect_equal(lookup$PCTILE[102], "mean")
  expect_equal(nrow(lookup), 102)
})
