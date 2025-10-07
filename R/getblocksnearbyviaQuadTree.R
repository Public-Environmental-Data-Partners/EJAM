

#' Fast way to find nearby points (distance to each Census block centroid near each site)
#'
#' @description This is what [getblocksnearby()] uses to do the work.
#'   Given a set of points and a specified radius in miles,
#'   this function quickly finds all the US Census blocks near each point.
#'   This does the work actually supporting getblocksnearby()
#'
#' @details
#'   For each point, it uses the specified search radius and finds the distance to
#'   every block within the circle defined by the radius.
#'   Each block is defined by its Census-provided internal point, by latitude and longitude.
#'
#'   Results are the sites2blocks table that would be used by doaggregate(),
#'   with distance in miles as one output column of data.table.
#'   Adjusts distance to avg resident in block when it is very small relative to block size,
#'   the same way EJSCREEN adjusts distances in creating proximity scores.
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
#' @param sitepoints data.table with columns lat, lon giving point locations of sites or facilities around which are circular buffers
#' @param radius in miles, defining circular buffer around a site point
#' @param radius_donut_lower_edge radius of lower edge of ring if analyzing ring not full circle
#' @param maxradius miles distance (max distance to check if not even 1 block point is within radius)
#' @param avoidorphans MAY BE OBSOLETE/UNUSED NOW.
#'   logical If TRUE, then where not even 1 BLOCK internal point is within radius of a SITE,
#'   it keeps looking past radius, up to maxradius, to find nearest 1 BLOCK.
#'   What EJSCREEN does in that case is report NA, right? So,
#'   does EJAM really need to report stats on residents presumed to be within radius,
#'    if no block centroid is within radius?
#'   Best estimate might be to report indicators from nearest block centroid which is
#'   probably almost always the one your site is sitting inside of,
#'   but ideally would adjust total count to be a fraction of blockwt based on
#'   what is area of circular buffer as fraction of area of block it is apparently inside of.
#'   Setting this to TRUE can produce unexpected results, which will not match EJSCREEN numbers.
#'
#'   Note that if creating a proximity score, by contrast, you instead want to find nearest 1 SITE if none within radius of this BLOCK.
#' @param quadtree (a pointer to the large quadtree object)
#'    created using indexblocks() which uses the SearchTree package.
#'    Takes about 2-5 seconds to create this each time it is needed.
#'    It can be automatically created when the package is attached via the .onAttach() function
#' @param report_progress_every_n Reports progress to console after every n points,
#'   mostly for testing, but a progress bar feature might be useful unless this is super fast.
#' @param quiet Optional. set to TRUE to avoid message about using getblock_diagnostics(),
#'   which is relevant only if a user saved the output of this function.
#' @param use_unadjusted_distance logical, whether to find points within unadjusted distance
#' @param retain_unadjusted_distance set to FALSE to drop it and save memory/storage. If TRUE,

