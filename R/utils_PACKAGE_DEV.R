
# Functions related to managing the EJAM package, names of its functions and datasets, etc.

################################ ################################# #
# . ####
# Notes on finding/counting global functions  ####
## different ways of finding pkg functions:
## 614-622 global functions found ####

# one way - using  getNamespace() within pkg_functions_and_data()
#
## 622 exported? or total global?
# y <- EJAM:::pkg_functions_and_data('EJAM', internal_included = F, data_included = F, alphasort_table = T, vectoronly = T)
# length(y)
##[1] 622
### yy <- pkg_functions_and_data(); table(yy[!yy$data,]$exported) # about 622 but maybe because after load_all()
### yy <- yy[!yy$data,]$object

# second way - by searching for text in source files:
#
### 249 exported + 365 global internal = 614 ####
## 614 global functions?
##
# find names of functions with @export or other tag

#  exported_functions <- pkg_functions_by_roxygen_tag()
#
## 252 functions with export tag per this approach  ***********
#
####################################################### #
## a newer function to compare to others
#
# x <- pkg_functions_preceding_lines()
# tail(x)
# colSums(x[,2:6])

# 562 functions found by this approach (seems to miss some)
# 104 functions lack documentation because have no roxygen tags
# 458 functions have roxygen tags per this approach
#  53 functions lack documentation because have a noRd tag
#    table(EXPORT = x$export, NORD= x$nord) # >50 say noRd (but just 1 is exported)
# 405 functions have roxygen tags and do create documentation as .Rd file
# 237 functions have export tag per this approach ***********
# 219 functions have keywords internal tag
# table(EXPORT = x$export, x$internal) # some are exported but "internal" in sense of not being listed in the index of functions

####################################################### #
##   look for those tagged as export, or keywords internal
#
# pkg_functions_export_tag <-
#  exported_functions <- pkg_functions_by_roxygen_tag()
#
# pkg_functions_internal_tag <-
#  keywords_internal  <- pkg_functions_by_roxygen_tag(tagpattern = "#' @keywords internal")
#
#   length(unique(union(exported_functions, keywords_internal)))
## [1] 440 functions have 1 or both of those tags
## 55 have both.
#     length(exported_functions)
## [1] 252
#  length(keywords_internal)
## [1] 243
#  length(
#    intersect(exported_functions, keywords_internal)
#   )
## [1] 55
#
## pkg_functions_found_in_files() ### #
#
################################ #
# others
#
# y = pkg_functions_and_data()
#
# z = pkg_functions_and_sourcefiles()
#
####################################################### #
# any_functions = pkg_functions_found_in_files()
# length(z)
# # [1] 614 total
#
# length(exported_functions)
## [1] 249  exported
#
# unexported_functions <- sort(unique(setdiff(any_functions, exported_functions)))
# length(unexported_functions)
## ## 365  unexported (of which 237 tagged as keywords internal)
##
# length(unique(union(c(exported_functions, keywords_internal), any_functions)))
# untagged = setdiff(any_functions, unique(union(exported_functions, keywords_internal)))
# length(untagged)
## [1] 184
# length(setdiff(c(exported_functions, keywords_internal), any_functions) )
## 0
# . ####
################################ ################################# #


# LISTING PKG  FUNCTIONS, DATA, SOURCEFILES, ETC. ####

##################################################################################### #
# . ####

## package version number ####

#' utility to get "Version" of package, from source or installed version
#'
#' @param local_source_only if FALSE (default), look at installed package.
#'  If TRUE, only check for DESCRIPTION file in working directory, and
#'  do not check for installed version (or version loaded by load_all() ).
#' @param package name of package to check, default is "EJAM"
#' @param short if TRUE, tries to return a shorter version of the info.
#' @examples x <- pkg_ver()
#' @returns desc as.character() of the specified field, or NULL if not found
#' @details
#' EJAM:::pkg_ver() is very similar to [golem::pkg_version()]
#'
#' By default (if local_source_only = FALSE) looks at installed version
#' but if load_all() was used (and local_source_only = FALSE), it looks at local source as loaded by load_all().
#'
#' @keywords internal
#' @noRd
#'
pkg_ver = function(short = FALSE, local_source_only = FALSE, package="EJAM") {

  pv = pkg_description(field = "Version", local_source_only = local_source_only, package = package)

  ## trim version number to Major.Minor ???
  if (short) {
    pv <- substr(pv, start = 1, stop = gregexpr('\\.', pv)[[1]][2] - 1)
  }

  return(pv)

  # Note
  ## There are many ways to check the version number of a package
  #
  ## Note the installed and source version numbers may differ during development.
  ## Also note using load_all() might change which versions some of these approaches report on.
  #
  ## The installed version   (or version loaded from local source by load_all() if that is done)
  #
  # as.character(desc::desc(package = "EJAM")$get("Version"))
  # as.character(utils::packageVersion("EJAM"))
  # as.character(EJAM:::description_file$get("Version")) # description_file is created by metadata_mapping.R
  # as.character(EJAM:::metadata_mapping$blockgroupstats[['ejam_package_version']])
  # as.character(EJAM:::global_or_param("app_version")) # only available after package is attached, and relies on EJAM:::description_file$get("Version")
  #
  # ## The local source version:   (these read the local source version number)
  # #
  # as.character(desc::desc(file = "DESCRIPTION")$get("Version"))
  # as.character(desc::desc_get("Version"))
  # golem::pkg_version()

}
# ######################################################## #

## package DESCRIPTION ####

#' utility to get DESCRIPTION file from source or installed version, or check a field like "Version"
#'
#' @param field  If field parameter is NULL, return description file as desc package object.
#' Assuming field is the name of a field in DESCRIPTION, such as "Version", return value of that field
#' but does not validate that field.
#'
#' @param local_source_only if FALSE (default), look at installed package.
#'  If TRUE, only check for DESCRIPTION file in working directory, and
#'  do not check for installed version (or version loaded by load_all() ).
#' @param package name of package to check, default is "EJAM"
#' @examples x <- pkg_description()
#' @returns desc package object that is from DESCRIPTION file,
#'   or just the specified field, or NULL if not found
#' @details
#' By default (if local_source_only = FALSE) looks at installed version
#' but if load_all() was used (and local_source_only = FALSE), it looks at local source as loaded by load_all().
#'
#' @keywords internal
#' @noRd
#'
pkg_description <- function(field = NULL, local_source_only = FALSE, package="EJAM") {

  if (local_source_only) {

    # 1) check in working directory for current local source version
    #  (not necessarily the same as the version installed, or the one loaded)

    desc <- try(desc::desc(file = "DESCRIPTION"), silent = TRUE)

    if (!inherits(desc, 'try-error')) {
      message("found local source version")
      if (is.null(field)) {
        return(desc)
      } else {
        out <- desc$get(field)
        out <- as.character(out)
        if (all(is.na(out))) {
          return(NULL)
        } else {
          return(out)
        }
      }
    } else {
      warning('cannot find DESCRIPTION file in working directory')
      return(NULL)
    }
  }

  # 2) if local DESCRIPTION not requested, this then checks for an INSTALLED version (or version loaded via load_all()  )

  desc <- try(desc::desc(package = package), silent = TRUE)

  if (!inherits(desc, 'try-error')) {
    # message("found installed version")
    if (is.null(field)) {
      return(desc)
    } else {
      out <- desc$get(field)
      out <- as.character(out)
      if (all(is.na(out))) {
        return(NULL)
      } else {
        return(out)
      }
    }
  }

  # 3) if still not found, maybe try another way to check for INSTALLED version (or version loaded via load_all() )

  desc <- try(desc::desc(file = system.file('DESCRIPTION', package = package)), silent = TRUE)

  if (!inherits(desc, 'try-error')) {
    # message("found installed version")
    if (is.null(field)) {
      return(desc)
    } else {
      out <- desc$get(field)
      out <- as.character(out)
      if (all(is.na(out))) {
        return(NULL)
      } else {
        return(out)
      }
    }
  }

  # 4) if still not found, give up

  if (inherits(desc, 'try-error')) {
    warning('cannot find DESCRIPTION file in working directory or in ', package, ' package')
    return(NULL)
  }

}
# ###################################################### #


# ###################################################### #
#   ##    To see if it is loaded:  getNamespaceInfo("EJAM", "path")
#   ##    To see if it is on the search() path, attached:  attr(as.environment("package:EJAM"), "path")
# ###################################################### #

##################################################################################### #

## package directory ####

pkg_dir_installed = function(pkg="EJAM") {find.package(pkg, lib.loc = .libPaths())}

pkg_dir_loaded_from = function(pkg="EJAM") {find.package(pkg, lib.loc = NULL)}

##################################################################################### #

## searching text in source files ####

