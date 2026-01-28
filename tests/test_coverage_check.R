
# Notes on test coverage ####

# see  also, test_coverage() which computes test coverage for your package. It's a shortcut for covr::package_coverage() plus covr::report().
# see  https://covr.r-lib.org/

# see  RStudio addin that does  covr::report()   ?covr::package_coverage()

################################ ################################# #

# this is a DRAFT / NOT IDEAL function to get a very basic check on
# which functions seem to clearly have unit test files already
# It could be replaced with something simpler and clearer.


## example of some of its output:

# Number of exported functions from the package (note the # might be higher if you have used load_all()...):  598
# Number of exported functions with exactly matching test file names:  57
# Number of exported functions with no matching test file names:  541
# or  129 where the function does not even appear at all in full text of any test file:
#
#
# newer
# These dont seem to have tests but are
# used (or mentioned) by the most R/*.R files
# (excluding commented-out lines):
#
#   Need to add unit tests for ejam2report, ejam2excel, plot_barplot_ratios, table_signif_round_x100, popup_from_ejscreen, popup_from_df, mapfast, sitepoints_from_any
#
# term nfiles nhits
#
# 18                  ejam2report      6    15  ***  ***  SUMMARY REPORT - needs unit tests ideally (the ejam2map and maybe barplot? parts are tested) (compares to prior? but does not test header, logo, footer, table contents, map, plot)
#
# ####   and maybe    ejam2excel is important  ***  ***   EXCEL (now has some tests) (Tables headers aligned, working URL links, right tabs, sorting of cols?, nrow/ncol?, etc.)
#
#   2                   table_round     14    22  ***  *** TABLE ROUNDING needs unit tests ideally
#   14                 table_signif      7    10  ***  *** same
#   20      table_signif_round_x100      6     8  ***  *** same
#   7           table_rounding_info      9    15  ***  *** same
#
#   13          popup_from_ejscreen      7   9  ***  *** POPUPS- it is tested actually, in test-MAP_FUNCTIONS.R
# 19                popup_from_df      6    13  ***  ***       - it is tested actually, in test-MAP_FUNCTIONS.R
#   3                       mapfast     10    20  *** *** MAPS - it is tested actually, in test-MAP_FUNCTIONS.R
#
# 6           sitepoints_from_any      9    13  *** SITEPOINTS INPUT needs unit tests ideally

# 10               read_csv_or_xl      8    16
# 1               global_or_param     16   196
# 4                       varinfo      9    16

# 5                    app_server      9    17 - app functionality tests should handle this
# 8                        app_ui      8    16 - app functionality tests should handle this
# 11                  indexblocks      7    13
# 12             fixnames_aliases      7    12
# 16              create_filename      6    10
# 17 distance_via_surfacedistance      6    11

#   and maybe calc_ejam ?

################################ ################################# #

