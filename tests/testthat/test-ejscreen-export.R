test_that("map_headernames CSV is the package-data source", {
  csv_path <- file.path("data-raw", "map_headernames.csv")
  if (!file.exists(csv_path)) {
    csv_path <- file.path("..", "..", "data-raw", "map_headernames.csv")
  }
  testthat::skip_if_not(file.exists(csv_path))

  csv <- utils::read.csv(
    csv_path,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = c(""),
    colClasses = "character"
  )
  csv[is.na(csv)] <- ""
  mh <- as.data.frame(EJAM::map_headernames, stringsAsFactors = FALSE)
  mh[is.na(mh)] <- ""

  expect_identical(names(csv), names(mh))
  expect_equal(nrow(csv), nrow(mh))
  for (col in names(csv)) {
    expect_equal(as.character(csv[[col]]), as.character(mh[[col]]), info = col)
  }
  expect_equal(csv$newsort[1], "010116162")
})

test_that("map_headernames validation does not create metadata rows", {
  mapping <- data.frame(
    rname = c("no2", "pctpre1960", "pctile.pctpre1960", "pctile.EJ.DISPARITY.no2.eo"),
    csvname = c("NO2", "PRE1960PCT", "P_LDPNT", "P_D2_NO2"),
    ejscreen_indicator = c("NO2", "PRE1960PCT", "P_LDPNT", "P_D2_NO2"),
    ejscreen_apinames_old = c("RAW_E_NO2", "RAW_E_LEAD", "", ""),
    ejscreen_bin = c("", "", "WRONG_BIN", "WRONG_D2_BIN"),
    ejscreen_text = c("", "", "WRONG_TEXT", "WRONG_D2_TEXT"),
    `pctile.` = c(0, 0, 1, 1),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::validate_map_headernames_ejscreen_names(mapping)
  expect_identical(out, mapping)
  expect_false("bgfips" %in% out$rname)
  expect_false("bin.pctpre1960" %in% out$rname)
  expect_false("text.EJ.DISPARITY.no2.eo" %in% out$rname)
})

test_that("strict map_headernames validation rejects legacy generated-schema inputs", {
  mapping <- data.frame(
    rname = c("state.pctile.Demog.Index", "internal_for_pctile"),
    csvname = c("S_P_DEMOGIDX_2ST", "use for pctile and avg but don't report"),
    ejscreen_apinames_old = c("S_D_DEMOGIDX2ST_PER", ""),
    ejscreen_indicator = c("***special", "use for pctile and avg but don't report"),
    stringsAsFactors = FALSE
  )

  expect_error(
    EJAM:::validate_map_headernames_ejscreen_names(mapping, strict = TRUE),
    "validation failed"
  )
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

test_that("calc_ejscreen_export uses EJSCREEN-compatible unemployment zero-denominator values", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "100010001002", "100010001003"),
    pctunemployed = c(NA_real_, NA_real_, NA_real_),
    laborforce_universe = c(0, 0, NA_real_),
    unemployedbase = c(0, 10, NA_real_),
    stringsAsFactors = FALSE
  )
  usastats_acs <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "mean", "100"),
    pctunemployed = c(0, 0.5, 1),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "pctunemployed", "pctile.pctunemployed"),
    ejscreen_indicator = c("ID", "UNEMPPCT", "P_UNEMPPCT"),
    `pctile.` = c(0, 0, 1),
    stringsAsFactors = FALSE
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = data.frame(bgfips = blockgroupstats$bgfips, stringsAsFactors = FALSE),
    usastats_acs = usastats_acs,
    mapping_for_names = mapping
  )

  expect_equal(out$UNEMPPCT, c(0, NA_real_, NA_real_))
  expect_equal(out$P_UNEMPPCT, c(0, NA_real_, NA_real_))
  expect_equal(out$B_UNEMPPCT, c(1L, NA_integer_, NA_integer_))
  expect_equal(out$T_UNEMPPCT, c("0 %ile", "", ""))
})

