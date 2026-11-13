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
#'   topoints are Census blocks, but they can be reversed as long as the index
#'   passed is an index of the topoints.
#'
#'   For each point, this function uses the specified search radius and finds the distance to
#'   every topoint within the circle defined by the radius.
#'   Each topoint is defined by its latitude and longitude.
#'
#'   Results are the sites2points table that would be used by doaggregate(),
#'   with distance in miles as one output column of table in [data.table](https://r-datatable.com) format
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
#' @param avoidorphans logical. TRUE is not implemented and gives an error.
#'   The intended future behavior is: where not even 1 topoint
#'   is within radius of a frompoint,
#'   it keeps looking past radius, up to maxradius, to find nearest 1 topoint
#'
#'   Note that if creating a proximity score, by contrast, you instead want to find nearest 1 SITE if none within radius of this BLOCK.
#'
#' @param quadtree (actually a pointer to a large quadtree object)
#'    created using [indexpoints()] which uses the SearchTree package.
#'    Helps find the "topoints"
#' @param quaddatatable table in [data.table](https://r-datatable.com) format like [quaddata] passed to function
#'   - the data.table used to create quadtree, such as [blockpoints] or [frs].
#'     Helps find the "topoints"
#'
#' @param report_progress_every_n Reports progress to console after every n points
#' @param quiet Optional.
#' @param retain_unadjusted_distance set to FALSE to drop it and save memory/storage. If TRUE,
#'   the distance_unadjusted column will save the actual distance of site to the topoint,
#'   which might be zero. adjusted distance uses a lower limit, min_distance
#' @param updateProgress, optional function to update Shiny progress bar
#' @return see details
#' @seealso  [getpointsnearby()]
#' @import data.table
#'
#' @export
#' @keywords internal
#'
getpointsnearbyviaQuadTree <- function(frompoints, radius = 3, maxradius = 31.07, avoidorphans = FALSE,
                                        min_distance = 100/1760, retain_unadjusted_distance = TRUE,
                                        report_progress_every_n = 500, quiet = FALSE,
                                        quadtree,
                                        quaddatatable,
                                        updateProgress = NULL) {

  if (avoidorphans) {
    stop("avoidorphans = TRUE is not implemented yet; use FALSE")
  }
  stopifnot(is.data.frame(frompoints), all(c("lat", "lon") %in% names(frompoints)),
            nrow(frompoints) > 0, is.numeric(frompoints$lat), is.numeric(frompoints$lon),
            all(is.finite(frompoints$lat)), all(is.finite(frompoints$lon)),
            all(abs(frompoints$lat) <= 90), all(abs(frompoints$lon) <= 180),
            length(radius) == 1L, is.finite(radius), radius >= 0, radius <= 100,
            length(min_distance) == 1L, is.finite(min_distance), min_distance >= 0)
  if (!methods::is(quadtree, "QuadTree")) {
    stop("quadtree must be an index created with indexpoints()")
  }
  # Do not add IDs to or convert the caller's table by reference.
  frompoints <- data.table::copy(data.table::as.data.table(frompoints))
  if (!"ejam_uniq_id" %in% names(frompoints)) {
    frompoints[, ejam_uniq_id := seq_len(.N)]
  }
  if (anyNA(frompoints$ejam_uniq_id) || anyDuplicated(frompoints$ejam_uniq_id)) {
    stop("frompoints must have unique, nonmissing ejam_uniq_id values")
  }
  # create_quaddata() returns Cartesian x, y, z as x2, z2, y2.
  # SearchTrees indexes the first two columns, so search x and y, not x and z.
  xyz <- c("x2", "z2", "y2")
  if (!all(c(xyz, "pointid") %in% names(quaddatatable))) {
    stop("quaddatatable must come from create_quaddata(topoints)")
  }
  quaddatatable <- data.table::as.data.table(quaddatatable)
  earthRadius_miles <- 3959
  radians <- pi / 180
  lat <- frompoints$lat * radians
  lon <- frompoints$lon * radians
  from_xyz <- cbind(earthRadius_miles * cos(lat) * cos(lon),
                    earthRadius_miles * cos(lat) * sin(lon),
                    earthRadius_miles * sin(lat))
  chord_radius <- distance_via_surfacedistance(radius)
  nsites <- nrow(frompoints)
  if (!quiet) {message("Finding nearby points for ", nsites, " sites")}
  res <- lapply(seq_len(nsites), function(i) {
    ids <- SearchTrees::rectLookup(quadtree,
                                  xlims = from_xyz[i, 1] + c(-1, 1) * chord_radius,
                                  ylims = from_xyz[i, 2] + c(-1, 1) * chord_radius)
    nearby <- quaddatatable[sort(ids), ]
    # Empty searches must still return a table with the documented columns.
    chord <- if (nrow(nearby)) {
      sqrt(rowSums(sweep(as.matrix(nearby[, ..xyz]), 2L, from_xyz[i, ], "-")^2))
    } else {numeric()}
    distance <- 2 * earthRadius_miles * asin(pmin(1, chord / (2 * earthRadius_miles)))
    keep <- distance <= radius
    ans <- data.table::data.table(
      ejam_uniq_id = rep(frompoints$ejam_uniq_id[i], sum(keep)),
      pointid = nearby$pointid[keep], distance = distance[keep])
    if (retain_unadjusted_distance) {ans[, distance_unadjusted := distance]}
    # Membership uses actual distance; the proximity floor must not remove matches.
    ans[, distance := pmax(distance, min_distance)]
    if (!quiet && report_progress_every_n > 0 && i %% report_progress_every_n == 0) {
      message("Finished ", i, " of ", nsites, " sites")
    }
    if (is.function(updateProgress)) {
      updateProgress(message_main = paste("Finished", i, "of", nsites, "sites"), value = i / nsites)
    }
    ans
  })
  data.table::rbindlist(res)
}
