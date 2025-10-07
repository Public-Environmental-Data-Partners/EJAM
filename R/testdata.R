

#' utility to show dir_tree of available files in testdata folders
#' See list of samples of input files to try in EJAM, and output examples from EJAM functions
#'
#' @param installed If you are a developer who has the local source package,
#' you can set this parameter to FALSE if you want to work with the
#' local source package version of the testdata folders
#' rather than the locally installed version.
#' @param pattern optional query regular expression, used as filter using when getting filenames
#' @param quiet set TRUE if you want to just get the path
#'   without seeing all the info in console and without browsing to the folder
#' @param folder_only set TRUE to get only directories, no files
#' @return path to local testdata folder comes with the EJAM package
#' @examples
#' testdata('shape', quiet = TRUE)
#' testdata('shape', quiet = T, folder_only=T)
#'
#' testdata("id", quiet = T)
#' testdata("id", quiet = T, folder_only=T)
#'
#' testdata('fips', quiet = T)
#' testdata('registryid', quiet = T)
#' testdata("address", quiet = T)
#'
#' # datasets as lazyloaded objects vs. files installed with package
#'
#' topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.
#'
#' # datasets / R objects
#' cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))
#'
#' # files
#' cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
#'
#' @keywords internal
#' @export
#'
testdata <- function(pattern = NULL, installed = TRUE, quiet = FALSE, folder_only = FALSE) {

  if (installed) {
    # testdata_folder <- system.file('testdata', package = 'EJAM')
    # text_to_print <- "system.file('testdata', package = 'EJAM')" # redundant
  }

  if (!installed && file.exists("DESCRIPTION")) {
    # testdata_folder <- "./inst/testdata"
    # text_to_print <-  '"./inst/testdata"' # redundant
  }
  if (!installed && !file.exists("DESCRIPTION")) {
    warning('testdata(installed = F) can only be used while working directory is the root of a source package - showing testdata(installed = T) instead')
    return(testdata(installed = TRUE, pattern = pattern, quiet = quiet, folder_only = folder_only))
  }

  # get path, but side effect is printing path in 3 formats, and prefer to show that after the tree
  info_to_print <- capture.output({
    testdata_folder <- testdatafolder(installed = installed, quiet = FALSE)
  })
  if (!quiet && interactive()) {
    # show the full tree folders structure:
    # want to show tree of relevant folders only, using regex if relevant
    cat('\n')

    fs::dir_tree(testdata_folder, recurse = 1, regex = pattern)
    ## *** It would not be very easy to replace dir_tree() to remove dependence on fs pkg
    ##    gets passed to dir_ls() which has a param recurse = FALSE DEFAULT!
    ##   recurse=1 means go down only 1 level, type can be "any", "file", "directory", glob or regexp can be used too

    cat("\n")
    # show the info captured (path shown 3 ways)
    cat(paste0(info_to_print, collapse = "\n"), '\n')
    # cat(text_to_print, '\n') # redundant
    # open file explorer to view the (overall) folder
    browseURL(normalizePath(testdata_folder[1]))
  }

  # filter to show all that matched pattern
  if (!is.null(pattern)) {
    matches <- fs::dir_ls(testdata_folder, regexp = pattern, ignore.case = TRUE, recurse = 1)
    # matches <- list.files(testdata_folder, pattern = pattern, ignore.case = TRUE, recursive = TRUE,
    ## Any gdb would show up as a useless long list of contents if you didn't limit recursion!
    ## *** fs pkg is useful since cant limit recurse to just 1 level down with base list.files()
    ##                       full.names = TRUE, include.dirs = TRUE)
  } else {
    matches <- testdata_folder
  }

  # make matches a simple vector not "fs_path" class vector
  #  (folders are not flagged in blue font this way but it is just simpler)
  matches <- as.vector(matches)

  if (folder_only) {matches <- matches[dir.exists(matches)]}

  return(matches)
}
######################################################### #

#' utility to show path to testdata folders
#' see folder that has samples of input files to try in EJAM, and output examples from EJAM functions
#'
#' @param pattern  optional query regular expression, used as filter using when getting dirnames.
#'   If NULL, returns only root testdata folder, otherwise matching subfolder(s)
#' @param installed If you are a developer who has the local source package,
#' you can set this parameter to FALSE if you want to work with the
#' local source package version of the testdata folders
#' rather than the locally installed version.
#' @param quiet whether to print info, but always TRUE if pattern is provided
#'
#' @return path(s) to local testdata folder(s) from the EJAM package
#' @examples
#' x = testdatafolder("shape" )
#' x
#' x["testdata" == basename(dirname(x))]
#'
#' #   Compare versions of the HTML summary report:
#'
#' fname = "examples_of_output/testoutput_ejam2report_10pts_1miles.html"
#' repo = "https://github.com/ejanalysis/EJAM"
#' \dontrun{
#' # in latest main branch on GH (but map does not render using this tool)
#' url_github_preview(file.path(repo, "blob/main/inst/testdata", fname))
#'
#' # from a specific release on GH (but map does not render using this tool)
#' url_github_preview(file.path(repo, "blob/v2.32.5/inst/testdata", fname))
#'
#' # local installed version
#' browseURL( system.file(file.path("testdata", fname), package="EJAM") )
#'
#' # local source package version in checked out branch
#' browseURL( file.path(testdatafolder(installed = F), fname) )
#' }
#'
#' @keywords internal
#' @export
#'
testdatafolder = function(pattern = NULL, installed = TRUE, quiet = FALSE) {

  if (!is.null(pattern)) {
    x = testdata(pattern = pattern, installed = installed, quiet = TRUE, folder_only = TRUE)
    return(x)
  }

  if (installed) {
    testdata_folder_shortcode_text <- "system.file('testdata', package = 'EJAM')"
    testdata_folder_shortcode_sourceable      <- "system.file('testdata', package = 'EJAM')"
  } else {
    testdata_folder_shortcode_text <- "'./inst/testpath'" # shortest
    testdata_folder_shortcode_sourceable      <- "file.path(getwd(), 'inst/testdata')" # or  "path.expand('./inst/testdata')" # just so source() returns './inst/testdata' )
  }
  testdata_folder <- source_this_codetext(testdata_folder_shortcode_sourceable)
  rpath <- gsub('\\\\', '/', normalizePath(testdata_folder)) # only needed if !installed but ok if installed

  if (!quiet) {
  cat('\n')
  cat('#  code that returns the path \n')
  cat(testdata_folder_shortcode_text, '\n')
  cat('\n')

  cat('#  the path as formatted by normalizePath() \n')
  print(normalizePath(testdata_folder))
  cat("\n")

  cat('#  the path in R format (also returned invisibly), shown here unquoted \n')
  cat(rpath, '\n')
  cat('\n')
}
  invisible(testdata_folder)
}
######################################################### #
