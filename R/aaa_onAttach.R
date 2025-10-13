
#' Set up EJAM (do slow initialization steps when package is attached)
#'
#' Download datasets, load to memory, index block locations
#'
#' @details This uses [dataload_dynamic()] and [indexblocks()]
#'
#' This function `.onAttach()` gets run when the package EJAM is attached,
#' which happens when library(EJAM) or require(EJAM) is used.
#' And if [devtools::load_all()] is used, which might mean it loads un-updated local copies
#' rather than the updated source copies in EJAM/data/ but presumably load_all() then replaces those by reading all from /data/
#'
#' This code would not get run if a server ran app.R as a regular shiny app (because of _disable_autoload.R ?)
#' and just used dataload or source to read the /R/*.R source files
#' rather than loading and attaching the EJAM package. see app.R   ***
#'
#' @param libname na
#' @param pkgname na
#'
#' @noRd
#'
.onAttach <- function(libname, pkgname) {

  # These instead could be set in the golem-config.yml file

  asap_download   <- TRUE  # download large datasets now?      Set to FALSE while Testing/Building often
  asap_index <- TRUE  # build index those now?                 Set to FALSE while Testing/Building often
  asap_bg    <- FALSE  # load now vs lazyload blockgroup data? Set to FALSE while Testing/Building often

  # startup msg shown at library(EJAM) or when reinstalling from source ####
  packageStartupMessage("Now running .onAttach(), as part of attaching the EJAM package.")

  #################### #
  packageStartupMessage("Reading global_defaults_package.R")
  # get location of logo etc. so that ejam2report() using generate_html_header() can find logo  even without launching shiny app
  ## notloaded <- inherits(try( path.package("EJAM") , silent = TRUE), "try-error")
  notloaded_and_notinstalled <- inherits(try( find.package("EJAM") , silent = TRUE), "try-error")
  if (notloaded_and_notinstalled) {
    packageStartupMessage("EJAM package must be installed or at least loaded from source already for .onAttach() to be able to use system.file(package = 'EJAM') \n")
    # try using local source package folders
    localpath <- file.path('./inst/global_defaults_package.R')
    if (!file.exists(localpath)) {
      packageStartupMessage("Cannot find", localpath, "to create global_defaults_package object\n")
    } else {
      junk = try(source(localpath))
      if (inherits(junk, "try-error")) {
        packageStartupMessage("Cannot source", localpath, "to create global_defaults_package object\n")
      }
    }
  } else {
  localpath <- system.file("global_defaults_package.R", package = "EJAM")
  # if you have just used devtools::load_all(), then this will find and try to the local source version of the global_defaults_package.R
  # if you have not done that, this will find and use the installed version.
  # It will source the file in the global environment by using local=FALSE
  # BUT, when this tries to source that .R file during .onAttach(), R has not yet attached all the .R files ?
  if (!file.exists(localpath)) {
    packageStartupMessage("EJAM package is installed or loaded but cannot find file at", localpath, "\n")
  } else {
    packageStartupMessage("Trying to source a local source code copy from ", localpath, " \n")
  }
  junk1 = try({
    source(localpath, local = FALSE)
    }, silent = TRUE)
  if (file.exists(localpath) && inherits(junk1, "try-error")) {
    packageStartupMessage("in .onAttach() -- Unable to do
    source(system.file('global_defaults_package.R', package = 'EJAM')
    ")
    # localpath <- system.file('inst/global_defaults_package.R', package = 'EJAM') # system.file() does not like starting with inst/
    localpath <- file.path(dirname(system.file(package = "EJAM")), "inst", "global_defaults_package.R")
    packageStartupMessage("Trying to source a local source code copy from ", localpath, " \n")
    junk2 = try(source(localpath), silent = TRUE)
    if (inherits(junk2, "try-error")) {
      packageStartupMessage("Cannot source", localpath, "to create global_defaults_package object\n")
      warning(paste0("
    Problem in .onAttach() -- Unable to create global_defaults_package object because cannot do
       source(system.file('global_defaults_package.R', package = 'EJAM'))
       or
       source(system.file('inst/global_defaults_package.R', package = 'EJAM')

    ", junk2, "
    Try (re)installing the package from source -- see guide on installing.
    Some functions are referred to in the file global_defaults_package.R
    while the package is loaded as with devtools::load_all(),
    but if those functions are new or got renamed to a new name
    then they may not be recognized while first trying to attach the package.
    Some functions can be used to generate URLs for reports like url_echo_facility() and
    if they are listed in the default_reports setting defined in global_defaults_package.R,
    they cause .onAttach() to fail if those functions are not yet recognized."))
    }
  }
  }
  rm(notloaded_and_notinstalled)
  #################### #

  # download BLOCK (not blockgroup) data, etc ####

  if (asap_download) {

    if (length(try(find.package("EJAM", quiet = T))) == 1) { # if it has been installed. but that function has to have already been added to package namespace once
      dataload_dynamic(varnames = c("blockpoints", "blockwts", "quaddata"),
                         folder_local_source = app_sys('data'),
                         onAttach = TRUE) # use default local folder when trying dataload_from_local()
      # EJAM function ... but does it have to say EJAM :: here? trying to avoid having packrat see that and presume EJAM pkg must be installed for app to work. ***
    }

    #################### #
    #   blockid2fips was used only in  state_from_blockid(), which is no longer used by testpoints_n(),
    #     so not loaded unless/until needed.
    #     Avoids loading the huge file "blockid2fips" (100MB) and just uses "bgid2fips" (3MB) as needed, that is only 3% as large in memory.
    #     blockid2fips was roughly 600 MB in RAM because it stores 8 million block FIPS as text.
    ######################### #
  }

  # create index of all US block points, to enable fast queries ####

  if (asap_index) {

    if (length(try(find.package("EJAM", quiet = T))) == 1) { # if it has been installed. but that function has to have already been added to package namespace once

      indexblocks()   # EJAM function works only AFTER shiny does load all/source .R files or package attached
    }
  }

  # load blockgroupstats etc. from package? ####
  ## This only makes sense if they cannot be lazyloaded (impossible since .onAttach() is running?),
  ##  or if you want to preload them to avoid a user waiting for them to load when they are needed,
  ##  but lazyloading blockgroupstats and statestats and usastats should be pretty fast and forcing data()
  ##  to happen here is a bit slow if you have to reload the pkg many times like when iterating, building documentation etc.
  ##  And it slightly delays the shiny app launch.

  if (asap_bg) {

    if (length(try(find.package("EJAM", quiet = T))) == 1) { # The first time you try to install the package, it will not have access to EJAM :: etc. !

      dataload_from_package() # EJAM function works only AFTER shiny does load all/source .R files or package attached
    }

    # load BLOCKGROUP (not block) data (EJSCREEN data), etc. from package
    # see ?dataload_from_package()
    # This loads some key data, while others get lazy loaded if/when needed.
    # data(list=c("blockgroupstats", "usastats", "statestats"), package="EJAM")
    # # would work after package is installed
    # data(list=c("frs", "frs_by_programid ", "frs_by_naics"),  package="EJAM")
    # # would be to preload some very large ones not always needed.
  }
  options(tigris_use_cache = TRUE)

  packageStartupMessage('For help using the EJAM package in RStudio:
                          ?EJAM
                        To launch shiny app locally:
                          ejamapp()
                        ')

}
