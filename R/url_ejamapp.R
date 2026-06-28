

#' Build a URL that launches the live EJAM app, optionally pre-loaded with sites
#'
#' Construct a deep link to the EJAM web app. With no site arguments it returns
#' the bare app URL. Given points, FIPS codes, a polygon shapefile, or a handoff
#' token, it appends launch query parameters that the deployed app reads at
#' startup to pre-select those places, so it opens ready to run. This is the way
#' to hand a set of places to an already-running app via a URL (for example, the
#' EJScreen "Send to EJAM" button); the deploy-time alternative is the parameters
#' of [ejamapp()].
#'
#' The query vocabulary matches [url_ejamapi()]: `lat`, `lon`, `fips`,
#' `shape` (GeoJSON text), `radius`, and `handoff`. Only one place-type is used
#' per launch (points, else FIPS, else polygons), matching the app's
#' one-method-per-analysis model. See the launch-URL handler described in the
#' "Defaults and Custom Settings for the Web App" vignette.
#'
#' Large or numerous polygons may not fit in a URL. For those, POST them to the
#' EJAM API `/handoff` endpoint and pass the returned token as `handoff`; the app
#' then fetches the places back from `GET /handoff/<token>` at startup.
#'
#' @param sitepoints data.frame with columns lat and lon (alternative to lat/lon)
#' @param lat,lon coordinate vector(s) of point(s), each treated as a site
#' @param fips vector of FIPS codes, each treated as a separate site
#' @param shapefile an sf polygon/multipolygon object (or ready-made GeoJSON text), encoded as simplified GeoJSON
#' @param shape alias (synonym) for shapefile
#' @param shp alias (synonym) for shapefile
#' @param radius analysis radius in miles (the buffer around points or out from polygon edges)
#' @param buffer alias (synonym) for radius ("buffer" reads more naturally for FIPS or polygon analysis)
#' @param handoff a token previously returned by the EJAM API `POST /handoff`.
#'   When supplied, the other site arguments are ignored and the app fetches the
#'   places back from `GET /handoff/<token>` at startup (the scalable path for
#'   many/large polygons).
#' @param dTolerance meters tolerance for [sf::st_simplify()] so a polygon fits in a URL
#' @param baseurl base URL of the live EJAM app. The default is a tidy
#'   `ejanalysis.com` shortcut. If `baseurl` is a redirect/shortcut, the redirect
#'   must forward the query string so the launch parameters reach the app.
#' @param browse set TRUE to open the URL in a browser (if interactive)
#' @returns URL (character) for the live EJAM app
#' @seealso [url_ejamapi()] [ejamapi()] [ejamapp()] [url_ejscreenmap()]
#'
#' @examples
#'  url_ejamapp()
#'  url_ejamapp(lat = c(33, 34), lon = c(-112, -114), radius = 3)
#'  url_ejamapp(fips = c("10001", "10003"))
#'  url_ejamapp(handoff = "abc123token")
#'
#' @export
#'
url_ejamapp <- function(sitepoints = NULL, lat = NULL, lon = NULL,
                        fips = NULL, shapefile = NULL, shape = NULL,
                        radius = NULL, buffer = NULL,
                        handoff = NULL, dTolerance = 100,
                        baseurl = "https://ejanalysis.com/ejamapp",
                        browse = FALSE, shp = NULL) {

  # Aliases (synonyms): buffer for radius, shape/shp for shapefile.
  if (is.null(radius)) {radius <- buffer}
  if (is.null(shapefile)) {shapefile <- shape}
  if (is.null(shapefile) && !is.null(shp)) {shapefile <- shp}

  if (!is.null(sitepoints)) {
    lat <- sitepoints$lat
    lon <- sitepoints$lon
  }

  # Build the launch query, one place-type per launch (points, else FIPS, else polygons).
  # The vocabulary matches url_ejamapi() so one convention serves both the API and the app.
  q <- character(0)
  if (!is.null(handoff)) {
    q <- c(q, paste0("handoff=", utils::URLencode(as.character(handoff)[1], reserved = TRUE)))
  } else if (!is.null(lat) && !is.null(lon)) {
    if (length(lat) != length(lon)) {
      stop("lat and lon must have the same length")
    }
    q <- c(q, paste0("lat=", paste(lat, collapse = ",")),
              paste0("lon=", paste(lon, collapse = ",")))
  } else if (!is.null(fips)) {
    q <- c(q, paste0("fips=", paste(fips, collapse = ",")))
  } else if (!is.null(shapefile)) {
    # accept either an sf object or ready-made GeoJSON text; simplify sf polygons
    # so the GeoJSON fits in a URL, like url_ejamapi() does
    # combine_in_one_string = TRUE so multi-polygon sf becomes ONE FeatureCollection
    # string (otherwise shape2geojson() returns a vector and geotxt[1] would drop all
    # but the first polygon).
    geotxt <- if (is.character(shapefile)) shapefile else shape2geojson(sf::st_simplify(shapefile, dTolerance = dTolerance), combine_in_one_string = TRUE)
    q <- c(q, paste0("shape=", utils::URLencode(geotxt[1], reserved = TRUE)))
  }
  if (is.null(handoff) && !is.null(radius)) {
    q <- c(q, paste0("radius=", radius[1]))  # a single radius applies to all sites
  }

  urlx <- if (length(q) > 0) paste0(baseurl, "?", paste(q, collapse = "&")) else baseurl

  if (browse && interactive()) {
    browseURL(urlx)
  }
  return(urlx)
}
