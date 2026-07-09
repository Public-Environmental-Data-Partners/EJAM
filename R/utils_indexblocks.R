
.ejam_cache <- new.env(parent = emptyenv())

ejam_cached_data_exists <- function(name) {
  exists(name, envir = .ejam_cache, inherits = FALSE) ||
    exists(name, inherits = TRUE) ||
    exists(name, envir = globalenv(), inherits = FALSE)
}

ejam_cached_data_get <- function(name) {
  if (exists(name, envir = .ejam_cache, inherits = FALSE)) {
    return(get(name, envir = .ejam_cache, inherits = FALSE))
  }
  if (exists(name, inherits = TRUE)) {
    return(get(name, inherits = TRUE))
  }
  if (exists(name, envir = globalenv(), inherits = FALSE)) {
    return(get(name, envir = globalenv(), inherits = FALSE))
  }

  dataload_dynamic(name)

  if (exists(name, envir = .ejam_cache, inherits = FALSE)) {
    return(get(name, envir = .ejam_cache, inherits = FALSE))
  }
  if (exists(name, inherits = TRUE)) {
    return(get(name, inherits = TRUE))
  }
  if (exists(name, envir = globalenv(), inherits = FALSE)) {
    return(get(name, envir = globalenv(), inherits = FALSE))
  }

  stop("Unable to load required EJAM dataset: ", name, call. = FALSE)
}

localtree_exists <- function() {
  exists("localtree", envir = .ejam_cache, inherits = FALSE)
}

localtree_get <- function() {
  if (!localtree_exists()) {
    indexblocks()
  }
  .ejam_cache$localtree
}

#' Create localtree (a quadtree index of all US block centroids) in package cache
#'
#' @details Note this is duplicated code in .onAttach() and also in global_defaults_*.R
#'
#'    .onAttach() can be edited to create this when the package loads,
#'   but then it takes time each time a developer rebuilds/installs the package or others that load EJAM.
#'
#' It also has to happen in global_defaults_*.R if it has not already.
#' @return Returns the quadtree index invisibly. Side effect is it creates the
#'   index in the package cache.
#'
#' @export
#'
indexblocks <- function() {

  cat("Checking for index of Census blocks called 'localtree' ...")
  if (!localtree_exists()) {
    cat('not found...')
    if (!ejam_cached_data_exists("quaddata")) {
      cat(    "\n index cannot be created until quaddata is loaded ... Trying dataload_dynamic() ... \n")
      message("The index of Census blockgroups (localtree) cannot be created until quaddata is loaded. Trying dataload_dynamic()")
    }
    quaddata_now <- ejam_cached_data_get("quaddata")
    cat("Building index...")
    .ejam_cache$localtree <- SearchTrees::createTree(
      quaddata_now,
      treeType = "quad",
      dataType = "point"
    )
    if (localtree_exists()) {
      cat("  Done building index.\n")
    } else {
      cat("  Failed to build index.\n")
      warning("indexblocks() failed to build index of Census blocks, 'localtree' ")
    }
  } else {
    cat('localtree already exists.\n')
  }
  invisible(.ejam_cache$localtree)
}