test_coverage_check <- function(loadagain = FALSE, quiet = TRUE) {

  # the quiet param here is only used by pkg_functions_and_sourcefiles() here

  # MUST BE IN ROOT OF A PACKAGE WHOSE NAME MATCHES THE DIR so that pkg_functions_and_data(basename(getwd())) will work

  # remove dependency on fs pkg, and  dplyr, tibble, stringr pkgs are already in Imports of DESCRIPTION file.

  cat("Looking in the source package EJAM/R/ folder for files like xyz.R, and in the EJAM/tests/testthat/ folder for test files like test-xyz.R \n")
  if (!loadagain) {cat("If you have not just done load_all() then loadaagain=TRUE is probably needed in test_coverage_check() !\n")}
  tdat = dplyr::bind_rows(
    tibble::tibble(
      type = "R",
      path = file.path("R", list.files("R/", pattern = "\\.[Rr]$")),
      name = as.character(tools::file_path_sans_ext(basename(path)))
    ),
    tibble::tibble(
      type = "test",
      path = file.path("tests/testthat", list.files("tests/testthat/", pattern = "^test[^/]+\\.[Rr]$")),
      name = as.character(tools::file_path_sans_ext(stringr::str_remove(basename(path), "^test[-_]")))
    )
  ) |>
    tidyr::pivot_wider(names_from = type, values_from = path)
  tdat <- tdat[order(tdat$name), ]

  names(tdat) <- gsub("name",   "object", names(tdat))
  names(tdat) <- gsub("R",    "codefile", names(tdat))
  names(tdat) <- gsub("test", "testfile", names(tdat))

  tdat$object <- gsub("^[^a-zA-Z_]+", "", tdat$object) # remove leading non-alphabetic characters ?

  cat("Checking all exported functions, not internal ones, BUT, if you just did load_all() then this will check ALL\n")
  capture.output({
    suppressWarnings({
      y <- EJAM:::pkg_functions_and_data(basename(getwd()), data_included = F, exportedfuncs_included = T, internal_included = TRUE)
    })
  })
  tdat$object_is_in_pkg <- tdat$object %in% y$object
  tdat$utils_object_is_in_pkg <- gsub("^utils_", "", tdat$object) %in% y$object

  tdat <- tdat[order(tdat$object_is_in_pkg, tdat$object), ]

  tdat$object[!tdat$object_is_in_pkg & !tdat$utils_object_is_in_pkg] <- NA
  tdat$object[!tdat$object_is_in_pkg & tdat$utils_object_is_in_pkg] <- gsub("^utils_", "", tdat$object[!tdat$object_is_in_pkg & tdat$utils_object_is_in_pkg])


  tdat$notes <- ""
  tdat$notes[!is.na(tdat$testfile) & !is.na(tdat$codefile)] <- "ok? exact match of 'R/x.R' and 'tests/testthat/test-x.R'"
  tdat$notes[!is.na(tdat$testfile) & !is.na(tdat$codefile)  & tdat$object_is_in_pkg]       <- "ok, object has a test file, exact match"
  tdat$notes[!is.na(tdat$testfile) & !is.na(tdat$codefile)  &!tdat$object_is_in_pkg & tdat$utils_object_is_in_pkg] <- "ok, object has a test file, though .R file and test file have 'utils_' prefix"
  tdat$notes[!is.na(tdat$testfile) & is.na(tdat$codefile) & tdat$object_is_in_pkg] <- "ok, object name and test file name match, though .R file name differs"
  tdat$notes[ is.na(tdat$testfile) & !is.na(tdat$codefile) & "data_" != substr(tdat$object, 1,5) & tdat$object_is_in_pkg]       <- "ok, object has a test file??"
  tdat$notes[ is.na(tdat$testfile) & !is.na(tdat$codefile) & "data_" != substr(tdat$object, 1,5) & tdat$utils_object_is_in_pkg] <- 'tbd' #
  tdat$notes[grepl("functionality.R$|ui_and_server.R$|test1.R$|test2.R$", tdat$testfile)] <- "ok, test file is for app functionality not a function"
  tdat$notes[!is.na(tdat$testfile) & is.na(tdat$codefile) & tdat$utils_object_is_in_pkg & grepl("test-utils_", tdat$testfile)] <- "ok, testfile prefixed with utils_ but otherwise matches object, though .R filename differs"
  justdata <- "R/data_" == substr(tdat$codefile, 1,7) & !is.na(tdat$codefile)
  tdat$notes[is.na(tdat$testfile) & !is.na(tdat$codefile) & !justdata  ] <- "cant find testfile of exact name,"
  tdat$notes[is.na(tdat$testfile) & !is.na(tdat$codefile) & !justdata & !tdat$utils_object_is_in_pkg ] <- "cant match this .R filename to a single (exported?) object or testfile - coverage unclear"

  funcs_not_in_txt_of_testfiles_at_all = NULL
  func2searchfor = tdat$object[!is.na(tdat$object) & tdat$notes == "cant find testfile of exact name,"]

  for (i in seq_along(func2searchfor)) {
    x = EJAM:::find_in_files(pattern = paste0(func2searchfor[i], ""), path = "./tests/testthat", ignorecomments = TRUE, quiet = T)
    if (length(x) > 0) {
      y = EJAM:::find_in_files(pattern = paste0("test_that.*", func2searchfor[i], ""), path = "./tests/testthat", ignorecomments = TRUE, quiet = T)
      if (length(y) > 0) {
        tdat$notes[tdat$object %in% func2searchfor[i]] <- paste0("OK? no fname match, but test_that found in ", length(y), " testfile(s)")
      } else {
      tdat$notes[tdat$object %in% func2searchfor[i]] <- paste0("no fname match, but name found in uncommented lines of ", length(x), " testfile(s)")
      }
    } else {
      funcs_not_in_txt_of_testfiles_at_all = c(funcs_not_in_txt_of_testfiles_at_all, func2searchfor[i])
      tdat$notes[tdat$object %in% func2searchfor[i]] <- paste0("NO TESTS - no fname match, and not in any uncommented lines of testfiles")
    }
  }
  ################################ #
  cat("\n\nCOVERAGE CHECK \n\n")
  # tdat %>%   print(n = Inf) # to see everything
  ################################ #

  cat(' -----------------------------------------------

      MATCHED EXACTLY -- all test files that exactly match name of a .R file: \n\n')

  tdat[!is.na(tdat$testfile) & !is.na(tdat$codefile), ] |> print(n = 500)
  #### *** or maybe
  # tdat[!is.na(tdat$testfile) & !is.na(tdat$codefile), c("R", "test")] |> print(n = 500)
  ################################ #
  cat(' -----------------------------------------------

  All test files that were not named based on a .R file,
     making it hard to know which .R files really lack tests
      but note some are actual objects in the package:\n\n')

  tdat[!is.na(tdat$testfile) & is.na(tdat$codefile),  ] |> print(n = 500)
  ################################ #
  cat(" -----------------------------------------------

      CHECK THESE
      - TESTS MISSING, like for dataload_dynamic() --  (note object_is_in_pkg column) -- or
      - SOME TEST FILES SPLIT OUT FROM MULTIFUNCTION code files, LIKE frs_from_xyz.R SPLIT INTO test-frs_from_naics.R ETC.  or
      - SOME TEST FILES GROUPED 2+ code files? (note object_is_in_pkg column)

      These are the .R files that lack a test file with exactly matching name:\n\n")

  justdata <- "R/data_" == substr(tdat$codefile, 1,7) & !is.na(tdat$codefile)
  x <- tdat[is.na(tdat$testfile) & !is.na(tdat$codefile) & !justdata, ]
  x[order(x$object), ] |> print(n = 500)

  cat('
      -----------------------------------------------\n\n')

  cat("   CERTAINLY NO TESTS \n\n")

  zz = x[order(x$object), ]
zz[substr(zz$notes,1,8) == "NO TESTS", c("object", "notes")] |> print(n = 500)

cat('
      -----------------------------------------------\n\n')


  ################################ #
  cat('
      -----------------------------------------------\n\n')

  junk = capture.output({
    suppressWarnings({
      y = EJAM:::pkg_functions_and_sourcefiles('EJAM', internal_included = TRUE, exportedfuncs_included = T, data_included = F, vectoronly = T,
                                               loadagain = loadagain, quiet = quiet)
    })})
  # print(setdiff(y, gsub("tests/testthat/test-|.R$", "", tdat$testfile)))
  cat('\n')
  cat("Number of exported functions from the package (note the # is much higher if you have used load_all()...): ",
      length(y), '\n'
  )
  cat("Number of exported functions with exactly matching test file names: ",
      length((intersect(y, gsub("tests/testthat/test-|.R$", "", tdat$testfile)))), '\n'
  )
  cat("Number of exported functions with no matching test file names: ",
      length((setdiff(y, gsub("tests/testthat/test-|.R$", "", tdat$testfile)))), '\n',
      "or ", length(funcs_not_in_txt_of_testfiles_at_all), "where the function does not even appear at all in full text of any test file:", '\n\n'
  )
  #  cat(paste0(funcs_not_in_txt_of_testfiles_at_all, collapse = ", "), "\n\n")
  (dput(sort(funcs_not_in_txt_of_testfiles_at_all)))
  cat("\n\n")
  junk = capture.output({
    freq = EJAM:::found_in_N_files_T_times(funcs_not_in_txt_of_testfiles_at_all, path = "./R", ignorecomments = TRUE)
  })
  freq = freq[order(freq$nfiles, decreasing = T), ]
  rownames(freq) <- NULL
  cat("

These dont appear in testfiles at all, but are
used (or mentioned) by the most R/*.R files
(excluding commented-out lines):

      ")

  print(head(as.data.frame(freq), 30))
  cat("\n\n")
  cat("Also see https://devtools.r-lib.org/reference/test.html and https://covr.r-lib.org/ and ?devtools::test_coverage() which computes test coverage for your package.\nIt's a shortcut for covr::package_coverage() plus covr::report().\n")

  invisible(tdat)
}


## to use this function:
#
#  tdat <-  test_coverage_check() # to get report and see key info
#  tdat %>%   print(n = Inf) # to see everything


## also see  https://devtools.r-lib.org/reference/test.html

# test_coverage() computes test coverage for your package. It's a shortcut for covr::package_coverage() plus covr::report().

# y = EJAM:::pkg_functions_and_data('EJAM')

## and

# x = EJAM:::linesofcode2(packages = 'EJAM')

