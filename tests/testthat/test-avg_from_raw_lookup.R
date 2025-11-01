# avg_from_raw_lookup

########## ########### ########### ########### ########### ########### #

###  CONSIDER ADJUSTING BEHAVIOR IN THESE CASES:

## no error but missing row -- invalid zone
# avg_from_raw_lookup("pm", zones = c("NY", "YXZ", "RI"))

## no error but unexpected output  - NA zone
# avg_from_raw_lookup("pm", zones = c("NY", "CA", NA))

## error:  invalid variable name
# avg_from_raw_lookup(c("pm", "xxxxx", "pctlowinc"), zones = c("NY",  "CA"))

## error:  NA variable name
# avg_from_raw_lookup(c("pm", NA), zones = c("NY",  "CA"))

########## ########### ########### ########### ########### ########### #

test_that("avg_from_raw_lookup 1 var, USA", {
  expect_no_error({
    vars = names_e
    expect_equal(

      as.numeric(round(avg_from_raw_lookup(vars[1]), 3)), # 1 var, USA
      as.numeric(round(usastats_means("pm"),3))

    )
  })
})
########## #

test_that("avg_from_raw_lookup multivar, USA", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(avg_from_raw_lookup(vars)  ),3),  # multivar, USA
      round(as.numeric(usastats[usastats$PCTILE=='mean', vars]),3)
    )
  })
})
########## #
test_that("avg_from_raw_lookup multivar, 1 zone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(avg_from_raw_lookup(vars, zone = "TX") ), 3),              # multivar, 1 zone
      round(as.numeric(statestats[statestats$PCTILE=='mean' & statestats$REGION == "TX", vars]), 3)
    )
  })
})
########## #
test_that("avg_from_raw_lookup 1 var,    1 zone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      round(as.numeric(avg_from_raw_lookup(vars[1], zone = "TX") ), 3),                # 1 var,    1 zone
      round(as.numeric(statestats[statestats$PCTILE=='mean' & statestats$REGION == "TX", vars[1]]), 3)
    )
  })
})
########## #
test_that("avg_from_raw_lookup  # 1 var,    multizone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      # avg_from_raw_lookup(vars[1], zone = c("TX", "TX", "GA")) # 1 var,    multizone
      as.vector(unlist((round((avg_from_raw_lookup(vars[1], zone = c("TX", "TX", "GA")) ), 3)))),       # 1 var,    multizone
      round(c(
        statestats[statestats$PCTILE=='mean' &  "TX"== statestats$REGION  , vars[1]]  ,
        statestats[statestats$PCTILE=='mean' &  "TX"== statestats$REGION  , vars[1]]  ,
        statestats[statestats$PCTILE=='mean' &  "GA"== statestats$REGION  , vars[1]]
      ), 3)
    )
  })
})
########## #
test_that("avg_from_raw_lookup multivar, multizone", {
  expect_no_error({
    vars = names_e
    expect_equal(
      avg_from_raw_lookup(vars,    zone = c("TX", "TX", "GA")), # multivar, multizone

      rbind(
        avg_from_raw_lookup(vars,    zone = "TX"),
        avg_from_raw_lookup(vars,    zone = "TX"),
        avg_from_raw_lookup(vars,    zone = "GA")
      )
    )
  })
})
########## # ########## # ########## # ########## # ########## #
test_that("error", {
  expect_error(
    avg_from_raw_lookup("invalid")
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


  avg_from_raw_lookup(custom_vars[1], lookup = customstats) # 1 var, USA
  x = avg_from_raw_lookup(custom_vars,    lookup = customstats)   # multivar, USA
  expect_equal(names(x),
               c("avg.pctlefthanded" ,  "avg.airqualityscore"))

  avg_from_raw_lookup(custom_vars,    zone = "TX",                lookup = customstats) # multivar, 1 zone
  avg_from_raw_lookup(custom_vars[1], zone = "TX",                lookup = customstats) # 1 var,    1 zone
  avg_from_raw_lookup(custom_vars[1], zone = c("TX", "TX", "GA"), lookup = customstats) # 1 var,    multizone
  x = avg_from_raw_lookup(custom_vars,    zone = c("TX", "TX", "GA"), lookup = customstats) # multivar, multizone

  expect_equal(names(x),
               c("state.avg.pctlefthanded" ,  "state.avg.airqualityscore"))
  })

})
########## # ########## # ########## # ########## # ########## #



# # examples of getting pctiles, averages, and ratios to averages
# # via functions that do parts of what is done in doaggregate()

#    see examples for ?pctile_cols_from_raw_lookup()
