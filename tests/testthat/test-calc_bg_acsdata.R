test_that("tract ACS indicators are merged into bg_acsdata without duplicate columns", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    bgid = c("1", "2"),
    pop = c(100, 200),
    pctmin = c(0.2, 0.3),
    pctlowinc = c(0.1, 0.4),
    pctlingiso = c(0.02, 0.03),
    pctlths = c(0.05, 0.06),
    pctpre1960 = c(0.3, 0.4),
    pctnohealthinsurance = c(0.2, 0.3)
  )
  bg_from_tracts <- data.table::data.table(
    bgfips = c("100010001002", "100010001001"),
    pctdisability = c(0.08, 0.09),
    disability = c(16, 9),
    disab_universe = c(200, 100),
    pctnohealthinsurance = c(0.05, 0.06),
    pctlingiso = c(0.99, 0.99)
  )

  out <- EJAM:::merge_bg_acsdata_tract_data(bg_acsdata, bg_from_tracts)

  expect_s3_class(out, "data.table")
  expect_equal(out$bgfips, sort(bg_acsdata$bgfips))
  expect_equal(out$pctdisability, c(0.09, 0.08))
  expect_equal(out$pctnohealthinsurance, c(0.06, 0.05))
  expect_equal(out$pctlingiso, c(0.02, 0.03))
  expect_false(any(duplicated(names(out))))
})

test_that("raw Island Areas DHC downloads normalize block group identifiers", {
  seen_urls <- character()
  fake_download <- function(url) {
    seen_urls <<- c(seen_urls, url)
    if (grepl("/dhcas\\?", url)) {
      return(data.table::data.table(
        NAME = "Block Group 1, Census Tract 0001, Eastern District, American Samoa",
        state = "60",
        county = "010",
        tract = "000100",
        `block group` = "1",
        P1_001N = "100"
      ))
    }
    if (grepl("/dhcgu\\?", url)) {
      return(data.table::data.table(
        NAME = "Block Group 1, Census Tract 0002, Guam",
        state = "66",
        county = "010",
        tract = "000200",
        `block group` = "1",
        P1_001N = "200"
      ))
    }
    stop("unexpected URL: ", url)
  }

  raw <- EJAM:::download_bg_islandareas_raw(
    tables = "P1",
    areas = c("AS", "GU"),
    download_fun = fake_download,
    metadata_fun = NULL
  )

  expect_s3_class(raw, "ejam_bg_islandareas_raw")
  expect_equal(raw$stage, "bg_islandareas_raw")
  expect_equal(names(raw$blockgroup), "P1")
  expect_equal(raw$blockgroup$P1$ST, c("AS", "GU"))
  expect_equal(raw$blockgroup$P1$bgfips, c("600100001001", "660100002001"))
  expect_equal(raw$blockgroup$P1$fips, raw$blockgroup$P1$bgfips)
  expect_equal(raw$blockgroup$P1$SUMLEVEL, c("150", "150"))
  expect_equal(raw$blockgroup$P1$P1_001N, c(100, 200))
  expect_true(any(grepl("for=block%20group", seen_urls, fixed = TRUE)))
})

test_that("Island Areas metadata labels are normalized before canonical mapping", {
  bgfips <- "660100001001"
  x <- data.table::data.table(
    fips = bgfips,
    bgfips = bgfips,
    ST = "GU",
    PCT1_001N = 100,
    PCT1_002N = 45,
    PCT1_003N = 1,
    PCT1_004N = 1,
    PCT1_005N = 1,
    PCT1_006N = 1,
    PCT1_007N = 1,
    PCT1_106N = 55,
    PCT1_107N = 1,
    PCT1_108N = 1,
    PCT1_109N = 1,
    PCT1_110N = 1,
    PCT1_111N = 1,
    PCT1_172N = 2
  )
  metadata <- data.table::data.table(
    name = c(
      "PCT1_001N", "PCT1_002N",
      sprintf("PCT1_%03dN", 3:7),
      "PCT1_106N",
      sprintf("PCT1_%03dN", 107:111),
      "PCT1_172N"
    ),
    label = c(
      " !!Total:",
      " !!Total:!!Male:",
      " !!Total:!!Male:!!Under 1 year",
      " !!Total:!!Male:!!1 year",
      " !!Total:!!Male:!!2 years",
      " !!Total:!!Male:!!3 years",
      " !!Total:!!Male:!!4 years",
      " !!Total:!!Female:",
      " !!Total:!!Female:!!Under 1 year",
      " !!Total:!!Female:!!1 year",
      " !!Total:!!Female:!!2 years",
      " !!Total:!!Female:!!3 years",
      " !!Total:!!Female:!!4 years",
      " !!Total:!!Female:!!65 years"
    )
  )

  out <- EJAM:::add_islandareas_canonical_columns(
    x,
    table = "PCT1",
    endpoint = "dhcgu",
    metadata_fun = function(endpoint, table, key) metadata
  )

  expect_equal(out$ISLANDAREAS_POP, 100)
  expect_equal(out$ISLANDAREAS_MALE, 45)
  expect_equal(out$ISLANDAREAS_FEMALE, 55)
  expect_equal(out$ISLANDAREAS_UNDER5, 10)
  expect_equal(out$ISLANDAREAS_UNDER18, 10)
  expect_equal(out$ISLANDAREAS_OVER64, 2)
})

