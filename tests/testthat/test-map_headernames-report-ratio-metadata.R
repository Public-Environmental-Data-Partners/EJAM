test_that("map_headernames is regenerated from csv, not the legacy xlsx workbook", {
  script <- readLines(test_path("../../data-raw/datacreate_map_headernames.R"), warn = FALSE)

  expect_true(any(grepl("map_headernames[.]csv", script)))
  expect_false(any(grepl("read_xlsx|readxl", script)))
})

test_that("map_headernames includes report ratio metadata requested in issues 240 and 241", {
  community_ratio_vars <- setdiff(names_community, "occupiedunits")

  expected <- list(
    names_health_ratio_to_avg = paste0(
      "ratio.to.avg.",
      c("pctdisability", "lowlifex", "rateheartdisease", "rateasthma", "ratecancer")
    ),
    names_health_ratio_to_state_avg = paste0(
      "ratio.to.state.avg.",
      c("pctdisability", "lowlifex", "rateheartdisease", "rateasthma", "ratecancer")
    ),
    names_climate_ratio_to_avg = paste0(
      "ratio.to.avg.",
      c("pctflood", "pctfire", "pctfire30", "pctflood30")
    ),
    names_climate_ratio_to_state_avg = paste0(
      "ratio.to.state.avg.",
      c("pctflood", "pctfire", "pctfire30", "pctflood30")
    ),
    names_criticalservice_ratio_to_avg = paste0(
      "ratio.to.avg.",
      c("pctnobroadband", "pctnohealthinsurance")
    ),
    names_criticalservice_ratio_to_state_avg = paste0(
      "ratio.to.state.avg.",
      c("pctnobroadband", "pctnohealthinsurance")
    ),
    names_d_language_ratio_to_avg = paste0("ratio.to.avg.", names_d_language),
    names_d_language_ratio_to_state_avg = paste0("ratio.to.state.avg.", names_d_language),
    names_d_languageli_ratio_to_avg = paste0("ratio.to.avg.", names_d_languageli),
    names_d_languageli_ratio_to_state_avg = paste0("ratio.to.state.avg.", names_d_languageli),
    names_age_ratio_to_avg = paste0("ratio.to.avg.", names_age),
    names_age_ratio_to_state_avg = paste0("ratio.to.state.avg.", names_age),
    names_d_extra_ratio_to_avg = paste0("ratio.to.avg.", names_d_extra),
    names_d_extra_ratio_to_state_avg = paste0("ratio.to.state.avg.", names_d_extra),
    names_community_ratio_to_avg = paste0("ratio.to.avg.", community_ratio_vars),
    names_community_ratio_to_state_avg = paste0("ratio.to.state.avg.", community_ratio_vars)
  )

  for (varlist in names(expected)) {
    rows <- map_headernames[map_headernames$varlist == varlist, , drop = FALSE]
    expect_true(
      setequal(rows$rname, expected[[varlist]]),
      label = paste0("rows for ", varlist, " match expected rnames")
    )
  }

  expect_false("ratio.to.avg.occupiedunits" %in% map_headernames$rname)
  expect_false("ratio.to.state.avg.occupiedunits" %in% map_headernames$rname)
})

