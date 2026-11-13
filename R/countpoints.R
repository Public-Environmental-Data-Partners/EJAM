#' Count supplied points within a radius of each site
#'
#' @description Counts records in the supplied point set, not a guaranteed complete
#'   inventory. Zero means none of the supplied points. A complete real-world count
#'   requires a point set covering each site's entire search area.
#' @details Uses sparse sf spatial queries rather than a sites-by-points matrix.
#'   Distances are geodesic and radius is in miles. Point IDs identify entities:
#'   repeated records with one ID count once, while separate IDs at the same
#'   coordinates count separately. Without IDs, rows count separately and repeated
#'   coordinates are reported. An ID with conflicting coordinates is rejected.
#'   Unlike [ejam2areafeatures()], this counts actual supplied points in the search
#'   area, not block groups containing a school or hospital.
#'
#' @param frompoints Site table with lat and lon columns (aliases accepted), or sf
#'   POINT features with a known CRS. Existing ejam_uniq_id values are preserved.
#' @param topoints Point table with lat and lon columns (aliases accepted), or sf
#'   POINT features with a known CRS. Empty point sets are allowed.
#' @param radius One nonnegative search radius in miles, used for all sites.
#' @param point_id Optional column identifying points. If omitted, pointid or id
#'   is used when present; otherwise each row is a distinct record.
#' @param return_matches TRUE to attach a table of counted point IDs per site.
#' @param source,date Optional text describing the point source and its date.
#' @param coverage_area Optional sf polygon(s), or a polygon file, defining where
#'   the supplied point inventory is complete. Sites extending outside it warn
#'   and get coverage_complete = FALSE. Without it, coverage is unknown (NA).
#'   Radius coverage checks use sf's buffered search polygons.
#' @param coverage_note Optional text describing completeness or coverage limits.
#' @return A data.table with one row per site: ejam_uniq_id, N (count), and
#'   coverage_complete. Attribute unique is the distinct point count across all
#'   sites; point_data records source, date, coverage_note, and the count definition.
#'   With return_matches = TRUE, attribute matches contains ejam_uniq_id and pointid.
#'   Inputs are never modified by reference. Missing site geometry is an error,
#'   not a zero count.
#' @seealso [countpoints_in_shape()] [countpoints_in_fips()] [getpointsnearby()]
#' @examples
#' sites <- data.frame(lat = c(40, 40.02), lon = c(-75, -75))
#' schools <- data.frame(id = c("a", "b"), lat = c(40, 40.01), lon = c(-75, -75))
#' counts <- countpoints_nearby(sites, schools, radius = 1, return_matches = TRUE)
#' attr(counts, "unique")
#' attr(counts, "matches")
#' @export
countpoints_nearby <- function(frompoints, topoints, radius = 3, point_id = NULL,
                               return_matches = FALSE, source = NULL, date = NULL,
                               coverage_area = NULL, coverage_note = NULL) {
  if (!is.numeric(radius) || length(radius) != 1L || !is.finite(radius) || radius < 0) {
    stop("radius must be one finite, nonnegative number of miles")
  }
  sites <- countpoints_prepare_points(frompoints, allow_empty = FALSE)
  points <- countpoints_prepare_points(topoints)
  points <- countpoints_prepare_ids(points, point_id)
  sites <- sf::st_transform(sites, 4326)
  points <- sf::st_transform(points, 4326)
  old_s2 <- sf::sf_use_s2()
  on.exit(suppressMessages(sf::sf_use_s2(old_s2)), add = TRUE)
  suppressMessages(sf::sf_use_s2(TRUE))
  matches <- sf::st_is_within_distance(sites, points, dist = units::set_units(radius, "miles"))
  search_area <- if (!is.null(coverage_area) && radius > 0) {
    sf::st_buffer(sites, dist = units::set_units(radius, "miles"))
  } else {sites}
  countpoints_result(sites, points, matches, search_area, return_matches,
                      source, date, coverage_area, coverage_note)
}