test_that("calc_ejscreen_export applies EPA reference rounding only where configured", {
  blockgroupstats <- data.frame(
    bgfips = "100010001001",
    ST = "DE",
    pctdisability = 0.2469572914361584103915,
    pctlowinc = 0.2469572914361584103915,
    stringsAsFactors = FALSE
  )
  statestats_acs <- data.frame(
    REGION = "DE",
    PCTILE = c("0", "mean", "86", "87", "100"),
    pctdisability = c(0, 0.2, 0.244066047471620, 0.2469572914361584659027, 1),
    pctlowinc = c(0, 0.2, 0.244066047471620, 0.2469572914361584659027, 1),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c(
      "bgfips", "pctdisability", "pctile.pctdisability",
      "pctlowinc", "pctile.pctlowinc"
    ),
    ejscreen_indicator = c(
      "ID", "DISABILITYPCT", "P_DISABILITYPCT",
      "LOWINCPCT", "P_LOWINCPCT"
    ),
    `pctile.` = c(0, 0, 1, 0, 1),
    stringsAsFactors = FALSE
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = data.frame(bgfips = blockgroupstats$bgfips, stringsAsFactors = FALSE),
    statestats_acs = statestats_acs,
    mapping_for_names = mapping,
    export_percentile_scope = "state",
    include_ejscreen_map_fields = FALSE
  )

  expect_equal(out$P_DISABILITYPCT, 87)
  expect_equal(out$P_LOWINCPCT, 86)
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

test_that("FeatureServer exceed-count fields are recomputed from exported percentile fields", {
  x <- data.frame(
    P_D2_PM25 = c(79, 80, 90, NA),
    P_D2_NO2 = c(NA, 79, 80, NA),
    P_D5_PM25 = c(80, 79, 90, NA),
    P_D5_NO2 = c(79, 80, NA, NA),
    EXCEED_COUNT_80 = c(99, 99, 99, 99),
    EXCEED_COUNT_80_SUP = c(99, 99, 99, 99),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::calc_ejscreen_feature_server_fields_added(
    x,
    feature_server_fields = c(
      "EXCEED_COUNT_80", "EXCEED_COUNT_80_SUP",
      "EXCEED_COUNT_90", "EXCEED_COUNT_90_SUP"
    )
  )

  expect_equal(out$EXCEED_COUNT_80, c(0L, 1L, 2L, NA_integer_))
  expect_equal(out$EXCEED_COUNT_80_SUP, c(1L, 1L, 1L, NA_integer_))
  expect_equal(out$EXCEED_COUNT_90, c(0L, 0L, 1L, NA_integer_))
  expect_equal(out$EXCEED_COUNT_90_SUP, c(0L, 0L, 1L, NA_integer_))
})

test_that("FeatureServer symbology stays missing when exceed count cannot be computed", {
  x <- data.frame(
    P_D2_PM25 = c(NA, 79, 80),
    stringsAsFactors = FALSE
  )

  out <- EJAM:::calc_ejscreen_feature_server_fields_added(
    x,
    feature_server_fields = c("EXCEED_COUNT_80", "SYMBOLOGY_EXCEED_COUNT_80")
  )

  expect_equal(out$EXCEED_COUNT_80, c(NA_integer_, 0L, 1L))
  expect_equal(out$SYMBOLOGY_EXCEED_COUNT_80, c(
    NA_character_,
    "0 EJ Indexes over 80th %tile",
    "1-13 EJ Indexes over 80th %tile"
  ))
})

test_that("calc_ejscreen_export keeps Island Areas rows visible with available environmental values", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "660100001001"),
    ST = c("DE", "GU"),
    pop = c(100, NA_real_),
    pctmin = c(0.2, NA_real_),
    pm = c(7, 9),
    stringsAsFactors = FALSE
  )
  bgej <- data.frame(
    bgfips = blockgroupstats$bgfips,
    stringsAsFactors = FALSE
  )
  usastats_envirodata <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "mean", "50", "100"),
    pm = c(0, 6, 7, 9),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c("bgfips", "pop", "pctmin", "pm", "pctile.pm"),
    ejscreen_indicator = c("ID", "ACSTOTPOP", "MINORPCT", "PM25", "P_PM25"),
    csvname = c("ID", "ACSTOTPOP", "MINORPCT", "PM25", "P_PM25"),
    `pctile.` = c(0, 0, 0, 0, 1),
    stringsAsFactors = FALSE
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = bgej,
    usastats_envirodata = usastats_envirodata,
    mapping_for_names = mapping
  )

  gu <- out[out$ID == "660100001001", ]
  expect_equal(nrow(out), 2L)
  expect_equal(gu$PM25, 9)
  expect_equal(gu$P_PM25, 100)
  expect_equal(gu$B_PM25, 11L)
  expect_equal(gu$T_PM25, "100 %ile")
  expect_true(is.na(gu$ACSTOTPOP))
  expect_true(is.na(gu$MINORPCT))
})

