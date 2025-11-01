# calc_ratios_cols

test_that("matches doaggregate() ratios", {
  #    see examples for ?pctile_cols_from_raw_lookup()
  expect_no_error({
  # examples of getting pctiles, averages, and ratios to averages
  # via functions that do parts of what is done in doaggregate()

  #############################
  #  using ejamit() which uses doaggregate()

  testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
  testfips = blockgroupstats$bgfips[ testrows ]
  junk = capture_output({
    out = ejamit(fips = testfips)
  })
  x = out$results_bysite
  # look at the averages, ratios, and percentiles
  names_these_pctile       = paste0("pctile.",      names_these)
  names_these_state_pctile = paste0("state.pctile.", names_these)
  avgs0    = x[ , c(..names_these_avg,          ..names_these_state_avg)]
  ratios0  = x[ , c(..names_these_ratio_to_avg, ..names_these_ratio_to_state_avg)]
  pctiles0 = x[ , c(..names_these_pctile,       ..names_these_state_pctile)]
  # outputs are data.tables, 1 row per site, 1 col per indicator
  # names(avgs0); dim(avgs0)
  # names(ratios0); dim(ratios0)
  # names(pctiles0); dim(pctiles0)

  #############################
  ##  using just parts of what doaggregate() does

  testrows = c(14840L, 96520L, 105100L, 138880L, 237800L)
  ## if missing names_d_demogindexstate, cannot do correct ratios  ***
  testvars = c("ST", names_these, names_d_demogindexstate)
  testbgs = blockgroupstats[testrows, ..testvars]

  #   ----------------- AVERAGES -----------------

  avgs <- cbind(
    avg_from_raw_lookup(varnames = names_these, zones = "USA"),
    avg_from_raw_lookup(varnames = names_these, zones = testbgs$ST)
  )
  data.table::setDT(avgs)
  # t(avgs)
  # expect_true(
  #   all.equal(avgs, avgs0) # that function gets tested elsewhere
  # )
  testbgs <- cbind(testbgs, avgs) # need these averages to calculate the ratios

  #   ----------------- RATIOS TO AVERAGES -----------------

  ratios <- calc_ratios_cols(testbgs)  # needs raw and avg cols be in 1 dt
  data.table::setDT(ratios)
  # t(ratios)
  expect_true(
    all.equal(ratios, ratios0)
  )

  #   ----------------- PERCENTILES -----------------
# ### tested elsewhere
#   pctiles <- cbind(
#     pctile_cols_from_raw_lookup(testbgs, varnames = names_these, zones = "USA"),
#     pctile_cols_from_raw_lookup(testbgs, varnames = names_these, zones = testbgs$ST)
#   )
#   data.table::setDT(pctiles)
#   all.equal(pctiles, pctiles0)
  # t(pctiles)

  })

})
