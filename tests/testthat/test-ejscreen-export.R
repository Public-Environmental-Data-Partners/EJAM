test_that("map_headernames augmentation fills EJSCREEN name columns", {
  mapping <- data.frame(
    rname = c("no2", "pctpre1960", "pctile.EJ.DISPARITY.no2.eo"),
    csvname = c("NO2", "PRE1960PCT", "P_D2_NO2"),
    apiname = c("RAW_E_NO2", "RAW_E_LEAD", ""),
    ejscreen_csv = c("", "", ""),
    stringsAsFactors = FALSE
  )

  out <- augment_map_headernames_ejscreen_names(mapping)
  mapped <- out[match(mapping$rname, out$rname), ]
  expect_equal(mapped$ejscreen_names, mapping$csvname)
  expect_equal(mapped$ejscreen_ftp_names, mapping$csvname)
  expect_equal(mapped$ejscreen_apinames_old[1:2], mapping$apiname[1:2])
  expect_equal(mapped$ejam_apinames, mapping$rname)
  expect_equal(out$ejscreen_names[out$rname == "bgfips"], "ID")
  expect_equal(out$ejscreen_bin[out$rname == "pctpre1960"], "B_LDPNT")
  expect_equal(out$ejscreen_text[out$rname == "pctile.EJ.DISPARITY.no2.eo"], "T_D2_NO2")
})

test_that("calc_ejscreen_export combines bgej and renames through map_headernames", {
  blockgroupstats <- data.frame(
    bgfips = "100010001001",
    pm = 7.1,
    stringsAsFactors = FALSE
  )
  bgej <- data.frame(
    bgfips = "100010001001",
    `EJ.DISPARITY.pm.eo` = 2.5,
    `pctile.EJ.DISPARITY.pm.eo` = 95,
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "pm", "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo"),
    ejscreen_names = c("ID", "PM25", "D2_PM25", "P_D2_PM25"),
    csvname = c("ID", "PM25", "D2_PM25", "P_D2_PM25"),
    apiname = c("", "RAW_E_PM25", "", ""),
    stringsAsFactors = FALSE
  )
  save_path <- tempfile(fileext = ".csv")

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = bgej,
    output_vars = c("bgfips", "pm", "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo"),
    mapping_for_names = mapping,
    required_output_names = c("ID", "PM25", "D2_PM25", "P_D2_PM25", "B_D2_PM25", "T_D2_PM25"),
    save_path = save_path
  )

  expect_equal(
    names(out),
    c("ID", "PM25", "D2_PM25", "P_D2_PM25", "B_D2_PM25", "T_D2_PM25")
  )
  expect_equal(out$B_D2_PM25, 11L)
  expect_equal(out$T_D2_PM25, "95 %ile")
  expect_true(file.exists(save_path))
  saved <- data.table::fread(save_path, colClasses = c(ID = "character"))
  expect_equal(saved, data.table::as.data.table(out))
})

test_that("calc_ejscreen_export adds EJ percentile and map helper fields from lookups", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    ST = c("DE", "DE"),
    stringsAsFactors = FALSE
  )
  bgej <- data.frame(
    bgfips = blockgroupstats$bgfips,
    `EJ.DISPARITY.pm.eo` = c(1, 2),
    check.names = FALSE
  )
  usastats_ej <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "mean", "50", "100"),
    `EJ.DISPARITY.pm.eo` = c(0, 1.5, 1, 2),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo"),
    ejscreen_names = c("ID", "D2_PM25", "P_D2_PM25"),
    csvname = c("ID", "D2_PM25", "P_D2_PM25"),
    apiname = "",
    stringsAsFactors = FALSE
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = bgej,
    usastats_ej = usastats_ej,
    mapping_for_names = mapping,
    include_state_ej_percentiles = FALSE
  )

  expect_equal(names(out), c("ID", "D2_PM25", "P_D2_PM25", "B_D2_PM25", "T_D2_PM25"))
  expect_equal(out$P_D2_PM25, c(50, 100))
  expect_equal(out$B_D2_PM25, c(6L, 11L))
  expect_equal(out$T_D2_PM25, c("50 %ile", "100 %ile"))
})

test_that("calc_ejscreen_export default output drops non-reporting placeholder names", {
  blockgroupstats <- data.frame(
    bgfips = "100010001001",
    keepme = 1,
    internal_a = 2,
    internal_b = 3,
    stringsAsFactors = FALSE
  )
  mapping <- data.frame(
    rname = c("keepme", "internal_a", "internal_b"),
    ejscreen_names = c("KEEP", "use for pctile and avg but don’t report", "use for pctile and avg but don’t report"),
    csvname = c("KEEP", "use for pctile and avg but don’t report", "use for pctile and avg but don’t report"),
    apiname = "",
    stringsAsFactors = FALSE
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = data.frame(bgfips = "100010001001", stringsAsFactors = FALSE),
    mapping_for_names = mapping,
    include_ejscreen_map_fields = FALSE
  )

  expect_equal(names(out), c("ID", "KEEP"))
  expect_equal(out$KEEP, 1)
})

test_that("EJSCREEN map helper fields use historical bins and current text", {
  expect_equal(
    calc_ejscreen_map_bin(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(0L, 0L, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, 0L)
  )
  expect_equal(
    calc_ejscreen_map_pctile_text(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(NA, NA, "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", NA)
  )

  out <- add_ejscreen_map_fields(
    data.frame(
      P_D2_NO2 = c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101),
      check.names = FALSE
    ),
    mapping_for_names = data.frame(
      rname = "pctile.EJ.DISPARITY.no2.eo",
      ejscreen_pctile = "P_D2_NO2",
      ejscreen_bin = "B_D2_NO2",
      ejscreen_text = "T_D2_NO2",
      stringsAsFactors = FALSE
    )
  )

  expect_equal(out$B_D2_NO2, c(0L, 0L, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, 0L))
  expect_equal(
    out$T_D2_NO2,
    c(NA, NA, "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", NA)
  )
})
