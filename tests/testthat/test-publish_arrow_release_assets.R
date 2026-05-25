test_that("publish_arrow_release_assets validates Arrow files in dry run", {
  skip_if_not_installed("arrow")

  path <- tempfile(fileext = ".arrow")
  arrow::write_ipc_file(
    data.frame(
      id = seq_len(5000),
      value = sprintf("value-%05d", seq_len(5000))
    ),
    sink = path
  )

  expect_message(
    plan <- publish_arrow_release_assets(
      files = path,
      tag = "vTEST",
      repo = "Public-Environmental-Data-Partners/ejamdata",
      release_date = as.Date("2026-05-25"),
      dry_run = TRUE
    ),
    "Updated datasets for EJScreen/EJAM updated as of 2026-05-25"
  )
  expect_s3_class(plan, "data.frame")
  expect_equal(plan$asset, basename(path))
  expect_equal(plan$tag, "vTEST")
})
