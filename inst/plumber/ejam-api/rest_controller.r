# Load necessary libraries
library(rlang)
library(plumber)
library(EJAM)
library(geojsonsf)
library(jsonlite)
library(sf)

source("query_pagination.R", local = TRUE)

############################# #
#* @apiTitle API for EJAM / EJSCREEN Data, Analysis, and Reports
#*
#* @apiDescription EJSCREEN provides environmental justice screening and mapping.
#* EJSCREEN's Multisite Tool is called EJAM (Environmental Justice Analysis Multisite).
#* For information about EJSCREEN, see <https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen.html>.
#* For technical documentation on EJAM (software powering the API) see
#* <https://ejanalysis.org/ejamdocs>.
#* For information on the API itself, see
#* <https://github.com/Public-Environmental-Data-Partners/EJAM-API#ejam-api>
############################# #

# HTML-escape a string so it is safe to interpolate into an HTML error page,
# preventing broken markup or reflected injection if a message ever contains
# user-influenced text. Escape & first so the entity ampersands we add are not
# themselves double-escaped.
escape_html <- function(x) {
  x <- gsub("&", "&amp;",  x, fixed = TRUE)
  x <- gsub("<", "&lt;",   x, fixed = TRUE)
  x <- gsub(">", "&gt;",   x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&#39;",  x, fixed = TRUE)
  x
}

# Centralized error handling function
handle_error <- function(message, type = "json") {
  if (type == "html") {
    # Escape the message: HTML error pages are rendered in the browser, so any
    # special characters in the message must not be treated as markup.
    return(paste0("<html><body><h3>Error</h3><p>", escape_html(message), "</p></body></html>"))
  }
  return(list(error = message))
}

# Write an HTML error page to the response with the right status and an
# explicit text/html Content-Type, then return the response object. The
# /report endpoints use an octet-stream @serializer (so finished report bytes
# pass through untouched); returning a bare string there would label these
# error pages as application/octet-stream and make browsers download them.
# Returning the response object with Content-Type set -- as report_response()
# does for successful reports -- delivers the error as a viewable page.
html_error <- function(res, status, message) {
  res$status <- status
  res$setHeader("Content-Type", "text/html")
  # Never let an error page be cached at the edge (successful GET /report
  # responses are cacheable -- see report_response()).
  res$setHeader("Cache-Control", "no-store")
  res$body <- handle_error(message, "html")
  res
}

# The fipper function processes FIPS inputs, converting area names (e.g., states)
# to the appropriate FIPS codes for the specified scale (e.g., counties).
fipper <- function(area, scale = "blockgroup") {
  fips_area <- tryCatch(
    name2fips(area),
    warning = function(w) {
      # If a warning occurs, it's likely the input is already a FIPS code.
      return(area)
    }
  )
  
  # Determine the type of the provided FIPS code.
  fips_type <- fipstype(fips_area)[1]
  
  if (fips_type == scale) {
    return(fips_area)
  }
  
  # Convert the FIPS code to the desired scale.
  switch(scale,
         "county" = fips_counties_from_statefips(fips_area),
         "blockgroup" = fips_bgs_in_fips(fips_area),
         fips_area # Default to returning the original FIPS if the scale is not recognized.
  )
}

# The ejamit_interface function serves as a unified interface for the ejamit function,
# handling various input methods such as latitude/longitude, shapes (SHP), and FIPS codes.
ejamit_interface <- function(area, method, buffer = 0, scale = "blockgroup", endpoint="report") {
  # Validate buffer size to ensure it's within a reasonable limit.
  if (!is.numeric(buffer) || buffer > 15) {
    stop("Please select a buffer of 15 miles or less.")
  }
  
  # Process the request based on the specified method.
  switch(method,
         "latlon" = {
           # Ensure the area is a data frame before passing it to ejamit.
           if (!is.data.frame(area)) {
             stop("Invalid coordinates provided.")
           }
           ejamit(sitepoints = area, radius = buffer)
         },
         "SHP" = {
           # Convert the GeoJSON input to an sf object.
           sf_area <- tryCatch(
             geojson_sf(area),
             error = function(e) stop("Invalid GeoJSON provided.")
           )
           ejamit(shapefile = sf_area, radius = buffer)
         },
         "FIPS" = {
           # Process the FIPS code using the fipper function.
           if (endpoint == "data"){
             fips_codes <- fipper(area = area, scale = scale)
           } else if (endpoint == "report") {
             fips_codes <- area
           }
           ejamit(fips = fips_codes, radius = buffer)
         },
         stop("Invalid method specified.") # Handle unrecognized methods.
  )
}

#* CORS support so browser apps (e.g. EJScreen) can fetch()/POST cross-origin.
#* The single-site report flow uses a top-level window.open() GET and needs no
#* CORS, but the /handoff POST and any future POST endpoints do. Public data API,
#* so origin is open; tighten to specific origins here if ever needed.
#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (identical(req$REQUEST_METHOD, "OPTIONS")) {
    # Respond to the CORS preflight request directly.
    res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    res$setHeader(
      "Access-Control-Allow-Headers",
      req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS %||% "Content-Type"
    )
    res$status <- 200L
    return(list())
  }
  plumber::forward()
}

