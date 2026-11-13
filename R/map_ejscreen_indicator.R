#' Map one EJSCREEN indicator at blockgroup resolution
#'
#' @md
#' @description Draw a Leaflet or ggplot choropleth for one county or state using raw
#'   values already in [blockgroupstats] and percentiles from [lookup_pctile()].
#'   No EJAM analysis is run. The Leaflet map includes indicator values, percentiles,
#'   blockgroup FIPS codes, and population (when available) in its popups.
#' @details Specify exactly one of countyfips or ST. National percentiles are
#'   the default, even when only one county or state is displayed. State
#'   percentiles use that state's lookup distribution, not the selected county.
#'   State demographic and EJ indexes use their state-specific raw scores.
#'   EJ/Supplemental Summary Index scores are read from [bgej] when they are
#'   not already present in blockgroup_data.
#'
#'   Only the selected scope is mapped. Panning or zooming does not load more
#'   blockgroups, and tract aggregation is not provided. Boundaries are downloaded
#'   as one state file through tigris and cached for reuse. Generalized cartographic
#'   boundaries are the default; large states can still take time to render.
#'   Supply shp to reuse polygons without downloading anything.
#' @param indicator One raw indicator name, such as `"pctlowinc"`,
#'   `"proximity.npl"`, or `"EJ.DISPARITY.pm.eo"`. A `"pctile."` or
#'   `"state.pctile."` prefix is also accepted and selects the percentile scope.
#' @param countyfips One county FIPS code, or a FIPS code whose parent county
#'   can be resolved by [fips2countyfips()]. Numeric codes are normalized to
#'   include leading zeros.
#' @param ST One state abbreviation, state name, or two-digit state FIPS code.
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
#' @param maptype Either "leaflet" (default) for an interactive map or "ggplot"
#'   for a static map using the same percentile colors and legend. zoom is only
#'   used by Leaflet.
#' @param year Census boundary year; defaults to [acs_endyear()] to match the
#'   package's ACS data vintage. Ignored when shp is supplied.
#' @param label,units Optional display label and units for a custom indicator.
#'   Explicit values override the metadata.
#' @param mydata_map_headernames Optional custom metadata table with rname,
#'   longname, and units columns; an optional source column supplies popup notes.
#' @param source Optional source note for popups, overriding metadata.
#' @param colorby Color by percentiles, raw values, or automatically use raw
#'   values when the reference lacks the indicator or region (the default).
#'   In raw mode colorbins are raw-value boundaries covering all finite values;
#'   omitted bins are generated from the data range. Missing values keep the
#'   No data style. A raw map never labels its colors as percentiles.
#' @param cb TRUE (default) for smaller generalized cartographic boundaries;
#'   FALSE for detailed TIGER/Line boundaries. Generalized boundaries are much
#'   faster to download and draw, but simplified and clipped along shorelines;
#'   use them for overview maps, not precise spatial analysis. Both choices
#'   reuse cached state files. Ignored when shp is supplied.
#' @return A Leaflet htmlwidget or a ggplot object. The ggplot object's data
#'   contains the selected raw indicator values, .map_value (the values used
#'   for coloring), and .map_percentile (NA when coloring raw values).
#' @seealso [ejam2map()] [mapfastej_counties()] [shapes_from_fips()]
#' @examples
#' \dontrun{
#' map_ejscreen_indicator("pctlowinc", countyfips = fips_from_name("Cook County, IL"))
#' map_ejscreen_indicator("pctlowinc", countyfips = "10001")
#' map_ejscreen_indicator("pctile.proximity.npl", countyfips = "10001", zoom = 10)
#' map_ejscreen_indicator("state.pctile.pctlowinc", ST = "DE")
#' map_ejscreen_indicator("pctlowinc", ST = "IL")
#' map_ejscreen_indicator("pctlowinc", ST = "IL", maptype = "ggplot")
#' # A custom one-county table needs no national reference.
#' custom <- data.frame(bgfips = c("100010401001", "100010401002"),
#'                      myscore = c(12, 28))
#' map_ejscreen_indicator("myscore", countyfips = "10001", blockgroup_data = custom,
#'                        label = "My indicator", units = "ppb", source = "Local study")
#' # For site results, use existing helpers, for example:
#' site_results <- data.frame(lat = c(39.1, 39.2), lon = c(-75.5, -75.6),
#'                            myscore = c(12, 28))
#' mapfast(site_results, column_names = "myscore", labels = "My indicator")
#' # Reuse boundaries instead of downloading them again.
#' bg <- blockgroupstats[substr(bgfips, 1, 5) == "10001", ]
#' polygons <- shapes_from_fips(bg$bgfips)
#' map_ejscreen_indicator("pm", countyfips = "10001", shp = polygons)
#' }
#' @export
#'
map_ejscreen_indicator <- function(indicator = "pctlowinc", countyfips = NULL,
                                   ST = NULL, zoom = NULL,
                                   scope = c("national", "state"),
                                   blockgroup_data = blockgroupstats, shp = NULL,
                                   lookup = NULL, index_data = NULL,
                                   colorbins = c(0, ejscreen_color_defaults()$colorbins, 100),
                                   colorfills = ejscreen_color_defaults()$colorfills,
                                   colorlabels = NULL, na.color = "#D3D3D3",
                                   fillOpacity = 0.7,
                                   maptype = c("leaflet", "ggplot"),
                                   year = NULL, cb = TRUE,
                                   label = NULL, units = NULL,
                                   mydata_map_headernames = NULL, source = NULL,
                                   colorby = c("auto", "percentile", "raw")) {
  colorby <- match.arg(colorby)
  automatic_bins <- missing(colorbins)
  automatic_fills <- missing(colorfills)
  maptype <- match.arg(maptype)
  if (!is.character(indicator) || length(indicator) != 1L ||
      is.na(indicator) || !nzchar(indicator)) {
    stop("indicator must be one nonempty indicator name", call. = FALSE)
  }
  explicit_scope <- !missing(scope)
  scope <- match.arg(scope)
  # what indicator to map? ####
  prefix_scope <- if (startsWith(indicator, "state.pctile.")) "state" else
    if (startsWith(indicator, "pctile.")) "national" else NULL
  if (!is.null(prefix_scope)) {
    if (explicit_scope && scope != prefix_scope) {
      stop("scope conflicts with the indicator's percentile prefix", call. = FALSE)
    }
    scope <- prefix_scope
    indicator <- sub("^(state[.]pctile[.]|pctile[.])", "", indicator)
  }
  # what County or State? ####

  if (is.null(countyfips) == is.null(ST)) {
    stop("Specify exactly one of countyfips or ST", call. = FALSE)
  }
  if (!is.null(countyfips)) {
    # figure out county
    countyfips <- fips2countyfips(countyfips)
    if (!is.character(countyfips) || length(countyfips) != 1L ||
        is.na(countyfips) || !grepl("^[0-9]{5}$", countyfips)) {
      stop("countyfips must be a valid five-character FIPS code or interpretable as such", call. = FALSE)
    }
    prefix <- countyfips
    statefips <- substr(countyfips, 1, 2)
  } else {
    # figure out State
    statefips <- if (length(ST) == 1L && !is.na(ST) &&
                     grepl("^[0-9]{2}$", as.character(ST))) {
      as.character(ST)
    } else {
      suppressWarnings(fips_state_from_state_abbrev(ST))
    }
    if (length(statefips) != 1L || is.na(statefips) || !statefips %in% stateinfo$FIPS.ST) {
      stop("ST must be a valid two-character state abbreviation or a two-character FIPS code or interpretable as such", call. = FALSE)
    }
    prefix <- statefips
  }
  ST <- fips2state_abbrev(statefips)

  # zoom level ####
  if (!is.null(zoom) && (!is.numeric(zoom) || length(zoom) != 1L ||
                         !is.finite(zoom) || zoom < 0 || zoom > 18)) {
    stop("zoom must be one number between 0 and 18", call. = FALSE)
  }
  # colors to use for color-coded bins ####
  if (!is.numeric(fillOpacity) || length(fillOpacity) != 1L ||
      !is.finite(fillOpacity) || fillOpacity < 0 || fillOpacity > 1) {
    stop("fillOpacity must be between 0 and 1", call. = FALSE)
  }
  # what blockgroup data to use? ####
  if (!is.data.frame(blockgroup_data) || !"bgfips" %in% names(blockgroup_data)) {
    stop("blockgroup_data must be a table containing bgfips", call. = FALSE)
  }
  keep <- !is.na(blockgroup_data$bgfips) & startsWith(as.character(blockgroup_data$bgfips), prefix)
  selected <- as.data.frame(blockgroup_data[keep, ])
  if (!nrow(selected)) stop("No blockgroups found in the selected scope", call. = FALSE)
  if (anyDuplicated(selected$bgfips) || any(!grepl("^[0-9]{12}$", selected$bgfips))) {
    stop("Selected bgfips must be unique twelve-character FIPS codes", call. = FALSE)
  }
  # . ###########################################################################
  # WHAT INDICATOR ?  (state vs US, EJ index vs other, etc.) ####

  ##   RAW vs EJ INDEX ? ####

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

  ## PERCENTILES ? *** ####

  if (is.null(lookup)) lookup <- if (scope == "national") usastats else statestats
  lookup_indicator <- if (raw_indicator %in% names(lookup)) raw_indicator else indicator
  zone <- if (scope == "national") "USA" else ST
  has_lookup <- is.data.frame(lookup) && all(c("REGION", "PCTILE", lookup_indicator) %in% names(lookup)) &&
    zone %in% lookup$REGION
  use_percentiles <- colorby != "raw" && has_lookup
  if (colorby == "percentile" && !has_lookup) {
    stop("The lookup table must contain the indicator and requested percentile region", call. = FALSE)
  }
  if (!use_percentiles && colorby == "auto") {
    message("No reference for this indicator and region; coloring by raw values")
  }
  percentiles <- if (use_percentiles) {
    lookup_pctile(selected[[raw_indicator]], lookup_indicator, lookup = lookup, zone = zone, snap_tol = 0)
  } else {rep(NA_real_, nrow(selected))}
  map_values <- if (use_percentiles) percentiles else selected[[raw_indicator]]
  map_values[!is.finite(map_values)] <- NA_real_
  percentile_label <- if (use_percentiles) paste(if (scope == "national") "US" else ST, "percentile") else "Raw value"

  # Explicit arguments override optional custom metadata.
  metadata <- data.frame()
  if (!is.null(mydata_map_headernames)) {
    if (!is.data.frame(mydata_map_headernames) || !all(c("rname", "longname", "units") %in% names(mydata_map_headernames))) {
      stop("mydata_map_headernames must contain rname, longname, and units", call. = FALSE)
    }
    metadata <- mydata_map_headernames[mydata_map_headernames$rname %in% indicator, , drop = FALSE]
    if (nrow(metadata) > 1L) stop("Custom metadata must have one row per indicator", call. = FALSE)
  }
  if (is.null(label)) label <- if (nrow(metadata) == 1L) as.character(metadata$longname) else fixcolnames(indicator, "r", "long")
  if (is.null(units)) units <- if (nrow(metadata) == 1L) as.character(metadata$units) else ""
  if (is.null(source)) source <- if (nrow(metadata) == 1L && "source" %in% names(metadata)) as.character(metadata$source) else ""
  if (is.na(units)) units <- ""
  if (is.na(source)) source <- ""
  if (!is.character(label) || length(label) != 1L || is.na(label) || !nzchar(label) ||
      !is.character(units) || length(units) != 1L || !is.character(source) || length(source) != 1L) {
    stop("label, units, and source must each be one character string", call. = FALSE)
  }
  if (nzchar(units)) label <- paste0(label, " (", units, ")")

  if (!use_percentiles && automatic_bins) {
    limits <- if (any(!is.na(map_values))) range(map_values, na.rm = TRUE) else c(0, 1)
    if (limits[1] == limits[2]) limits <- limits + c(-1, 1) * max(0.5, abs(limits[1]) * 0.01)
    colorbins <- seq(limits[1], limits[2], length.out = length(colorfills) + 1L)
  }
  if (!is.numeric(colorbins) || length(colorbins) < 2L || any(!is.finite(colorbins)) || any(diff(colorbins) <= 0)) {
    stop("colorbins must increase strictly (percentiles: from 0 to 100)", call. = FALSE)
  }
  if (use_percentiles && (colorbins[1] != 0 || tail(colorbins, 1) != 100)) {
    stop("colorbins must increase strictly from 0 to 100", call. = FALSE)
  }
  if (!use_percentiles && any(map_values < colorbins[1] | map_values > tail(colorbins, 1), na.rm = TRUE)) {
    stop("Raw colorbins must cover all finite indicator values", call. = FALSE)
  }
  if (!use_percentiles && automatic_fills && length(colorfills) != length(colorbins) - 1L) {
    colorfills <- grDevices::colorRampPalette(colorfills)(length(colorbins) - 1L)
  }
  if (length(colorfills) != length(colorbins) - 1L) stop("Supply one color per bin", call. = FALSE)
  # Validate colors and retain the package's hexadecimal output convention.
  colorfills <- grDevices::rgb(t(grDevices::col2rgb(colorfills)), maxColorValue = 255)
  if (is.null(colorlabels)) {
    defaults <- ejscreen_color_defaults()
    colorlabels <- if (use_percentiles && identical(colorbins, c(0, defaults$colorbins, 100))) {
      defaults$colorlabels
    } else {
      paste0(signif(head(colorbins, -1), 6), "-", ifelse(seq_along(colorfills) == length(colorfills),
                signif(tail(colorbins, -1), 6), paste0("<", signif(tail(colorbins, -1), 6))))
    }
  }
  if (!is.character(colorlabels) || length(colorlabels) != length(colorfills) || anyNA(colorlabels)) {
    stop("colorlabels must have one label per color bin", call. = FALSE)
  }
  # . ###########################################################################

  # get polygons ####

  if (is.null(shp)) {
    if (!is.logical(cb) || length(cb) != 1L || is.na(cb)) {
      stop("cb must be TRUE or FALSE", call. = FALSE)
    }
    shp <- shapes_from_fips(as.character(selected$bgfips),
                            myservice_blockgroup = if (cb) "cartographic" else "tiger",
                            year = if (is.null(year)) acs_endyear() else year)
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
  map_values <- map_values[available]
  shp <- sf::st_transform(shp[positions[available], ], 4326)

  # use ggplot to draw map ####
  if (maptype == "ggplot") {
    return(plot_ejscreen_indicator(shp, selected, map_values,
                                   label = label, percentile_label = percentile_label,
                                   colorbins = colorbins, colorfills = colorfills,
                                   colorlabels = colorlabels, na.color = na.color,
                                   fillOpacity = fillOpacity, use_percentiles = use_percentiles))
  }
  # use leaflet to draw map ####
  popup_df <- selected[, intersect(c("bgfips", raw_indicator, "pop"), names(selected)), drop = FALSE]
  formatted_columns <- intersect(names(popup_df), map_headernames$rname)
  if (length(formatted_columns)) popup_df <- format_ejamit_columns(popup_df, nms = formatted_columns)
  popup_df$percentile <- ifelse(is.na(map_values), "No data", format(signif(map_values, 6), trim = TRUE))
  if (nzchar(source)) popup_df$source <- source
  popup_labels <- c(bgfips = "Blockgroup FIPS", pop = "Population", percentile = percentile_label, source = "Source")
  popup_labels[raw_indicator] <- label
  popup <- popup_from_any(popup_df, labels = unname(popup_labels[names(popup_df)]))
  colors <- map_ejscreen_indicator_colors(map_values, colorbins, colorfills, na.color)
  map <- leaflet::leaflet(shp) |>
    leaflet::addTiles() |>
    leaflet::addPolygons(color = "#555555", weight = 0.5, fillColor = colors,
                         fillOpacity = fillOpacity, popup = popup,
                         label = paste0(selected$bgfips, ": ", popup_df$percentile))
  legend_colors <- unname(colorfills)
  legend_labels <- colorlabels
  if (anyNA(map_values)) {
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

# Use ggplot instead of leaflet to map an EJSCREEN indicator
# color-coded by percentiles.
# Both renderers use the same percentile bins, including exact cutoffs and
# missing values. Retain the raw indicators in the ggplot object's sf data.

plot_ejscreen_indicator <- function(shp,
                                    selected,
                                    percentiles,
                                    label,
                                    percentile_label,
                                    colorbins, colorfills, colorlabels,
                                    na.color, fillOpacity, use_percentiles = TRUE) {

  plotdata <- sf::st_sf(selected, geometry = sf::st_geometry(shp))

  plotdata$.map_percentile <- if (use_percentiles) percentiles else NA_real_
  plotdata$.map_value <- percentiles
  bin <- findInterval(percentiles, colorbins, rightmost.closed = TRUE)
  bin[is.na(percentiles)] <- length(colorfills) + 1L
  plotdata$.map_bin <- factor(bin, levels = seq_len(length(colorfills) + anyNA(percentiles)))
  legend_colors <- unname(colorfills)
  legend_labels <- colorlabels
  if (anyNA(percentiles)) {
    legend_colors <- c(legend_colors, na.color)
    legend_labels <- c(legend_labels, "No data")
  }

  ggplot2::ggplot(plotdata,
                  ggplot2::aes(fill = !!rlang::sym(".map_bin"))) +
    ggplot2::geom_sf(color = NA, alpha = fillOpacity) +
    ggplot2::scale_fill_manual(values = legend_colors,
                               labels = legend_labels,
                               drop = FALSE,
                               name = paste0(label, " (", percentile_label, ")")) +
    ggplot2::coord_sf(datum = NA) +
    ggplot2::labs(title = label) +
    ggplot2::theme_void()
}
# ########################################################################## #

# Shared raw/percentile bin membership for Leaflet and ggplot.
map_ejscreen_indicator_colors <- function(values, bins, fills, na.color) {
  bin <- findInterval(values, bins, rightmost.closed = TRUE)
  colors <- unname(fills[bin])
  colors[is.na(values)] <- na.color
  colors
}