#'   the distance_unadjusted column will save the actual distance of site to block internal point
#'   -- the distance column always represents distance to average resident in the block, which is
#'   estimated by adjusting the site to block distance in cases where it is small relative to the
#'   size of the block, to put a lower limit on it, which can result in a large estimate of distance
#'   if the block is very large. See EJSCREEN documentation.
#' @param updateProgress, optional function to update Shiny progress bar
#'
#' @examples
#'   # indexblocks() # if localtree not available yet, quadtree = localtree
#'   x = getblocksnearby(testpoints_1000, radius = 3)
#' @seealso [ejamit()] [getblocksnearby()]
#' @import data.table
#'
#' @export
#' @keywords internal
#'
getblocksnearbyviaQuadTree  <- function(sitepoints, radius = 3, radius_donut_lower_edge = 0, maxradius = 31.07, avoidorphans = FALSE,
                                        report_progress_every_n = 500, quiet = FALSE,
                                        use_unadjusted_distance = FALSE,
                                        retain_unadjusted_distance = TRUE,
                                        quadtree, updateProgress = NULL) {

  # indexgridsize was defined at start as say 10 miles in global? could be passed here as a parameter
  # and buffer_indexdistance defined here in code but is never used anywhere...
  # buffer_indexdistance <- ceiling(radius / indexgridsize)
  ########################################################################### ##
  # Validate inputs ####

  if (missing(sitepoints)) {
    if (shiny::isRunning()) {
      warning("sitepoints missing - see getblocksnearby()")
      return(NULL)
    } else {
      stop("sitepoints missing - see getblocksnearby()")
    }
  }
  stopifnot(is.data.frame(sitepoints), "lat" %in% colnames(sitepoints), "lon" %in% colnames(sitepoints), NROW(sitepoints) >= 1, is.numeric(sitepoints$lat))
  if (missing(quadtree)) {
    if (shiny::isRunning()) {
      warning("quadtree=localtree is missing - see getblocksnearby() and indexblocks()")
      return(NULL)
    } else {
      stop("quadtree=localtree is missing - see getblocksnearby() and indexblocks()")
    }
  }
  if (!is(quadtree,"QuadTree")) {
    if (shiny::isRunning()) {
      warning('quadtree must be an index created with indexblocks() or indexpoints(pts), from SearchTrees package with treeType = "quad" and dataType = "point"')
      return(NULL)
    } else {
      stop('quadtree must be an index created with indexblocks() or indexpoints(pts), from SearchTrees package with treeType = "quad" and dataType = "point"')
    }
  }
  if (missing(radius)) {warning("radius missing so using default radius of 3 miles")}
  stopifnot(is.numeric(radius), radius <= 100, radius >= 0, length(radius) == 1,
            is.numeric(radius_donut_lower_edge), radius_donut_lower_edge <= 100, radius_donut_lower_edge >= 0, length(radius_donut_lower_edge) == 1)
  if (radius_donut_lower_edge > 0 && radius_donut_lower_edge >= radius) {stop("radius_donut_lower_edge must be less than radius")}
  if (!data.table::is.data.table(sitepoints)) {data.table::setDT(sitepoints)} # should we set a key or index here, like ? ***
  ########################################################################### ##
  # ejam_uniq_id ####
  if (!("ejam_uniq_id" %in% names(sitepoints))) {
    sitepoints$ejam_uniq_id <- seq.int(length.out = NROW(sitepoints))
  }
  ########################################################################### ##
  # pass in a list of uniques and the surface radius distance
  ## >filter na values? or keep length of out same as input? *** ####
  # sitepoints <- sitepoints[!is.na(sitepoints$lat) & !is.na(sitepoints$lon), ] # perhaps could do this by reference to avoid making a copy

  # TRANSFORM COORDINATES OF SITES ####

  earthRadius_miles <- 3959 # in case it is not already in global envt
  radians_per_degree <- pi / 180
  truedistance <- distance_via_surfacedistance(radius)
  nRowsDf <- NROW(sitepoints)
  if (!quiet) {
    cat("Finding Census blocks with internal point within ", radius," miles of the site (point), for each of", nRowsDf," sites (points)...\n")
  }

  lat_rad <- sitepoints$lat * radians_per_degree
  lon_rad <- sitepoints$lon * radians_per_degree
  FAC_X <- earthRadius_miles * cos(lat_rad) * cos(lon_rad)
  FAC_Y <- earthRadius_miles * cos(lat_rad) * sin(lon_rad)
  FAC_Z <- earthRadius_miles * sin(lat_rad)

  ########################################################################### ##
  ########################################################################### ##

  # LOOP OVER SITES ####

  res <- lapply(1:nRowsDf, FUN = function(a) {

    ### * FAST SEARCH - WHICH BLOCKS ARE APPROX NEARBY ####

    vec <- SearchTrees::rectLookup(localtree,
                                   xlims = FAC_X[a] + c(-1,1) * truedistance,
                                   ylims = FAC_Z[a] + c(-1,1) * truedistance
    )
    tmp <- quaddata[vec,]

    ### * EXACT DISTANCE TO EACH BLOCK  ####

    distances <- as.numeric(
      pdist::pdist(
        tmp[ , .(BLOCK_X, BLOCK_Y, BLOCK_Z)],
        c(FAC_X[a], FAC_Y[a], FAC_Z[a]))@dist
    )
    # add the distances and ejam_uniq_id to the table of nearby blocks
    tmp[ , distance := distances]      # converts distances dt into a vector that becomes a column of tmp
    tmp[, ejam_uniq_id := sitepoints[a, .(ejam_uniq_id)]]

    ### progress bar ####
    ## could add check that data has enough points to show increments with rounding ***
    ## i.e. if 5% increments, need at least 20 points or %% will return NaN
    if (((a %% report_progress_every_n) == 0) & interactive()) {cat(paste("Finished finding blocks near ",a ," of ", nRowsDf),"\n" ) }   # i %% report_progress_every_n indicates i mod report_progress_every_n (“i modulo report_progress_every_n”)
    pct_inc <- 5
    if (is.function(updateProgress) & (nRowsDf >= (100/pct_inc)) & (a %% round(nRowsDf/(100/pct_inc)) < 1)) {
      boldtext <- paste0((pct_inc)*round((100/pct_inc*a/nRowsDf)), '% done')
      updateProgress(message_main = boldtext, value = round((pct_inc)*a/nRowsDf,2)/(pct_inc))
    }

    return(tmp[, .(blockid, distance, ejam_uniq_id)])
  }) # end loop over sites
  ########################################################################### ##

  # Max allowed count of blocks ####
  if (sum(sapply(res, nrow)) > 2100000000) {
    shiny::validate(
      need(FALSE, "The analysis found too many nearby Census blocks and was interrupted. Please use a smaller radius or analyze fewer points at once.")
    )
  }
  # Compile as data.table ####

  sites2blocks <- data.table::rbindlist(res)
  data.table::setkey(sites2blocks, blockid, ejam_uniq_id, distance)
  ########################################################################### ##
  ########################################################################### ##

  # ADJUST DISTANCES ####

  ## if adjusting very short distances -- only if use_unadjusted_distance = FALSE  ####

  if (!quiet) {
    cat('Stats via getblocks_diagnostics(), but NOT ADJUSTING UP FOR VERY SHORT DISTANCES: \n')
    cat("min distance before adjustment: ", min(sites2blocks$distance, na.rm = TRUE), "\n")
    cat("max distance before adjustment: ", max(sites2blocks$distance, na.rm = TRUE), "\n\n")
    #getblocks_diagnostics(sites2blocks) # returns NA if no blocks nearby
  }

  # distance can get adjusted to a minimum possible value,  0.9 * effective radius of block_radius_miles (see EJSCREEN Technical Documentation discussion of proximity analysis for rationale)
  # See notes in the file EJAM/data-raw/datacreate_blockwts.R
  # use block_radius_miles here, to correct the distances that are small relative to a block size.
  # This adjusts distance the way EJSCREEN does for proximity scores - so distance reflects distance of sitepoint to avg resident in block
  # (rather than sitepoint's distance to the block internal point),
  # including e.g., where distance to block internal point is so small the site is inside the block.
  # This also avoids infinitely small or zero distances.
  ## if retain_unadjusted_distance ####
  if (retain_unadjusted_distance) {
    sites2blocks[ , distance_unadjusted := distance] # wastes space but for development/ debugging probably useful
    sites2blocks <-  blockwts[sites2blocks, .(ejam_uniq_id, blockid, distance, blockwt, bgid, block_radius_miles, distance_unadjusted), on = 'blockid']
  } else {
    sites2blocks <-  blockwts[sites2blocks, .(ejam_uniq_id, blockid, distance, blockwt, bgid, block_radius_miles), on = 'blockid']
  }
  if (!use_unadjusted_distance) {
    if (!quiet) {  cat("\n\nAdjusting upwards the very short distances now...\n ")}
    # 2 ways considered here for how exactly to make the adjustment:
    sites2blocks[distance < block_radius_miles, distance := 0.9 * block_radius_miles]  # assumes distance is in miles
    # or a more continuous but slower (and non EJSCREEN way?) adjustment for when dist is between 0.9 and 1.0 times block_radius_miles:
    # sites2blocks_dt[ , distance  := pmax(block_radius_miles, distance, na.rm = TRUE)] # assumes distance is in miles
  }
  # now drop that info about area or size of block to save memory. do not need it later in sites2blocks
  sites2blocks[ , block_radius_miles := NULL]
  ################################### #

  ## if radius_donut_lower_edge > 0 ####

  if (radius_donut_lower_edge > 0) {
    sites2blocks <- sites2blocks[distance <= truedistance & distance > radius_donut_lower_edge, ] # if analyzing a ring (donut)
  } else {
    sites2blocks <- sites2blocks[distance <= truedistance, ] # had been inside the loop.
  }
  ################################### #
  if (!quiet && !use_unadjusted_distance) {
    cat('Stats via getblocks_diagnostics(), AFTER ADJUSTING up FOR SHORT DISTANCES: \n')
    cat("min distance AFTER adjustment: ", min(sites2blocks$distance, na.rm = TRUE), "\n")
    cat("max distance AFTER adjustment: ", max(sites2blocks$distance, na.rm = TRUE), "\n\n")
    getblocks_diagnostics(sites2blocks)
    cat("\n")
  }
  ########################################################################### ##

  # SORT OUTPUT LIKE INPUT ? ####
  # >sort again to return sites in same sort order as inputs were in
  # sitepoints$ejam_uniq_id is vector of ids in correct order, original order. do not assume they are sorted as 1:N
  # do join to return sites2blocks with ejam_unique_id in the order in which they are found in sitepoints, and the .SD prevents it from pulling in the lat lon cols from sitepoints


  # > DROP from s2b SITES WITH NO BLOCKS FOUND ####
  sites2blocks <- sites2blocks[sitepoints, .SD, on = "ejam_uniq_id"][!is.na(blockid), ]

  return(sites2blocks)
}