# ________________________________ ####
# Docs ####

#* Redirect the API root to the interactive documentation page, so visiting the
#* base URL (no endpoint or parameters) shows the Swagger UI.
#* @tag Docs
#* @get /
function(res) {
  res$status <- 302L
  res$setHeader("Location", "/__docs__/")
  list()
}

# /data ####

#* Return EJAM analysis data as JSON based on geography
#* @tag Data
#* @param sites A data frame of site coordinates (lat/lon)
#* @param shape A GeoJSON string representing the area of interest
#* @param fips A FIPS code for a specific US Census geography
#* @param buffer The buffer radius in miles
#* @param radius Synonym for buffer.
#* @param geometries A boolean to indicate whether to include geometries in the output
#* @param scale The Census geography at which to return results (blockgroup or county)
#* @post /data
function(sites = NULL, shape = NULL, fips = NULL, buffer = 0, radius = NULL, geometries = FALSE, scale = NULL, res) {
  if (!is.null(radius)) {buffer <- radius}  # radius is a synonym (alias) for buffer
  # Determine the input method.
  method <- if (!is.null(sites)) "latlon" else if (!is.null(shape)) "SHP" else if (!is.null(fips)) "FIPS" else NULL
  area <- sites %||% shape %||% fips
  
  if (is.null(method) || is.null(area)) {
    res$status <- 400
    return(handle_error("You must provide valid points, a shape, or a FIPS code."))
  }
  
  # Perform the EJAM analysis.
  result <- tryCatch(
    ejamit_interface(area = area, method = method, buffer = as.numeric(buffer), scale = scale, endpoint = "data"),
    error = function(e) {
      res$status <- 400
      handle_error(e$message)
    }
  )
  
  # If an error was returned from the interface, return it.
  if ("error" %in% names(result)) {
    return(result)
  }
  
  # Prepare the final JSON output.
  if (geometries) {
    output_shape <- switch(method,
                           "latlon" = sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326),
                           "SHP" = geojson_sf(shape),
                           "FIPS" = shapes_from_fips(fips)
    )
    # Combine the analysis results with the geographic shapes.
    return(cbind(data.table::setDF(result$results_bysite), output_shape))
  } else {
    return(result$results_bysite)
  }
}

# /query ####

#* Return EJAM analysis data as JSON based on attribute query
#* Query responses are paginated. Use page and limit to request subsequent pages.
#* @tag Data
#* @param attribute An EJSCREEN attribute, in EJAM syntax (e.g. pctunemployed)
#* @param value A decimal, 0-1, representing a cutoff/threshold; returns blockgroups whose percentile rank for the attribute is larger (e.g. pctunemployed > .9)
#* @param page Positive whole-number page to return. Defaults to 1.
#* @param limit Positive whole-number rows per page. Defaults to 100 and cannot exceed 500.
#* @post /query
function(attribute = "pctunemployed", value = .9, page = 1, limit = QUERY_DEFAULT_LIMIT, res) {
  query_endpoint_response(
    attribute = attribute,
    value = value,
    page = page,
    limit = limit,
    res = res,
    error_handler = handle_error
  )
}

# /report ####

