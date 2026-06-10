# Tests for the EJSCREEN web-app pipeline outputs added for issue #395:
#   calc_acs_by_geography(), calc_ejscreen_threshold_layers(),
#   calc_ejscreen_threshold_layers_from_exports(), ejscreen_compare_geography_to_epa().

test_that("calc_acs_by_geography excludes Island Areas by default (identified by ST)", {
  bg <- data.frame(
    bgfips = c("010010201001", "010010201002", "6000100", "7800000001"),
    ST     = c("AL", "AL", "AS", "VI"),
    pop    = c(100, 200, 50, 60),
    lowinc = c(20, 40, 10, 12),
    povknownratio = c(80, 160, 40, 48),
    pctlowinc     = c(0.25, 0.25, 0.20, 0.25),
    stringsAsFactors = FALSE
  )
  inc <- suppressMessages(calc_acs_by_geography(bg, levels = "blockgroup", exclude_islandareas = FALSE))$blockgroup
  exc <- suppressMessages(calc_acs_by_geography(bg, levels = "blockgroup", exclude_islandareas = TRUE))$blockgroup
  expect_equal(nrow(inc), 4L)
  expect_equal(nrow(exc), 2L)
  expect_false(any(exc$bgfips %in% c("6000100", "7800000001")))
})

test_that("calc_acs_by_geography sums counts and uses per-indicator (denominator) weights", {
  bg <- data.frame(
    bgfips = c("010010201001", "010010201002"), ST = c("AL", "AL"),
    pop = c(100, 300), lowinc = c(25, 90),
    povknownratio = c(100, 100), pctlowinc = c(0.25, 0.30),
    stringsAsFactors = FALSE
  )
  tr <- suppressMessages(calc_acs_by_geography(bg, levels = "tract", exclude_islandareas = FALSE))$tract
  expect_equal(nrow(tr), 1L)
  expect_equal(tr$pop, 400)        # sum of counts
  expect_equal(tr$lowinc, 115)     # sum of counts
  # pctlowinc weighted by povknownratio (100,100) = mean(0.25,0.30) = 0.275,
  # which differs from the population-weighted value (0.2875) -> confirms the right weight.
  expect_equal(tr$pctlowinc, 0.275, tolerance = 1e-9)
})

test_that("calc_acs_by_geography does not mutate a data.table input and honors id_col", {
  dt <- data.table::data.table(
    bgfips = c("010010201001", "010010201002"), ST = c("AL", "AL"),
    pop = c(1, 2), pctlowinc = c(0.1, 0.2), povknownratio = c(10, 20)
  )
  nb <- ncol(dt)
  invisible(suppressMessages(calc_acs_by_geography(bg = dt, levels = "state", exclude_islandareas = FALSE)))
  expect_equal(ncol(dt), nb)  # no leaked ..num../..wgt.. helper columns

  r <- suppressMessages(calc_acs_by_geography(
    bg = data.frame(ID = c("010010201001"), pop = 5), id_col = "ID",
    levels = "blockgroup", exclude_islandareas = FALSE))$blockgroup
  expect_equal(names(r)[1], "ID")  # block-group output id uses id_col
})

test_that("calc_acs_by_geography repairs a numeric FIPS column before deriving parent GEOIDs", {
  # 10010201001 is "010010201001" with its leading zero lost (Alabama, ST=01).
  bg <- data.frame(
    bgfips = c(10010201001, 10010201002), ST = c("AL", "AL"),
    pop = c(100, 300), pctlowinc = c(0.25, 0.30), povknownratio = c(100, 100),
    stringsAsFactors = FALSE
  )
  r <- suppressMessages(calc_acs_by_geography(bg, levels = c("blockgroup", "tract", "state")))
  expect_equal(sort(r$blockgroup$bgfips), c("010010201001", "010010201002"))
  expect_equal(r$tract$tractfips, "01001020100")
  expect_equal(r$state$statefips, "01")
})