#' utility - Helper for find_in_files()
#'
#' @details
#' Search an in-memory character vector line by line
#'
#'  This is somewhat like grepv() but with these options:
#'  option to return numbers of the elements or line numbers as names of the output vector
#'  option to ignore commented-out lines of code (if searching with in lines of code)
#'  option to return just the matching part of the element or line instead of the whole line if desired.
#'
#'  use grepl to find all members of character vector z where the character string "h" appears in the string
#'  but the string does not start with zero or more spaces followed by the character "#"
#'
#' @examples
#'
#' EJAM:::grep_lines("x",  c("x", "y", "has any x x xxxxx"))
#'
#' xx = c("   ej", "ej", "#ej", "   #ej", "asdf#ej", "   asdf#ej", "#   ej", "#   xej", "x#  ej", "  x#ej")
#'
#'  cbind(xx, EJAM:::grep_lines("ej", xx, ignorecomments = TRUE,  value = FALSE))
#'  cbind(xx, EJAM:::grep_lines("ej", xx, ignorecomments = FALSE, value = FALSE))
#'
#'  cbind(  EJAM:::grep_lines("ej", xx, ignorecomments = TRUE,    value = TRUE))
#'  cbind(  EJAM:::grep_lines("ej", xx, ignorecomments = FALSE,   value = TRUE))
#'
#' @inherit grepn seealso
#'
#' @keywords internal
#'
#' @description Internal helper used by [find_in_files()] to search text that is
#'   already in memory, such as the output of [readLines()].
#' @param pattern regular expression to look for
#' @param x character vector to search, typically one element per line
#' @param ignore.case logical passed to [grepl()]
#' @param ignorecomments if `TRUE`, lines beginning with `#` are excluded
#' @param value if `TRUE`, return matching lines; otherwise return a logical vector
#' @return Character vector of matching lines if `value = TRUE`, otherwise a
#'   logical vector the same length as `x`. Returned values are named with line
#'   numbers where applicable.
#' @seealso [find_in_files()] [grepn()] [grepns()] [grepls()]
#' @keywords internal
#'
grep_lines = function(pattern, x, ignore.case = TRUE, ignorecomments = FALSE, value = TRUE) {

  hit_line = grepl(pattern = pattern, x = x, ignore.case = ignore.case)
  commented_line = grepl("^\\s*#", x = x)
  if (ignorecomments) {
    hits  = hit_line & !commented_line
  } else {
    hits = hit_line
  }
  which_hit = which(hits)
  if (value) {
    out = x[hits]
  } else {
    out = hits # like grepl
  }
  names(out) <- which_hit # names(out) are the file's line numbers if looking in a file via find_in_files()
  return(out)
}
################################ #


#' Search across files for lines matching a regular expression
#'
#' @param pattern regular expression to look for
#' @param path can be e.g., "./R" or "./tests/testthat" or "."
#' @param recursive if TRUE, search includes subfolders (passed to `list.files()`)
#' @param filename_pattern default is R code files only! A regular expression that would limit file names to search
#' @param full.names if TRUE, returns paths not just filenames (passed to `list.files()`)
#' @param ignorecomments omit hits from commented out lines
#' @param ignore.case as in grep
#' @param whole_line set it to FALSE to see only the matching fragments
#'   vs entire line of text that has a match in it
#' @param quiet whether to print results or just invisibly return
#'
#' @seealso [grep_lines()] [grepn()] [grepns()] [grepls()] [found_in_files()]
#'   [found_in_N_files_T_times()]
#'
#' @examples
#' EJAM:::find_in_files("[^_]logo_....",    path = "./R", whole_line = FALSE)
#' EJAM:::find_in_files("report_logo.....", path = "./R", whole_line = FALSE)
#' EJAM:::find_in_files("app_logo......",   path = "./R", whole_line = FALSE)
#'
#' EJAM:::find_in_files("latlon_from_.{18}",    whole_line = FALSE)
#' EJAM:::find_in_files("latlon_from_s.{9}",    whole_line = FALSE)
#' EJAM:::find_in_files("latlon_from_mact.{9}", whole_line = FALSE)
#'
#' ## useful reminders of how to filter lines of code vs comments when using find_in_files()
#'
#' grepl_line_not_commented_out = "^[ ]*[^# ]+.*"  ## line starts with zero or more spaces followed by a non-space non-# character, so not commented out and not blank line, but may have a comment later in the line after code
#' grepl_line_commented_out     = "^[ |#]*#.*"     ## line starts with (zero or more spaces and then) a hash mark
#' grepl_line_may_have_comment  = "#.*"            ## line contains a hash mark somewhere, but that may be number sign within quoted text
#'  grepl(grepl_line_may_have_comment,  " print('The # of people is 4.')")  ## TRUE even though there is no comment here
#'  grepl(grepl_line_may_have_comment,  " # print('The number of people is 4.')") # a commented-out line
#'  grepl(grepl_line_may_have_comment,  "   print('The number of people is 4.')   # a comment only after the code")
#'
#' EJAM:::find_in_files(paste0(grepl_line_not_commented_out, "xxx"))
#' EJAM:::find_in_files(paste0(grepl_line_commented_out,     "xxx"))
#' EJAM:::find_in_files(paste0(grepl_line_may_have_comment,  "xxx"))
#'
#' @return a list of named vectors,
#'   where names are file paths with hits, elements are vectors of text with hits.
#'
#' @keywords internal
#'
find_in_files <- function(pattern,
                          path = ".", # "./tests/testthat",
                          recursive = TRUE,
                          filename_pattern = "\\.R$|\\.r$",
                          full.names = TRUE,
                          ignorecomments = FALSE,
                          ignore.case = TRUE,
                          whole_line = TRUE,
                          quiet = FALSE) {

  ## test cases for where just 1 file has hits or first file has just 1 hit, etc.
  #
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_', whole_line = T)
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_', whole_line = F)
  #
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_a', whole_line = T)
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_a', whole_line = F)
  #
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_m', whole_line = T)
  # find_in_files(pattern =  "#' @return" , path = './R', filename_pattern = 'frs_m', whole_line = F)

  if (FALSE) {
    # testing/checking

    grepl_line_not_commented_out = "^[ ]*[^# ]+.*"  ## line starts with zero or more spaces followed by a non-space non-# character, so not commented out and not blank line, but may have a comment later in the line after code
    grepl_line_commented_out     = "^[ |#]*#.*"     ## line starts with (zero or more spaces and then) a hash mark
    grepl_line_may_have_comment  = "#.*"            ## line contains a hash mark somewhere, but that may be number sign within quoted text

  }

  if (!quiet) {
    cat("\nSearching in ", path, ' to find files containing ', pattern, '\n')
    # or e.g., find_in_files(pattern = "^#'.*[^<]http", path = "./R")
  }
  x <- list.files(path = path, pattern = filename_pattern, recursive = recursive, full.names = full.names)
  names(x) <- x
  if (ignorecomments) {
    pattern <- paste0("(^|[^#])", pattern) # ignore comments, so only match if not preceded by a #
  }
  found <- x |>
    purrr::map(
      ~grep_lines(pattern, readLines(.x, warn = FALSE), value = TRUE, ignore.case = ignore.case,
                 ignorecomments = ignorecomments)
    ) |>
    purrr::keep(~length(.x) > 0)
  # rownumbers_with_hits <- sapply(found, names)

  if (!whole_line) {
    # return just the matching part, not text before or after that on a given line of text
    ## but does not quite work right if the line has quote marks inside it
    found <- lapply(found, function(z) {
      oldnames <- names(z)
      thisfile <- as.vector(gsub(paste0(".*(", pattern, ").*"), "\\1",  z))
      #  now for each element in the list called "found" we have to fix names of its vector to be the line numbers again
      names(thisfile) <- oldnames
      rownames(thisfile) <- NULL
      thisfile
    })
    # for (i in seq_along(found)) {
    #   names(found[[i]]) <- rownumbers_with_hits[[i]]
    #   rownames(found[[i]]) <- NULL
    # }
  } else {
    for (i in seq_along(found)) {
      rownames(found[[i]]) <- NULL
    }
  }

  if (!quiet) {
    if (length(found) > 0) {
      cat("\n------------------------------------------------------------------------- \n")
      cat("Which line numbers contain a match to this pattern, within each file?\n")
      cat(  "------------------------------------------------------------------------- \n\n")

      # add dummy data to help retain format expected
      if (length(found[[1]]) < 2) {
        found[[1]] = c(found[[1]], `0` = "dummy entry to ensure data.table format even if only 1 hit per file" )
      }
      if (length(found) == 1) {
        found <- c(found,  list(dummydata000 = c(`0` = "dummy entry", `01` = "dummy entry")))
      }
      printable <- lapply(found, function(y) {
        prt <- cbind(linenumber = names(y), text = y)
        rownames(prt) <- NULL
        prt
      })
      for (i in seq_along(printable)) {
        printable[[i]] <- as.data.frame(printable[[i]])
        printable[[i]]$file <- names(found)[i]
        printable[[i]]$filenumber <- i
      }
      # get rid of dummy data
      printable[[1]] <- printable[[1]][printable[[1]]$linenumber != 0, ]
      printable$dummydata000 <- NULL
      found[[1]] <- found[[1]][ !("0" == names(found[[1]]))]
      found <- found[!("dummydata000" == names(found))]

      printable <- do.call(rbind, printable)
      printable <- printable[, c("filenumber", "file", "linenumber", "text")]
      rownames(printable) <- NULL
      if (!whole_line) {
        print(printable)
      } else {
        # looks better if whole lines all start in same vertical alignment
        print(cbind(filenumber = printable$filenumber, file = printable$file, linenumber = printable$linenumber, text = printable$text))
      }

      cat("\n")
      cat(  "------------------------------------------------------------------------- \n")
      cat("How many times does the pattern appear in a given file?\n")
      cat(  "------------------------------------------------------------------------- \n\n")
      print(cbind(hits_in_file = sort(sapply(found, NROW), decreasing = TRUE), file_rank = 1:length(found)))
      cat("\n")
      cat("# of files: ", length(found), "\n")
      cat("# of hits: ", sum(sapply(found, NROW), na.rm = TRUE), "\n")
      cat("\n------------------------------------------------------------------------- \n")
    }
  }
  if (length(found) == 0) {found <- NULL}

  # sapply(x, function(z) cbind(linenumber=names(z), text = z))

  invisible(found)
}
################################ #


