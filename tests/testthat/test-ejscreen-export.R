test_that("map_headernames augmentation fills EJSCREEN name columns", {
  mapping <- data.frame(
    rname = c("no2", "pctpre1960", "pctile.pctpre1960", "pctile.EJ.DISPARITY.no2.eo"),
    csvname = c("NO2", "PRE1960PCT", "P_LDPNT", "P_D2_NO2"),
    ejscreen_apinames_old = c("RAW_E_NO2", "RAW_E_LEAD", "", ""),
    ejscreen_bin = c("", "", "WRONG_BIN", "WRONG_D2_BIN"),
    ejscreen_text = c("", "", "WRONG_TEXT", "WRONG_D2_TEXT"),
    `pctile.` = c(0, 0, 1, 1),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::augment_map_headernames_ejscreen_names(mapping)
  mapped <- out[match(mapping$rname, out$rname), ]
  expect_equal(mapped$ejscreen_indicator, mapping$csvname)
  expect_equal(mapped$ejscreen_ftp_names, mapping$csvname)
  expect_equal(mapped$ejscreen_apinames_old[1:2], mapping$ejscreen_apinames_old[1:2])
  expect_equal(mapped$ejam_apinames, mapping$rname)
  expect_equal(out$ejscreen_indicator[out$rname == "bgfips"], "ID")
  expect_false("ejscreen_app" %in% names(out))
  expect_false("ejscreen_pctile" %in% names(out))
  expect_false("ejscreen_bin" %in% names(out))
  expect_false("ejscreen_text" %in% names(out))
  expect_false(".text" %in% names(out))
  expect_true("text." %in% names(out))
  expect_true(all(c(
    "EXCEED_COUNT_90",
    "EXCEED_COUNT_90_SUP",
    "SYMBOLOGY_EXCEED_COUNT_80",
    "Shape__Area",
    "Shape__Length"
  ) %in% out$ejscreen_indicator))
  expect_equal(out$ejscreen_indicator[out$rname == "bin.pctpre1960"], "B_LDPNT")
  expect_equal(out$ejscreen_indicator[out$rname == "text.EJ.DISPARITY.no2.eo"], "T_D2_NO2")
  expect_equal(out$bin.[out$rname == "bin.pctpre1960"], 1)
  expect_equal(out$text.[out$rname == "text.EJ.DISPARITY.no2.eo"], 1)
})

test_that("map_headernames augmentation removes legacy special markers from current EJSCREEN name columns", {
  mapping <- data.frame(
    rname = c("state.pctile.Demog.Index", "internal_for_pctile"),
    csvname = c("S_P_DEMOGIDX_2ST", "use for pctile and avg but don't report"),
    ejscreen_apinames_old = c("S_D_DEMOGIDX2ST_PER", ""),
    ejscreen_indicator = c("***special", "use for pctile and avg but don't report"),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::augment_map_headernames_ejscreen_names(mapping)
  current_name_cols <- c(
    "ejscreen_indicator"
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
    ejscreen_apinames_old = c("", "RAW_E_PM25", "", ""),
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

test_that("calc_ejscreen_export saves direct s3 paths through pipeline upload helper", {
  blockgroupstats <- data.frame(
    bgfips = "100010001001",
    pm = 7.1,
    stringsAsFactors = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "pm"),
    ejscreen_indicator = c("ID", "PM25"),
    csvname = c("ID", "PM25"),
    ejscreen_apinames_old = "",
    stringsAsFactors = FALSE
  )
  uploaded <- new.env(parent = emptyenv())
  save_path <- "s3://example-bucket/ejscreen_export.csv"

  testthat::local_mocked_bindings(
    ejscreen_pipeline_s3_uri_exists = function(uri) {
      expect_equal(uri, save_path)
      FALSE
    },
    ejscreen_pipeline_s3_upload = function(local_path, uri) {
      uploaded$uri <- uri
      uploaded$data <- data.table::fread(local_path, colClasses = c(ID = "character"))
      uri
    },
    .package = "EJAM"
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = data.frame(bgfips = "100010001001", stringsAsFactors = FALSE),
    output_vars = c("bgfips", "pm"),
    mapping_for_names = mapping,
    include_ejscreen_map_fields = FALSE,
    save_path = save_path
  )

  expect_equal(uploaded$uri, save_path)
  expect_equal(uploaded$data, data.table::as.data.table(out))
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
    ejscreen_apinames_old = "",
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
      "EJ.DISPARITY.pm.supp", "pctile.EJ.DISPARITY.pm.supp",
      "bin.pm", "text.pm", "bin.EJ.DISPARITY.pm.eo", "text.EJ.DISPARITY.pm.eo",
      "bin.EJ.DISPARITY.pm.supp", "text.EJ.DISPARITY.pm.supp"
    ),
    ejscreen_indicator = c(
      "ID", "DEMOGIDX_2", "DEMOGIDX_2ST", "P_DEMOGIDX_2",
      "PM25", "P_PM25", "OZONE", "P_OZONE",
      "D2_PM25", "P_D2_PM25", "D5_PM25", "P_D5_PM25",
      "B_PM25", "T_PM25", "B_D2_PM25", "T_D2_PM25",
      "B_D5_PM25", "T_D5_PM25"
    ),
    `pctile.` = c(rep(0, 3), 1, 0, 1, 0, 1, 0, 1, 0, 1, rep(0, 6)),
    bin. = c(rep(0, 12), 1, 0, 1, 0, 1, 0),
    text. = c(rep(0, 12), 0, 1, 0, 1, 0, 1),
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
    ejscreen_apinames_old = "",
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
    rname = c(
      "bgfips", "EJ.DISPARITY.pm.eo", "pctile.EJ.DISPARITY.pm.eo",
      "bin.EJ.DISPARITY.pm.eo", "text.EJ.DISPARITY.pm.eo"
    ),
    ejscreen_indicator = c("ID", "D2_PM25", "P_D2_PM25", "B_D2_PM25", "T_D2_PM25"),
    `pctile.` = c(0, 0, 1, 0, 0),
    bin. = c(0, 0, 0, 1, 0),
    text. = c(0, 0, 0, 0, 1),
    longname = c(
      "Block group FIPS", "PM2.5 EJ index", "PM2.5 EJ index percentile",
      "PM2.5 EJ index map bin", "PM2.5 EJ index popup text"
    ),
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

test_that("calc_ejscreen_dataset_creator_input renames, orders, and reports placeholders", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    pop = c(100, 200),
    `Demog.Index` = c(0.1, 0.2),
    pm = c(7.1, 8.2),
    count.ej.80up = c(3, 4),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "pop", "Demog.Index", "pm", "count.ej.80up"),
    ejscreen_indicator = c("ID", "ACSTOTPOP", "DEMOGIDX_2", "PM25", "EXCEED_COUNT_80"),
    csvname = c("ID", "ACSTOTPOP", "DEMOGIDX_2", "PM25", "EXCEED_COUNT_80"),
    ejscreen_apinames_old = "",
    stringsAsFactors = FALSE
  )
  expected <- c("ID", "ACSTOTPOP", "DEMOGIDX_2", "PM25", "EXCEED_COUNT_80")

  out <- NULL
  expect_warning(
    out <- EJAM:::calc_ejscreen_dataset_creator_input(
      blockgroupstats = blockgroupstats,
      mapping_for_names = mapping,
      expected_output_names = expected,
      placeholder_fields = "EXCEED_COUNT_80",
      return_report = TRUE
    ),
    "filled fields"
  )

  expect_equal(names(out$data), expected)
  expect_equal(out$data$ID, blockgroupstats$bgfips)
  expect_equal(out$data$ACSTOTPOP, blockgroupstats$pop)
  expect_equal(out$data$DEMOGIDX_2, blockgroupstats$Demog.Index)
  expect_true(all(is.na(out$data$EXCEED_COUNT_80)))
  expect_equal(
    out$report$status[match(expected, out$report$ejscreen_name)],
    c("mapped", "mapped", "mapped", "mapped", "placeholder")
  )
  expect_true(out$report$placeholder[out$report$ejscreen_name == "EXCEED_COUNT_80"])
})

test_that("ejscreen_dataset_creator_input_fields matches dataset-creator column contract", {
  fields <- EJAM:::ejscreen_dataset_creator_input_fields()

  expect_equal(length(fields), 51)
  expect_false(anyDuplicated(fields) > 0)
  expect_equal(fields[1:5], c("ID", "STATE_NAME", "ST_ABBREV", "CNTY_NAME", "REGION"))
  expect_true(all(c("DISABILITYPCT", "PM25", "NO2", "EXCEED_COUNT_80_SUP") %in% fields))
  expect_equal(tail(fields, 6), c(
    "AREALAND", "AREAWATER", "NPL_CNT", "TSDF_CNT",
    "EXCEED_COUNT_80", "EXCEED_COUNT_80_SUP"
  ))
})

test_that("EJSCREEN map helper fields use historical bins and current text", {
  expect_equal(
    EJAM:::calc_ejscreen_map_bin(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(0L, 0L, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, 0L)
  )
  expect_equal(
    EJAM:::calc_ejscreen_map_pctile_text(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c(NA, NA, "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", NA)
  )

  out <- EJAM:::calc_ejscreen_map_fields_added(
    data.frame(
      P_D2_NO2 = c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101),
      check.names = FALSE
    ),
    mapping_for_names = data.frame(
      rname = c(
        "pctile.EJ.DISPARITY.no2.eo",
        "bin.EJ.DISPARITY.no2.eo",
        "text.EJ.DISPARITY.no2.eo"
      ),
      ejscreen_indicator = c("P_D2_NO2", "B_D2_NO2", "T_D2_NO2"),
      `pctile.` = c(1, 0, 0),
      bin. = c(0, 1, 0),
      text. = c(0, 0, 1),
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