# Normalize the sitenumber value shared by GET /report and POST /report.
# Returns 0 for 0/"overall" (aggregate multisite report), a positive whole
# number N (which site to report on -- and, for a one-site submission, the
# "Site N" display label), the endpoint's default when omitted/empty, or NULL
# when invalid -- the caller must then return a 400. Values such as 1.5, Inf,
# -2, or "abc" are rejected rather than silently falling back, because N can
# flow into the report header as a label: the contract is a positive whole
# original-analysis row number.
normalize_sitenumber <- function(sitenumber, default) {
  if (length(sitenumber) > 1) sitenumber <- sitenumber[[1]]  # e.g. a repeated query param
  if (is.null(sitenumber)) return(default)
  chr <- trimws(as.character(sitenumber))
  if (identical(chr, "")) return(default)
  if (identical(tolower(chr), "overall")) return(0)
  n <- suppressWarnings(as.numeric(chr))
  if (length(n) != 1 || is.na(n) || !is.finite(n) || n < 0 || n != trunc(n)) return(NULL)
  n
}

# Render an ejamit() result as an EJAM report and write it to the plumber
# response as HTML or PDF. Shared by GET /report (one value per param) and
# POST /report (JSON body; supports many/large polygons and mixed/large sets).
# report_title is intentionally left unset so ejam2report() picks the correct
# header by sitenumber ("EJSCREEN Community Report" vs "EJSCREEN Multisite Summary").
report_response <- function(result, method, to_map, sitenum, ext, res, cache_header = NULL) {
  ext <- tolower(ext)
  if (!ext %in% c("html", "pdf")) {
    res$status <- 400
    res$setHeader("Content-Type", "text/html")
    res$setHeader("Cache-Control", "no-store")
    res$body <- handle_error("fileextension must be 'html' or 'pdf'.", "html")
    return(res)
  }
  # Per-site report links built from a multisite EJAM analysis submit only their
  # own site but carry sitenumber=N, the row that site had in the ORIGINAL
  # analysis (Public-Environmental-Data-Partners/EJAM#348 and EJAM#470). Report
  # on the one submitted row, but label the header "Site N" instead of
  # mislabeling every per-site report as "Site 1". The label pass-through needs
  # an EJAM whose ejam2report() has sitenumber_label (added in EJAM#470); with an
  # older pinned EJAM this falls back to today's behavior (a "Site 1" label), so
  # the change is safe to deploy before the EJAM_VERSION pin advances.
  sitenumber_label <- NULL
  if (sitenum > 1 && NROW(result$results_bysite) == 1) {
    if ("sitenumber_label" %in% names(formals(ejam2report))) {
      sitenumber_label <- sitenum
    }
    sitenum <- 1  # matches ejam2report()'s own out-of-range fallback, now explicit
  }
  # NOTE: no pre-render check here on purpose. A single-site report on a site
  # where the analysis found no residents (e.g. a small buffer in an
  # unpopulated area: /report?lat=33&lon=-112&buffer=1) is a legitimate
  # request: EJAM versions that include
  # Public-Environmental-Data-Partners/EJAM#468 (merged after v3.2022.1)
  # render a real report for it, so the API must let ejam2report() handle it.
  if (is.null(sitenumber_label)) {
    report_output <- ejam2report(result, sitenumber = sitenum, return_html = (ext == "html"),
      launch_browser = FALSE, site_method = method, shp = to_map, fileextension = ext)
  } else {
    report_output <- ejam2report(result, sitenumber = sitenum, sitenumber_label = sitenumber_label,
      return_html = (ext == "html"),
      launch_browser = FALSE, site_method = method, shp = to_map, fileextension = ext)
  }

  # Fail-safe: never ship a no-content result as a 200. When ejam2report()
  # cannot render (it returns a bare logical NA -- e.g. the zero-population
  # single-site case on EJAM versions without EJAM#468), plumber would
  # otherwise serialize that as a 1-byte "application/pdf" 200, an unopenable
  # download that the edge cache then serves for a day. Return a clear,
  # uncacheable (no-store) error page instead.
  if (is.null(report_output) || length(report_output) == 0 ||
      (length(report_output) == 1 && is.logical(report_output))) {
    return(html_error(res, 500, paste0(
      "Report generation returned no content for this request. ",
      "This can happen when the analysis finds no residents at the chosen site ",
      "(population 0 within the requested distance) and the EJAM version deployed here ",
      "cannot yet render a zero-population report. ",
      "Try a larger buffer/radius, or sitenumber=0 for an overall multisite summary.")))
  }

  # Successful reports are deterministic for a given URL + deployed data
  # release, so GET responses are marked edge-cacheable (the Cloudflare proxy
  # at api.ejanalysis.com can then serve repeat requests instantly instead of
  # recomputing for 13-45+ seconds). POST responses pass cache_header = NULL
  # and get an explicit no-store so no intermediary caches them.
  res$setHeader("Cache-Control", if (is.null(cache_header)) "no-store" else cache_header)

  if (ext == "html") {
    res$setHeader("Content-Type", "text/html")
    res$body <- report_output
    return(res)
  }

  # PDF (default). ejam2report() returns a file path or raw bytes.
  if (is.character(report_output) && file.exists(report_output)) {
    res$setHeader("Content-Type", "application/pdf")
    res$setHeader("Content-Disposition", "inline; filename=ejscreen_report.pdf")
    file_size <- file.info(report_output)$size
    res$body <- readBin(report_output, "raw", n = file_size)
    on.exit(unlink(report_output), add = TRUE)
    return(res)
  }
  res$setHeader("Content-Type", "application/pdf")
  res$body <- report_output
  res
}