#' Check which search terms are found in any file
#'
#' @param pattern_vector in a loop, each element is passed to `find_in_files()`
#' @param path optional path like "./R"
#' @param ignorecomments if TRUE, ignore matches in lines that are just comments not actual source code
#' and note TRUE IS NOT DEFAULT IN find_in_files() but is here
#' @param ... passed to `find_in_files()` can be ignore.case, filename_pattern, etc.
#' @examples
#'   EJAM:::found_in_files(c("gray", "grey"), quiet = FALSE, ignore.case = FALSE)
#' @details Uses [find_in_files()] once for each element of `pattern_vector`.
#'
#' @return Logical vector, one element per search term in `pattern_vector`.
#' @seealso [find_in_files()] [found_in_N_files_T_times()] [grepn()] [grepns()]
#'   [grepls()] [grep_lines()]
#'
#' @keywords internal
#'
found_in_files <- function(pattern_vector, path = "./R", ignorecomments = TRUE, ...) {

  found <- vector(length = length(pattern_vector))
  for (i in seq_along(pattern_vector)) {
    hits <- find_in_files(pattern = pattern_vector[i], path = path, ignorecomments=ignorecomments, ...)
    found[i] <- length(hits) > 0
  }
  foundones <- pattern_vector[found]
  print(foundones)
  return(found) # logical vector
}
################################ #

#' Count how often each search term appears across files
#'
#' @description For each term in `pattern_vector`, runs [find_in_files()] and
#'   reports both how many files contain the term and how many matching lines
#'   were found overall.
#' @param pattern_vector character vector of search terms
#' @param path optional path like "./R"
#' @param ignorecomments if `TRUE`, ignore matches in lines that are just
#'   comments rather than active source code
#' @param ... passed to [find_in_files()] such as `ignore.case` or
#'   `filename_pattern`
#' @return Data frame with columns `term`, `nfiles`, and `nhits`.
#' @examples
#' EJAM:::found_in_N_files_T_times(c("gray", "grey"), path = "./R", quiet = TRUE)
#' @seealso [find_in_files()] [found_in_files()] [grepn()] [grepns()] [grepls()]
#'   [grep_lines()]
#' @keywords internal
#'
found_in_N_files_T_times <- function(pattern_vector, path = "./R", ignorecomments = TRUE, ...) {

  nfiles <- vector(length = length(pattern_vector))
  nhits <- vector(length = length(pattern_vector))
  for (i in seq_along(pattern_vector)) {
    hits <- find_in_files(pattern = pattern_vector[i], path = path, ignorecomments = ignorecomments, ...)
    nfiles[i] <- length(hits)
    nhits[i] <- length(as.vector(unlist(hits)))
    # found[i] <- length(hits) > 0
  }
  # foundones <- pattern_vector[found]
  out <- data.frame(term = pattern_vector,
                    nfiles = nfiles,
                    nhits = nhits
  )
  print(head(
    out[order(out$nfiles, out$nhits, decreasing = TRUE), ]
  ), 10)
  invisible(out)
}
################################ ################################# #
# . ####
## package's functions & datasets####


# get functions, datasets, filenames - exported & internal

#' utility to see which objects in a loaded/attached package are functions or datasets, exported or not (internal)
#' @details
#'   See [pkg_dupeRfiles()] for files supporting a shiny app that is not a package, e.g.
#'
#'   See [pkg_dupenames()] for objects that are in R packages.
#'
#'   See [pkg_functions_and_data()], pkg_functions_and_sourcefiles(),
#'
#'   See [pkg_data()]
#'
#' @param pkg name of package as character like "EJAM"
#' @param alphasort_table default is FALSE, to show internal first as a group, then exported funcs, then datasets
#' @param internal_included default TRUE includes internal (unexported) objects in the list
#' @param exportedfuncs_included default TRUE includes exported functions (non-datasets, actually) in the list (unless functions_included = FALSE)
#' @param data_included default TRUE includes datasets in the output, as would be seen via data(package=pkg)
#' @param functions_included default TRUE includes functions in the output
#' @param vectoronly set to TRUE to just get a character vector of object names instead of the data.frame table output
#' @seealso [ls()] [getNamespace()] [getNamespaceExports()] [loadedNamespaces()]
#'
#' @return table in [data.table](https://r-datatable.com) format with colnames object, exported, data  where exported and data are 1 or 0 for T/F,
#'   unless vectoronly = TRUE in which case it returns a character vector
#'
#' @examples
#'
#'  # some way to see what functions are in the package:
#'
#'  x1 <- EJAM:::pkg_functions_and_data(data_included = FALSE, vectoronly = TRUE)
#'  if (interactive()) {
#'    x2 <- EJAM:::pkg_functions_and_sourcefiles()
#'    info3 <- capture.output({ x3 <- EJAM:::pkg_functions_by_roxygen_tag() })
#'    info4 <- capture.output({ x4 <- EJAM:::pkg_functions_found_in_files() })
#'    ## x5 <- EJAM:::pkg_functions_preceding_lines() # may need to be debugged
#'  }
#'
#'  # Which functions, files, or data objects are named with certain terms?
#'
#'  terms <- c("name",  "var", "fix",  "meta", "calc", "ejscreen", "report", "make")
#'  # also try   "^get", "^block", "^bg"
#'
#'  # See FUNCTION names that use certain words - Useful view
#'
#'  extra <- capture.output({
#'    funcs <- EJAM:::pkg_functions_found_in_files()
#'  }); rm(extra)
#'  sapply(terms, function(term) {cbind(grep(term, funcs, value = TRUE))})
#'
#'  # See FILE names that use certain words - Useful view
#'
#'  # list.files(recursive = TRUE, pattern = "^datacreate")
#'  list.files(recursive = TRUE, pattern = "^util.*R$")
#'  sapply(setdiff(terms, 'name'), function(term) {
#'    list.files(recursive = TRUE, pattern = paste0(term, ".*R$"))
#'  })
#'
#'  # See DATASET names that use certain words - Useful view
#'
#'  dat <- EJAM:::pkg_functions_and_data(functions_included = FALSE, vectoronly = TRUE)
#'  terms1 = "formula"
#'  cat("DATA OBJECTS \n"); grep(terms1, dat, value=TRUE)
#'  cat("FUNCTIONS \n"); paste0(grep(terms1, funcs, value=TRUE), "()")
#'
#'  terms1="calc"
#'  cat("DATA OBJECTS \n"); grep(terms1, dat, value=TRUE)
#'  cat("FUNCTIONS \n"); paste0(grep(terms1, funcs, value=TRUE), "()")
#'
#'  # some ways to to see what datasets are in the EJAM package:
#'
#'   yo <- EJAM:::pkg_functions_and_data(functions_included = FALSE, vectoronly = TRUE)
#'   x  <- EJAM:::pkg_data("EJAM", simple = FALSE)
#'   setequal(x$Item, yo)
#'
#'  # Plot showing that just a couple of large datasets
#'  # account for most of the total:
#'
#'   biggest = x$Item[which.max(x$sizen)]
#'   bigp = round(100 * x$sizen[which.max(x$sizen)] / sum(x$sizen), 0)
#'   plot(cumsum(  sort(x$sizen,decreasing = TRUE )) / sum(x$sizen),
#'        ylim=c(0,1), ylab="Share of total size", xlab="datasets sorted large to small", type = 'b',
#'             main= paste0(biggest, " alone is ", bigp,"% of total"))
#'             abline(v=0);abline(h=0);abline(h=1);abline(v=length(x$sizen))
#'
#'   subset(x, x$size >= 0.1) # at least 100 KB
#'   xo <- x$Item
#'   grep("names_", xo, value = TRUE, ignore.case = TRUE, invert = TRUE) # most were like names_d, etc.
#'   ls()
#'   data("avg.in.us", package="EJAM") # lazy load an object into memory and make it visible to user
#'   ls()
#'
#'
#'  # another way to see just a vector of the data object names
#'  data(package = "EJAM")$results[, 'Item']
#'
#'  # not actually sorted within each pkg by default
#'  head(EJAM:::pkg_data())
#'  # not actually sorted by default
#'  head(EJAM:::pkg_data("EJAM")$Item)
#'  ## EJAM:::pkg_data("MASS", simple = TRUE)
#'
#'  # sorted by size if simple=F
#'  ## EJAM:::pkg_data("datasets", simple = FALSE)
#'  x <- EJAM:::pkg_data(simple = FALSE)
#'  # sorted by size already, to see largest ones among all these pkgs:
#'  tail(x[, 1:3], 20)
#'
#'  # sorted alphabetically within each pkg
#'  head(
#'    x[order(x$Package, x$Item), 1:2]
#'  )
#'  # sorted alphabetically across all the pkgs
#'  head(
#'    x[order(x$Item), 1:2]
#'  )
#'
#' # datasets as lazyloaded objects vs. files installed with package
#'
#' topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.
#'
#' # datasets / R objects
#' cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = TRUE)))
#'
#' # files
#' cbind(files.in.package = sort(basename(testdata(topic, quiet = TRUE))))
#'
#'
#' @keywords internal
#'
pkg_functions_and_data <- function(pkg = "EJAM",
                                   alphasort_table = FALSE,
                                   internal_included = TRUE,
                                   exportedfuncs_included = TRUE,
                                   functions_included = TRUE,
                                   data_included = TRUE,
                                   vectoronly = FALSE) {

  if (!paste0("package:", pkg) %in% search()) {
    stop(paste0("package:", pkg), " is not found in search() -- this function needs the package attached via library() or require() or possibly via devtools::load_all()")
  }

  ## (helpers) ### #
  if (!internal_included) {
    if (exists("radius_inferred")) {
      warning("Looks like you have done load_all() and if so, internal objects will get included in output here, even though you set internal_included = FALSE")
    }
    # x = sort(getNamespaceExports("EJAM"))
    # y = sort(EJAM:::pkg_functions_and_data("EJAM", internal_included = FALSE, vectoronly = T, data_included = F))
    # length(x); length(y); setdiff(y, x)
  }
  dataonly <- function(pkg) {pkg_data(pkg = pkg, simple = TRUE)$Item}

  exported_plus_internal_withdata <- function(pkg) {
    funcs <- ls(getNamespace(pkg), all.names = TRUE)
    funcs <- funcs[sapply(funcs, function(fname) {is.function(get(fname))})] # removes things in namespace like  ".__NAMESPACE__." that are not functions
    sort(union(dataonly(pkg),
               funcs
    ))
  } # all.names filters those starting with "."
  exported_only_withdata          <- function(pkg) {ls(paste0("package:", pkg))}
  # same as ls(envir = as.environment(x = paste0("package:", pkg)))
  # same as  getNamespaceExports() except sorted

  exported_plus_internal_nodata <- function(pkg) {sort(setdiff(
    exported_plus_internal_withdata(pkg = pkg),
    dataonly(pkg = pkg)))}
  exported_only_nodata <- function(pkg) {sort(setdiff(
    exported_only_withdata(pkg = pkg),
    dataonly(pkg = pkg)))}

  internal_only_withdata <- function(pkg) {sort(setdiff(
    exported_plus_internal_withdata(pkg = pkg),
    exported_only_nodata(pkg = pkg)))}
  internal_only_nodata <- function(pkg) {sort(setdiff(
    internal_only_withdata(pkg = pkg),
    dataonly(pkg = pkg)))}

  # # double-checks
  #
  # setequal(      exported_plus_internal_withdata("EJAM"),
  #          union(exported_plus_internal_nodata(  "EJAM"), dataonly("EJAM")))
  #
  # setequal(      exported_only_withdata(         "EJAM"),
  #          union(exported_only_nodata(           "EJAM"), dataonly("EJAM")))
  #
  # setequal(      internal_only_withdata(         "EJAM"),
  #          union(internal_only_nodata(           "EJAM"), dataonly("EJAM")))

  # table format output

  omni <- exported_plus_internal_withdata(pkg)
  y <- data.frame(
    object = omni,
    exported = ifelse(omni %in% exported_only_withdata(pkg), 1, 0),
    data = ifelse(omni %in% dataonly(pkg), 1, 0)
  )
  if (!data_included) {
    y <- y[y$data != 1, , drop = FALSE]
  }
  if (!functions_included) { # to supposedly drop funcs, actually drop non-data, or keep only data
    y <- y[y$data == 1, , drop = FALSE]
  }

  if (!internal_included) {
    y <- y[!(y$exported == 0), ]
  }
  if (!exportedfuncs_included) {
    y <- y[!(y$exported == 1 & y$data == 0), ]
  }

  if (!vectoronly) {
    if (alphasort_table) {
      # already done by default
    } else {
      y <- y[order(y$exported, y$data, y$object), ]
    }
    return(y)
  }

  # vector format output

  if (vectoronly) {
    # cat('\n\n')
    # cat(pkg)
    # cat('\n\n')
    # print(y)
    # cat('\n\n')

    return(y$object)

    ################# #
    # if (internal_included & data_included) {
    #   x <- exported_plus_internal_withdata(pkg)
    # }
    # if (internal_included & !data_included) {
    #   x <- exported_plus_internal_nodata(pkg)
    # }
    # if (!internal_included & data_included) {
    #   x <- exported_only_withdata(pkg)
    # }
    # if (!internal_included & !data_included) {
    #   x <- exported_only_nodata(pkg)
    # }
    #   return(x)
    ################# #

  }
}
##################################################################### #
# . ####