test_that("Island Areas race metadata mapping uses aggregate labels, not area-specific raw positions", {
  bgfips <- "780100001001"
  x <- data.table::data.table(
    fips = bgfips,
    bgfips = bgfips,
    ST = "VI",
    P5_004N = 60,
    P5_020N = 11,
    P5_021N = 20,
    P5_032N = 7,
    P3_004N = 65,
    P3_020N = 12,
    P3_021N = 20
  )
  p5_metadata <- data.table::data.table(
    name = c("P5_004N", "P5_020N", "P5_021N", "P5_032N"),
    label = c(
      "!!Total:!!Not Hispanic or Latino:!!One Race:!!Black or African American:",
      "!!Total:!!Not Hispanic or Latino:!!One Race:!!Black or African American:!!Other Black or African American",
      "!!Total:!!Not Hispanic or Latino:!!One Race:!!White",
      "!!Total:!!Not Hispanic or Latino:!!Two or More Races:!!All other race combinations"
    )
  )
  p3_metadata <- data.table::data.table(
    name = c("P3_004N", "P3_020N", "P3_021N"),
    label = c(
      "!!Total:!!One Race:!!Black or African American:",
      "!!Total:!!One Race:!!Black or African American:!!Other Black or African American",
      "!!Total:!!One Race:!!White"
    )
  )

  p5 <- EJAM:::add_islandareas_canonical_columns(
    x,
    table = "P5",
    endpoint = "dhcvi",
    metadata_fun = function(endpoint, table, key) p5_metadata
  )
  p3 <- EJAM:::add_islandareas_canonical_columns(
    x,
    table = "P3",
    endpoint = "dhcvi",
    metadata_fun = function(endpoint, table, key) p3_metadata
  )

  expect_equal(p5$ISLANDAREAS_NHBA, 60)
  expect_equal(p5$ISLANDAREAS_NHWA, 20)
  expect_equal(p5$ISLANDAREAS_NHMULTI, NA_real_)
  expect_equal(p3$ISLANDAREAS_BA, 65)
  expect_equal(p3$ISLANDAREAS_WA, 20)
})

test_that("Island Areas rows can be appended to bg_acsdata after transformation", {
  bg_acsdata <- data.table::data.table(
    bgfips = "100010001001",
    bgid = "1",
    pop = 100,
    pctmin = 0.2
  )
  bg_islandareasdata <- data.table::data.table(
    bgfips = "660100002001",
    bgid = "1",
    pop = 200,
    pctmin = 0.8,
    islandareas_source = "2020 Island Areas Census DHC"
  )

  out <- EJAM:::merge_bg_acsdata_islandareas_data(bg_acsdata, bg_islandareasdata)

  expect_s3_class(out, "data.table")
  expect_equal(out$bgfips, c("100010001001", "660100002001"))
  expect_equal(out$pop, c(100, 200))
  expect_equal(out$islandareas_source, c(NA_character_, "2020 Island Areas Census DHC"))
})

test_that("Island Areas demographics can be reduced to EPA-compatible placeholder rows", {
  bg_islandareasdata <- data.table::data.table(
    bgfips = "660100002001",
    bgid = "660100002001",
    ST = "GU",
    statename = "Guam",
    REGION = 9L,
    countyname = NA_character_,
    pop = 200,
    pctmin = 0.8,
    pctlowinc = 0.4,
    pctlingiso = 0.1,
    pctlths = 0.2,
    pctdisability = 0.12,
    islandareas_source = "2020 Island Areas Census DHC"
  )

  out <- EJAM:::calc_bg_islandareas_placeholder_data(bg_islandareasdata)

  expect_s3_class(out, "data.table")
  expect_equal(out$bgfips, "660100002001")
  expect_equal(out$bgid, "660100002001")
  expect_equal(out$ST, "GU")
  expect_equal(out$statename, "Guam")
  expect_equal(out$REGION, 9L)
  expect_equal(out$pop, NA_real_)
  expect_equal(out$pctmin, NA_real_)
  expect_equal(out$pctlowinc, NA_real_)
  expect_match(out$islandareas_source, "placeholder")
})

