
# results_summarized$cols ####

testthat::test_that("batch.summarize cols (count at 80th+)", {
  
  # check batch.summarize output cols
  # for each site, it only has max index at site and count at 90+ at site:
  
  # make test data
  # ensures latest version of output is used but slower for testing:
  out <- ejamit(testpoints_100, radius = 1) 
  # out <- testoutput_ejamit_100pts_1miles # 
  
  
  # NOTE default settings for threshnames do not make sense
  expect_no_error({
    
    x80 <- batch.summarize(sitestats = out$results_bysite, 
                           popstats  = out$results_bybg_people, 
                           overall   = out$results_overall,
                           
                           threshnames = list(some = names_ej_pctile),
                           thresholds = list(80)
    )
    
    x90 <- batch.summarize(sitestats = out$results_bysite, 
                           popstats  = out$results_bybg_people, 
                           overall   = out$results_overall,
                           threshnames = list(some = names_ej_pctile),
                           thresholds = list(90)
    )
    
  })  
  
  # x80$cols[1:n, ]
  #   Max.of.variables Number.of.variables.at.above.threshold.of.80
  # 1               92                                            6
  # 2               98                                           12
  # 3               83                                            1
  # 4               71                                            0
  
  n <- 100
  
  # reformat results just to look at count of indicators at/above 80th pctile
  
  xx80 <- as.data.frame(
    t(data.frame(x80$cols, 
                 out$results_bysite[, ..names_ej_pctile])[1:n, ])
  )
  xx80 <- as.vector(unlist(xx80[2, ]))
  
  xx90 <- as.data.frame(t(data.frame(x90$cols, 
                                     out$results_bysite[, ..names_ej_pctile])[1:n, ])
  )
  xx90 <- as.vector(unlist(xx90[2, ]))
  
  ### Use apply(sum(x>=80)) to INDEPENDENTLY COUNT #indexes >=80TH PCTILE, at each site
  
  ox <- t(out$results_bysite[1:n, ..names_ej_pctile])
  
  ox80 <- as.vector(apply(ox, 2, function(x) sum(x >= 80, na.rm = TRUE)))
  ox90 <- as.vector(apply(ox, 2, function(x) sum(x >= 90, na.rm = TRUE)))
  
  # compare results from batch.summarize() vs counting via apply(sum())
  
  expect_equal(xx80, ox80)
  expect_equal(xx90, ox90)
  
})
######################################## #

# results_summarized$cols ####

test_that("batch.summarize rows Average Person ok", {
  
  # x <- testoutput_ejamit_1000pts_1miles
  x <- ejamit(testpoints_1000, radius = 1) # about 15 seconds to ensure have latest results
  suppressWarnings({
    t1 <- as.numeric(as.vector(unlist(
      
      x$results_overall
      
    )))
    t2 <- as.numeric(as.vector(unlist(
      
      x$results_summarized$rows["Average person", ]
      
    )))
  })
  # not all.equal() due to rounding, NA, TRUE, "", etc.
  ratio <- round(t1 / t2, 4)
  both_zero <- t1 == 0 & t2 == 0
  expect_true(
    all(ratio %in% c(1, NA) | both_zero)
  )
})




# needs more tests here... tests for $rows 






######################################## #

# $flagged_areas ####

test_that("batch.summarize()$flagged_areas has 13 rows and expected columns incl. state versions", {

  junk <- capture.output({
    suppressWarnings({
      x <- batch.summarize(
        sitestats = data.table::copy(testoutput_ejamit_10pts_1miles$results_bysite),
        popstats  = data.table::copy(testoutput_ejamit_10pts_1miles$results_bybg_people),
        overall   = data.table::copy(testoutput_ejamit_10pts_1miles$results_overall),
        quiet = TRUE
      )
    })
  })
  fa <- x$flagged_areas
  expect_true(is.data.frame(fa))
  expect_equal(NROW(fa), 13)
  expect_equal(
    names(fa),
    c("Indicator", "Percent_of_these_Sites", "Percent_of_these_People",
      "Percent_of_all_People_Nationwide", "ratio",
      "Percent_of_all_People_Statewide", "ratio_to_state_avg", "rname")
  )
  # percentages are in 0-100, and the ratios are consistent with their components
  pctcols <- c("Percent_of_these_Sites", "Percent_of_these_People",
               "Percent_of_all_People_Nationwide", "Percent_of_all_People_Statewide")
  for (pc in pctcols) {
    expect_true(all(fa[[pc]] >= 0 & fa[[pc]] <= 100, na.rm = TRUE), info = pc)
  }
  # ratio_to_state_avg is computed from the UNROUNDED statewide baseline (so tiny
  # baselines like VA yesno_tribal 0.017% do not collapse to 0 and NA out the ratio),
  # while Percent_of_all_People_Statewide is displayed rounded to 1 decimal place -
  # so recomputing from the displayed columns only matches approximately, and only
  # where the displayed baseline is not too close to 0
  ok <- is.finite(fa$ratio_to_state_avg) & fa$Percent_of_all_People_Statewide >= 0.5
  expect_true(any(ok))
  expect_equal(
    fa$ratio_to_state_avg[ok],
    fa$Percent_of_these_People[ok] / fa$Percent_of_all_People_Statewide[ok],
    tolerance = 0.05
  )
  okus <- is.finite(fa$ratio)
  expect_equal(
    fa$ratio[okus],
    round(fa$Percent_of_these_People[okus] / fa$Percent_of_all_People_Nationwide[okus], 2)
  )
})
######################################## #