#' UTILITY - DRAFT - See names and size of data sets in installed package(s) - internal utility function
#'
#' Wrapper for data() and can get memory size of objects
#' @details do not rely on this much - it was a quick utility.
#'   It may create and leave objects in global envt - not careful about that.
#'
#'   Also see functions like pkg_functions_and_data() and pkg_functions_xyz
#'
#' @param pkg a character vector giving the package(s) to look in for data sets
#' @param len Only affects what is printed to console - specifies the
#'   number of characters to limit Title to, making it easier to see in the console.
#' @param sortbysize if TRUE (and simple = FALSE),
#'   sort by increasing size of object, within each package, not alpha.
#' @param simple FALSE to get object sizes, etc., or
#'    TRUE to just get names in each package, like
#'    `data(package = "EJAM")$results[, c("Package", 'Item')]`
#' @return If simple = TRUE, data.frame with colnames Package and Item.
#'   If simple = FALSE, data.frame with colnames Package, Item, size, Title.Short
#'
#' @inherit pkg_functions_and_data examples
#'
#' @keywords internal
#'
pkg_data <- function(pkg = 'EJAM', len=30, sortbysize=TRUE, simple = TRUE) {

  if (simple) {
    cat('Get more info with pkg_data(simple = FALSE)\n\n')
    out <- data.frame(data(package = pkg)$results[, c('Package', 'Item')])
    if (sortbysize) {cat('ignoring sortbysize because simple=TRUE \n\n')}
    return(out)
  }

  n <- length(pkg)
  ok <- rep(FALSE, n)
  for (i in 1:n) {
    ok[i] <- 0 != length(find.package(pkg[i], quiet = TRUE))
  }
  pkg <- pkg[ok] # available in a library but not necessarily attached ie on search path, in print(.packages()) or via search()
  # pkg_on_search_path <- pkg %in%  .packages() # paste0('package:', pkg) %in% search()
  were_attached <- .packages()
  were_loaded <- loadedNamespaces()

  ## commented out the on.exit section as it was causing namespace/search path issues with some of the EJAM dependencies
  # on.exit({
  #   #  get it back to those which had been attached and or loaded before we started this function
  #   wasnotherebefore <- setdiff(.packages(), were_attached)
  #   for (this in wasnotherebefore) {
  #     # for (this in pkg[!(pkg %in% were_attached)]) {
  #     detach(paste0("package:", this), unload  = FALSE, force = TRUE, character.only = TRUE)
  #   }
  #   wasnotloadedbefore <- setdiff(loadedNamespaces(), were_loaded)
  #   for (this in wasnotloadedbefore) {
  #     unloadNamespace(this)
  #   }
  # })

  if (length(pkg) == 0) {
    return(NULL)
  } else {

    zrows <- as.data.frame(data(package = pkg)$results) # this works for multiple packages all at once

    # THIS PART ONLY WORKS ON ONE PACKAGE AT A TIME I THINK

    cat('Loading all packages .... please wait... \n')
    for (this in pkg) {
      library(this, character.only = TRUE, quietly = TRUE)
      # otherwise they are not attached/on search path and cannot use get() to check object size, etc.
    }

    zrows$size = sapply(
      #objects(envir = as.environment( paste0("package:", pkg) )),
      zrows$Item,
      function(object_x) {

        # for each item in any package:
        thispkg <- zrows$Package[match(object_x, zrows$Item)]
        if (!exists(object_x, envir = as.environment(paste0("package:", thispkg) ) )) {
          cat('cannot find ', object_x, ' in ', thispkg, ' via exists() so trying to use data() \n')
          #return(0)
          data(object_x, envir = as.environment(paste0("package:", thispkg) ) )
        } # in case supposedly data but not lazy loaded per DESCRIPTION
        if (!exists(object_x, envir = as.environment(paste0("package:", thispkg) ) )) {
          cat('tried loading  ', object_x,' via data() but failed \n')
          subpart = gsub(' .*', '', object_x)
          bigpart = gsub(".*\\((.*)\\)", '\\1', object_x)
          cat('so trying to load the overall item ', bigpart, ' that contains object ', subpart, '\n')
          data(bigpart,  envir = as.environment(paste0("package:", thispkg) ))
          object_x = subpart
          #return(0)
        }

        xattempt <- try(
          get(object_x, envir = as.environment(paste0("package:", thispkg) ) ),
          silent = TRUE
        )
        if (inherits(xattempt, "try-error")) {
          cat("Error in trying to use get(", object_x, ", envir = as.environment(", paste0('package:', thispkg), ")) \n")
          xattempt <- NULL
        }

        format(object.size(
          xattempt
        ),
        # maybe since already attached do not need to do all this to specify where it is
        units = "MB", digits = 3, standard = "SI")
      } # end function(object_x)
    ) # end of sapply loop over all zrows$Item
    ############################## #
    cat('\n\n')

    zrows <- zrows[ , c("Package", "Item", "size", "Title")]
    sizenumeric =   as.numeric(gsub("(.*) MB", "\\1", zrows$size))
    zrows$sizen <- sizenumeric

    if (sortbysize) {
      zrows <- zrows[order(sizenumeric), ]
      rownames(zrows) <- NULL
    }

    ############################## #
    # show sorted rounded largest ones only, with shortened titles
    zrows_narrow <- zrows
    zrows_narrow$Title.Short  <- substr(zrows_narrow$Title, 1, len)
    zrows_narrow$Title <- NULL
    sizenumeric =   as.numeric(gsub("(.*) MB", "\\1", zrows_narrow$size))
    if (sum(sizenumeric >= 1)  == 0) {
      cat("None are > 1 MB in size: \n\n")
      rounding = 3
    } else {
      cat('The ones at least 1 MB in size: \n\n')
      zrows_narrow <- (zrows_narrow[sizenumeric >= 1, ])
      rounding = 0
    }
    sizenumeric =   as.numeric(gsub("(.*) MB", "\\1", zrows_narrow$size))
    zrows_narrow$size <-  paste0(round(sizenumeric, rounding), ' MB')
    print(zrows_narrow)

    ############################## #

    invisible(zrows)
  }
}
##################################################################################### #
# . ####

