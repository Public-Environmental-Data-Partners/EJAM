RELEASE_TAG_ENDPOINT <- "GET /repos/{owner}/{repo}/releases/tags/{tag}"

# Set up a fake installed package data folder plus the mocks every test here
# needs, and return the environment that records what the mocks were asked to do.
local_arrow_download_setup <- function(gh_fun,
                                       pb_download_fun = NULL,
                                       env = parent.frame()) {
  package_root <- withr::local_tempdir(.local_envir = env)
  installed_data_folder <- file.path(package_root, "data")
  dir.create(installed_data_folder, recursive = TRUE)

  calls <- new.env(parent = emptyenv())
  calls$package_root <- package_root
  calls$installed_data_folder <- installed_data_folder
  calls$gh <- list()
  calls$pb_download_files <- list()
  calls$pb_releases_called <- FALSE

  withr::local_envvar(c(GITHUB_PAT = "test-token", GITHUB_TOKEN = NA), .local_envir = env)

  EJAM:::ejamdata_download_problem_clear()
  withr::defer(EJAM:::ejamdata_download_problem_clear(), envir = env)

  testthat::local_mocked_bindings(
    app_sys = function(...) file.path(package_root, ...),
    offline_cat = function(...) FALSE,
    .package = "EJAM",
    .env = env
  )

  if (is.null(pb_download_fun)) {
    pb_download_fun <- function(file, dest, repo, tag, overwrite = FALSE,
                                use_timestamps = TRUE, .token = NULL) {
      calls$pb_download <- list(
        file = file, dest = dest, repo = repo, tag = tag,
        overwrite = overwrite, use_timestamps = use_timestamps, token = .token
      )
      calls$pb_download_files <- c(calls$pb_download_files, list(file))
      for (filename in file) {
        writeBin(as.raw(rep(1L, 2048)), file.path(dest, filename))
      }
      TRUE
    }
  }

  testthat::local_mocked_bindings(
    pb_releases = function(...) {
      calls$pb_releases_called <- TRUE
      data.frame(tag_name = "v2.32.8.001")
    },
    pb_download = pb_download_fun,
    .package = "piggyback",
    .env = env
  )

  testthat::local_mocked_bindings(
    read_ipc_file = function(path, as_data_frame = FALSE) list(path = path),
    .package = "arrow",
    .env = env
  )

  testthat::local_mocked_bindings(
    gh = function(endpoint, ..., .token = NULL) {
      args <- list(...)
      calls$gh <- c(calls$gh, list(list(endpoint = endpoint, args = args, token = .token)))
      gh_fun(endpoint, args, .token)
    },
    .package = "gh",
    .env = env
  )

  calls
}

# A GitHub answer for "get a release by tag" that has the named assets.
fake_release <- function(asset_names, draft = FALSE) {
  list(
    id = 1L,
    draft = draft,
    assets = lapply(asset_names, function(nm) list(name = nm, size = 2048L))
  )
}

