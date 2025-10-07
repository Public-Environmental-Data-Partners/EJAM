
#' plotblocksnearby - Map view of Census blocks (their centroids) near one or more sites
#' Utility to quickly view one or more facility points on map with the blocks found nearby
#'
#' @details Uses [getblocksnearby()] if lat,lon points provided as sitepoints,
#'  but skips it if looks like user passed output of getblocksnearby(),
#'  and then displays a map of those blocks near the specified point.
#' @param sitepoints table of points with lat, lon in decimal degrees (data.frame or data.table),
#'   but also could just be the output of getblocksnearby() if that has already been done.
#' @param radius optional. in miles (Max allowed is 32 miles, or just over 50 kilometers since 31.06856 miles is 50 * 1000 / meters_per_mile).
#' @param sites2blocks optional. If provided, used as sites2blocks like [testoutput_getblocksnearby_10pts_1miles]
#'    If neither sites2blocks nor sitepoints is provided it cannot plot and returns error.
#'    If sites2blocks and sitepoints are both provided, it uses them both to plot blocks and sites (centers of circles).
#'    If sites2blocks not provided, but sitepoints alone is provided, checks if sitepoints is actually sites2blocks, and uses as such.
#'    If sites2blocks not provided, but sitepoints alone is provided, and sitepoints is really sitepoints, it runs getblocksnearby() to create sites2blocks.
#'    If sites2blocks is provided, but sitepoints is not, it could only do a bad approximation of sitepoints so it will not draw the circle or site at center of the circle.
#' @param usemapfast optional. simpler plot if FALSE
#' @param returnmap optional. if set TRUE, returns the leaflet map object instead of tabular info.
#'   That  is needed to pass results to map_blockgroups_over_blocks() for example.
#' @param overlay_blockgroups optional. if set TRUE, also plots overlay of blockgroup boundaries.
#' @param maxradius optional. see [getblocksnearby()]
#' @param avoidorphans optional. see [getblocksnearby()]
#' @param ... optional. passed to mapfast() or plot() depending on usemapfast,
#'   like column_names = "ej" for better map popups on block points
#'
#' @return invisibly returns sites2blocks like getblocksnearby() does
#'
#' @export
#'
plotblocksnearby <- function(sitepoints, radius=3, sites2blocks,
                             usemapfast=TRUE, returnmap=FALSE, overlay_blockgroups=FALSE,
                             maxradius = 31.07, avoidorphans = FALSE, ...) {

  ## example was failing to parse, but is mostly useful
  #
    #  see all Census Blocks within 1 mile of 1 site, if already had run getblocksnearby()
    # getblocks_output <- testoutput_getblocksnearby_10pts_1miles
    #
    #  eg <- getblocks_output[ejam_uniq_id == 1,]
    #  eg2 <- getblocks_output[ejam_uniq_id %in% c(3,10),]
    #
    #  z <-  plotblocksnearby(sitepoints = testpoints_10[1,],
    #    sites2blocks = eg, radius = 1)
    #  # see two sites if already had run getblocksnearby()
    #  z2 <-  plotblocksnearby(sitepoints = testpoints_10[c(3,10),],
    #    sites2blocks = eg2, radius = 1)
    #
    #     \dontrun{
    #
    # # See two sites and all Census Blocks within 5 kilometers
    #   plotblocksnearby(testpoints_10[c(3,10),], radius = convert_units(5, from = "km", towhat = "miles"))
    #
    # # See one randomly selected regulated facility from FRS
    # and all Census Blocks and Blockgroups within 2 miles:
    #   plotblocksnearby(testpoints_n(1), 2, overlay_blockgroups=T)
    #
    # # See 100 sites and all blocks within 1 mile of each -
    # # Note you have to specify radius here or it uses default that may not match intent
    # # - and this is a bit slow
    # plotblocksnearby(
    #   testoutput_ejamit_100pts_1miles$results_bysite[,
    #       c("ejam_uniq_id", "lat", "lon"), with=FALSE],
    #  radius = 1)
    # }
    #

  if (radius > 32) {radius <- 32; warning("Cannot use radius above 32 miles (almost 51 km) here - Returning results for 32 miles!")}
  if (missing(sitepoints) &&  missing(sites2blocks)) {
    warning('must provide either sitepoints or sites2blocks or both')
    return(NULL)
  }
  if (missing(sitepoints) && !missing(sites2blocks)) {
    warning('sitepoints missing so will not try to guess site at center of circle - drawing surrounding blocks only')
  }
  if (!missing(sitepoints) && !missing(sites2blocks)) {
    # good
  }
  # ########################################################################################### #

  # GET BLOCKS NEARBY (unless already provided) ####

  if ( all(c("blockid", "distance", "ejam_uniq_id") %in% names(sitepoints))) {

    really_sitepoints <- FALSE
    # instead of a list of lat,lon points, the user has just provided the output of getblocksnearby() already run, aka sites2blocks
    # so skip getblocksnearby() ... do not have to do it again if already done.
    sites2blocks <- copy(sitepoints) # which ignores what they might have also passed as sites2blocks = xyz redundantly

    if (sites2blocks[, uniqueN(ejam_uniq_id)] > 100) {
      warning("this mapping function is not intended for so many sites - showing only the first 100")
      sites2blocks <- sites2blocks[ejam_uniq_id %in% sort(unique(ejam_uniq_id))[1:100], ]
    }
    # but will need to approximate the lat,lon of each site, below, after we get lat lon of each block.
    # and the approximation done here is pretty bad so the circle drawn around that bad approximation of sitepoints is not covering the right blocks !

  } else {

    really_sitepoints <- TRUE

    if (NROW(sitepoints) > 100) {
      warning("this mapping function is not intended for so many sites - showing only the first 100")
      sitepoints <- sitepoints[1:100, ]
    }
    if (missing(sites2blocks)) {
      # Use getblocksnearby() since user only provided a list of lat,lon points.
      sites2blocks <- getblocksnearby(sitepoints = sitepoints, radius = radius, maxradius = maxradius, avoidorphans = avoidorphans)
    }
  }

  if (NROW(sites2blocks) == 0 || all(is.na(sites2blocks$blockid))) {
    warning('No block internal points are near the specified sitepoints')
    zeronearby <- TRUE
    x <- copy(sitepoints)
    setDT(x)
  } else {
    sitepoints <- copy(sitepoints)
    zeronearby <- FALSE
    ########################################################################################### #
    ##
    ## notes on lat lon of sites versus lat lon of block points
    #
    # pts = copy(testpoints_10[1:2,])
    # # add ejam_uniq_id column
    # pts = sitepoints_from_any(pts)
    #
    # # find blocks
    # s2b = getblocksnearby(pts)
    #
    # # to add latlon of the SITES (pts), not the blocks
    # s2b[pts, c('sitelat', 'sitelon') := .(lat,lon), on = "ejam_uniq_id"]
    #
    # # to add latlon of the BLOCKS, not the sites
    # latlon_join_on_blockid(s2b)
    # s2b
    # # can map blocks lat,lon easily if colnames are lat,lon
    # mapfast(s2b[ejam_uniq_id == 1,], radius = 0.01)
    # # to rename block lat,lon for clarity
    # setnames(s2b,"lat","blocklat"); setnames(s2b,"lon","blocklon")
    # s2b
    ##
    ## see how latlon_from_s2b() estimated site coordinates are not quite the same as actual site lat lon
    # x = latlon_from_s2b(s2b)
    # mapfast(rbind(data.table(s2b[ejam_uniq_id == 1, .(from = "blocks", ejam_uniq_id = 1, lat = lat, lon = lon )]),
    #               data.table(from = rep("latlon_from_s2b",30), ejam_uniq_id = rep(1, 30), lat = rep(x[1,lat], 30), lon = rep(x[1,lon], 30)),
    #               data.table(from = "actual site", ejam_uniq_id = 1, lat = s2b[ejam_uniq_id == 1, sitelat], lon = s2b[ejam_uniq_id == 1, sitelon])), radius = 0.01)
    # x[1,]; s2b[1,.(ejam_uniq_id,sitelat,sitelon)]
    # radius_inferred(s2b)
    # ########################################################################################### #

    # BLOCK LAT LON ####

    bl <- latlon_join_on_blockid(sites2blocks) # it checks 1st to see if lat lon already there, but that would be unclear if they were since they might be just site latlon not block latlon. Not there normally.
    setDT(bl) # redundant but fast

    ## infer radius approx., and sitepoints latlon approx. ####
    #  if we know only output of getblocksnearby() not actual sitepoints
    if (!really_sitepoints) {
      if (missing(radius)) {radius <- radius_inferred(bl)} # round(max(bl$distance, na.rm = TRUE), 1)}
      sitepoints <- latlon_from_s2b(bl)
    }
    setnames(bl, 'lat', 'blocklat')
    setnames(bl, 'lon', 'blocklon')
    bl$site.bgid <- NA
    # ########################################################################################### #

    # SITE unique id ####

    # Put site point(s) (which have lat,lon) and surrounding block points (which have blocklat,blocklon) into one table
    setDT(sitepoints) # not sure this is needed
    x <- copy(sitepoints)
    x$site.bgid <- NA
    if ("ejam_uniq_id" %in% names(x)) {
      if (!all(as.vector(unlist(x[ , ejam_uniq_id])) == 1:NROW(x))) {
        warning(paste0("ejam_uniq_id is already a colname of sitepoints, but note it is not equal to rownumbers as assumed by getblocksnearby()"))
      }
    } else {
      x$ejam_uniq_id <- 1:NROW(sitepoints)
    }
    # ########################################################################################### #

    # so it is clear that this is the bgid of the bg containing the site, not the bgids of the bgs containing the surrounding blocks
    x <- merge(x, bl, by = "ejam_uniq_id", all.y = TRUE)
  }
  # ########################################################################################### #
  if (usemapfast) {

    if (!zeronearby) {
      ########################################################## #

      # BLOCKS (SURROUNDING A SITE) ####

      xb <- copy(x)
      if (!("ejam_uniq_id" %in% names(xb))) {xb[, ejam_uniq_id := 1:NROW(xb)]} # ensure it has ejam_uniq_id
      xb[ , blockcount_near_site := .N, by = "ejam_uniq_id"]
      # if ("site.bgid" %in% names(xb)) {xb$site.bgid <- NULL} # retaining this is OK # ok to leave that info on each block since it is named clearly
      xb[, lat := blocklat]
      xb[, lon := blocklon]
      xb[, blockfips := NA]
      xb <- unique(xb)
    }
    if (really_sitepoints) {
      ########################################################## #

      # SITES (AT CENTER OF EACH CIRCLE) ####

      xpt <- copy(x)
      xpt[ , blockcount_near_site := .N, by = "ejam_uniq_id"]
      xpt <- xpt[ !duplicated(xpt[ , .(lat,lon)]),] # only one point per ejam_uniq_id, since the block coordinates in x had been named blocklat, blocklon, so the lat,lon here were just the site coordinates
      xpt$distance <- 0
      xpt$bgid    <- NA #########
      xpt$blockwt <- NA
      xpt$blockid <- NA
      xpt$blocklat <- NA; xpt$blocklon <- NA
      xpt$blockfips <- NA
      xpt$blockid <- NA
      xpt$distance_unadjusted <- NA
      ########################################################## #

      # BLOCKS AND SITES IN A COMBINED TABLE

      if (zeronearby) {
        mapinfo <- xpt
      } else {
        mapinfo <- rbind(xpt, xb)
      }
    } else {
      mapinfo <- xb
    }
    ########################################################## #
    if ("blockid" %in% names(mapinfo)) {

      # GET FIPS CODES FOR BLOCKS AND BLOCKGROUPS ####

      if (!exists('blockid2fips')) {
        dataload_dynamic("blockid2fips")
        if (!exists('blockid2fips')) {
          warning("cannot find blockid2fips")
          blockid2fips <- data.table(blockid = NA, blockfips = NA)
        }
      }
      mapinfo[blockid2fips, blockfips := blockfips, on = "blockid"]
      mapinfo[ , bgfips := substr(blockfips, 1, 12)]

      # POPULATION COUNTS FOR BLOCK, BLOCKGROUP, SITE ####

      mapinfo[blockgroupstats, bgpop := pop, on = 'bgid']
      mapinfo[ , blockpop := round(blockwt * bgpop, 1)]
      mapinfo[ , pop_nearby := round(sum(blockpop, na.rm = TRUE), 0), by = "ejam_uniq_id"]
    }
    ########################################################## #

    # MAPPING

    z <- mapfast(mapinfo, radius = 0.005, ...)

    if (really_sitepoints) {

      # CIRCLE SURROUNDING EACH SITE ####

      # to show radius of search (units in meters for circles, and pixels for circle markers)

      z <- leaflet::addCircles(z, lat = xpt$lat, lng = xpt$lon,
                               radius = meters_per_mile *  as.vector(radius), color = "gray",
                               fillOpacity = 0.06, fillColor = "gray", opacity = 0.7) #  %>% # overall circle

      # SITES (AT CENTER OF EACH CIRCLE)

      z <- leaflet::addCircleMarkers(z, lat = xpt$lat, lng = xpt$lon,
                                     radius = 10, color = "red", opacity = 0.75) # %>%  # in pixels for center of circle=point
    }

    # MAP POPUP INFO for each site (if available) and blocks surrounding the site

    vnames <- c(
      # for each block (or overall like radius and total pop)
      'blockfips', 'blockid', 'blocklat', 'blocklon',
      'distance', 'distance_unadjusted', 'radius', 'radius.miles',
      'blockwt', 'blockpop',
      # for each blockgroup
      'bgpop', 'pop_nearby',
      'bgfips', 'bgid',
      # for site
      'site.bgid', 'blockcount_near_site', 'ejam_uniq_id'
    )
    vnames <- intersect(vnames, colnames(mapinfo))

    z <- leaflet::addCircles(z, lat = mapinfo$lat, lng = mapinfo$lon, fillOpacity = 0.1,
                             popup = popup_from_df(setDF(mapinfo), column_names = vnames), radius = 10)

    ########################################################## #

    # OVERLAY BLOCKGROUP BOUNDARIES

    if (overlay_blockgroups) {
      z <- map_blockgroups_over_blocks(z)
    }
    print(z)
  } else {
    ########################################################## #
    # IF NOT USING LEAFLET MAP

    bplot <- function(x,   ... ) {
      if (!zeronearby) {
        plot(x = x$blocklon, y = x$blocklat , ... )
      }
      if (really_sitepoints) {
        points(x = x$lon, y = x$lat  , col = "red")
      }
    }
    # bplot(x, sample(1:nrow(sitepoints), 1)) # plots a random site surrounded by nearby block points
    bplot(x, main = "Site and surrounding block centroids", xlab = "", ylab = "", ...)
  }
  # ########################################################################################### #
  if (returnmap) {
    return(z)
  } else {
    invisible(sites2blocks)
  }
}
# ########################################################################################### #