# # utility to get the filename where a function is defined PLUS other info
# #
# # @details returns NA where there are special characters like %, and
# #   maybe returns NA if e.g., function is defined as equal to / alias of another function,
# #   like askradius <- ask_number where ask_number = function() {}
# #
pkg_functions_and_sourcefiles <- function(pkg = "EJAM",
                                          funcs = NULL, # default is all
                                          alphasort_table = TRUE,
                                          internal_included = TRUE,
                                          exportedfuncs_included = TRUE,
                                          data_included = FALSE,
                                          loadagain = TRUE, # needed to find internal functions if load_all() wasnt just done
                                          quiet = FALSE,
                                          full.names = FALSE) {

  vectoronly = FALSE
  info <- pkg_functions_and_data(pkg = pkg, internal_included = internal_included, exportedfuncs_included = exportedfuncs_included,
                                 data_included = data_included, alphasort_table = alphasort_table, vectoronly = vectoronly)
  funcnames <- info$object

  if (!is.null(funcs)) { # report on just a subset of specified functions
    if (!all(funcs %in% funcnames)) {warning("not all specified funcs were found")}
    funcnames <- intersect(funcnames, funcs)

  }
  # does not work:
  ## funcnames <- paste0(pkg, ":::", funcnames) # to be able to find them if load_all() not done

  if (basename(getwd()) != pkg) {stop("working directory must be the source package folder for pkg", pkg)}
  if (loadagain) {
    devtools::load_all()
    envt <- globalenv()
  } else {
    envt <- as.environment(paste0("package:", pkg)) # will only find filename of exported ones if load_all() was not already done
  }
  if (length(funcnames) == 0) {stop("no function names found")}
  ## Get the filename of source code .R file containing each function.
  filenames <- vector(length = length(funcnames))

  for (i in seq_along(funcnames)) {
    func <- try(parse(text = paste0("`", funcnames[i], "`")), silent = TRUE) # handles e.g., "`%not_in%`"
    if (inherits(func, "try-error") || length(func) == 0) {
      filenames[i] <- NA
    } else {
      x <- try(utils::getSrcFilename(eval(func, envir = envt), full.names = full.names), silent = TRUE)
      if (inherits(x, "try-error") || length(x) == 0 || length(x) > 1) {
        filenames[i] <- NA
      } else {
        filenames[i] <- x
      }
    }
  }
  if (!quiet) {cat("\n")}
  x <- data.frame(file = filenames, object = funcnames)
  if (alphasort_table) {
    x <- x[order(x$object), ]
  } else {
    x <- x[order(x$file, x$object), ]
  }
  return(x)
}
##################################################################################### #

# Get each function's filename AND keywords tag

# so we can check
# which say @keywords internal in the .R file vs
# which are listed as internal in _pkgdown.yml vs
# which are actually unexported by the package.

## EXAMPLE
#
# x <- pkg_functions_with_keywords_internal_tag()

# > colSums(x[, 8:11])
# both_but_differ   fname_is_func   fname_is_name  fname_is_name1
#               1             144               0             144

# table(func.na = is.na(x$func),
#       name.na = is.na(x$name))
#
#             name.na
## func.na FALSE TRUE
##   FALSE   165  489  have func/call
##   TRUE     17    0  no func/call (in the call tag)
##
## 165 have both name and func call (some are datasets).
## 489 have only func/call.
## 17 have only name call, like datasets.
## 0 have neither.
#
# both = x[!is.na(x$func) & !is.na(x$name) , ]

### check if exported vs keyword internal, etc.
# golem::detach_all_attached()
# load_all(export_all = FALSE)
# x = EJAM:::pkg_functions_with_keywords_internal_tag()
# y = EJAM:::pkg_functions_and_data("EJAM")
# z = data.frame(x, y[match(x$name1, y$object), ])
# z[, c('name1', 'keywordval', 'exported')]


# NOTE THIS IS SLOW SINCE by default IT LOADS THE PACKAGE (AND PARSES ALL ROXYGEN TAGS)

## compare this to   pkg_functions_by_roxygen_tag() & others
# see also pkg_functions_preceding_lines()

pkg_functions_with_keywords_internal_tag <- function(

  package.dir = ".",
  loadagain = TRUE,
  quiet = FALSE,
  alphasort_table = TRUE # or can group by file if set FALSE
) {

  # Does load_all() first if loadagain==TRUE so even unexported functions will seem exported, fyi
  #
  # Does not check undocumented functions (those lacking roxygen tags, like if func_alias <- definedfunc1)
  # but does check unexported functions with roxygen tags
  # and does check documented datasets not just functions

  roclets <- NULL
  load_code <- NULL
  clean <- FALSE

  base_path <- normalizePath(package.dir)
  is_first <- roxygen2:::roxygen_setup(base_path)
  roxygen2:::roxy_meta_load(base_path)
  packages <- roxygen2::roxy_meta_get("packages")
  lapply(packages, loadNamespace)
  if (loadagain) {
    load_code <- roxygen2:::find_load_strategy(load_code)
    env <- load_code(base_path) # slow step
  } else {
    env = globalenv()
  }
  roxygen2:::local_roxy_meta_set("env", env)

  blocks <- roxygen2::parse_package(base_path, env = NULL)  # slow step

  results <- list()
  i <- 0

  function_names_in_blocks <- sapply(blocks, function(x)  as.character(x$call)[2])

  for (block in blocks) {

    i <- i + 1
    # block <- blocks[[671]]
    # block <- blocks[[1]]
    object_name <- function_names_in_blocks[i]
    ## if that is NA, it must be a data object, not a function?
    ## if we wanted to collect the data object name:
    #if (is.na(object_name)) {object_name <- roxygen2::block_get_tag_value(block, 'name')}
    if (is.null(object_name) || length(object_name) == 0 || any(is.na(object_name))) {
      object_name <- NA # e.g., a data object not a function
      # cat("cannot find name in this block: \n")
      # cat("\n")
    }

    if (!("call" %in% names(block))) {
      object_call <- NA
    } else {
      if (is.null(block$call) || any(is.na(block$call)) || length(block$call) == 0) {
        object_call <- NA
        # probably a dataset or package rather than a function definition
      } else {
        # roxygen2:::block_get_tag_value(block, 'name') # no
        if (length(block$call) > 1) {
          object_call <- gsub("(|)", "", block$call[2]) # name of function hopefully
        } else {
          object_call <- block$call # sometimes it contained the dataset name somehow
        }
      }
    }
    if (!quiet) {
      cat(paste0(i, ". ", paste0(object_call, " / ", object_name), " "))
    }
    tags <- roxygen2::block_get_tags(block, "keywords")

    if (length(tags) == 0) {
      keywordval <- ""
    } else {
      if (length(tags) > 1) {
        if (!quiet) {cat("   MULTIPLE KEYWORDS TAGS FOUND - showing 1st only\n")}
      }
      if (!quiet) {cat(' @keywords ')}
      # for (tag in tags) {
      #    keyword <- roxygen2:::block_get_tag_value(block, 'keywords')  # or
      tag <- tags[[1]] # only expect one keywords tag per documented object ?
      keywordval <- tag$val
      # keywordinfo <- paste0("[", tag$file, ":", tag$line, "] ", tag$val)
      ## line is start of block, not the keywords tag itself
      if (!quiet) {cat(keywordval)}
    }
    if (!quiet && is.na(object_name)) {cat(" (seems to be a dataset not a function)")}
    if (!quiet) {cat("\n")}

    results[[i]] <- data.frame(n = i, func = object_call, name = object_name,
                               file = basename(block$file), line = block$line, keywordval = keywordval)
    # } # would be loop over keyword tags
  }

  results <- do.call(rbind, results)
  filename.no.ext = gsub(".R$", "", results$file)

  results$name1 <- ifelse(is.na(results$func), results$name, results$func) # use func/call and only use name as backup 2d choice
  results$both_but_differ = !is.na(results$func)  & results$func != results$name & !is.na(results$name)
  results$fname_is_func  <- !is.na(results$func)  & results$func  == filename.no.ext
  results$fname_is_data_name  <- !is.na(results$name)  & paste0("data_", results$name)  == filename.no.ext
  results$fname_is_name1 <- !is.na(results$name1) & results$name1 == filename.no.ext

  # NOW DROP DATA OBJECTS and sort
  results <- results[!is.na(results$name), ]
  if (alphasort_table) {
    results <- results[order(results$name), ]
  }
  return(results)
  # return(list(blocks = blocks, results = results) ) # for troubleshooting
}
##################################################################### #

################################ #

# see also pkg_functions_preceding_lines() to check multiple tags
# nlines_to_search defines how many rows above  the func definition line should be checked

pkg_functions_by_roxygen_tag <- function(

  tagpattern = "#' @export", # or, e.g.,  "#' @return"  etc.
  filename_pattern = "\\.R$|\\.r$",  # or, e.g.,  "frs_"
  path="./R",
  nlines_to_search = 50
) {

  x = find_in_files(tagpattern, path = path, filename_pattern = filename_pattern)
  n = length(x)
  fname = vector(length = n); rownums = list()
  funcname <- NULL

  for (i in seq_along(x)) {
    fname[i] = names(x[i])
    rownums[[i]] = names(x[[i]] )
    taglinenumbers = as.numeric(rownums[[i]])
    txt = readLines(fname[i])
    for (ii in 1:length(taglinenumbers)) {
      nextfuncname <-
        grep(pattern = "^([^# ]*) .*function\\(",
             x = txt[   taglinenumbers[ii]:(nlines_to_search + taglinenumbers[ii]) ],
             value = TRUE)
      nextfuncname <- gsub("^([^ #]*) .*function\\(.*", "\\1", nextfuncname)
      if (is.null(nextfuncname)
          # || (0 %in% length(nextfuncname) )
      ) {
        cat("no function definition found just after line ", taglinenumbers[ii], " in file ", fname[i])
        nextfuncname <- NULL
      } else {
        if ("" %in% nextfuncname) { nextfuncname <- NULL} else {
          if (length(nextfuncname) == 0) { nextfuncname <- NULL}
        }
      }
      funcname <- c(funcname, nextfuncname)
    }
  }
  funcname <- sort(funcname)
  cat("# of files: ", n, "\n")
  cat("# of functions: ", length(funcname), "\n")
  return(funcname)
}
################################ #