test_that("raw Island Areas DHC tables transform to bg_acsdata-compatible indicators", {
  bgfips <- "660100001001"
  table_for <- function(values) {
    data.table::as.data.table(c(
      list(
        GEO_ID = paste0("1500000US", bgfips),
        fips = bgfips,
        bgfips = bgfips,
        SUMLEVEL = "150",
        ST = "GU"
      ),
      values
    ))
  }
  pct80_two_plus_cols <- sprintf("PCT80_%03dN", seq(13, 157, by = 12))
  pct80_values <- as.list(stats::setNames(rep(0, length(pct80_two_plus_cols)), pct80_two_plus_cols))
  pct80_values$PCT80_001N <- 80
  pct80_values$PCT80_013N <- 80
  pbg74_values <- list(
    PBG74_001N = 80,
    PBG74_002N = -999999999,
    PBG74_003N = 10,
    PBG74_004N = 10,
    PBG74_005N = 10,
    PBG74_006N = 10,
    PBG74_007N = 10,
    PBG74_008N = 5,
    PBG74_009N = 5,
    PBG74_010N = 20
  )

  raw <- list(
    stage = "bg_islandareas_raw",
    yr = 2020L,
    blockgroup = list(
      PCT1 = table_for(c(
        list(PCT1_001N = 100, PCT1_002N = 45, PCT1_003N = 1, PCT1_004N = 1, PCT1_005N = 1, PCT1_006N = 1, PCT1_007N = 1),
        stats::setNames(as.list(rep(1, 13)), sprintf("PCT1_%03dN", 8:20)),
        list(PCT1_106N = 55, PCT1_107N = 1, PCT1_108N = 1, PCT1_109N = 1, PCT1_110N = 1, PCT1_111N = 1),
        stats::setNames(as.list(rep(1, 13)), sprintf("PCT1_%03dN", 112:124)),
        stats::setNames(as.list(rep(1, 38)), sprintf("PCT1_%03dN", 68:105)),
        stats::setNames(as.list(rep(1, 38)), sprintf("PCT1_%03dN", 172:209))
      )),
      P5 = table_for(list(
        ISLANDAREAS_HISP = 10,
        ISLANDAREAS_NONHISP = 90,
        ISLANDAREAS_NHWA = 30,
        ISLANDAREAS_NHBA = 5,
        ISLANDAREAS_NHAIANA = 2,
        ISLANDAREAS_NHNHPIA = 20,
        ISLANDAREAS_NHAA = 10,
        ISLANDAREAS_NHOTHERALONE = 3,
        ISLANDAREAS_NHMULTI = 20
      )),
      P3 = table_for(list(
        ISLANDAREAS_WA = 30,
        ISLANDAREAS_BA = 5,
        ISLANDAREAS_AIANA = 2,
        ISLANDAREAS_AA = 20,
        ISLANDAREAS_NHPIA = 25,
        ISLANDAREAS_OTHERALONE = 3,
        ISLANDAREAS_MULTI = 15
      )),
      PCT80 = table_for(pct80_values),
      PBG74 = table_for(pbg74_values),
      PBG78 = table_for(list(PBG78_001N = 40, PBG78_002N = 8)),
      PBG19 = table_for(list(PBG19_001N = 50, PBG19_003N = 5, PBG19_004N = 4, PBG19_010N = 3, PBG19_011N = 2)),
      PCT26 = table_for(list(
        PCT26_001N = 90,
        ISLANDAREAS_LAN_ENGLISH = 40,
        ISLANDAREAS_LINGISO = 15
      )),
      HBG18 = table_for(list(HBG18_001N = 70, HBG18_009N = 7, HBG18_010N = 6, HBG18_011N = 1)),
      PBG32 = table_for(list(PBG32_001N = 80, PBG32_005N = 30, PBG32_007N = 3, PBG32_012N = 20, PBG32_014N = 2)),
      H4 = table_for(list(H4_001N = 60, H4_002N = 20, H4_003N = 10)),
      HBG42 = table_for(list(HBG42_001N = 60, HBG42_004N = 45)),
      PBG29 = table_for(list(PBG29_001N = 90, PBG29_004N = 3, PBG29_007N = 4, PBG29_010N = 2)),
      PBG68 = table_for(list(PBG68_001N = 12345)),
      PBG26 = table_for(list(
        PBG26_001N = 90, PBG26_004N = 1, PBG26_007N = 2, PBG26_010N = 3,
        PBG26_013N = 4, PBG26_016N = 5, PBG26_019N = 6
      ))
    )
  )

  out <- EJAM:::calc_bg_islandareasdata(raw)

  expect_equal(out$bgfips, bgfips)
  expect_equal(out$ST, "GU")
  expect_equal(out$statename, "Guam")
  expect_equal(out$REGION, 9)
  expect_equal(out$pop, 100)
  expect_equal(out$pctunder5, 0.1)
  expect_equal(out$pctunder18, 0.36)
  expect_equal(out$pctover64, 0.76)
  expect_equal(out$pctfemale, 0.55)
  expect_equal(out$pctmin, 0.7)
  expect_equal(out$pctnhwa, 0.3)
  expect_equal(out$pctlowinc, 0.75)
  expect_equal(out$pctpoor, 0.2)
  expect_equal(out$pctlths, 14 / 50)
  expect_equal(out$pctlingiso, 15 / 90)
  expect_equal(out$pctpre1960, 14 / 70)
  expect_equal(out$pctunemployed, 5 / 50)
  expect_equal(out$pctownedunits, 30 / 60)
  expect_equal(out$pctnobroadband, 15 / 60)
  expect_equal(out$pctnohealthinsurance, 9 / 90)
  expect_equal(out$pctdisability, 21 / 90)
  expect_equal(out$percapincome, 12345)
})

