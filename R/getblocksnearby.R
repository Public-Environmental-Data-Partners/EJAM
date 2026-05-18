#' Very fast way to distances to all nearby Census blocks
#'
#' @description
#'   Get distance from each site (e.g., facility) to each
#'   Census block centroid within some radius
#'
#'   Given a set of points and a specified radius,
#'   this function quickly finds all the US Census blocks near each point.
#'   For each point, it uses the specified radius distance and finds the distance to
#'   every block within the circle defined by the radius.
#'   Each block is defined by its Census-provided internal point, by latitude and longitude.
#'
#'   Each point can be the location of a regulated facility or other type of site, and
#'   the blocks are a high-resolution source of information about where
#'   residents live.
#'
#'   Finding which blocks have their internal points in a circle provides
#'   a way to quickly estimate what fraction of a blockgroup is
#'   inside the circular buffer more accurately and more quickly than
#'   areal apportionment of blockgroups would provide.
#'
#' @details
#'  See [ejamit()] for examples.
#'
#'  getblocksnearby() is a wrapper redirecting to the right version, like [getblocksnearbyviaQuadTree()]
#'    Census block "internal points" (defined by Census Bureau) are actually what it looks for,
#'    and they are like centroids.
#'    The blocks are pre-indexed for the whole USA, via the data object quadtree aka localtree
#'
#' @inheritParams getblocksnearbyviaQuadTree
#' @param ...  passed to [getblocksnearbyviaQuadTree()] or other such functions
#'
#' @return table in [data.table](https://r-datatable.com) format like testoutput_getblocksnearby_10pts_1miles, with
#'   columns named "ejam_uniq_id", "blockid", "distance", etc.
#'   The ejam_uniq_id represents which of the input sites is being referred to, and the table
#'   will only have the ids of the sites where blocks were found. If 10 sites were input but only sites 5 and 8
#'   were valid and had blocks identified, then the data.table here will only include ejam_uniq_id values of 5 and 8.
#'   This is like the output of  [get_blockpoints_in_shape()], or [getblocksnearby_from_fips()] if return_shp = FALSE.
#'
#' @seealso [ejamit()] [getblocksnearby_from_fips()] [get_blockpoints_in_shape()]
#'
#' @export
#'
getblocksnearby <- function(sitepoints, radius = 3, maxradius = 31.07, radius_donut_lower_edge = 0,
                             avoidorphans = FALSE,
                             quadtree = NULL,
                             quiet = FALSE,
                             use_unadjusted_distance = TRUE,
                             ...
) {
  ################################################################################## #
  # select file if missing
  if (missing(sitepoints)) {
    if (interactive()) {
      sitepoints <- rstudioapi::selectFile()
    } else {
      if (shiny::isRunning()) {
        warning("sitepoints (locations to analyze) is missing but required.")
        return(NULL)

      } else {
        stop("sitepoints (locations to analyze) is missing but required.")
      }
    }
  }
  # if user entered a table, path to a file (csv, xlsx), or whatever, then read it to get the lat lon values from there
  sitepoints <- latlon_from_anything(sitepoints)
  stopifnot(is.data.frame(sitepoints), "lat" %in% colnames(sitepoints), "lon" %in% colnames(sitepoints), NROW(sitepoints) >= 1, is.numeric(sitepoints$lat))
  ## that handles problems here in sitepoints.
  # Probably need stopifnot above since unclear what you should return otherwise.
  # But ok if any/orall lat and/or lon are NA values

  ################################################################################## #

  # timed <- system.time({
  if (missing(quadtree)) {
    if (!exists("quaddata") || !exists("blockwts") || !exists("blockpoints") ) {  #| !exists("bgid2fips")
      # should
      cat('census block data file(s) not already loaded, so key data will now be downloaded (or loaded from a local copy if possible)...\n')
      # loads quaddata needed to make localtree index, and several other large files pkg uses.

      dataload_dynamic(varnames = c('quaddata', 'blockwts', 'blockpoints')) # and blockid2fips and bgid2fips and bgej are available
    }
    quadtree <- indexblocks()
  }
  if (!quiet) {
    cat("Analyzing", NROW(sitepoints), "points, radius of", radius, "miles around each.\n")
  }
  ################################################################################## #
  # wrapper to make it simple to (possibly later) switch between functions to use for this, clustered vs not, etc.

    x <- getblocksnearbyviaQuadTree(sitepoints = sitepoints, radius = radius, maxradius = maxradius,
                                    radius_donut_lower_edge = radius_donut_lower_edge,
                                    avoidorphans = avoidorphans,
                                    use_unadjusted_distance = use_unadjusted_distance,
                                    quadtree = quadtree,
                                    quiet = quiet,
                                    ...)

  return(x)
}