## This just counts source code lines where a function definition seems to start on
## a line with no leading spaces or # signs (not a commented line)
## so it probably avoids functions defined within other functions

pkg_functions_found_in_files <- function(

  # find any line with function definition (ignore if any spaces or # precede func name, since those are usually function within a function, or comments or roxygen tags/examples, etc.)
  pattern        = "^([^ #]+) *(<-|=) *function\\(",
  pattern_gsub   = "^([^ #]+) *(<-|=) *function\\(.*", # save func name in parens here, while matching the entire line
  path= "./R") {

  z = find_in_files( pattern = pattern, path = path)
  z = as.vector(unlist(z))
  z = gsub(pattern_gsub,  "\\1", z) # replace entire line with just the function name
  z = z[!(z %in% "")]
  z = sort(z)
  return(z)
}
################################ #

## view lines of roxygen tags just above a function definition,
## to see if it has any roxygen comments at all
## or says #' @keywords internal  or whatever
# see also pkg_functions_by_roxygen_tag()
# see also pkg_functions_with_keywords_internal_tag()

pkg_functions_preceding_lines = function(path = "./R",
                                         nlines_to_search = 200,
                                         # Will now look at only contiguous lines starting with #' going only upwards until it hits a line that is NOT starting with #'
                                         quiet = TRUE) {

  n <- 0
  info_roxy_nobreak <- vector()
  info_roxy <- vector()
  info_roxy <- vector()
  info_func <- vector()
  info_internal <- vector()
  info_nord <- vector()
  info_export <- vector()
  info_return <- vector()
  # find any line with function definition
  # (ignore if any spaces or # precede func name, since those are usually function within a function, or comments or roxygen tags/examples, etc.)
  # find function definition lines, seeking "xyz=function(" or "xyz  <-  function(" etc. ignoring commented out or roxygen tag lines
  query = "^[^ #]+ *(<-|=) *function\\("
  files_defining_functions <- EJAM:::find_in_files(pattern = query, path = path, quiet = TRUE)
  filenames = (names(files_defining_functions))

  for (thisfile in seq_along(files_defining_functions)) {

    textrows = readLines(filenames[thisfile])
    linenums = as.numeric(names(files_defining_functions[[thisfile]]))
    funcnames = as.vector(gsub("^([^ ]*) .*", "\\1", files_defining_functions[[thisfile]]))

    for (thisfunction in 1:length(funcnames)) {
      n = n + 1
      priorlinenums <- (linenums[thisfunction] - (nlines_to_search:0))
      priorlinenums[priorlinenums < 1] <- 1
      priorlinenums <- unique(priorlinenums)
      # Remove preceding rows that are unrelated to this one function
      # by searching up from func definition to 1st row encountered that is not roxygen tags
      lastunrelatedline <-  which(!grepl("^ *#'", rev( textrows[priorlinenums[1:(length(priorlinenums) - 1)]])))[1]
      if (length(lastunrelatedline) != 0) {
        lastunrelatedline <- length(priorlinenums) - lastunrelatedline
        priorlinenums <- priorlinenums[(1+lastunrelatedline):length(priorlinenums)]
      }

      # text2show is what to search within (while creating table of info_return)
      # but is also what to show in console. might want to show only a few lines but still search in all/many prior rows, though.
      text2show <- textrows[priorlinenums]
      # show just the function name not that whole line
      funcname <- gsub(" .*", "", text2show[length(text2show)])
      # text2show[length(text2show)] <- paste0(funcname, " <- ")
      # drop func definition line itself
      text2show <- text2show[1:(length(text2show) - 1)]
      # drop all but blank and #' roxygen lines, for display purposes
      text2show <- text2show[nchar(text2show) == 0 | grepl("^ *#' [^ ]", text2show)]
      text2show[nchar(text2show) == 0] <- "     [just a blank line is here]"
      text2show <- unique(text2show)

      # display key lines to console
      if (!quiet) {
        cat("------------------ File: ", as.vector(basename(filenames[thisfile])),
            "--------- Func: ", paste0(funcname, "() "), "\n")
        cat(text2show, sep = "\n")
        cat("\n")
      }
      # summarize counts for a table of results

      priorlinetext = textrows[max(priorlinenums)]
      info_roxy_nobreak[n] <- substr(priorlinetext,1,2) == "#'" # only in the last row (?)
      info_roxy[n] <- any(grepl("#'", text2show)) # any of last few rows
      info_func[n] <- funcname
      info_internal[n] <- any(grepl("@keywords internal", text2show))
      info_nord[n]     <- any(grepl("@noRd", text2show))
      info_export[n]   <- any(grepl("@export", text2show))
      info_return[n]   <- any(grepl("@return", text2show))
    }
  }
  info_table <- data.frame(
    func = info_func,
    roxy_nobreak = info_roxy_nobreak,
    roxy = info_roxy,
    export = info_export,
    internal = info_internal,
    nord = info_nord,
    return = info_return
  )
  info_table <- info_table[order(info_table$func), ]
  # show counts of functions with/without a given tag, and overall counts
  print(summary(info_table))
  cat("\n")
  cat("# of files: ", length(unique(files_defining_functions)), "\n")
  cat("# of functions: ", length(info_func), "\n")
  cat("\n")
  return(info_table)
}
################################ ################################# #
# . ####
################################ ################################# #

# conflicting sourcefile names ####

#' UTILITY - check conflicting sourcefile names in 2 packages/folders
#'
#' @description See what same-named .R files are in 2 sourcecode folders
#' @details
#'   See [pkg_dupeRfiles()] for files supporting a shiny app that is not a package
#'
#'   See [pkg_dupenames()] for objects that are in R packages.
#'
#'   See [pkg_data()] for objects that are in R packages.
#'
#'   See [pkg_functions_and_data()] for functions in R package.
#'
#'   See [pkg_functions_that_use()] - searches for text in each function exported by pkg (or each .R source file in pkg/R)
#'
#' @param folder1 path to other folder with R source files
#' @param folder2 path to a folder with R source files, defaults to "./R"
#'
#' @keywords internal
#'
pkg_dupeRfiles <- function(folder1 = '../EJAM/R', folder2 = './R') {
  if (!dir.exists(folder1)) {
    #try to interpret as name of source package without path
    # assuming wd is one pkg and other is in parallel place
    folder1 <- paste0("../", folder1, "/R")
    if (!dir.exists(folder1)) {stop('folder1 does not exist nor does ', folder1)}
  }
  cat("Comparing .R files in ", folder1, ", to the files in ", folder2, "\n\n")
  docs1 <- list.files(folder1)
  docs2 <- list.files(folder2)
  both <- intersect(docs1, docs2)
  x <- list()
  for (fname in both) {
    x[[fname]] <-  ifelse(identical(
      readLines(file.path(folder1, fname)),
      readLines(file.path(folder2, fname))
    ) , "identical", "differ")
  }
  cat('\n\n')
  out <- data.frame(filename = both, identical = unlist(as.vector(x)))
  out <- out[order(out$identical), ]
  rownames(out) <- NULL
  return(out)
}
##################################################################### #

# conflicting exported functions or data ####

#' UTILITY - check conflicting getNamespaceExports (names of exported functions or datasets)
#'
#' @description See what same-named objects (functions or data) are exported by some (installed) packages
#' @details utility to find same-named exported objects (functions or datasets) within source code
#'   of 2+ packages, and see what is on search path, for dev renaming / moving functions/ packages
#'
#'   See [pkg_dupeRfiles()] for files supporting a shiny app that is not a package, e.g.
#'
#'   See [pkg_dupenames()] for objects that are in R packages.
#'
#'   See [pkg_functions_and_data()], pkg_functions_and_sourcefiles(), etc.
#'
#'   See [pkg_data()]
#'
#' @param pkg one or more package names as vector of strings.
#'   If "all" it checks all installed pkgs, but takes very very long potentially.
#' @param sortbypkg If TRUE, just returns same thing but sorted by package name
#' @param compare.functions If TRUE, sends to console inf about whether body and formals
#'   of the functions are identical between functions of same name from different packages.
#'   Only checks the first 2 copies, not any additional ones (where 3+ pkgs use same name)
#' @return data.frame with columns Package, Object name (or NA if no dupes)
#'
#' @keywords internal
#'
pkg_dupenames <- function(pkg = EJAM::ejampackages, sortbypkg=FALSE, compare.functions=TRUE) {

  # Get list of exported names in package1, then look in package1 to
  #   obs <- getNamespaceExports(pkg)
  # find those appearing in source code .R files without package1:: specified,
  # since code using those functions and code defining those have to both be in the same pkg,
  #  (or need to add xyz:: specified)
  # and maybe want to do global search replace within files, like this:
  #   xfun::gsub_file()

  if ("all" %in% pkg) {
    pkg <- as.vector(installed.packages()[,"Package"])
  } else {

    # THIS COULD/SHOULD BE REPLACED USING ::: and/or getFromNamespace(), etc.

    findPkgAll <- function(pkg) { # finds path to each installed package of those specified
      unlist(lapply(.libPaths(), function(lib)
        find.package(pkg, lib, quiet = TRUE, verbose = FALSE)))
    }
    installed.packages.among <- function(pkg) {
      fff <- findPkgAll(pkg) # ok if a pkg is not installed. finds path to installed not source location
      if (length(fff) == 0) {warning("none of those packages are installed")
        return(NA)
      }
      gsub(".*/", "", fff) # get just names of pkgs not full paths
    }
    pkg <- installed.packages.among(pkg)
  }
  # getNamespaceExports will get exported object names, but fails if any pkg is not installed, hence code above

  xnames <-  sapply(pkg, function(x) {

    # DO WE WANT TO CHECK EVEN NON-EXPORTED OBJECTS? see getFromNamespace() and :::

    y <- try(getNamespaceExports(x), silent = TRUE)

    if (inherits(y,"try-error")) {return(paste0("nothing_exported_by_", x))} else {return(y)}
  } ) # extremely slow if "all" packages checked

  counts <- sapply(xnames, length)
  xnames <- unlist(xnames)
  xnames_pkgs <- rep(names(counts), counts)
  names(xnames) <- xnames_pkgs
  ddd <-  data.frame(variable = xnames, package = names(xnames))
  duplicatednameslistedonceeach <- names(table(  xnames ))[(table(  xnames ) > 1)]
  if (length(duplicatednameslistedonceeach) > 0) {
    ddd <- ddd[ddd$variable %in% duplicatednameslistedonceeach, ]
    ddd <- ddd[order(ddd$variable), ]
    rownames(ddd) <- NULL
  } else {
    ddd <- NA
    return(ddd)
  }
  if (sortbypkg) ddd <- ddd[order(ddd$package), ]

  if (compare.functions) {
    ddd$problem = "ok"
    #  use pkg_functions_all_equal() here to compare all pairs (but ignores more 2d copy of a function, so misses check of trios)
    #  to see if identical names are actually identical functions
    # ddd <- pkg_dupenames()
    for (var in unique(ddd$variable)) {
      ok <- pkg_functions_all_equal(
        fun = var,
        package1 = ddd$package[ddd$variable == var][1],
        package2 = ddd$package[ddd$variable == var][2]
      )
      cat(var, " identical? ", ok, " \n")
      if (any(!ok)) {ddd$problem[ddd$variable == var] <- "Copies of this function differ"}
    }
    cat(" \n\n")
  } else {
    ddd$problem = "not checked"
  }

  return(ddd)
}
##################################################################### #
## (helper for pkg_dupenames) ### #