test_that("Island Areas transformation uses P1 total population when PCT1 is unavailable at block group", {
  bgfips <- "660100001001"
  table_for <- function(values) {
    data.table::as.data.table(c(
      list(
        fips = bgfips,
        bgfips = bgfips,
        ST = "GU"
      ),
      values
    ))
  }
  raw <- list(
    blockgroup = list(
      P1 = table_for(list(P1_001N = 321)),
      PCT1 = table_for(list(PCT1_001N = NA_real_, PCT1_002N = NA_real_, PCT1_106N = NA_real_))
    )
  )

  out <- EJAM:::calc_bg_islandareasdata(raw)

  expect_equal(out$pop, 321)
  expect_equal(out$male, NA_real_)
  expect_equal(out$female, NA_real_)
  expect_equal(out$under5, NA_real_)
  expect_equal(out$under18, NA_real_)
  expect_equal(out$over64, NA_real_)
  expect_equal(out$pctunder5, NA_real_)
  expect_equal(out$pctunder18, NA_real_)
  expect_equal(out$pctover64, NA_real_)
})

test_that("calc_bg_acsdata appends Island Areas placeholder rows by default", {
  bg_acsdata <- data.table::data.table(
    bgfips = "100010001001",
    bgid = "1",
    pop = 100,
    pctmin = 0.2,
    pctlowinc = 0.1,
    pctlingiso = 0.02,
    pctlths = 0.05,
    pctpre1960 = 0.3,
    pctdisability = 0.09
  )
  bg_islandareasdata <- data.table::data.table(
    bgfips = "660100001001",
    bgid = "660100001001",
    pop = 200,
    pctmin = 0.8,
    pctlowinc = 0.4,
    pctlingiso = 0.1,
    pctlths = 0.2,
    pctpre1960 = 0.5,
    pctdisability = 0.12
  )

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) bg_acsdata,
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      data.table::data.table(bgfips = bg_acsdata$bgfips)
    },
    calc_bg_islandareasdata = function(islandareas_raw) {
      expect_equal(islandareas_raw$stage, "bg_islandareas_raw")
      bg_islandareasdata
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    include_tract_data = TRUE,
    include_islandareas_data = TRUE,
    islandareas_raw = list(stage = "bg_islandareas_raw")
  )

  expect_equal(out$bgfips, c("100010001001", "660100001001"))
  expect_equal(out$pop, c(100, NA_real_))
  expect_equal(out$pctmin, c(0.2, NA_real_))
  expect_match(out$islandareas_source[2], "placeholder")
})

