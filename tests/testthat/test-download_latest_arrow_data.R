test_that("download_latest_arrow_data downloads release asset filenames from required tag", {
  required_tag <- EJAM:::ejamdata_required_tag()
  package_root <- tempfile("ejam-package-")
  installed_data_folder <- file.path(package_root, "data")
  dir.create(installed_data_folder, recursive = TRUE)
  on.exit(unlink(package_root, recursive = TRUE), add = TRUE)

  calls <- new.env(parent = emptyenv())
  calls$pb_releases_called <- FALSE

  withr::local_envvar(c(GITHUB_PAT = "test-token", GITHUB_TOKEN = NA))

  local_mocked_bindings(
    app_sys = function(...) file.path(package_root, ...),
    offline_cat = function(...) FALSE,
    .package = "EJAM"
  )

  local_mocked_bindings(
    pb_releases = function(...) {
      calls$pb_releases_called <- TRUE
      data.frame(tag_name = "v2.32.8.001")
    },
    pb_download = function(file, dest, repo, tag, overwrite = FALSE,
                           use_timestamps = TRUE, .token = NULL) {
      calls$pb_download <- list(
        file = file,
        dest = dest,
        repo = repo,
        tag = tag,
        overwrite = overwrite,
        use_timestamps = use_timestamps,
        token = .token
      )
      for (filename in file) {
        writeBin(as.raw(rep(1L, 2048)), file.path(dest, filename))
      }
      TRUE
    },
    .package = "piggyback"
  )

  local_mocked_bindings(
    read_ipc_file = function(path, as_data_frame = FALSE) list(path = path),
    .package = "arrow"
  )

  local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      calls$gh <- list(
        endpoint = endpoint,
        args = list(...),
        token = .token
      )
      list()
    },
    .package = "gh"
  )

  result <- EJAM:::download_latest_arrow_data(
    varnames = c("blockpoints", "quaddata"),
    repository = "Public-Environmental-Data-Partners/ejamdata",
    envir = new.env(parent = emptyenv())
  )

  expect_true(isTRUE(result))
  expect_false(calls$pb_releases_called)
  expect_identical(calls$pb_download$file, c("blockpoints.arrow", "quaddata.arrow"))
  expect_identical(calls$pb_download$tag, required_tag)
  expect_true(isTRUE(calls$pb_download$overwrite))
  expect_false(calls$pb_download$use_timestamps)
  expect_identical(calls$pb_download$token, "test-token")
  expect_identical(calls$gh$endpoint, "GET /repos/{owner}/{repo}")
  expect_identical(calls$gh$args$owner, "Public-Environmental-Data-Partners")
  expect_identical(calls$gh$args$repo, "ejamdata")
  expect_identical(calls$gh$token, "test-token")
  marker_path <- file.path(installed_data_folder, "ejamdata_version.txt")
  expect_identical(readLines(marker_path), required_tag)
  marker_bytes <- readBin(marker_path, what = "raw", n = file.info(marker_path)$size)
  expect_identical(tail(marker_bytes, 1), charToRaw("\n"))
})

test_that("dynamic_data_release_tag canonicalizes the historical v2.32.8.1 ejamdata alias", {
  expect_identical(
    unname(EJAM:::dynamic_data_release_tag(
      c("bgej", "frs"),
      piggybacktag = "v2.32.8.1"
    )),
    c("v2.32.8.001", "v2.32.8.001")
  )
  expect_identical(
    unname(EJAM:::dynamic_data_release_tag(
      c("bgej", "frs"),
      piggybacktag = "v2.32.8.001"
    )),
    c("v2.32.8.001", "v2.32.8.001")
  )
})