#' UTILITY - check different versions of function with same name in 2 packages
#' obsolete since old EPA ejscreen api functions were phased out - was used by pkg_dupenames() to check different versions of function with same name in 2 packages
#' @param fun quoted name of function, like "latlon_infer"
#' @param package1 quoted name of package, like "EJAM"
#' @param package2 quoted name of other package
#'
#' @return TRUE or FALSE
#' @seealso [pkg_dupenames()] [all.equal.function()]
#'
#' @keywords internal
#'
pkg_functions_all_equal <- function(fun="latlon_infer", package1="EJAM", package2) {

  # not the same as base R all.equal.function() see  ?all.equal.function

  # strange quirks did not bother to debug:

  # 1) Normally it checks the first two cases of dupe named functions from 2 packages,
  # and answers with FALSE or TRUE (1 value).
  # But it returns FALSE 3 times for some?
  # pkg_dupenames(ejampackages) # or just pkg_dupenames()

  # 2) ### error when checking a package that is loaded but not attached.
  # eg doing this:
  # pkg_functions_all_equal("get.distance.all", "proxistat", "EJAM") # something odd about proxistat pkg
  #   and note there is now a function called proxistat()

  if (!(is.character(fun) && is.character(package1) && is.character(package2))) {
    warning("all params must be quoted ")
    return(NA)
  }
  # we could attach
  f1 = try(
    silent = TRUE,
    expr = getFromNamespace(fun, ns = package1)
    # get((fun), envir = as.environment(paste0("package:", (package1)) ) ) # this would not work if the package were not already loaded, on search path. see ?getFromNamespace
  )
  if (inherits(f1,"try-error")  ) {
    # warning("fails when checking a package that is loaded but not attached - library func allows it to work. ")
    warning(fun, " not found in ", package1 )
    return(NA)
  }
  if (!(is.function(f1))) {warning(package1, "::", fun, " is not a function");return(NA)}

  f2 = try(
    silent = TRUE,
    expr = getFromNamespace(fun, ns = package2)
    # get((fun), envir = as.environment(paste0("package:", (package2)) ) )
  )

  if (inherits(f2,"try-error")) {
    # warning("fails when checking a package that is loaded but not attached - library func allows it to work. ")
    warning(fun, " not found in ",  package2)
    return(NA)
  }
  if (!(is.function(f2))) {warning(package2, "::", fun, " is not a function");return(NA)}

  x <- isTRUE(all.equal(body(f1), body(f2))) && isTRUE(all.equal(formals(f1), formals(f2)))
  return(x)
}
##################################################################################### #
# search / find text in functions or source files ####

#' utility for developing package - searches for text in each function exported by pkg (or each .R source file in pkg/R)
#'
#' @details Searches the body and parameter defaults of exported functions.
#' @param text something like "EJAM::" or "stop\\(" or "library\\(" or "***"
#' @param pkg name of package or path to source package root folder - this
#'
#'   checks only the exported functions of an installed package,
#'   if pkg = some installed package as character string like "EJAM"
#'
#'   checks each .R source FILE NOT each actual function,
#'   if pkg = root folder of source package with subfolder called R with .R source files
#'
#' @param ignore_comments logical,
#'   ignore_comments is ignored and treated as if it were TRUE when pkg = some installed package
#'
#'   ignore_comments is used only if pkg = a folder that contains .R files
#'
#'    Note it will fail to ignore comments in .R files that are at the end of the line of actual code like  print(1) # that prints 1
#' @param internal_included whether to also check internal functions - tries to identify those using `pkg_functions_and_data()`
#'
#' @return vector of names of functions or paths to .R files
#'
#' @keywords internal
#'
pkg_functions_that_use <- function(text = "stop\\(", pkg = "EJAM", ignore_comments = TRUE, internal_included = TRUE) {

  if (grepl("\\(", text) && !grepl("\\\\\\(", text)) {warning('to look for uses of stop(), for example, use two slashes before the open parens, etc. as when using grepl()')}

  stops <- NULL
  if (inherits(try(find.package(pkg), silent = TRUE), "try-error")) {
    # not an installed pkg.
    if (dir.exists(file.path(pkg, "R"))) {
      # it should be a folder that is root of source package with subfolder called R with .R files so search in those

      for (this in list.files(file.path(pkg, 'R'), pattern = '.R', full.names = TRUE)) {
        text_lines_of_function_body <- readLines(this)
        # each row is an element of the vector here
        if (ignore_comments) {
          dropcommentedlines <- function(mytext) {gsub("^[ ]*#.*$", "", mytext)} # presumes each line is an element of mytext vector
          text_lines_of_function_body <- dropcommentedlines(text_lines_of_function_body)
        }
        text_of_function_body <- paste0(text_lines_of_function_body, collapse = '\n')
        if (grepl(text, text_of_function_body)) {
          stops <- c(stops, this)}
      }

    } else {
      if (shiny::isRunning()) {
        warning('pkg must be the name of an installed package or a path to root of source package with R subfolder that has .R files')
        return(NULL)
      } else {
        stop('pkg must be the name of an installed package or a path to root of source package with R subfolder that has .R files')
      }
    }
  } else {
    # it is an installed package
    if (!ignore_comments) {warning('always ignores commented lines when checking exported functions of an installed package')}

    if (!internal_included) {
      funcnames <- getNamespaceExports(pkg)

    } else {
      funcnames <- pkg_functions_and_data(pkg = pkg, data_included = FALSE, vectoronly = TRUE, internal_included = TRUE)
    }

    for (this in funcnames) {

      text_lines_of_function_body <- as.character(functionBody(get(this)))
      # or is that the same as just  as.character(body(this))  ??
      # each row is an element of the vector now

      # also check the function parameter default values
      text_lines_of_function_body <- c(text_lines_of_function_body, paste0(formals(this), collapse = " "))

      if (ignore_comments) {
        dropcommentedlines <- function(mytext) {gsub("^[ ]*#.*$", "", mytext)} # presumes each line is an element of mytext vector
        # however that will fail to ignore comments that are at the end of the line of actual code like  print(1) # that prints 1
        text_lines_of_function_body <- dropcommentedlines(text_lines_of_function_body)
      }
      text_of_function_body <- paste0(text_lines_of_function_body, collapse = '\n')
      if (grepl(text, text_of_function_body)) {
        stops <- c(stops, this)}
    }
  }
  return(sort(stops))
}
##################################################################################### #

################# #    ################# #    ################# #    ################# #    ################# #


# recursive dependencies of a package ####

