############################################################################### #
## Helpers that keep maps of many sites small and fast:
## short popups, clustered points, simplified polygons, and a static map image in the downloaded report.
## The limits are settings in global_defaults_package.R (see map_size_setting()).
############################################################################### #

#' Get one of the settings that limit how much detail a map of many sites shows
#'
#' @details These settings are defined in `global_defaults_package.R`, and the web app
#'   can override them via [ejamapp()]. This function also works where those defaults
#'   are not available, such as when EJAM functions are called via `EJAM::` without
#'   attaching the package, by falling back to built-in values.
#'
#'   - `default_max_pts_show_detailed_popups` (1,000): above this many sites, popups are short.
#'   - `default_max_pts_map_show_unclustered` (5,000): above this many points, they are clustered markers.
#'   - `default_max_pts_map_show_in_downloaded_report` (20,000): above this many points,
#'     the downloaded report shows a static image of the map.
#'   - `default_max_shapes_map_show_in_downloaded_report` (20,000): the same for polygons.
#'   - `default_max_shapes_map_unsimplified` (500): above this many polygons, shapes are simplified.
#'
#' @param vname name of the setting, such as `"default_max_pts_show_detailed_popups"`
#'
#' @return a number
#'
#' @keywords internal
#'
map_size_setting <- function(vname) {

  builtin <- list(
    default_max_pts_show_detailed_popups             = 1000,
    default_max_pts_map_show_unclustered             = 5000,
    default_max_pts_map_show_in_downloaded_report    = 20000,
    default_max_shapes_map_show_in_downloaded_report = 20000,
    default_max_shapes_map_unsimplified              = 500
  )
  if (!(vname %in% names(builtin))) {stop("unknown map size setting: ", vname)}
  x <- try(global_or_param(vname), silent = TRUE)
  x <- suppressWarnings(as.numeric(if (inherits(x, "try-error")) NULL else x))
  if (length(x) != 1 || is.na(x)) {
    x <- builtin[[vname]]
  }
  x
}
############################################################################### #

#' Decide how detailed map popups should be, given how many sites are mapped
#'
#' @param n number of sites on the map
#' @param popup_style `"auto"`, `"full"`, `"short"`, or `"none"`.
#'   `"auto"` means full popups unless there are more than
#'   `default_max_pts_show_detailed_popups` sites (see [map_size_setting()]), then short ones.
#'
#' @return `"full"`, `"short"`, or `"none"`
#'
#' @keywords internal
#'
map_popup_style <- function(n, popup_style = "auto") {

  if (is.null(popup_style) || length(popup_style) != 1 || is.na(popup_style)) {popup_style <- "auto"}
  popup_style <- match.arg(popup_style, c("auto", "full", "short", "none"))
  if (popup_style == "auto") {
    popup_style <- if (n > map_size_setting("default_max_pts_show_detailed_popups")) "short" else "full"
  }
  popup_style
}
############################################################################### #

#' Simplify polygons for a map, if there are many of them
#'
#' @details If there are more than `default_max_shapes_map_unsimplified` polygons
#'   (see [map_size_setting()]), each is simplified with [sf::st_simplify()],
#'   which keeps the map smaller and faster. This affects only what is drawn, not any analysis.
#'   If simplifying fails, the polygons are returned unchanged.
#'
#' @param shapes spatial data.frame of polygons
#' @param dTolerance_meters passed to [sf::st_simplify()] as `dTolerance`
#'   (meters for longitude/latitude coordinates)
#'
#' @return `shapes`, possibly simplified
#'
#' @keywords internal
#'
map_shapes_simplified <- function(shapes, dTolerance_meters = 100) {

  if (!inherits(shapes, "sf") || NROW(shapes) <= map_size_setting("default_max_shapes_map_unsimplified")) {
    return(shapes)
  }
  simpler <- try(suppressWarnings(sf::st_simplify(shapes, preserveTopology = TRUE, dTolerance = dTolerance_meters)), silent = TRUE)
  if (inherits(simpler, "try-error")) {
    return(shapes)
  }
  simpler
}
############################################################################### #

#' Decide if the downloaded report should show a static image of the map
#'
#' @param n number of sites to be mapped
#' @param polygons TRUE if sites are polygons (shapefile or FIPS units), FALSE if points
#'
#' @return TRUE if `n` is more than `default_max_shapes_map_show_in_downloaded_report`
#'   (polygons) or `default_max_pts_map_show_in_downloaded_report` (points);
#'   see [map_size_setting()]
#'
#' @keywords internal
#'
map_static_in_report <- function(n, polygons = FALSE) {

  cap <- if (polygons) {
    map_size_setting("default_max_shapes_map_show_in_downloaded_report")
  } else {
    map_size_setting("default_max_pts_map_show_in_downloaded_report")
  }
  isTRUE(n > cap)
}
############################################################################### #

#' Save a static image (PNG) of a leaflet map
#'
#' @param map leaflet html widget, as from [ejam2map()]
#' @param delay seconds to wait for basemap tiles before the image is taken
#' @param vwidth,vheight size of the image in pixels
#'
#' @return path to a temporary .png file, or NULL if it could not be made
#'   (the caller should delete the file when done with it)
#'
#' @keywords internal
#'
map_png_from_widget <- function(map, delay = pdf_wait_seconds("map_snapshot"), vwidth = 900, vheight = 500) {

  if (is.null(map) || anyNA(map) || length(map) == 0) {return(NULL)}
  map_widget_html  <- tempfile(fileext = ".html")
  map_widget_files <- sub("\\.html$", "_files", map_widget_html)
  map_png          <- tempfile(fileext = ".png")
  on.exit({
    unlink(map_widget_html)
    unlink(map_widget_files, recursive = TRUE)
  }, add = TRUE)
  tryCatch({
    htmlwidgets::saveWidget(map, file = map_widget_html, selfcontained = TRUE)
    # delay is an unconditional pause covering content that arrives after
    # the page load event (mainly leaflet basemap tiles) -- see pdf_wait_seconds()
    webshot2::webshot(map_widget_html, file = map_png, delay = delay, vwidth = vwidth, vheight = vheight)
    if (file.exists(map_png)) map_png else NULL
  }, error = function(e) {
    message("Could not capture static map image: ", conditionMessage(e))
    unlink(map_png)
    NULL
  })
}
############################################################################### #
