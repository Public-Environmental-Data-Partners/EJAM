
#' Utility to load a couple of datasets using data immediately instead of relying on lazy loading
#'
#' @details
#'  See also read_builtin() function from the readr package!
#'
#'  Default is to load some but not all the datasets into memory immediately.
#'   [blockgroupstats], [usastats], [statestats], and some others are always essential to EJAM.
#'   The FRS-related datasets are huge and are loaded separately as `.arrow`
#'   files with [dataload_dynamic()] only when needed.
#' @param olist vector of strings giving names of objects to load using data().
#'   This should be limited to package `.rda` datasets. FRS-related datasets
#'   are no longer `.rda` package data.
#' @param envir the environment into which they should be loaded
#' @return Nothing
#' @seealso [pkg_data()] [dataload_dynamic()] [dataload_from_local()] [indexblocks()] [.onAttach()]
#'
#' @inherit pkg_functions_and_data examples
#'
#' @keywords internal
#'
dataload_from_package <- function(olist = c("blockgroupstats", "usastats", "statestats"), envir=globalenv()) {

  # check if all of olist exist within the package as data!

  data(list = olist, package = "EJAM",
       envir = envir
  )

  # Obsolete: FRS tables are .arrow dynamic datasets loaded with
  # dataload_dynamic(), not package .rda data loaded with data().

  # get full path and name for data file in locally installed package?
  # system.file("/data/blockgroupstats.rda", package="EJAM")
  # this works on a local source package, only:
  # fullnames <- list.files('./data', pattern = '\\.rda$' , full.names = F)
  # f.rda <-
  #   oname <- gsub(".rda", "", f.rda)

  # Note:
  #  See also read_builtin() function from the readr package!
  #
  #   Use of data within a function without an envir argument has the
  # almost always undesirable side-effect of putting an object in the user's workspace
  # (and indeed, of replacing any object of that name already there).
  # It would almost always be better to put the object in the current evaluation environment
  # by data(..., envir = environment()). However, two alternatives are usually preferable, both described in the ‘Writing R Extensions’ manual.
  #
  # For sets of data, set up a package to use lazy-loading of data. (But that causes a delay when it is needed)
  #
  # For objects which are system data, for example lookup tables used in calculations within the function,
  #  use a file ‘R/sysdata.rda’ in the package sources
  #  or create the objects by R code at package installation time.
  #
  # A sometimes important distinction is that the second approach places objects in the namespace but the first does not.
  # So if it is important that the function sees mytable as an object from the package, it is system data and the second approach should be used.
}
