#' Fast way to find nearby points - For each frompoint, it finds distances to all nearby topoints (within radius)
#'
#' @description Given a set of frompoints (e.g., facilities or blocks) and a specified radius in miles,
#'   this function quickly finds all the topoints (e.g., blocks or facilities) near each point.
#'   If from and to are facilities and census blocks, respectively, this can be used to aggregate
#'   over blockgroups near a facility for an EJAM analysis. But if it is used to define from
#'   as blocks and to as facilities, it finds all facilities near each block, which is how
#'   proxistat works to create proximity indicators.
#'
#' @details
#'   The explanation below is assuming frompoints are "sites" such as facilities and
#'   topoints are Census blocks, but they can be reversed as long as the quaddata index
#'   passed is an index of the topoints.
#'
#'   For each point, this function uses the specified search radius and finds the distance to
#'   every topoint within the circle defined by the radius.
#'   Each topoint is defined by its latitude and longitude.
#'
#'   Results are the sites2points table that would be used by doaggregate(),
#'   with distance in miles as one output column of data.table.
#'
#' @param frompoints data.table with columns lat, lon giving point locations of
#'   sites or facilities or blocks around which are circular buffers defined by radius.
#'
#'  - pointid will be the indexed topoints id.
#'
#'  - ejam_uniq_id is the frompoints id
#'
#' @param radius in miles, defining circular buffer around a frompoint
#' @param maxradius miles distance (max distance to check if not even 1 topoint is within radius)
#' @param min_distance miles minimum distance to use for cases where from and to points are
#'   identical or almost the same location.
#' @param avoidorphans logical If TRUE, then where not even 1 topoint
#'   is within radius of a frompoint,
#'   it keeps looking past radius, up to maxradius, to find nearest 1 topoint
#'
#'   Note that if creating a proximity score, by contrast, you instead want to find nearest 1 SITE if none within radius of this BLOCK.
#'
#' @param quadtree (a pointer to the large quadtree object)
#'    created using indexpoints() which uses the SearchTree package.
#'    Helps find the "topoints"
#' @param quaddatatable data.table like quaddata passed to function
#'   - the data.table used to create quadtree, such as blockpoints or frs.
#'     Helps find the "topoints"
#'
#' @param report_progress_every_n Reports progress to console after every n points
#' @param quiet Optional.
#' @param retain_unadjusted_distance set to FALSE to drop it and save memory/storage. If TRUE,
#'   the distance_unadjusted column will save the actual distance of site to the topoint,
#'   which might be zero. adjusted distance uses a lower limit, min_distance
#' @param updateProgress, optional function to update Shiny progress bar
#'
#' @seealso  [getpointsnearby()]
#' @import data.table
#'
#' @export
#'
getpointsnearbyviaQuadTree <- function(frompoints, radius = 3, maxradius = 31.07, avoidorphans = FALSE,
                                        min_distance = 100/1760, retain_unadjusted_distance = TRUE,
                                        report_progress_every_n = 500, quiet = FALSE,
                                        quadtree,
                                        quaddatatable,
                                        updateProgress = NULL) {

  if (!is(quadtree,"QuadTree")) {
    if (shiny::isRunning()) {
      warning('quadtree must be an index created with indexpoints(pts), from SearchTrees package with treeType = "quad" and dataType = "point"')
      return(NULL)
    } else {
      stop('quadtree must be an index created with indexpoints(pts), from SearchTrees package with treeType = "quad" and dataType = "point"')
    }
  }
  if (missing(frompoints)) {
    if (shiny::isRunning()) {
      warning("frompoints missing  ")
      return(NULL)
    } else {
      stop("frompoints missing  ")
    }
  }
  stopifnot(is.data.frame(frompoints), "lat" %in% colnames(frompoints), "lon" %in% colnames(frompoints), NROW(frompoints) >= 1, is.numeric(frompoints$lat))
  if (missing(quadtree)) {
    if (shiny::isRunning()) {
      warning("quadtree ")
      return(NULL)
    } else {
      stop("quadtree is missing ")
    }
  }
  if (!is(quadtree,"QuadTree")) {stop('quadtree  is not class quadtree')}
  stopifnot(is.numeric(radius), radius <= 100, radius >= 0, length(radius) == 1)
  if (missing(radius)) {warning("radius missing so using default radius of 3 miles")}

  if (!data.table::is.data.table(frompoints)) {data.table::setDT(frompoints)} # should we set a key or index here  ? ***

  ########################################################################### ##
  # ejam_uniq_id ####
  if (!('ejam_uniq_id' %in% names(frompoints))) {
    frompoints$ejam_uniq_id <- seq.int(length.out = NROW(frompoints))
  }
  ########################################################################### ##


  # TRANSFORM COORDINATES OF SITES ####

  earthRadius_miles <- 3959 # in case it is not already in global envt
  radians_per_degree <- pi / 180
  truedistance <- distance_via_surfacedistance(radius)  # simply 7918*sin(radius/7918) which is nearly identical to unadjusted distances, like 9.999997 vs. 10.000000 miles ! even 29.999928 vs 30 miles
  nRowsDf <- NROW(sitepoints)
  if (!quiet) {
    cat("Finding points within ", radius," miles of the site (frompoint), for each of", nRowsDf," sites (points)...\n")
  }

  lat_rad <- frompoints$lat * radians_per_degree
  lon_rad <- frompoints$lon * radians_per_degree
  FAC_X <- earthRadius_miles * cos(lat_rad) * cos(lon_rad)
  FAC_Y <- earthRadius_miles * cos(lat_rad) * sin(lon_rad)
  FAC_Z <- earthRadius_miles * sin(lat_rad)

  ######################################################################################################################## #
  ######################################################################################################################## #

  # LOOP OVER frompoints SITES HERE ####

  res <- lapply(1:nRowsDf, FUN = function(a) {

    ### * FAST SEARCH - WHICH BLOCKS ARE APPROX NEARBY ####
    #### USE quadtree INDEX OF points TO FIND points NEAR THIS 1 SITE,
    # find vector of the hundreds of point ids that are approximately near this site

    vec <- SearchTrees::rectLookup(
      tree = quadtree,
      xlims = FAC_X[a] + c(-1,1) * truedistance,
      ylims = FAC_Z[a] + c(-1,1) * truedistance
    )
    tmp <-  quaddatatable[vec, ]  # all the indexed topoints near this 1 site.

    ### * EXACT DISTANCE TO EACH BLOCK or topoint  ####

    # pdist() can Compute a distance matrix between two matrices of observations,
    # but here is used in loop to only check all pts near ONE frompoint at a time. Seems inefficient - cant we vectorize outside loop in batches that are manageable size each? ***
    # distances is now just a 1 column data.table of hundreds of distance values. Some may be 5.08 miles even though specified radius of 3 miles even though distance to corner of bounding box should be 1.4142*r= 4.2426, not 5 ?
    # pdist computes a n by p distance matrix using two separate matrices

    distances <- as.matrix(
      pdist::pdist(
        tmp[ , .(BLOCK_X, BLOCK_Y, BLOCK_Z)],           #######   should change names from BLOCK to generic points ***
        c(FAC_X[a], FAC_Y[a], FAC_Z[a]))@dist
    )
    # add the distances and ejam_uniq_id to the table of nearby blocks or topoints
    tmp[ , distance := distances]      # converts distances dt into a vector that becomes a column of tmp
    tmp[, ejam_uniq_id := frompoints[a, .(ejam_uniq_id)]]

    ### progress bar ####
    ## could add check that data has enough points to show increments with rounding ***
    ## i.e. if 5% increments, need at least 20 points or %% will return NaN
    if (((a %% report_progress_every_n) == 0) && interactive()) {cat(paste("Finished finding points near ", a ," of ", nRowsDf),"\n" ) }   # i %% report_progress_every_n indicates i mod report_progress_every_n (“i modulo report_progress_every_n”)
    ## update progress bar at 5% intervals
    pct_inc <- 5
    ## add check that data has enough points to show increments with rounding
    ## i.e. if 5% increments, need at least 20 points or %% will return NaN
    if (is.function(updateProgress) && (nRowsDf >= (100/pct_inc)) && (a %% round(nRowsDf/(100/pct_inc)) < 1)) {
      boldtext <- paste0((pct_inc)*round((100/pct_inc*a/nRowsDf)), '% done')
      updateProgress(message_main = boldtext, value = round((pct_inc)*a/nRowsDf,2)/(pct_inc))
    }

    return(tmp[, .(pointid, distance, ejam_uniq_id)])
  }) # end loop over frompoints
  ########################################################################### ##

  # Max allowed count of nearby points ####
  if (sum(sapply(res, nrow)) > 2100000000) {
    shiny::validate(
      need(FALSE, "The analysis found too many nearby points and was interrupted. Please use a smaller radius or analyze fewer points at once.")
    )
  }
  # Compile as data.table ####

  sites2points <- data.table::rbindlist(res)
  data.table::setkey(sites2points, pointid, ejam_uniq_id, distance)
  ########################################################################### ##
  ########################################################################### ##

  # avoidorphans ? ####

  #### If avoidorphans TRUE, and no topoint within radius of site, look past radius to maxradius   ############## #
  # But note looking past radius is NOT how EJSCREEN works, for buffer reports - it just fails to provide any result if no blockpoint is inside circle.
  # For proximity scores, which are different than circular buffer reports, EJSCREEN does look beyond radius, but not for circular zone report).
  # Also, you would rarely get here even if avoidorphans set TRUE.
  # cat('about to check avoidorphans\n')

  if ( avoidorphans && (NROW(res[[i]])  == 0)) {
    warning("NOT USING avoidorphans CURRENTLY - avoidorphans=T needs fixing")
    if ( 1 == 0 ) {
      if (!quiet) {cat("avoidorphans is TRUE, so avoiding reporting zero POINTS nearby by searching past radius of ", radius, " to maxradius of ", maxradius, "\n")}

      stop("next step crashes R -- work in progress -- would have to recode since not inside loop over sites here")

      # search neighbors, allow for multiple at equal distance
      vec  <- SearchTrees::knnLookup(
        quadtree,
        unlist(c(frompoints[ , 'FAC_X'])),  # ??? untested - avoidorphans=T needs fixing ***
        unlist(c(frompoints[ , 'FAC_Z'])),  # ???
        k = 10   # why 10?
      )
      tmp <-  quaddata[vec[1, ], ]  # the first distance in the new vector of distances? is that the shortest?
      x <- tmp[, .(BLOCK_X, BLOCK_Y, BLOCK_Z)]    #######   should change from BLOCK to generic points ***
      y <- frompoints[i, .(FAC_X, FAC_Y, FAC_Z)]
      distances <- as.matrix(pdist::pdist(x, y))
      tmp[ , distance := distances[ , c(1)]]
      tmp[ , ejam_uniq_id := frompoints[i, .(ejam_uniq_id)]]
      # keep only the 1 pt that is closest to this site (that is > radius but < maxradius) -- NEED TO CONFIRM/TEST THIS !!
      truemaxdistance <- distance_via_surfacedistance(maxradius)
      data.table::setorder(tmp, distance) # ascending order short to long distance
      res[[i]] <- tmp[distance <= truemaxdistance, .(pointid, distance, ejam_uniq_id)]
    } # end of chunk that skips avoidorphans
  }    ### end of if avoidorphans
  ########################################################################### ##
  ########################################################################### ##

  # ADJUST DISTANCES ####

  ## if adjusting very short distances -- only if use_unadjusted_distance = FALSE  ####

  if (!quiet) {
    cat('Stats via getblocks_diagnostics(), but NOT ADJUSTING UP FOR VERY SHORT DISTANCES: \n')
    cat("min distance before adjustment: ", min(sites2points$distance, na.rm = TRUE), "\n")
    cat("max distance before adjustment: ", max(sites2points$distance, na.rm = TRUE), "\n\n")
    #getblocks_diagnostics(sites2points) # returns NA if no points nearby
  }

  ### this would have to be adjusted to handle points as opposed to blocks, if it is even relevant
  ## nearby points could be e.g., CAFOs not blocks, in which case you would want size of CAFO footprint instead of size of block!
  ## but either from or topoints would likely be blocks, right? so maybe this is still relevant?
  # distance can get adjusted to a minimum possible value,  0.9 * effective radius of block_radius_miles (see EJSCREEN Technical Documentation discussion of proximity analysis for rationale)
  # See notes in the file EJAM/data-raw/datacreate_blockwts.R
  # use block_radius_miles here, to correct the distances that are small relative to a block size.
  # This adjusts distance the way EJSCREEN does for proximity scores - so distance reflects distance of sitepoint to avg resident in block
  # (rather than sitepoint's distance to the block internal point),
  # including e.g., where distance to block internal point is so small the site is inside the block.
  # This also avoids infinitely small or zero distances.

  ## if retain_unadjusted_distance ####
  if (retain_unadjusted_distance) {
    sites2points[ , distance_unadjusted := distance] # wastes space but for development/ debugging probably useful

    #   ##   join that updated sites2points is irrelevant for non-blocks
    #   sites2points <-  blockwts[sites2points, .(ejam_uniq_id, pointid, distance, blockwt, bgid, block_radius_miles, distance_unadjusted), on = 'blockid']
    # } else {
    #   sites2points <-  blockwts[sites2points, .(ejam_uniq_id, pointid, distance, blockwt, bgid, block_radius_miles), on = 'blockid']

    setcolorder(sites2points, c("ejam_uniq_id", "pointid", "distance", "distance_unadjusted"))
  } else {
    setcolorder(sites2points, c("ejam_uniq_id", "pointid", "distance"))
  }

  if (!use_unadjusted_distance) {
    cat("*** unable to adjust for very short distances based on size of places represented by topoints, e.g. \n")
    warning("unable to adjust for very short distances based on size of places represented by topoints, e.g. ")
    if (FALSE) {
      if (!quiet) {  cat("\n\nAdjusting upwards the very short distances now...\n ")}
      ### area = pi * r^2; r^2 = (area/pi); r = sqrt(area/pi)
      if ("area" %in% names(sites2points)) {
        sites2points$point_radius_miles <- sqrt(sites2points$area/pi)
        # 2 ways considered here for how exactly to make the adjustment:
        # one way:
        sites2points[distance < point_radius_miles, distance := 0.9 * point_radius_miles]  # assumes distance is in miles
        # other way:  a more continuous but slower (and non EJSCREEN way?) adjustment for when dist is between 0.9 and 1.0 times point_radius_miles:
        # sites2blocks_dt[ , distance  := pmax(point_radius_miles, distance, na.rm = TRUE)] # assumes distance is in miles
        # now drop that info about area or size of block to save memory. do not need it later in sites2points. dont have it?
        # sites2points[ , point_radius_miles := NULL]
      }
    }
  }
  ########################################################################### ##

  ## unlike in getblocksnearby, we can put a lower limit on distance here:
  sites2points[distance < min_distance, distance := min_distance]  # assumes distance is in miles

  ################################### #

  ## if radius_donut_lower_edge > 0 ####

  if (radius_donut_lower_edge > 0) {
    sites2points <- sites2points[distance <= truedistance & distance > radius_donut_lower_edge, ] # if analyzing a ring (donut)
  } else {
    sites2points <- sites2points[distance <= truedistance, ] # had been inside the loop.
  }
  ################################### #
  if (!quiet && !use_unadjusted_distance) {
    cat('Stats via getblocks_diagnostics(), AFTER ADJUSTING up FOR SHORT DISTANCES: \n')
    cat("min distance AFTER adjustment: ", min(sites2points$distance, na.rm = TRUE), "\n")
    cat("max distance AFTER adjustment: ", max(sites2points$distance, na.rm = TRUE), "\n\n")
    getblocks_diagnostics(sites2points)
    cat("\n")
  }
  ########################################################################### ##

  # SORT OUTPUT LIKE INPUT ? ####
  # >sort again to return sites in same sort order as inputs were in
  # sitepoints$ejam_uniq_id is vector of ids in correct order, original order. do not assume they are sorted as 1:N
  # do join to return sites2blocks with ejam_unique_id in the order in which they are found in sitepoints, and the .SD prevents it from pulling in the lat lon cols from sitepoints


  # > DROP from s2b SITES WITH NO topoints FOUND ####
  sites2points <- sites2points[sitepoints, .SD, on = "ejam_uniq_id"][!is.na(pointid), ]

  return(sites2points)
}
