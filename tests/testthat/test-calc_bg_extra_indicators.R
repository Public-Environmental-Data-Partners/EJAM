test_that("bg_extra_indicators requires explicit input or explicit reuse", {
  expect_error(
    EJAM:::calc_bg_extra_indicators(extra_indicator_vars = "lowlifex"),
    "bg_extra_indicators must be supplied"
  )

  existing <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(0.1, 0.2),
    rateasthma = c(7.1, 8.2)
  )

  expect_warning(
    out <- EJAM:::calc_bg_extra_indicators(
      extra_indicator_vars = c("lowlifex", "rateasthma"),
      reuse_existing_if_missing = TRUE,
      existing_blockgroupstats = existing
    ),
    "Reusing current blockgroupstats data"
  )
  expect_equal(names(out), c("bgfips", "lowlifex", "rateasthma"))
})

test_that("extra indicator defaults are driven by map_headernames varlist groups", {
  mapping <- data.frame(
    rname = c("lowlifex", "pctdisability", "pm", "num_school", "custom_extra"),
    varlist = c("names_health", "names_health", "names_e", "names_featuresinarea", "custom"),
    stringsAsFactors = FALSE
  )

  expect_equal(
    namesbyvarlist(
      varlist = c("names_health", "names_featuresinarea"),
      nametype = "rname",
      mapping = mapping,
      exclude = "pctdisability"
    )$rname,
    c("lowlifex", "num_school")
  )
  expect_equal(
    namesbyvarlist(
      varlist = c("names_health", "names_featuresinarea"),
      nametype = "rname",
      mapping = mapping,
      available_vars = c("num_school")
    )$rname,
    "num_school"
  )
  expect_true(all(EJAM:::ejscreen_default_extra_indicator_vars() %in% EJAM::map_headernames$rname))
})

test_that("bg_extra_indicators fills missing columns only when reuse is explicit", {
  partial <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(0.1, 0.2)
  )
  existing <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(9, 9),
    rateasthma = c(7.1, 8.2)
  )

  expect_error(
    EJAM:::calc_bg_extra_indicators(partial, extra_indicator_vars = c("lowlifex", "rateasthma")),
    "missing expected extra indicator columns"
  )

  expect_warning(
    out <- EJAM:::calc_bg_extra_indicators(
      partial,
      extra_indicator_vars = c("lowlifex", "rateasthma"),
      reuse_existing_if_missing = TRUE,
      existing_blockgroupstats = existing
    ),
    "Reusing current blockgroupstats data for missing"
  )
  expect_equal(out$lowlifex, c(0.1, 0.2))
  expect_equal(out$rateasthma, c(7.1, 8.2))
})

test_that("calc_ejscreen_blockgroupstats uses explicit extra indicator stage", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002", "440010001001", "440010001002"),
    REGION = "",
    pop = c(100, 150, 120, 160),
    pctmin = c(0.2, 0.3, 0.4, 0.5),
    pctlowinc = c(0.1, 0.2, 0.3, 0.4),
    pctlingiso = c(0.02, 0.03, 0.04, 0.05),
    pctlths = c(0.05, 0.06, 0.07, 0.08),
    pctdisability = c(0.11, 0.12, 0.13, 0.14)
  )
  bg_envirodata <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    pctpre1960 = c(0.2, 0.3, 0.4, 0.5),
    pm = c(7, 8, 9, 10)
  )
  bg_extra_indicators <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    lowlifex = c(0.1, 0.2, 0.3, 0.4),
    rateasthma = c(7.1, 8.2, 9.3, 10.4)
  )

  out <- EJAM:::calc_ejscreen_blockgroupstats(
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    extra_indicator_vars = c("lowlifex", "rateasthma")
  )

  expect_true(all(c("ST", "statename", "countyname", "REGION", "bgid") %in% names(out)))
  expect_true(all(c("lowlifex", "rateasthma", "pm", "Demog.Index") %in% names(out)))
  expect_equal(out$rateasthma, bg_extra_indicators$rateasthma)
  expect_false(any(is.na(out$REGION) | out$REGION == ""))
})

test_that("calc_ejscreen_blockgroupstats can intentionally reuse old extra indicators", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002", "440010001001", "440010001002"),
    ST = c("DE", "DE", "RI", "RI"),
    pop = c(100, 150, 120, 160),
    pctmin = c(0.2, 0.3, 0.4, 0.5),
    pctlowinc = c(0.1, 0.2, 0.3, 0.4),
    pctlingiso = c(0.02, 0.03, 0.04, 0.05),
    pctlths = c(0.05, 0.06, 0.07, 0.08),
    pctdisability = c(0.11, 0.12, 0.13, 0.14)
  )
  bg_envirodata <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    pctpre1960 = c(0.2, 0.3, 0.4, 0.5)
  )
  existing <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    lowlifex = c(0.1, 0.2, 0.3, 0.4)
  )

  expect_error(
    EJAM:::calc_ejscreen_blockgroupstats(
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      extra_indicator_vars = "lowlifex"
    ),
    "bg_extra_indicators must be supplied"
  )

  expect_warning(
    out <- EJAM:::calc_ejscreen_blockgroupstats(
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      extra_indicator_vars = "lowlifex",
      reuse_existing_extra_if_missing = TRUE,
      existing_blockgroupstats = existing
    ),
    "Reusing current blockgroupstats data"
  )
  expect_equal(out$lowlifex, existing$lowlifex)
})

test_that("demographic index shifting does not warn when a state input is all NA", {
  bgstats <- data.table::data.table(
    bgfips = c("100010001001", "100010001002", "720010001001", "720010001002"),
    ST = c("DE", "DE", "PR", "PR"),
    lowlifex = c(0.1, 0.2, NA_real_, NA_real_),
    pctmin = c(0.2, 0.3, 0.4, 0.5),
    pctlowinc = c(0.1, 0.2, 0.3, 0.4),
    pctlingiso = c(0.02, 0.03, 0.04, 0.05),
    pctlths = c(0.05, 0.06, 0.07, 0.08),
    pctdisability = c(0.11, 0.12, 0.13, 0.14)
  )

  expect_warning(
    out <- calc_blockgroup_demog_index(bgstats),
    NA
  )
  expect_equal(out$bgfips, bgstats$bgfips)
})
