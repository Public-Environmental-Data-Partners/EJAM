test_that("map_headernames augmentation fills EJSCREEN name columns", {
  mapping <- data.frame(
    rname = c("no2", "pctpre1960", "pctile.EJ.DISPARITY.no2.eo"),
    csvname = c("NO2", "PRE1960PCT", "P_D2_NO2"),
    apiname = c("RAW_E_NO2", "RAW_E_LEAD", ""),
    ejscreen_csv = c("", "", ""),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::augment_map_headernames_ejscreen_names(mapping)
  mapped <- out[match(mapping$rname, out$rname), ]
  expect_equal(mapped$ejscreen_indicator, mapping$csvname)
  expect_equal(mapped$ejscreen_ftp_names, mapping$csvname)
  expect_equal(mapped$ejscreen_apinames_old[1:2], mapping$apiname[1:2])
  expect_equal(mapped$ejam_apinames, mapping$rname)
  expect_equal(out$ejscreen_indicator[out$rname == "bgfips"], "ID")
  expect_false("ejscreen_app" %in% names(out))
  expect_true(all(c(
    "EXCEED_COUNT_90",
    "EXCEED_COUNT_90_SUP",
    "SYMBOLOGY_EXCEED_COUNT_80",
    "Shape__Area",
    "Shape__Length"
  ) %in% out$ejscreen_indicator))
  expect_equal(out$ejscreen_bin[out$rname == "pctpre1960"], "B_LDPNT")
  expect_equal(out$ejscreen_text[out$rname == "pctile.EJ.DISPARITY.no2.eo"], "T_D2_NO2")
})

test_that("map_headernames augmentation removes legacy special markers from current EJSCREEN name columns", {
  mapping <- data.frame(
    rname = c("state.pctile.Demog.Index", "internal_for_pctile"),
    csvname = c("S_P_DEMOGIDX_2ST", "use for pctile and avg but don't report"),
    apiname = c("S_D_DEMOGIDX2ST_PER", ""),
    ejscreen_indicator = c("***special", "use for pctile and avg but don't report"),
    ejscreen_csv = c("***special", "use for pctile and avg but don't report"),
    ejscreen_gdb = c("***special", "use for pctile and avg but don't report"),
    ejscreen_pctile = c("P_***special", "use for pctile and avg but don't report"),
    ejscreen_bin = c("B_***special", "use for pctile and avg but don't report"),
    ejscreen_text = c("T_***special", "use for pctile and avg but don't report"),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::augment_map_headernames_ejscreen_names(mapping)
  current_name_cols <- c(
    "ejscreen_indicator", "ejscreen_csv", "ejscreen_gdb",
    "ejscreen_pctile", "ejscreen_bin", "ejscreen_text"
  )

  expect_false(any(grepl("***special", unlist(out[current_name_cols]), fixed = TRUE)))
  expect_false(any(grepl("use for pctile", unlist(out[current_name_cols]), ignore.case = TRUE)))
  expect_equal(out$ejscreen_ftp_names[out$rname == "state.pctile.Demog.Index"], "S_P_DEMOGIDX_2ST")
  expect_equal(out$ejscreen_apinames_old[out$rname == "state.pctile.Demog.Index"], "S_D_DEMOGIDX2ST_PER")
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
    ejscreen_indicator = c("ID", "PM25", "D2_PM25", "P_D2_PM25"),
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
    ejscreen_indicator = c("ID", "D2_PM25", "P_D2_PM25"),
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

test_that("calc_ejscreen_export can produce FeatureServer percentile and schema fields", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    ST = c("DE", "DE"),
    `Demog.Index` = c(0.1, 0.9),
    `Demog.Index.Supp` = c(0.2, 0.8),
    `Demog.Index.State` = c(0.3, 0.7),
    `Demog.Index.Supp.State` = c(0.4, 0.6),
    pm = c(1, 2),
    o3 = c(3, 4),
    check.names = FALSE
  )
  bgej <- data.frame(
    bgfips = blockgroupstats$bgfips,
    `EJ.DISPARITY.pm.eo` = c(5, 6),
    `EJ.DISPARITY.pm.supp` = c(7, 8),
    check.names = FALSE
  )
  usastats_acs <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "mean", "50", "80", "90", "100"),
    `Demog.Index` = c(0, 0.5, 0.1, 0.8, 0.9, 1),
    pm = c(0, 1.5, 1, 1.8, 2, 3),
    o3 = c(0, 3.5, 3, 3.8, 4, 5),
    check.names = FALSE
  )
  usastats_ej <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "mean", "50", "80", "90", "100"),
    `EJ.DISPARITY.pm.eo` = c(0, 5.5, 5, 5.8, 6, 7),
    `EJ.DISPARITY.pm.supp` = c(0, 7.5, 7, 7.8, 8, 9),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c(
      "bgfips", "Demog.Index", "Demog.Index.State", "pctile.Demog.Index",
      "pm", "pctile.pm", "o3", "pctile.o3",
      "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo",
      "EJ.DISPARITY.pm.supp", "pctile.EJ.DISPARITY.pm.supp"
    ),
    ejscreen_indicator = c(
      "ID", "DEMOGIDX_2", "DEMOGIDX_2ST", "P_DEMOGIDX_2",
      "PM25", "P_PM25", "OZONE", "P_OZONE",
      "D2_PM25", "P_D2_PM25", "D5_PM25", "P_D5_PM25"
    ),
    ejscreen_pctile = c(
      "", "P_DEMOGIDX_2", "", "P_DEMOGIDX_2",
      "P_PM25", "P_PM25", "P_OZONE", "P_OZONE",
      "P_D2_PM25", "P_D2_PM25", "P_D5_PM25", "P_D5_PM25"
    ),
    stringsAsFactors = FALSE
  )
  feature_fields <- EJAM:::ejscreen_feature_server_fields()

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = bgej,
    usastats_acs = usastats_acs,
    usastats_ej = usastats_ej,
    mapping_for_names = mapping,
    feature_server_fields = feature_fields
  )

  expect_equal(length(feature_fields), 235)
  expect_equal(names(out), feature_fields)
  expect_equal(out$OBJECTID, seq_len(nrow(out)))
  expect_equal(out$P_PM25, c(50, 90))
  expect_equal(out$B_PM25, c(6L, 10L))
  expect_equal(out$T_PM25, c("50 %ile", "90 %ile"))
  expect_equal(out$P_D2_PM25, c(50, 90))
  expect_equal(out$P_D5_PM25, c(50, 90))
  expect_equal(out$EXCEED_COUNT_80, c(0L, 1L))
  expect_equal(out$EXCEED_COUNT_80_SUP, c(0L, 1L))
  expect_equal(out$EXCEED_COUNT_90, c(0L, 1L))
  expect_equal(out$EXCEED_COUNT_90_SUP, c(0L, 1L))
  expect_equal(out$SYMBOLOGY_EXCEED_COUNT_80, c(
    "0 EJ Indexes over 80th %tile",
    "1-13 EJ Indexes over 80th %tile"
  ))
  expect_true(all(is.na(out$Shape__Area)))
  expect_true(all(is.na(out$Shape__Length)))
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
    ejscreen_indicator = c("KEEP", "use for pctile and avg but don’t report", "use for pctile and avg but don’t report"),
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