test_that("download_latest_arrow_data downloads release asset filenames from required tag", {
  required_tag <- EJAM:::ejamdata_required_tag()

  calls <- local_arrow_download_setup(
    gh_fun = function(endpoint, args, token) {
      if (identical(endpoint, RELEASE_TAG_ENDPOINT)) {
        return(fake_release(c("blockpoints.arrow", "quaddata.arrow", "bgej.arrow")))
      }
      list()
    }
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

  # first the token check, then the release asset listing
  expect_identical(calls$gh[[1]]$endpoint, "GET /repos/{owner}/{repo}")
  expect_identical(calls$gh[[1]]$args$owner, "Public-Environmental-Data-Partners")
  expect_identical(calls$gh[[1]]$args$repo, "ejamdata")
  expect_identical(calls$gh[[1]]$token, "test-token")
  expect_identical(calls$gh[[2]]$endpoint, RELEASE_TAG_ENDPOINT)
  expect_identical(calls$gh[[2]]$args$tag, required_tag)

  expect_null(EJAM:::ejamdata_download_problem())
  marker_path <- file.path(calls$installed_data_folder, "ejamdata_version.txt")
  expect_identical(readLines(marker_path), required_tag)
  marker_bytes <- readBin(marker_path, what = "raw", n = file.info(marker_path)$size)
  expect_identical(tail(marker_bytes, 1), charToRaw("\n"))
})

test_that("a failed asset listing is reported as an API failure, not as missing data", {
  # This is the GitHub outage of 2026-08-17: the asset listing came back useless,
  # and EJAM used to treat that as "there is nothing to download".
  calls <- local_arrow_download_setup(
    gh_fun = function(endpoint, args, token) {
      if (identical(endpoint, RELEASE_TAG_ENDPOINT)) {
        stop("boom: GitHub said no")
      }
      list()
    }
  )

  expect_warning(
    expect_message(
      result <- EJAM:::download_latest_arrow_data(
        varnames = "quaddata",
        repository = "Public-Environmental-Data-Partners/ejamdata",
        envir = new.env(parent = emptyenv())
      ),
      "Could not list assets for release"
    ),
    "GitHub API request failed"
  )

  expect_false(isTRUE(result))
  # nothing was downloaded, and no local marker was written
  expect_null(calls$pb_download)
  expect_false(file.exists(file.path(calls$installed_data_folder, "ejamdata_version.txt")))

  problem <- EJAM:::ejamdata_download_problem()
  expect_true(grepl("Could not list assets for release", problem))
  expect_true(grepl("UNREACHABLE rather than empty", problem))
  # and the later "dataset is not on disk" error now carries that cause
  expect_true(grepl("Could not list assets", EJAM:::ejamdata_download_problem_note()))
})

test_that("a release that really has no assets is reported differently than a failed listing", {
  calls <- local_arrow_download_setup(
    gh_fun = function(endpoint, args, token) {
      if (identical(endpoint, RELEASE_TAG_ENDPOINT)) {
        return(fake_release(character(0)))
      }
      list()
    }
  )

  suppressWarnings(
    expect_message(
      result <- EJAM:::download_latest_arrow_data(
        varnames = "quaddata",
        repository = "Public-Environmental-Data-Partners/ejamdata",
        envir = new.env(parent = emptyenv())
      ),
      "has NO assets at all"
    )
  )

  expect_false(isTRUE(result))
  expect_null(calls$pb_download)
  problem <- EJAM:::ejamdata_download_problem()
  expect_true(grepl("genuinely empty release", problem))
  expect_false(grepl("UNREACHABLE", problem))
})

test_that("assets present but not the requested file is reported as a missing asset", {
  calls <- local_arrow_download_setup(
    gh_fun = function(endpoint, args, token) {
      if (identical(endpoint, RELEASE_TAG_ENDPOINT)) {
        return(fake_release(c("blockpoints.arrow", "bgej.arrow")))
      }
      list()
    }
  )

  suppressWarnings(
    expect_message(
      result <- EJAM:::download_latest_arrow_data(
        varnames = "quaddata",
        repository = "Public-Environmental-Data-Partners/ejamdata",
        envir = new.env(parent = emptyenv())
      ),
      "does not include: quaddata.arrow"
    )
  )

  expect_false(isTRUE(result))
  expect_null(calls$pb_download)
  expect_true(grepl("really are absent from that release", EJAM:::ejamdata_download_problem()))
})

test_that("a download that silently produces no file is retried, then reported", {
  attempts <- new.env(parent = emptyenv())
  attempts$n <- 0L

  calls <- local_arrow_download_setup(
    gh_fun = function(endpoint, args, token) {
      if (identical(endpoint, RELEASE_TAG_ENDPOINT)) {
        return(fake_release("quaddata.arrow"))
      }
      list()
    },
    pb_download_fun = function(file, dest, repo, tag, overwrite = FALSE,
                               use_timestamps = TRUE, .token = NULL) {
      attempts$n <- attempts$n + 1L
      # First call behaves like piggyback did during the outage: it "succeeds"
      # without downloading anything. The second call works.
      if (attempts$n >= 2L) {
        for (filename in file) {
          writeBin(as.raw(rep(1L, 2048)), file.path(dest, filename))
        }
      }
      invisible(list())
    }
  )

  result <- EJAM:::download_latest_arrow_data(
    varnames = "quaddata",
    repository = "Public-Environmental-Data-Partners/ejamdata",
    envir = new.env(parent = emptyenv())
  )

  expect_true(isTRUE(result))
  expect_identical(attempts$n, 2L)
  expect_null(EJAM:::ejamdata_download_problem())
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
