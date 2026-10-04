test_that("package MACT labels have normalized whitespace", {
  for (field in c("title", "dropdown_label")) {
    expect_identical(mact_table[[field]], stringr::str_squish(mact_table[[field]]))
  }
})