test_that("calc_ejscreen_export_schema_report flags missing and extra fields", {
  export <- data.frame(
    ID = "100010001001",
    D2_PM25 = 1,
    P_D2_PM25 = 50,
    B_D2_PM25 = 6L,
    EXTRA_FIELD = 9,
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo"),
    ejscreen_indicator = c("ID", "D2_PM25", "P_D2_PM25"),
    ejscreen_pctile = c("", "P_D2_PM25", "P_D2_PM25"),
    ejscreen_bin = c("", "B_D2_PM25", "B_D2_PM25"),
    ejscreen_text = c("", "T_D2_PM25", "T_D2_PM25"),
    longname = c("Block group FIPS", "PM2.5 EJ index", "PM2.5 EJ index percentile"),
    stringsAsFactors = FALSE
  )

  report <- EJAM:::calc_ejscreen_export_schema_report(
    ejscreen_export = export,
    mapping_for_names = mapping
  )

  expect_equal(report$status[report$ejscreen_name == "EXTRA_FIELD"], "present_extra")
  expect_equal(report$status[report$ejscreen_name == "T_D2_PM25"], "missing_expected")
  expect_equal(report$field_type[report$ejscreen_name == "B_D2_PM25"], "map_bin")
  expect_true(report$present_in_export[report$ejscreen_name == "ID"])
})

test_that("EJSCREEN map helper fields use historical bins and current text", {
  expect_equal(
    EJAM:::calc_ejscreen_map_bin(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(0L, 0L, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, 0L)
  )
  expect_equal(
    calc_ejscreen_map_pctile_text(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(NA, NA, "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", NA)
  )

  out <- EJAM:::calc_ejscreen_map_fields_added(
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