test_that("calc_bg_acsdata can opt into DHC-derived Island Areas demographics", {
  bg_acsdata <- data.table::data.table(
    bgfips = "100010001001",
    bgid = "1",
    pop = 100,
    pctmin = 0.2,
    pctlowinc = 0.1,
    pctlingiso = 0.02,
    pctlths = 0.05,
    pctpre1960 = 0.3,
    pctdisability = 0.09
  )
  bg_islandareasdata <- data.table::data.table(
    bgfips = "660100001001",
    bgid = "660100001001",
    pop = 200,
    pctmin = 0.8,
    pctlowinc = 0.4,
    pctlingiso = 0.1,
    pctlths = 0.2,
    pctpre1960 = 0.5,
    pctdisability = 0.12
  )

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) bg_acsdata,
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      data.table::data.table(bgfips = bg_acsdata$bgfips)
    },
    calc_bg_islandareasdata = function(islandareas_raw) bg_islandareasdata,
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    include_tract_data = TRUE,
    include_islandareas_data = TRUE,
    use_islandareas_demographics = TRUE,
    islandareas_raw = list(stage = "bg_islandareas_raw")
  )

  expect_equal(out$bgfips, c("100010001001", "660100001001"))
  expect_equal(out$pop, c(100, 200))
  expect_equal(out$pctmin, c(0.2, 0.8))
})

test_that("pre1960 formula uses Census B25034 pre-1960 bins", {
  x <- data.table::data.table(
    B25034_001 = 300,
    B25034_008 = 60, # 1960 to 1969; not part of pre-1960
    B25034_009 = 50, # 1950 to 1959
    B25034_010 = 40, # 1940 to 1949
    B25034_011 = 30  # 1939 or earlier
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "builtunits",
      "built1950to1959",
      "built1940to1949",
      "builtpre1940",
      "pre1960",
      "pctpre1960"
    )
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$pre1960, 120)
  expect_equal(out$pctpre1960, 120 / 300)
})

test_that("pctnobroadband uses the B28002 broadband subscription universe", {
  x <- data.table::data.table(
    C16002_001 = 200,
    B28002_001 = 100,
    B28002_004 = 30
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "hhlds",
      "broadband_universe",
      "nobroadband",
      "pctnobroadband"
    )
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$nobroadband, 70)
  expect_equal(out$pctnobroadband, 0.7)
})

test_that("pctpoor uses the ACS household poverty universe", {
  x <- data.table::data.table(
    C17002_001 = 500,
    C17002_002 = 40,
    C17002_003 = 60,
    B17017_001 = 200,
    B17017_002 = 30
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "povknownratio",
      "pov50",
      "pov99",
      "poverty_household_universe",
      "poor",
      "pctpoor"
    )
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$povknownratio, 500)
  expect_equal(out$poor, 30)
  expect_equal(out$pctpoor, 0.15)
})

test_that("pctunemployed uses labor force while unemployedbase preserves age-16-plus universe", { # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  x <- data.table::data.table(
    B23025_001 = c(500, 100),
    B23025_003 = c(250, 0),
    B23025_005 = c(25, 0)
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "unemployedbase", # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
      "laborforce_universe",
      "unemployed",
      "pctunemployed"
    )
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$unemployedbase, c(500, 100))  # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  expect_equal(out$laborforce_universe, c(250, 0))
  expect_equal(out$unemployed, c(25, 0))
  expect_equal(out$pctunemployed, c(0.1, NA_real_))
})

test_that("percapincome converts ACS sentinel and missing values to NA", {
  x <- data.table::data.table(
    B19301_001 = c(12000, -666666666, NA_real_)
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname == "percapincome"
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$percapincome, c(12000, NA_real_, NA_real_))
})

test_that("lan_other includes Arabic and other unspecified C16001 categories", {
  x <- data.table::data.table(
    C16001_001 = 100,
    C16001_033 = 7,
    C16001_036 = 13
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c("lan_universe", "lan_other", "pctlan_other")
  ]

  out <- EJAM::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$lan_other, 20)
  expect_equal(out$pctlan_other, 0.2)
})

test_that("tract allocation defaults to decennial 2020 blockgroup weights", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("100010001001", "100010001002"),
        B01001_001 = c(1, 99)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    tractfips = "10001000100",
    bgwt = c(0.25, 0.75)
  )

  testthat::local_mocked_bindings(
    calc_bgwts_from_bg_cenpop2020 = function(bg_cenpop = EJAM::bg_cenpop2020) {
      decennial_weights
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_bgwts(acs_raw = acs_raw, yr = 2022)

  expect_equal(out, decennial_weights)
})

