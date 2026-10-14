#' Map one EJSCREEN indicator at blockgroup resolution
#'
#' @description Draw a Leaflet choropleth for one county or state using raw
#'   values already in [blockgroupstats] and percentiles from [lookup_pctile()].
#'   No EJAM analysis is run. The map includes indicator values, percentiles,
#'   blockgroup FIPS codes, and population (when available) in its popups.
#' @details Specify exactly one of countyfips or ST. National percentiles are
#'   the default, even when only one county or state is displayed. State
#'   percentiles use that state's lookup distribution, not the selected county.
#'   State demographic and EJ indexes use their state-specific raw scores.
#'   EJ/Supplemental Summary Index scores are read from [bgej] when they are
#'   not already present in blockgroup_data.
#'
#'   Only the selected scope is mapped. Panning or zooming does not load more
#'   blockgroups, and tract aggregation is not provided. Large states can be
#'   slow to download and render. Supply shp to reuse downloaded boundaries.
#' @param indicator One raw indicator name, such as `"pctlowinc"`,
#'   `"proximity.npl"`, or `"EJ.DISPARITY.pm.eo"`. A `"pctile."` or
#'   `"state.pctile."` prefix is also accepted and selects the percentile scope.
#' @param countyfips One five-character county FIPS code, including leading zeros.
#' @param ST One state abbreviation or two-character state FIPS code.
#' @param zoom Optional initial Leaflet zoom level from 0 to 18. If NULL,
#'   fit the view to all selected blockgroup polygons.
#' @param scope `"national"` (default) or `"state"` percentile distribution.
#'   An explicitly supplied scope must agree with any percentile prefix.
#' @param blockgroup_data A data.frame or data.table with bgfips and raw
#'   indicator columns; defaults to the package's blockgroupstats.
#' @param shp Optional sf blockgroup polygons with a FIPS, GEOID, or bgfips
#'   column and a known coordinate reference system. May contain additional
#'   polygons. Missing or empty boundaries are omitted with a warning; duplicate
#'   FIPS matches are rejected. At least one drawable polygon is required.
#' @param lookup Optional percentile lookup table; defaults to usastats or
#'   statestats according to scope. Must contain REGION, PCTILE, and the indicator.
#' @param index_data Optional bgej-like table of Summary Index scores, joined
#'   by bgfips. If needed and omitted, bgej is loaded using [dataload_dynamic()].
#' @param colorbins Percentile bin boundaries INCLUDING 0 and 100. Defaults
#'   to the shared package cutoffs. A cutoff belongs to the higher bin.
#' @param colorfills One fill color per bin, from the shared package defaults.
#' @param colorlabels Optional legend labels, one per bin. Standard bins use
#'   the shared labels; custom bins get interval labels automatically.
#' @param na.color Fill color for missing percentiles, labeled "No data" in
#'   the legend when needed.
#' @param fillOpacity Polygon fill opacity between 0 and 1.
#' @return A Leaflet htmlwidget.
#' @seealso [ejam2map()] [mapfastej_counties()] [shapes_from_fips()]
#' @examples
#' \dontrun{
#' map_ejscreen_indicator("pctlowinc", countyfips = "10001")
#' map_ejscreen_indicator("pctile.proximity.npl", countyfips = "10001", zoom = 10)
#' map_ejscreen_indicator("state.pctile.pctlowinc", ST = "DE")
#' # Reuse boundaries instead of downloading them again.
#' bg <- blockgroupstats[substr(bgfips, 1, 5) == "10001", ]
#' polygons <- shapes_from_fips(bg$bgfips)
#' map_ejscreen_indicator("pm", countyfips = "10001", shp = polygons)
#' }
#' @export
map_ejscreen_indicator <- function(indicator = "pctlowinc", countyfips = NULL,
                                    ST = NULL, zoom = NULL,
                                    scope = c("national", "state"),
                                    blockgroup_data = blockgroupstats, shp = NULL,
                                    lookup = NULL, index_data = NULL,
                                    colorbins = c(0, ejscreen_color_defaults()$colorbins, 100),
                                    colorfills = ejscreen_color_defaults()$colorfills,
                                    colorlabels = NULL, na.color = "#D3D3D3",
                                    fillOpacity = 0.7) {
  if (!is.character(indicator) || length(indicator) != 1L ||
      is.na(indicator) || !nzchar(indicator)) {
    stop("indicator must be one nonempty indicator name", call. = FALSE)
  }
  explicit_scope <- !missing(scope)
  scope <- match.arg(scope)
  prefix_scope <- if (startsWith(indicator, "state.pctile.")) "state" else
    if (startsWith(indicator, "pctile.")) "national" else NULL
  if (!is.null(prefix_scope)) {
    if (explicit_scope && scope != prefix_scope) {
      stop("scope conflicts with the indicator's percentile prefix", call. = FALSE)
    }
    scope <- prefix_scope
    indicator <- sub("^(state[.]pctile[.]|pctile[.])", "", indicator)
  }
  if (is.null(countyfips) == is.null(ST)) {
    stop("Specify exactly one of countyfips or ST", call. = FALSE)
  }
  if (!is.null(countyfips)) {
    if (!is.character(countyfips) || length(countyfips) != 1L ||
        is.na(countyfips) || !grepl("^[0-9]{5}$", countyfips)) {
      stop("countyfips must be one five-character FIPS code", call. = FALSE)
    }
    prefix <- countyfips
    statefips <- substr(countyfips, 1, 2)
  } else {
    if (!is.character(ST) || length(ST) != 1L || is.na(ST)) {
      stop("ST must be one state abbreviation or two-character FIPS code", call. = FALSE)
    }
    statefips <- if (grepl("^[0-9]{2}$", ST)) ST else
      stateinfo$FIPS.ST[match(toupper(ST), stateinfo$ST)]
    prefix <- statefips
  }
  ST <- stateinfo$ST[match(statefips, stateinfo$FIPS.ST)]
  if (is.na(ST)) stop("Unknown state FIPS code or abbreviation", call. = FALSE)
  if (!is.null(zoom) && (!is.numeric(zoom) || length(zoom) != 1L ||
                         !is.finite(zoom) || zoom < 0 || zoom > 18)) {
    stop("zoom must be one number between 0 and 18", call. = FALSE)
  }
  if (!is.numeric(fillOpacity) || length(fillOpacity) != 1L ||
      !is.finite(fillOpacity) || fillOpacity < 0 || fillOpacity > 1) {
    stop("fillOpacity must be between 0 and 1", call. = FALSE)
  }
  if (!is.numeric(colorbins) || length(colorbins) < 2L ||
      any(!is.finite(colorbins)) || any(diff(colorbins) <= 0) ||
      colorbins[1] != 0 || tail(colorbins, 1) != 100) {
    stop("colorbins must increase strictly from 0 to 100", call. = FALSE)
  }
  validate_colorbins(colorbins[-c(1, length(colorbins))], colorfills)
  if (is.null(colorlabels)) {
    defaults <- ejscreen_color_defaults()
    colorlabels <- if (identical(colorbins, c(0, defaults$colorbins, 100))) {
      defaults$colorlabels
    } else {
      paste0(head(colorbins, -1), "-", ifelse(seq_along(colorfills) == length(colorfills),
                                           tail(colorbins, -1), paste0("<", tail(colorbins, -1))))
    }
  }
  if (!is.character(colorlabels) || length(colorlabels) != length(colorfills) || anyNA(colorlabels)) {
    stop("colorlabels must have one label per color bin", call. = FALSE)
  }
  if (!is.data.frame(blockgroup_data) || !"bgfips" %in% names(blockgroup_data)) {
    stop("blockgroup_data must be a table containing bgfips", call. = FALSE)
  }
  keep <- !is.na(blockgroup_data$bgfips) & startsWith(as.character(blockgroup_data$bgfips), prefix)
  selected <- as.data.frame(blockgroup_data[keep, ])
  if (!nrow(selected)) stop("No blockgroups found in the selected scope", call. = FALSE)
  if (anyDuplicated(selected$bgfips) || any(!grepl("^[0-9]{12}$", selected$bgfips))) {
    stop("Selected bgfips must be unique twelve-character FIPS codes", call. = FALSE)
  }
  raw_indicator <- indicator
  if (scope == "state") {
    candidates <- c(paste0("state.", indicator), paste0(indicator, ".State"))
    candidates <- candidates[candidates %in% names(blockgroup_data)]
    if (length(candidates)) raw_indicator <- candidates[1]
    if (startsWith(indicator, "EJ.DISPARITY.")) raw_indicator <- paste0("state.", indicator)
  }
  if (!raw_indicator %in% names(selected) && startsWith(indicator, "EJ.DISPARITY.")) {
    if (is.null(index_data)) {
      if (!exists("bgej")) dataload_dynamic("bgej", silent = TRUE)
      if (!exists("bgej")) stop("Could not load bgej Summary Index scores", call. = FALSE)
      index_data <- get("bgej", inherits = TRUE)
    }
    if (!is.data.frame(index_data) || !all(c("bgfips", raw_indicator) %in% names(index_data))) {
      stop("index_data must contain bgfips and the requested Summary Index", call. = FALSE)
    }
    indexes <- as.data.frame(index_data[index_data$bgfips %in% selected$bgfips, ])
    index_positions <- match(selected$bgfips, indexes$bgfips)
    if (anyDuplicated(indexes$bgfips) || anyNA(index_positions)) {
      stop("index_data must have exactly one score row per selected blockgroup", call. = FALSE)
    }
    selected[[raw_indicator]] <- indexes[[raw_indicator]][index_positions]
  }
  if (!raw_indicator %in% names(selected)) {
    stop(sprintf("Indicator '%s' was not found in blockgroup_data", indicator), call. = FALSE)
  }
  if (!is.numeric(selected[[raw_indicator]])) {
    stop("The indicator must contain numeric values", call. = FALSE)
  }
  if (is.null(lookup)) lookup <- if (scope == "national") usastats else statestats
  lookup_indicator <- if (raw_indicator %in% names(lookup)) raw_indicator else indicator
  zone <- if (scope == "national") "USA" else ST
  if (!is.data.frame(lookup) || !all(c("REGION", "PCTILE", lookup_indicator) %in% names(lookup)) ||
      !zone %in% lookup$REGION) {
    stop("The lookup table must contain the indicator and requested percentile region", call. = FALSE)
  }
  percentiles <- lookup_pctile(selected[[raw_indicator]], lookup_indicator,
                               lookup = lookup, zone = zone, snap_tol = 0)
  if (is.null(shp)) {
    # Keep each request within the boundary helper's 50-blockgroup batch size.
    batches <- split(seq_along(selected$bgfips), ceiling(seq_along(selected$bgfips) / 50))
    shp <- do.call(rbind, lapply(batches, function(i) shapes_from_fips(selected$bgfips[i])))
  }
  if (!inherits(shp, "sf") || is.na(sf::st_crs(shp))) {
    stop("shp must be sf polygons with a known coordinate reference system", call. = FALSE)
  }
  idcolumn <- intersect(c("FIPS", "GEOID", "bgfips"), names(shp))[1]
  if (is.na(idcolumn)) stop("shp must contain FIPS, GEOID, or bgfips", call. = FALSE)
  ids <- as.character(shp[[idcolumn]])
  if (anyDuplicated(ids[ids %in% selected$bgfips])) {
    stop("shp contains duplicate blockgroup FIPS codes", call. = FALSE)
  }
  positions <- match(selected$bgfips, ids)
  available <- !is.na(positions)
  matched <- shp[positions[available], ]
  empty <- sf::st_is_empty(matched)
  if (any(!empty & !as.character(sf::st_geometry_type(matched)) %in% c("POLYGON", "MULTIPOLYGON"))) {
    stop("shp must contain polygons", call. = FALSE)
  }
  available[available] <- !empty
  if (!any(available)) stop("No selected blockgroups have drawable polygons", call. = FALSE)
  if (any(!available)) {
    warning(sprintf("Omitting %s blockgroup(s) with missing or empty boundaries: %s",
                    sum(!available), paste(head(selected$bgfips[!available], 5), collapse = ", ")),
            call. = FALSE)
  }
  selected <- selected[available, , drop = FALSE]
  percentiles <- percentiles[available]
  shp <- sf::st_transform(shp[positions[available], ], 4326)
  popup_df <- selected[, intersect(c("bgfips", raw_indicator, "pop"), names(selected)), drop = FALSE]
  formatted_columns <- intersect(names(popup_df), map_headernames$rname)
  if (length(formatted_columns)) popup_df <- format_ejamit_columns(popup_df, nms = formatted_columns)
  popup_df$percentile <- ifelse(is.na(percentiles), "No data", format(round(percentiles, 1), trim = TRUE))
  label <- fixcolnames(indicator, "r", "long")
  percentile_label <- paste(if (scope == "national") "US" else ST, "percentile")
  popup_labels <- c(bgfips = "Blockgroup FIPS", pop = "Population", percentile = percentile_label)
  popup_labels[raw_indicator] <- label
  popup <- popup_from_any(popup_df, labels = unname(popup_labels[names(popup_df)]))
  colors <- pctile2colorhex(percentiles, colorbins = colorbins, colorfills = colorfills, na.color = na.color)
  map <- leaflet::leaflet(shp) |>
    leaflet::addTiles() |>
    leaflet::addPolygons(color = "#555555", weight = 0.5, fillColor = colors,
                         fillOpacity = fillOpacity, popup = popup,
                         label = paste0(selected$bgfips, ": ", popup_df$percentile))
  legend_colors <- unname(pctile2colorhex(head(colorbins, -1), colorbins, colorfills))
  legend_labels <- colorlabels
  if (anyNA(percentiles)) {
    legend_colors <- c(legend_colors, na.color)
    legend_labels <- c(legend_labels, "No data")
  }
  map <- leaflet::addLegend(map, colors = legend_colors, labels = legend_labels,
                            title = htmltools::htmlEscape(paste0(label, " (", percentile_label, ")")),
                            opacity = fillOpacity)
  bb <- sf::st_bbox(shp)
  if (is.null(zoom)) {
    leaflet::fitBounds(map, bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]])
  } else {
    leaflet::setView(map, mean(bb[c("xmin", "xmax")]), mean(bb[c("ymin", "ymax")]), zoom = zoom)
  }
}
