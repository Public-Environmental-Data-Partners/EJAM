################################################## #
# helper

pdf_file_has_magic_bytes <- function(path) {

  if (length(path) != 1 || is.na(path) || !file.exists(path)) {
    return(FALSE)
  }

  connection <- file(path, open = "rb")
  on.exit(close(connection), add = TRUE)
  identical(
    readBin(connection, what = "raw", n = 4L),
    charToRaw("%PDF")
  )
}
################################################## #
# helper

assert_valid_pdf_file <- function(path, min_size = 100L) {

  if (length(path) != 1 || is.na(path) || !file.exists(path)) {
    stop("Expected a PDF file, but none was created at: ", path, call. = FALSE)
  }

  if (!pdf_file_has_magic_bytes(path)) {
    stop(
      "Expected a real PDF file beginning with %PDF, but got different bytes at: ",
      path,
      call. = FALSE
    )
  }

  size <- file.info(path)$size
  if (is.na(size) || size < min_size) {
    stop(
      "Expected a non-empty PDF file, but the file at '", path,
      "' is only ", size, " bytes.",
      call. = FALSE
    )
  }

  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}
################################################## #
# helper

verify_pdf_runtime <- function() {

  if (!requireNamespace("pagedown", quietly = TRUE)) {
    stop(
      "The 'pagedown' package is required to verify PDF generation during the build.",
      call. = FALSE
    )
  }

  input_file <- tempfile(fileext = ".html")
  output_file <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(input_file, output_file)), add = TRUE)

  writeLines(
    "<html><body><p>EJAM PDF build verification</p></body></html>",
    input_file,
    useBytes = TRUE
  )

  pagedown::chrome_print(
    input = input_file,
    output = output_file,
    options = list(printBackground = TRUE),
    wait = 0,
    timeout = 60,
    verbose = 0
  )
  assert_valid_pdf_file(output_file)

  message("EJAM PDF build verification produced a valid PDF.")
  invisible(TRUE)
}
