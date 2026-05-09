##################### #

test_that("getblocks_summarize_blocks_per_site does not crash", {
  expect_no_error({
    junk <- capture_output({

      x = EJAM:::getblocks_summarize_blocks_per_site(testoutput_getblocksnearby_1000pts_1miles)
      y = EJAM:::getblocks_summarize_blocks_per_site(testoutput_getblocksnearby_1000pts_1miles,
                                              varname = "blockid" )
    })
  })
  expect_equal(
    sum(x$freq_of_sites),
    length(unique(testoutput_getblocksnearby_1000pts_1miles$ejam_uniq_id))
  )
  expect_true(
    class(x) == "data.frame"
  )
  expect_true(
    class(y) == "data.frame"
  )
})
##################### #

test_that("getblocks_summarize_sites_per_block does not crash", {

  skip_if_not(exists("getblocks_summarize_sites_per_block"), "getblocks_summarize_sites_per_block() is not exported and not loaded")
  expect_no_error({
    # EJAM  ... ::: getblocks_summarize_sites_per_block(testoutput_getblocksnearby_1000pts_1miles) # would use the installed version not a sourced version
    z <- getblocks_summarize_sites_per_block(testoutput_getblocksnearby_1000pts_1miles)
    getblocks_summarize_sites_per_block(testoutput_getblocksnearby_1000pts_1miles, "ejam_uniq_id")
  })
  expect_true({ "table" %in% class(z)})
  expect_error({
    getblocks_summarize_sites_per_block(testoutput_getblocksnearby_1000pts_1miles, "invalidcolname")
  })
})
##################### #

test_that("getblocks_diagnostics does not crash", {

  expect_no_error({
    junk1 <- capture_output({
      x1 = getblocks_diagnostics(testoutput_getblocksnearby_1000pts_1miles, detailed = TRUE, see_pctiles = TRUE)
    })
    junk2 <- capture_output({
      x2 = getblocks_diagnostics(testoutput_getblocksnearby_1000pts_1miles, detailed = TRUE, see_pctiles = F)
    })
    junk3 <- capture_output({
    x3 = getblocks_diagnostics(testoutput_getblocksnearby_1000pts_1miles, detailed = F,    see_pctiles = TRUE)
    })
    junk4 <- capture_output({
    x4 = getblocks_diagnostics(testoutput_getblocksnearby_1000pts_1miles, detailed = F,    see_pctiles = F)
    })
  })
  expect_true(  any(grepl("percentiles.of.distance", x =  junk1)) )
  expect_false( any(grepl("percentiles.of.distance", x =  junk2)) )
  expect_true(any(grepl("freq_of_sites", junk1)))
  expect_false(any(grepl("freq_of_sites", junk3)))
  expect_true(class(x1) == 'list')
  expect_equal(
    names(x1),
    c("sitecount_unique_out", "blockcount_avgsite", "blockcount_incl_dupes",
      "blockcount_unique", "uniqueblocks_near_only1site", "uniqueblocks_near_exactly2site",
      "uniqueblocks_near_exactly3site", "ratio_blocks_incl_dupes_to_unique",
      "pct_of_unique_blocks_in_overlaps", "count_block_site_distances",
      "uniqueblocks_near_multisite", "max_distance_unadjusted", "max_distance",
      "min_distance_unadjusted", "min_distance")
  )

})
##################### #
