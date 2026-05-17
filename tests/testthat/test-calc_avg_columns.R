# calc_avg_columns

########## ########### ########### ########### ########### ########### #

###  CONSIDER ADJUSTING BEHAVIOR IN THESE CASES:

## no error but missing row -- invalid zone
# calc_avg_columns("pm", zones = c("NY", "YXZ", "RI"))

## no error but unexpected output  - NA zone
# calc_avg_columns("pm", zones = c("NY", "CA", NA))

## error:  invalid variable name
# calc_avg_columns(c("pm", "xxxxx", "pctlowinc"), zones = c("NY",  "CA"))

## error:  NA variable name
# calc_avg_columns(c("pm", NA), zones = c("NY",  "CA"))

########## ########### ########### ########### ########### ########### #

test_that("calc_avg_columns 1 var, USA", {
  expect_no_error({
    vars = names_e
    expect_equal(

      as.numeric(round(EJAM:::calc_avg_columns(vars[1]), 3)), # 1 var, USA
      as.numeric(round(usastats[usastats$PCTILE == "mean" & usastats$REGION == "USA", vars[1]], 3))

    )
  })
})
########## #

test_that("calc_avg_columns multivar, USA", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(EJAM:::calc_avg_columns(vars)  ),3),  # multivar, USA
      round(as.numeric(usastats[usastats$PCTILE=='mean', vars]),3)
    )
  })
})
########## #
test_that("calc_avg_columns multivar, 1 zone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(EJAM:::calc_avg_columns(vars, zone = "TX") ), 3),              # multivar, 1 zone
      round(as.numeric(statestats[statestats$PCTILE=='mean' & statestats$REGION == "TX", vars]), 3)
    )
  })
})
########## #
test_that("calc_avg_columns 1 var,    1 zone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(EJAM:::calc_avg_columns(vars[1], zone = "TX") ), 3),                # 1 var,    1 zone
      round(as.numeric(statestats[statestats$PCTILE=='mean' & statestats$REGION == "TX", vars[1]]), 3)
    )
  })
})
########## #
test_that("calc_avg_columns  # 1 var,    multizone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      # calc_avg_columns(vars[1], zone = c("TX", "TX", "GA")) # 1 var,    multizone
      as.vector(unlist((round((EJAM:::calc_avg_columns(vars[1], zone = c("TX", "TX", "GA")) ), 3)))),       # 1 var,    multizone
      round(c(
        statestats[statestats$PCTILE=='mean' &  "TX"== statestats$REGION  , vars[1]]  ,
        statestats[statestats$PCTILE=='mean' &  "TX"== statestats$REGION  , vars[1]]  ,
        statestats[statestats$PCTILE=='mean' &  "GA"== statestats$REGION  , vars[1]]
      ), 3)
    )
  })
})
########## #
test_that("calc_avg_columns multivar, multizone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      EJAM:::calc_avg_columns(vars,    zone = c("TX", "TX", "GA")), # multivar, multizone

      rbind(
        EJAM:::calc_avg_columns(vars,    zone = "TX"),
        EJAM:::calc_avg_columns(vars,    zone = "TX"),
        EJAM:::calc_avg_columns(vars,    zone = "GA")
      )
    )
  })
})
########## # ########## # ########## # ########## # ########## #
test_that("error", {
  expect_error(
    EJAM:::calc_avg_columns("invalid")
  )
})
########## # ########## # ########## # ########## # ########## #
test_that("custom vars ok", {

  customstats = data.frame(PCTILE = "mean",
                           REGION        = c("USA", "GA", "TX"),
                           pctlefthanded = c(0.20, 0.30, 0.10),
                           airqualityscore = c(58.3, 71, 48)
  )
  custom_vars = setdiff(names(customstats), c("PCTILE", "REGION"))
  expect_no_error({


  EJAM:::calc_avg_columns(custom_vars[1], lookup = customstats) # 1 var, USA
  x = EJAM:::calc_avg_columns(custom_vars,    lookup = customstats)   # multivar, USA
  expect_equal(names(x),
               c("avg.pctlefthanded" ,  "avg.airqualityscore"))

  EJAM:::calc_avg_columns(custom_vars,    zone = "TX",                lookup = customstats) # multivar, 1 zone
  EJAM:::calc_avg_columns(custom_vars[1], zone = "TX",                lookup = customstats) # 1 var,    1 zone
  EJAM:::calc_avg_columns(custom_vars[1], zone = c("TX", "TX", "GA"), lookup = customstats) # 1 var,    multizone
  x = EJAM:::calc_avg_columns(custom_vars,    zone = c("TX", "TX", "GA"), lookup = customstats) # multivar, multizone

  expect_equal(names(x),
               c("state.avg.pctlefthanded" ,  "state.avg.airqualityscore"))
  })

})
########## # ########## # ########## # ########## # ########## #



# # examples of getting pctiles, averages, and ratios to averages
# # via functions that do parts of what is done in doaggregate()

#    see examples for ?calc_pctile_columns()
