required_versions <- c(
  arrow = "24.0.0",
  curl = "7.1.0"
)

required_libcurl <- "7.73.0"

description_path <- Sys.getenv("EJAM_DESCRIPTION", "DESCRIPTION")

if (!file.exists(description_path)) {
  stop("Cannot find DESCRIPTION at ", description_path, call. = FALSE)
}

description_fields <- read.dcf(
  description_path,
  fields = c("Depends", "Imports", "Suggests")
)

dependency_text <- paste(description_fields[1, ], collapse = ",")

declared_minimum <- function(package) {
  pattern <- paste0(
    "(^|,)\\s*",
    package,
    "\\s*\\(\\s*>=\\s*([0-9][^)[:space:],]*)\\s*\\)"
  )
  match <- regexec(pattern, dependency_text)
  result <- regmatches(dependency_text, match)[[1]]

  if (length(result) < 3) {
    return(NA_character_)
  }

  result[[3]]
}

normalize_version <- function(version) {
  sub("^([0-9]+\\.[0-9]+(\\.[0-9]+)?).*", "\\1", as.character(version))
}

for (package in names(required_versions)) {
  required <- required_versions[[package]]
  declared <- declared_minimum(package)

  if (is.na(declared)) {
    stop(
      "DESCRIPTION must declare ",
      package,
      " (>= ",
      required,
      ")",
      call. = FALSE
    )
  }

  if (utils::compareVersion(declared, required) < 0) {
    stop(
      "DESCRIPTION declares ",
      package,
      " >= ",
      declared,
      "; expected >= ",
      required,
      call. = FALSE
    )
  }

  installed <- as.character(utils::packageVersion(package))

  if (utils::compareVersion(installed, required) < 0) {
    stop(
      "Installed ",
      package,
      " is ",
      installed,
      "; expected >= ",
      required,
      call. = FALSE
    )
  }

  message(package, " package OK: ", installed, " >= ", required)
}

libcurl_version <- normalize_version(curl::curl_version()[["version"]])

if (utils::compareVersion(libcurl_version, required_libcurl) < 0) {
  stop(
    "libcurl is ",
    libcurl_version,
    "; curl 7.1.0 requires libcurl >= ",
    required_libcurl,
    call. = FALSE
  )
}

message("libcurl OK: ", libcurl_version, " >= ", required_libcurl)

tmp_arrow <- tempfile(fileext = ".arrow")
on.exit(unlink(tmp_arrow), add = TRUE)

expected <- data.frame(
  row_id = c(1L, 2L),
  label = c("one", "two"),
  stringsAsFactors = FALSE
)

arrow::write_ipc_file(expected, sink = tmp_arrow)
actual <- arrow::read_ipc_file(file = tmp_arrow, as_data_frame = TRUE)

if (!identical(as.data.frame(actual), expected)) {
  stop("Arrow IPC round trip did not preserve the test data frame", call. = FALSE)
}

message("Arrow IPC read/write smoke test OK")