test_that("decennial tract weights are remapped when ACS state tract FIPS do not overlap", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("091104001011", "091104001012"),
        B01001_001 = c(25, 75)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = c("090034001011", "090034001012", "100010001001"),
    tractfips = c("09003400101", "09003400101", "10001000100"),
    bgwt = c(0.4, 0.6, 1)
  )

  out <- NULL
  expect_warning(
    out <- EJAM:::repair_decennial_weights_with_acs_mismatched_states(decennial_weights, acs_raw),
    "Connecticut"
  )

  out_bgfips <- as.character(out$bgfips)
  expect_false(any(startsWith(out_bgfips, "09003")))
  expect_true(all(c("091104001011", "091104001012", "100010001001") %in% out_bgfips))
  expect_equal(out$tractfips[match(c("091104001011", "091104001012"), out_bgfips)], c("09110400101", "09110400101"))
  expect_equal(out$bgwt[match(c("091104001011", "091104001012"), out_bgfips)], c(0.4, 0.6))
})

test_that("decennial tract weights are repaired when ACS blockgroups are missing", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("100010001001", "100010001002"),
        B01001_001 = c(25, 75)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = "100010001001",
    tractfips = "10001000100",
    bgwt = 1
  )

  out <- NULL
  expect_warning(
    out <- EJAM:::repair_decennial_weights_with_acs_mismatched_states(decennial_weights, acs_raw),
    "missing one or more ACS blockgroups"
  )

  expect_equal(out$bgfips, c("100010001001", "100010001002"))
  expect_equal(out$bgwt, c(0.25, 0.75))
})

test_that("tract-derived pctdisability preserves tract rate for zero-weight blockgroups", {
  b18101 <- data.table::data.table(
    GEO_ID = "1400000US10001000100",
    fips = "10001000100",
    SUMLEVEL = "140",
    B18101_001 = 1000,
    B18101_004 = 100,
    B18101_007 = 0,
    B18101_010 = 0,
    B18101_013 = 0,
    B18101_016 = 0,
    B18101_019 = 0,
    B18101_023 = 0,
    B18101_026 = 0,
    B18101_029 = 0,
    B18101_032 = 0,
    B18101_035 = 0,
    B18101_038 = 0
  )
  bgwts <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    tractfips = "10001000100",
    bgwt = c(0, 1)
  )

  testthat::local_mocked_bindings(
    calc_blockgroupstats_bgwts = function(acs_raw, env, yr, weight_source) {
      bgwts
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_from_tract_data(
    yr = 2022,
    tables = "B18101",
    formulas = EJAM::formulas_ejscreen_acs_disability$formula,
    acs_raw = list(tract = list(B18101 = b18101))
  )

  expect_equal(out$disab_universe, c(0, 1000))
  expect_equal(out$disability, c(0, 100))
  expect_equal(out$pctdisability, c(0.1, 0.1))
})

test_that("tract language values are repeated at blockgroup scale", {
  b18101 <- data.table::data.table(
    GEO_ID = "1400000US10001000100",
    fips = "10001000100",
    SUMLEVEL = "140",
    B18101_001 = 1000,
    B18101_004 = 100,
    B18101_007 = 0,
    B18101_010 = 0,
    B18101_013 = 0,
    B18101_016 = 0,
    B18101_019 = 0,
    B18101_023 = 0,
    B18101_026 = 0,
    B18101_029 = 0,
    B18101_032 = 0,
    B18101_035 = 0,
    B18101_038 = 0
  )
  c16001 <- data.table::data.table(
    GEO_ID = "1400000US10001000100",
    fips = "10001000100",
    SUMLEVEL = "140",
    C16001_001 = 100,
    C16001_002 = 80,
    C16001_003 = 20
  )
  bgwts <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    tractfips = "10001000100",
    bgwt = c(0.25, 0.75)
  )

  testthat::local_mocked_bindings(
    calc_blockgroupstats_bgwts = function(acs_raw, env, yr, weight_source) {
      bgwts
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_from_tract_data(
    yr = 2022,
    tables = c("B18101", "C16001"),
    formulas = c(
      EJAM::formulas_ejscreen_acs_disability$formula,
      "lan_universe = C16001_001",
      "lan_english = C16001_002",
      "lan_spanish = C16001_003",
      "pctlan_spanish <- ifelse(lan_universe == 0, 0, as.numeric(lan_spanish) / lan_universe)"
    ),
    acs_raw = list(tract = list(B18101 = b18101, C16001 = c16001))
  )

  expect_equal(out$lan_universe, c(100, 100))
  expect_equal(out$lan_spanish, c(20, 20))
  expect_equal(out$pctlan_spanish, c(0.2, 0.2))
})

test_that("bg_cenpop2020 keeps FIPS when legacy bgid lookup is missing", {
  expect_true(all(c("bgfips", "bgid", "pop2020", "ST") %in% names(EJAM::bg_cenpop2020)))
  ct <- EJAM::bg_cenpop2020[EJAM::bg_cenpop2020$ST == "CT", ]

  expect_gt(nrow(ct), 0)
  expect_false(any(is.na(ct$bgfips)))
  expect_true(all(nchar(ct$bgfips) == 12))
})

test_that("calc_bg_acsdata can save a validated bg_acsdata stage", {
  pipeline_dir <- file.path(tempdir(), "ejam-calc-bg-acsdata-test")

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) {
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        bgid = c("1", "2"),
        pop = c(100, 200),
        pctmin = c(0.2, 0.3),
        pctlowinc = c(0.1, 0.4),
        pctlingiso = c(0.02, 0.03),
        pctlths = c(0.05, 0.06),
        pctpre1960 = c(0.3, 0.4)
      )
    },
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      expect_equal(tract_weight_source, "decennial2020")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        pctdisability = c(0.09, 0.08),
        disability = c(9, 16),
        disab_universe = c(100, 200)
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    save_stage = TRUE,
    pipeline_dir = pipeline_dir
  )

  expect_true(file.exists(file.path(pipeline_dir, "bg_acsdata.csv")))
  loaded <- as.data.frame(EJAM:::ejscreen_pipeline_load("bg_acsdata", pipeline_dir, format = "csv"))
  loaded$bgid <- as.character(loaded$bgid)
  expect_equal(
    loaded,
    as.data.frame(out)
  )
  expect_true(all(c("pctpre1960", "pctdisability", "disab_universe") %in% names(out)))
})