#' Count supplied points inside each polygon
#'
#' @inherit countpoints_nearby description details return
#' @inheritParams countpoints_nearby
#' @param shp sf POLYGON/MULTIPOLYGON features, or a polygon file readable by
#'   [shapefile_from_any()]. One row defines one site. Points on a boundary count
#'   in each touching site, and once in the overall distinct total.
#' @seealso [countpoints_nearby()] [countpoints_in_fips()]
#' @export
countpoints_in_shape <- function(shp, topoints, point_id = NULL, return_matches = FALSE,
                                 source = NULL, date = NULL, coverage_area = NULL,
                                 coverage_note = NULL) {
  sites <- countpoints_prepare_shapes(shp)
  points <- countpoints_prepare_ids(countpoints_prepare_points(topoints), point_id)
  points <- sf::st_transform(points, sf::st_crs(sites))
  old_s2 <- sf::sf_use_s2()
  on.exit(suppressMessages(sf::sf_use_s2(old_s2)), add = TRUE)
  suppressMessages(sf::sf_use_s2(TRUE))
  matches <- sf::st_intersects(sites, points, model = "closed")
  countpoints_result(sites, points, matches, sites, return_matches,
                      source, date, coverage_area, coverage_note)
}

#' Count supplied points in Census areas
#'
#' @inherit countpoints_nearby description return
#' @inheritParams countpoints_nearby
#' @param fips Character vector of Census FIPS codes supported by [shapes_from_fips()].
#' @param shp Optional sf polygons with FIPS, GEOID, or bgfips. Supply cached
#'   boundaries for offline use. Rows are matched to fips, never by row position.
#' @param ... Additional boundary arguments to [shapes_from_fips()]. By default
#'   counties and block groups use detailed TIGER boundaries and year defaults
#'   to [acs_endyear()] for the package's ACS vintage. State boundaries
#'   follow that helper's bundled source. Generalized polygons can alter counts.
#' @seealso [countpoints_nearby()] [countpoints_in_shape()]
#' @export
countpoints_in_fips <- function(fips, topoints, point_id = NULL, return_matches = FALSE,
                                source = NULL, date = NULL, coverage_area = NULL,
                                coverage_note = NULL, shp = NULL, ...) {
  if (!is.character(fips) || !length(fips) || anyNA(fips) || any(!grepl("^[0-9]+$", fips))) {
    stop("fips must be a nonempty character vector of Census FIPS codes")
  }
  if (is.null(shp)) {
    args <- list(...)
    if (is.null(args$year)) args$year <- acs_endyear()
    if (is.null(args$myservice_county)) args$myservice_county <- "tiger"
    if (is.null(args$myservice_blockgroup)) args$myservice_blockgroup <- "tiger"
    shp <- do.call(shapes_from_fips, c(list(fips = unique(fips)), args))
  }
  if (!inherits(shp, "sf")) stop("shp must be sf polygons")
  idcol <- intersect(c("FIPS", "GEOID", "bgfips"), names(shp))[1]
  if (is.na(idcol)) stop("shp must contain FIPS, GEOID, or bgfips")
  ids <- as.character(shp[[idcol]])
  if (anyDuplicated(ids[ids %in% fips])) stop("shp has duplicate boundaries for requested FIPS")
  where <- match(fips, ids)
  if (anyNA(where)) stop("Missing boundaries for requested FIPS: ", paste(fips[is.na(where)], collapse = ", "))
  shp <- shp[where, ]
  shp$ejam_uniq_id <- seq_along(fips)
  result <- countpoints_in_shape(shp, topoints, point_id, return_matches,
                                 source, date, coverage_area, coverage_note)
  result[, fips := fips]
  result
}

# Prepare valid coordinates without changing input tables or dropping bad rows.
countpoints_prepare_points <- function(x, allow_empty = TRUE) {
  if (!inherits(x, "sf")) {
    if (!is.data.frame(x)) stop("Points must be a table or sf POINT features")
    x <- as.data.frame(x)
    if (!all(c("lat", "lon") %in% names(x))) x <- latlon_from_anything(x, interactiveprompt = FALSE)
    if (!all(c("lat", "lon") %in% names(x)) || !is.numeric(x$lat) || !is.numeric(x$lon) ||
        any(!is.finite(x$lat)) || any(!is.finite(x$lon)) || any(abs(x$lat) > 90) || any(abs(x$lon) > 180)) {
      stop("Points must have finite numeric latitude/longitude in valid ranges")
    }
    # Avoid the legacy point helper's NA-to-zero conversion and preserve empty sets.
    x <- if (nrow(x)) sf::st_as_sf(x, coords = c("lon", "lat"), crs = 4326) else
      sf::st_sf(x[, setdiff(names(x), c("lat", "lon")), drop = FALSE], geometry = sf::st_sfc(crs = 4326))
  }
  if (is.na(sf::st_crs(x)) || any(sf::st_is_empty(x)) ||
      any(as.character(sf::st_geometry_type(x)) != "POINT") ||
      (nrow(x) > 0L && any(!is.finite(sf::st_coordinates(x))))) stop("Points must have nonempty POINT geometry and a known CRS")
  if (!allow_empty && !nrow(x)) stop("Supply at least one site")
  x
}