#* Generate an EJAM report
#* @tag Reports
#* @param lat Latitude of the site
#* @param lon Longitude of the site
#* @param shape A GeoJSON string representing the area of interest
#* @param fips A FIPS code for a specific US Census geography
#* @param buffer The buffer radius in miles. Default if omitted: 3 for lat/lon points; 0 for fips or shape (analyze inside the boundary itself, no buffer).
#* @param radius Synonym for buffer.
#* @param sitenumber Which site to report on. Defaults to 1 (single-site). Use 0 (or "overall") for an aggregate MULTISITE report across all sites. When only ONE site is submitted (as in the per-site report links EJAM builds from multisite results), N > 1 is used to label the report header "Site N" -- that site's row in the original analysis -- instead of "Site 1". (The "Site N" label requires an EJAM release whose ejam2report() has the sitenumber_label parameter -- EJAM#470; with an older pinned EJAM the report falls back to the default "Site 1" header.)
#* @param fileextension "html" or "pdf". Default if omitted: pdf for a single-site report (better page breaks when printing), html for a multisite report (sitenumber=0/overall) -- html is much faster to generate and its interactive map links each site to its own report.
#* @serializer contentType list(type = "application/octet-stream")
#* @get /report
function(lat = NULL, lon = NULL, shape = NULL, fips = NULL, buffer = NULL, radius = NULL, sitenumber=1, fileextension = NULL, res) {
  if (!is.null(radius)) {buffer <- radius}  # radius is a synonym (alias) for buffer
  # Determine the input method and prepare the area.
  method <- if (!is.null(lat) && !is.null(lon)) "latlon" else if (!is.null(shape)) "SHP" else if (!is.null(fips)) "FIPS" else NULL

  # Buffer default depends on the method: points keep the traditional 3-mile
  # ring (a bare point is not an area, so some buffer is required), while FIPS
  # and polygon inputs are already areas -- their natural default is 0, meaning
  # analyze inside the boundary itself with no buffer.
  if (is.null(buffer)) {buffer <- if (identical(method, "latlon")) 3 else 0}

  # Multisite support: lat/lon and fips may be comma-separated lists, one site
  # each. Splitting here lets the same endpoint serve single-site (one value)
  # and multisite (several values) requests. Each FIPS code is a separate site
  # (no fipper() expansion), so a list of counties reports as a list of counties.
  # Parse + validate lat/lon up front so mismatched counts fail cleanly (a 400)
  # instead of silently recycling (e.g. lat=33 & lon=-112,-114) or erroring 500.
  latv <- NULL; lonv <- NULL
  if (identical(method, "latlon")) {
    latv <- as.numeric(trimws(strsplit(paste(lat, collapse = ","), ",")[[1]]))
    lonv <- as.numeric(trimws(strsplit(paste(lon, collapse = ","), ",")[[1]]))
    if (anyNA(latv) || anyNA(lonv)) {
      return(html_error(res, 400, "lat and lon must contain only numeric comma-separated values."))
    }
    if (length(latv) != length(lonv)) {
      return(html_error(res, 400, "lat and lon must have the same number of comma-separated values."))
    }
  }
  area <- switch(
    method %||% "",
    "latlon" = data.frame(lat = latv, lon = lonv),
    "FIPS" = trimws(strsplit(paste(fips, collapse = ","), ",")[[1]]),
    "SHP" = shape,
    NULL
  )

  if (is.null(method) || is.null(area)) {
    return(html_error(res, 400, "You must provide valid coordinates, a shape, or a FIPS code."))
  }

  # Normalize sitenumber. 0 or "overall" -> aggregate multisite report
  # (ejam2report renders results_overall); otherwise a single site N.
  # Invalid values (1.5, Inf, -2, "abc", ...) are a 400, not a silent fallback,
  # since N can become the "Site N" report-header label -- see normalize_sitenumber().
  sitenum <- normalize_sitenumber(sitenumber, default = 1)
  if (is.null(sitenum)) {
    return(html_error(res, 400, "sitenumber must be a positive whole number, or 0 (or 'overall') for an aggregate multisite report."))
  }

  # Default report format (when fileextension is not specified) mirrors the
  # EJAM package's report links (Public-Environmental-Data-Partners/EJAM#443):
  # - single-site report -> pdf: the traditional printable community report,
  #   with proper page breaks for printing.
  # - multisite report (sitenumber=0/overall) -> html: generated several times
  #   faster (no headless-Chrome PDF steps), so the user gets the report much
  #   sooner, and its interactive map lets the user click any site's point to
  #   request that one site's report -- which a static PDF map cannot do.
  # An explicitly passed fileextension always overrides this.
  if (is.null(fileextension)) {
    fileextension <- if (sitenum == 0) "html" else "pdf"
  }

  # Perform the EJAM analysis.
  result <- tryCatch(
    ejamit_interface(area = area, method = method, buffer = as.numeric(buffer), endpoint="report"),
    error = function(e) e
  )

  # If an error occurred during the analysis, return it as an HTML page.
  if (inherits(result, "error")) {
    return(html_error(res, 400, conditionMessage(result)))
  }
  
  # Get submitted polygon shape(s) to appear in report map.
  to_map<-NULL # Clear any previous maps
  if (method == "SHP"){
    to_map<-geojson_sf(area) # TBD: get this returned from ejamit_interface
    to_map$ejam_uniq_id <- seq_len(nrow(to_map)) # one id per feature (multisite-safe)
  }

  # Generate and return the report (HTML or PDF). See report_response() above.
  # GET responses are cacheable (deterministic per URL + data release); 1 day
  # keeps repeat clicks fast while limiting staleness after a redeploy. (Purge
  # the Cloudflare cache, or bump the data release, when redeploying.)
  report_response(result, method, to_map, sitenum, tolower(fileextension), res,
                  cache_header = "public, max-age=86400")
}

