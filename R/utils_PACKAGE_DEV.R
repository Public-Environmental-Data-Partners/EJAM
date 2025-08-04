
# Functions related to managing the EJAM package, names of its functions and datasets, etc.



# GET FUNCTIONS, DATA, SOURCEFILES, ETC. ####

##################################################################################### #
# . ####
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
#' @param exportedfuncs_included default TRUE includes exported functions (non-datasets, actually) in the list
#' @param data_included default TRUE includes datasets in the list, as would be seen via data(package=pkg)
#' @param vectoronly set to TRUE to just get a character vector of object names instead of the data.frame table output
#' @seealso [ls()] [getNamespace()] [getNamespaceExports()] [loadedNamespaces()]
#'
#' @return data.table with colnames object, exported, data  where exported and data are 1 or 0 for T/F,
#'   unless vectoronly = TRUE in which case it returns a character vector
#' @examples  # pkg_functions_and_data("datasets")
#'
#' @keywords internal
#'
pkg_functions_and_data <- function(pkg = "EJAM",
                                   alphasort_table = FALSE,
                                   internal_included = TRUE,
                                   exportedfuncs_included = TRUE,
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

  exported_plus_internal_withdata <- function(pkg) {sort(union(dataonly(pkg), ls(getNamespace(pkg), all.names = TRUE)))} # all.names filters those starting with "."
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
    y <- y[y$data == 0, ]
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
#' @param sortbysize if TRUE (and simple=F),
#'   sort by increasing size of object, within each package, not alpha.
#' @param simple FALSE to get object sizes, etc., or
#'    TRUE to just get names in each package, like
#'    `data(package = "EJAM")$results[, c("Package", 'Item')]`
#' @return If simple = TRUE, data.frame with colnames Package and Item.
#'   If simple = FALSE, data.frame with colnames Package, Item, size, Title.Short
#' @examples
#'  # see just a vector of the data object names
#'  data(package = "EJAM")$results[, 'Item']
#'
#'  # not actually sorted within each pkg by default
#'  pkg_data()
#'  # not actually sorted by default
#'  pkg_data("EJAM")$Item
#'  ##pkg_data("MASS", simple=T)
#'
#'  # sorted by size if simple=F
#'  ##pkg_data("datasets", simple=F)
#'  x <- pkg_data(simple = F)
#'  # sorted by size already, to see largest ones among all these pkgs:
#'  tail(x[, 1:3], 20)
#'
#'  # sorted alphabetically within each pkg
#'  x[order(x$Package, x$Item), 1:2]
#'  # sorted alphabetically across all the pkgs
#'  x[order(x$Item), 1:2]
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

# # utility to get the filename where a function is defined PLUS other info
# #
# # @details returns NA where there are special characters like %, and
# #   maybe returns NA if e.g., function is defined as equal to / alias of another function,
# #   like askradius <- ask_number where ask_number = function() {}
# #
pkg_functions_and_sourcefiles <- function(pkg = "EJAM",
                                          alphasort_table = FALSE, # or use TRUE here?
                                          internal_included = TRUE,
                                          exportedfuncs_included = TRUE,
                                          data_included = FALSE, # or use FALSE here?
                                          vectoronly = FALSE,
                                          loadagain = TRUE, quiet = FALSE) {

  info <- pkg_functions_and_data(pkg = pkg, internal_included = internal_included, exportedfuncs_included = exportedfuncs_included,
                                 data_included = data_included, alphasort_table = alphasort_table, vectoronly = vectoronly)
  if (vectoronly) {
    funcnames <- info
  } else {
    funcnames <- info$object
  }
  if (basename(getwd()) != pkg) {stop("working directory must be the source package folder for pkg", pkg)}
  x <- pkg_functions_with_keywords_internal_tag(loadagain = loadagain, quiet = quiet) # DOES load_all() again if loadagain==TRUE
  fnames <- x$func
  fnames <- x$file[match(funcnames, fnames)] # match to ensure same order as info$object, but check how extra or missing ones are handled
  if (vectoronly) {
    return(fnames)
  } else {
    return(data.frame(file = fnames, info))
  }
}
##################################################################################### #

# rough notes on draft quick look for file names???

pkg_functions_and_sourcefiles2 <- function(funcnames, pkg = "EJAM", full.names = TRUE) {

  # get R/*.R FILENAME that defines each function
  if (missing(funcnames)) {fnames <- pkg_functions_and_sourcefiles(pkg = pkg)$object}

  fnames <- paste0(pkg, ":::", vector(length = length(funcnames)))
  for (i in seq_along(funcnames)) {
    funcname <- funcnames[i] # funcname <- "pkg_data"
    cat(paste0(funcname, ", "))
    # findInFiles::fifR(pattern = paste0("^ *", funcname, ".*function[(]"), output = "tibble")$file
    found <- try({parse(text = funcname)}, silent = TRUE) # catch specials like  %||%
    if (inherits(found, "try-error") || length(found) == 0) {
      fnames[i] <- NA
    } else {
      found <- try({getSrcFilename(eval(found), full.names = full.names)}, silent = TRUE)
      if (inherits(found, "try-error") || length(found) == 0) {fnames[i] <- NA} else {fnames[i] <- found}
    }
  }
  cat("\n")
  return(fnames)
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

pkg_functions_with_keywords_internal_tag <- function(package.dir = ".", loadagain = TRUE, quiet = FALSE) {

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
  packages <- roxygen2:::roxy_meta_get("packages")
  lapply(packages, loadNamespace)
  if (loadagain) {
    load_code <- roxygen2:::find_load_strategy(load_code)
    env <- load_code(base_path) # slow step
  } else {
    env = globalenv()
  }
  roxygen2:::local_roxy_meta_set("env", env)

  blocks <- roxygen2:::parse_package(base_path, env = NULL)  # slow step

  results <- list()
  i <- 0

  for (block in blocks) {

    i <- i + 1
    # block <- blocks[[671]]
    # block <- blocks[[1]]

    object_name <- roxygen2:::block_get_tag_value(block, 'name')
    if (is.null(object_name) || length(object_name) == 0 || any(is.na(object_name))) {
      object_name <- NA
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
    tags <- roxygen2:::block_get_tags(block, "keywords")

    if (length(tags) == 0) {
      if (!quiet) {cat(' \n')}
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
      if (!quiet) {cat(keywordval, "\n")}
    }

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

  return(results)
  # return(list(blocks = blocks, results = results) ) # for troubleshooting
}
##################################################################### #

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
#' obsolete since EJAMejscreenapi phased out? was used by pkg_dupenames() to check different versions of function with same name in 2 packages
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
  ### or
  # pkg_dupenames(c("proxistat", "EJAMejscreenapi"), compare.functions = T)
  # Error in pkg_functions_all_equal(fun = var, package1 = ddd$package[ddd$variable ==  :
  #                                                                   distances.all not found in proxistat
  #                                                                Called from: pkg_functions_all_equal(fun = var, package1 = ddd$package[ddd$variable ==

  if (!(is.character(fun) & is.character(package1) & is.character(package2))) {
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

  x <- (TRUE == all.equal(body(f1), body(f2))) & (TRUE == all.equal(formals(f1), formals(f2)))
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
#'
#' @return vector of names of functions or paths to .R files
#'
#' @keywords internal
#'
pkg_functions_that_use <- function(text = "stop\\(", pkg = "EJAM", ignore_comments = TRUE) {


  if (grepl("\\(", text) & !grepl("\\\\\\(", text)) {warning('to look for uses of stop(), for example, use two slashes before the open parens, etc. as when using grepl()')}

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
    if (ignore_comments == FALSE) {warning('always ignores commented lines when checking exported functions of an installed package')}
    for (this in getNamespaceExports(pkg)) {

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

  # This may be useful to see dependencies of a package like EJAM:

x = sort(packrat", ":::", "recursivePackageDependencies('",
             localpkg,
             "', lib.loc = .libPaths(), ignores = NULL))

x
      "))

  #################### #

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