countpoints_prepare_shapes <- function(x) {
  if (!inherits(x, "sf")) x <- shapefile_from_any(x, silentinteractive = TRUE)
  if (!inherits(x, "sf") || is.na(sf::st_crs(x)) || !nrow(x) || any(sf::st_is_empty(x)) ||
      any(!as.character(sf::st_geometry_type(x)) %in% c("POLYGON", "MULTIPOLYGON")) ||
      any(!sf::st_is_valid(x))) stop("Supply nonempty valid polygons with a known CRS")
  x
}

countpoints_prepare_ids <- function(points, point_id) {
  if (is.null(point_id)) point_id <- intersect(c("pointid", "id"), names(points))[1]
  if (length(point_id) != 1L || (!is.na(point_id) && (!is.character(point_id) || !point_id %in% names(points)))) {
    stop("point_id must name a column in topoints")
  }
  xy <- if (nrow(points)) as.data.frame(sf::st_coordinates(points)) else data.frame(X = numeric(), Y = numeric())
  if (is.na(point_id)) {
    if (anyDuplicated(xy)) warning("Repeated coordinates without point IDs; counting each supplied record separately", call. = FALSE)
    points$.countpoints_id <- seq_len(nrow(points))
  } else {
    ids <- points[[point_id]]
    if (!(is.character(ids) || is.numeric(ids)) || anyNA(ids) || any(!nzchar(as.character(ids)))) {
      stop("Point IDs must be nonmissing, nonempty numeric or character values")
    }
    first <- match(ids, ids)
    if (nrow(points) && any(xy != xy[first, , drop = FALSE])) stop("Repeated point IDs have conflicting coordinates")
    points$.countpoints_id <- ids
    points <- points[!duplicated(ids), ]
  }
  points
}

countpoints_result <- function(sites, points, matches, search_area, return_matches,
                               source, date, coverage_area, coverage_note) {
  ids <- if ("ejam_uniq_id" %in% names(sites)) sites$ejam_uniq_id else seq_len(nrow(sites))
  if (anyNA(ids) || anyDuplicated(ids)) stop("Site ejam_uniq_id values must be unique and nonmissing")
  if (!is.logical(return_matches) || length(return_matches) != 1L || is.na(return_matches)) stop("return_matches must be TRUE or FALSE")
  complete <- rep(NA, nrow(sites))
  if (!is.null(coverage_area)) {
    coverage <- sf::st_union(sf::st_transform(countpoints_prepare_shapes(coverage_area), sf::st_crs(search_area)))
    complete <- lengths(sf::st_covered_by(search_area, coverage, model = "closed")) > 0L
    # Spherical union can reorder/round coincident edges. Difference correctly
    # recognizes fully covered polygons even when the containment predicate does not.
    polygons <- as.character(sf::st_geometry_type(search_area)) %in% c("POLYGON", "MULTIPOLYGON")
    for (i in which(!complete & polygons)) {
      remainder <- sf::st_difference(sf::st_geometry(search_area)[i], coverage)
      complete[i] <- all(sf::st_is_empty(remainder) | as.numeric(sf::st_area(remainder)) == 0)
    }
    if (any(!complete)) warning(sum(!complete), " site search area(s) extend outside the point set's coverage area", call. = FALSE)
  }
  result <- data.table::data.table(ejam_uniq_id = ids, N = lengths(matches), coverage_complete = complete)
  attr(result, "unique") <- length(unique(unlist(matches, use.names = FALSE)))
  attr(result, "point_data") <- list(source = source, date = date, coverage_note = coverage_note,
    definition = "Number of distinct points in the supplied set; zero means none of the supplied points")
  if (return_matches) {
    attr(result, "matches") <- data.table::data.table(
      ejam_uniq_id = rep(ids, lengths(matches)), pointid = points$.countpoints_id[unlist(matches, use.names = FALSE)])
  }
  result
}