#* Generate an EJAM report from a POST body (supports many/large polygons and mixed/large site sets).
#* Same report engine as GET /report, but inputs travel in the request body so there is no URL-length limit.
#* @tag Reports
#* @param sites An array of {lat, lon} site objects
#* @param shape A GeoJSON FeatureCollection string (one or more polygons)
#* @param fips An array of FIPS codes (each one a separate site)
#* @param buffer The buffer radius in miles (out from a polygon edge, or around a point)
#* @param radius Synonym for buffer.
#* @param sitenumber Which site to report on. Defaults to 0 = aggregate MULTISITE report across all sites. When only ONE site is submitted, N > 1 is used to label the report header "Site N" (that site's row in the original analysis) instead of "Site 1" -- see GET /report, including the note that the label requires an EJAM release with ejam2report(sitenumber_label=) (EJAM#470); older pinned EJAM falls back to "Site 1".
#* @param fileextension "html" or "pdf". Default if omitted: html for the (default) multisite report, pdf when a single sitenumber is chosen. See GET /report.
#* @serializer contentType list(type = "application/octet-stream")
#* @post /report
function(sites = NULL, shape = NULL, fips = NULL, buffer = 0, radius = NULL, sitenumber = 0, fileextension = NULL, res) {
  if (!is.null(radius)) {buffer <- radius}  # radius is a synonym (alias) for buffer
  # One method per analysis; require exactly one input so an ambiguous request
  # (e.g. both sites and fips) fails cleanly instead of silently picking one.
  if (sum(!is.null(sites), !is.null(shape), !is.null(fips)) != 1) {
    return(html_error(res, 400, "Provide exactly one of sites, shape, or fips."))
  }
  method <- if (!is.null(sites)) "latlon" else if (!is.null(shape)) "SHP" else "FIPS"
  area <- sites %||% shape %||% fips

  # 0 or "overall" -> aggregate multisite report; otherwise the chosen single site N.
  # Invalid values are a 400, same as GET /report -- see normalize_sitenumber().
  sitenum <- normalize_sitenumber(sitenumber, default = 0)
  if (is.null(sitenum)) {
    return(html_error(res, 400, "sitenumber must be a positive whole number, or 0 (or 'overall') for an aggregate multisite report."))
  }

  # Default format mirrors GET /report (and Public-Environmental-Data-Partners/EJAM#443):
  # html for the multisite report (much faster to generate; interactive map
  # links each site to its own report), pdf for a single-site report (better
  # page breaks when printing). Explicit fileextension always overrides.
  if (is.null(fileextension)) {
    fileextension <- if (sitenum == 0) "html" else "pdf"
  }

  result <- tryCatch(
    ejamit_interface(area = area, method = method, buffer = as.numeric(buffer), endpoint = "report"),
    error = function(e) e
  )
  if (inherits(result, "error")) {
    return(html_error(res, 400, conditionMessage(result)))
  }

  # Submitted polygon(s) to appear in the report map.
  to_map <- NULL
  if (method == "SHP") {
    to_map <- geojson_sf(area)
    to_map$ejam_uniq_id <- seq_len(nrow(to_map))
  }

  report_response(result, method, to_map, sitenum, tolower(fileextension), res)
}