#' utility for developing package, see what pkgs it depends on, recursively (i.e., downstream ones too)
#' Reminder of ways to check this is printed to console.
#'
#' @param localpkg "EJAM" or another installed package
#'
#' @param depth would be used if using the deepdep package and function
#' @param ignores_grep would be used if using the deepdep package and function
#' @return NULL
#'
#' @keywords internal
#'
pkg_dependencies <- function(localpkg = "EJAM", depth = 6, ignores_grep = "0912873410239478") {

  #################### #

  cat(paste0("

  # Some notes on ways to see dependencies of a package like EJAM:

# x1 = renv::dependencies()
#
x2 = sort(packrat", ":::", "recursivePackageDependencies('",
             localpkg,
             "', lib.loc = .libPaths(), ignores = NULL))

# but note that https://rstudio.github.io/renv/articles/packrat.html explains that
# the renv package has replaced the packrat package
# But note Posit Connect does not seem to work with renv? it uses rsconnect etc.

# For example try this for the EJAM package:


# from root of source pkg:
x1 = renv::dependencies() ; x1 = unique(x1$Package)
x2 = sort(packrat:::recursivePackageDependencies('EJAM', lib.loc = .libPaths(), ignores = NULL))
x3 = attachment::att_from_rscripts()
x4 = attachment::att_from_examples()
x5 = attachment::att_from_description()
x6 = attachment::att_from_rmds()
xl = list(x1,x2,x3,x4,x5,x6)
names(xl) <- c('renv', 'packrat', 'rscripts', 'examples', 'desc', 'rmds')
print(sapply(xl, length))
length(setdiff(xl$renv, xl$packrat))
length(setdiff(xl$packrat, xl$rscripts))
length(intersect(xl$packrat, xl$rscripts))
length(setdiff(xl$rscripts, xl$packrat))


pkgs_needed = sort(packrat:::recursivePackageDependencies('EJAM', lib.loc = .libPaths(), ignores = NULL))
# shorter list because direct not all recursive, but provides rationale for each inference:
pkgs_needed_newerinfo = renv::dependencies()
pkgs_needed2 = sort(unique(pkgs_needed_newerinfo$Package))

pkgs_in_imports  = desc::desc_get('Imports',  file = system.file('DESCRIPTION', package='EJAM'))
pkgs_in_suggests = desc::desc_get('Suggests', file = system.file('DESCRIPTION', package='EJAM'))
cleanit = function(x) {
 x = gsub('\n', '', x)
 x = trimws(as.vector(unlist(strsplit(x, ','))))
 x = gsub(' .*', '', x)
 return(x)
}
pkgs_in_imports = cleanit(pkgs_in_imports)
pkgs_in_suggests = cleanit(pkgs_in_suggests)
pkgs_missing_from_desc_supposedly_needed = sort(setdiff(pkgs_needed, c(pkgs_in_imports, pkgs_in_suggests)))
pkgs_in_desc_supposedly_not_needed       = sort(setdiff(c(pkgs_in_imports, pkgs_in_suggests), pkgs_needed))

pkgs_missing_from_desc_supposedly_needed
pkgs_in_desc_supposedly_not_needed
setdiff(pkgs_needed2, pkgs_needed) # found by renv but not by packrat

 setdiff(setdiff(pkgs_needed2, pkgs_needed), pkgs_in_desc_supposedly_not_needed)
### e.g.,
#  [1] 'base' 'census2020download' 'EJAM' 'githubr' 'graphics' 'grDevices' 'parallel' 'plumber'
#  [9] 'roxygen2' 'rsconnect' 'stats' 'svglite' 'tools' 'utils'
setdiff(pkgs_in_desc_supposedly_not_needed, setdiff(pkgs_needed2, pkgs_needed))
### e.g.,
# [1] 'datasets' 'fipio' 'rnaturalearth' 'tidygeocoder'

# but should confirm these truly reflect what is actually needed and not needed
# for web app to work,
# functions used by analysts but not web app, and
# functions only used in maintaining the pkg!
pkgs_all = unique(c(pkgs_in_imports, pkgs_in_suggests, pkgs_needed))
pkgs_all_sizes = EJAM:::pkg_sizes(pkgs_all, quiet=T) # e.g., nearly 1 GB
# Largest packages:  (size of folder once installed)
cat(length(pkgs_all), ' packages appear to be needed.\n')
tail(pkgs_all_sizes, 15)


# and see EJAM:::find_transitive_minR() to see what version of R those collectively need at minimum
      "))



  #   cat(paste0("
  #
  #   # or if you have the deepdep package installed (it is not required by EJAM)...
  #
  # y = sort(
  #   unique(
  #     grep(
  #       '", ignores_grep, "',
  #       deepdep", "::", "deepdep(
  #         '", localpkg, "',
  #         local = TRUE,
  #         downloads = FALSE,
  #         depth = ", depth, "
  #       )$name,
  #       value = TRUE,
  #       invert = TRUE)
  #   )
  # )
  #
  #       "))
  #
  #   #################### #
  #
  #   cat("
  #
  # setdiff(x,y)
  # setdiff(y,x)
  #       ")
  #################### #

  ## report all dependencies and downstream ones etc.
  ## requires that packrat and deepdep packages be attached 1st:
  # x <- grep("asdfasdfasfasdfasdf", deepdep('EJAM', local = TRUE, downloads = FALSE, depth = 6)$name, value = TRUE, invert = TRUE)
  # y <- sort( packrat:::recursivePackageDependencies('EJAM', lib.loc = .libPaths(), ignores = NULL))
  # setdiff(y, x)
  # ## [1] "snow"
  ## for some reason this 1 package is identified as a dependency one way but not the other way

  invisible()
}
##################################################################################### #

#################### #  #################### #  #################### #

pkg_sizes = function(pkgs, quiet=FALSE) {

  get_directory_size <- function(path, recursive = TRUE) {
    # Ensure the provided path is a character string
    stopifnot(is.character(path))

    # List all files within the directory, including subdirectories if recursive is TRUE
    # full.names = TRUE ensures the full path is returned for each file
    files <- list.files(path, full.names = TRUE, recursive = recursive)

    # Get file information for all listed files
    # The 'size' column contains the size of each file in bytes
    file_details <- file.info(files)

    # Sum the sizes of all files to get the total directory size
    total_size <- sum(file_details$size, na.rm = TRUE)
    return(total_size / 1e6)
  }

  x = vector(length = length(pkgs))
  for (i in seq_along(pkgs)) {
    loc <- try(find.package(pkgs[i])[1], silent = TRUE)
    if (inherits(loc, "try-error")) {
      x[i] <- NA
    } else {
      x[i] <- get_directory_size(loc)
    }
    if (!quiet) {
      cat(paste0(i, "/", length(pkgs), " ", pkgs[i], " size = ", round(x[i], 2), " MB\n"))
    }
  }
  y = data.frame(meg = round(x, 3), pkg = pkgs)
  cat("\n\nTOTAL: ", round(sum(y$meg, na.rm = TRUE), 1), "MB in ", length(y$meg)," packages. \n\n")
  y = y[order(-y$meg), ]
  rownames(y) <- NULL
  y = y[order(y$meg), ]
  return(y)

  # # Save directory
  # save.dir = "F:/CRANMirror"
  #
  # # Create a directory to store package .tar.gz
  # dir.create(save.dir)
  #
  # # Obtain a list of packages
  # pkgs = available.packages()[,'Package']
  #
  # # Download those packages
  # download.packages(pkgs = pkg$package.list, destdir = save.dir)
  # pkg.files = list.files(save.dir)
  # pkg.sizes = round(file.size(file.path(save.dir,pkg.files))/ 1024^2,2) # Convert to MB from Bytes
}

# x = pkg_sizes(pkgs_all )

#################### #  #################### #  #################### #

# REPORT WHAT R VERSION IS ALREADY THE MINIMUM REQUIREMENT ACROSS THE PACKAGE EJAM DEPENDS UPON?

## based on https://www.r-bloggers.com/2022/09/minimum-r-version-dependency-in-r-packages/

pkg_dependencies_min_R <- function(package = 'EJAM', recursive_deps = NULL) {

  db <- tools::CRAN_package_db()

  if (is.null(recursive_deps)) {

    if (package == "EJAM") {
      msg = paste0("Try this after installing the packrat package:
    recursive_deps <- packrat",
                   ":::",
                   "recursivePackageDependencies('EJAM', lib.loc = .libPaths(), ignores = NULL)

                 find_transitive_minR(recursive_deps = recursive_deps)"
      )
      cat(msg, "\n\n")
      stop("EJAM package does not require packrat so you might need to install that separately")
    } else {
      recursive_deps <- tools::package_dependencies(
        package = package,
        recursive = TRUE,
        db = db
      )[[1]]
    }
  }

  # These code chunks are detailed below in the 'Minimum R dependencies in CRAN
  # packages' section
  r_deps <- db |>
    dplyr::filter(Package %in% recursive_deps) |>
    # We exclude recommended pkgs as they're always shown as depending on R-devel
    dplyr::filter(is.na(Priority) | Priority != "recommended") |>
    dplyr::pull(Depends) |>
    strsplit(split = ",") |>
    purrr::map(~ grep("^R ", .x, value = TRUE)) |>
    unlist()

  r_vers <- trimws(gsub("^R \\(>=?\\s(.+)\\)", "\\1", r_deps))

  return(max(package_version(r_vers)))
}
############################ #

# is a package loaded or just installed or not even installed?

# also see  EJAM:::pkg_dir_installed()

pkg_available <- function(pkg,
                          if_not_installed = c("stop", "warning", "message", "cat")[2],
                          if_not_loaded = c("stop", "warning", "message", "cat")[2]
                          # ,if_not_attached =  c("stop", "warning", "message", "cat")[2]
) {

  stopifnot(!missing(pkg), !is.null(pkg), length(pkg) == 1)
  stopifnot(length(if_not_installed) == 1, if_not_installed %in% c("stop", "warning", "message", "cat"),
            length(if_not_loaded) == 1, if_not_loaded %in% c("stop", "warning", "message", "cat")
            # ,length(if_not_attached) == 1, if_not_attached %in% c("stop", "warning", "message", "cat")
  )

  installed <- !inherits(try(find.package(pkg), silent = TRUE), "try-error")
  loaded <- isNamespaceLoaded(pkg)
  # attached <- paste0("package:", pkg) %in% search()

  ## isNamespaceLoaded()  checks if loaded but does not check if also attached.
  ##  if library() or require() has been used, it will be both loaded and attached.
  ##  A package that is loaded by EJAM even though not attached is still available for use by functions,
  ##  so being loaded should be sufficient even if not attached.

  # if (!attached) {
  #   msg <- paste0(pkg, " package is needed here but is not attached")

  if (loaded) {

    return(TRUE)

  } else {
    # msg <- paste0(pkg, " package is needed here but is not loaded")

    if (!installed) {
      msg <- paste0(pkg, " package is needed for this but does not appear to be installed \n")
      get(if_not_installed)(msg) # stop or warning or message or cat()

      return(FALSE)

    } else {
      msg <- paste0(pkg, " package must be loaded for this and appears to be installed but not loaded. Try using library(", pkg,") or require(", pkg,") \n")
      get(if_not_loaded)(msg) # stop or warning or message or cat()

      return(FALSE)
    }
  }
}
############################ #
