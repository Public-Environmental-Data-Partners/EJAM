

#' Get URL(s) of HTML summary reports for use with EJAM-API
#' @seealso [ejamapi()] [url_ejamapp()] [url_package()]
#' @details
#' - Relies on the EJAM REST API, whose source code is at
#'   https://github.com/Public-Environmental-Data-Partners/EJAM-API
#'   (the API base URL itself comes from `url_package("api")`; see the `ejam_api_url`
#'   field in DESCRIPTION).
#'
#' - To construct a "deep link" that launches the live EJAM *app* (not the API)
#'   pre-loaded with sites, see [url_ejamapp()], which uses the same query
#'   vocabulary (lat, lon, fips, shape, radius, handoff).
#'
#' - Accepts a subset of [ejamit()]'s input-parameter names (sitepoints, lat, lon, radius,
#'   fips, shapefile); it does not accept every [ejamit()]/[ejam2report()] option (see the
#'   note below on unsupported options).
#'
#' - The API honors the `sitenumber` parameter passed through to [ejam2report()]:
#'   `sitenumber = 1` requests a single-site report (the API's per-request default when
#'   none is supplied), and `sitenumber = 0` (or "overall") produces an aggregate
#'   *multisite* report. (Note `url_ejamapi()`'s own default is `sitenumber = "each"` --
#'   see the parameter docs below.) When a URL sends only ONE site to the API but says
#'   `sitenumber=N`, N identifies which row that site was in the original multisite
#'   analysis, so the API can label the report header "Site N" instead of mislabeling
#'   every per-site report as Site 1
#'   (Public-Environmental-Data-Partners/EJAM#348) -- the per-site URLs this
#'   function returns carry that. The API leaves the
#'   report title to [ejam2report()], which uses "EJSCREEN Community Report" for a
#'   single site and "EJSCREEN Multisite Summary" for the aggregate. Many or large
#'   polygons can exceed URL length for this GET-based path; the API also provides
#'   a POST `/report` endpoint for those. The API does not yet accept every
#'   [ejam2report()] option (e.g. logo_path, thresholds & threshnames,
#'   radius_donut_lower_edge).
#'
#' @param sitepoints see [ejamit()]
#' @param lat,lon can be provided as vectors of coordinates instead of providing sitepoints table
#' @param radius  analysis radius in miles; see [ejamit()]. Default is 3 miles for point
#'   (lat/lon/sitepoints) analysis, but 0 (no buffer) when fips or shapefile is specified.
#'
#' @param fips  see [ejamit()]
#'
#' @param shapefile  see [ejamit()], but each polygon is encoded as geojson string
#'   which might get too long for encoding in a URL for the API using GET
#' @param shape,shp aliases (synonyms) for shapefile
#' @param dTolerance number of meters tolerance to use in [sf::st_simplify()] to simplify polygons
#'   to fit as url-encoded text geojson. Only used when a shapefile/polygon is provided; ignored
#'   for point (lat/lon) or fips analysis.
#'
#' @param as_html if FALSE (default) returns plain character URL(s); if TRUE returns HTML
#'   hyperlinks (via [url_linkify()]) suitable for use in a [DT::datatable()] or other HTML context
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values. Default NULL
#'   (and an explicitly passed NULL) resolves to the EJAM API base URL from
#'   DESCRIPTION (`ejam_api_url`), via [url_package()] with type="api".
#' @param baseurl do not change unless endpoint actually changed. Default NULL
#'   (and an explicitly passed NULL) resolves to the DESCRIPTION `ejam_api_url`
#'   followed by "/report?". See [ejamapi()] for a better way to handle choice of endpoint.
#'
#' @param sitenumber controls how many URLs are returned and which site(s) each covers:
#'
#'  - `"each"` (or `-1`) -- **the default** -- returns a vector of URLs, one per site
#'    (one single-site report per site). Unlike [ejam2report()]/[ejam2map()], which never
#'    return a vector, the `url_*` helpers can; that vector-per-site output is the main
#'    reason this parameter exists. Each URL sends only its own site to the API but also
#'    carries `sitenumber=N` (that site's row number in the inputs) so the API labels the
#'    report header "Site N" instead of calling every per-site report Site 1
#'    (Public-Environmental-Data-Partners/EJAM#348).
#'
#'  - `"overall"` (or `0`, `NULL`, or `""`) -- returns a single URL requesting one
#'    aggregate *multisite* report combining all sites (sent to the API as `sitenumber=0`;
#'    assumes >1 site was provided).
#'
#'  - `N` (a number `> 0`) -- returns a single URL for just the Nth site found in the
#'    inputs (e.g. the 3rd point, fips, or polygon). The URL carries `sitenumber=N` when
#'    `N > 1` (as for "each" above; omitted when N is 1 since Site 1 is the API's default label).
#'
#'  Single-site auto-override: when the inputs resolve to exactly one site (one row of
#'  sitepoints, one fips code, or one polygon), sitenumber is coerced to `1` regardless of what
#'  was requested, so a lone place yields a single-site report URL (with no `sitenumber`
#'  parameter in it).
#'
#' @param ... a named list of other query parameters passed to the API,
#'   to allow for expansion of allowed parameters
#'
#' @return vector of character string URLs -- see details on sitenumber parameter
#'
#' @examples
#'
#'  pts = data.frame(lat=37.64122, lon=-122.41065)
#'  pts2 = data.frame(lat = c(37.64122, 43.92249), lon = c(-122.41065, -72.663705))
#'  pts10 = testpoints_10
#'  pts_fname = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM")
#'
#'   # vector of 1-site report URLs
#'  x = url_ejamapi(pts_fname)
#'  x = url_ejamapi(sitepoints = pts2)
#'  x_bysite = url_ejamapi(pts10, radius = 3.1, sitenumber = "each")
#'
#'  ## 1 summary report URL - may not be implemented yet
#'  # x_overall = url_ejamapi(pts10, radius = 3.1, sitenumber = "overall")
#'
#'  # FIPS Census units
#'  y = url_ejamapi(fips = c("050014801001", "050014802001"))
#'  ## blockgroups may not be implemented yet
#'  # y = url_ejamapi(fips = testinput_fips_mix)
#'
#'  # Polygons
#'  shp = testinput_shapes_2[2, c("geometry", "FIPS", "NAME")]
#'  z = url_ejamapi(shapefile = shp)
#'
#'  # HTML hyperlinks (e.g. for a DT::datatable cell) instead of plain URLs
#'  x_links = url_ejamapi(pts2, as_html = TRUE, linktext = "Report")
#'
#'  \dontrun{
#'  browseURL(paste0(url_package("api"), "/report?lat=33&lon=-112&buffer=4"))  # API base from DESCRIPTION
#'
#'  browseURL(x[1])
#'  browseURL(y[1])
#'  browseURL(z[1])
#' }
#'
#' @param version optional EJAM version tag (e.g. "3.2024.0") sent to the API as
#'   version=<ver> so the API can serve the matching data vintage. Default NULL
#'   resolves to the installed package Version (from DESCRIPTION).
#'
#' @param fileextension report format requested from the API, sent as
#'   fileextension=<ext> on each generated report URL. Default "auto" picks the
#'   format by report type: "html" for an aggregate *multisite* report URL
#'   (sitenumber 0/"overall" covering more than one site) since HTML renders
#'   several times faster and displays directly in the browser tab, but "pdf"
#'   for *single-site* report URLs (the traditional printable community report).
#'   Use "html" or "pdf" to force one format for all URLs, or NULL/"" to omit
#'   the parameter and get the API's own default. Case/whitespace are
#'   normalized; any other value is an error (values are placed in a URL, so
#'   arbitrary text is rejected rather than encoded). Only applied to actual
#'   API /report URLs, never to app-fallback or ifna links.
#'
#' @export
#'
url_ejamapi = function(

  sitepoints = NULL, lat = NULL, lon = NULL,
  radius = 3,

  ## unused so far:
  # radius_donut_lower_edge = 0,
  # maxradius = 31.07,
  # avoidorphans = FALSE,
  # quadtree = NULL, # not relevant

  fips = NULL,
  shapefile = NULL,
  dTolerance = 100, # 100 meters tolerance to simplify polygons to fit as url-encoded text geojson

  ## unused so far:
  # countcols = NULL,
  # wtdmeancols = NULL,
  # calculatedcols = NULL,
  # calctype_maxbg = NULL,
  # calctype_minbg = NULL,
  # subgroups_type = "nh",
  # include_ejindexes = TRUE,
  # calculate_ratios = TRUE,
  # extra_demog = TRUE,
  # need_proximityscore = FALSE,
  # infer_sitepoints = FALSE,
  # need_blockwt = TRUE,

  # thresholds = list(80, 80),
  # threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile, names_ej_supp_state_pctile)),
  # threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"),

  # updateProgress = NULL,
  # updateProgress_getblocks = NULL,
  # progress_all = NULL,
  # in_shiny = FALSE,
  # quiet = TRUE,
  # silentinteractive = FALSE,
  # called_by_ejamit = TRUE,
  # testing = FALSE,
  # showdrinkingwater = TRUE,
  # showpctowned = TRUE,
  # download_city_fips_bounds = TRUE,
  # download_noncity_fips_bounds = FALSE,

  linktext = "Report",
  as_html = FALSE,
  ifna = NULL,
  baseurl = NULL,

  sitenumber = "each",

  version = NULL,

  fileextension = "auto",

  ...,

  shape = NULL, shp = NULL   # name-only aliases (after ... so positional args still flow into ... unchanged)
) {

  if (is.null(shapefile) && !is.null(shape)) {shapefile <- shape}
  if (is.null(shapefile) && !is.null(shp))   {shapefile <- shp}

  # Single source of truth: the EJAM API base URL lives in DESCRIPTION (ejam_api_url),
  # read via url_package("api"). Default NULL (and an explicitly passed NULL) resolve here.
  if (is.null(ifna))    {ifna    <- url_package("api")}
  if (is.null(baseurl)) {baseurl <- paste0(url_package("api"), "/report?")}

  ## unused so far:
  {
    xxx = "
  @param radius_donut_lower_edge
  @param maxradius
  @param avoidorphans
  @param quadtree

  @param countcols
  @param wtdmeancols
  @param calculatedcols
  @param calctype_maxbg
  @param calctype_minbg
  @param subgroups_type
  @param include_ejindexes
  @param calculate_ratios
  @param extra_demog
  @param need_proximityscore
  @param infer_sitepoints
  @param need_blockwt
  @param thresholds
  @param threshnames
  @param threshgroups
  @param updateProgress
  @param updateProgress_getblocks
  @param progress_all
  @param in_shiny
  @param quiet
  @param silentinteractive
  @param called_by_ejamit
  @param testing
  @param showdrinkingwater
  @param showpctowned
  @param download_city_fips_bounds
  @param download_noncity_fips_bounds
  "
  }
  if (is.null(linktext)) {linktext <- paste0("Report")}
  # print( rlang::list2(...) )
  ###################### #
  #   ... args  ####
  and_other_query_terms = urls_from_keylists(keylist_bysite = ..., baseurl = "")
  if (length(and_other_query_terms) > 0 && !(all(and_other_query_terms %in% ""))) {and_other_query_terms <- paste0("&", and_other_query_terms)}
  # EJAM version tag, so the API can serve the matching data vintage. Default = package Version.
  if (is.null(version)) {version <- tryCatch(as.character(utils::packageVersion("EJAM")), error = function(e) NULL)}
  if (!is.null(version) && length(version) == 1 && nzchar(version)) {
    if (length(and_other_query_terms) == 0) {and_other_query_terms <- ""}
    and_other_query_terms <- paste0(and_other_query_terms, "&version=", version)
  }
  ################################################## #  ################################################## #
  # (baseurl and ifna were already resolved from url_package("api") near the top.)
  shp_one_site_fallback_url <- "https://ejanalysis.com/ejamapp"
  # see https://github.com/Public-Environmental-Data-Partners/EJAM-API/tree/main
  # baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?"
  # e.g.,
  # https://ejamapi-84652557241.us-central1.run.app/report?lat=33&lon=-112&buffer=4
  ################################################## #  ################################################## #

  ################################################## #  sitetype  --------------------- -
  # sitetype ####
  # and convert any lat,lon to sitepoints
  sites <- sites_from_input(sitepoints = sitepoints, lat = lat, lon = lon, fips = fips, shapefile = shapefile)
  sitepoints <- sites$sitepoints
  shapefile <- sites$shapefile
  fips <- sites$fips
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  ## latlon_from_regid ####
  if (is.null(sites$sitetype)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- "latlon"
    }
  }
  ################################################## #  sitenumber --------------------- -

  # sitenumber (overall vs 1-site) ####

  # After normalization here:
  #  0 means "overall" report (all sites in one URL, sent to the API as sitenumber=0)
  # -1 means "each" site report, in a vector of URLs (each URL sends 1 site to the API,
  #      plus sitenumber=N saying which row that site was in the inputs, so the report
  #      header can be labeled Site N -- Public-Environmental-Data-Partners/EJAM#348)
  #  N  means Nth site report (1 URL sending just site N, plus sitenumber=N when N > 1)

  if (length(sitenumber) > 1) {stop("invalid value for sitenumber")}
  if (is.null(sitenumber) || all(is.na(sitenumber)) || length(sitenumber) == 0 || all(sitenumber %in% "") || sitenumber %in% c(0, "0", "overall")) {
    sitenumber <- 0  # "overall"
    # provide all the sites in one URL, and pass sitenumber=0 to the API

  } else {
    if (sitenumber %in% c("each", -1)) {
      sitenumber <- -1  # each site (vector of URLs)
    } else {
      sitenumber <- as.numeric(sitenumber)  # Nth site
    }
  }
  ###################################### #  shapefile  ###################################### #
  # > shapefile ####
  if ("shp" %in% sitetype) {

    if (missing(radius) || is.null(radius) || all(radius %in% c(0, "", NA))) {radius <- 0}
    # geojson format
    # %7B"type"%3A"FeatureCollection"%2C"features"%3A%5B%7B"type"%3A"Feature"%2C"properties"%3A%7B%7D%2C"geometry"%3A%7B"coordinates"%3A%5B%5B%5B-112.01991856401462%2C33.51124624304089%5D%2C%5B-112.01991856401462%2C33.47010908826502%5D%2C%5B-111.95488826248605%2C33.47010908826502%5D%2C%5B-111.95488826248605%2C33.51124624304089%5D%2C%5B-112.01991856401462%2C33.51124624304089%5D%5D%5D%2C"type"%3A"Polygon"%7D%7D%5D%7D

    if (NROW(shapefile) ==  1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

    if ("shp" %in% sitetype) {
      # if (!is.null(shapefile)) {
      bad <-  (sf::st_is_empty(shapefile))
      url_of_report <- NULL

      if (sitenumber == 0) {
        # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
        # remove empty geography rows first
        if (any(!bad)) {
        geotxt <- shape2geojson(
          sf::st_simplify(shapefile[!bad,], dTolerance = dTolerance), # SIMPLIFY POLYGONS to fit as url-encoded text
          combine_in_one_string = TRUE) # overall summary multisite report
        } else {
          geotxt <- NA
        }
        url_of_report <- paste0(
          urls_from_keylists(
            baseurl = baseurl,
            keylist_bysite = list(shape=geotxt, buffer=radius, sitenumber=sitenumber)
          ), and_other_query_terms
        )
        url_of_report[is.na(geotxt)] <- NA # later will convert to ifna
      }
      if (sitenumber > 0) {
        # 1 site's URL:  return only 1 URL, 1 of the sites, and do not pass any sitenumber parameter to the API (since we only send site N to the API so it would be confusing to pass site 3 and have to tell the API it is site 1 of what was passed)
        if (bad[sitenumber]) {
          url_of_report <- NA_character_
        } else {
          url_of_report <- shp_one_site_fallback_url
        }
        sitenumber <- "" # now omit this from the URL used in API
      }
      if (!is.null(sitenumber) && -1 %in% sitenumber) {
        # "each" site's URL: these are app-fallback links (not API /report URLs) until
        # per-polygon API report links are implemented, so no sitenumber is added here.
        # Once implemented, they should carry sitenumber=1..N like the latlon and fips
        # branches do, so the API labels each report with the site's original row number
        # (see Public-Environmental-Data-Partners/EJAM#348).
        url_of_report <- rep(shp_one_site_fallback_url, NROW(shapefile))
        if (any(bad)) {
        url_of_report[bad] <- NA_character_
        }
        sitenumber <- NULL # now omit this from the URL used in API ?
      }
    } else {
      url_of_report <- NA # later will convert to ifna
    }
  } else {
    ###################################### # fips  ###################################### #
    # > fips #####
    if ("fips" %in% sitetype) {
      if (missing(radius) || is.null(radius) || all(radius %in% c(0, "", NA))) {radius <- 0}

      # suppressWarnings({
      #   ftype <- fipstype(fips)
      # })
      # if (!all(ftype %in% "blockgroup")) {
      #   # warning("fips other than blockgroup may be work in progress")
      # }
      if (!is.null(fips)) {

        if (NROW(fips) == 1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

        if (sitenumber == 0) {
          # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
          fips <- paste0(fips, collapse = ",") ## *** check this is the expected format in the API
        }
        if (sitenumber > 0) {
          # 1 site's URL: return only 1 URL, sending only site N to the API, plus (when N > 1)
          # sitenumber=N so the API can label the report header "Site N" -- the row this site
          # had in the original set of inputs -- instead of "Site 1"
          # (Public-Environmental-Data-Partners/EJAM#348).
          fips <- fips[sitenumber]  # 1-site report
          if (sitenumber == 1) {sitenumber <- ""} # omit from URL; Site 1 is the API's default label anyway
        }
        if (-1 %in% sitenumber) {
          # "each" site's URL: provide vector of urls, 1 site in each, each carrying
          # sitenumber=1..N so the API labels each report with that site's original row
          # number instead of calling every one "Site 1"
          # (Public-Environmental-Data-Partners/EJAM#348)
          sitenumber <- seq_along(fips)
        }

        url_of_report <- paste0(
          urls_from_keylists(
            baseurl = baseurl,
            keylist_bysite = list(fips=fips, buffer=radius, sitenumber=sitenumber)
          ), and_other_query_terms
        )
        # url_of_report <- paste0(
        #   baseurl,
        #   "fips=", fips, "&",
        #   "buffer=", radius, "&",
        #   "sitenumber=", sitenumber,
        #   and_other_query_terms
        # )
        #
        url_of_report[is.na(fips)] <- NA # later will convert to ifna
        # url_of_report[!(ftype %in% "blockgroup")] <- NA
      } else {
        url_of_report <- NA # later will convert to ifna
      }
    } else {
      ###################################### # sitepoints  ###################################### #
      # > sitepoints ####
      if ("latlon" %in% sitetype) {

        if (NROW(sitepoints) == 1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

        if (sitenumber == 0) {
          # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
          x <- sitepoints
          # x <- latlon_from_anything(sitepoints, interactiveprompt = F) # do we want this actually ?? see notes in sites_from_input() and related
          lat <- x$lat
          lon <- x$lon
          # Note slight changes can occur in lat,lon values if using paste(lat,lon,sep=',) instead of format() as per ?as.character()
          lat <- paste0(lat, collapse = ",")
          lon <- paste0(lon, collapse = ",")
        }
        if (sitenumber > 0) {
          # 1 site's URL: return only 1 URL, sending only site N to the API, plus (when N > 1)
          # sitenumber=N so the API can label the report header "Site N" -- the row this site
          # had in the original set of inputs -- instead of "Site 1"
          # (Public-Environmental-Data-Partners/EJAM#348).
          x <- sitepoints[sitenumber, , drop = FALSE]  # 1-site report
          if (sitenumber == 1) {sitenumber <- ""} # omit from URL; Site 1 is the API's default label anyway
          lat <- x$lat
          lon <- x$lon
        }
        if (length(sitenumber) == 1 && sitenumber == -1) {
          # "each" site's URL: provide vector of urls, 1 site in each, each carrying
          # sitenumber=1..N so the API labels each report with that site's original row
          # number instead of calling every one "Site 1"
          # (Public-Environmental-Data-Partners/EJAM#348)
          x <- sitepoints
          sitenumber <- seq_len(NROW(x))
          lat <- x$lat
          lon <- x$lon
        }

        if (!is.null(lat) && !is.null(lon)) {
          url_of_report <- paste0(
            urls_from_keylists(
              baseurl = baseurl,
              keylist_bysite = list(lat=lat, lon=lon, buffer=radius, sitenumber=sitenumber)
            ), and_other_query_terms
            )
          # url_of_report <- paste0(
          #   baseurl,
          #   "lat=", lat, "&",
          #   "lon=", lon, "&",
          #   "buffer=", radius, "&",
          #   "sitenumber=", sitenumber,
          #   and_other_query_terms
          # )
          url_of_report[is.na(lat) | is.na(lon)] <- NA # later will convert to ifna
        } else {
          url_of_report <- NA # later will convert to ifna
        }
      } else {
        ###################################### # none of the above  ###################################### #
        url_of_report <- NA # later will convert to ifna
      }
    }
  }
  ###################### #
  # fileextension (report format) ####
  # Appended here, after the branches above, because "auto" depends on the kind
  # of report each URL requests: at this point sitenumber is 0 only for an
  # aggregate MULTISITE report over >1 site (single-site links carry N or omit
  # it, and "each" links carry 1..N), so auto = html for the multisite summary (renders several
  # times faster; the link opens in a browser tab) and pdf for single-site
  # reports (the traditional printable community report). Applied only to
  # actual API /report URLs -- never to the app-fallback links used for
  # single-polygon sites, nor to NA entries that become ifna below. Validated
  # strictly rather than URL-encoded: these can be raw URLs (as_html = FALSE),
  # so unvalidated text could inject extra query parameters or break the URL.
  if (!is.null(fileextension) && !identical(fileextension, "")) {
    fileextension <- tolower(trimws(as.character(fileextension)))
    # Note %in% returns FALSE (not NA) for NA input, so NA already failed this
    # validation with the intended message; is.na() just makes that explicit.
    if (length(fileextension) != 1 || is.na(fileextension) || !fileextension %in% c("auto", "html", "pdf")) {
      stop("fileextension must be 'auto', 'html', or 'pdf' (or NULL or '' to omit it from the URL)")
    }
    if (fileextension == "auto") {
      fileextension <- if (identical(sitenumber, 0)) "html" else "pdf"
    }
    is_api_report_url <- !is.na(url_of_report) & startsWith(as.character(url_of_report), baseurl)
    url_of_report[is_api_report_url] <- paste0(url_of_report[is_api_report_url], "&fileextension=", fileextension)
  }
  ###################### #

  urlx <- url_of_report
  ok <- !(is.na(urlx)) # so !ok means bad/NA
  # urlx[ok] <- paste0(urlx[ok], and_other_query_terms) # "&", other_query_terms)   # already done now

  ###################### #
  # default URL if bad ####
  # use a default URL if bad input, and only linkify when not NA

  urlx[!ok] <- ifna  # possibly user set ifna to NA or else it is a default url
  ok <- !is.na(urlx)  # now ok means it was a good  input or bad input, except if ifna was set to NA, that is not ok so we can avoid urlencoding that type of NA !

  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE ***
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna

  return(urlx)
}
################################################### #################################################### #