# ---- Site handoff (token-based) for launching the EJAM app pre-loaded ----
# An external app (e.g. EJScreen) POSTs a set of selected places and gets back a
# short token; it then opens the EJAM app at  ...?handoff=<token>  and the app
# fetches GET /handoff/<token> to pre-load those places. This avoids URL-length
# limits when handing off polygons.
#
# NOTE: this draft uses a simple in-process store with a TTL. On Cloud Run with
# more than one instance, a token created on instance A may not resolve on
# instance B. For production use a shared store (GCS object / Firestore / Redis)
# or run the service with min-instances=1 and a single max instance.
.handoff_store    <- new.env(parent = emptyenv())
.handoff_ttl_secs <- 60 * 60  # tokens live for 1 hour
.handoff_env_numeric_or_default <- function(name, default_value) {
  val <- suppressWarnings(as.numeric(Sys.getenv(name, as.character(default_value))))
  if (!is.finite(val) || val <= 0) {
    return(default_value)
  }
  val
}
.handoff_max_tokens <- .handoff_env_numeric_or_default("HANDOFF_MAX_TOKENS", 64)
.handoff_max_payload_bytes <- .handoff_env_numeric_or_default("HANDOFF_MAX_PAYLOAD_BYTES", 1048576)  # 1 MiB
.handoff_token_collision_retries <- as.integer(.handoff_env_numeric_or_default("HANDOFF_TOKEN_COLLISION_RETRIES", 8))

.handoff_new_token <- function() {
  # Tokens are bearer credentials, so REQUIRE a cryptographically-secure RNG --
  # fail fast rather than silently fall back to a guessable token.
  if (!requireNamespace("openssl", quietly = TRUE)) {
    stop("The 'openssl' package is required to mint secure handoff tokens.")
  }
  paste(as.character(openssl::rand_bytes(18)), collapse = "")  # 36 hex chars, CSPRNG
}
.handoff_purge_expired <- function() {
  now <- as.numeric(Sys.time())
  for (k in ls(.handoff_store)) {
    if (.handoff_store[[k]]$expires < now) {
      rm(list = k, envir = .handoff_store)
    }
  }
}