test_that("map_headernames includes related avg and pctile rows for expanded report groups", {
  community_vars <- setdiff(names_community, "occupiedunits")
  expected <- list(
    names_d_language_avg = paste0("avg.", names_d_language),
    names_d_language_state_avg = paste0("state.avg.", names_d_language),
    names_d_language_pctile = paste0("pctile.", names_d_language),
    names_d_language_state_pctile = paste0("state.pctile.", names_d_language),
    names_d_languageli_avg = paste0("avg.", names_d_languageli),
    names_d_languageli_state_avg = paste0("state.avg.", names_d_languageli),
    names_d_languageli_pctile = paste0("pctile.", names_d_languageli),
    names_d_languageli_state_pctile = paste0("state.pctile.", names_d_languageli),
    names_age_avg = paste0("avg.", names_age),
    names_age_state_avg = paste0("state.avg.", names_age),
    names_age_pctile = paste0("pctile.", names_age),
    names_age_state_pctile = paste0("state.pctile.", names_age),
    names_d_extra_avg = paste0("avg.", names_d_extra),
    names_d_extra_state_avg = paste0("state.avg.", names_d_extra),
    names_d_extra_pctile = paste0("pctile.", names_d_extra),
    names_d_extra_state_pctile = paste0("state.pctile.", names_d_extra),
    names_community_avg = paste0("avg.", community_vars),
    names_community_state_avg = paste0("state.avg.", community_vars),
    names_community_pctile = paste0("pctile.", community_vars),
    names_community_state_pctile = paste0("state.pctile.", community_vars)
  )

  for (varlist in names(expected)) {
    rows <- map_headernames[map_headernames$varlist == varlist, , drop = FALSE]
    expect_true(
      setequal(rows$rname, expected[[varlist]]),
      label = paste0("rows for ", varlist, " match expected rnames")
    )
  }

  expect_false("avg.occupiedunits" %in% map_headernames$rname)
  expect_false("pctile.occupiedunits" %in% map_headernames$rname)
})

test_that("generated names_* objects match the new map_headernames varlists", {
  expected_objects <- c(
    "names_health_ratio_to_avg",
    "names_health_ratio_to_state_avg",
    "names_climate_ratio_to_avg",
    "names_climate_ratio_to_state_avg",
    "names_criticalservice_ratio_to_avg",
    "names_criticalservice_ratio_to_state_avg",
    "names_d_language_avg",
    "names_d_language_state_avg",
    "names_d_language_pctile",
    "names_d_language_state_pctile",
    "names_d_language_ratio_to_avg",
    "names_d_language_ratio_to_state_avg",
    "names_d_languageli_avg",
    "names_d_languageli_state_avg",
    "names_d_languageli_pctile",
    "names_d_languageli_state_pctile",
    "names_d_languageli_ratio_to_avg",
    "names_d_languageli_ratio_to_state_avg",
    "names_age_avg",
    "names_age_state_avg",
    "names_age_pctile",
    "names_age_state_pctile",
    "names_age_ratio_to_avg",
    "names_age_ratio_to_state_avg",
    "names_d_extra_avg",
    "names_d_extra_state_avg",
    "names_d_extra_pctile",
    "names_d_extra_state_pctile",
    "names_d_extra_ratio_to_avg",
    "names_d_extra_ratio_to_state_avg",
    "names_community_avg",
    "names_community_state_avg",
    "names_community_pctile",
    "names_community_state_pctile",
    "names_community_ratio_to_avg",
    "names_community_ratio_to_state_avg"
  )

  for (object_name in expected_objects) {
    object_exists <- exists(object_name, inherits = TRUE)
    expect_true(object_exists, label = paste0(object_name, " exists"))
    if (object_exists) {
      expect_identical(get(object_name), varlist2names(object_name))
    }
  }
})

test_that("doaggregate output includes representative report ratio columns", {
  results_bysite <- as.data.frame(testoutput_doaggregate_10pts_1miles$results_bysite)
  expected_columns <- c(
    "ratio.to.avg.pctspanish_li",
    "ratio.to.state.avg.pctspanish_li",
    "ratio.to.avg.pctlan_spanish",
    "ratio.to.state.avg.pctlan_spanish",
    "ratio.to.avg.pctunder18",
    "ratio.to.state.avg.pctunder18",
    "ratio.to.avg.pctpoor",
    "ratio.to.state.avg.pctpoor",
    "ratio.to.avg.pctnobroadband",
    "ratio.to.state.avg.pctnobroadband",
    "ratio.to.avg.rateheartdisease",
    "ratio.to.state.avg.rateheartdisease",
    "ratio.to.avg.pctfire30",
    "ratio.to.state.avg.pctfire30",
    "ratio.to.avg.pctownedunits",
    "ratio.to.state.avg.pctownedunits"
  )

  expect_true(all(expected_columns %in% names(results_bysite)))
  expect_true(all(colSums(!is.na(results_bysite[expected_columns])) > 0))
})
