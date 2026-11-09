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
  expect_true(info$roxy_nobreak)
  expect_true(info$roxy)
  expect_true(info$return)
})

test_that("pkg_functions_preceding_lines extracts names without spaces around equals", {
  tmp <- tempfile("pkg-functions-preceding-lines-compact-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Compact helper",
      "#' @return NULL",
      "compact_helper=function() NULL"
    ),
    file.path(tmp, "compact_helper.R")
  )

  out <- capture.output({
    info <- EJAM:::pkg_functions_preceding_lines(path = tmp)
  })

  expect_true(length(out) > 0)
  expect_equal(info$func, "compact_helper")
  expect_true(info$return)
})

test_that("pkg_functions_preceding_lines only counts anchored roxygen tags", {
  tmp <- tempfile("pkg-functions-preceding-lines-anchored-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Mentions @export, @return, @noRd, and @keywords internal in prose.",
      "#' @keywords internal",
      "#' @noRd",
      "anchored_helper <- function() NULL"
    ),
    file.path(tmp, "anchored_helper.R")
  )

  out <- capture.output({
    info <- EJAM:::pkg_functions_preceding_lines(path = tmp)
  })

  expect_true(length(out) > 0)
  expect_equal(info$func, "anchored_helper")
  expect_false(info$export)
  expect_false(info$return)
  expect_true(info$internal)
  expect_true(info$nord)
})

test_that("pkg_functions_by_roxygen_tag returns only the function after a tag", {
  tmp <- tempfile("pkg-functions-by-roxygen-tag-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Tagged helper",
      "#' @export",
      "tagged_helper <- function() NULL",
      "untagged_helper <- function() NULL"
    ),
    file.path(tmp, "tagged_helper.R")
  )

  out <- capture.output({
    funcs <- EJAM:::pkg_functions_by_roxygen_tag(path = tmp)
  })

  expect_true(length(out) > 0)
  expect_equal(funcs, "tagged_helper")
})

test_that("pkg_functions_by_roxygen_tag ignores indented function definitions", {
  tmp <- tempfile("pkg-functions-by-roxygen-tag-indented-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Tagged helper",
      "#' @export",
      "  indented_helper <- function() NULL",
      "tagged_helper <- function() NULL"
    ),
    file.path(tmp, "tagged_helper.R")
  )

  out <- capture.output({
    funcs <- EJAM:::pkg_functions_by_roxygen_tag(path = tmp)
  })

  expect_true(length(out) > 0)
  expect_equal(funcs, "tagged_helper")
})

test_that("pkg_functions_by_roxygen_tag reports tags without nearby functions", {
  tmp <- tempfile("pkg-functions-by-roxygen-tag-missing-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(
    c(
      "#' Missing helper",
      "#' @export",
      "#' @return NULL"
    ),
    file.path(tmp, "missing_helper.R")
  )

  out <- capture.output({
    funcs <- EJAM:::pkg_functions_by_roxygen_tag(path = tmp)
  })

  expect_null(funcs)
  expect_true(any(grepl("no function definition found", out)))
})

test_that("find_in_files works when path is not the working directory", {
  tmp <- tempfile("find-in-files-")
  dir.create(file.path(tmp, "sub"), recursive = TRUE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  writeLines(c("nothing here", "a toque here"), file.path(tmp, "one.txt"))
  writeLines(c("toque again", "and toque twice"), file.path(tmp, "sub", "two.txt"))
  writeLines("toque in a file type not searched", file.path(tmp, "three.md"))

  # full.names = FALSE used to fail in readLines() unless path was the working directory
  expect_false(normalizePath(getwd()) == normalizePath(tmp))
  short <- EJAM:::find_in_files("toque", path = tmp, filename_pattern = "\\.txt$",
                                full.names = FALSE, quiet = TRUE)
  expect_equal(names(short), c("one.txt", "sub/two.txt"))
  expect_equal(short[["one.txt"]], c(`2` = "a toque here"))
  expect_equal(names(short[["sub/two.txt"]]), c("1", "2"))

  full <- EJAM:::find_in_files("toque", path = tmp, filename_pattern = "\\.txt$",
                               full.names = TRUE, quiet = TRUE)
  expect_equal(names(full), file.path(tmp, c("one.txt", "sub/two.txt")))
  expect_equal(unname(full), unname(short))

  fragments <- EJAM:::find_in_files("toque [a-z]+", path = tmp, filename_pattern = "\\.txt$",
                                    full.names = FALSE, whole_line = FALSE, quiet = TRUE)
  expect_equal(fragments[["sub/two.txt"]], c(`1` = "toque again", `2` = "toque twice"))

  expect_null(EJAM:::find_in_files("zzznotfoundzzz", path = tmp, filename_pattern = "\\.txt$",
                                   full.names = FALSE, quiet = TRUE))
})
