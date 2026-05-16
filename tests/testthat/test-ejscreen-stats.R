test_that("calc_ejscreen_stats accepts custom environmental indicator sets", {
  bgstats <- data.frame(
    bgfips = sprintf("10001000100%s", 1:4),
    ST = c("DE", "DE", "RI", "RI"),
    pop = c(100, 120, 90, 110),
    pctlowinc = c(0.1, 0.2, 0.3, 0.4),
    custom_env = c(1, 2, 3, 4),
    another_env = c(10, 20, 30, 40),
    Demog.Index = c(0.2, 0.3, 0.4, 0.5),
    Demog.Index.Supp = c(0.3, 0.4, 0.5, 0.6),
    Demog.Index.State = c(0.2, 0.3, 0.4, 0.5),
    Demog.Index.Supp.State = c(0.3, 0.4, 0.5, 0.6),
    check.names = FALSE
  )

  out <- EJAM:::calc_ejscreen_stats(
    bgstats = bgstats,
    acs_vars = "pctlowinc",
    enviro_vars = c("custom_env", "another_env"),
    ej_indicator_vars = "custom_env",
    ej_indicator_pctile_vars = "pctile.custom_env",
    ej_indicator_state_pctile_vars = "state.pctile.custom_env",
    ej_index_vars = "EJ.custom.eo",
    ej_index_supp_vars = "EJ.custom.supp",
    ej_index_state_vars = "state.EJ.custom.eo",
    ej_index_supp_state_vars = "state.EJ.custom.supp"
  )

  expect_true(all(c("custom_env", "another_env") %in% names(out$usastats_envirodata)))
  expect_true(all(c("EJ.custom.eo", "EJ.custom.supp") %in% names(out$bgej)))
  expect_true("EJ.custom.eo" %in% names(out$usastats_ej))
  expect_true("state.EJ.custom.eo" %in% names(out$statestats_ej))
})

test_that("calc_ejscreen_stats excludes percapincome from default lookup stages", {
  bgstats <- data.frame(
    bgfips = sprintf("10001000100%s", 1:4),
    ST = c("DE", "DE", "RI", "RI"),
    pop = c(100, 120, 90, 110),
    pctlowinc = c(0.1, 0.2, 0.3, 0.4),
    percapincome = c(10000, NA_real_, 30000, 40000),
    custom_env = c(1, 2, 3, 4),
    Demog.Index = c(0.2, 0.3, 0.4, 0.5),
    Demog.Index.Supp = c(0.3, 0.4, 0.5, 0.6),
    Demog.Index.State = c(0.2, 0.3, 0.4, 0.5),
    Demog.Index.Supp.State = c(0.3, 0.4, 0.5, 0.6),
    check.names = FALSE
  )

  out <- EJAM:::calc_ejscreen_stats(
    bgstats = bgstats,
    enviro_vars = "custom_env",
    ej_indicator_vars = "custom_env",
    ej_indicator_pctile_vars = "pctile.custom_env",
    ej_indicator_state_pctile_vars = "state.pctile.custom_env",
    ej_index_vars = "EJ.custom.eo",
    ej_index_supp_vars = "EJ.custom.supp",
    ej_index_state_vars = "state.EJ.custom.eo",
    ej_index_supp_state_vars = "state.EJ.custom.supp"
  )

  expect_true("pctlowinc" %in% names(out$usastats_acs))
  expect_false("percapincome" %in% names(out$usastats_acs))
  expect_false("percapincome" %in% names(out$statestats_acs))
  expect_false("percapincome" %in% names(out$usastats))
  expect_false("percapincome" %in% names(out$statestats))
})
