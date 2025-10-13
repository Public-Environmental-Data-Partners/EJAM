
test_ejam_1group <- function(fnames,
                             groupname = "",
                             reporter = "minimal", # some of the code below now only works if using this setting
                             load_helpers = TRUE,
                             print4eachfile = FALSE, # useless - keep it FALSE
                             print4group = TRUE,
                             add_seconds_bygroup = TRUE,
                             stop_on_failure = FALSE, timebyfile = NULL, timebygroup = NULL,
                             truncate_test_name_nchar = 60
) {
  xtable <- list()
  for (i in 1:length(fnames)) {
    seconds_byfile <- 0
    seconds_byfile = system.time({
      cat(paste0("#", i, ' '))
      suppressWarnings(suppressMessages({
        junk <- testthat::capture_output_lines({
          x <- try(

            testthat::test_file(
              file.path("./tests/testthat/", fnames[i]),
              load_helpers = load_helpers,
              load_package = 'none',
              # or else  Helper, setup, and teardown files located in the same directory as the test will also be run. See vignette("special-files") for details.
              reporter = reporter,
              stop_on_failure = stop_on_failure
            )

          )
          if (inherits(x, "try-error")) {cat("Stopped on failure in ", fnames[i], "\n")}
        }
        , print = print4eachfile) # here it is a useless param of capture_output_lines()
      }))
      x <- as.data.frame(x)
      if (NROW(x) == 0) {        # at one point it was having trouble around here
        cat("\n\n ********** FAILED TO GET ANY RESULTS TRYING TO RUN TESTS IN", file.path("./tests/testthat/", fnames[i]), '\n\n')
        xtable[[i]] <- NULL
        next
      }
      x$tests <- x$nb
      x$nb <- NULL
      x$flag <- x$tests - x$passed
      x$err  <- x$tests - x$passed - x$warning
      x$error_cant_test <- ifelse(x$error > 0, 1, 0)  ## a problem with counting this?
      x$error <- NULL
      x$skipped <- ifelse(x$skipped, 1, 0)
      x$err = NULL
      x$untested_skipped <- x$skipped; x$skipped = NULL
      x$untested_cant <- x$error_cant_test;  x$error_cant_test = NULL
      x$tested = x$tests - x$untested_skipped; x$tests = NULL
      x$total = x$untested_skipped + x$untested_cant + x$tested
      x$warned = x$warning; x$warning = NULL
      x$failed = x$tested - x$passed - x$warned
      x$flagged = x$untested_skipped + x$untested_cant + x$warned + x$failed; x$flag = NULL
      if (sum(x$total) != sum(x$passed + x$flagged)) {stop('math error in counts!')}
      x <- x[, c(
        'file',  'test',
        'total', 'passed', 'flagged', 'untested_cant', 'untested_skipped', 'warned', 'failed'
      )]
      x$test <- substr(x$test, 1, truncate_test_name_nchar) # some are long
      xtable[[i]] <- data.table::data.table(x)
    })
    xtable[[i]]$seconds_byfile <- seconds_byfile['elapsed']
    if (!is.null(timebyfile)) {
    # xtable[[i]]$seconds_byfile_predicted <-  timebyfile[file %in% fnames[i], seconds_byfile ] # fails if duplicate test names?
    xtable[[i]]$seconds_byfile_predicted <- timebyfile$seconds_byfile[match(xtable[[i]]$file,timebyfile$file)]
    } else {
      xtable[[i]]$seconds_byfile_predicted <-  NA
    }
  }
  xtable <- data.table::rbindlist(xtable)
  if (!is.null(timebygroup)) {
  seconds_bygroup_predicted <- timebygroup[testgroup %in% groupname, seconds_bygroup[1]]
  } else {
    seconds_bygroup_predicted <- NA
  }
  seconds_bygroup <- round(sum(xtable[ , seconds_byfile[1], by = 'file'][,V1]), 0)
  ## can add this shorter time estimate to the results instead of relying on
  ## the slightly longer time estimate that can be done in test_ejam_bygroup()
  if (add_seconds_bygroup) {
    xtable[ , seconds_bygroup := seconds_bygroup]
    xtable[ , seconds_bygroup_predicted := seconds_bygroup_predicted]
  }
  cat('done. '); cat(' Finished test group', groupname, 'in', seconds_bygroup, 'seconds.\n')
  cat(' Had predicted it would take', seconds_bygroup_predicted, 'seconds.\n')
  if (print4group) {
    print(c(
      colSums(xtable[, .(
        total, passed, flagged, untested_cant, untested_skipped, warned, failed)]),
      seconds_bygroup_actual = seconds_bygroup,
      seconds_bygroup_predicted = seconds_bygroup_predicted
    ))
  }
  return(xtable)
}
########################################################################################################################################### #
test_ejam_bygroup <- function(testlist,
                              print4group = FALSE,
                              testing = FALSE,
                              stop_on_failure = FALSE,
                              reporter = "minimal", # this may be the only option that works now
                              timebyfile = NULL, timebygroup = NULL
) {
  # probably cannot now, but used to be able to use  reporter=default_compact_reporter()
  try({suppressWarnings(suppressMessages({beepr_available <- require(beepr)}))}, silent = TRUE)
  xtable <- list()
  i <- 0
  for (tgroupname in names(testlist)) {
    seconds_bygroup_viasystemtime = system.time({
      i <- i + 1
      if (i == 1) {load_helpers <- TRUE} else {load_helpers <- FALSE}
      fnames = unlist(testlist[[tgroupname]])
      cat("", tgroupname, "group has", length(fnames), "test files. Starting ")

      xtable[[i]] <- data.table::data.table(

        testgroup = tgroupname,

        test_ejam_1group(testlist[[tgroupname]],
                         groupname = tgroupname,
                         load_helpers = load_helpers,
                         print4group = print4group,
                         stop_on_failure = stop_on_failure,
                         add_seconds_bygroup = TRUE, #   can be done here by test_ejam_bygroup() not by test_ejam_1group()
                         reporter = reporter,
                         timebyfile=timebyfile, timebygroup=timebygroup)
      )
    })
    ## time elapsed - This is the total time including overhead of looping, using test_ejam_1group() for each group, and compiling.
    secs1 <- round(seconds_bygroup_viasystemtime['elapsed'], 0)
    if (testing) {
      cat('Seconds elapsed based on test_ejam_bygroup() using system.time() is', secs1, '\n')
      # other ways fail if no test happened in a file like for group golem:
      ## This is a slightly shorter timing estimate could be done in test_ejam_1group() by using add_seconds_bygroup=T
      secs2 <- round(xtable[[i]]$seconds_bygroup[1], 0)
      cat('Seconds elapsed based on test_ejam_bygroup() reporting total reported by test_ejam_1group() is', secs2, '\n')
      ## or, a similar estimate could be done here, but just like it would be in test_ejam_1group() :
      secs3 <- round(sum(xtable[[i]][ , seconds_byfile[1], by = 'file'][,V1]), 0)
      cat('Seconds elapsed based on test_ejam_bygroup() summing seconds_byfile once per file is', secs3, '\n')
    }
    secs <- secs1
    xtable[[i]]$seconds_bygroup <- secs # replaces any estimate done by test_ejam_1group()

    ## Show table of counts for this group of files of tests:
    print(c(
      colSums(xtable[[i]][, .(
        total, passed, flagged, untested_cant, untested_skipped, warned, failed)]),
      seconds_actual = secs,
      seconds_predicted = xtable[[i]]$seconds_bygroup_predicted[1]
    ))
    if (sum(xtable[[i]]$flagged) > 0) {
      # using beepr::beep() since utils::alarm() may not work
      # using :: might create a dependency but prefer that pkg be only in Suggests in DESCRIPTION
      if (interactive() && beepr_available) {beepr::beep(10)}
      if (sum(xtable[[i]]$failed) > 0) {
        cat(paste0("     ***      Some FAILED in ", tgroupname, ": ",
                   paste0(unique(xtable[[i]]$file[xtable[[i]]$failed > 0]), collapse = ","), "\n"))
        cat(paste0("tests failed: ",
                   paste0(unique(xtable[[i]]$test[xtable[[i]]$failed > 0]), collapse = ","), "\n"))
      } else {
        cat(paste0("     ***      Some UNTESTED or WARNED in ", tgroupname, ": ",
                   paste0(unique(xtable[[i]]$file[xtable[[i]]$flagged > 0]), collapse = ","), "\n"))
      }
    }
  } # looped over groups of test files

  xtable <- data.table::rbindlist(xtable)
  time_minutes <-   round(sum(xtable[ , (seconds_bygroup[1]) / 60, by = "testgroup"][, V1]) , 1)
  cat(paste0('\n', time_minutes[1], ' minutes total for all groups\n\n'))
  xtable[ , flagged_byfile := sum(flagged), by = "file"]
  xtable[ , failed_byfile  := sum(failed),  by = "file"]
  xtable[ , flagged_bygroup := sum(flagged), by = "testgroup"]
  xtable[ , failed_bygroup  := sum(failed),  by = "testgroup"]
  setorder(xtable, -failed_bygroup, -flagged_bygroup, testgroup, -failed, -flagged, file)
  setcolorder(xtable, neworder = c('seconds_bygroup', 'seconds_byfile'), after = NCOL(xtable))
  return(xtable)
}
