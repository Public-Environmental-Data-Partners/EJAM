test_that("ejam2barplot_indicators ratio includes analyzed site and person summaries", {
  # This test intentionally passes legacy labels to validate backward compatibility.
  expect_no_error({
    x <- ejam2barplot_indicators(
      testoutput_ejamit_1000pts_1miles,
      indicator_type = "Demographic",
      data_type = "ratio",
      mybarvars.stat = "avg",
      mybarvars.sumstat = c("Average site", "Average person")
    )
  })

  expect_true("ggplot" %in% class(x))
  expect_setequal(
    as.character(unique(x$data$Summary)),
    c("Average person in US", "Average site analyzed", "Average person at sites analyzed")
  )
  # The US comparison baseline is explicitly added as ratio = 1 for every indicator.
  expect_true(all(x$data$ratio[x$data$Summary == "Average person in US"] == 1))
})

test_that("ejam2barplot_indicators raw uses clarified summary labels", {
  expect_no_error({
    x <- ejam2barplot_indicators(
      testoutput_ejamit_1000pts_1miles,
      indicator_type = "Demographic",
      data_type = "raw",
      mybarvars.stat = "avg",
      mybarvars.sumstat = c("Average site", "Average person")
    )
  })

  expect_true("ggplot" %in% class(x))
  expect_true(all(c("Average site analyzed", "Average person at sites analyzed") %in% levels(x$data$Summary)))
})

test_that("ejam2barplot_indicators accepts clarified summary labels as inputs", {
  expect_no_error({
    x <- ejam2barplot_indicators(
      testoutput_ejamit_1000pts_1miles,
      indicator_type = "Demographic",
      data_type = "ratio",
      mybarvars.stat = "avg",
      mybarvars.sumstat = c("Average site analyzed", "Average person at sites analyzed")
    )
  })

  expect_true("ggplot" %in% class(x))
  expect_setequal(
    as.character(unique(x$data$Summary)),
    c("Average person in US", "Average site analyzed", "Average person at sites analyzed")
  )
})

test_that("ejam2barplot_indicators median ratio joins to US baselines without NAs", {
  expect_no_error({
    x <- ejam2barplot_indicators(
      testoutput_ejamit_1000pts_1miles,
      indicator_type = "Demographic",
      data_type = "ratio",
      mybarvars.stat = "med",
      mybarvars.sumstat = c("Median site analyzed", "Median person at sites analyzed")
    )
  })

  expect_true("ggplot" %in% class(x))
  expect_setequal(
    as.character(unique(x$data$Summary)),
    c("Median person in US", "Median site analyzed", "Median person at sites analyzed")
  )
  expect_false(any(is.na(x$data$ratio[x$data$Summary != "Median person in US"])))
  expect_true(all(x$data$ratio[x$data$Summary == "Median person in US"] == 1))
})

test_that("ejam2barplot_indicators median raw supports analyzed median labels", {
  expect_no_error({
    x <- ejam2barplot_indicators(
      testoutput_ejamit_1000pts_1miles,
      indicator_type = "Demographic",
      data_type = "raw",
      mybarvars.stat = "med",
      mybarvars.sumstat = c("Median site analyzed", "Median person at sites analyzed")
    )
  })

  expect_true("ggplot" %in% class(x))
  expect_setequal(
    as.character(unique(x$data$Summary)),
    c("Median person in US", "Median site analyzed", "Median person at sites analyzed")
  )
})