test_that("calc_ejscreen_export can emulate EPA StatePct export field semantics", {
  blockgroupstats <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    ST = c("DE", "DE"),
    `Demog.Index` = c(0.1, 0.2),
    `Demog.Index.State` = c(0.7, 0.8),
    pm = c(10, 20),
    check.names = FALSE
  )
  bgej <- data.frame(
    bgfips = blockgroupstats$bgfips,
    `EJ.DISPARITY.pm.eo` = c(1, 2),
    `state.EJ.DISPARITY.pm.eo` = c(5, 10),
    check.names = FALSE
  )
  statestats_acs <- data.frame(
    REGION = "DE",
    PCTILE = c("0", "mean", "50", "100"),
    `Demog.Index.State` = c(0, 0.75, 0.7, 0.8),
    check.names = FALSE
  )
  statestats_envirodata <- data.frame(
    REGION = "DE",
    PCTILE = c("0", "mean", "50", "100"),
    pm = c(0, 15, 10, 20),
    check.names = FALSE
  )
  statestats_ej <- data.frame(
    REGION = "DE",
    PCTILE = c("0", "mean", "50", "100"),
    `state.EJ.DISPARITY.pm.eo` = c(0, 7.5, 5, 10),
    check.names = FALSE
  )
  mapping <- data.frame(
    rname = c(
      "bgfips", "Demog.Index", "Demog.Index.State", "pctile.Demog.Index",
      "pm", "pctile.pm",
      "EJ.DISPARITY.pm.eo", "state.EJ.DISPARITY.pm.eo",
      "pctile.EJ.DISPARITY.pm.eo",
      "bin.pm", "text.pm",
      "bin.EJ.DISPARITY.pm.eo", "text.EJ.DISPARITY.pm.eo"
    ),
    ejscreen_indicator = c(
      "ID", "DEMOGIDX_2", "DEMOGIDX_2ST", "P_DEMOGIDX_2",
      "PM25", "P_PM25",
      "D2_PM25", "S_D2_PM25",
      "P_D2_PM25",
      "B_PM25", "T_PM25",
      "B_D2_PM25", "T_D2_PM25"
    ),
    `pctile.` = c(rep(0, 3), 1, 0, 1, rep(0, 2), 1, rep(0, 4)),
    bin. = c(rep(0, 9), 1, 0, 1, 0),
    text. = c(rep(0, 9), 0, 1, 0, 1),
    stringsAsFactors = FALSE
  )
  feature_fields <- c(
    "ID", "DEMOGIDX_2", "P_DEMOGIDX_2", "PM25", "P_PM25",
    "D2_PM25", "P_D2_PM25", "B_PM25", "T_PM25",
    "B_D2_PM25", "T_D2_PM25", "EXCEED_COUNT_80"
  )

  out <- calc_ejscreen_export(
    blockgroupstats = blockgroupstats,
    bgej = bgej,
    statestats_acs = statestats_acs,
    statestats_envirodata = statestats_envirodata,
    statestats_ej = statestats_ej,
    mapping_for_names = mapping,
    export_percentile_scope = "state",
    feature_server_fields = feature_fields
  )

  expect_false("DEMOGIDX_2ST" %in% names(out))
  expect_false("S_D2_PM25" %in% names(out))
  expect_equal(out$DEMOGIDX_2, blockgroupstats$Demog.Index.State)
  expect_equal(out$D2_PM25, bgej$state.EJ.DISPARITY.pm.eo)
  expect_equal(out$P_DEMOGIDX_2, c(50, 100))
  expect_equal(out$P_PM25, c(50, 100))
  expect_equal(out$P_D2_PM25, c(50, 100))
  expect_equal(out$B_PM25, c(6L, 11L))
  expect_equal(out$T_PM25, c("50 %ile", "100 %ile"))
  expect_equal(out$EXCEED_COUNT_80, c(0L, 1L))
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
    rname = c("bgfips", "keepme", "internal_a", "internal_b"),
    ejscreen_indicator = c("ID", "KEEP", "use for pctile and avg but don’t report", "use for pctile and avg but don’t report"),
    csvname = c("ID", "KEEP", "use for pctile and avg but don’t report", "use for pctile and avg but don’t report"),
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

test_that("calc_ejscreen_export_reference_report preserves IDs and summarizes differences", {
  old_width <- getOption("width")
  on.exit(options(width = old_width), add = TRUE)
  options(width = 40)

  reference <- data.frame(
    ID = c("010010201001", "020200001001"),
    A = c(1, 2),
    B = c(NA_real_, 3),
    C = c("same", "old"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  ejscreen_export <- data.frame(
    ID = reference$ID,
    A = c(1, 2.01),
    B = c(0, 3),
    C = c("same", "new"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  reference_path <- tempfile(fileext = ".csv")
  data.table::fwrite(reference, reference_path)

  out <- EJAM:::calc_ejscreen_export_reference_report(
    ejscreen_export = ejscreen_export,
    reference_path = reference_path,
    reference_format = "csv",
    numeric_tolerance = 0.001
  )

  expect_equal(out$summary$value[out$summary$metric == "shared_ids"], "2")
  expect_equal(out$summary$value[out$summary$metric == "columns_with_differences"], "3")
  expect_equal(
    out$summary$value[out$summary$metric == "columns_with_substantive_numeric_relative_differences_gt_0.1pct"],
    "1"
  )
  expect_true(any(grepl("varlist.*rname.*column.*example_pipeline", out$text)))
  expect_true(all(c("varlist", "rname", "relative_tolerance") %in% names(out$report)))
  expect_false("diff_gt_1e_12" %in% names(out$report))
  expect_equal(out$report$na_mismatch[out$report$column == "B"], 1L)
  expect_true(all(c("zero_ref", "zero_pipeline") %in% names(out$report)))
  expect_equal(out$report$zero_pipeline[out$report$column == "B"], 1L)
  expect_equal(out$report$example_id[out$report$column == "A"], "020200001001")
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
    c(NA_integer_, NA_integer_, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, NA_integer_)
  )
  expect_equal(
    EJAM:::calc_ejscreen_map_pctile_text(c(NA, -1, 0, 9, 10, 89, 90, 94, 95, 100, 101)),
    c("", "", "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", "")
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

  expect_equal(out$B_D2_NO2, c(NA_integer_, NA_integer_, 1L, 1L, 2L, 9L, 10L, 10L, 11L, 11L, NA_integer_))
  expect_equal(
    out$T_D2_NO2,
    c("", "", "0 %ile", "9 %ile", "10 %ile", "89 %ile",
      "90 %ile", "94 %ile", "95 %ile", "100 %ile", "")
  )
})