test_that("download_bg_acs_raw saves a folder-plus-manifest raw ACS checkpoint", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acs-raw-test")

  testthat::local_mocked_bindings(
    download_acs_raw_tables = function(yr, tables, fips, fiveorone, download_fun, download_timeout, download_retries) {
      expect_true(is.function(download_fun))
      expect_equal(download_timeout, 3600)
      expect_equal(download_retries, 2)
      stats::setNames(lapply(seq_along(tables), function(i) {
        data.table::data.table(
          GEO_ID = paste0("1500000US", fips, "_", i),
          fips = paste0("10001000100", i),
          SUMLEVEL = if (fips == "tract") "140" else "150",
          B01001_001 = i
        )
      }), tables)
    },
    .package = "EJAM"
  )

  raw <- download_bg_acs_raw(
    yr = 2024,
    blockgroup_tables = c("B01001", "B03002"),
    tract_tables = "B18101",
    pipeline_dir = pipeline_dir,
    save_stage = TRUE,
    stage_format = "csv"
  )

  expect_s3_class(raw, "ejam_bg_acs_raw")
  expect_equal(names(raw$blockgroup), c("B01001", "B03002"))
  expect_equal(names(raw$tract), "B18101")
  raw_dir <- file.path(pipeline_dir, "bg_acs_raw")
  expect_true(dir.exists(raw_dir))
  expect_true(file.exists(file.path(raw_dir, "manifest.rds")))
  expect_true(file.exists(file.path(raw_dir, "manifest.csv")))
  expect_true(file.exists(file.path(raw_dir, "blockgroup", "B01001.csv")))
  expect_true(file.exists(file.path(raw_dir, "tract", "B18101.csv")))
  loaded <- EJAM:::ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "csv")
  expect_equal(loaded$yr, 2024)
  expect_equal(names(loaded$blockgroup), c("B01001", "B03002"))
})

test_that("raw ACS folder load includes user-added table files", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acs-raw-manual-table-test")
  raw_dir <- file.path(pipeline_dir, "bg_acs_raw")
  dir.create(file.path(raw_dir, "blockgroup"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(raw_dir, "tract"), recursive = TRUE, showWarnings = FALSE)
  saveRDS(list(
    stage = "bg_acs_raw",
    yr = 2024,
    fiveorone = "5",
    source = "test",
    raw_acs_storage = "folder",
    tables = data.frame()
  ), file.path(raw_dir, "manifest.rds"))
  saveRDS(data.table::data.table(
    GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
    fips = c("100010001001", "100010001002"),
    SUMLEVEL = "150",
    B99999_001 = c(1, 2)
  ), file.path(raw_dir, "blockgroup", "B99999.rds"))

  loaded <- EJAM:::ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "rds")

  expect_s3_class(loaded, "ejam_bg_acs_raw")
  expect_equal(names(loaded$blockgroup), "B99999")
  expect_equal(loaded$blockgroup$B99999$B99999_001, c(1, 2))
})

