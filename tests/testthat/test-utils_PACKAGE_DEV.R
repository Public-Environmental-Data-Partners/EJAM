test_that("pkg_functions_preceding_lines handles top-of-file roxygen blocks", {
  tmp <- tempfile("pkg-functions-preceding-lines-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Tiny helper",
      "#' @return NULL",
      "tiny_helper <- function() NULL"
    ),
    file.path(tmp, "tiny_helper.R")
  )

  out <- capture.output({
    info <- EJAM:::pkg_functions_preceding_lines(path = tmp)
  })

  expect_true(length(out) > 0)
  expect_s3_class(info, "data.frame")
  expect_equal(info$func, "tiny_helper")
  expect_true(info$roxy)
  expect_true(info$return)
})