test_that("calc_ejscreen_threshold_layers computes P1..P100 hit counts (NA-aware, rounded)", {
  df <- data.frame(bgfips = c("A", "B"),
                   P_D2_PM25 = c(4, 10), P_D2_OZONE = c(90.4, 10), P_D2_X = c(90, NA))
  L <- calc_ejscreen_threshold_layers(
    df, id_col = "bgfips", layers = "us_ejindexes",
    cols_us_ej = c("P_D2_PM25", "P_D2_OZONE", "P_D2_X"))$us_ejindexes
  expect_equal(ncol(L), 1L + 3L + 100L)            # bgfips + 3 ranks + P1..P100
  expect_equal(L$P4[1], 1)                          # A: PM25 = 4
  expect_equal(L$P90[1], 2)                         # A: OZONE rounds 90.4->90, X = 90
  expect_equal(sum(L[1, paste0("P", 1:100)]), 3)    # 3 non-NA indexes
  expect_equal(L$P10[2], 2)                         # B: PM25 = 10, OZONE = 10 (X is NA)
  expect_equal(sum(L[2, paste0("P", 1:100)]), 2)    # NA ignored
})

test_that("calc_ejscreen_threshold_layers clamps out-of-range rounded ranks into P1/P100", {
  # 0.4 rounds to 0 -> P1; 100.6 rounds to 101 -> P100; every non-NA rank counted once.
  df <- data.frame(bgfips = "A", P_D2_A = 0.4, P_D2_B = 100.6, P_D2_C = 55)
  L <- calc_ejscreen_threshold_layers(
    df, id_col = "bgfips", layers = "us_ejindexes",
    cols_us_ej = c("P_D2_A", "P_D2_B", "P_D2_C"))$us_ejindexes
  expect_equal(L$P1, 1)
  expect_equal(L$P100, 1)
  expect_equal(L$P55, 1)
  expect_equal(sum(L[1, paste0("P", 1:100)]), 3)
})

test_that("calc_ejscreen_threshold_layers matches the colcounter identity for in-range ranks", {
  set.seed(395)
  m <- matrix(sample(c(1:100, NA), 8 * 5, replace = TRUE), nrow = 8)
  colnames(m) <- paste0("P_D2_", LETTERS[1:5])
  df <- data.frame(bgfips = paste0("bg", 1:8), m)
  L <- calc_ejscreen_threshold_layers(
    df, id_col = "bgfips", layers = "us_ejindexes",
    cols_us_ej = colnames(m))$us_ejindexes
  for (k in c(1, 17, 50, 99, 100)) {
    expected <- colcounter(m, threshold = k, or.tied = TRUE, na.rm = TRUE) -
      colcounter(m, threshold = k + 1, or.tied = TRUE, na.rm = TRUE)
    expect_equal(L[[paste0("P", k)]], unname(expected))
  }
})

test_that("calc_ejscreen_threshold_layers_from_exports builds the four layers", {
  nat <- data.frame(ID = c("A", "B"), P_D2_PM25 = c(10, 90), P_D5_PM25 = c(20, 80))
  st  <- data.frame(ID = c("A", "B"), P_D2_PM25 = c(5, 95),  P_D5_PM25 = c(15, 85))
  res <- calc_ejscreen_threshold_layers_from_exports(nat, st)
  expect_setequal(names(res),
                  c("us_ejindexes", "us_supplemental", "state_ejindexes", "state_supplemental"))
  expect_equal(res$us_ejindexes$P10[1], 1)
  expect_equal(res$us_supplemental$P20[1], 1)
  expect_equal(res$state_ejindexes$P5[1], 1)
  # national only -> only the two US layers
  res_us <- calc_ejscreen_threshold_layers_from_exports(nat, NULL)
  expect_setequal(names(res_us), c("us_ejindexes", "us_supplemental"))
})

test_that("ejscreen_compare_geography_to_epa maps names, scales pct, keeps already-matching, ignores unmapped", {
  ejam <- data.frame(tractfips = c("01001020100", "06037207400"),
                     pop = c(1865, 3492), pctlowinc = c(0.2568, 0.30),
                     P_D2_PM25 = c(50, 60), stringsAsFactors = FALSE)
  epa  <- data.frame(STCNTR = c("01001020100", "06037207400"),
                     TOTALPOP = c(1865, 3492), PCT_LOWINC = c(25.68, 30.00),
                     P_D2_PM25 = c(50, 60), UNMAPPED_EPA = c(9, 9), stringsAsFactors = FALSE)
  cmp <- ejscreen_compare_geography_to_epa(ejam, epa)
  expect_equal(attr(cmp, "n_joined"), 2L)
  expect_true(all(c("pop", "pctlowinc", "P_D2_PM25") %in% cmp$rname))  # acs-mapped + already-matching
  expect_false("UNMAPPED_EPA" %in% cmp$reference)                      # unmapped reference col ignored
  expect_true(all(abs(cmp$cor - 1) < 1e-6))                            # values agree (pct scaled by 100)
})