#* Store a set of selected sites for handoff to the EJAM app; returns a token.
#* @tag Handoff
#* @param method One of "latlon", "FIPS", or "SHP" (optional; inferred if omitted)
#* @param sites Array of {lat, lon} site objects
#* @param fips Array of FIPS codes (each one a separate site)
#* @param shape A GeoJSON FeatureCollection of polygons
#* @param radius Buffer radius in miles. Default if omitted: 0 when the payload has fips or shape and no sites (analyze inside the boundary itself, no buffer); no default when sites are present (the EJAM app applies its own point default).
#* @param buffer Synonym for radius.
#* @post /handoff
function(method = NULL, sites = NULL, fips = NULL, shape = NULL, radius = NULL, buffer = NULL, res) {
  if (is.null(radius)) {radius <- buffer}  # buffer is a synonym (alias) for radius
  .handoff_purge_expired()
  if (is.null(sites) && is.null(fips) && is.null(shape)) {
    res$status <- 400
    return(handle_error("Provide sites, fips, or shape to hand off."))
  }
  if (is.null(method)) {
    method <- if (!is.null(sites)) "latlon" else if (!is.null(shape)) "SHP" else "FIPS"
  }
  # FIPS and polygon inputs are already areas, so their natural buffer default
  # is 0 (analyze inside the boundary itself). Store the explicit 0 rather than
  # leaving radius NULL: an absent field serializes as JSON {} in the GET
  # /handoff/<token> payload, which clients can misparse (a zero-length list,
  # not NULL, in R -- it crashed the EJAM app's launch handler; see
  # Public-Environmental-Data-Partners/EJAM#465). Keyed on the payload CONTENT
  # (fips/shape present, sites absent), not the method string: method is
  # caller-provided and unvalidated, so e.g. {method:"latlon", fips:[...]} or a
  # lowercase "fips" would dodge a method-based default -- and the EJAM app
  # likewise dispatches on payload content, ignoring method. When sites are
  # present they take precedence in the app (points), which applies its own
  # point-method default/minimum at the radius slider, so no default is stored:
  # a bare point needs SOME positive buffer, not 0.
  if (is.null(radius) && is.null(sites) && (!is.null(fips) || !is.null(shape))) {radius <- 0}
  if (is.finite(.handoff_max_tokens) && length(ls(.handoff_store)) >= .handoff_max_tokens) {
    res$status <- 429
    return(handle_error(sprintf("Handoff token capacity reached (max %d active tokens). Retry after a short delay; tokens expire after 1 hour.", as.integer(.handoff_max_tokens))))
  }
  payload <- list(method = method, sites = sites, fips = fips, shape = shape, radius = radius)
  payload_raw <- serialize(payload, connection = NULL)
  payload_bytes <- length(payload_raw)
  if (is.finite(.handoff_max_payload_bytes) && payload_bytes > .handoff_max_payload_bytes) {
    res$status <- 413
    return(handle_error(sprintf("Handoff payload size %d bytes exceeds limit of %d bytes.", payload_bytes, as.integer(.handoff_max_payload_bytes))))
  }
  token <- NULL
  for (attempt in seq_len(.handoff_token_collision_retries)) {
    candidate <- .handoff_new_token()
    if (is.null(.handoff_store[[candidate]])) {
      token <- candidate
      break
    }
  }
  if (is.null(token)) {
    res$status <- 503
    return(handle_error("Unable to mint a unique handoff token; retry request."))
  }
  expires <- floor(as.numeric(Sys.time())) + .handoff_ttl_secs  # integer epoch seconds
  .handoff_store[[token]] <- list(
    payload_raw = payload_raw,
    expires = expires
  )
  # The token is a bearer credential -- don't let it sit in shared/proxy caches.
  res$setHeader("Cache-Control", "no-store")
  list(token = token, expires = expires)
}

#* Retrieve a previously stored handoff payload by token.
#* @tag Handoff
#* @param token The handoff token returned by POST /handoff
#* @get /handoff/<token>
function(token, res) {
  .handoff_purge_expired()
  entry <- .handoff_store[[token]]
  if (is.null(entry)) {
    res$status <- 404
    return(handle_error("Unknown or expired handoff token."))
  }
  res$setHeader("Cache-Control", "no-store")  # bearer-credential payload, not cacheable
  unserialize(entry$payload_raw)
}

# /assets ####

#* Serve static assets from the ./assets directory at /assets.
#* NOTE: do NOT mount at root "/", which shadows plumber's OpenAPI/Swagger
#* docs UI at /__docs__/ and makes the documentation page return 404.
#* @assets ./assets /assets
list()