test_that("merge_acs_raw_tables preserves blockgroups missing from one ACS table", {
  raw_tables <- list(
    B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 200)
    ),
    B19301 = data.table::data.table(
      GEO_ID = "1500000US100010001001",
      fips = "100010001001",
      SUMLEVEL = "150",
      B19301_001 = 12345
    )
  )

  expect_warning(
    out <- EJAM:::merge_acs_raw_tables(raw_tables),
    "Not every ACS raw table has the same number of rows"
  )

  expect_equal(sort(out$fips), c("100010001001", "100010001002"))
  expect_equal(out[order(fips)]$B01001_001, c(100, 200))
  expect_true(is.na(out[order(fips)]$B19301_001[2]))
})

test_that("calc_blockgroupstats_acs can transform a raw ACS table checkpoint", {
  raw <- list(
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 0)
    ))
  )

  out <- EJAM:::calc_blockgroupstats_acs(
    yr = 2024,
    formulas = c(
      "pop = B01001_001",
      "pctall = ifelse(pop == 0, 0, pop / pop)"
    ),
    tables = "B01001",
    acs_raw = raw
  )

  expect_equal(out$bgfips, c("100010001001", "100010001002"))
  expect_equal(out$pop, c(100, 0))
  expect_equal(out$pctall, c(1, 0))
})

test_that("calc_bg_acsdata can read raw ACS stage before formula transformation", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acsdata-from-raw-test")
  raw <- list(
    stage = "bg_acs_raw",
    yr = 2024,
    blockgroup_tables = "B01001",
    tract_tables = "B18101",
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 200)
    )),
    tract = list(B18101 = data.table::data.table(
      GEO_ID = c("1400000US10001000100"),
      fips = "10001000100",
      SUMLEVEL = "140",
      B18101_001 = 300
    ))
  )
  EJAM:::ejscreen_pipeline_save(raw, "bg_acs_raw", pipeline_dir, format = "rds")

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) {
      expect_equal(acs_raw$stage, "bg_acs_raw")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        bgid = c("1", "2"),
        pop = c(100, 200),
        pctmin = c(0.2, 0.3),
        pctlowinc = c(0.1, 0.4),
        pctlingiso = c(0.02, 0.03),
        pctlths = c(0.05, 0.06),
        pctpre1960 = c(0.3, 0.4)
      )
    },
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      expect_equal(tract_weight_source, "decennial2020")
      expect_equal(names(acs_raw$tract), "B18101")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        pctdisability = c(0.09, 0.08),
        disability = c(9, 16),
        disab_universe = c(100, 200)
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    acs_raw_stage = "bg_acs_raw",
    pipeline_dir = pipeline_dir,
    stage_format = "rds"
  )

  expect_true(all(c("pop", "pctdisability") %in% names(out)))
})

test_that("ACS raw blockgroup population can provide same-vintage tract weights", {
  raw <- list(
    stage = "bg_acs_raw",
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US091104001011", "1500000US091104001012", "1500000US091104001021"),
      fips = c("091104001011", "091104001012", "091104001021"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 300, 0)
    ))
  )

  out <- EJAM:::calc_bgwts_from_acs_raw(raw)

  expect_equal(out$bgfips, raw$blockgroup$B01001$fips)
  expect_equal(out$tractfips, c("09110400101", "09110400101", "09110400102"))
  expect_equal(out$bgwt, c(0.25, 0.75, 0))
})

test_that("tract weight selection falls back to nationwide weights when packaged weights are unavailable", {
  fallback <- data.table::data.table(
    bgfips = "010010201001",
    tractfips = "01001020100",
    bgwt = 1
  )
  testthat::local_mocked_bindings(
    calc_bgwts_from_bg_cenpop2020 = function(bg_cenpop = EJAM::bg_cenpop2020) NULL,
    calc_bgwts_nationwide = function(year = 2020) fallback,
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_bgwts(acs_raw = NULL, env = emptyenv())

  expect_equal(out, fallback)
})
