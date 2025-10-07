
test_that("bgid_from_blockid ok", {
  rad = 0.658
  pts = data.frame(lat=39.4347105, lon=-74.7203421)
  junk=capture.output({
    s2b = getblocksnearby(sitepoints=pts, radius = rad)
  })
  expect_no_error({
    x = bgid_from_blockid(s2b$blockid) # vector of unique ids
    y = bgid_from_blockid(s2b$blockid, asdt = TRUE) # data.table
  })
  expect_true(is.vector(x))
  expect_true(is.atomic(x))
  expect_true(data.table::is.data.table(y))
  expect_true(all(x %in% y$bgid))
})
