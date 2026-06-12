test_that("pctiles_lookup_create includes 0 through 100 and mean rows", {
  lookup <- pctiles_lookup_create(data.frame(indicator = c(2, 4, 8)))

  expect_equal(lookup$PCTILE[1], "0")
  expect_equal(lookup$PCTILE[101], "100")
  expect_equal(lookup$PCTILE[102], "mean")
  expect_equal(nrow(lookup), 102)
  expect_true("indicator" %in% names(lookup))
  expect_equal(lookup$indicator[lookup$PCTILE == "mean"], mean(c(2, 4, 8)))
})

test_that("pctiles_lookup_create omits NA values from one-column lookups", {
  lookup <- pctiles_lookup_create(data.frame(percapincome = c(100, NA_real_, 300)))

  expect_true("percapincome" %in% names(lookup))
  expect_equal(lookup$percapincome[lookup$PCTILE == "mean"], 200)
})
