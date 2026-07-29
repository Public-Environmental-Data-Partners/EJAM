# is.numericish

testcases <- list(
  t1 = c(0, -1, 1, 100, 100.1, 100.10, 100.100, -99.100),
  t2 = as.character(c(0, -1, 1, 100, 100.1, 100.10, 100.100, -99.100)),
  t3 = c("00001", "00.00100", ".1", ".010", "    0001  "),
  t4 = testinput_fips_mix,
  t5 = c(NA, NA, NA),

  t6 = c(  "", "    ",  "   0    4  ", " 1. 4"), # FALSE, FALSE, FALSE , FALSE
  t7 = c("NA","1a","NULL"), # FALSE, FALSE, FALSE

  t8 = NULL  # NULL
)

for (i in seq_along(testcases)) {
  tx = testcases[[i]]
  x = is.numericish(tx)

  # cat("\n\n", names(testcases)[i], "\n\n")
  # print( cbind(testdata = tx, is.numericish = x))

  test_that(paste0("is.numericish ok for ", names(testcases)[i]), {
    if (i < 6) {
      expect_true(all(x))
    }
    if (i %in% 6:7) {
      expect_true(all(!x))
    }
    if (i == 8) {
      expect_null(x)
    }
  })

}
############################### ################################ #

test_that("is.numericish ok for data.frame", {

    testcases <- list(
    t1 = c(0, -1, 1, 100, 100.1, 100.10, 100.100, -99.100),
    t2 = as.character(c(0, -1, 1, 100, 100.1, 100.10, 100.100, -99.100)),
    t3 = c("00001", "00.00100", ".1", ".010", "    0001  "),
    t4 = testinput_fips_mix,
    t5 = c(NA, NA, NA),

    t6 = c(  "", "    ",  "   0    4  ", " 1. 4"), # FALSE, FALSE, FALSE , FALSE
    t7 = c("NA","1a","NULL"), # FALSE, FALSE, FALSE

    t8 = NULL  # NULL
  )

  testcases_df <- data.frame(
    t1 = testcases[[1]][1:3],
    t2 = testcases[[2]][1:3],
    t3 = testcases[[3]][1:3],
    t4 = testcases[[4]][1:3],
    t5 = testcases[[5]][1:3],
    t6 = testcases[[6]][1:3],
    t7 = testcases[[7]][1:3]

  )
  x = sapply(testcases_df, is.numericish )

   expect_true(
     all(x[,1:5] == TRUE)
   )
   expect_true(
     all(x[,6:7] == FALSE)
   )
})

test_that("is.numericish does not alter a data.table input, and matches the data.frame result", {
  # it used to setDF() a data.table input by reference and never restore it
  # (the caller's object was left as a data.frame)
  df <- data.frame(a = c(1.5, NA, 3), b = c("x", "", "z"), c = c("08", "1.90", NA),
                   stringsAsFactors = FALSE)
  dt <- data.table::as.data.table(df)
  snapshot <- data.table::copy(dt)

  expect_identical(is.numericish(dt), is.numericish(df))
  expect_true(data.table::is.data.table(dt))
  expect_identical(dt, snapshot)
})
