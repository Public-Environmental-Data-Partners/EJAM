
.ejam_cache <- new.env(parent = emptyenv())

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
    if (!exists("quaddata")) {
      cat(    "\n index cannot be created until quaddata is loaded ... Trying dataload_dynamic() ... \n")
      message("The index of Census blockgroups (localtree) cannot be created until quaddata is loaded. Trying dataload_dynamic()")
      dataload_dynamic("quaddata")
    }
    if (exists("quaddata")) {
      cat("Building index...")
      .ejam_cache$localtree <- SearchTrees::createTree(
        quaddata,
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
      cat("  Failed to load quaddata.\n")
      warning("indexblocks() failed because quaddata could not be loaded")
    }
  } else {
    cat('localtree already exists.\n')
  }
  invisible(.ejam_cache$localtree)
}
